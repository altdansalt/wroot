#!/bin/bash
# Benchmark compiling one std package (default: runtime) with native vs wasm compile under
# different wasmtime configurations. Requires a populated ~/e1/work-wasm (from runplan.py).
# Usage: bench-compile.sh [pkg] [reps]
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
run() { # label, command...
  local label=$1; shift
  for i in $(seq $REPS); do
    /usr/bin/time -f "$label	%e	%U	%M" bash -c "$*" 2>&1 >/dev/null | tail -1
  done
}
export GOOS=wasip1 GOARCH=wasm GOROOT
run "native -c=2"            "$GOROOT/pkg/tool/linux_amd64/compile $args"
run "native -c=1"            "$GOROOT/pkg/tool/linux_amd64/compile ${args/-c=2/-c=1}"
run "native -c=1 GOMAXPROCS=1" "GOMAXPROCS=1 $GOROOT/pkg/tool/linux_amd64/compile ${args/-c=2/-c=1}"
run "wasm cranelift o2 cwasm" "wasmtime run --allow-precompiled $WT $E1/bin/compile.cwasm $args"
run "wasm cranelift o0 cwasm" "wasmtime run --allow-precompiled $WT $E1/bin-o0/compile.cwasm $args"
run "wasm winch cwasm"        "wasmtime run -C compiler=winch --allow-precompiled $WT $E1/bin-winch/compile.cwasm $args"
run "wasm o2 GOGC=200"        "wasmtime run --allow-precompiled $WT --env GOGC=200 $E1/bin/compile.cwasm $args"
run "wasm o2 GOGC=off"        "wasmtime run --allow-precompiled $WT --env GOGC=off $E1/bin/compile.cwasm $args"
run "wasm o2 no-signals-traps" "wasmtime run -O signals-based-traps=n --allow-precompiled $WT $E1/bin-nosig/compile.cwasm $args"
