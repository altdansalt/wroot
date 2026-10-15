# e3 — native host + wasm control plane skeleton

Date: 2026-10-15. VM: altwasm, 2 vCPU / 3.8 GB (about 10% CPU steal even when idle).
Toolchain: Rust 1.99, wasmtime / wasmtime-wasi 49.0.3, Go 1.27.2.

## What was built

```
host/       wasmdev-host (Rust, ~770 lines) + vendored, patched wasmtime-wasi 49.0.3
control/    control plane: Go, GOOS=wasip1, net/http (~1100 lines)
examples/   hello (wasip1 command), httphello (wasip1 net/http service)
scripts/    demo-e3.sh (end-to-end + measurements), bench-cache.sh, svc-ready.py
docs/HOST_CAPABILITIES.md   every capability the host grants, and why
```

Run it: `scripts/demo-e3.sh` (builds what is missing; `KEEP=1` leaves the
server up). By hand:

```
cd host && cargo build --release -j2
(cd control && GOOS=wasip1 GOARCH=wasm go build -o ../build/control.wasm .)
host/target/release/wasmdev-host --control build/control.wasm \
    --listen 127.0.0.1:8780 --data ./data --token secret
curl localhost:8780/            # API description for agents
```

### Split between host and wasm

The host only provides capabilities: a listening socket, `/data`, stdio,
env/args, and four imports (`wasmdev.exec_start/status/kill/release`,
pointer+length JSON). Everything else is Go in wasm: routing, auth (an
admin bearer token plus per-agent tokens minted with `POST /v1/tokens`),
workspaces (directories under `/data/ws`, accessed through `os.Root` so
symlinks created by workloads can't escape), the tool registry
(`/data/tools/<name>/tool.json`), building exec specs (mounts,
argv0, stdio files under `/data/runs/<job>`), sync/async jobs, and services.

Workloads: each one runs on its own OS thread with a current-thread tokio
runtime, using `wasmtime_wasi::p1` (async), `StoreLimits` (memory, default
1 GiB), and epoch interruption (5 ms tick). On every tick the epoch callback
yields to the executor, or traps if a kill was requested. The run future is
`select!`ed against kill and timeout, and dropping it cancels the guest
even when it is blocked in a host call (`poll_oneoff`, `sock_accept`).
`exec_start` validates the spec and binds the service port inline, so the
port is known as soon as it returns. Module compilation and execution happen
on the workload thread, so a 2-minute compile never blocks the control
plane.

## Problem 1 (big): wasmtime 49 has no wasip1 sockets

- `wasmtime_wasi::p1` (the p2-backed adapter) returns `ENOTSOCK` for every
  `sock_*` call ("p1 sock_accept is not implemented").
- The legacy `wasi-common` crate, which implemented `--tcplisten`, is no
  longer published (the last release is 46.0.3) and is gone from the 49 tree.
  `wasmtime run -S tcplisten=…` still parses but cannot work for core modules.
- So the Go-wasip1-HTTP-server approach (`net.FileListener(os.NewFile(3))`)
  cannot run on stock current wasmtime.
- Delegating from a shadowing `Linker` definition to the original p1
  function doesn't work: a host→host `Func::call` gets the store's default
  caller, which has no `memory` export.

Fix: vendor wasmtime-wasi 49.0.3 and patch p1 (+357/−25 lines, see
`git diff be9c3fa -- host/vendor`). It adds `Descriptor::Socket` backed by
a tokio `AsyncFd`, `WasiP1Ctx::preopen_tcp_listener`, `sock_accept/recv/
send/shutdown`, socket `fd_read/fd_write/fd_close/fd_fdstat_get/
fd_fdstat_set_flags/fd_filestat_get`, and FD_READ/FD_WRITE readiness in
`poll_oneoff`. The OS socket is always non-blocking, and the guest's
NONBLOCK flag is emulated. Preopened listeners start NONBLOCK, because Go
never sets the flag on an `os.NewFile` fd and a blocking `sock_accept`
would freeze the whole single-threaded Go runtime. This is a maintenance
burden. Upstreaming it, or moving to p2 sockets, is the real fix.

### Problem 2: preopen ordering vs fd 3

wasi-libc and Go scan `fd_prestat_get` from fd 3 upward and stop at the first
`EBADF`. Wasi-libc treats any other error as fatal. If the listener is fd 3,
every preopened directory after it is invisible. So listeners are numbered
after the dirs (fd = 3 + number of dirs), and the host advertises the number
in `$WASMDEV_LISTEN_FD`. The control plane's listener is fd 4 (`/data`
is fd 3). This differs from the "fd 3" in the original plan.

### Problem 3: Nagle

Go can't `setsockopt(TCP_NODELAY)` on wasip1, so accepted sockets had Nagle on.
The host now sets `TCP_NODELAY` on accepted sockets. Native Go does this by
default.

### Smaller issues
- `wasmtime::Error` is no longer `anyhow::Error` in 49. Calls that use
  `anyhow::Context` need `.map_err(anyhow::Error::from)`.
- `Config::async_support` is deprecated and does nothing (async is always on).
- On this VM, process-spawn noise (curl + jq) adds 10–90 ms. The first
  service measurements (around 90 ms) were all client noise.
  `scripts/svc-ready.py` measures from one warm client instead.
  `time.sleep(1ms)` overshoots by more than 20 ms about 7 times a second
  here (CPU steal), which explains the rare 50–80 ms outliers in every series.

## Measurements

All numbers are warm unless noted. Medians from `scripts/demo-e3.sh` and
`scripts/bench-cache.sh`.

| What | Result |
|---|---|
| Trivial run (`hello.wasm`, Go, 2.6 MB) via HTTP, 20 runs | p50 **2.6–3.1 ms** HTTP total; wall in host p50 **1.1 ms**, so control-plane + HTTP overhead p50 **≈1.5–1.7 ms** |
| Same module via `wasmtime run` CLI (fresh process, no cache) | ~100 ms per run |
| Service start-to-ready (`httphello`, 9.5 MB, Go net/http) | POST p50 **1.5 ms**, POST → first successful GET p50 **2.5 ms** |
| Service, first ever start (includes Cranelift compile) | 12.8–22 s |
| Control plane `control.wasm` (12 MB) cold compile | 15.5 s idle VM (same as `wasmtime compile`: 14.0 s); 21–34 s while other work runs |
| Control plane from disk cache (`deserialize_file`) | **80–110 ms** → host ready in ≈100 ms |
| `hello.wasm` compile → disk → memory | 4.4–8.8 s → 3–8 ms → 0.01 ms |
| **Go `cmd/compile` as wasip1 (53 MB wasm)** cold compile | **117 s, 1.26 GB peak RSS** |
| ... from disk cache (new host process) | **212 ms** load, `-V=full` run total 216 ms |
| ... in-memory hit | 0.008 ms load; run 4–68 ms |
| Disk cache size | 132 MB for 53 MB wasm, plus small entries (≈2.4× the wasm size) |
| Control plane stays responsive during CPU-bound workload | trivial run completed in 4.7 ms while a `for {}` job was spinning; the spinning job was killed in under 5 ms after DELETE |
| Timeout of spinning guest (`timeout_ms: 300`) | ends at 303 ms (state `timeout`) |

Takeaways:
- The cache is essential. A toolchain-sized module cannot be compiled per
  request (2 minutes, over 1 GB RSS on this VM). From disk it loads in about
  0.2 s and from memory it's free. Cold compiles should be done ahead of
  time, e.g. when a tool is registered (`PUT /v1/tools`) instead of on the
  first run. The compile lock also serializes compiles, so two 1.2 GB
  compiles can't run at once.
- Winch compiled `control.wasm` in 3.4 s vs 14 s for Cranelift. A
  "Winch first, Cranelift in the background" tiering would make first
  runs of new user modules much faster.
- Per-run overhead (≈1.5 ms) is mostly Go `net/http` in wasm, JSON, and
  creating and reading the stdout/stderr files. The host part
  (thread + store + instantiate) is in the 1 ms "wall".

## Open questions

1. **Polling vs notification for job completion.** The control plane polls
   `exec_status` with exponential backoff (50 µs → 5 ms). This is simple and
   costs at most a few ms of added latency for long jobs, and about 0 for
   short ones. A blocking `exec_wait` is not an option: it would stall the
   single-threaded Go runtime. The clean design, now possible with the
   socket patch, is a host→guest *event stream*: a preopened connected
   stream socket (or `socketpair`) where the host writes `handle\n` on
   completion. A Go goroutine reads it via `net.FileConn` and wakes
   waiters through channels, so the wait happens in the netpoller with no
   polling. The same channel could carry service log lines or port-ready
   events. Recommendation: implement it when job counts grow. Polling is fine
   for the skeleton.
2. **Exposing services over the network.** Today the host binds
   `0.0.0.0:8100-8199` directly and the URL uses `--public-host`. Options:
   (a) keep direct ports and rely on the exe.dev proxy only for the API
   port (simple, but every service port needs separate exposure);
   (b) have the control plane reverse-proxy `/{svc}/...` or
   `<svc>.host` to the loopback port (one public port, auth in one
   place, but it adds a hop through Go-in-wasm); (c) have the host
   proxy by Host header natively (fast, but pushes logic into the host).
   I lean to (b) with services bound to 127.0.0.1, measuring the extra hop.
3. **wasip1 vs wasip2 for workloads.** The p1 path works today for Go
   and Rust and is what the toolchain experiments (e1/e2) produce. But p1
   sockets only exist through our patch, and p1 has no outbound network.
   wasip2 components get `wasi:sockets` and `wasi:http` upstream. The seam
   is marked in `exec.rs` (`TODO(wasip2)`): detect a component and run
   `wasi:cli/command` through the component linker with the same
   ExecSpec/Status contract. Services would get a `wasi:sockets` listener
   or be `wasi:http/proxy` components, which would remove the need for the
   fd-passing hack. The open issue is that Go (the control plane and most
   toolchains) has no wasip2 port yet, so p1 stays for the control plane
   either way.
4. **Upstreaming the p1 socket patch** vs keeping it. Alternatively, move
   the control plane off fd-passing by adapting it with the
   wasi-preview1-component-adapter, which also lacks sockets.
5. **Resource hygiene.** `/data/runs/*` and finished job records are never
   garbage-collected. Workspaces have no quota. There are no per-agent
   ownership checks: any valid token can touch any workspace.
6. **Security of the disk cache.** `.cwasm` files are trusted native code
   (`deserialize_file` is `unsafe`). The cache sits next to the data dir,
   never inside it, but it should become a host-only path
   (`$XDG_CACHE_HOME`) with a checksum/HMAC.
7. **Stdout capture** goes to files and is read after exit. Streaming
   (SSE or chunked) for long compiles needs either polling files or the
   event channel from (1).
