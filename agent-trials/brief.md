# Brief for agents trialing the wasmdev service

You are an autonomous coding agent. A development service called **wasmdev** builds, tests and
runs software as WebAssembly. Compilers run as WebAssembly inside the service. Your job is to
complete the task below **using only this service for all compiling, testing and running** of
your project, and to report honestly on how well the service worked for you.

## Access
- API base URL: `$WASMDEV_URL` (e.g. https://altwasm.exe.xyz:8700, or http://127.0.0.1:8700 if you run on the same VM)
- Every request needs the service token: `Authorization: Bearer $(cat ~/.config/wasmdev/api_token)`
- If the URL is `https://altwasm.exe.xyz...` you also need the exe.dev proxy token:
  `X-Exedev-Authorization: Bearer $(cat ~/.config/wasmdev/vm_token)`.
  The same proxy header is needed to reach services you start (`https://altwasm.exe.xyz:<port>/`).
- Never print or paste token values into files, logs or your final answer.
- Start by reading `GET $WASMDEV_URL/` — it documents the API.

## Rules
- Do NOT install or use local compilers/interpreters (gcc, clang, go, rustc, python for your project code, wasmtime...)
  for building or testing your project. curl, jq, tar, shell and an editor are fine. Keep your source files locally
  in your working dir and upload them to the service.
- Don't modify the service. If something is missing or broken, work around it if reasonable and record it.
- Other agents use the same service at the same time; stay in your own workspaces.

## Report
Write `REPORT.md` in your working dir:
1. Outcome: did you finish? What works (with the exact API calls that prove it)?
2. Friction log: a list of concrete problems — what you tried, what happened (error text), time lost, what would have helped.
3. Missing capabilities you wanted, ranked.
4. Timings you observed (builds, test runs, service start).
Keep it factual and specific; this report directly drives the next round of development.
