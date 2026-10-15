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
