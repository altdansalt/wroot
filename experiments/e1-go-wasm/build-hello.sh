#!/bin/bash
# Step 2 of e1: build hello world (and the http server) for wasip1 using ONLY the wasm toolchain.
# The plan comes from the native `go build -a -n`; runplan.py swaps every compile/asm/link/pack
# invocation for `wasmtime run --allow-precompiled --dir ~/e1::~/e1 --env PWD=... <tool>.cwasm`.
set -e
export PATH=$HOME/.wasmtime/bin:~/e1/goroot/bin:$PATH
cd ~/e1/hello
GOOS=wasip1 GOARCH=wasm go build -a -n -o hello.wasm . > plan.sh 2>&1        # plan only, nothing built
python3 ~/e1/runplan.py plan.sh --mode wasm   --work ~/e1/work-wasm   -j 2   # cold: all std deps
python3 ~/e1/runplan.py plan.sh --mode wasm   --work ~/e1/work-wasm   --reuse  # warm: main+link only
wasmtime hello.wasm
python3 ~/e1/runplan.py plan.sh --mode native --work ~/e1/work-native -j 2   # same plan, native tools
cd ~/e1/httpd
GOOS=wasip1 GOARCH=wasm go build -a -n -o httpd.wasm . > plan.sh 2>&1
python3 ~/e1/runplan.py plan.sh --mode wasm --work ~/e1/work-httpd-wasm -j 2
# wasmtime 49 removed the legacy p1 impl, which is the only one supporting tcplisten; use 36.x:
WT=~/e1/wt-old/wasmtime-v36.0.2-x86_64-linux/wasmtime
$WT run -S preview2=n -S tcplisten=127.0.0.1:8099 httpd.wasm &
sleep 25; curl -s http://127.0.0.1:8099/hi/there; kill %1
