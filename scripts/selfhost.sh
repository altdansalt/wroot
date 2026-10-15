#!/usr/bin/env bash
# Self-hosting: use the service's own API to develop its control plane.
#
#   1. upload control/ (the control plane's Go sources) to a workspace
#   2. go vet + go test (its unit tests: cmd mini-shell parser, diff builtin,
#      trap explanations, clang -### job parser, ...) - run by wasm cmd/go
#   3. go build control.wasm through the service; compare with a native build
#      (same flags: GOOS=wasip1 GOARCH=wasm CGO_ENABLED=0 -trimpath -buildvcs=false)
#   4. restart the host with the service-built control.wasm and use it:
#      it serves the API, runs C and Go, and re-runs its own tests.
#
#   scripts/selfhost.sh        # uses data-w1demo (tools registered by demo-w1.sh)
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$PWD
export PATH="$HOME/.cargo/bin:/usr/local/go/bin:$PATH"
PORT=${PORT:-8785}
TOKEN=${TOKEN:-self-$RANDOM$RANDOM}
DATA=${DATA:-$ROOT/data-w1demo}
API=http://127.0.0.1:$PORT
OUT=$(mktemp -d)
HOST_PID=
say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
ok() { printf '   \033[32mOK\033[0m %s\n' "$*"; }
die() { printf '   \033[31mFAIL\033[0m %s\n' "$*"; exit 1; }
api() { local m=$1 p=$2; shift 2; curl -sS -X "$m" -H "Authorization: Bearer $TOKEN" "$API$p" "$@"; }
run() {
  local t0=$(date +%s%3N)
  api POST "/v1/workspaces/$WS/run" -d "$(jq -nc --arg c "$1" '{cmd: $c, timeout_ms: 1800000}')" >"$OUT/r.json"
  echo "   \$ $1  -> exit=$(jq -r .exit_code "$OUT/r.json") state=$(jq -r .state "$OUT/r.json") ($(($(date +%s%3N) - t0)) ms)"
}
field() { jq -r "$1" "$OUT/r.json"; }
start_host() { # start_host CONTROL_WASM
  host/target/release/wasmdev-host --control "$1" --listen "127.0.0.1:$PORT" --data "$DATA" \
    --token "$TOKEN" --service-ports 8150-8199 >>"$DATA.log" 2>&1 &
  HOST_PID=$!
  until curl -sf "$API/healthz" >/dev/null 2>&1; do
    kill -0 $HOST_PID 2>/dev/null || { tail "$DATA.log"; die "host exited"; }
    sleep 0.05
  done
}
stop_host() { kill $HOST_PID 2>/dev/null; wait $HOST_PID 2>/dev/null || true; HOST_PID=; }
trap 'stop_host; rm -rf "$OUT"' EXIT

say "native reference build of the control plane"
NATIVE=$ROOT/build/control.wasm
(cd control && env -u GOFLAGS GOOS=wasip1 GOARCH=wasm CGO_ENABLED=0 go build -trimpath -buildvcs=false -o "$NATIVE" .)
echo "   $(sha256sum "$NATIVE" | cut -c1-16)…  $NATIVE ($(go version | cut -d' ' -f3))"

say "start the service (native-built control plane)"
start_host "$NATIVE"
for t in go llvm; do
  [[ $(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "$API/v1/tools/$t") == 200 ]] ||
    die "tool $t not registered in $DATA: run scripts/demo-w1.sh first"
  api GET "/v1/tools/$t?wait=1" >/dev/null
done
WS=$(api POST /v1/workspaces | jq -r .id); echo "   workspace $WS"
tar -C control -cf "$OUT/src.tar" --exclude='*.wasm' .
api POST "/v1/workspaces/$WS/files" -H 'Content-Type: application/x-tar' --data-binary "@$OUT/src.tar" | jq -c .written

say "1. go vet + go test of the control plane, through the service"
run "go vet ./..."
[[ $(field .exit_code) == 0 ]] && ok "go vet clean" || { field .stderr; die "vet"; }
run "go test -v -count=1 ./..."
field .stdout | grep -E '^(--- |ok|FAIL|PASS)' | sed 's/^/   > /'
[[ $(field .exit_code) == 0 ]] && ok "control plane unit tests pass (the test binary ran as a wasm child of go, compiled by Winch)" || { field .stderr; die "tests"; }

say "2. go build control.wasm through the service"
run "go build -trimpath -buildvcs=false -o control.wasm . && go version"
[[ $(field .exit_code) == 0 ]] || { field .stderr; die "build"; }
field .stdout | sed 's/^/   > /'
api GET "/v1/workspaces/$WS/files/control.wasm" -o "$ROOT/build/control-selfbuilt.wasm"
SELF=$ROOT/build/control-selfbuilt.wasm
echo "   service-built: $(sha256sum "$SELF" | cut -c1-64)"
echo "   native:        $(sha256sum "$NATIVE" | cut -c1-64)"
if cmp -s "$SELF" "$NATIVE"; then ok "byte-identical ($(stat -c %s "$SELF") bytes)"; else die "builds differ"; fi
stop_host

say "3. restart the host with the service-built control.wasm"
t0=$(date +%s%3N)
start_host "$SELF"
echo "   API up in $(($(date +%s%3N) - t0)) ms ($(grep 'control plane .* loaded' "$DATA.log" | tail -1 | grep -o 'loaded in [^;]*'))"
api GET / | head -1 | sed 's/^/   GET \/ > /'
api GET "/v1/tools/go?wait=1" >/dev/null
WS=$(api POST /v1/workspaces | jq -r .id)
api POST "/v1/workspaces/$WS/files" -H 'Content-Type: application/x-tar' --data-binary "@$OUT/src.tar" >/dev/null
printf '#include <stdio.h>\nint main(void){puts("C via self-built control plane");return 0;}\n' |
  api PUT "/v1/workspaces/$WS/files/hi.c" --data-binary @- >/dev/null
run "cc -o hi.wasm hi.c && ./hi.wasm"
[[ $(field .stdout) == "C via self-built control plane"* ]] && ok "C build+run works" || die "C"
run "go test -count=1 ./... && go build -trimpath -buildvcs=false -o control2.wasm ."
field .stdout | sed 's/^/   > /'
[[ $(field .exit_code) == 0 ]] && ok "the self-built control plane tests and rebuilds itself" || { field .stderr; die "go"; }
api GET "/v1/workspaces/$WS/files/control2.wasm" -o "$OUT/control2.wasm"
cmp -s "$OUT/control2.wasm" "$SELF" && ok "fixed point: rebuilt control.wasm is identical again" || die "rebuild differs"
echo; ok "self-hosting complete"
