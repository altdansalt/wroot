#!/usr/bin/env bash
# Register the Go toolchain (from scripts/build-go-toolchain.sh) as the
# wasmdev tool "go", using only the HTTP API:
#   PUT /v1/tools/go   streamed tar: tool.json + goroot/ (pristine std
#                      sources + wasip1 go/compile/link/vet/... binaries)
# The service then (1) compiles go and the tools it spawns into the host's
# module cache (Cranelift, one time, ~5-10 min on 2 vCPUs) and (2) runs the
# "warm" command once, which builds/vets/tests a program importing
# net/http and testing so that GOCACHE (shared by all workspaces) holds
# the standard library. ?wait=1 blocks until both are done.
#
#   API=http://127.0.0.1:8780 TOKEN=... scripts/register-go.sh
set -euo pipefail
cd "$(dirname "$0")/.."
API=${API:-http://127.0.0.1:8780}
: "${TOKEN:?set TOKEN}"
G=${GO_TOOLCHAIN:-$PWD/build/go-wasip1}
[[ -f $G/goroot/bin/go ]] || { echo "run scripts/build-go-toolchain.sh first"; exit 1; }
ver=$(head -1 "$G/goroot/VERSION")

python3 - "$G/tool.json" "$ver" <<'PY'
import json, sys
tools = ["compile", "link", "asm", "vet", "buildid", "cover", "test2json", "pack"]
warm_main = '''package main

import (
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"os"
	"strconv"
)

func listener() net.Listener {
	fd, _ := strconv.Atoi(os.Getenv("WASMDEV_LISTEN_FD"))
	l, err := net.FileListener(os.NewFile(uintptr(fd), "listener"))
	if err != nil {
		panic(err)
	}
	return l
}

func main() {
	if len(os.Args) > 1 {
		http.Serve(listener(), http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			json.NewEncoder(w).Encode(map[string]string{"path": r.URL.Path})
		}))
	}
	fmt.Println(Add(1, 2))
}

func Add(a, b int) int { return a + b }
'''
warm_test = '''package main

import "testing"

func TestAdd(t *testing.T) {
	if Add(1, 2) != 3 {
		t.Fatal("bad")
	}
}
'''
m = {
    "module": "goroot/bin/go",
    "argv0": "go",
    "description": f"Go {sys.argv[2]} toolchain for GOOS=wasip1 GOARCH=wasm: cmd/go and the tools it runs (compile, link, vet, test binaries) are all wasm processes (wasmdev_proc spawn)",
    "mounts": [{"path": "goroot", "guest": "/usr/local/go"}],
    "scratch": "/tmp",
    "scratch_compiler": "winch",
    "shared": [{"name": "gocache", "guest": "/gocache"}],
    "spawn": True,
    "env": {
        "GOROOT": "/usr/local/go", "PATH": "/usr/local/go/bin",
        "GOCACHE": "/gocache", "GOTMPDIR": "/tmp", "HOME": "/tmp/home", "GOPATH": "/tmp/gopath",
        "GOFLAGS": "-p={cpus}", "GOTOOLCHAIN": "local", "GOPROXY": "off", "GOSUMDB": "off",
        "CGO_ENABLED": "0", "GOOS": "wasip1", "GOARCH": "wasm",
    },
    "commands": {"go": []},
    "precompile_modules": ["goroot/bin/gofmt"] + [f"goroot/pkg/tool/wasip1_wasm/{t}" for t in tools],
    "warm": {
        "files": {"go.mod": "module warm\n\ngo 1.27\n", "main.go": warm_main, "main_test.go": warm_test},
        "cmd": "go build -o /tmp/warm.wasm . && go vet . && go test -count=1 .",
    },
}
json.dump(m, open(sys.argv[1], "w"), indent=2)
PY

t0=$(date +%s%N)
tar -C "$G" -cf - tool.json goroot |
  curl -sS --fail-with-body -X PUT -T - -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/x-tar" "$API/v1/tools/go?wait=1" |
  jq -c '{name: .tool.name, upload_ms, precompile: .tool.precompile}'
echo "  go registered + precompiled + warmed in $(( ($(date +%s%N) - t0) / 1000000 )) ms"
