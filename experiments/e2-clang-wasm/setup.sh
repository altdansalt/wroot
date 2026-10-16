#!/usr/bin/env bash
# Reproduce the e2 setup on a fresh Ubuntu VM (what was run on wasm-x2).
set -eu
curl https://wasmtime.dev/install.sh -sSf | bash          # -> ~/.wasmtime/bin/wasmtime (49.0.3 tested)
export PATH=$HOME/.wasmtime/bin:$PATH
mkdir -p ~/e2/dl ~/e2/yowasp ~/e2/tools ~/e2/sdk34 && cd ~/e2/dl
# 1. YoWASP clang (npm only; PyPI has no yowasp-clang). llvm.core.wasm is the raw wasip1 module.
curl -sSLO https://registry.npmjs.org/@yowasp/clang/-/clang-22.0.0-git20542-10.tgz
mkdir -p yowasp && tar xzf clang-22.0.0-git20542-10.tgz -C yowasp
cp yowasp/package/gen/llvm.core.wasm ~/e2/yowasp/llvm.wasm
mkdir -p ~/e2/yowasp/usr && tar xf yowasp/package/gen/llvm-resources.tar -C ~/e2/yowasp/usr
wasmtime compile ~/e2/yowasp/llvm.wasm -o ~/e2/yowasp/llvm.cwasm     # ~100-190 s, ~2 GB RSS
# 2. wasm-tools as wasm (for wasip2 componentization) + p1 adapter
V=1.262.0
curl -sSL https://github.com/bytecodealliance/wasm-tools/releases/download/v$V/wasm-tools-$V-wasm32-wasip1.tar.gz | tar xz
cp wasm-tools-$V-wasm32-wasip1/wasm-tools.wasm ~/e2/tools/
WV=$(wasmtime --version | cut -d' ' -f2)
curl -sSLo ~/e2/tools/wasi_snapshot_preview1.command.wasm https://github.com/bytecodealliance/wasmtime/releases/download/v$WV/wasi_snapshot_preview1.command.wasm
wasmtime compile ~/e2/tools/wasm-tools.wasm -o ~/e2/tools/wasm-tools.cwasm
# 3. wasi-sdk 34 sysroot: adds wasm32-wasip2 libc and EH-enabled libc++ (lib/*/eh)
curl -sSLO https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-34/wasi-sysroot-34.0.tar.gz
curl -sSLO https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-34/libclang_rt-34.0.tar.gz
tar xzf wasi-sysroot-34.0.tar.gz -C ~/e2/sdk34 && tar xzf libclang_rt-34.0.tar.gz -C ~/e2/sdk34
S=~/e2/sdk34/wasi-sysroot-34.0
mkdir -p ~/e2/usr2 && cp -r ~/e2/yowasp/usr/. ~/e2/usr2/
cp -r $S/include/wasm32-wasip2 ~/e2/usr2/include/ && cp -r $S/lib/wasm32-wasip2 ~/e2/usr2/lib/
mkdir -p ~/e2/usr2/lib/wasm32-unknown-wasip2 ~/e2/usr2/lib/wasm32-wasip1-eh
cp ~/e2/sdk34/libclang_rt-34.0/wasm32-unknown-wasip2/* ~/e2/usr2/lib/wasm32-unknown-wasip2/
cp $S/lib/wasm32-wasip1/eh/*.a ~/e2/usr2/lib/wasm32-wasip1-eh/
