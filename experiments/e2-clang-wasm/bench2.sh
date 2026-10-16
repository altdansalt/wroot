#!/usr/bin/env bash
# Steady-state compile-time comparison, robust to CPU steal on the helper VM:
# configs are INTERLEAVED round-robin for R rounds; report MIN wall, MIN
# user+sys CPU, max RSS per (config, input).
# Run on wasm-x2 from ~/e2/work.  Output -> ~/e2/bench2.txt
set -u
export PATH=$HOME/.wasmtime/bin:$PATH
Y=$HOME/e2/yowasp; mkdir -p tmp
R=${R:-5}
declare -A BW BC BR
run1() {  # key cmd...
  local key=$1; shift
  /usr/bin/time -o tmp/.t -f "%e %U %S %M" "$@" >/dev/null 2>tmp/.err || { BW[$key]=FAIL; return; }
  local w u s rss c
  read w u s rss < tmp/.t
  c=$(echo "$u + $s" | bc)
  [[ -z ${BW[$key]:-} || $(echo "$w < ${BW[$key]}" | bc) == 1 ]] && BW[$key]=$w
  [[ -z ${BC[$key]:-} || $(echo "$c < ${BC[$key]}" | bc) == 1 ]] && BC[$key]=$c
  (( rss > ${BR[$key]:-0} )) && BR[$key]=$rss
}
CONFIGS=(cranelift cranelift-O0 winch native18)
INPUTS=("hello.c" "big.c" "-O2 big.c" "hello.cpp")
cmd_for() {  # config input -> prints command
  local cfg=$1 in=$2 drv=clang extra=""
  [[ $in == *.cpp ]] && { drv=clang++; extra="-fno-exceptions"; }
  case $cfg in
    cranelift)    echo "wasmtime run --allow-precompiled --dir .::/ --dir $Y/usr::/usr $Y/llvm.cwasm $drv -c $extra $in -o tmp/a.o";;
    cranelift-O0) echo "wasmtime run --allow-precompiled --dir .::/ --dir $Y/usr::/usr $Y/llvm-o0.cwasm $drv -c $extra $in -o tmp/a.o";;
    winch)        echo "wasmtime run -C compiler=winch --allow-precompiled --dir .::/ --dir $Y/usr::/usr $Y/llvm-winch.cwasm $drv -c $extra $in -o tmp/a.o";;
    native18)     if [[ $in == *.cpp ]]; then echo "clang++ -c $in -o tmp/n.o";  # x86 + libstdc++ (clang18 can't parse libc++22 headers)
                  else echo "clang --target=wasm32-wasip1 --sysroot=$Y/usr -c $in -o tmp/n.o"; fi;;
  esac
}
for r in $(seq $R); do
  for in in "${INPUTS[@]}"; do
    for cfg in "${CONFIGS[@]}"; do
      run1 "$cfg|$in" $(cmd_for $cfg "$in")
    done
  done
done
printf '%-14s %-12s %9s %9s %10s\n' config input min_wall min_cpu maxrss_KB
for in in "${INPUTS[@]}"; do
  for cfg in "${CONFIGS[@]}"; do
    k="$cfg|$in"
    printf '%-14s %-12s %9s %9s %10s\n' "$cfg" "$in" "${BW[$k]}" "${BC[$k]:-}" "${BR[$k]:-}"
  done
done
