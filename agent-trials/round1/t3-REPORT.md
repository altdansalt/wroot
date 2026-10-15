# T3 report — expression-language interpreter in C++17 (wasmdev)

## 1. Outcome
Finished. Language: ints, floats, strings, bools, nil, lists, variables, `if/else if/else`, `while`/`break`/`continue`,
named and anonymous functions, recursion, mutual recursion (hoisted `fn`), closures with shared mutable captures,
`&& ||` short-circuit, builtins (print len str int float sqrt floor substr push type), runtime errors with line numbers (exit 1).
Source: `src/interp.cpp` (~330 lines). Tests: `tests/*.txt` + `.out` (20 programs, 2 of them expected-error, one deep-recursion).
Runner: `runtests.sh` (bash + curl; each test is one `run` call on the service).

Proof (all through the service, result `passed=20 failed=0`):
- `PUT /v1/workspaces/$WS/files/interp.cpp`
- `POST /v1/workspaces/$WS/run {"cmd":"c++ -std=c++17 -O2 -Wall -Wl,-z,stack-size=4194304 -o run.wasm interp.cpp"}` -> exit 0, no warnings
- `POST /v1/workspaces/$WS/files` (tar of tests) then, per test, `POST .../run {"cmd":"./run.wasm 07_fact.txt"}`

C++17 (exceptions, std::function, shared_ptr, iostream) worked fine; no need to fall back to C.

## 2. Friction log
1. **Compile time is slow**: 30–68 s per build of a single 330-line C++ file (33 s, 40 s, 29 s, 44 s, 49 s, 68 s; varies with load/-O level, other agents share the host). About 8 builds => ~5 min of waiting. No incremental build / no way to see progress. Would help: faster/warm compiler, `-O1` guidance, ccache-like object cache, or precompiled headers for libc++ (`<iostream>`, `<map>`, `<functional>` dominate).
2. **Host call-stack limit is far below what linear-memory stack allows**: deep recursion in the interpreter trapped with `wasm trap: call stack exhausted` at roughly 350 interpreted call levels (sum(300) OK, sum(400) trapped; ~7 wasm frames per interpreted call). Raising `-Wl,-z,stack-size=` did not help (this limit is wasmtime's `max_wasm_stack`, not the linear stack). Workaround: interpreter-level depth limit of 300 and test depth 200. Would help: documented limit, and/or a run option (`max_stack_kb`) to raise it. Not documented in the API root.
3. **Default linear-memory stack is only 64KB**: without `-Wl,-z,stack-size=...` the program faults with `memory fault at wasm address 0xffffff60 ... out of bounds memory access` (stack overflow wraps below 0). Confusing error; I lost 2 builds (~1.5 min) by forgetting the flag when I changed other flags. Would help: bigger default stack (e.g. 1–8MB) in the toolchain, or a hint in the error.
4. **stdout is lost on a trap**: when the guest traps, `stdout` was empty even though earlier `print` output (buffered in C++ `cout`, not flushed) had been produced. Output that was flushed would presumably show; unflushed libc buffers are lost, which is expected, but a note in docs would help.
5. `exit_code` is `null` when state is `failed` (jq `-r` prints "null") — fine, but runners have to special-case it.
6. `wall_ms` for first run of a new module was 2418 ms (cache/JIT compile of the 1–2 MB wasm), later runs 1–3 ms. Fine, but notable.
7. Test runner limits: `cmd` has no pipes/redirection/loops, and wasip1 can't spawn processes, so a test runner cannot run inside the service; I drove it from local bash with one HTTP call per test. A `run` that accepts several commands/stdin files, or a batch endpoint, would cut round trips.
8. Minor: first `PUT file` response is `{"path": ...}` and curl prints it unless `-o /dev/null`; nothing wrong.

## 3. Missing capabilities (ranked)
1. Faster C++ compile (warm compiler / PCH / object cache).
2. Configurable wasm stack limit (or documented value) for `run`.
3. Larger default linker stack-size.
4. A batch/test-runner endpoint (run N commands, each with its own stdin/expected output) to avoid per-test HTTP overhead.
5. Surface trap type more clearly in `state`/`error` (e.g. `stack_overflow`) and keep partial stdout.

## 4. Timings
- Compile (c++ -std=c++17, 1 file ~330 lines, -O2/-O1): 29–68 s (typ. ~40 s).
- First execution of fresh run.wasm: ~2.4 s (module precompile); subsequent executions: 1.6–5 ms; fib(20) tree recursion 297 ms (first), 82 ms for a loop test on cold cache hit.
- Full 20-test suite: ~4.9 s wall locally (incl. upload + 20 HTTP calls, one cold start).
- Workspace creation, file upload: sub-second.
