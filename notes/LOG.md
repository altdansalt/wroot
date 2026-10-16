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
- Input for D2/E5: the E4 driver is the -### approach; it works today without rebuilding clang. YoWASP llvm.wasm cannot use a spawn import as shipped (its driver calls posix_spawn, stubbed in wasi-libc), so E5 needs a rebuilt clang (or wasi-libc posix_spawn → import shim) to replace it. Suggest E5 route spawn requests guest → host → control plane (policy in wasm), reusing E4's multi-step job runner (control/exec.go runCtx.step).

## E4 result — clang in the service (see notes/e4-clang-service.md) — coordinator re-ran demo-e4 warm: passes
- cc driver lives in control plane (clang -### → jobs as separate wasm execs). wasip2 components supported; component services may bind only their $PORT, no outbound.
- Warm: 2-file C build 0.6 s, C unit test build+run 0.7 s, C++ STL+exceptions 24 s (slow), wasip2 C server build 1.0 s, service→first 200 ~0.3 s.

## Deployment for agent trials
- `scripts/serve.sh`: API on 0.0.0.0:8700, data ~/wasmdev-data, services 8100-8199.
- Reached from other VMs through exe.dev proxy: https://altwasm.exe.xyz:8700 with X-Exedev-Authorization (VM token, locally signed, 7-day exp) + service bearer token. Unauthenticated → 307 to login. Tokens in ~/.config/wasmdev (0600).
- Registering clang on the live (busy) VM: precompile 535 s. One-time, but argues for shipping precompiled artifacts / precompiling offline.
- No Claude token for other VMs → remote agents = Codex (gpt-6.1-sol via exe.dev LLM gateway) on wasm-x2; Claude Code (sonnet-5.5) agents run locally.

## Agent trials round 1 (started)
- T1 Codex@wasm-x2: C csvstat library + unit/e2e tests.
- T2 Codex@wasm-x2: C HTTP KV service, run as service, tested over network from wasm-x2.
- T3 Claude Code@altwasm: interpreter in C++17 with test suite.

## E5 result — process spawn + unmodified cmd/go in wasm (branch e5-spawn, notes/e5-spawn.md)
- Host capability `wasmdev_proc` (spawn/wait/kill/pipe/open_null); children resolved via parent's mounts, run on own threads, shared module cache; exit-fd becomes EOF on exit so single-threaded Go waits without blocking. Spawn round trip 1-2 ms.
- go version/env/build/vet/test work on a 3-package module, every process wasm. Binary byte-identical to native (-trimpath). Toolchain build reproducible (identical hashes on 2 VMs).
- Go patches: filelock no-op, StartProcess via wasmdev_proc, runtime notetsleepg park-not-spin (upstream bug: signal.Notify livelocked I/O on wasip1). User code compiles against pristine go1.27.2 std.
- Host fix: blocking poll_oneoff sleep made sleeping workloads unkillable — capped.
- Timings (wasm-x1, heavy steal): go build cold 230 s (-p 2) vs native 35 s; warm no-op 3.1 s, after edit 6.2 s; go test warm -count=1 7.4 s. New test binary module compile 19.6 s cranelift vs 3-4.5 s winch → use winch for fresh, short-lived modules.
- YoWASP llvm.wasm refuses all subprocesses → clang keeps E4's job-list driver.

## DECISION D3: adopt wasmdev_proc spawn; Go runs as unmodified cmd/go in wasm
- Go toolchain support = run real `go` with spawn. Clang = control-plane job-list driver (until an LLVM wasm build can spawn).
- Verification: coordinator re-running E5 from a clean clone on wasm-x1 (in progress).

## Agent trials round 1 — results (reports in agent-trials/round1/)
- T1 (Codex, C csvstat): done. 1074 unit checks + 5 CLI e2e pass. Coordinator re-ran its test.sh from wasm-x2: passes.
- T2 (Codex, C wasip2 KV HTTP service): done; network suite passes from wasm-x2. Coordinator verified from wasm-x1 (third VM): healthz ok, PUT/GET ok, unauth → 307.
- T3 (Claude Code, C++17 interpreter): done, 20/20 tests.
- Criteria 3,4,5,6 demonstrated by real agents (C/C++).
- Friction (ranked by impact):
  1. C++ compile 30-68 s per 330-line file (YoWASP clang has assertions; libc++ headers). C is fine (0.4-1.3 s/file).
  2. wasm call-stack limit (wasmtime max_wasm_stack) not configurable/documented; 64 KB default linear stack → confusing OOB fault.
  3. No pipes/redirection/loops in cmd; test runners must be driven client-side, one HTTP call per test.
  4. Service URL returned as http://host:port, should be the usable https proxy URL; no readiness wait.
  5. WASI libc gotchas (tmpfile, long double printf) undocumented.

## W1 — Go first-class + round-1 fixes + self-hosting (notes/w1.md)
- Merged e5-spawn. Go registered as tool "go" over the API (scripts/register-go.sh): spawn grant, shared GOCACHE (/data/cache/go), -p=host cores, GOPROXY=off, test binaries via Winch, 10 modules precompiled + std warm-up at registration.
- Host: engines per (compiler, max_wasm_stack); 8 MiB default wasm stack (per-run up to 256 MiB); Winch + background Cranelift tier-up for workspace programs/services (Winch compiles ~5x faster, code ~2x slower); trap codes; exec_ready; spawn opt-in; separate compile lock for small modules (user programs waited 70-87 s behind toolchain compiles).
- Control plane: cmd shell with && || ; | (buffered) < > >> 2> 2>&1 and builtins echo/cat/cmp/diff; trap explanations; cc default 1 MiB stack; service url (https public) + local_url + wait_ready/ready_ms; GET / gotchas + Go quickstart.
- Warm Go loop: build 0.2-0.7 s, vet 0.6 s, test -count=1 1-4 s, net/http service ready ~1-2 s. Cold registration (fresh caches) 3.5-16 min depending on VM noise.
- Self-hosting (criterion 7): service vets/tests its control plane and builds control.wasm byte-identical to native (-trimpath -buildvcs=false); host restarted on the self-built control.wasm, which rebuilt itself identically. Live service redeployed with it + go tool.

## Coordinator verification after W1 (2026-10-15)
- E5 from clean clone on wasm-x1 (host build + scripts/build-go-toolchain.sh + run-go.sh go test): EXIT=0; cold 12m03s, warm -count=1 5.7 s.
- Criterion 7 by hand against the LIVE service (curl only): upload control/, `go vet` 1.0 s, `go test -count=1` 2.0 s (ok), `go build -trimpath -buildvcs=false` 1.7 s → selfbuilt.wasm sha256 d4bf0455… == native build. 

## Repo
- Pushed to github.com/altdansalt/wroot (public) via exe.dev GitHub integration (https://github.int.exe.xyz/altdansalt/wroot.git, remote `origin`). History scanned for tokens before first push: clean.
- Workers push to feature branches; coordinator reviews/merges to main.

## 2026-10-16 wind-down (at owner's request)
- Helper VMs wasm-x1, wasm-x2 deleted (token cannot stop, only rm). Trial dirs + logs archived to ~/archive/ on altwasm first.
- Live wasmdev service on altwasm stopped (restart: `setsid nohup scripts/serve.sh > ~/wasmdev-serve.log 2>&1 &`; data/caches kept in ~/wasmdev-data).
- No agents running.
