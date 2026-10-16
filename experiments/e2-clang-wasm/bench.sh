#!/usr/bin/env bash
# Benchmark YoWASP clang.wasm under wasmtime vs native clang 18.
# Run on wasm-x2 from ~/e2/work (sources copied from ../src).
# Prints: label  median_wall_s  max_rss_kb   (3 runs each)
set -u
export PATH=$HOME/.wasmtime/bin:$HOME/.local/bin:$PATH
Y=$HOME/e2/yowasp
W="wasmtime run --allow-precompiled --dir .::/ --dir $Y/usr::/usr --dir ./tmp::/tmp --env TMPDIR=/tmp $Y/llvm.cwasm"
mkdir -p tmp

bench() {  # label cmd...
  local label=$1; shift
  local ts=() rss=0
  for i in 1 2 3; do
    /usr/bin/time -o tmp/.t -f "%e %M" "$@" >/dev/null 2>&1 || echo "  ($label: exit $?)" >&2
    out=$(tail -1 tmp/.t)
    ts+=("${out% *}"); r=${out#* }; (( r > rss )) && rss=$r
  done
  med=$(printf '%s\n' "${ts[@]}" | sort -n | sed -n 2p)
  printf '%-48s %8s s %9s KB\n' "$label" "$med" "$rss"
}

bench "wasm: clang --version (cwasm load)"        $W clang --version
bench "wasm: hello.c -c -O0"                      $W clang -c hello.c -o tmp/a.o
bench "wasm: hello.c -c -O2"                      $W clang -c -O2 hello.c -o tmp/a.o
bench "wasm: big.c (2.2k lines) -c -O0"           $W clang -c big.c -o tmp/a.o
bench "wasm: big.c (2.2k lines) -c -O2"           $W clang -c -O2 big.c -o tmp/a.o
bench "wasm: hello.cpp (iostream) -c -O0 -fno-exc" $W clang++ -c -fno-exceptions hello.cpp -o tmp/a.o
bench "wasm: hello.cpp (iostream) -c -O2 -fno-exc" $W clang++ -c -O2 -fno-exceptions hello.cpp -o tmp/a.o
$W clang -c hello.c -o tmp/h.o
bench "wasm: wasm-ld hello"                        $W wasm-ld -m wasm32 -L/usr/lib/wasm32-wasip1 /usr/lib/wasm32-wasip1/crt1-command.o /tmp/h.o -lc /usr/lib/wasm32-unknown-wasip1/libclang_rt.builtins.a -o /tmp/h.wasm
bench "wasm: wcc.py clang hello.c (driver+cc1+ld)" ../wcc.py clang hello.c -o tmp/h2.wasm

N="clang --target=wasm32-wasip1 --sysroot=$Y/usr"
bench "native18->wasm32: hello.c -c -O0"           $N -c hello.c -o tmp/n.o
bench "native18->wasm32: big.c -c -O0"             $N -c big.c -o tmp/n.o
bench "native18->wasm32: big.c -c -O2"             $N -c -O2 big.c -o tmp/n.o
bench "native18->wasm32: hello.cpp -c -O0 -fno-exc" $N -c -fno-exceptions -nostdinc++ -isystem $Y/usr/include/c++/v1 hello.cpp -o tmp/n.o
bench "native18->wasm32: hello.cpp -c -O2 -fno-exc" $N -c -O2 -fno-exceptions -nostdinc++ -isystem $Y/usr/include/c++/v1 hello.cpp -o tmp/n.o
