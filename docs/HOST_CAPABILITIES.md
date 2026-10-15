# wasmdev-host capabilities

`wasmdev-host` is the only native code in wasmdev. Everything else — the
HTTP API, workspace/tool/job bookkeeping, auth — is the control plane, a
wasip1 module (Go) running inside the host. Workloads (compilers, tests,
user programs, services) are separate wasm programs — wasip1 core modules
or wasip2 components, detected from the binary header — that the host
compiles and runs natively with wasmtime. Wasm is never interpreted inside
wasm. Build orchestration (e.g. the clang driver that splits `clang -###`
into jobs) is control-plane code; the host only executes what it is given.

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
  "listen": false,                         // true = service, see below
  "precompile_only": false                 // true = only compile into the cache
}
```

`precompile_only` compiles the module (or loads it from the disk cache)
into the in-memory cache and finishes with state `exited` without
instantiating it. The control plane uses it to warm toolchains when they
are registered and at startup, so the first `cc` call doesn't pay the
2–4 minute compile of clang. The cache's compile lock serializes compiles
(one ~1.9 GB clang compile at a time on a 4 GB VM).

All paths are the control plane's view (`/data/...`). The host maps them
into the data dir, rejects non-normalized paths, and canonicalizes
(resolving symlinks) to make sure the result is still inside the data dir,
since workloads can create symlinks in their workspaces.

### Exec status (JSON)

```json
{"handle": 7, "state": "exited", "done": true, "exit_code": 0, "error": null,
 "wall_ms": 3.2, "load_ms": 0.1, "cache": "memory", "port": null, "listen_fd": null,
 "kind": "module"}
```

`state`: `starting | running | exited | failed | killed | timeout`.
`cache`: how the compiled module was obtained (`memory | disk | compiled`).
`kind`: `module` (wasip1 core module) or `component` (wasip2).

## To workloads

| Capability | How | Why |
|---|---|---|
| WASI preview1 | `wasmtime_wasi::p1` (patched, see below) | wasip1 command modules (Go, Rust, C via wasi-libc, the clang toolchain itself). |
| WASI preview2 (`wasi:cli/command` components) | `wasmtime_wasi::p2` component linker; `wasi:cli/run` is called | wasip2 programs (C built with `--target=wasm32-wasip2`), mainly network services. Same spec/status contract as modules. |
| argv, env | from spec | |
| Directories | preopens from spec (`dirs`), read-only or read-write | The control plane mounts the workspace at `/work` and `/` (wasi-libc ignores `$PWD`, so relative paths resolve against `/`), and tool data (sysroots) read-only. Preopens are in spec order starting at fd 3. |
| stdin/stdout/stderr | files in the data dir | Captured output for the API. |
| Listening TCP socket, wasip1 service | host binds `--service-bind` on a free port in `--service-ports` (default `0.0.0.0`, 8100–8199); preopened at fd `3 + len(dirs)`; `$WASMDEV_LISTEN_FD` | Long-running servers. Only `accept` on that listener — no `sock_open`, no outbound. Port is released when the workload exits. |
| `wasi:sockets` TCP, wasip2 service | host reserves a free port (bind, held until the guest starts, then released), passes it as `$PORT` / `$WASMDEV_PORT`, and installs a `socket_addr_check` | The guest binds/listens itself. **Allowed:** `TcpBind`/`TcpListen` on exactly the assigned port, on an address no wider than `--service-bind` (any address if that is `0.0.0.0`; else that address or loopback); `TcpAccept` from anyone. **Denied:** `TcpConnect` (all outbound, including loopback, other services and the control plane), UDP (`allow_udp(false)`), DNS (`allow_ip_name_lookup(false)`). Small race: between releasing the reservation and the guest's bind another process could take the port; then the guest's `bind` fails and the service exits. |
| No sockets, plain runs | components that are not services get `allow_tcp(false)` too | Builds and tests are offline. |
| CPU time | epoch interruption every 5 ms → yield to executor; `timeout_ms` enforced by trap/cancellation | Never blocks other work; hard timeouts even when the guest is blocked in a host call (the future is dropped). |
| Memory | `StoreLimits` (`memory_limit_mb`, default `--memory-mb`); max 4 instances per module, 64 per component (wit-component shims) | Bound per-workload memory. |
| Wasm features | wasmtime defaults + exceptions (`gc`/`gc-drc` cargo features) | C++ built with `-fwasm-exceptions` (exnref encoding) needs the exception-handling proposal; legacy EH is not supported by wasmtime 49. |
| Child processes (wasip1 core modules only) | `wasmdev_proc.*` imports, see [Process spawn](#process-spawn-wasmdev_proc) | Unmodified tool drivers (`cmd/go`, later clang's driver) orchestrate their own sub-tools (compile, asm, link, vet, test binaries) as further wasm processes. The children are wasm modules found through the caller's own preopens and get no more authority than the caller. |

**Outbound network decision.** Workloads get no outbound network: not
for builds (reproducibility, no exfiltration of workspace contents, no
abuse of the VM's IP), and not for services. Ingress to services is
through their assigned port only. When agents need outbound access (e.g.
fetching dependencies), the plan is an explicit per-run grant from the
control plane (`ExecSpec.network`: an allow-list of host:port checked in
`socket_addr_check`, plus `allow_ip_name_lookup`) rather than a blanket
`inherit_network()`. wasip1 modules can't open sockets at all (p1 has no
`sock_open`).

Not granted to anything: outbound network, UDP, DNS, threads, access
outside the data dir, host (native) processes, the module cache directory.
Child *wasm* processes are granted (below); native processes are not.

## Process spawn (`wasmdev_proc`)

Why: real toolchains are *drivers* that run other programs. `go build` runs
`compile`/`asm`/`link` once per package, `go test` additionally runs `vet` and
the test binary, clang's driver runs `cc1` and `wasm-ld`. Without a spawn
primitive the orchestration has to be re-implemented outside the tool (e.g.
`go build -n` plans or `clang -###` job lists replayed by the control plane).
With it, the unmodified driver runs in wasm and the host only executes what it
asks for. Process spawn is the only way to get concurrency for single-threaded
wasip1 tools too: children run on their own host threads, so `go build -p 2`
really compiles two packages at once.

Every wasip1 workload (and its children, recursively) gets this import module.
All functions return a WASI errno (0 = success); none of them blocks the
caller except `wait` with `nohang = 0`.

| Import | Semantics |
|---|---|
| `spawn(path, path_len, argv, argv_len, env, env_len, dir, dir_len, fd0, fd1, fd2, *pid, *exit_fd) -> errno` | Start a child. `path`/`dir`: absolute guest paths (UTF-8, not NUL-terminated). `argv`/`env`: concatenated NUL-terminated strings (`env` entries `K=V`; the child gets exactly these plus `PWD=dir`). `fd0..fd2`: **caller** fds to become the child's stdin/stdout/stderr (any file, pipe end, socket, or the caller's own stdio), `-1` = /dev/null. Returns a pid (>= 1000) and an *exit fd*. `ENOENT` (not found via preopens), `EACCES` (not a regular file / resolves outside its mount), `ENOEXEC` (not wasm), `EBADF` (bad stdio fd), `EAGAIN` (limits). |
| exit fd | A stream socket in the caller's fd table that reaches EOF when the child has exited. The caller waits for it like for any other fd (Go: netpoller via `poll_oneoff`), so a single-threaded guest keeps running its other work (e.g. copying child output) while children run. |
| `wait(pid, nohang, *status) -> errno` | Reap a child. With `nohang` returns `EAGAIN` while it runs. Status is Unix-encoded: exit code `<< 8`; killed/timed out = signal 9; host-level failure (trap, bad module) = signal 6. `ECHILD` for pids that are not the caller's children. |
| `kill(pid, sig) -> errno` | Terminate a child (any signal = kill; asynchronous, observe via the exit fd). `ESRCH` if not a child. |
| `pipe(*fds[2]) -> errno` | A connected pair (read end, write end) of stream fds (a Unix socket pair, shut down in the other direction). Pollable and non-blocking-capable, so Go's `os.Pipe` + netpoller work. |
| `open_null(write, *fd) -> errno` | A real `/dev/null` fd (Go's `os/exec` opens `os.DevNull` for unset stdio). |

Resolution and isolation:
- The program path is resolved through the **caller's preopens** (longest
  guest-prefix match), then canonicalized; it must stay inside that mount
  (symlinks cannot escape). The file must start with the wasm magic.
- The child gets exactly the caller's preopens (same guest paths, same
  read-only/read-write permissions), so absolute paths mean the same thing in
  parent and child. It cannot gain a directory the parent does not have.
- `PWD` carries the working directory: wasip1 has no cwd; Go emulates it from
  `$PWD`. (wasi-libc programs start at `/`; pass them absolute paths.)
- Children inherit the parent's memory limit, run without a timeout of their
  own, and are killed when the parent's store is dropped (parent exit, kill or
  timeout): no orphans. Limits: 64 live children per process, depth 8.
- Children use the shared compiled-module cache (memory, then disk), so a
  53 MB `compile` spawn costs ~0.2 s from disk once per host process and
  ~0 afterwards; a first-ever module (e.g. a new test binary) is compiled by
  Cranelift on spawn.
- wasip2 components can be *spawned* (as children) but do not get
  `wasmdev_proc` themselves.

Guest side: Go needs a small std patch (only for the toolchain binaries, see
`patches/go/` and `scripts/build-go-toolchain.sh`): `syscall.StartProcess`,
`Wait4`, `Kill`, `Pipe`, a real `WaitStatus`, `/dev/null` on wasip1;
`os.Pipe`; `os.(*Process).blockUntilWaitable` reads the exit fd through the
netpoller; `exec.LookPath` stats files (WASI has no x bits). Programs the
guest *builds* are compiled against pristine std and do not import
`wasmdev_proc`.

Test harness without the control plane:

```
wasmdev-host exec [--dir HOST[::GUEST][:ro]]... [--env K=V]... [--cwd GUEST] \
                  [--cache DIR] [--memory-mb N] -- module.wasm [args...]
```

stdio inherited, exit code propagated, `WASMDEV_TRACE_PROC=1` logs one line per
process (wall time, module load time, cache hit kind). See
`experiments/e5-spawn/run-go.sh`.
## Module cache

Compiled modules and components are cached in memory (key: SHA-256 of
the wasm bytes, memoized on path+size+mtime) and on disk in `<data>.cache/`
(`<sha256>-<engine-compat-hash>.cwasm`, written via `Module::serialize`,
loaded via `Module::deserialize_file`). The cache dir is a sibling of the
data dir so no guest can plant a `.cwasm` (deserializing is `unsafe`:
it trusts the file as native code). Disk hits are deserialized without
taking the compile lock (so they never wait behind a multi-minute
compile); misses compile one at a time. After each compile the host calls
`malloc_trim(0)`: Cranelift's parallel compile otherwise leaves ~1.9 GB
of freed glibc arena memory resident after compiling clang.

| Module | wasm | compile (this VM, noisy) | .cwasm | load from disk |
|---|---|---|---|---|
| clang/lld (llvm.wasm) | 75 MB | 227–254 s, ~1.9 GB peak | 219 MB | 0.6–1.2 s |
| wasm-tools.wasm | 16 MB | 42 s | 43 MB | 0.2–0.6 s |
| control.wasm | 12 MB | 22–27 s | 26 MB | 0.1–0.4 s |

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

Process spawn adds (`src/p1_proc.rs`, `SockKind::Unix`): Unix stream
sockets as p1 descriptors (pipe ends, exit fds), exporting a guest fd as a
host object for a child's stdio, and inserting a host file (`/dev/null`).

`poll_oneoff` with a single relative clock subscription used to do a blocking
`std::thread::sleep` when `allow_blocking_current_thread` is set, which made a
sleeping workload unkillable (kill/timeout work by dropping the future). The
patch limits that fast path to sleeps <= 10 ms.

Diff: `git diff <vendor commit> -- host/vendor/` (first commit is the
pristine crate).
