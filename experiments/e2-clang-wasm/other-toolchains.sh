#!/usr/bin/env bash
# Quick checks of other WASI-hosted toolchains (run on wasm-x2).
set -eu
export PATH=$HOME/.wasmtime/bin:$PATH
# CPython 3.15.0 WASI (brettcannon/cpython-wasi-build, built with wasi-sdk 33)
mkdir -p ~/e2/cpython && cd ~/e2/cpython
curl -sSLO https://github.com/brettcannon/cpython-wasi-build/releases/download/v3.15.0/python-3.15.0-wasi_sdk-33.zip
python3 -m zipfile -e python-3.15.0-wasi_sdk-33.zip .
wasmtime compile python.wasm -o python.cwasm
wasmtime run --allow-precompiled --dir ./lib::/lib --dir ./app::/app python.cwasm /app/t.py   # unittest OK, no _sqlite3
# Go compiler + linker built for wasip1 by the native go toolchain
mkdir -p ~/e2/go && cd ~/e2/go
GOOS=wasip1 GOARCH=wasm go build -o compile.wasm cmd/compile
GOOS=wasip1 GOARCH=wasm go build -o link.wasm cmd/link
C=$(go env GOCACHE)
GOOS=wasip1 GOARCH=wasm go list -export -f "{{if .Export}}packagefile {{.ImportPath}}={{.Export}}{{end}}" -deps fmt runtime > importcfg
sed -i "s#$C#/gocache#" importcfg
D="--dir .::/w --dir $C::/gocache"
wasmtime run $D compile.wasm -p main -importcfg /w/importcfg -o /w/hello.a /w/hello.go
wasmtime run $D link.wasm -importcfg /w/importcfg -buildmode=exe -o /w/hello.wasm /w/hello.a
wasmtime hello.wasm
