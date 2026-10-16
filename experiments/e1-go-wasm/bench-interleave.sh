#!/bin/bash
# Interleaved native vs wasm compile of one package, recording host CPU steal% per run.
# Usage: bench-interleave.sh [pkg] [reps]
PKG=${1:-runtime}; REPS=${2:-3}
export PATH=$HOME/.wasmtime/bin:$PATH
E1=$HOME/e1; WORK=$E1/work-wasm; GOROOT=$E1/goroot
line=$(grep -E "linux_amd64/compile .* -p $PKG " $E1/hello/plan.sh | head -1)
args=${line#*linux_amd64/compile }
args=${args//\$WORK/$WORK}
args=${args//-o $WORK/-o /tmp/bench}
mkdir -p /tmp/bench/$(basename $(dirname $(echo $args | awk '{print $2}')))
cd $GOROOT/src/$PKG
WT="--dir $E1::$E1 --dir /tmp::/tmp --env PWD=$PWD --env GOOS=wasip1 --env GOARCH=wasm"
export GOOS=wasip1 GOARCH=wasm GOROOT
steal() { awk '/^cpu /{print $9, $2+$3+$4+$5+$6+$7+$8+$9}' /proc/stat; }
run() {
  local label=$1; shift
  read s0 t0 < <(steal)
  local r=$(/usr/bin/time -f "%e	%U	%M" bash -c "$*" 2>&1 >/dev/null | tail -1)
  read s1 t1 < <(steal)
  echo "$PKG	$label	$r	steal=$(( 100*(s1-s0)/(t1-t0+1) ))%"
}
for i in $(seq $REPS); do
  run "native -c=1 GOMAXPROCS=1" "GOMAXPROCS=1 $GOROOT/pkg/tool/linux_amd64/compile ${args/-c=2/-c=1}"
  run "native -c=2"              "$GOROOT/pkg/tool/linux_amd64/compile $args"
  run "wasm o2 cwasm"            "wasmtime run --allow-precompiled $WT $E1/bin/compile.cwasm $args"
  run "wasm o2 GOGC=off"         "wasmtime run --allow-precompiled $WT --env GOGC=off $E1/bin/compile.cwasm $args"
done
