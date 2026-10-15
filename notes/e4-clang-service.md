# E4: C/C++ as a service toolchain (compiler as wasm) + wasip2 component workloads

Date: 2026-10-15. VM: altwasm, 2 vCPU / 3.8 GB. The VM was noisy during this
work: 25–80% CPU steal, plus another agent's `git gc` at times. So
single-run numbers vary by 2–3x. Min-of-N numbers are given where it matters.

## What was built

| Piece | Where |
|---|---|
| Reproducible toolchain fetch (upstream npm / GitHub releases, pinned sha256) | `scripts/fetch-toolchains.sh` → `toolchains/` (gitignored) |
| Toolchain registration over HTTP (streamed tar + `tool.json`) | `scripts/register-toolchains.sh` |
| Host: wasip2 components, precompile-only execs, service socket policy, wasm EH, cache fixes | `host/src/{exec,cache,main}.rs` |
| Control plane: tool commands, multi-step jobs, `cmd` lines, clang driver | `control/{tools,exec,cc,doc}.go` |
| Demo (HTTP API only after start) | `scripts/demo-e4.sh`, sources in `examples/c/` |

Run it:

```
scripts/fetch-toolchains.sh          # once, ~20 s, 230 MB unpacked
FRESH=1 scripts/demo-e4.sh           # cold: registers + compiles clang (~4–5 min here)
scripts/demo-e4.sh                   # warm: reuses data-e4demo{,.cache}
```

The fetched tree is byte-identical to the one tested on wasm-x2 in e2. Both
trees hash to the same value: 6004 files in the merged sysroot plus
`llvm.wasm`. So it was rebuilt from upstream, not copied. The `.cwasm` files
from wasm-x2 were not reused. They are tied to the engine config, and the
host's (epoch interruption, exceptions) differs from the CLI's.

## Using it (agent's view)

```
POST /v1/workspaces/{id}/run {"cmd": "cc -O2 -Wall -o app.wasm main.c util.c && ./app.wasm"}
POST /v1/workspaces/{id}/run {"cmd": "c++ -O2 -std=c++17 -o app.wasm main.cpp"}
POST /v1/workspaces/{id}/run {"cmd": "cc --target=wasm32-wasip2 -o srv.wasm server.c"}
POST /v1/workspaces/{id}/services {"module": "srv.wasm"}      -> {"port", "url", "kind": "component"}
```

- `cmd` takes shell-like words: quoting, globs relative to the workspace, and
  `&&`. Pipes and redirection are rejected with a clear 400 error.
  `{"module", "args"}` still works.
- The response is shaped like a shell result: concatenated stdout/stderr, the
  exit code of the first failing step, and `state`
  (exited/failed/timeout/killed). It also has `steps[]` (argv, wall_ms,
  load_ms, cache, kind) so agents can see where the time went.
- `timeout_ms` covers the whole command line. Each step gets the time
  remaining. `DELETE /v1/jobs/{id}` kills whichever step is running.
- Commands exported by the `llvm` tool: `cc gcc clang c++ g++ clang++ wasm-ld
  ld ar ranlib nm objdump strip size c++filt`. All of them are the same 75 MB
  multicall module, selected by argv[1].

## Design

### Tools are data; the driver is control-plane code

`tool.json` gained four fields:

- `commands`: command name → argv prefix.
- `scratch`: a guest path that gets a fresh per-invocation writable directory.
  It is shared by every step of one invocation. clang uses `/tmp` for `.o` files.
- `driver`: names a Go driver for commands whose prefix starts with a program
  the driver handles.
- `clang`: sysroot-specific knowledge kept as data: which tool componentizes,
  the adapter path, and the C++ EH flags.

The clang driver (`control/cc.go`, ~200 lines) does the following:

1. For `--version`, `-###`, `-print-*` and similar, it passes the arguments
   straight through.
2. Otherwise it runs `clang -### <args>` as one execution, captures the output,
   and parses the quoted job lines. Banner lines are dropped unless `-v` is
   given. Driver diagnostics are kept.
3. It runs each job as its own wasm execution of the same module: cc1 jobs
   (leading `""` dropped) and `wasm-ld`.
4. `wasm-component-ld` (wasip2) is native Rust upstream, so it is emulated:
   `wasm-ld … -o /tmp/wasmdev-core.wasm`, then the componentizer tool
   (`wasm-tools component new core -o out`). `--adapt` with the p1 adapter is
   added only if the core module still imports `wasi_snapshot_preview1`. The
   driver checks this by reading the core module's bytes from the scratch dir.
   Adapting unconditionally makes wit-component fail with a duplicate
   `wasi:cli/run`.
5. For C++ on wasip1 (unless `-fno-exceptions` is given), it adds
   `-fwasm-exceptions -mllvm -wasm-use-legacy-eh=false`, plus
   `-L/usr/lib/wasm32-wasip1-eh -lunwind` when linking. YoWASP's own libc++
   has no EH, and wasmtime only accepts exnref, not legacy EH. Without these
   flags, a plain `c++ main.cpp` fails to link because clang defaults to
   `-fexceptions`.

The host has no notion of clang, jobs or toolchains. It got exactly one
generic new capability: `precompile_only`.

### The seam: control-plane driver vs. "guest may spawn registered tools"

Alternative considered: a host import (or a WASI-ish `proc_spawn`) that lets
any workload ask for another registered tool to run, like a subprocess. With
it, clang's own driver, `make`, a shell or a test runner could spawn children
directly.

- **Why not now:** the clang we have can't use it. YoWASP's `llvm.wasm` is a
  stock wasip1 build whose driver calls `posix_spawn`, which wasi-libc stubs
  out. Using a custom import would mean rebuilding LLVM, or binary-patching an
  import, and then maintaining that. The `-###` split already gives the same
  result.
- **Cost of the driver approach:** each "spawner" (clang today; `make`/`sh`
  later) needs its own control-plane driver, and the driver must know the
  tool's CLI. For clang that is about 200 lines and stable, because `-###` is a
  documented interface.
- **The general mechanism will be needed** once agents run real build systems
  (`make`, `cmake --build`, `go build` calling compile/link, test runners
  spawning the binary under test). Where the decision would sit: the spawn
  request should go **to the control plane, not the host**. The control plane
  decides which tool, which mounts and which limits, using exactly the
  `step()` machinery added here. The host just exposes a blocking-from-the-
  guest's-view `spawn/wait` that it forwards. This keeps the policy in wasm.
  It needs a host→control-plane callback channel (the event-fd idea from e3
  open question 1), which doesn't exist yet.
- Decision: **control-plane driver now** (simplest thing that works, no
  rebuilt toolchain). Keep the multi-step job runner (`runCtx.step`) generic,
  so a future spawn import is just another caller of it.

### Jobs are now multi-step (control plane)

Before E4 a job was one host handle. Now a run is a goroutine that runs steps.
Each step is `host.Start` + poll + `host.Release`; host job records used to
leak and are now released. stdout/stderr are renamed or appended into the
job's files. Kill and timeout apply to the job as a whole. Services are still
single-execution.

### Workspace mounted at `/` as well as `/work`

wasi-libc never reads `$PWD`: its cwd is `/`. clang (and any C program) given
`main.c` therefore looks for `/main.c`. Every run now mounts the workspace at
`/work` (fd 3, `$PWD`, for Go) **and** `/` (fd 4). Tool mounts (`/usr`,
`/tmp`) shadow subdirectories of the same names by longest-prefix match. For
wasip1 services the listen fd moved from 4 to 5; it was always advertised in
`$WASMDEV_LISTEN_FD`.

### Host: components (wasip2)

- Kind detection uses bytes 6..8 of the header (`01 00` = component layer).
  The cache memoizes `(hash, kind)` and stores serialized `Component`s next to
  `Module`s.
- Components run as `wasi:cli/command` via `wasmtime_wasi::p2::bindings::Command`,
  with the same `ExecSpec`/`Status`, stdio files, preopens, epoch preemption,
  kill/timeout and `StoreLimits` (64 instances: wit-component adds shim
  instances). `run` returning `Err(())` gives exit code 1; `proc_exit` gives
  its code.
- Services: wasi:sockets has no "preopened socket", so the host reserves a
  free port, sets `$PORT`, and installs a `socket_addr_check` allowing only
  bind/listen on that port. Outbound TCP, UDP and DNS are denied. Plain runs
  get `allow_tcp(false)`. Verified with `examples/c/netprobe.c`:

  ```
  as service:  bind+listen 0.0.0.0:$PORT ok | 0.0.0.0:$PORT+1 EACCES | 127.0.0.1:$PORT ok
               connect 127.0.0.1:8781 EACCES | connect 1.1.1.1:80 EACCES | udp EACCES
  as plain run: every socket op fails
  ```
- Outbound decision (documented in HOST_CAPABILITIES): **none by default**,
  including loopback. That means a test program can't call the agent's own
  service yet. The future escape hatch is a per-exec allow-list from the
  control plane, not `inherit_network()`.

## Measurements

### One-time and startup (cold → warm)

| What | Cold | Warm |
|---|---|---|
| fetch-toolchains.sh (downloads ~150 MB, assemble) | 21 s | — |
| control plane up (control.wasm compile vs disk cache) | 21.7–26.8 s | **0.19–0.6 s** |
| register `wasm-tools` (upload 16 MB + compile) | 42 s | — |
| register `llvm` (upload 215 MB tar: 6.7–7.6 s; compile) | **227–254 s**, 1.9 GB peak RSS | — |
| both toolchains in host memory after a restart (disk cache) | — | **0.9–1.5 s** |
| host RSS after compiling clang | 1.9 GB → **110 MB** with `malloc_trim` | 47 MB idle after restart; 176 MB after demo |

The clang compile was 2.3–2.5x slower here than on wasm-x2 (~100 s). That
fits the steal on this VM. Registration time is paid once per wasmtime
version and engine config. The demo's warm path never compiles clang.

### Per build (min of N via HTTP, warm, this VM)

| Command | min | median | steps (ms, min run) |
|---|---|---|---|
| `cc -c hello.c` | 104 ms | 190 ms | `-###` 6, cc1 92 |
| `cc -O2 -o hello.wasm hello.c greet.c` | 314 ms | 500 ms | 6, 103, 89, 94 (ld) |
| `cc -O1 test_calc.c calc.c && ./t.wasm` | 401 ms | 512 ms | 5, 109, 177, 17, run 1 |
| `cc --target=wasm32-wasip2 -O2 httpd.c` (clang + wasm-ld + wasm-tools) | 394 ms | 408 ms | 5, 182, 107, 86 |
| `c++ -O0 -std=c++17 shapes.cpp` (EH, STL) | 9.2 s | 9.6 s | 6, 8800, 304 |
| `c++ -O2 -std=c++17 shapes.cpp` (single demo runs) | 29–35 s | | cc1 28–34 s, ld 0.9–1.1 s |
| run `hello.wasm` (C, warm) | 2 ms | 3 ms | |

Host vs. CLI: the same cc1 jobs under `wasmtime run` with the CLI `.cwasm`
take the same time on this VM: `clang -c hello.c` 0.10 s, `shapes.cpp -O2`
20–30 s. So the host and control plane add only per-step overhead (a few ms).
The time goes to the compiler itself. The C++ cost is libc++ headers in an
`+assertions` clang build (e2 saw ~6x native) on a CPU-starved VM.

### Demo (`scripts/demo-e4.sh`, warm run)

```
service start (API up)                          409 ms
toolchains in memory after API up (disk cache) 1509 ms
1. cc 2 files (first build)                    1099 ms
1. cc 2 files (warm)                           1008 ms
1. run hello.wasm (first: compiles output)      100 ms
1. run hello.wasm (warm)                          3 ms
2. build + run unit tests                       980 ms
3. c++ build (first)                          35396 ms
3. c++ build (warm)                           29390 ms
3. run shapes.wasm (first: compiles 2 MB)      2997 ms
3. run shapes.wasm (warm)                         5 ms
4. cc wasip2 (clang + wasm-ld + wasm-tools)    1391 ms
4. service start -> first HTTP 200             1589 ms   (includes compiling the component)
4. service start -> first HTTP 200 (warm)       114 ms   (poll loop with curl spawns; ~5 ms granularity)
```

"First" vs "warm" for builds mostly measures noise. clang is already warm in
memory in both cases. The real cold costs are the one-time registration and
the compile of each new output binary on its first run (0.1 s for small C,
about 1–3 s for a 2.8 MB C++ binary).

## Problems hit (and fixes)

1. **wasi-libc ignores `$PWD`.** clang reported "no such file 'hello.c'" with
   the workspace at `/work`. Fix: also mount the workspace at `/`.
2. **Exceptions need wasmtime's `gc` feature.** `Config::wasm_exceptions` is
   behind `gc`, and the host was built with `default-features = false`.
   Added `gc` and `gc-drc`.
3. **1.9 GB RSS kept after compiling clang** (glibc arenas of Cranelift's
   worker threads). `malloc_trim(0)` after each compile brings it to about
   110 MB.
4. **Disk-cache loads waited behind compiles.** At startup the llvm warm-up
   queued behind wasm-tools' 36 s compile on the compile lock. Disk hits now
   skip the lock: llvm load went from 36 s to 0.6 s.
5. **Toolchain upload** (215 MB tar) was `io.ReadAll`'d in the wasm control
   plane. It is now streamed (`bufio.Peek` to sniff wasm vs tar).
6. Test-writing gotcha, not a toolchain bug: `long` is 32-bit on wasm32
   (`fib(50)` overflowed in the first unit test).
7. Note for whoever runs scripts here: `pkill -f data-e4` also matched the
   invoking shell's command line. Use a pid file.

## Open issues / next

1. **Parallel cc1 jobs.** TUs in one `cc` call run one after another. Running
   the cc1 jobs concurrently (bounded by vCPUs), then the link, would roughly
   halve multi-file builds on 2 vCPU. `runCtx` needs multiple live handles
   for kill.
2. **C++ compile speed.** Use a non-assertions clang (build YoWASP's recipe
   ourselves) and/or precompiled headers or modules for libc++. A cache keyed
   on the preprocessed TU would also help repeated builds.
3. **C++ on wasip2.** wasi-sdk 34 ships no wasip2 libc++ (the `eh/` dir is
   empty). Options: build libc++ for wasip2, or link the wasip1 libc++
   against wasip2 libc (ABI-risky).
4. **Generic spawn** (see "The seam") for make/cmake/test runners: it needs
   the host→control-plane event channel first.
5. **Outbound allow-list** per exec (and loopback-to-own-service for tests).
6. **Port race for components:** the host releases the port reservation just
   before the guest binds it. Fixing this needs a "preopened listener"
   extension for wasi:sockets, or a host-side accept proxy.
7. `wasi:http/proxy` components as services (no socket code in the guest).
8. GC of `/data/runs/*` (scratch dirs are removed per job, but step outputs
   and job records remain).
