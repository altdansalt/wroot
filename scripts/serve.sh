#!/usr/bin/env bash
# Run the long-lived wasmdev service (used by real agents).
# API on :8700 (exe.dev proxy: https://altwasm.exe.xyz:8700, private, needs exe.dev auth),
# services on 8100-8199. Token read from ~/.config/wasmdev/api_token (never printed).
set -euo pipefail
cd "$(dirname "$0")/.."
DATA=${DATA:-$HOME/wasmdev-data}
PORT=${PORT:-8700}
mkdir -p "$DATA"
[[ -f build/control.wasm ]] || (cd control && GOOS=wasip1 GOARCH=wasm go build -o ../build/control.wasm .)
export WASMDEV_TOKEN=$(cat "$HOME/.config/wasmdev/api_token")
exec host/target/release/wasmdev-host --control build/control.wasm --listen "0.0.0.0:$PORT" \
  --data "$DATA" --service-bind 0.0.0.0 --service-ports 8100-8199 \
  --public-host "${PUBLIC_HOST:-altwasm.exe.xyz}"
