#!/usr/bin/env bash
# Run cmd/go (wasm) under `wasmdev-host exec` on a module directory; every
# child (compile, asm, link, vet, test binaries) is spawned as wasm through
# the host's wasmdev_proc capability.
#
#   experiments/e5-spawn/run-go.sh <module dir> <go args...>
#   e.g. run-go.sh experiments/e5-spawn/testmod test -p 2 ./...
#
# Env: HOST (wasmdev-host binary), TC (guest GOROOT from
# scripts/build-go-toolchain.sh), STATE (persistent GOCACHE/tmp dir),
# WASMDEV_CACHE (compiled-module cache), WASMDEV_TRACE_PROC=1 (per-process log).
set -euo pipefail
here=$(cd "$(dirname "$0")/../.." && pwd)
HOST=${HOST:-$here/host/target/release/wasmdev-host}
TC=${TC:-$here/build/go-wasip1/goroot}
STATE=${STATE:-$here/build/e5-state}
mod=$(cd "$1" && pwd)
shift
mkdir -p "$STATE"/{gocache,tmp,home}
exec "$HOST" exec \
	--dir "$TC::/goroot:ro" \
	--dir "$STATE::/state" \
	--dir "$mod::/work" \
	--cwd /work \
	--env GOROOT=/goroot \
	--env GOCACHE=/state/gocache \
	--env HOME=/state/home \
	--env GOPATH=/state/home/go \
	--env GOTMPDIR=/state/tmp \
	--env TMPDIR=/state/tmp \
	--env GOTOOLCHAIN=local \
	--env GOPROXY=off \
	--env GOSUMDB=off \
	--env GOWORK=off \
	--env CGO_ENABLED=0 \
	--env PATH=/goroot/bin \
	-- "$TC/bin/go" "$@"
