# wasmdev-host capabilities

`wasmdev-host` is the only native code in wasmdev. Everything else — the
HTTP API, workspace/tool/job bookkeeping, auth — is the control plane, a
wasip1 module (Go) running inside the host. Workloads (compilers, tests,
user programs, services) are separate wasm modules that the host compiles
and runs natively with wasmtime. Wasm is never interpreted inside wasm.

This file lists every capability the host grants to wasm, and why.

## To the control plane

| Capability | How | Why |
|---|---|---|
| WASI preview1 (args, env, clocks, random, `proc_exit`, `sched_yield`) | `wasmtime_wasi::p1` | Normal Go runtime needs these. |
| stdout / stderr | inherited from the host process | Logging. stdin is empty. |
| `/data` (read-write) | preopened dir, fd 3 | All persistent state: workspaces (`/data/ws`), run outputs (`/data/runs`), tool registry (`/data/tools`), agent tokens (`/data/tokens.json`). |
| One listening TCP socket | bound by the host to `--listen`, preopened as fd 4 (`$WASMDEV_LISTEN_FD`), starts NONBLOCK | Serving the HTTP API. The control plane cannot open other sockets (no `sock_open` in p1, and p2 sockets are not linked). |
| Env: `WASMDEV_TOKEN`, `WASMDEV_PUBLIC_HOST`, `WASMDEV_LISTEN_FD`, other `WASMDEV_*` from host env | `WasiCtxBuilder::env` | Admin bearer token; hostname to put in service URLs; listener fd. |
| `wasmdev.exec_start(spec_ptr, spec_len) -> i64` | host import | Start a workload. Spec is JSON (below). Never blocks: validation and port binding happen inline, compilation and execution on a new OS thread. Errors surface as status `failed`. |
| `wasmdev.exec_status(handle, buf_ptr, buf_cap) -> i32` | host import | Non-blocking status as JSON. Returns the JSON length; if it is > `buf_cap` nothing was written and the caller retries with a bigger buffer. `-1` = unknown handle. |
| `wasmdev.exec_kill(handle) -> i32` | host import | Request termination (asynchronous; observe via status). |
| `wasmdev.exec_release(handle) -> i32` | host import | Kill if running and forget the job record (frees memory). |

The control plane is CPU-preempted at every epoch tick (5 ms) by yielding
to the host executor; it has no memory limit (it is trusted code).

### Exec spec (JSON)

```json
{
  "module": "/data/ws/w1/hello.wasm",
  "args": ["hello.wasm", "a"],            // full argv incl. argv[0]
  "env": {"PWD": "/work"},
  "dirs": [{"host": "/data/ws/w1", "guest": "/work", "readonly": false}],
  "stdin": "/data/runs/j1/stdin",          // optional, default empty
  "stdout": "/data/runs/j1/stdout",        // optional, default discarded
  "stderr": "/data/runs/j1/stderr",
  "timeout_ms": 60000,                     // 0 = none
  "memory_limit_mb": 512,                  // 0 = host default (--memory-mb)
  "listen": false                          // true = service, see below
}
```

All paths are the control plane's view (`/data/...`). The host maps them
into the data dir, rejects non-normalized paths, and canonicalizes
(resolving symlinks) to make sure the result is still inside the data dir,
since workloads can create symlinks in their workspaces.

### Exec status (JSON)

```json
{"handle": 7, "state": "exited", "done": true, "exit_code": 0, "error": null,
 "wall_ms": 3.2, "load_ms": 0.1, "cache": "memory", "port": null, "listen_fd": null}
```

`state`: `starting | running | exited | failed | killed | timeout`.
`cache`: how the compiled module was obtained (`memory | disk | compiled`).

## To workloads

| Capability | How | Why |
|---|---|---|
| WASI preview1 | `wasmtime_wasi::p1` (patched, see below) | wasip1 command modules (Go, Rust, C via wasi-libc). |
| argv, env | from spec | |
| Directories | preopens from spec (`dirs`), read-only or read-write | Workspace at `/work`; tool data (sysroots etc.) read-only. Preopens are in spec order starting at fd 3. |
| stdin/stdout/stderr | files in the data dir | Captured output for the API. |
| Listening TCP socket (services only) | host binds `--service-bind` on a free port in `--service-ports` (default `0.0.0.0`, 8100–8199); preopened at fd `3 + len(dirs)`; `$WASMDEV_LISTEN_FD` | Long-running servers. Only `accept` on that listener — no outbound network, no `sock_open`. Port is released when the workload exits. |
| CPU time | epoch interruption every 5 ms → yield to executor; `timeout_ms` enforced by trap/cancellation | Never blocks other work; hard timeouts even when the guest is blocked in a host call (the future is dropped). |
| Memory | `StoreLimits` (`memory_limit_mb`, default `--memory-mb`), max 4 instances | Bound per-workload memory. |

Not granted to anything: outbound network, wasi:sockets (p2), threads,
access outside the data dir, host processes, the module cache directory.

## Module cache

Compiled modules are cached in memory (key: SHA-256 of the wasm bytes,
memoized on path+size+mtime) and on disk in `<data>.cache/`
(`<sha256>-<engine-compat-hash>.cwasm`, written via `Module::serialize`,
loaded via `Module::deserialize_file`). The cache dir is a sibling of the
data dir so no guest can plant a `.cwasm` (deserializing is `unsafe`:
it trusts the file as native code).

## The wasip1 socket patch

wasmtime 47+ removed the legacy `wasi-common` crate, and the p2-backed
`wasmtime_wasi::p1` returns `ENOTSOCK` for every `sock_*` call, so stock
wasmtime 49 can no longer run a wasip1 server on a preopened socket
(`wasmtime run -S tcplisten` is effectively dead for core modules). We
vendor `wasmtime-wasi` 49.0.3 under `host/vendor/` with a small patch
(`src/p1_socket.rs` + `Descriptor::Socket` in `src/p1.rs`):

- `WasiP1Ctx::preopen_tcp_listener(std::net::TcpListener)`; listeners get
  fds *after* preopened dirs, because wasi-libc and Go stop the preopen
  scan at the first `EBADF` from `fd_prestat_get`.
- `sock_accept`, `sock_recv`, `sock_send`, `sock_shutdown`;
  `fd_read`/`fd_write`/`fd_close`/`fd_fdstat_get`/`fd_fdstat_set_flags`/
  `fd_filestat_get` on sockets; `poll_oneoff` FD_READ/FD_WRITE readiness.
- OS sockets are always non-blocking and registered with tokio
  (`AsyncFd`); the guest's NONBLOCK flag is emulated, and "blocking"
  operations await readiness, so they stay cancellable.

Diff: `git diff <vendor commit> -- host/vendor/` (first commit is the
pristine crate).
