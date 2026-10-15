#!/usr/bin/env bash
# Build the Go toolchain (cmd/go + compile, asm, link, pack, vet, ...) as
# wasip1 modules for wasmdev, reproducibly, from a pinned Go release plus
# patches/go/*.patch.
#
# Native Go is used ONLY here, to bootstrap the .wasm files. At service
# runtime every Go process (go, compile, link, vet, test binaries) is wasm,
# spawned through the host's wasmdev_proc capability.
#
# Output ($OUT, default build/go-wasip1):
#   goroot/                 GOROOT for the guest: PRISTINE go1.27.2 sources
#                           (src, pkg/include, go.env, VERSION) - so programs
#                           built in wasm are identical to upstream builds -
#   goroot/bin/{go,gofmt}   cmd/go (wasm, patched std), gofmt
#   goroot/pkg/tool/wasip1_wasm/{compile,asm,link,pack,vet,buildid,test2json,cover}
#                           tools (wasm, patched std; tools are found by name,
#                           no .wasm suffix, as cmd/go expects)
#
# Only the toolchain binaries are built from the patched std (syscall/os/
# os/exec spawn + pipes; cmd/go filelock). The std sources that the guest
# compiles user code against are unpatched.
#
# Env: GOROOT_SRC (default /usr/local/go; must be $GO_VERSION, else a
# release tarball is downloaded and checked against $GO_SHA256),
# OUT, TOOLS.
set -euo pipefail
here=$(cd "$(dirname "$0")/.." && pwd)
GO_VERSION=go1.27.2
GO_SHA256=${GO_SHA256:-}
OUT=${OUT:-$here/build/go-wasip1}
TOOLS=${TOOLS:-"compile asm link pack vet buildid test2json cover"}
GOROOT_SRC=${GOROOT_SRC:-/usr/local/go}

if [ "$(head -1 "$GOROOT_SRC/VERSION" 2>/dev/null)" != "$GO_VERSION" ]; then
	dl=$OUT/dl
	mkdir -p "$dl"
	tgz=$dl/$GO_VERSION.linux-amd64.tar.gz
	[ -f "$tgz" ] || curl -fsSL -o "$tgz" "https://go.dev/dl/$GO_VERSION.linux-amd64.tar.gz"
	if [ -n "$GO_SHA256" ]; then echo "$GO_SHA256  $tgz" | sha256sum -c -; fi
	rm -rf "$dl/go" && tar -C "$dl" -xzf "$tgz"
	GOROOT_SRC=$dl/go
fi
echo "using $GOROOT_SRC ($(head -1 "$GOROOT_SRC/VERSION"))"

# 1. Patched tree for building the toolchain binaries.
work=$OUT/patched
rm -rf "$work"
mkdir -p "$work"
cp -a "$GOROOT_SRC/src" "$GOROOT_SRC/VERSION" "$GOROOT_SRC/go.env" "$work/"
ln -s "$GOROOT_SRC/pkg" "$work/pkg" # native compile/link for the bootstrap build
for p in "$here"/patches/go/*.patch; do
	echo "applying $(basename "$p")"
	patch -s -p1 -d "$work" <"$p"
done

# 2. Pristine guest GOROOT.
g=$OUT/goroot
rm -rf "$g"
mkdir -p "$g/bin" "$g/pkg/tool/wasip1_wasm"
cp -a "$GOROOT_SRC/src" "$GOROOT_SRC/VERSION" "$GOROOT_SRC/go.env" "$g/"
cp -a "$GOROOT_SRC/pkg/include" "$g/pkg/"

# 3. Build. Deterministic: -trimpath, fixed GOROOT path in the binaries
# does not matter (GOROOT is always passed in the environment).
export GOROOT=$work GOOS=wasip1 GOARCH=wasm CGO_ENABLED=0 GOTOOLCHAIN=local GOFLAGS=-trimpath
export GOCACHE=${GOCACHE:-$OUT/gocache-native}
cd "$work/src"
"$GOROOT_SRC/bin/go" build -o "$g/bin/go" ./cmd/go
"$GOROOT_SRC/bin/go" build -o "$g/bin/gofmt" ./cmd/gofmt # for go fmt
for t in $TOOLS; do
	"$GOROOT_SRC/bin/go" build -o "$g/pkg/tool/wasip1_wasm/$t" "./cmd/$t"
done
ls -la "$g/bin" "$g/pkg/tool/wasip1_wasm"
sha256sum "$g/bin/go" "$g/bin/gofmt" "$g"/pkg/tool/wasip1_wasm/* >"$OUT/SHA256SUMS"
echo "done: $g"
