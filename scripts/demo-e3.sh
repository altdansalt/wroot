#!/usr/bin/env bash
# End-to-end demo of wasmdev (experiment e3): native host + wasm control
# plane + wasm workloads and services. Prints measurements at the end.
#
#   scripts/demo-e3.sh            # builds what's missing, runs the demo
#   KEEP=1 scripts/demo-e3.sh     # leave the server running afterwards
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$PWD
export PATH="$HOME/.cargo/bin:/usr/local/go/bin:$PATH"

PORT=${PORT:-8780}
TOKEN=${TOKEN:-demo-token-$RANDOM$RANDOM}
DATA=${DATA:-$ROOT/data-demo}
BUILD=$ROOT/build
API=http://127.0.0.1:$PORT
mkdir -p "$BUILD"

say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
api() { # api METHOD PATH [curl args...]
  local m=$1 p=$2; shift 2
  curl -sS -X "$m" -H "Authorization: Bearer $TOKEN" "$API$p" "$@"
}
now_ms() { date +%s%3N; }

say "build"
if [[ ! -x host/target/release/wasmdev-host || -n "${REBUILD:-}" ]]; then
  (cd host && cargo build --release -j2)
fi
(cd control && GOOS=wasip1 GOARCH=wasm go build -o "$BUILD/control.wasm" .)
(cd examples && GOOS=wasip1 GOARCH=wasm go build -o "$BUILD/hello.wasm" ./hello \
             && GOOS=wasip1 GOARCH=wasm go build -o "$BUILD/httphello.wasm" ./httphello)
ls -la "$BUILD"

start_host() {
  host/target/release/wasmdev-host --control "$BUILD/control.wasm" \
    --listen "127.0.0.1:$PORT" --data "$DATA" --token "$TOKEN" \
    --service-ports 8100-8199 >>"$DATA.log" 2>&1 &
  HOST_PID=$!
  for _ in $(seq 1 600); do
    curl -sf "$API/healthz" >/dev/null 2>&1 && return 0
    sleep 0.05
  done
  echo "host did not come up"; cat "$DATA.log"; exit 1
}
stop_host() { kill "$HOST_PID" 2>/dev/null || true; wait "$HOST_PID" 2>/dev/null || true; }
trap '[[ -z "${KEEP:-}" ]] && stop_host' EXIT

say "start host (cold: empty module cache)"
rm -rf "$DATA" "$DATA.cache" "$DATA.log"
t0=$(now_ms); start_host; t1=$(now_ms)
echo "host+control plane ready in $((t1 - t0)) ms (includes compiling control.wasm)"
grep 'control plane' "$DATA.log" | head -1

say "GET / (agent-facing API description)"
curl -sS "$API/" | head -8; echo "..."

say "auth is enforced"
curl -sS -o /dev/null -w "no token -> HTTP %{http_code}\n" -X POST "$API/v1/workspaces"

say "create workspace + upload hello.wasm"
WS=$(api POST /v1/workspaces | jq -r .id); echo "workspace: $WS"
api PUT "/v1/workspaces/$WS/files/hello.wasm" --data-binary "@$BUILD/hello.wasm" | jq -c .
api POST "/v1/workspaces/$WS/files" -d '{"files":{"notes/readme.txt":"hi from the agent\n"}}' | jq -c .

say "run hello.wasm (first run compiles the module)"
api POST "/v1/workspaces/$WS/run" -d '{"module":"hello.wasm","args":["world"],"env":{"GREETING":"hey"}}' | tee /tmp/wasmdev-run1.json | jq .
FIRST_LOAD=$(jq .load_ms /tmp/wasmdev-run1.json)

say "run with stdin, writes to /work, nonzero exit, timeout"
api POST "/v1/workspaces/$WS/run" -d '{"module":"hello.wasm","args":["stdin"],"stdin":"shout this"}' | jq -c '{exit_code,stdout,cache,load_ms}'
api POST "/v1/workspaces/$WS/run" -d '{"module":"hello.wasm","args":["write"]}' | jq -c '{exit_code,stderr}'
echo -n "workspace file written by wasm: "; api GET "/v1/workspaces/$WS/files/out.txt"
api POST "/v1/workspaces/$WS/run" -d '{"module":"hello.wasm","args":["fail"]}' | jq -c '{state,exit_code,stderr}'
api POST "/v1/workspaces/$WS/run" -d '{"module":"hello.wasm","args":["spin"],"timeout_ms":300}' | jq -c '{state,error,wall_ms}'
api GET "/v1/workspaces/$WS/files/" | jq -c '[.entries[].path]'

say "async run + job polling"
JOB=$(api POST "/v1/workspaces/$WS/run?async=1" -d '{"module":"hello.wasm","args":["async"]}' | jq -r .job_id)
echo "job: $JOB"; api GET "/v1/jobs/$JOB?wait=1" | jq -c '{state,exit_code,stdout}'

say "control plane stays responsive while a CPU-bound job runs"
SPIN=$(api POST "/v1/workspaces/$WS/run?async=1" -d '{"module":"hello.wasm","args":["spin"],"timeout_ms":5000}' | jq -r .job_id)
sleep 0.2
api POST "/v1/workspaces/$WS/run" -d '{"module":"hello.wasm","args":["concurrent"]}' -w 'run during spin: %{time_total}s\n' -o /dev/null
api DELETE "/v1/jobs/$SPIN" -o /dev/null -w 'kill spin job: HTTP %{http_code}\n'
api GET "/v1/jobs/$SPIN?wait=1" | jq -c '{state,error,wall_ms}'

say "tool registry: register hello as a tool, run it by name"
api PUT "/v1/tools/hello?argv0=hello&description=demo%20tool" --data-binary "@$BUILD/hello.wasm" | jq -c .
api GET /v1/tools | jq -c '[.tools[].name]'
api POST "/v1/workspaces/$WS/run" -d '{"module":"hello","args":["via-tool"]}' | jq -c '{exit_code,stdout,cache}'

say "latency: 20 trivial runs (warm cache)"
: >/tmp/wasmdev-lat.txt
for i in $(seq 1 20); do
  api POST "/v1/workspaces/$WS/run" -d '{"module":"hello.wasm"}' \
    -w '\n%{time_total}\n' -o /tmp/wasmdev-lat-body.json >/tmp/wasmdev-lat-t.txt
  http_ms=$(python3 -c "print(float(open('/tmp/wasmdev-lat-t.txt').read().split()[-1])*1000)")
  wall_ms=$(jq .wall_ms /tmp/wasmdev-lat-body.json)
  echo "$http_ms $wall_ms" >>/tmp/wasmdev-lat.txt
done
LAT=$(python3 - <<'EOF'
import statistics as st
rows=[tuple(map(float,l.split())) for l in open('/tmp/wasmdev-lat.txt')]
http=[r[0] for r in rows]; wall=[r[1] for r in rows]; ov=[h-w for h,w in rows]
print(f"http_p50={st.median(http):.2f}ms wall_p50={st.median(wall):.2f}ms overhead_p50={st.median(ov):.2f}ms (min http {min(http):.2f}, max {max(http):.2f})")
EOF
)
echo "$LAT"

say "baseline: wasmtime CLI running the same module (process + instantiate)"
if command -v ~/.wasmtime/bin/wasmtime >/dev/null; then
  ~/.wasmtime/bin/wasmtime run "$BUILD/hello.wasm" >/dev/null # warm its cache if enabled
  t0=$(date +%s%N); for i in $(seq 1 5); do ~/.wasmtime/bin/wasmtime run "$BUILD/hello.wasm" >/dev/null; done; t1=$(date +%s%N)
  echo "wasmtime run hello.wasm: $(( (t1 - t0) / 5000000 )) ms avg (no compile cache configured)"
fi

say "service: start httphello and curl it"
api PUT "/v1/workspaces/$WS/files/httphello.wasm" --data-binary "@$BUILD/httphello.wasm" >/dev/null
t0=$(date +%s%N)
SVC_JSON=$(api POST "/v1/workspaces/$WS/services" -d '{"module":"httphello.wasm"}')
echo "$SVC_JSON" | jq -c .
URL=$(echo "$SVC_JSON" | jq -r .url); SID=$(echo "$SVC_JSON" | jq -r .service_id)
until curl -sf "$URL" >/dev/null 2>&1; do sleep 0.005; done
t1=$(date +%s%N); COLD_READY=$(( (t1 - t0) / 1000000 ))
curl -sS "$URL"; curl -sS "${URL}some/path"
api GET /v1/services | jq -c '[.services[] | {service_id,state,port}]'
api GET "/v1/services/$SID/logs" | jq -c .
api DELETE "/v1/services/$SID" | jq -c '{service_id,state}'
curl -s -o /dev/null -m 1 "$URL" && echo "still reachable?!" || echo "service stopped, port closed"

# Warm start-to-ready, measured from one warm client process (curl/jq
# process spawns on this VM add 10-90 ms of noise).
python3 -I scripts/svc-ready.py "$API" "$TOKEN" "$WS" httphello.wasm 10 | tee /tmp/wasmdev-svc.txt
READY=$(tail -1 /tmp/wasmdev-svc.txt)
echo "service start-to-ready: first ${COLD_READY} ms (includes compile); warm $READY"

say "restart host (warm disk cache)"
stop_host
t0=$(now_ms); start_host; t1=$(now_ms)
echo "host+control plane ready in $((t1 - t0)) ms"
grep 'control plane' "$DATA.log" | tail -1
DISK=$(api POST "/v1/workspaces/$WS/run" -d '{"module":"hello.wasm"}' | jq -c '{cache,load_ms}')
echo "hello.wasm after restart: $DISK (first ever run: load_ms=$FIRST_LOAD, compiled)"

say "summary"
echo "trivial run: $LAT"
echo "service start-to-ready: cold ${COLD_READY} ms; warm $READY"
grep 'control plane .* loaded' "$DATA.log" | sed 's/^/  /'
if [[ -n "${KEEP:-}" ]]; then echo "server left running: $API token=$TOKEN pid=$HOST_PID"; fi
