# T5 report

## Outcome

Completed the control-plane implementation, host-independent tests, and required
service-side vet/test/build. The host ABI prevents true streaming between wasm
executions; this implementation streams builtin-only pipelines without
redirections using concurrent goroutines and unbuffered `io.Pipe` connections.
Other pipelines retain sequential disk spooling. No service was modified or
deployed. All project compilation, formatting, tests and execution used wasmdev.

Delivered:

- `control/`: modified source, including `pipeline.go`, `pipeline_test.go`, and
  `PIPELINES.md` explaining the execution model and precise host extension needed.
- `control.original/`: pristine snapshot saved before edits.
- `PATCH.diff`: `diff -ruN control.original control`; additions included.
- `evidence/final.result.json`: complete passing output and step timings.
- `evidence/control.wasm`: downloaded 12 MiB build artifact.
- `evidence/source.tar` and `evidence/source.sha256`: final local source archive
  and checksums.
- `api.sh`: curl wrapper that reads tokens at invocation time without printing them.

Behavior verified by 15 passing top-level tests (plus five pipeline subtests):
parser and existing helper tests; streaming eligibility; backpressure; an
unbounded producer terminated by an early consumer after three `yes` lines;
cancellation of active stages; multistage builtin output and request stdin;
last-stage status; early-exit stages and ordered step records; large `cat`
input; broken-pipe errors; expired deadlines/killed flag handling; and rejection
of `cat` appending its input file to itself. Tests call the actual builtin
pipeline executor and generic pipe scheduler without requiring host imports.
The unbounded producer test uses an injected stage, not a new `yes` builtin.

`cat` now copies incrementally instead of reading and accumulating all inputs.
`cmp`/`diff` retain their existing whole-input algorithms. The pipeline
transport is bounded; this does not promise bounded total memory for every
builtin or bounded disk use for spooled wasm producers. Kill/deadline handling
closes internal pipes and joins stages; it does not preempt CPU-only diff work
or interrupt arbitrary borrowed input/output readers.

### Exact API proof

Workspace: `wa19b5398c57b`. Final job: `j22-0fa788`.
`WASMDEV_URL` is used unchanged. Tokens are read only by `api.sh`.

```sh
# API discovery (saved as evidence/api.md):
./api.sh "$WASMDEV_URL/"

# Isolated workspace (response saved as evidence/workspace.json):
./api.sh -X POST "$WASMDEV_URL/v1/workspaces"

# Source upload, using the workspace returned above:
tar -cf evidence/source.tar -C control .
./api.sh -X POST -H 'Content-Type: application/x-tar' \
  --data-binary @evidence/source.tar \
  "$WASMDEV_URL/v1/workspaces/wa19b5398c57b/files"

# Exact final verification request (evidence/check.request.json):
# {"cmd":"go vet ./... && go test -v ./... && go build -o control.wasm .",
#  "timeout_ms":600000}
./api.sh -X POST -H 'Content-Type: application/json' \
  --data-binary @evidence/check.request.json \
  "$WASMDEV_URL/v1/workspaces/wa19b5398c57b/run?async=1"
# {"job_id":"j22-0fa788","state":"running"}

./api.sh --max-time 55 "$WASMDEV_URL/v1/jobs/j22-0fa788?wait=1"
# Saved verbatim as evidence/final.result.json:
# done=true, state="exited", exit_code=0, error=null, stderr=""
# stdout ends: PASS\nok  \twasmdev/control\t0.665s\n
# Every step (go vet, go test -v, go build) exited 0.

./api.sh "$WASMDEV_URL/v1/workspaces/wa19b5398c57b/files/control.wasm" \
  -o evidence/control.wasm
```

Formatting was also done through `POST .../run` with
`{"cmd":"go fmt ./...","timeout_ms":600000}`; responses are saved in
`evidence/format.result.json` and `evidence/format.final.json`. Formatted changed
files were fetched with `GET .../files/{filename}`. Two unrelated snapshot
formatting changes were restored locally/remotely before final verification.
The archive above is regenerated from the final files, including that restoration.

## Friction log

1. **Host stdio cannot represent pipes.** Inspection of `ExecSpec`, `step`, and
   `host_wasip1.go` found only path-based stdin/stdout/stderr and
   start/status/kill/release/ready operations. There was no runtime error: the
   missing capability is in the ABI itself. Concurrent regular-file readers
   cannot distinguish temporary EOF from completion. Approximately one minute
   of initial investigation/design; the resulting scope limitation remains.
   Documented endpoint-based pipe capabilities would enable the full feature.
2. **Builtin `cat` amplified buffering.** It previously used `os.ReadFile` and
   a combined `bytes.Buffer`, even though pipeline intermediates were already
   disk-backed. Replaced this with incremental copying. Found by source review,
   not an API failure. Incremental copying also needs self-append detection;
   added a test and explicit diagnostic: `cat: input and output are the same file`.
3. **Whole-package formatting touches unrelated files.** `go fmt ./...` also
   reported `main.go` and `tools.go`, which already had formatting differences
   in the snapshot. Restored both to avoid unrelated patch changes. Roughly
   seconds of cleanup; targeted formatting would have avoided this.
4. **Test linkage requires care.** The source explicitly warns that reaching
   host execution functions causes custom wasm imports to become required in
   ordinary test binaries. Kept the pipe scheduler and builtin executor testable
   independently of `runSimple`/host execution. No import-instantiation failures
   occurred during this task. A host test harness would permit deeper tests of
   mixed pipelines, redirections, trap handling and multiple host executions.

No API requests failed, and no vet, test or build errors occurred. No local
compiler/interpreter was installed or used. The existing API's async job and
per-step timing responses worked well.

## Missing capabilities, ranked

1. **Host-owned bounded pipes with explicit endpoint lifetimes**, usable in
   ExecSpec by both wasip1 and wasip2, with backpressure, EOF and broken-pipe
   semantics. Also pollable host read/write operations for builtin integration.
   `control/PIPELINES.md` specifies ownership, startup and cancellation details.
2. **Host harness for the control plane** to test real exec imports, traps,
   cancellation and descriptor routing without deploying the service snapshot.
3. **Completion/readiness notifications** instead of repeated host-status polls.
   This is also noted by the existing `waitDone` TODO.

## Observed timings

Host-reported `wall_ms`; these include the registered Go tool invocation rather
than just compiler CPU time. Tools were already memory-cached/Cranelift, so
these are not cold toolchain timings.

| Operation | First verification | Final verification |
|---|---:|---:|
| `go vet ./...` | 843.581 ms | 797.886 ms |
| `go test -v ./...` | 3898.752 ms | 4204.348 ms |
| `go build -o control.wasm .` | 3229.446 ms | 3359.333 ms |
| Entire three-step request | 7985.960 ms | 8380.370 ms |

Test package reported 0.665 s in both verification runs. First formatting run:
336.040 ms tool / 347.899 ms overall. Service startup: not measured; the task
provides a nondeployable snapshot and no service was started. Compilation and
unit tests prove the changes in the snapshot, not deployment of the live API.
