#!/usr/bin/env bash
# Measure ahead-of-time compile cost of llvm.wasm (75 MB) with different
# wasmtime compiler settings, then the runtime speed of each artifact on big.c.
# Run on wasm-x2. Output -> ~/e2/bench-compile.txt
set -u
export PATH=$HOME/.wasmtime/bin:$PATH
Y=$HOME/e2/yowasp; cd $Y
T() { /usr/bin/time -f "$1: %e s wall, %U s user, %M KB maxrss" "${@:2}"; }

T "cranelift default (already measured -> llvm.cwasm)" true
T "cranelift opt-level=0" wasmtime compile -O opt-level=0 llvm.wasm -o llvm-o0.cwasm
T "winch" wasmtime compile -C compiler=winch llvm.wasm -o llvm-winch.cwasm
ls -la $Y/*.cwasm

cd $HOME/e2/work; mkdir -p tmp
for m in llvm.cwasm llvm-o0.cwasm llvm-winch.cwasm; do
  flags=""; [[ $m == *winch* ]] && flags="-C compiler=winch"
  for f in "hello.c" "big.c" "-O2 big.c"; do
    T "run $m clang -c $f" wasmtime run $flags --allow-precompiled --dir .::/ --dir $Y/usr::/usr \
      $Y/$m clang -c $f -o tmp/a.o
  done
done
# implicit cache: plain `wasmtime run llvm.wasm` after a previous run
T "wasmtime run llvm.wasm (cache warm, no cwasm)" wasmtime run llvm.wasm clang --version
T "wasmtime run -C cache=n llvm.wasm (cold JIT)" wasmtime run -C cache=n llvm.wasm clang --version
du -sh $HOME/.cache/wasmtime 2>/dev/null
