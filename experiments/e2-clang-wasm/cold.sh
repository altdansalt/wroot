#!/usr/bin/env bash
# Cold-start costs of the 75 MB llvm.wasm: JIT w/o cache, AOT compile, cache-warm run,
# and end-to-end wcc.py builds. Run on wasm-x2. Output -> ~/e2/cold.txt
export PATH=$HOME/.wasmtime/bin:$PATH
Y=$HOME/e2/yowasp; cd $HOME/e2/work
T() { /usr/bin/time -f "$1: %e s wall, %U s user, %M KB maxrss" "${@:2}" >/dev/null; }
T "cold: wasmtime run -C cache=n llvm.wasm clang --version (cranelift JIT, all funcs)" wasmtime run -C cache=n $Y/llvm.wasm clang --version
T "cold: wasmtime compile (cranelift) -> cwasm" wasmtime compile $Y/llvm.wasm -o /tmp/x.cwasm
T "cold: wasmtime compile -C compiler=winch -> cwasm" wasmtime compile -C compiler=winch $Y/llvm.wasm -o /tmp/x.cwasm
rm -f /tmp/x.cwasm
T "warm cache: wasmtime run llvm.wasm clang --version (implicit cache)" wasmtime run $Y/llvm.wasm clang --version
T "warm cache: wasmtime run llvm.wasm clang --version (implicit cache)" wasmtime run $Y/llvm.wasm clang --version
T "cwasm: clang --version" wasmtime run --allow-precompiled $Y/llvm.cwasm clang --version
for i in 1 2 3; do T "e2e wcc.py clang hello.c -> hello.wasm" ../wcc.py clang hello.c -o tmp/h.wasm; done
for i in 1 2 3; do T "e2e wcc.py clang -O2 main.c fib.c sum.c" ../wcc.py clang -O2 multi/main.c multi/fib.c multi/sum.c -o tmp/m.wasm; done
for i in 1 2 3; do T "e2e wcc.py clang++ -O2 -fno-exceptions hello.cpp" ../wcc.py clang++ -O2 -fno-exceptions hello.cpp -o tmp/c.wasm; done
for i in 1 2 3; do T "e2e wcc.py wasip2 tcpserver.c (clang+wasm-ld+wasm-tools.wasm)" env WCC_USR=$HOME/e2/usr2 WCC_WASM_TOOLS=$HOME/e2/tools/wasm-tools.cwasm ../wcc.py clang --target=wasm32-wasip2 -O2 tcpserver.c -o tmp/t.wasm; done
