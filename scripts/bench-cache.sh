#!/usr/bin/env bash
# Measure the compiled-module cache on a toolchain-sized module:
# Go's cmd/compile built for wasip1 (~50 MB wasm).
#   cold    = compile with Cranelift (+ serialize to disk cache)
#   memory  = in-process Module cache hit
#   disk    = fresh host process, Module::deserialize_file
set -euo pipefail
cd "$(dirname "$0")/.."
export PATH="$HOME/.cargo/bin:/usr/local/go/bin:$PATH"
BUILD=$PWD/build; DATA=$PWD/data-bench; PORT=8790; TOKEN=bench
API=http://127.0.0.1:$PORT
[[ -f $BUILD/gocompile.wasm ]] || GOOS=wasip1 GOARCH=wasm go build -o "$BUILD/gocompile.wasm" cmd/compile
[[ -f $BUILD/control.wasm ]] || (cd control && GOOS=wasip1 GOARCH=wasm go build -o "$BUILD/control.wasm" .)
ls -la "$BUILD/gocompile.wasm"

api() { local m=$1 p=$2; shift 2; curl -sS -X "$m" -H "Authorization: Bearer $TOKEN" "$API$p" "$@"; }
start() {
  host/target/release/wasmdev-host --control "$BUILD/control.wasm" --listen 127.0.0.1:$PORT \
    --data "$DATA" --token $TOKEN >>"$DATA.log" 2>&1 &
  PID=$!
  until curl -sf $API/healthz >/dev/null 2>&1; do sleep 0.1; done
}
run() {
  api POST "/v1/workspaces/$WS/run" -d '{"module":"gocompile","args":["-V=full"],"timeout_ms":600000}' \
    | jq -c '{cache, load_ms, wall_ms, exit_code, out: (.stdout|.[0:40])}'
}
rss() { awk '/VmHWM/{print $2/1024 " MB peak RSS"}' /proc/$PID/status; }

rm -rf "$DATA" "$DATA.cache" "$DATA.log"
start
WS=$(api POST /v1/workspaces | jq -r .id)
api PUT "/v1/tools/gocompile?argv0=compile" --data-binary "@$BUILD/gocompile.wasm" | jq -c .
echo "cold:";   run; rss
echo "memory:"; run; run
kill $PID; wait $PID 2>/dev/null || true
start
echo "disk (new host process):"; run
echo "memory:"; run
rss
du -sh "$DATA.cache"
kill $PID; wait $PID 2>/dev/null || true
