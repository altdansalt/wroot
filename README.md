# wroot — wasmdev: a WebAssembly-native development service for coding agents

Agents upload source, build it with compilers that **themselves run as WebAssembly**, run tests,
and start long-running network services — all through a small HTTP API. The control plane is
also WebAssembly. A thin native host (Rust + wasmtime) only provides execution, sockets, files,
clocks and process spawn; see [docs/HOST_CAPABILITIES.md](docs/HOST_CAPABILITIES.md).

```
agent ──HTTP──▶ wasmdev-host (Rust, wasmtime)          native: sockets, files, exec, spawn
                  └─ control.wasm (Go, wasip1)          wasm: API, workspaces, cc driver, mini-shell
                       └─ workloads (wasm): clang/lld (YoWASP LLVM), go/compile/link (Go toolchain
                          built for wasip1), user programs (wasip1), services (wasip1 / wasip2 components)
```

## Status
All seven initial success criteria are demonstrated reproducibly (see [notes/LOG.md](notes/LOG.md)):
C/C++ and Go builds with wasm-hosted compilers, tests, runs, network services, multiple
independent agents (Codex + Claude Code trials in `agent-trials/`), and self-hosting: the
service vets, tests and builds its own control plane byte-identically to a native build
(`scripts/selfhost.sh`).

## Quick start
```
scripts/fetch-toolchains.sh      # pinned clang/sysroot/wasm-tools from upstream
scripts/build-go-toolchain.sh    # Go toolchain for wasip1 (patches in patches/go/)
(cd host && cargo build --release)
scripts/serve.sh                 # API on :8700; GET / documents the API for agents
scripts/demo-w1.sh               # Go end-to-end;  scripts/demo-e4.sh  C/C++ end-to-end
```

## Layout
- `host/` native host (vendored, patched wasmtime-wasi: p1 sockets, process spawn)
- `control/` control plane (Go → wasip1)
- `patches/go/` Go toolchain patches (filelock, spawn via host, wasip1 runtime fix)
- `notes/` experiment log, decisions, measurements; `agent-trials/` briefs and agent reports
