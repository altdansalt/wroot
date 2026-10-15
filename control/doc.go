package main

import (
	"net/http"
	"strings"
)

func (s *server) index(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/markdown; charset=utf-8")
	w.Write([]byte(strings.TrimSpace(apiDoc) + "\n"))
}

const apiDoc = `
# wasmdev — WebAssembly-native dev service for coding agents

Everything runs as WebAssembly executed natively by the host's wasmtime:
wasip1 core modules and wasip2 components (auto-detected). Upload files to
a workspace, then run wasm programs (your own, or registered tools such as
the C/C++ compiler and the Go toolchain, which are themselves wasm) in it.

Auth: send "Authorization: Bearer <token>" on every /v1 request.
All bodies are JSON unless noted. Errors: {"error": "..."}.

## Workspaces
- POST   /v1/workspaces                         -> {"id"}
- GET    /v1/workspaces
- DELETE /v1/workspaces/{id}
- PUT    /v1/workspaces/{id}/files/{path}       raw body = file contents
- GET    /v1/workspaces/{id}/files/{path}       raw contents; a directory (or "" / ".") -> JSON listing
- DELETE /v1/workspaces/{id}/files/{path}
- POST   /v1/workspaces/{id}/files              many files: {"files": {"a/b.txt": "text"}} or a tar (Content-Type: application/x-tar)

The workspace is mounted at /work (= $PWD) and at / (wasi-libc programs
resolve relative paths against /). Tool mounts such as /usr shadow it.

## Running
- POST /v1/workspaces/{id}/run
    {"cmd": "cc -O2 -o app.wasm *.c && ./app.wasm < in.txt > out.txt && diff out.txt want.txt"}
    {"module": "<tool | command | path in workspace>", "args": [...]}
  optional: "env": {...}, "stdin": "...", "timeout_ms": 60000, "memory_mb": 512,
            "max_wasm_stack": 8388608 (bytes, see Limits), "compiler": "tiered"|"cranelift"|"winch"
  -> {"exit_code", "stdout", "stderr", "wall_ms", "state", "error", "trap", "steps": [...]}
  state: exited | failed (trap/instantiation error, see "error" and "trap") | killed | timeout
  Add ?async=1 to get {"job_id"} immediately, then:
- GET    /v1/jobs/{id}        (add ?wait=1 to block until done)
- DELETE /v1/jobs/{id}        kill
- GET    /v1/jobs

"cmd" is a small shell:
  - words, '...' and "..." quoting, backslash escapes, globs (*.c ? [..]) against the workspace
  - a && b, a || b, a ; b   (exit_code = last command run, like sh)
  - a | b                   pipes are BUFFERED: a runs to completion, then b reads its output
  - < file, > file, >> file, 2> file, 2>> file, 2>&1   (paths relative to the workspace)
  - builtins: echo [-n], cat [files|-], cmp A B, diff A B (unified-style, exit 1 if different), true, false
  - no variables ($X), substitution, subshells, loops, background jobs, cd (use "go -C dir" or paths)
Each "step" is one wasm execution (argv, wall_ms, load_ms, cache, compiler) or builtin.
Compiling your programs: by default ("tiered") a new program's first run uses the fast
baseline compiler Winch (~5x faster to compile, code ~2x slower) while the optimizing
Cranelift compiles it in the background; later runs use the Cranelift code.
"compiler": "cranelift" forces optimized code (slower first start).
A failed (trapped) step stops the command line; output written before the trap is kept.

Programs: wasip1 command modules (GOOS=wasip1, wasm32-wasip1) or wasip2
command components (wasm32-wasip2). No network except for services; no
threads; user programs cannot start subprocesses.

## Limits
- wasm call stack ("max_wasm_stack"): 8 MiB by default per run (max 256 MiB).
  Exceeding it traps with trap "stack_overflow". Set it per run (bytes):
  {"cmd": "./interp.wasm deep.txt", "max_wasm_stack": 67108864}. It applies to
  workspace programs and to what go runs (test binaries), not to the compilers.
- C/C++ linear-memory stack: cc/c++ link with -Wl,-z,stack-size=1048576 (1 MiB)
  unless you pass your own -Wl,-z,stack-size=N. Overflowing it shows up as
  trap "memory_out_of_bounds" at an address just below 4 GiB (0xffff....).
- memory_mb: per-program linear memory limit (default 1024).
- timeout_ms: whole run (all steps).

## C / C++ (clang 22 + wasm-ld, running as wasm; needs the "llvm" tool)
Commands: cc, c++, clang, clang++, gcc, g++, wasm-ld, ar, ranlib, nm,
objdump, strip, size, c++filt. Normal clang arguments:
    {"cmd": "cc -O2 -Wall -o app.wasm main.c util.c"}            wasip1 (default)
    {"cmd": "c++ -O2 -o app.wasm main.cpp"}                      C++ with exceptions (wasip1)
    {"cmd": "cc --target=wasm32-wasip2 -o srv.wasm server.c"}    wasip2 component (sockets)
    {"cmd": "cc -c a.c && ar rcs liba.a a.o && cc main.c -L. -la -o app.wasm"}
Headers/libs live in /usr (wasi-libc, libc++). C++ is wasip1-only.
C++ compiles are slow (libc++ headers; ~10-40 s per file): prefer -O0/-O1
while iterating and split code into several files.

### WASI libc gotchas
- tmpfile(), tmpnam(): not available. fopen a file in the workspace instead.
- printf/scanf of long double (%Lf, %Lg): link with -lc-printscan-long-double
  (else the program traps in long_double_not_supported).
- No threads (no -pthread), no fork/exec/system/popen, no sockets in wasip1.
- Emulations are opt-in (the compile error names the flag): signal()/raise():
  -D_WASI_EMULATED_SIGNAL -lwasi-emulated-signal; anonymous mmap:
  -D_WASI_EMULATED_MMAN -lwasi-emulated-mman; getpid: -D_WASI_EMULATED_GETPID
  -lwasi-emulated-getpid; clock()/times(): -D_WASI_EMULATED_PROCESS_CLOCKS
  -lwasi-emulated-process-clocks.
- Stack: 1 MiB default (see Limits); big local arrays -> make them static or heap.
- stdout is fully buffered when not a terminal: if the program may trap, fflush(stdout)
  (or setvbuf(stdout, NULL, _IONBF, 0)) to keep output written before the crash.
- Servers: build with --target=wasm32-wasip2 (see Services).

## Go (go1.27.2; cmd/go, compile, link, vet all run as wasm; needs the "go" tool)
    {"cmd": "go build -o app.wasm . && ./app.wasm"}
    {"cmd": "go test ./..."}              (exit_code 1 and FAIL lines if a test fails)
    {"cmd": "go vet ./... && go test -run TestX -v ./pkg"}
    {"cmd": "go run ./cmd/tool arg"}
GOOS=wasip1 GOARCH=wasm, CGO_ENABLED=0, GOFLAGS=-p=<host cores> (override via "env"),
GOPROXY=off (no downloads: only the standard library and vendored modules — use
"go mod vendor" locally and upload vendor/), GOTOOLCHAIN=local. The build cache
(GOCACHE) is shared by all workspaces, so std packages compile once; first build of
new packages is ~5x slower than native. Test binaries are compiled with the fast
baseline compiler (Winch). Go programs: no threads (GOMAXPROCS=1), no os/exec.

### Go HTTP service (wasip1): use the listener the host passes in
    import ("net"; "net/http"; "os"; "strconv")
    func listener() net.Listener {
        fd, err := strconv.Atoi(os.Getenv("WASMDEV_LISTEN_FD"))
        if err != nil { l, _ := net.Listen("tcp", ":8080"); return l } // native fallback
        l, err := net.FileListener(os.NewFile(uintptr(fd), "listener"))
        if err != nil { panic(err) }
        return l
    }
    func main() { http.Serve(listener(), handler) }
Build with go build -o srv.wasm . then POST .../services {"module": "srv.wasm", "wait_ready": true}.
(net.Listen itself does not work in wasip1; outbound connections are not possible.)

## Services (long-running servers)
- POST /v1/workspaces/{id}/services  {"module", "args", "env", "wait_ready": true, "ready_timeout_ms": 30000}
  -> {"service_id", "port", "url", "local_url", "kind", "state", "ready", "ready_ms"}
  url: the address to use from elsewhere (the public HTTPS proxy URL when the service
  has a public host, e.g. https://host.example:8100/); local_url: http://127.0.0.1:port/.
  wait_ready: respond once the program accepts connections (wasip1: it called accept;
  wasip2: its port accepts a TCP connection), or with "ready": false plus its stdout/
  stderr if it exited or timed out. ready_ms = time from start to ready.
  wasip2 component (e.g. C built with --target=wasm32-wasip2): bind and
  listen on port $PORT yourself (any address, e.g. INADDR_ANY). Only that
  port may be bound; outbound connections, UDP and DNS are denied.
  wasip1 module (Go, see above): the host binds the port and passes a preopened
  listening socket whose fd is in $WASMDEV_LISTEN_FD.
- GET    /v1/services
- GET    /v1/services/{id}
- GET    /v1/services/{id}/logs   -> {"stdout", "stderr"}
- DELETE /v1/services/{id}

## Tools (registry of wasm programs, e.g. compilers)
- GET    /v1/tools               (each with its "precompile" status)
- GET    /v1/tools/{name}        (?wait=1 blocks until precompiled and warmed)
- PUT    /v1/tools/{name}        body = raw .wasm (optional ?argv0=&description=)
                                 or a tar with tool.json + files (streamed):
     {"module": "llvm.wasm", "argv0": "llvm",
      "mounts": [{"path": "usr", "guest": "/usr"}], "env": {"K": "v, {cpus} = host cores"},
      "scratch": "/tmp", "scratch_compiler": "winch", "commands": {"cc": ["clang"]},
      "driver": "clang", "spawn": true, "shared": [{"name": "cache", "guest": "/cache"}],
      "precompile_modules": ["bin/other.wasm"], "warm": {"files": {...}, "cmd": "..."}}
  Modules are compiled into the host cache right away, then "warm.cmd" runs once
  in a scratch workspace (?wait=1 to block).
- DELETE /v1/tools/{name}
Run a tool by name or by one of its commands. Tool mounts are read-only.

## Admin
- POST /v1/tokens {"agent": "name"} (admin token only) -> {"token"}
`
