# E5: process spawn for wasm workloads — unmodified `cmd/go` in wasm

Date: 2026-10-15. Branch `e5-spawn`. Heavy runs were on `wasm-x1` (2 vCPU / 4 GB,
**50–80% CPU steal** for the whole session; absolute times are inflated, so
compare rows of the same table). Go go1.27.2, wasmtime 49.0.3.

**Result: success.** `go version`, `go env`, `go build`, `go vet` and
`go test` (passing, and a failing variant with exit 1) run end to end, and
every process is wasm. `cmd/go` is wasm. It spawns `compile`, `asm`, `link`,
`vet` and the test binaries as wasm children through a new host capability.
Children run in parallel on host threads. The wasm-built binary is
**byte-identical** to the native-built one (`-trimpath`, sha256 `b91e90cc…`).
The toolchain build is reproducible: 9/9 `.wasm` files hash identically on
`wasm-x1` and `altwasm`.

## 1. Design

### Host: `wasmdev_proc` imports (host/src/proc.rs, ~410 lines)

The model is Unix-like on purpose, so the guest needs only a thin `syscall`
shim. Full contract: docs/HOST_CAPABILITIES.md § Process spawn.

| import | what |
|---|---|
| `spawn(path, argv, env, dir, fd0, fd1, fd2) -> (pid, exit_fd)` | Never blocks. The path is resolved through the **caller's preopens** (longest guest prefix, then canonicalized; it must stay in that mount). The file must be wasm. The child gets the same preopens and perms, the given argv/env, and `PWD=dir`. Its stdio is caller fds (file, pipe, socket, or the caller's own stdio) or -1 for /dev/null. |
| exit fd | Stream socket that reaches EOF when the child exits. **This is the key to the single-thread problem.** Go waits on it in the netpoller (`poll_oneoff`), not in a blocking host call, so cmd/go keeps scheduling other goroutines: output copiers and other `-p` workers. No polling or backoff loop. |
| `wait(pid, nohang)` | Reaps the child. The status is Unix-encoded (exit<<8, or signal 9/6). |
| `kill(pid, sig)` | Any signal kills the child. |
| `pipe()` | Unix socketpair (each end shut down in one direction). Both ends are pollable p1 descriptors, so `os.Pipe` + `bytes.Buffer` stdout work unchanged. |
| `open_null(write)` | Real `/dev/null` fd (os/exec opens `os.DevNull` for nil stdio). |

Other properties:
- Children run on their own OS threads, so `-p N` gives real parallelism.
- They use the shared module cache (memory → disk `.cwasm` → Cranelift).
- A child is killed when its parent's store drops, so there are no orphans.
- Limits: 64 live children per process, depth 8.
- Guest pids start at 1000, because wasip1 `Getpid()` is 3 and
  `Kill(Getpid())` means exit-self.

Changes outside proc.rs, kept small so E4's edits merge cleanly:
- `exec.rs` (+~90 lines): a `Prepared` gets optional stdio objects, an exit
  notifier, depth and trace. Workloads get a `ProcCtx`. There is a new
  `start_prepared`. Path-based stdio became `Stdio` objects, so children can
  be given the parent's fd 1.
- `main.rs`: +4 lines.
- `cli_exec.rs`: `wasmdev-host exec [--dir H::G[:ro]] [--env] [--cwd] -- m.wasm args`.
  It inherits stdio and has a `WASMDEV_TRACE_PROC=1` per-process log. Use it
  for iteration without the control plane (`experiments/e5-spawn/run-go.sh`).
- Vendored wasmtime-wasi (+~120 lines): `SockKind::Unix`, `p1_proc.rs`
  (export a guest fd as a host object; insert a socket or file).
- The `poll_oneoff` fix in section 3.

Choice on stdio: **host pipes, not temp files.** Making Go's `os.Pipe` real
(socketpair + netpoller) needed no change to os/exec semantics. It also works
for big outputs (1 MiB tested) and streams output while the child runs. The
temp-file alternative would have needed os/exec patches and loses streaming.

### Guest: Go patches (patches/go/, ~360 lines incl. comments)

1. `0001-cmd-go-filelock-noop-wasip1.patch`: from E1. Needed for any go.mod read.
2. `0002-wasip1-process-spawn-wasmdev.patch`:
   - `syscall`: `StartProcess`, `Wait4` (+`WNOHANG`), `Kill(pid≠self)`, `Pipe`, a real `WaitStatus`, and `Open("/dev/null")` → `open_null`.
   - `os`: `Pipe` (kindPipe → netpoller). `blockUntilWaitable` reads the exit fd to EOF in the netpoller.
   - `os/exec`: `LookPath` stats the file. WASI has no x bits, so any regular file counts.
3. `0003-runtime-wasip1-notetsleepg-park-not-spin.patch`: see section 3.

**Only the toolchain binaries are built from patched std.** The guest GOROOT
that `go` compiles user code against is pristine go1.27.2. So user programs
and test binaries do not import `wasmdev_proc`, and they match upstream
builds bit for bit. `scripts/build-go-toolchain.sh` builds
`go, compile, asm, link, pack, vet, buildid, test2json, cover` with
`-trimpath` into `build/go-wasip1/goroot/{bin,pkg/tool/wasip1_wasm}`. It is
pinned to go1.27.2: it uses `/usr/local/go` if that is go1.27.2, else it
downloads the release. Native Go is used only for this bootstrap.

Runtime env (run-go.sh):

```
GOROOT=/goroot (ro)  GOCACHE=/state/gocache  GOTMPDIR=TMPDIR=/state/tmp  HOME=/state/home
GOTOOLCHAIN=local  GOPROXY=off  GOSUMDB=off  GOWORK=off  CGO_ENABLED=0  PWD=/work
```

`GOCACHE` persists under the state dir. Std archives are built once by the
wasm compiler and reused.

## 2. Measurements

Small module: 3 packages (`main`, `calc`, `strutil`); 2 test packages with an
Example. The compiled-module cache is warm (Cranelift compile of the tools is
one-time, see the table after the main one). Source:
`experiments/e5-spawn/bench.sh`, raw output in `results-bench.txt`.

| scenario | wasm (all processes wasm) | native go1.27.2 (same target) |
|---|---|---|
| `go build`, cold GOCACHE (all std deps), `-p 1` | 333 s | 35 s |
| `go build`, cold GOCACHE, `-p 2` | **230 s** (1.45x faster than -p 1) | 35 s |
| `go build`, warm, no change | **3.1 s** | — |
| `go build`, warm, edit calc.go | **6.2 s** | — |
| `go test ./...`, cold GOCACHE, `-p 1` | 577 s | (`test -c` 74 s) |
| `go test ./...`, cold GOCACHE, `-p 2` | **362 s** (1.6x faster than -p 1) | (`test -c` 71 s) |
| `go test`, warm, results cached | 3.5 s | — |
| `go test -count=1`, warm (relink + run, binaries in module cache) | 7.4 s | — |
| `go test`, warm, edit calc.go | 7.8 s | — |
| `go test -tags failing` (FAIL, exit 1) | 9.5 s | — |
| `go test`, warm, **new test binary** (test file edited) | 28 s, of which **19.6 s** is Cranelift JIT of the 5.3 MB test binary | — |
| `go vet ./...`, warm | 32 s (full analyzer suite in wasm) | — |

Peak RSS for the whole host process is 590 MB at `-p 2` cold (580 MB at
`-p 1`), and 100–380 MB warm. The native numbers do not improve from -p 1 to
-p 2 because native compile already uses threads, and steal was 65–80%.

One-time costs and micro numbers:
- Cranelift compile on first use (shared cache afterwards; 2 vCPU with steal):
  - compile.wasm 93–193 s
  - go 28 s
  - vet 49 s
  - link 44–48 s
  - asm 33–37 s
- Cold `go build` with an empty module cache took 504 s, of which 278 s was JIT.
- Loading a tool from the disk cache costs ~0.2 s, once per host process. After that it comes from memory.
- Spawn + wait round trip (3 MB Go child, from the memory cache): **1–2 ms**. Four parallel children: 3–62 ms. 1 MiB of child stdout through a pipe: 5 ms.
- Process counts: about 98 processes for a cold `go build` (62 compile), about 160 for a cold `go test`.
- `go version`: 0.3 s warm.

Winch as a first tier for never-seen modules (wasmtime CLI, same 5.3 MB test
binary, with epoch interruption):

| compiler | compile time |
|---|---|
| Cranelift | 18.2–18.9 s |
| Winch | 3.3–4.5 s |

Both run the test (`PASS`). Since a test binary is usually run exactly once,
Winch would cut the "new test binary" case from about 28 s to about 13 s.
This is the biggest remaining warm-path cost.

## 3. Problems found (and fixed)

1. **wasip1 runtime livelock (Go bug, patch 0003).** `runtime.notetsleepg` on
   wasip1 loops on `Gosched()`. `go test` calls `signal.Notify`
   (`base.StartSigHandlers`), and that parks a goroutine there forever, so a
   goroutine is always runnable. wasm has no sysmon thread, so the scheduler
   never blocks in netpoll. Every goroutine waiting on the exit fd or on a pipe
   starved, and cmd/go spun at 100% CPU after the first test binary exited. The
   fix parks on a timer with backoff (20 µs → 10 ms). Upstream-worthy: any
   wasip1 program that uses `signal.Notify` and waits on I/O hits this.
2. **Unkillable sleeping workloads (pre-existing host bug).**
   - wasmtime-wasi's `poll_oneoff` fast path does a blocking
     `std::thread::sleep` for a single relative clock subscription when
     `allow_blocking_current_thread` is on. That is our setting.
   - A guest in `time.Sleep(1h)` therefore ignored kill and timeout, which
     work by dropping the future.
   - The vendored patch now takes that path only for sleeps of 10 ms or less.
     This also affects control-plane jobs and services (E3 assumed this case
     was cancellable).
3. wasip1 has no cwd. Go emulates it from `$PWD`, so the child gets
   `PWD=dir`. wasi-libc ignores `$PWD`, so C tools must be given absolute
   paths (E4 hit the same thing).
4. `runtime.NumCPU()` is 1 on wasip1, so `go build` defaults to `-p 1`. Pass
   `-p N` explicitly, or set `GOFLAGS=-p=N`, where N = host cores.
5. The compile lock serializes Cranelift compiles. Two test binaries compiled
   back to back cost 35 s + 65 s on the noisy VM in the first run.
6. Every distinct test binary leaves a `.cwasm` (≈2.5x its size) in the disk
   cache. It needs a GC policy (LRU, or no disk caching for modules under
   tmp dirs).

## 4. clang driver through spawn: blocked by the YoWASP build

`llvm.wasm` (YoWASP clang 22.1, as fetched by E4) imports only
`wasi_snapshot_preview1`. LLVM's WASI `Program.inc` fails every subprocess
(`clang: error: unable to execute command: WASI does not support spawning
subprocesses`). That applies even to `-cc1`: the build runs cc1 out of
process (`"" "clang" -cc1`), and `-fintegrated-cc1` does not change that.
So `clang -o hello hello.c` cannot use spawn without rebuilding LLVM. The
rebuild would mean:
- patching `llvm/lib/Support/Wasi/Program.inc` so
  `ExecuteNoWait`/`Wait` call `wasmdev_proc.spawn`/`wait` (~100 lines of C++);
- giving the driver its own path (argv0 is empty there; the driver re-execs
  itself for cc1, and `wasm-ld` is the same multicall module).

That is a multi-hour LLVM-to-wasm build, so I did not attempt it here. The
host side would need no change.

## 5. Comparison with E4's "control plane drives `clang -###`"

| | E5 spawn (driver in wasm) | E4 job list (driver logic in control plane) |
|---|---|---|
| Tool changes | Small std patch, once per language runtime (Go: ~360 lines); LLVM: a Program.inc patch + rebuild | None to the tool; it needs `-###` support |
| Fidelity | Exact upstream semantics: caching (GOCACHE, test result cache), `-p`, vet, `_testmain.go`, buildid, `-tags`, failing exit codes all come from cmd/go itself | Must re-implement the driver's runtime behaviour (E4: `wasm-component-ld` emulation, EH flags, job splitting). Infeasible for cmd/go: its action graph, cache and testmain are in-process |
| Host surface | +5 imports, pipes, exit fds (generic: any driver, any language) | None beyond exec |
| Parallelism | The driver decides (`-p`); children on host threads | The control plane must schedule |
| Per-process cost | ~1–2 ms spawn; module from the memory cache | Similar per step, plus a control-plane round trip per job |
| Observability | Host trace per process; the API sees one job | Per-step timings in the API response |
| Risks | Patched runtime/std to maintain (small, self-contained; 0003 is an upstream bug fix); child processes need resource accounting | Brittle for complex drivers; logic outside the tool |

For clang (one compile + one link) the job-list approach is adequate and
works today. For Go, spawn is the only route that does not re-implement
cmd/go.

## Recommendation

- Adopt `wasmdev_proc` as a general host capability, and run Go builds and
  tests through unmodified wasm `cmd/go`.
- Ship the reproducible toolchain plus precompiled `.cwasm` files, and keep
  GOCACHE in the data dir.
- Default to `-p = cores`.
- Next steps:
  1. Add a Winch first tier for unregistered modules: test binaries go from
     about 19 s to about 4 s.
  2. Add a cache GC for test-binary `.cwasm` files.
  3. Upstream the wasip1 `notetsleepg` fix.
  4. Expose spawn through the control-plane API as `"cmd": "go test ./..."`
     on a Go tool.
  5. Revisit clang through spawn only if a spawn-capable LLVM wasm build
     appears. Until then keep E4's `-###` driver.

Files:
- `host/src/{proc,cli_exec}.rs`
- `host/vendor/wasmtime-wasi/src/p1_proc.rs`
- `patches/go/*`
- `scripts/build-go-toolchain.sh`
- `experiments/e5-spawn/{run-go.sh,bench.sh,results-bench.txt,testmod,spawntest}`
