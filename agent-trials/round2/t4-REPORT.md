# T4 report

## Outcome

Completed. The stdlib-only Go URL shortener is running and was left running:

**https://altwasm.exe.xyz:8100/**

Workspace: `wca98b78141e9`; service: `s9-8d2a7c`.
The public proxy requires the exe.dev proxy authorization header described in TASK.md.

Implemented POST /api/links, GET /<code> (302), GET /api/links/<code> (URL, code, hits, created UTC timestamp), and GET /healthz. HTTP(S) URLs require a host and reject credentials, whitespace, malformed URLs, and unsupported schemes. JSON bodies are limited to 8 KiB and must contain exactly one object with known fields. Mutex-protected monotonic base-36 IDs cannot collide within this service instance; exhaustion returns 503. Creation and hit updates are protected under concurrent requests. Storage is in memory: restarting loses links and resets IDs. IDs are predictable, not secrets. PUBLIC_SCHEME=https accounts for TLS termination at the proxy without trusting forwarded headers.

All compilation, formatting, vetting, and Go tests ran through wasmdev. Local execution was limited to shell/curl/jq and file operations. Local sources match the formatted remote sources.

### Reproducible proof

The helper `api.sh` reads authorization tokens from their configured files without printing them. Exact successful build request:

```bash
./api.sh -X POST -H 'Content-Type: application/json' \
  -d '{"cmd":"go fmt ./... && go vet ./... && go test -v ./... && go build -o srv.wasm .","timeout_ms":240000}' \
  "$WASMDEV_URL/v1/workspaces/wca98b78141e9/run?async=1"
./api.sh "$WASMDEV_URL/v1/jobs/j8-be9b8c?wait=1"
```

Job exited 0; every step exited 0. Table-driven validation and handler tests, concurrent creation/hit tests, and exhaustion test all passed. Full evidence: `build-result.json`.

Exact service start:

```bash
./api.sh -X POST -H 'Content-Type: application/json' \
  -d '{"module":"srv.wasm","env":{"PUBLIC_SCHEME":"https"},"wait_ready":true,"ready_timeout_ms":30000}' \
  "$WASMDEV_URL/v1/workspaces/wca98b78141e9/services"
```

Returned ready=true, state=running. See `service.json`.

Network verification from this machine:

```bash
./network-test.sh https://altwasm.exe.xyz:8100/
./api.sh "$WASMDEV_URL/v1/services/s9-8d2a7c"
```

The script contains the exact curl calls and assertions. It verified health, 201 creation with the correct public short_url, 302 and exact Location, stats with created and one hit, 20 concurrent network requests followed by exactly 21 total hits, invalid URL rejection (400), and unknown code (404). Output: `network-result.txt`. Final API status: running, ready=true, error=null (`service-final.json`). No redirect destination was fetched.

## Friction log

- First vet attempt caught my unused test import: `vet: ./main_test.go:6:2: "net/http" imported and not used`. The chained command correctly stopped before testing/building. Removed the import and reran successfully. Initial failed job took 1.870 s; correction and resubmission cost roughly a minute including implementation cleanup. This was an agent source mistake, not a service fault.
- The preopened-listener requirement differs from ordinary Go net.Listen. The API documentation provided a working net.FileListener pattern, which worked on the first service start. No additional time lost debugging it.
- TLS terminates outside the Go process. An explicit PUBLIC_SCHEME setting was needed to produce HTTPS short URLs; otherwise request TLS state would imply HTTP. Handled before the first network test, roughly a minute of implementation consideration. A documented public-origin environment variable would simplify this.
- No service errors, traps, timeouts, or failed network assertions were observed.

## Missing capabilities wanted, ranked

1. Race-detector / threaded Go execution for stronger concurrency verification. The documented wasm execution uses GOMAXPROCS=1 and no threads; goroutine and network concurrency tests passed, but do not establish race-detector coverage. No race run was attempted.
2. A documented public-origin environment variable for services, making absolute URLs straightforward behind the HTTPS proxy.
3. Durable service storage/lifecycle guidance for applications that must survive restarts. Not required for this in-memory task and not tested.

## Observed timings

From service-reported wall times, with shared compiler cache already warm:

| Operation | Time |
| --- | ---: |
| Initial vet, failed unused import | 1.867 s |
| Successful go fmt ./... | 0.187 s |
| Successful go vet ./... | 0.638 s |
| go test -v ./... (including build/run) | 2.540 s |
| Test package reported runtime | 0.844 s |
| go build -o srv.wasm . | 1.320 s |
| Successful combined job | 4.711 s |
| Service start to ready | 1.059 s |
| Network script plus final status query, local command wall time | 0.692 s |

Timings are observations from this run, not cold-cache benchmarks.
