#!/usr/bin/env bash
# W1 demo: Go as a first-class toolchain, plus the round-1 friction fixes.
# After starting the service, everything goes through the HTTP API (curl):
#
#   1. Go multi-package module: go build, run the binary (stdin from a file,
#      output redirected + diffed inside the service), rebuild warm/after edit
#   2. go vet (clean, then a deliberate printf bug -> exit 1)
#   3. go test (pass; then a failing test -> FAIL + exit 1)
#   4. Go net/http service: wait_ready, curl it, stop
#   5. limits: wasm call-stack (max_wasm_stack) and C linear stack, with
#      classified traps; output before the trap is kept
#
#   scripts/demo-w1.sh             # reuse data-w1demo (+ compile cache, GOCACHE)
#   FRESH=1 scripts/demo-w1.sh     # wipe data + cache: registers + compiles all tools,
#                                  # warms Go's std (cold: ~20-30 min on 2 vCPUs)
#   KEEP=1 scripts/demo-w1.sh      # leave the service running
#
# Needs: scripts/fetch-toolchains.sh and scripts/build-go-toolchain.sh run once,
# cargo, go, jq, curl.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$PWD
export PATH="$HOME/.cargo/bin:/usr/local/go/bin:$PATH"
PORT=${PORT:-8784}
TOKEN=${TOKEN:-demo-$RANDOM$RANDOM}
DATA=${DATA:-$ROOT/data-w1demo}
BUILD=$ROOT/build
API=http://127.0.0.1:$PORT
OUT=$(mktemp -d)

say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
ok() { printf '   \033[32mOK\033[0m %s\n' "$*"; }
die() { printf '   \033[31mFAIL\033[0m %s\n' "$*"; exit 1; }
now_ms() { date +%s%3N; }
TIMES=()
record() { TIMES+=("$(printf '%-52s %9s ms' "$1" "$2")"); }

# api METHOD PATH [curl args] -> body on stdout; $OUT/http_ms = client time
api() {
  local m=$1 p=$2; shift 2
  curl -sS -X "$m" -H "Authorization: Bearer $TOKEN" -w '%{stderr}%{time_total}' "$API$p" "$@" 2>"$OUT/t"
  python3 -c "import sys; print(round(float(open(sys.argv[1]).read().split()[-1])*1000))" "$OUT/t" >"$OUT/http_ms"
}
# run CMDLINE [extra JSON] -> result in $OUT/r.json; prints a summary
run() {
  api POST "/v1/workspaces/$WS/run" -d "$(jq -nc --arg c "$1" --argjson x "${2:-{\}}" '{cmd: $c} + $x')" >"$OUT/r.json"
  jq -r '"   $ \(.steps | length) steps, exit=\(.exit_code) state=\(.state) wall=\(.wall_ms|floor)ms"' "$OUT/r.json"
}
field() { jq -r "$1" "$OUT/r.json"; }
show() { field "$1" | sed '/^$/d; s/^/   > /' | head -${2:-12}; }
ms() { cat "$OUT/http_ms"; }

for f in toolchains/llvm/llvm.wasm build/go-wasip1/goroot/bin/go; do
  [[ -f $f ]] || die "$f missing: run scripts/fetch-toolchains.sh / scripts/build-go-toolchain.sh"
done
say "build host + control plane"
[[ -x host/target/release/wasmdev-host && -z "${REBUILD:-}" ]] || (cd host && cargo build --release -j2)
mkdir -p "$BUILD"
(cd control && GOOS=wasip1 GOARCH=wasm CGO_ENABLED=0 go build -trimpath -buildvcs=false -o "$BUILD/control.wasm" .)

if [[ -n "${FRESH:-}" ]]; then rm -rf "$DATA" "$DATA.cache"; fi
say "start service"
t0=$(now_ms)
host/target/release/wasmdev-host --control "$BUILD/control.wasm" --listen "127.0.0.1:$PORT" \
  --data "$DATA" --token "$TOKEN" --service-ports 8150-8199 \
  --public-host "${PUBLIC_HOST:-altwasm.exe.xyz}" >>"$DATA.log" 2>&1 &
HOST_PID=$!
trap '[[ -z "${KEEP:-}" ]] && { kill $HOST_PID 2>/dev/null; wait $HOST_PID 2>/dev/null || true; }; rm -rf "$OUT"' EXIT
until curl -sf "$API/healthz" >/dev/null 2>&1; do
  kill -0 $HOST_PID 2>/dev/null || { tail "$DATA.log"; die "host exited"; }
  sleep 0.05
done
t1=$(now_ms); echo "   API up in $((t1 - t0)) ms"; record "service start (API up)" $((t1 - t0))

say "toolchains: llvm + wasm-tools (C/C++), go (all wasm)"
code() { curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "$API/v1/tools/$1"; }
if [[ $(code llvm) != 200 ]]; then
  t0=$(now_ms); API=$API TOKEN=$TOKEN scripts/register-toolchains.sh
  record "register llvm + wasm-tools (upload+precompile)" $(($(now_ms) - t0))
fi
if [[ $(code go) != 200 ]]; then
  t0=$(now_ms); API=$API TOKEN=$TOKEN scripts/register-go.sh
  record "register go (upload+precompile 10 modules+warm std)" $(($(now_ms) - t0))
fi
t0=$(now_ms)
for t in llvm wasm-tools go; do api GET "/v1/tools/$t?wait=1" | jq -c '{name, precompile}'; done
record "all tools ready (after API up)" $(($(now_ms) - t0))

say "create workspace + upload a Go module (3 packages + a service)"
WS=$(api POST /v1/workspaces | jq -r .id); echo "   workspace $WS"
tar -C examples/go-w1 --exclude=extra -cf "$OUT/src.tar" .
api POST "/v1/workspaces/$WS/files" -H 'Content-Type: application/x-tar' --data-binary "@$OUT/src.tar" | jq -c '.written'
printf 'the quick brown fox\njumps over the lazy dog\n' | api PUT "/v1/workspaces/$WS/files/words.txt" --data-binary @- >/dev/null
printf 'hello, Agent! sum(1..10)=55 fib(30)=832040\nstdin words: 9, reversed name: tnega\n' |
  api PUT "/v1/workspaces/$WS/files/want.txt" --data-binary @- >/dev/null

say "1. go build + run"
run "go version && go build -o app.wasm ."
[[ $(field .exit_code) == 0 ]] || { show .stderr 30; die "go build failed"; }
show .stdout 1; record "1. go version && go build (first in workspace)" "$(ms)"
run "go build -o app.wasm ."; record "1. go build (no change)" "$(ms)"
api PUT "/v1/workspaces/$WS/files/calc/calc.go" --data-binary @<(sed 's/Sum returns/Sum computes/' examples/go-w1/calc/calc.go) >/dev/null
run "go build -o app.wasm ."; record "1. go build (after editing calc.go)" "$(ms)"
api POST "/v1/workspaces/$WS/run" -d '{"module": "app.wasm", "args": ["agent"], "stdin": "a b c"}' >"$OUT/r.json"
record "1. run app.wasm (first: compiles the module)" "$(ms)"; show .stdout
[[ $(field .stdout) == *"hello, Agent! sum(1..10)=55 fib(30)=832040"*"stdin words: 3"* ]] && ok "binary runs" || die "unexpected output"
run "./app.wasm agent < words.txt > out.txt && diff out.txt want.txt && echo identical"
record "1. ./app.wasm < in > out && diff (warm)" "$(ms)"; show .stdout
[[ $(field .stdout) == "identical"* ]] && ok "stdin/stdout redirection + diff builtin in the service" || die "redirect/diff"

say "2. go vet"
run "go vet ./..."; record "2. go vet ./... (first)" "$(ms)"
[[ $(field .exit_code) == 0 ]] && ok "vet clean" || { show .stderr 20; die "vet failed"; }
run "go vet ./..."; record "2. go vet ./... (warm)" "$(ms)"
api PUT "/v1/workspaces/$WS/files/strutil/vetbad.go" --data-binary @examples/go-w1/extra/vetbad.go >/dev/null
run "go vet ./..."; show .stderr 4
[[ $(field .exit_code) == 1 && $(field .stderr) == *"wrong type"* ]] && ok "vet finds the printf bug -> exit 1" || die "expected vet failure"
api DELETE "/v1/workspaces/$WS/files/strutil/vetbad.go" >/dev/null

say "3. go test"
run "go test -count=1 ./..."; show .stdout; record "3. go test -count=1 ./... (first: build+JIT+run tests)" "$(ms)"
[[ $(field .exit_code) == 0 ]] || { show .stderr 20; die "tests failed"; }
field '.steps[0]' | jq -c '{argv: .argv[0:3], wall_ms, compiler}'
run "go test ./..."; record "3. go test ./... (warm, cached results)" "$(ms)"
run "go test -count=1 ./..."; record "3. go test -count=1 ./... (warm: relink + rerun)" "$(ms)"
api PUT "/v1/workspaces/$WS/files/calc/calc_fail_test.go" --data-binary @examples/go-w1/extra/calc_fail_test.go >/dev/null
run "go test ./..."; show .stdout 8; record "3. go test ./... (failing test added)" "$(ms)"
[[ $(field .exit_code) == 1 && $(field .stdout) == *"--- FAIL: TestSumWrong"*"FAIL"* ]] && ok "failing test -> FAIL, exit 1" || die "expected FAIL"
run "go test ./... > test.log 2>&1 || echo 'tests failed, see test.log'"; show .stdout 2
api DELETE "/v1/workspaces/$WS/files/calc/calc_fail_test.go" >/dev/null

say "4. Go net/http service (wasip1, listener from \$WASMDEV_LISTEN_FD)"
run "go build -o srv.wasm ./srv"; record "4. go build ./srv (net/http)" "$(ms)"
[[ $(field .exit_code) == 0 ]] || { show .stderr 20; die "srv build failed"; }
api POST "/v1/workspaces/$WS/services" -d '{"module": "srv.wasm", "wait_ready": true}' >"$OUT/svc.json"
record "4. start service, wait_ready (first: compiles module)" "$(ms)"
jq -c '{service_id, state, ready, ready_ms, url, local_url}' "$OUT/svc.json"
[[ $(jq -r .ready "$OUT/svc.json") == true ]] || die "service not ready"
URL=$(jq -r .local_url "$OUT/svc.json"); SID=$(jq -r .service_id "$OUT/svc.json")
R=$(curl -sS "${URL}fib/50"); echo "   > GET /fib/50 -> $R"
[[ $R == *'"fib":12586269025'* ]] && ok "service answers right after wait_ready" || die "bad response"
curl -sS "${URL}healthz" | sed 's/^/   > /'
api GET "/v1/services/$SID/logs" | jq -r .stderr | sed 's/^/   log: /'
api DELETE "/v1/services/$SID" | jq -c '{service_id, state}'
api POST "/v1/workspaces/$WS/services" -d '{"module": "srv.wasm", "wait_ready": true}' >"$OUT/svc.json"
record "4. start service, wait_ready (warm)" "$(ms)"; jq -c '{ready, ready_ms}' "$OUT/svc.json"
api DELETE "/v1/services/$(jq -r .service_id "$OUT/svc.json")" >/dev/null

say "5. limits and trap messages (C)"
api PUT "/v1/workspaces/$WS/files/deep.c" --data-binary @examples/go-w1/extra/deep.c >/dev/null
run "cc -O0 -o deep.wasm deep.c && ./deep.wasm big"
echo "   trap=$(field .trap)"; field .error | fold -w 100 | sed 's/^/   error: /' | head -4; show .stdout 2
[[ $(field .trap) == memory_out_of_bounds && $(field .error) == *"stack-size"* && $(field .stdout) == start* ]] &&
  ok "C stack overflow (1 MiB default stack) explained; stdout before the trap kept" || die "expected classified trap"
run "cc -O0 -Wl,-z,stack-size=4194304 -o deep.wasm deep.c && ./deep.wasm big"
[[ $(field .exit_code) == 0 ]] && ok "-Wl,-z,stack-size=4194304 overrides the default" || die "override failed"
run "cc -O0 -Wl,-z,stack-size=268435456 -o deepr.wasm deep.c && ./deepr.wasm 1000000"
echo "   trap=$(field .trap)"; field .error | fold -w 100 | sed 's/^/   error: /' | head -3
[[ $(field .trap) == stack_overflow ]] && ok "deep recursion hits the 8 MiB wasm call stack -> stack_overflow" || die "expected stack_overflow"
run "./deepr.wasm 1000000" '{"max_wasm_stack": 134217728}'; show .stdout 2
[[ $(field .exit_code) == 0 ]] && ok "max_wasm_stack=128 MiB per run -> passes" || die "max_wasm_stack"

say "timings (client-side, ms; first = first use in this service process/workspace)"
printf '%s\n' "${TIMES[@]}" | sed 's/^/   /'
echo "   host RSS: $(($(ps -o rss= -p $HOST_PID) / 1024)) MB"
[[ -n "${KEEP:-}" ]] && echo "service left running: $API token=$TOKEN workspace=$WS"
echo; ok "demo complete"
