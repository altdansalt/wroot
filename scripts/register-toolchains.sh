#!/usr/bin/env bash
# Register the wasm C/C++ toolchain (from scripts/fetch-toolchains.sh) with a
# running wasmdev service, using only its HTTP API:
#   PUT /v1/tools/llvm        clang/lld/ar/... multicall + sysroot (driver "clang")
#   PUT /v1/tools/wasm-tools  componentizer for wasip2 links
# Each upload is a streamed tar (tool.json + files). The service then
# precompiles the module into the host cache (?wait=1: we block until done;
# ~100 s / ~1.9 GB peak for clang on a cold cache, ~0.5 s from disk cache).
#
#   API=http://127.0.0.1:8780 TOKEN=... scripts/register-toolchains.sh
set -euo pipefail
cd "$(dirname "$0")/.."
API=${API:-http://127.0.0.1:8780}
: "${TOKEN:?set TOKEN}"
T=${TOOLCHAINS:-$PWD/toolchains}
[[ -f $T/llvm/llvm.wasm && -f $T/wasm-tools/wasm-tools.wasm ]] || { echo "run scripts/fetch-toolchains.sh first"; exit 1; }

cat >"$T/llvm/tool.json" <<'JSON'
{
  "module": "llvm.wasm",
  "argv0": "llvm",
  "description": "clang/clang++/wasm-ld/ar/nm 22.1 (YoWASP, wasip1) with wasi-libc + libc++ sysroot for wasm32-wasip1 and wasm32-wasip2 (wasi-sdk 34)",
  "mounts": [{"path": "usr", "guest": "/usr"}],
  "scratch": "/tmp",
  "commands": {
    "cc": ["clang"], "gcc": ["clang"], "clang": ["clang"],
    "c++": ["clang++"], "g++": ["clang++"], "clang++": ["clang++"],
    "wasm-ld": ["wasm-ld"], "ld": ["wasm-ld"], "ar": ["ar"], "ranlib": ["ranlib"],
    "nm": ["nm"], "objdump": ["objdump"], "strip": ["strip"], "size": ["size"], "c++filt": ["c++filt"]
  },
  "driver": "clang",
  "clang": {
    "componentizer": "wasm-tools",
    "adapter": "/wasm-tools/wasi_snapshot_preview1.command.wasm",
    "cxx_compile_flags": ["-fwasm-exceptions", "-mllvm", "-wasm-use-legacy-eh=false"],
    "cxx_link_flags": ["-L/usr/lib/wasm32-wasip1-eh", "-lunwind"]
  }
}
JSON
cat >"$T/wasm-tools/tool.json" <<'JSON'
{
  "module": "wasm-tools.wasm",
  "argv0": "wasm-tools",
  "description": "wasm-tools 1.262 (wasip1): component new/wit/print/validate; used by cc for wasm32-wasip2 links",
  "mounts": [{"path": ".", "guest": "/wasm-tools"}]
}
JSON

put() { # put NAME DIR FILES...
  local name=$1 dir=$2; shift 2
  local t0=$(date +%s%N)
  tar -C "$dir" -cf - tool.json "$@" |
    curl -sS --fail-with-body -X PUT -T - -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/x-tar" "$API/v1/tools/$name?wait=1" |
    jq -c '{name: .tool.name, upload_ms, precompile: .tool.precompile}'
  echo "  $name registered + precompiled in $(( ($(date +%s%N) - t0) / 1000000 )) ms"
}
put wasm-tools "$T/wasm-tools" wasm-tools.wasm wasi_snapshot_preview1.command.wasm
put llvm "$T/llvm" llvm.wasm usr
