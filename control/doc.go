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
a workspace, then run wasm modules (your own, or registered tools such as
the C/C++ compiler, which is itself wasm) against it.

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
    {"cmd": "cc -O2 -o app.wasm *.c && ./app.wasm x"}       command line, or
    {"module": "<tool | command | path in workspace>", "args": [...]}
    plus optional "env": {...}, "stdin": "...", "timeout_ms": 60000, "memory_mb": 512
  -> {"exit_code", "stdout", "stderr", "wall_ms", "state", "error", "steps": [...]}
  state: exited | failed (trap/instantiation error, see "error") | killed | timeout
  "cmd" supports quotes, globs (*.c) and && (stop at first failure); no
  pipes/redirection. Each "step" is one wasm execution (argv, wall_ms,
  load_ms, cache). Output of all steps is concatenated.
  Add ?async=1 to get {"job_id"} immediately, then:
- GET    /v1/jobs/{id}        (add ?wait=1 to block until done)
- DELETE /v1/jobs/{id}        kill
- GET    /v1/jobs

Modules: wasip1 command modules (GOOS=wasip1, wasm32-wasip1) or wasip2
command components (wasm32-wasip2). No network except for services.

## C / C++ (clang 22 + wasm-ld, running as wasm; needs the "llvm" tool)
Commands: cc, c++, clang, clang++, gcc, g++, wasm-ld, ar, ranlib, nm,
objdump, strip, size, c++filt. Normal clang arguments:
    {"cmd": "cc -O2 -Wall -o app.wasm main.c util.c"}            wasip1 (default)
    {"cmd": "c++ -O2 -o app.wasm main.cpp"}                      C++ with exceptions (wasip1)
    {"cmd": "cc --target=wasm32-wasip2 -o srv.wasm server.c"}    wasip2 component (sockets)
    {"cmd": "cc -c a.c && ar rcs liba.a a.o && cc main.c -L. -la -o app.wasm"}
Headers/libs live in /usr (wasi-libc, libc++). C++ is wasip1-only.

## Services (long-running servers)
- POST /v1/workspaces/{id}/services  {"module", "args", "env"}
  -> {"service_id", "port", "url", "kind"}
  wasip2 component (e.g. C built with --target=wasm32-wasip2): bind and
  listen on port $PORT yourself (any address, e.g. INADDR_ANY). Only that
  port may be bound; outbound connections, UDP and DNS are denied.
  wasip1 module: the host binds the port and passes a preopened listening
  socket whose fd is in $WASMDEV_LISTEN_FD (3 + number of preopened dirs).
  In Go:
      fd, _ := strconv.Atoi(os.Getenv("WASMDEV_LISTEN_FD"))
      ln, _ := net.FileListener(os.NewFile(uintptr(fd), "l"))
      http.Serve(ln, handler)
- GET    /v1/services
- GET    /v1/services/{id}
- GET    /v1/services/{id}/logs   -> {"stdout", "stderr"}
- DELETE /v1/services/{id}

## Tools (registry of wasm programs, e.g. compilers)
- GET    /v1/tools               (each with its "precompile" status)
- GET    /v1/tools/{name}        (?wait=1 blocks until precompiled)
- PUT    /v1/tools/{name}        body = raw .wasm (optional ?argv0=&description=)
                                 or a tar with tool.json + files (streamed):
     {"module": "llvm.wasm", "argv0": "llvm",
      "mounts": [{"path": "usr", "guest": "/usr"}], "env": {},
      "scratch": "/tmp", "commands": {"cc": ["clang"]}, "driver": "clang"}
  The module is compiled into the host cache right away (?wait=1 to block).
- DELETE /v1/tools/{name}
Run a tool by name or by one of its commands. Tool mounts are read-only.

## Admin
- POST /v1/tokens {"agent": "name"} (admin token only) -> {"token"}
`
