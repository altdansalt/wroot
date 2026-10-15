# T2 wasmdev trial report

## Outcome

Completed. C sources are `server.c`, `parser.c`, and `parser.h`; C unit tests are `parser_test.c`. All compilation and C execution used wasmdev. Network tests ran from this VM using bash and curl against the remote service through the exe.dev HTTPS proxy. No local compiler, interpreter, or Wasm runtime was used for the project.

**Service left running:** https://altwasm.exe.xyz:8100/

- Workspace: `w8ff51df7f08b`
- Service: `s13-507d7a`
- Component: `server.wasm` (wasm32-wasip2)
- The service requires the exe.dev proxy authorization header described below.
- The API returned `http://altwasm.exe.xyz:8100/`; the tested proxy URL is the HTTPS equivalent.

Implemented PUT/GET/DELETE `/kv/<key>`, GET `/kv`, and GET `/healthz`. PUT returns 201 on creation and 200 on replacement; DELETE returns 204 or 404. Values are binary-safe, including empty values and exactly 1,048,576 bytes. The key list is JSON. Keys accept 1–255 ASCII letters, digits, `-`, `_`, `.`, and `~`; other keys receive 400. Missing keys receive 404. The parser bounds headers to 16 KiB and rejects conflicting framing, invalid Content-Length, missing/duplicate Host, and oversized bodies. Transfer-Encoding and Expect are deliberately rejected (501/417); clients should send Content-Length and disable curl's automatic Expect for large uploads.

Keep-alive and buffered pipelined requests are implemented. The curl test confirms reuse of the client-to-proxy connection; it does not independently prove reuse of a particular upstream proxy-to-service socket. The server serves one connection at a time, as permitted by the sequential-connections requirement. An idle keep-alive client can block other clients; there is no idle timeout, concurrent connection handling, persistence, eviction, or total-store memory quota. Data lasts only for the service process lifetime.

## Reproduction and proof

`api.sh` reads tokens from their configured files and supplies both authorization headers without printing their values. It expands `$WASMDEV_URL` at invocation. Exact API requests used:

```bash
# Discovery and isolated workspace creation
./api.sh /
./api.sh /v1/workspaces -X POST
# Returned workspace w8ff51df7f08b

for file in parser.h parser.c server.c parser_test.c; do
  ./api.sh "/v1/workspaces/w8ff51df7f08b/files/$file" \
    -X PUT --data-binary "@$file"
done

./api.sh /v1/workspaces/w8ff51df7f08b/run \
  -H 'Content-Type: application/json' \
  -d '{"cmd":"cc -O2 -Wall -Wextra -Werror -o parser_test.wasm parser.c parser_test.c && ./parser_test.wasm && cc --target=wasm32-wasip2 -O2 -Wall -Wextra -Werror -o server.wasm server.c parser.c","timeout_ms":120000}'

./api.sh /v1/workspaces/w8ff51df7f08b/services \
  -H 'Content-Type: application/json' -d '{"module":"server.wasm"}'
# Returned service s13-507d7a, port 8100, state starting.

./api.sh /v1/services/s13-507d7a
# state: running, error: null, exit_code: null
./api.sh /v1/services/s13-507d7a/logs
# stdout: "listening on 8100\n", stderr: ""

./api.sh /v1/workspaces/w8ff51df7f08b/run \
  -H 'Content-Type: application/json' -d '{"cmd":"./parser_test.wasm"}'

./test-network.sh https://altwasm.exe.xyz:8100

curl --http1.1 -sS \
  -H "X-Exedev-Authorization: Bearer $(cat ~/.config/wasmdev/vm_token)" \
  -H 'Connection: close' https://altwasm.exe.xyz:8100/healthz
# ok
```

Initial compilation succeeded on the first attempt with `-Wall -Wextra -Werror`, no diagnostics, exit code 0, state `exited`. `build.json` records the full API response and all compiler/link/component steps. A separate execution in `unit-rerun.json` again exited 0. Unit output:

```text
PASS: incomplete headers, framing, body limits, invalid lengths, duplicate headers, version, host, NUL, connection policy
PASS: 89 parser assertions
```

The tests include every incomplete prefix of a valid header, correct header/body boundary detection, mixed-case header names, whitespace, zero and maximum lengths, numeric overflow, negative/nonnumeric/empty lengths, duplicate Content-Length, unsupported transfer encoding, Expect, malformed HTTP versions/request lines/header names, missing/duplicate Host, embedded NUL, oversized headers, and Connection: close.

`test-network.sh` is repeatable, fails on unexpected statuses or content, uses temporary files, and cleans its test keys. It compares the 1 MiB random binary payload byte for byte. Its successful captured output (`network-output.txt`):

```text
PASS healthz
PASS JSON key list
PASS missing, create, read, overwrite, list
PASS empty value
PASS 1 MiB binary round trip (byte-for-byte)
PASS over-limit body rejected
PASS invalid key, unsupported method, unknown route
PASS keep-alive client connection reuse (200 1; 200 0; proxy may pool upstream)
PASS 25 sequential connections
PASS delete, repeated delete, list cleanup
ALL NETWORK TESTS PASSED

real	0m13.198s
user	0m7.206s
sys	0m1.586s
```

## Friction log

1. **Returned service URL did not match the documented proxy scheme.** Service creation returned `http://altwasm.exe.xyz:8100/`. The task's access instructions and exe.dev proxy documentation call for HTTPS on additional ports. I changed the scheme to HTTPS before the first network request; it worked immediately. No failed HTTP request was attempted. Time impact: less than a minute of checking documentation. Returning a directly usable HTTPS URL, or separate origin/proxy URLs, would help.
2. **My first oversized-body test declared bytes it did not send.** I used `Content-Length: 1048577` with an empty upload. Curl reported `curl: (28) Operation timed out after 20002 milliseconds with 0 bytes received`. The incomplete initial suite took 24.003 seconds. This is a test construction error, not evidence of a wasmdev defect; the authenticated proxy path may wait for the advertised body. I corrected it to upload an actual 1,048,577-byte payload, which reliably returned 413, and added startup cleanup so the suite can be repeated after partial runs. Time impact: about one minute including the timeout and correction.
3. **Readiness requires follow-up requests.** Creation returned `state: starting`; a later status query returned `running` and logs showed the listener. This worked, but the response alone did not establish application readiness. Time impact: seconds. A documented readiness wait or example polling loop would reduce client boilerplate.

No compiler, linker, component conversion, socket, authorization, or service-runtime failures were observed. No changes were made to wasmdev or other agents' workspaces/services.

## Desired capabilities, ranked

These are conveniences/visibility gaps observed during the task, not blockers:

1. Return the usable authenticated HTTPS proxy URL alongside the internal/origin URL.
2. Offer a readiness wait/health-check option and startup-duration measurement for service creation.
3. Include a minimal C WASI-p2 HTTP/socket example and a note distinguishing client proxy keep-alive from upstream connection reuse. The current API documentation was sufficient to implement the service, but a sample would reduce uncertainty.

## Observed timings

Times below are from wasmdev response fields unless explicitly identified as local wall time. Tool modules were already cached in memory.

| Operation | Observed duration |
| --- | ---: |
| Full initial build + unit run + component conversion | 3292.659 ms |
| Unit-test build (driver + two compilations + link; sum of steps) | 698.537 ms |
| First unit-test execution including cold module load | 490.309 ms |
| First unit-test module load (included above) | 489.769 ms |
| Service build including component conversion (sum of steps) | 1973.962 ms |
| Component conversion step alone | 190.207 ms |
| Cached unit-test rerun | 1.555 ms |
| Cached rerun module load (included above) | 0.00651 ms |
| Service-create HTTP call, approximate local tool wall time | 0.20 s |
| Successful complete network suite, local shell `time` | 13.198 s |

Service creation timestamp: `2026-10-15T13:55:13.382835448Z`. The first health response was dated `2026-10-15T13:55:19 GMT`, so the service was confirmed reachable roughly six seconds after creation. This includes agent time between calls and is an upper bound, not a measured time-to-listen. No precise application startup duration was returned by the API.

Raw evidence: `workspace.json`, `service.json`, `service-status.json`, `service-logs.json`, `build.json`, `timings.json`, `unit-rerun.json`, and `network-output.txt`. Final status and health are recorded separately in `final-status.json`, `final-logs.json`, and `final-health.txt`.
