#!/bin/bash
# Step 1 of e1: copy GOROOT, build the Go toolchain as wasip1 modules, precompile with wasmtime.
# Runs on wasm-x1. No GOROOT patches are needed for compile/link/asm/pack.
set -e
mkdir -p ~/e1/bin
[ -d ~/e1/goroot ] || cp -a "$(go env GOROOT)" ~/e1/goroot
export PATH=~/e1/goroot/bin:$HOME/.wasmtime/bin:$PATH
cd ~/e1/goroot/src
for t in compile link asm pack go; do
  GOOS=wasip1 GOARCH=wasm go build -o ~/e1/bin/$t.wasm ./cmd/$t
  wasmtime compile -o ~/e1/bin/$t.cwasm ~/e1/bin/$t.wasm     # cranelift, opt-level=2 default
done
go build -o ~/e1/bin/pack-native ./cmd/pack     # go1.27 no longer ships pkg/tool/*/pack
# variants used by bench-compile.sh
mkdir -p ~/e1/bin-o0 ~/e1/bin-winch ~/e1/bin-nosig
for t in compile asm pack link; do
  wasmtime compile -O opt-level=0      -o ~/e1/bin-o0/$t.cwasm    ~/e1/bin/$t.wasm
  wasmtime compile -C compiler=winch   -o ~/e1/bin-winch/$t.cwasm ~/e1/bin/$t.wasm
done
wasmtime compile -O signals-based-traps=n -o ~/e1/bin-nosig/compile.cwasm ~/e1/bin/compile.wasm
# cmd/go needs the filelock patch (filelock-wasip1.patch) to get past go.mod locking:
#   (cd ~/e1/goroot && git apply filelock-wasip1.patch)
#   GOOS=wasip1 GOARCH=wasm go build -o ~/e1/bin/go-patched.wasm ./cmd/go
# and expects its tools in $GOROOT/pkg/tool/wasip1_wasm/:
mkdir -p ~/e1/goroot/pkg/tool/wasip1_wasm
for t in compile link asm pack; do cp ~/e1/bin/$t.wasm ~/e1/goroot/pkg/tool/wasip1_wasm/$t; done
