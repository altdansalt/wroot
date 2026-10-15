# wasmdev trial T1 report

## Outcome

Completed. Implemented a multi-source C library, static archive, stdin CLI, C unit program,
and fixture-based end-to-end runner targeting wasm32-wasip1. All compilation, linking,
and execution of project C code took place through wasmdev. Local shell/curl/jq/tar handled
transport and diff compared returned output. No local compiler or project interpreter was used.

Final verification: **1,074 unit checks passed**, and **five CLI tests passed**: ordinary data,
quoted commas/escaped quotes/embedded CRLF, ragged rows/empty fields, empty input, and malformed
CSV. Unit checks also cover large fields, final records without newline, blank rows, bare CR,
callback failure, NUL rejection, numeric filtering, mean/min/max, extreme numeric values,
and distinct counts at 1000, repeated values at the cap, and overflow at 1001.

Deliverables: `include/csvstat.h`, `src/{parser,stats,main}.c`, `tests/unit.c`, fixtures and expected
files, `build.json`, `test.sh`, `service.sh`, README, and service-built artifacts in `artifacts/`.
Semantics and limitations are documented in README.md. Retained remote workspace: `wa8c26d33b26b`.
No long-running service was needed or started.

### Exact API calls proving the result

`service.sh` is a curl wrapper that adds the required bearer headers without printing tokens.
All calls below use the environment's WASMDEV_URL. The build command and flags are preserved
verbatim in `build.json`; full per-step API results are in `logs/build.json`.

```sh
# API discovery and isolated workspace creation:
./service.sh "$WASMDEV_URL/"
./service.sh -X POST "$WASMDEV_URL/v1/workspaces"
# Creation returned {"id":"wa8c26d33b26b","mount":"/work"}.

# Upload (as performed by test.sh):
tar -cf upload.tar include src tests
./service.sh -X POST -H 'Content-Type: application/x-tar' \
  --data-binary @upload.tar \
  "$WASMDEV_URL/v1/workspaces/wa8c26d33b26b/files"

# Build archive, CLI, unit program, and execute unit program:
./service.sh -H 'Content-Type: application/json' --data-binary @build.json \
  "$WASMDEV_URL/v1/workspaces/wa8c26d33b26b/run"
# state=exited, exit_code=0, stdout="PASS: 1074 unit checks\n"

# CLI invocation for each fixture; test.sh compares stdout to its expected file:
for fixture in basic quoted ragged empty invalid; do
  jq -n --rawfile input "tests/fixtures/$fixture.csv" \
    '{module:"csvstat.wasm",stdin:$input}' > request.json
  ./service.sh -H 'Content-Type: application/json' --data-binary @request.json \
    "$WASMDEV_URL/v1/workspaces/wa8c26d33b26b/run"
done
```

`logs/{basic,quoted,ragged,empty}.json` show state=exited and exit_code=0. Each stdout
matches the corresponding expected file byte-for-byte. `logs/invalid.json` shows state=exited,
exit_code=1, empty stdout, and `csvstat: unterminated quoted field` on stderr.
Run `./test.sh` to reproduce the entire upload/build/test/compare sequence.

## Friction log

1. **My upload omission:** initially uploaded `tests/fixtures` but omitted `tests/unit.c`.
   Compiler returned `clang: error: no such file or directory: 'tests/unit.c'` after building
   the library and CLI. Corrected tar input to include all of `tests`. Roughly 20 seconds
   lost, including inspection; not a service defect. Evidence: `logs/first-build-missing-upload.json`.
2. **WASI temporary-file limitation:** unit tests initially used `tmpfile()` and compilation
   with -Werror failed: `'tmpfile' is deprecated: tmpfile is not defined on WASI`.
   Replaced it with fopen of a scratch path in this isolated workspace and explicit removal.
   Roughly 30 seconds lost. A brief documented libc compatibility note would have helped.
   Evidence: `logs/tmpfile-unsupported.json`.
3. **Long-double formatting requires an extra library:** the unit tests passed but the first CLI
   execution trapped in `long_double_not_supported`, state=failed, exit_code=null. Stderr:
   `Support for formatting long double values is currently disabled.` followed by
   `To enable it, add -lc-printscan-long-double to the link command.` Added exactly that link flag;
   rebuilt and all tests passed. Roughly 25 seconds lost. The runtime error was actionable;
   documenting this flag in the C quickstart would avoid the trap. Evidence: `logs/long-double-trap.json`.
4. **No pipes or redirection in cmd:** this is explicitly documented, so I did not attempt
   unsupported syntax. Used the API stdin field for CLI input and compared returned stdout
   with local diff. No blocked work; a small amount of harness glue was necessary.

Time-lost figures above are approximate human-observed interaction time, not instrumented timings.
No service modification, tool installation, or access to another workspace was required.

## Missing capabilities wanted, ranked

1. A C/WASI compatibility quick reference covering unsupported libc routines and optional
   printf/scanf libraries. These caused the two substantive build/runtime iterations.
2. A run API option for stdin from a workspace file, plus output-to-file support or a documented
   fixture-test recipe. Current JSON stdin is sufficient for this task but requires transport glue.
3. Build-output artifact manifest or convenience download bundle. Individual GET file calls worked
   for `csvstat.wasm`, `unit.wasm`, and `libcsvstat.a`.

None of these prevented completion. Per-step diagnostics and timings were useful.

## Observed timings

Timings below are API-reported wall_ms, not total curl/network elapsed time. Final run used
already cached compiler modules. Other users share the service, so these are observations only.

| Operation | Time |
| --- | ---: |
| First incomplete build, stopping at missing unit source | 1,609.086 ms |
| Build attempt stopped by tmpfile compilation diagnostics | 2,302.024 ms |
| Final complete build plus unit execution | 3,210.232 ms |
| Final parser compilation backend step | 398.353 ms |
| Final stats compilation backend step | 596.155 ms |
| Archive creation | 5.806 ms |
| CLI link step | 101.469 ms |
| Unit compilation backend step | 1,316.890 ms |
| Unit link step | 116.778 ms |
| Unit execution step, warm module | 10.533 ms |
| First successful CLI invocation, cache=compiled | 1,099.790 ms |
| That invocation's reported module load | 816.525 ms |
| Warm quoted / ragged / empty CLI requests | 2.051 / 1.827 / 1.936 ms |
| Warm invalid-input CLI request | 83.096 ms |

Workspace creation curl call took approximately 0.407 seconds as observed by the command tool.
Service start timing: not applicable; this is a stdin CLI task. No HTTP server was started.
