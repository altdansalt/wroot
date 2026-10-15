#!/usr/bin/env bash
# Fetch the wasm-hosted C/C++ toolchain from upstream release artifacts,
# verify pinned sha256s, and assemble it under toolchains/ (gitignored):
#
#   toolchains/llvm/llvm.wasm          YoWASP clang/lld multicall (wasip1 core module)
#   toolchains/llvm/usr/               merged sysroot mounted at guest /usr:
#                                        YoWASP resources (clang headers, wasip1 libc/libc++)
#                                      + wasi-sdk-34 wasm32-wasip2 libc + builtins
#                                      + wasi-sdk-34 EH-enabled libc++ (lib/wasm32-wasip1-eh)
#   toolchains/wasm-tools/wasm-tools.wasm   wasm-tools (wasip1) for `component new`
#   toolchains/wasm-tools/wasi_snapshot_preview1.command.wasm   p1->p2 adapter
#
# Then `scripts/register-toolchains.sh` uploads them to a running service.
# Nothing here is native code: every artifact is wasm or data.
set -euo pipefail
cd "$(dirname "$0")/.."
T=${TOOLCHAINS:-$PWD/toolchains}
DL=$T/dl
mkdir -p "$DL"

YOWASP_VER=22.0.0-git20542-10
WASI_SDK=34
WASM_TOOLS_VER=1.262.0
WASMTIME_VER=49.0.3   # adapter must match the host's wasmtime-wasi

fetch() { # fetch URL FILE SHA256
  local url=$1 out=$DL/$2 sum=$3
  if [[ ! -f $out ]] || ! echo "$sum  $out" | sha256sum -c --quiet - 2>/dev/null; then
    echo "fetch $url"
    curl -fsSL --retry 3 -o "$out.part" "$url"
    mv "$out.part" "$out"
  fi
  echo "$sum  $out" | sha256sum -c --quiet - || { echo "sha256 mismatch: $out"; exit 1; }
}

fetch "https://registry.npmjs.org/@yowasp/clang/-/clang-$YOWASP_VER.tgz" \
  "clang-$YOWASP_VER.tgz" 6230ea1afa9691fa065935cf68c01642ff9b31c183fe8ac64cdfda025df06009
fetch "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-$WASI_SDK/wasi-sysroot-$WASI_SDK.0.tar.gz" \
  "wasi-sysroot-$WASI_SDK.0.tar.gz" 9d813544eeebe38b7b8f2244ed591de46b6db812c6dd1a257ff9f0d2a905a2be
fetch "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-$WASI_SDK/libclang_rt-$WASI_SDK.0.tar.gz" \
  "libclang_rt-$WASI_SDK.0.tar.gz" eee3e634dcf71aa22b1333391623cf5c9965a637dc428a27b1a858c026c587f1
fetch "https://github.com/bytecodealliance/wasm-tools/releases/download/v$WASM_TOOLS_VER/wasm-tools-$WASM_TOOLS_VER-wasm32-wasip1.tar.gz" \
  "wasm-tools-$WASM_TOOLS_VER-wasm32-wasip1.tar.gz" 8d4538e39c1c96658148658aaa4f1e9e612a87d14cb8abbf5e3739239223a157
fetch "https://github.com/bytecodealliance/wasmtime/releases/download/v$WASMTIME_VER/wasi_snapshot_preview1.command.wasm" \
  "wasi_snapshot_preview1.command-$WASMTIME_VER.wasm" 5fa17adc6c9585b9782955ccab376ed93ea3d2bfd41ed6e32b496736c9897a89

X=$(mktemp -d "$T/.x.XXXXXX"); trap 'rm -rf "$X"' EXIT

# --- llvm (clang, wasm-ld, ar, nm, ...) + merged sysroot ---
tar xzf "$DL/clang-$YOWASP_VER.tgz" -C "$X" package/gen/llvm.core.wasm package/gen/llvm-resources.tar
mkdir -p "$X/llvm/usr" "$X/sdk"
mv "$X/package/gen/llvm.core.wasm" "$X/llvm/llvm.wasm"
tar xf "$X/package/gen/llvm-resources.tar" -C "$X/llvm/usr"
tar xzf "$DL/wasi-sysroot-$WASI_SDK.0.tar.gz" -C "$X/sdk"
tar xzf "$DL/libclang_rt-$WASI_SDK.0.tar.gz" -C "$X/sdk"
S=$X/sdk/wasi-sysroot-$WASI_SDK.0
R=$X/sdk/libclang_rt-$WASI_SDK.0
U=$X/llvm/usr
cp -r "$S/include/wasm32-wasip2" "$U/include/"
cp -r "$S/lib/wasm32-wasip2" "$U/lib/"
mkdir -p "$U/lib/wasm32-unknown-wasip2" "$U/lib/wasm32-wasip1-eh"
cp "$R/wasm32-unknown-wasip2/"* "$U/lib/wasm32-unknown-wasip2/"
cp "$S/lib/wasm32-wasip1/eh/"*.a "$U/lib/wasm32-wasip1-eh/"
cat >"$X/llvm/VERSIONS" <<EOF
@yowasp/clang $YOWASP_VER (npm)
wasi-sdk $WASI_SDK (wasi-sysroot + libclang_rt; wasip2 libc, EH libc++)
EOF

# --- wasm-tools + adapter ---
mkdir -p "$X/wasm-tools"
tar xzf "$DL/wasm-tools-$WASM_TOOLS_VER-wasm32-wasip1.tar.gz" -C "$X"
mv "$X/wasm-tools-$WASM_TOOLS_VER-wasm32-wasip1/wasm-tools.wasm" "$X/wasm-tools/"
cp "$DL/wasi_snapshot_preview1.command-$WASMTIME_VER.wasm" "$X/wasm-tools/wasi_snapshot_preview1.command.wasm"
echo "wasm-tools $WASM_TOOLS_VER; adapter from wasmtime $WASMTIME_VER" >"$X/wasm-tools/VERSIONS"

rm -rf "$T/llvm" "$T/wasm-tools"
mv "$X/llvm" "$X/wasm-tools" "$T/"
du -sh "$T/llvm/llvm.wasm" "$T/llvm/usr" "$T/wasm-tools"
echo "toolchains ready in $T"
