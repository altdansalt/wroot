# E2: a C/C++ compiler running as WASI under wasmtime

Date: 2026-10-15. Host: wasm-x2 (2 vCPU, 4 GB, Ubuntu, noisy, with up to ~27% CPU steal). wasmtime 49.0.3.
Scripts: `~/wasmdev/experiments/e2-clang-wasm/` (`setup.sh`, `wcc.py`, `bench*.sh`, `cold.sh`, `other-toolchains.sh`, `src/`, `results/`).

## TL;DR

- **Recommended: YoWASP clang 22.1** (`@yowasp/clang` 22.0.0-git20542-10 on npm, published 2026-03-12). It's one multicall
  **wasip1 core module** (`gen/llvm.core.wasm`, 75.5 MB) plus a 33 MB wasi-libc/libc++ sysroot tar. It runs directly under
  the `wasmtime` CLI with no JS. Clang, wasm-ld, ar, nm and objdump all work.
- You still need a small host-side driver, `wcc.py`, because WASI can't spawn processes. It works the same way as YoWASP's JS
  `runClang`: it runs `clang -###`, then runs each job (cc1 and wasm-ld) as a separate `wasmtime run`.
- **C, C++ and multi-file builds to wasm32-wasip1 all work.** C++ exceptions also work if you use the EH libc++ from the
  wasi-sdk-34 sysroot.
- **wasm32-wasip2 also works end to end in WASM.** Combining YoWASP clang with the wasi-sdk-34 wasip2 libc and `wasm-tools.wasm`
  (`component new`) produced a C TCP server. It listened under `wasmtime run -S inherit-network`, and both curl and nc got
  answers.
- **Speed:** with a precompiled `.cwasm`, startup is about 0.07 s. Compiling C is about 2.5–3x slower than native clang. C++
  headers are slow: about 2.3 s for an iostream hello vs about 0.36 s native. The one-time AOT compile is about 100 s wall
  (about 200 s CPU) at about 1.9 GB RSS.

## Candidates surveyed

| Candidate | Status (Oct 2026) | Usable under wasmtime CLI? |
|---|---|---|
| **YoWASP clang** — npm `@yowasp/clang` ([github.com/YoWASP/clang](https://github.com/YoWASP/clang)) | LLVM 22.1.0 (YoWASP fork on codeberg), last repo push 2026-03. **Not on PyPI** (`yowasp-clang` doesn't exist there); npm only, no GitHub releases | **Yes.** `llvm.core.wasm` is a plain wasip1 command module (29 wasi_snapshot_preview1 imports, exports `_start`/`memory`) |
| wasmer `clang/clang` ([wasmer.io/posts/clang-in-browser](https://wasmer.io/posts/clang-in-browser)) | Maintained, about 100 MB | No. It's WASIX: it needs `posix_spawn` and the wasmer runtime |
| binji/wasm-clang | Last push 2023-12, LLVM 8-era, browser-only | No (stale) |
| wasi-sdk | Ships native hosts only. Release 34 (2026-08) gives the sysroot, which we reuse | n/a (but its sysroot is useful, see below) |

## Exact invocation (no Python, raw wasmtime)

```sh
Y=~/e2/yowasp      # llvm.wasm, llvm.cwasm, usr/ (from llvm-resources.tar)
wasmtime compile $Y/llvm.wasm -o $Y/llvm.cwasm                     # once
W="wasmtime run --allow-precompiled --dir .::/ --dir $Y/usr::/usr --dir ./tmp::/tmp --env TMPDIR=/tmp $Y/llvm.cwasm"
$W clang -c --target=wasm32-wasip1 -O2 hello.c -o hello.o          # cc1 runs in-process, no spawn
$W wasm-ld -m wasm32 -L/usr/lib/wasm32-wasip1 /usr/lib/wasm32-wasip1/crt1-command.o hello.o -lc \
   /usr/lib/wasm32-unknown-wasip1/libclang_rt.builtins.a -o hello.wasm
wasmtime hello.wasm
```

- **Multicall:** argv[0] is ignored (YoWASP passes `yowasp-llvm`), so wasmtime's argv[0] (the module path) is fine. **argv[1]
  selects the tool:** `clang`, `clang++`, `wasm-ld`/`lld`/`ld.lld`, `ar`, `ranlib`, `nm`, `objdump`, `objcopy`, `strip`,
  `size`, `readobj`, `symbolizer`, `c++filt`, and others. An unknown name prints the list.
- **Filesystem layout the build expects:** `InstalledDir` is empty, `-resource-dir /usr`, `-isysroot /usr`. So the sysroot must
  be mounted at guest `/usr`, and the clang builtin headers live in `/usr/include`. User files go at guest `/`. Paths must be
  relative to cwd, or guest-absolute.
- **Temp files:** the driver needs `TMPDIR` set to a writable preopen. Without it you get
  `unable to make temporary file: No such file or directory`.
- **Subprocesses:** in-process cc1 is used (`-fintegrated-cc1`; the job line starts with `""`), so `clang -c` needs no spawn. A
  compile-and-link invocation needs to spawn `wasm-ld`, which fails under WASI. `wcc.py` handles this by running `-###`,
  parsing the quoted job lines, dropping the leading `""`, and running each job through wasmtime. For wasip2 the driver
  wants `wasm-component-ld` (native Rust). `wcc.py` emulates it with `wasm-ld` → `/tmp/core.wasm` → `wasm-tools.wasm
  component new`. It adds `--adapt wasi_snapshot_preview1=...command.wasm` only if p1 imports remain; adding it
  unconditionally panics wit-component on a duplicate `wasi:cli/run` export.
- `wcc.py` usage: `wcc.py clang -O2 a.c b.c -o x.wasm`, `wcc.py clang++ ...`, `wcc.py ar rcs libu.a *.o`. Settings come from env:
  `WCC_MODULE`, `WCC_USR`, `WCC_WASM_TOOLS`, `WCC_ADAPTER`, `WCC_VERBOSE=1`.

## Results

| Test | Result |
|---|---|
| C hello, wasip1 (`wcc.py clang hello.c`) | OK, 28 KB output |
| C++ hello with iostream, vector, sort (`clang++ -O2 -fno-exceptions`) | OK, 601 KB output |
| C++ without `-fno-exceptions` (YoWASP sysroot) | **Link fails.** The driver defaults to `-fexceptions -fcxx-exceptions`, but YoWASP's libc++abi has no `__cxa_throw` and the like. Workaround: `-fno-exceptions` |
| C++ exceptions with wasi-sdk-34 `lib/wasm32-wasip1/eh/{libc++,libc++abi,libunwind}.a` + `-fwasm-exceptions -mllvm -wasm-use-legacy-eh=false -lunwind` | **OK.** It caught `std::out_of_range` and `int`. Output is 2.8 MB. Legacy EH is rejected by wasmtime 49 (`legacy_exceptions feature required`), so exnref is required |
| Multi-file (3 TUs in one invocation; also separate `-c`, `ar rcs`, link `-lu`) | OK |
| wasip2 target with YoWASP sysroot alone | No: there are no wasip2 headers or libs (`stdio.h` not found) |
| **wasip2 with the wasi-sdk-34 sysroot merged into `usr2/`** | **OK.** The output is a 436 KB component that imports `wasi:sockets/*@0.2.12`. `wasmtime run -S inherit-network tcp2.wasm` binds :8089, and curl and nc both got `HTTP/1.0 200` |
| wasip1 + preopened socket (`-S tcplisten`) | **Not available** in wasmtime 49: "components do not support --tcplisten" and "`-Spreview2=n` no longer supported". wasi-libc p1 does link `sock_accept`, but wasmtime no longer provides it. Use wasip2 for servers |

## Measurements

All on wasm-x2. The steady-state numbers are the minimum over 5 interleaved runs (`bench2.sh`), because CPU steal made single
runs vary by 2–3x.

**Module and artifact sizes**

| Item | Size |
|---|---|
| llvm.wasm (raw wasip1) | 75.5 MB |
| npm tgz | 27 MB |
| sysroot (YoWASP) | 33 MB (29.7 MB tar) |
| llvm.cwasm, cranelift | 191 MB |
| llvm.cwasm, cranelift `-O opt-level=0` | 205 MB |
| llvm.cwasm, winch | 322 MB |
| implicit wasmtime cache entry | 62 MB (compressed) |
| wasm-tools.wasm / .cwasm | 16 MB / 38 MB |

**One-time / startup cost**

| What | Wall | CPU | Peak RSS |
|---|---|---|---|
| `wasmtime run -C cache=n llvm.wasm clang --version` (cold JIT) | 81 s (189 s in a noisy period) | 158 s | 1.94 GB |
| `wasmtime compile` (cranelift) | 101 s | 196 s | 1.94 GB |
| `wasmtime compile -C compiler=winch` | 29 s | 48 s | 2.29 GB |
| Warm implicit cache (`wasmtime run llvm.wasm`) | 0.8–1.2 s | 0.6–0.8 s | 460 MB |
| **Precompiled `.cwasm` `clang --version`** | **0.07 s** | 0.04 s | 60 MB |

**Per-file compile (`-c`, min of 5), wall time / peak RSS**

| Input | cranelift .cwasm | cranelift O0 .cwasm | winch .cwasm | native clang 18 |
|---|---|---|---|---|
| hello.c -O0 | 0.02 s / 103 MB | 0.02 s | 0.03 s / 133 MB | 0.01 s / 90 MB |
| big.c (2.2k lines) -O0 | **0.32 s** / 118 MB | 0.33 s | 0.52 s / 152 MB | 0.12 s / 111 MB |
| big.c -O2 | **0.94 s** / 125 MB | 0.93 s | 1.39 s / 176 MB | 0.37 s / 102 MB |
| hello.cpp, iostream -O0 | **2.34 s** / 152 MB | 2.18 s | 2.99 s / 196 MB | 0.36 s * / 120 MB |

\* Native C++ is x86 against libstdc++. Clang 18 can't parse the libc++ 22 headers (`__builtin_clzg`), so this row isn't
apples-to-apples.

**End to end with `wcc.py`** (`-###` + cc1 + wasm-ld, each a separate wasmtime process)

| Build | Wall |
|---|---|
| hello.c | 0.2–0.3 s |
| 3-file C -O2 | 0.4–0.5 s |
| hello.cpp -O2 | 4.4 s |
| wasip2 tcpserver (clang + wasm-ld + wasm-tools.wasm) | 0.4 s |

**What these numbers mean**

- C is about **2.5–3x native**, and C++ is about **6x**. Part of this is that the YoWASP build has `+assertions` on.
  libc++-heavy translation units are the pain point, so precompiled headers or modules would help.
- `-O opt-level=0` for cranelift made no runtime difference here and didn't compile faster.
- Winch compiles the AOT artifact 3.5x faster but runs clang about 1.5x slower and uses more memory. That trade-off only makes
  sense for one-shot use.
- Peak RSS while compiling is only 100–200 MB. The expensive part is the one-time AOT compile at about 2 GB. **Ship a `.cwasm`
  per wasmtime version and host arch**, or build it once at deploy time.

## Rust (survey only; nothing was built)

- **rustc does run as WASM.** [oligamiq/rust_wasm](https://github.com/oligamiq/rust_wasm) publishes rustc 1.83-dev (LLVM backend)
  built for **wasm32-wasip1-threads**, with releases up to 2026-08. [rntz-llm/rust-wasm-serve](https://github.com/rntz-llm/rust-wasm-serve)
  uses those builds to compile Rust in the browser. It reports about 56 MB of assets (31 MB rustc + 25 MB sysroot) and 1–3 s for
  a small program at opt-level 0. Its limits: single file, std only, no cargo or crates, and it needs threads and shared
  memory plus wasm exception handling.
- [LuvHakii/rust-wasm](https://github.com/LuvHakii/rust-wasm) is a patch-based rustc plus rust-analyzer for the browser
  (wasip1, active Oct 2026, 0 stars).
- **Status:** usable as a demo, but it's an old nightly and depends on wasi-threads. wasmtime still marks
  `-S threads` / `-W threads` as experimental. A cranelift-backend rustc in WASM doesn't exist as a maintained artifact. This
  is the riskiest piece; it would need its own experiment (E3?).

## Other WASI-hosted toolchains

| Toolchain | Where | Maturity / result here |
|---|---|---|
| **CPython 3.15.0 WASI** | [brettcannon/cpython-wasi-build](https://github.com/brettcannon/cpython-wasi-build) releases (python.org tier-2 wasip1 target) | **Tested.** 32 MB python.wasm, AOT compile 10 s, cwasm 17 MB. `wasmtime run --allow-precompiled --dir ./lib::/lib --dir ./app::/app python.cwasm /app/t.py` ran a `unittest` suite (json, hashlib) OK. `socket` and `threading` import; `_sqlite3` is missing. Warm run 0.17 s / 33 MB |
| **Go compiler (cmd/compile + cmd/link) as wasip1** | Built by stock Go: `GOOS=wasip1 GOARCH=wasm go build cmd/compile` (147 s) | **Tested.** compile.wasm (53 MB) and link.wasm (12 MB) compiled and linked `hello.go` with fmt into a wasip1 binary that runs (compile 0.9 s, link 0.5 s). Stdlib export data came from the native Go cache. A fully-WASM flow would compile std once with compile.wasm. **Very promising: an official toolchain, pure Go, no spawn needed when driven per package** |
| QuickJS-ng | [quickjs-ng/quickjs](https://github.com/quickjs-ng/quickjs) v0.17.0 ships `qjs-wasi.wasm` / `qjs-wasi-reactor.wasm` | Mature, prebuilt. Not tested |
| Zig | `stage1/zig1.wasm` in the zig repo (moved to codeberg.org/ziglang/zig) | Bootstrap-only compiler (C backend), not a general toolchain |
| TinyGo | — | No WASM-hosted build (needs LLVM). Not viable |
| Ruby, PHP | ruby/ruby.wasm; vmware-labs webassembly-language-runtimes (stale since 2024) | Interpreters exist, not checked |

## Blockers and caveats

1. **No process spawning in WASI.** The service needs its own driver (`wcc.py`, or a Go/Rust equivalent built into the
   service) that splits `clang -###` into jobs. The same applies to `make`, `cc` called from build scripts, and similar tools.
   Plan for a "job runner" that maps exec → new wasmtime instance. Precompiled `.cwasm` makes that cheap: about 20 ms per
   instance.
2. **YoWASP packaging.** It's npm only, built from a fork on codeberg, with an `+assertions` build and a single maintainer.
   We take only the raw core module. For a production service, consider building clang for wasip1 ourselves from the YoWASP
   recipe (non-assertions, which should be faster).
3. **The YoWASP sysroot is wasip1-only and has no C++ exceptions.** Merge in the wasi-sdk-34 sysroot (wasip2 libc and
   `eh/` libc++). The mix is clang 22 with libc++ 23 libs: it worked for the tests here but isn't guaranteed.
4. **wasip1 `--tcplisten` is gone from wasmtime 49,** so network servers must target wasip2. A wasip2 build needs
   `wasm-tools.wasm` (or a wasm build of `wasm-component-ld`) for componentization. Both are available as WASM.
5. **AOT cost.** 1.9–2.3 GB RSS and about 100 s for the one-time `.cwasm` compile. `.cwasm` files are tied to the wasmtime
   version and CPU.
6. **The helper VM has heavy CPU steal,** so single-run timings vary 2–3x. Use the min-of-N numbers.

## Recommendation

Use **YoWASP clang 22 (raw `llvm.core.wasm`) + wasi-sdk-34 sysroot + `wasm-tools.wasm`**, run through wasmtime with a precompiled
`.cwasm` and a host-side job runner that replaces the clang driver's spawning. This gives a working, all-WASM C/C++ toolchain
today for wasip1 and wasip2, including sockets and C++ EH, at about 3x native speed for C. Next steps: (a) a non-assertions
clang build, (b) embed the job runner in the service (wasmtime crate, keep `Module` in memory, one `Store` per job), (c)
evaluate the Go-in-WASM toolchain as a second language (cheap and official), (d) put rustc-in-WASM in a separate, riskier
experiment.

## Artifacts on wasm-x2 (`~/e2/`)

| Path | Contents |
|---|---|
| `~/e2/yowasp/llvm.wasm` | Raw clang module |
| `~/e2/yowasp/llvm.cwasm` | Cranelift AOT build |
| `~/e2/yowasp/llvm-o0.cwasm` | Cranelift `-O opt-level=0` AOT build |
| `~/e2/yowasp/llvm-winch.cwasm` | Winch AOT build |
| `~/e2/yowasp/usr/` | YoWASP sysroot |
| `~/e2/usr2/` | Merged sysroot: YoWASP + wasi-sdk-34 wasip2 + `lib/wasm32-wasip1-eh` |
| `~/e2/sdk34/` | wasi-sysroot-34 and libclang_rt-34 |
| `~/e2/tools/` | wasm-tools.wasm/.cwasm, p1 command adapter |
| `~/e2/wcc.py`, `~/e2/bench*.sh`, `~/e2/cold.sh` | Scripts |
| `~/e2/bench*.txt`, `~/e2/cold.txt` | Benchmark output |
| `~/e2/work/` | Built outputs: hello.wasm, hellocpp.wasm, exc.wasm, multi/multi.wasm, tcp2.wasm, tcpserver.wasm (p1) |
| `~/e2/cpython/` | python.wasm, python.cwasm, lib/, app/t.py |
| `~/e2/go/` | compile.wasm, link.wasm, hello.go, hello.wasm, importcfg |
| `~/e2/dl/` | Downloads |
