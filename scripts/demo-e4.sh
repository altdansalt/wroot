#!/usr/bin/env bash
# E4 demo: C/C++ as an agent-usable toolchain, with the compiler itself
# running as wasm, plus wasip2 component services. After starting the
# service, everything goes through the HTTP API with curl:
#
#   1. C (wasip1): build a 2-file program, run it, check stdout
#   2. C unit tests: exit code reflects pass/fail (good and buggy impl)
#   3. C++ (wasip1, exceptions + STL)
#   4. C HTTP server built for wasip2, started as a service, curled, stopped
#
#   scripts/demo-e4.sh              # reuse data-e4 (+ its compile cache) if present
#   FRESH=1 scripts/demo-e4.sh      # wipe data + cache: registers + compiles clang (~2-4 min)
#   KEEP=1 scripts/demo-e4.sh       # leave the service running
#
# Needs: scripts/fetch-toolchains.sh run once (toolchains/), cargo, go, jq, curl.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$PWD
export PATH="$HOME/.cargo/bin:/usr/local/go/bin:$PATH"
PORT=${PORT:-8782}
TOKEN=${TOKEN:-demo-$RANDOM$RANDOM}
DATA=${DATA:-$ROOT/data-e4demo}
BUILD=$ROOT/build
API=http://127.0.0.1:$PORT
OUT=$(mktemp -d); trap 'rm -rf "$OUT"' EXIT

say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
ok() { printf '   \033[32mOK\033[0m %s\n' "$*"; }
die() { printf '   \033[31mFAIL\033[0m %s\n' "$*"; exit 1; }
now_ms() { date +%s%3N; }
TIMES=()
record() { TIMES+=("$(printf '%-44s %9s ms' "$1" "$2")"); }

# api METHOD PATH [curl args] -> body on stdout; $OUT/http_ms = client time
api() {
  local m=$1 p=$2; shift 2
  curl -sS -X "$m" -H "Authorization: Bearer $TOKEN" -w '%{stderr}%{time_total}' "$API$p" "$@" 2>"$OUT/t"
  python3 -c "import sys; print(round(float(open(sys.argv[1]).read().split()[-1])*1000))" "$OUT/t" >"$OUT/http_ms"
}
# run CMDLINE -> JSON result in $OUT/r.json; prints a summary line
run() {
  api POST "/v1/workspaces/$WS/run" -d "$(jq -nc --arg c "$1" '{cmd: $c}')" >"$OUT/r.json"
  jq -r '"   $ \(.steps | length) steps, exit=\(.exit_code) state=\(.state) wall=\(.wall_ms|floor)ms"' "$OUT/r.json"
  jq -r '"     " + (.steps[] | "\(.argv[0:2] | join(" ") | .[0:22])\t\(.wall_ms|floor) ms\tload \(.load_ms*10|floor/10) ms (\(.cache))")' "$OUT/r.json"
}
field() { jq -r "$1" "$OUT/r.json"; }

if [[ ! -f toolchains/llvm/llvm.wasm ]]; then
  say "fetch toolchains (one time)"; scripts/fetch-toolchains.sh
fi
say "build host + control plane"
[[ -x host/target/release/wasmdev-host && -z "${REBUILD:-}" ]] || (cd host && cargo build --release -j2)
mkdir -p "$BUILD"
(cd control && GOOS=wasip1 GOARCH=wasm go build -o "$BUILD/control.wasm" .)

if [[ -n "${FRESH:-}" ]]; then rm -rf "$DATA" "$DATA.cache"; fi
say "start service"
t0=$(now_ms)
host/target/release/wasmdev-host --control "$BUILD/control.wasm" --listen "127.0.0.1:$PORT" \
  --data "$DATA" --token "$TOKEN" --service-ports 8100-8199 >>"$DATA.log" 2>&1 &
HOST_PID=$!
trap '[[ -z "${KEEP:-}" ]] && { kill $HOST_PID 2>/dev/null; wait $HOST_PID 2>/dev/null; }; rm -rf "$OUT"' EXIT
until curl -sf "$API/healthz" >/dev/null 2>&1; do
  kill -0 $HOST_PID 2>/dev/null || { tail "$DATA.log"; die "host exited"; }
  sleep 0.05
done
t1=$(now_ms); echo "   API up in $((t1 - t0)) ms"; record "service start (API up)" $((t1 - t0))

say "toolchain: llvm (clang/wasm-ld) + wasm-tools, both wasm"
if [[ $(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "$API/v1/tools/llvm") != 200 ]]; then
  t0=$(now_ms)
  API=$API TOKEN=$TOKEN scripts/register-toolchains.sh
  t1=$(now_ms); record "register toolchains (upload+precompile)" $((t1 - t0))
else
  # registered earlier: the control plane warms them from the disk cache at startup
  t0=$(now_ms)
  for t in llvm wasm-tools; do api GET "/v1/tools/$t?wait=1" | jq -c '{name, precompile}'; done
  t1=$(now_ms); record "toolchains in memory after API up (disk cache)" $((t1 - t0))
fi
api GET /v1/tools | jq -r '.tools[] | "   \(.name): \(.description[0:70])..."'

say "create workspace + upload sources (tar)"
WS=$(api POST /v1/workspaces | jq -r .id); echo "   workspace $WS"
tar -C examples/c -cf "$OUT/src.tar" .
printf 'one\ntwo\nthree\n' >"$OUT/input.txt"
api POST "/v1/workspaces/$WS/files" -H 'Content-Type: application/x-tar' --data-binary "@$OUT/src.tar" | jq -c '.written'
api PUT "/v1/workspaces/$WS/files/data/input.txt" --data-binary "@$OUT/input.txt" >/dev/null

say "1. C -> wasip1: cc -O2 -Wall -o hello.wasm hello.c greet.c"
run "cc -O2 -Wall -o hello.wasm hello.c greet.c"
[[ $(field .exit_code) == 0 ]] || { field .stderr; die "build failed"; }
record "1. cc 2 files (first build)" "$(cat "$OUT/http_ms")"
run "cc -O2 -Wall -o hello.wasm hello.c greet.c"; record "1. cc 2 files (warm)" "$(cat "$OUT/http_ms")"
api POST "/v1/workspaces/$WS/run" -d '{"module": "hello.wasm", "args": ["agent"]}' >"$OUT/r.json"
record "1. run hello.wasm (first: compiles output)" "$(cat "$OUT/http_ms")"
field .stdout | sed '/^$/d; s/^/   > /'
[[ $(field .stdout) == *"hello, agent, from C"*"input.txt has 3 lines"* ]] && ok "stdout as expected" || die "unexpected stdout"
api POST "/v1/workspaces/$WS/run" -d '{"module": "hello.wasm", "args": ["agent"]}' >"$OUT/r.json"
record "1. run hello.wasm (warm)" "$(cat "$OUT/http_ms")"

say "2. C unit tests: exit status = failed checks"
run "cc -O1 -o test_calc.wasm test_calc.c calc.c && ./test_calc.wasm"
record "2. build + run unit tests" "$(cat "$OUT/http_ms")"
field .stdout | sed '/^$/d; s/^/   > /'
[[ $(field .exit_code) == 0 ]] && ok "tests pass -> exit 0" || die "expected exit 0"
run "cc -O1 -o test_calc.wasm test_calc.c calc_buggy.c && ./test_calc.wasm"
field '.stdout, .stderr' | sed '/^$/d; s/^/   > /'
[[ $(field .exit_code) == 1 ]] && ok "buggy impl -> exit 1 (1 failed check), state $(field .state)" || die "expected exit 1"
run "cc -o broken.wasm calc.c missing.c"
[[ $(field .exit_code) != 0 ]] && ok "compile error -> exit $(field .exit_code): $(field .stderr | head -1)" || die "expected failure"

say "3. C++ -> wasip1 (exceptions, STL): c++ -O2 -o shapes.wasm shapes.cpp"
run "c++ -O2 -std=c++17 -o shapes.wasm shapes.cpp"
[[ $(field .exit_code) == 0 ]] || { field .stderr; die "C++ build failed"; }
record "3. c++ build (first)" "$(cat "$OUT/http_ms")"
run "c++ -O2 -std=c++17 -o shapes.wasm shapes.cpp"; record "3. c++ build (warm)" "$(cat "$OUT/http_ms")"
api POST "/v1/workspaces/$WS/run" -d '{"module": "shapes.wasm"}' >"$OUT/r.json"
record "3. run shapes.wasm (first: compiles 2 MB output)" "$(cat "$OUT/http_ms")"
field .stdout | sed '/^$/d; s/^/   > /'
[[ $(field .stdout) == *"caught: negative size"*"total="* ]] && ok "C++ exceptions + STL work" || die "unexpected C++ output"
api POST "/v1/workspaces/$WS/run" -d '{"module": "shapes.wasm"}' >"$OUT/r.json"; record "3. run shapes.wasm (warm)" "$(cat "$OUT/http_ms")"

say "4. C HTTP server -> wasip2 component, run as a service"
run "cc --target=wasm32-wasip2 -O2 -Wall -o httpd.wasm httpd.c"
[[ $(field .exit_code) == 0 ]] || { field .stderr; die "wasip2 build failed"; }
record "4. cc wasip2 (clang + wasm-ld + wasm-tools)" "$(cat "$OUT/http_ms")"
t0=$(date +%s%N)
SVC=$(api POST "/v1/workspaces/$WS/services" -d '{"module": "httpd.wasm"}')
echo "$SVC" | jq -c '{service_id, kind, port, url, state}'
URL=$(echo "$SVC" | jq -r .url); SID=$(echo "$SVC" | jq -r .service_id)
for _ in $(seq 1 2000); do curl -sf -o /dev/null "$URL" 2>/dev/null && break; sleep 0.005; done
t1=$(date +%s%N); record "4. service start -> first HTTP 200" $(((t1 - t0) / 1000000))
R1=$(curl -sS "${URL}hello"); R2=$(curl -sS -X POST "${URL}api/items")
echo "   > $R1"; echo "   > $R2"
[[ $R2 == *"POST /api/items"* ]] && ok "service answers on its port" || die "bad response"
api GET "/v1/services/$SID/logs" | jq -r .stderr | sed 's/^/   log: /'
api DELETE "/v1/services/$SID" | jq -c '{service_id, state}'
curl -s -o /dev/null -m 1 "$URL" && die "still reachable" || ok "stopped, port closed"
t0=$(date +%s%N)
SID=$(api POST "/v1/workspaces/$WS/services" -d '{"module": "httpd.wasm"}' | jq -r .service_id)
for _ in $(seq 1 2000); do curl -sf -o /dev/null "$URL" 2>/dev/null && break; sleep 0.005; done
t1=$(date +%s%N); record "4. service start -> first HTTP 200 (warm)" $(((t1 - t0) / 1000000))
api DELETE "/v1/services/$SID" >/dev/null

say "timings (client-side, ms; first = first use in this service process)"
printf '%s\n' "${TIMES[@]}" | sed 's/^/   /'
echo "   host RSS: $(($(ps -o rss= -p $HOST_PID) / 1024)) MB"
[[ -n "${KEEP:-}" ]] && echo "service left running: $API token=$TOKEN workspace=$WS"
echo; ok "demo complete"
