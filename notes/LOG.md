# wasmdev experiment / decision log

## 2026-10-15 — environment
- Coordinator VM `altwasm`: 2 vCPU / 3.8 GB. Plan caps every VM at 2 vCPU / 4 GB (standalone too).
- Helper VMs created: `wasm-x1`, `wasm-x2` (tag wasmdev), reached via `ssh <name>.exe.xyz`.
- Existing `tun-*` / `claud` VMs belong to other work; untouched.
- Local Go is go1.27.2.

## Initial architecture hypothesis (to be tested)
- Native host = Rust + wasmtime embedding. Provides only: listening sockets, filesystem dirs, wasm module execution (spawn/wait), clocks.
- Control plane = Go compiled to wasip1, serving HTTP via net.FileListener on a host-preopened socket.
  Chosen tentatively because a Go toolchain can itself run as wasip1, which makes self-hosting (criterion 7) plausible.
- Toolchains as wasm: Go (cmd/compile+link built for wasip1), clang/lld built for WASI.

## E2 result — clang as wasm (see notes/e2-clang-wasm.md)
- YoWASP clang 22.1 (npm @yowasp/clang): 75.5 MB wasip1 multicall module + 33 MB sysroot. Runs under plain wasmtime.
- Precompile to .cwasm: ~100 s / 1.9 GB RSS once (191 MB artifact); startup then 0.07 s. Must cache compiled modules.
- 2.2k-line C: 0.32 s -O0 / 0.94 s -O2 (native 0.12/0.37) → ~2.6x slower. C++ iostream hello 2.3 s (native 0.36).
- clang driver needs to spawn wasm-ld: workaround = `clang -###` then run each job. → Host/control plane needs a "spawn"-like job capability.
- wasip1 `--tcplisten` gone in wasmtime 49 → network services should target wasip2 (C TCP server via wasi-sdk-34 wasip2 libc + wasm-tools component link worked, all in wasm).
- rustc-as-wasm: exists only as old 1.83 nightly forks needing wasi-threads; deferred.
- CPython 3.15 WASI works incl. unittest (no sqlite3). Candidate third language.

## E3 result — host + control plane skeleton (see notes/e3-host.md) — independently re-run by coordinator: demo passes
- Rust host (wasmtime 49) + Go wasip1 control plane serving net/http on host-preopened socket. Trivial run p50 ~3 ms over HTTP; service start-to-ready ~3 ms warm.
- wasmtime-wasi 49 p1 has no socket support → vendored + ~360-line patch adding preopened TCP listeners. 
- Module cache: 53 MB cmd/compile cold compile 117 s/1.26 GB; disk cache 212 ms; memory 0.01 ms.

## DECISION D1 (expensive to reverse): control plane = Go/wasip1 on patched wasmtime-wasi p1 sockets
- Why: Go toolchain runs as wasm → control plane can be built/tested by the service itself (criterion 7); stock net/http works.
- Cost: carrying a wasmtime-wasi patch. Exit: if Go gains wasip2, or move ingress to wasi:http.
- User workloads: wasip1 (Go, C, Python) AND wasip2 components (C servers via wasi:sockets) — both supported.
- Services exposed on host ports 8100-8199; reachable privately via exe.dev proxy https://altwasm.exe.xyz:PORT (exe.dev auth), no extra proxy layer for now.

## E1 result — Go toolchain as wasip1 (see notes/e1-go-wasm.md)
- compile/link/asm/pack/go all build for wasip1 unpatched (compile.wasm 53 MB). Hello + net/http server built fully by wasm tools, byte-identical to native.
- Speed (noisy VM, 30-80% steal): ~4x slower per package single-thread; cold hello (all std) 20.5 s native vs 103 s wasm; warm hello 0.5 s vs 1.1-1.7 s. Peak 0.55 GB.
- Startup: JIT 127 s, cache 1.0 s, .cwasm 0.08 s → precompile mandatory. Winch/opt-level=0 not worth it. GOGC=off ~20% faster.
- cmd/go in wasm: `go list -deps` works with a filelock no-op patch; `go build` blocks on subprocess spawn. go test needs _testmain.go (generated in-process by cmd/go).
- Rejected E1's suggestion to generate build plans/_testmain natively: that would be native logic behind the API.

## DECISION D2: add a process-spawn host capability (experiment E5)
- Both clang driver (spawns wasm-ld) and cmd/go (spawns compile/link/asm) want subprocesses. A generic "spawn a wasm module as child process" capability lets unmodified tool drivers run in wasm; the host only executes, the orchestration stays in the tools.
- Competing approach already in flight: E4 = clang job list (-###) driven by control plane. Compare after E5.

## E4 result — C/C++ toolchain in the service + wasip2 components (see notes/e4-clang-service.md)
- `scripts/fetch-toolchains.sh` rebuilds the e2 toolchain from upstream (pinned sha256); byte-identical to wasm-x2's.
- Tools `llvm` (clang/lld multicall + merged sysroot) and `wasm-tools` registered over HTTP (streamed tar), precompiled at registration (clang: 227–254 s / 1.9 GB here, once) and warmed from disk cache at startup (~1 s).
- clang driver lives in the control plane (Go/wasm): `clang -###` → each job a separate wasm execution; wasm-component-ld emulated (wasm-ld + wasm-tools). `{"cmd": "cc -O2 -o a.wasm *.c && ./a.wasm"}` works like a shell. Host knows nothing about clang (only gained `precompile_only`).
- Warm builds: small C 0.3–0.5 s, wasip2 server 0.4 s, C++ (STL+EH) 9 s at -O0 / ~30 s at -O2 (same as wasmtime CLI on this noisy VM).
- Host runs wasip2 components (auto-detected); component services may only bind their assigned $PORT; no outbound/UDP/DNS. C HTTP server built by wasm clang serves via the services API.
- Decision (cheap to reverse): spawning is done by control-plane drivers, not a guest "spawn" import, until we need make/sh; then route spawn requests guest → host → control plane.
