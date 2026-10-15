# E1: Go toolchain as wasip1 under wasmtime

Date: 2026-10-15. Host: `wasm-x1` (2 vCPU, 4 GB), go1.27.2, wasmtime 49.0.3 (plus 36.0.2 for sockets).
Scripts: `~/wasmdev/experiments/e1-go-wasm/` (local). Artifacts: `~/e1/` on wasm-x1.

**Question:** can the Go toolchain run as a wasip1 module under wasmtime and build Go programs targeting wasip1?

**Answer: yes, with no patches to compile/asm/link/pack.** The wasm toolchain builds hello world and a
net/http server, and the output is **byte-identical** to what the native toolchain produces (same sha256).
It runs about 3.5-5x slower than native on one thread, and ~5-10x slower on whole builds because wasip1
has no threads (no `-c` backend parallelism) and every tool invocation pays a startup cost. cmd/go also builds
as wasip1, but `go build` stops at the first subprocess spawn. Getting it working needs a host spawn
import plus pipes. That is roughly 300-450 lines in std and a custom wasmtime embedder, not the wasmtime CLI.

> **Measurement caveat:** wasm-x1 had heavy hypervisor CPU steal throughout: 30-80%, measured from
> `/proc/stat` per run. Absolute times are inflated and noisy, sometimes by up to 2x between identical runs.
> Treat **ratios from interleaved runs** and **min-of-N** as the signal. Re-run `bench-interleave.sh` on a
> quiet box before quoting absolute numbers externally.

## 1. Building the toolchain for wasip1

```sh
cp -a /usr/local/go ~/e1/goroot
cd ~/e1/goroot/src
for t in compile link asm pack go; do GOOS=wasip1 GOARCH=wasm ../bin/go build -o ~/e1/bin/$t.wasm ./cmd/$t; done
```

| tool | builds? | .wasm size | .cwasm size (cranelift o2) | `wasmtime compile` time | runs `-V`? |
|---|---|---|---|---|---|
| compile | yes, unpatched | 53.5 MB | 110.7 MB | 113 s (winch 18 s, o0 88 s) | yes |
| link | yes, unpatched | 12.5 MB | 27.2 MB | 26 s | yes |
| asm | yes, unpatched | 9.0 MB | 19.8 MB | 17 s | yes |
| pack | yes, unpatched | 3.4 MB | 7.6 MB | 5 s | yes |
| go | yes, unpatched; needs the filelock patch to *work* | 31.6 MB | 65.2 MB | 59 s | `version`, `env` OK |

The patches I expected to need were not needed:
- **cmd/link output (mmap):** `cmd/link/internal/ld/outbuf_nommap.go` already covers wasm, so it writes to a heap buffer.
- **cmd/go/internal/mmap:** `mmap_other.go` already covers wasip1 and reads the file into memory.
- **os/exec in compile/link:** not reached. The linker only execs for external linking, and wasm always links internally.
- **Target selection:** `internal/buildcfg` defaults GOOS/GOARCH to the *toolchain's* platform. A wasip1-built compiler therefore targets wasip1/wasm by default. We pass `GOOS=wasip1 GOARCH=wasm` anyway.
- **cwd:** wasip1 Go emulates the working directory from `$PWD`. Passing `--env PWD=$PWD` makes the relative `./foo.s` paths in the build plan work.

The only patch needed (for cmd/go only), in `experiments/e1-go-wasm/filelock-wasip1.patch`:

```diff
--- a/src/cmd/go/internal/lockedfile/internal/filelock/filelock_other.go
+++ b/src/cmd/go/internal/lockedfile/internal/filelock/filelock_other.go
-//go:build !unix && !windows
+//go:build !unix && !windows && !wasip1
--- /dev/null
+++ b/src/cmd/go/internal/lockedfile/internal/filelock/filelock_wasip1.go
+//go:build wasip1
+
+package filelock
+
+// WASI preview1 has no advisory locks. Treat locks as no-ops; the host
+// sandbox is expected to serialize access to shared caches.
+
+type lockType int8
+
+const (
+	readLock = iota + 1
+	writeLock
+)
+
+func lock(f File, lt lockType) error { return nil }
+
+func unlock(f File) error { return nil }
```
Without it, any go.mod read fails with `go: RLock .../go.mod: unsupported operation`.

## 2. Driving compile/asm/link/pack directly

`runplan.py` takes the native `GOOS=wasip1 GOARCH=wasm go build -a -n` plan and splits it into per-action
blocks. It infers the dependency DAG from `$WORK/bNNN` references and runs the blocks with N workers. Each
tool call becomes:

```sh
wasmtime run --allow-precompiled --dir ~/e1::~/e1 --env PWD="$PWD" \
  --env GOROOT=~/e1/goroot --env GOOS=wasip1 --env GOARCH=wasm ~/e1/bin/compile.cwasm <args...>
```

Other changes to the plan:
- `go tool pack r` becomes `pack.cwasm r`.
- `go tool buildid -w` lines are dropped. They only rewrite the build ID for the cache, and the output was still identical.
- `$WORK` is replaced literally, because the importcfg heredocs are quoted.
- Mounting the host dir at the *same guest path* means every absolute path in the plan works unchanged.

Results:
- **hello world** (58 actions: runtime, internal/\*, reflect, os, fmt, ... including all `.s` files via asm.wasm) builds, and `wasmtime hello.wasm` prints `hello from wasm-built wasm`.
  - `sha256(hello wasm-built) == sha256(hello native-built)` = `6ab60417...1867`
- **net/http server** (183 actions, including crypto/tls and vendor/golang.org/x/...) builds and is byte-identical to the native build (`cmp` OK, 9.47 MB).
  - Served with `wasmtime run -S preview2=n -S tcplisten=127.0.0.1:8099 httpd.wasm`. `curl /hi/there` returns `hello from a Go http server compiled by wasm toolchain; path=/hi/there`, and 200 sequential curls took 3.6 s.
  - **Gotcha:** wasmtime 49 removed the legacy p1 implementation (`-Spreview2=n flag is no longer supported`). The p2-backed p1 rejects `tcplisten` (`components do not support --tcplisten`). I used wasmtime **36.0.2** for this, at `~/e1/wt-old/`. Our own embedder would have to provide the preopened listener fd itself.

Commands: `experiments/e1-go-wasm/build-tools.sh`, `build-hello.sh`, `runplan.py`.

## 3. Measurements

All runs are on 2 vCPU with heavy steal (see caveat). "j" is the number of concurrent tool processes.
Native `compile` used its default `-c=2` backend concurrency. The wasm compile is always single-threaded
(wasip1 has GOMAXPROCS=1).

### Whole builds

| scenario | native | wasm (cranelift o2 .cwasm) | ratio |
|---|---|---|---|
| hello: cold std deps + main + link, 58 actions, j=2 | 20.5 s, peak RSS 0.20 GB | 102.7 s, peak RSS 0.55 GB | 5.0x |
| hello: warm (std archives cached; compile main + link only) | 0.39-0.59 s | 1.09-1.70 s | ~3x |
| test binary (1 test): cold, 127 actions, vet removed, j=2 | 41.8 s | ~200 s | ~4.8x |
| net/http server: cold, 183 actions, j=2 | 27.0 s, RSS 0.18 GB | 258.9 s, RSS 0.55 GB | 9.6x |
| `runtime` package alone (largest; ~45% of hello cold) | 6.3-11.9 s | 46-48 s in-plan | |

### Single package, interleaved (min of 3; `bench-interleave.sh`, `bench-compile.sh`)

| package | native -c=1 GOMAXPROCS=1 | native -c=2 | wasm o2 | wasm o2 GOGC=off | wasm/native-1T |
|---|---|---|---|---|---|
| fmt | 0.60 s | 0.39 s | 2.52 s | 1.99 s | 4.2x |
| reflect | 3.80 s | 2.90 s | 15.99 s | 14.10 s | 4.2x |
| runtime | 4.79 s (best seen) / 9.88 s (interleaved) | 2.51 s / 6.08 s | 26.4 s / 31.4 s | 34.4 s | 3.2-5.5x |

Note: `-c=1` also disables cmd/compile's starting-heap boost (`gc/main.go:88`), so the native
single-thread column is slightly pessimistic. The wasm runs keep `-c=2` from the plan, so the boost is on
but there is still only one thread.

Peak RSS when compiling runtime: native 0.17-0.21 GB, wasm 0.55 GB (0.59 GB with GOGC=off). The wasm
linear memory never shrinks, and wasm has none of the native compiler's heap tuning headroom.

### wasmtime knobs (compiling fmt, min of 3, single-threaded)

| config | exec time | vs default | module compile time for compile.wasm (53 MB) |
|---|---|---|---|
| cranelift opt-level=2 (default) | 2.52 s | 1.00 | 113-127 s (1.1 GB RSS while compiling) |
| cranelift opt-level=0 | 3.02 s | 1.20x slower | 88-119 s (barely faster to compile) |
| winch (baseline compiler; must also pass `-C compiler=winch` at run) | 3.28 s | 1.30x slower | **18-20 s** |
| `-O signals-based-traps=n` (explicit bounds checks) | 3.10 s | 1.23x slower | ~112 s |
| guest `GOGC=off` | 1.99 s | 0.79 (faster), +5-25% RSS | n/a |
| guest `GOGC=200` | 3.28 s | slower, because setting GOGC disables cmd/compile's own `AdjustStartingHeap` tuning | n/a |

Startup costs for compile.wasm:

| how it starts | wall time |
|---|---|
| JIT, cache off | 127 s |
| JIT, wasmtime's default on-disk cache hit (`~/.cache/wasmtime`) | 1.0 s, 0.28 GB RSS (decompress + load) |
| precompiled `.cwasm` (mmap) | **0.08 s**, 41 MB RSS |

Precompiled `.cwasm` is mandatory for a per-invocation tool model.

Takeaways:
- Keep cranelift o2 and precompile once per toolchain version.
- Winch could serve as a fast first tier while cranelift compiles in the background, since it is only 1.3x slower.
- `opt-level=0` buys nothing.
- Consider setting `GOGC=off`, or a memory-limit-based setting, for short-lived compile processes when memory allows.

### Where the gap comes from

1. **No threads in wasip1.** The native compiler's `-c` backend concurrency is lost. That is about 1.5-2x on large packages (runtime: -c=2 2.5 s vs -c=1 4.8 s).
2. **Raw codegen.** Go's wasm backend plus cranelift is about 3.5-4x slower than native amd64 per thread. Go's wasm target is known to be slow: no registers for the Go stack, and goroutine switching implemented with an explicit stack/PC dispatch.
3. **Per-tool startup and mmap of a 110 MB .cwasm.** Small, but there are 183 invocations for net/http, plus asm calls.

**Mitigation for (1): process-level parallelism.** Run more concurrent wasm instances (`-j` = cores). This is
what cmd/go already does via `-p`. On a 2-vCPU VM it can't recover much.

## 4. cmd/go as wasip1 with host-provided spawn

### What works today, with only the filelock patch

Tested with
`wasmtime run --allow-precompiled --dir ~/e1::~/e1 --env PWD=... --env HOME=... --env GOROOT=... --env GOCACHE=... --env GOTOOLCHAIN=local --env GOTMPDIR=... go-patched.cwasm <cmd>`:

| command | result |
|---|---|
| `go version`, `go env` | OK (reports GOHOSTOS=wasip1) |
| `go list -deps .` | OK. Module loading and package resolution work. |
| `go build` / `go build -n` / `go list -json std` | Fail at `cmd/go/internal/work/buildid.go:160`: `exec.Command(tool, "-V=full")` (toolID). First error: `open /dev/null: Bad file number`. |
| `go vet` / `go test` | Fail: `no such tool "vet"`. cmd/vet is not built for wasm yet; it would likely build the same way. |

Setup notes:
- Tools must be at `$GOROOT/pkg/tool/wasip1_wasm/{compile,asm,link,pack}`, because cmd/go uses GOHOSTOS/GOHOSTARCH = wasip1/wasm. Copies are already in place on wasm-x1.
- `GOTMPDIR` must be inside a preopen. Otherwise you get `mkdir /tmp/go-build...: Bad file number`.

### Every process / exec dependency, in order of encounter for `go build`

1. `os/exec` opens `os.DevNull` for nil Stdin/Stdout (`os/exec/exec.go:544,593`). Fix this by preopening `/dev` or mapping /dev/null in the host.
2. `os/exec.LookPath` on wasm always returns ErrNotFound (`os/exec/lp_wasm.go`). `cmd/go/internal/work/shell.go:624` calls `pathcache.LookPath(cmdline[0])` before every tool run.
3. `os.Pipe` returns ENOSYS on wasm (`os/pipe_wasm.go:13`, `syscall/fs_wasip1.go:942`). `exec.Cmd` needs a pipe whenever Stdout/Stderr is an `io.Writer` (`shell.go:631-632` sets them to a `bytes.Buffer`, and buildid.go:161 does the same with a `strings.Builder`).
4. `syscall.StartProcess` / `syscall.Wait4` return ENOSYS (`syscall/syscall_wasip1.go:409-415`). `syscall.Kill` only handles self (`:393`). `WaitStatus` is a stub (`:298-308`).
5. Call sites in cmd/go:

   | location | used for | needed when |
   |---|---|---|
   | `work/buildid.go:160` | `<tool> -V=full` toolID | every build, `-n` included |
   | `work/shell.go:626/650` | every compile/asm/link run | always |
   | `work/buildid.go:222,310` | gccToolID | cgo only (n/a for wasip1 targets) |
   | `work/init.go:390` | `cc --version` | cgo only |
   | `work/exec.go:2641` | | cgo only |
   | `test/test.go:1672` | runs the test binary | `go test` |
   | `toolchain/exec.go:45` | GOTOOLCHAIN switching | avoided with `GOTOOLCHAIN=local` |
   | `modfetch/codehost/*`, `vcs/vcs.go` | git etc. for direct VCS fetches | module fetches; GOPROXY path is HTTP |
   | `base/base.go:215` | `go run` / `go tool` | those commands |

   Module downloads via GOPROXY also need **outbound sockets**, which wasip1 doesn't have (no connect). So
   module download needs a pre-populated GOMODCACHE, vendoring, or another host import. That is a separate blocker.
6. `os.Executable` errors on wasm (`os/executable_wasm.go`). It is harmless once GOROOT is set explicitly.

### The deadlock trap

wasip1 Go is single-threaded. If `proc_wait` were a plain blocking host call, the whole wasm instance would
freeze. cmd/go's `-p` parallelism would disappear, and worse, the goroutine that copies a child's stdout pipe
into the `bytes.Buffer` could not run. A child that fills the pipe would then deadlock against the parent
blocked in wait. So both the pipes and process exit must be **non-blocking fds integrated with the
wasip1 netpoller** (`runtime/netpoll_wasip1.go`, poll_oneoff level-triggered), e.g. a pidfd-like "exit fd"
that becomes readable when the child exits.

### Patch sketch (not implemented)

```go
// syscall/proc_wasmdev_wasip1.go   (new, ~120 lines)
//go:wasmimport wasmdev proc_spawn
func proc_spawn(argv, argvLen, env, envLen, dir, dirLen unsafe.Pointer, fds *[3]int32, exitfd *int32, pid *int32) Errno
//go:wasmimport wasmdev proc_wait        // non-blocking: returns EAGAIN until exited
func proc_wait(pid int32, status *uint32) Errno
//go:wasmimport wasmdev proc_kill
func proc_kill(pid int32, sig int32) Errno
//go:wasmimport wasmdev fd_pipe          // returns two new WASI fds (nonblocking)
func fd_pipe(rfd, wfd *int32) Errno

func StartProcess(argv0 string, argv []string, attr *ProcAttr) (pid int, handle uintptr, err error) // marshal argv/env (NUL-separated), attr.Dir, attr.Files[0..2]; return pid, handle=exitfd
func Wait4(pid int, ws *WaitStatus, options int, ru *Rusage) (int, error)                          // proc_wait; WNOHANG semantics
func Pipe(fd []int) error                                                                          // fd_pipe + set nonblock
// syscall_wasip1.go: delete the 3 ENOSYS stubs (:409-415, fs_wasip1.go:942); make WaitStatus real (~15 lines: Exited/ExitStatus)
// syscall_wasip1.go Kill (:393): route pid != self to proc_kill (~5 lines)

// os/pipe_wasm.go -> split: js keeps ENOSYS; wasip1 calls syscall.Pipe + newFile(kindPipe/nonblock) (~20 lines)
// os/exec_unix.go wait(): on wasip1, block by reading exitfd through internal/poll (pidfd-style, so the
//   netpoller parks the goroutine instead of the whole instance) then Wait4(WNOHANG) (~40 lines; or reuse
//   pidfd_linux.go structure via a new pidfd_wasip1.go, ~80 lines)
// os/exec/lp_wasm.go -> lp_wasip1.go: stat-based PATH search like lp_unix.go, or ask the host (~30 lines)
// os/executable_wasm.go: optional, read from env/host (~10 lines)
```

**Estimate:** about 300-450 lines of Go in std (syscall/os/os/exec), and zero changes to cmd/go beyond
the filelock patch.

The host side is a custom wasmtime embedder (Rust, wasmtime-wasi p1 context) that does the following:
- implements `wasmdev.proc_spawn` by instantiating another `.cwasm` (for `$GOROOT/pkg/tool/wasip1_wasm/*` and test binaries) or a native process (policy), on a host thread;
- wires its stdio to host pipes inserted into the caller's WASI fd table;
- exposes exit as a pollable fd.

That is roughly 500-800 lines of Rust. This is the real work, and it also gives us the right place to
solve sockets (tcplisten removed from the CLI) and the module proxy.

A cheaper alternative is to skip cmd/go entirely and run the planner natively or in a host service. The
planner is the `go build -n` / `go list -json` / action-graph logic; that service then dispatches
compile/link wasm instances, as `runplan.py` does. This experiment shows that path already works end to end.

## 5. Tests (`go test`)

`go test -n` on a 1-test package produces this plan:
1. The normal compile of the package under test (with `_test.go` files).
2. A `main` package compiled from **`$WORK/b001/_testmain.go`**, linked as `pkg.test` with `-s -w`.
3. **71 `vet` invocations**: dependency vet runs (`-unsafeptr=false -unreachable=false`) to produce vetx facts, plus the real vet of the package.
4. Running `$WORK/b001/pkg.test -test.testlogfile=... -test.paniconexit0 -test.timeout=10m0s`. For wasip1 that goes via the `go_wasip1_wasm_exec` wrapper, i.e. wasmtime.

Key point: **`_testmain.go` is not in the `-n` output.** cmd/go generates it in-process. It does this by
parsing the test files for Test/Benchmark/Fuzz/Example functions (`cmd/go/internal/load/test.go`, the
`formatTestmain` / `testmainTmpl` template) and writing it with Go source. So driving tests without cmd/go
means:
- either reimplement test discovery plus the template (~300 lines, mostly copying `load/test.go`);
- or get `_testmain.go` from a native `go test -work -c` (what I did here);
- or get cmd/go working (section 4).

Vet can be skipped (`-vet=off`) or vet.wasm built the same way.

### Measured: driving a test build without cmd/go works

Steps:
1. `GOOS=wasip1 GOARCH=wasm go test -a -n -c -o tdemo.test.wasm .` gives `~/e1/tdemo/plan-c.sh` (127 actions, including 71 vet lines).
2. Delete the vet lines and insert `cp _testmain.go $WORK/b001/` before the `-p main` compile. The `_testmain.go` comes from native `go test -work -c` (49 lines). The result is `plan-c-novet.sh`.
3. Run `runplan.py plan-c-novet.sh --mode wasm -j 2`. The cold build took 200 s for the wasm tools vs 41.8 s natively. The deps are testing, flag, runtime/pprof, and so on.
4. Run `wasmtime tdemo.test.wasm -test.v`. Output: `=== RUN TestAdd / --- PASS: TestAdd / PASS`.
5. The wasm-built test binary is byte-identical to one built with native tools from the same plan. It differs from `go test -c` output only in the build ID (79 bytes), because the `buildid -w` rewrite step is skipped.

(Driver note: the link block's script can exceed Linux MAX_ARG_STRLEN (128 KB), so `runplan.py` pipes it to `bash -s` on stdin.)

## Artifacts on wasm-x1

| path | contents |
|---|---|
| `~/e1/goroot/` | writable GOROOT copy (git repo; `git diff` shows the filelock patch). `pkg/tool/wasip1_wasm/` holds the wasm tools for cmd/go. |
| `~/e1/bin/{compile,link,asm,pack,go,go-patched}.wasm` and `.cwasm` | toolchain (cranelift o2 precompiled). `pack-native` is a native pack for the baseline. |
| `~/e1/bin-o0/`, `~/e1/bin-winch/`, `~/e1/bin-nosig/` | wasmtime variant .cwasm files |
| `~/e1/hello/` | `plan.sh`, `hello.wasmbuilt.wasm`, `hello.native.wasm` (identical) |
| `~/e1/httpd/` | `plan.sh`, `httpd.wasmbuilt.wasm`, `httpd.native.wasm` (identical), `httpd.cwasm` |
| `~/e1/tdemo/` | `plan.sh` (`go test -n`), `plan-c-novet.sh`, `_testmain.go`, `tdemo.test.wasm` |
| `~/e1/work-wasm/`, `~/e1/work-native/`, `~/e1/work-httpd-*/`, `~/e1/work-test-wasm/` | `$WORK` trees containing all std `.a` archives built by the wasm toolchain |
| `~/e1/runplan.py`, `~/e1/bench-*.sh`, `~/e1/bench-*.tsv`, `~/e1/log-*.txt` | drivers, raw benchmark data, build logs |
| `~/e1/wt-old/wasmtime-v36.0.2-x86_64-linux/` | wasmtime with the legacy p1 implementation (tcplisten) |
| `~/.wasmtime/bin/wasmtime` | wasmtime 49.0.3 |

## Blockers / risks

1. **Speed:** about 4x per thread, and 5-10x for whole builds on small machines. Go-on-wasm codegen is the dominant factor; we can't fix it short of a different compilation strategy for the toolchain (e.g. wasm GC / stack switching in future Go). We can amortize with warm std caches (warm hello is ~1.1-1.7 s), precompiled .cwasm, process-level parallelism and GOGC tuning.
2. **Memory:** about 0.55 GB peak per wasm compile of large packages, vs 0.2 GB native. j=4 on a 4 GB box is the limit.
3. **cmd/go needs spawn + pipes + non-blocking wait** (section 4). It is not possible with the wasmtime CLI; it needs a custom embedder.
4. **Sockets:** current wasmtime (49) CLI dropped `tcplisten` for p1 modules. Serving needs wasmtime ≤36-ish or our embedder. Outbound networking (GOPROXY) is unavailable in wasip1.
5. **Module compile cost:** 113-127 s to cranelift-compile compile.wasm (1.1 GB RSS). It must be done once per toolchain version and shipped as .cwasm, which is tied to the wasmtime version and CPU features.

## Recommendation

**Go is feasible as a first language.** Plan for:
- (a) shipping precompiled `.cwasm` toolchains per Go version;
- (b) an orchestrator, either native or our own embedder, that executes the action graph and dispatches compile/asm/link as wasm instances in parallel. For v1, use the `go build -n` / `go list -json` planning (`runplan.py` style), plus a native-side `_testmain.go` generator for tests;
- (c) a persistent std-archive cache, because cold std builds are the painful part (100-260 s here) and the archives are reproducible;
- (d) later, the host `proc_spawn` / `fd_pipe` / exit-fd imports (~400 lines of std patch + ~600 lines of Rust) so the real cmd/go runs inside wasm.

Re-measure on a box without steal before committing to absolute latency targets.
