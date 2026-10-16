#!/usr/bin/env python3
"""Execute a `go build -n` plan, replacing the toolchain with wasm tools under wasmtime.

Usage: runplan.py PLAN.sh --mode wasm|native --work DIR [-j N] [--reuse DIR]

The plan is split into per-action blocks (each starts with `mkdir -p $WORK/bNNN/`).
Dependencies between blocks are inferred from `$WORK/bNNN` references, and blocks
are run in parallel with N workers.

--reuse DIR: blocks whose $WORK/bNNN/_pkg_.a already exists in DIR are skipped
(warm build: std archives cached). Pass the same dir as --work.
"""
import argparse, os, re, subprocess, sys, time, concurrent.futures as cf

ap = argparse.ArgumentParser()
ap.add_argument("plan")
ap.add_argument("--mode", choices=["wasm", "native"], default="wasm")
ap.add_argument("--work", required=True)
ap.add_argument("-j", type=int, default=2)
ap.add_argument("--reuse", action="store_true")
ap.add_argument("--only", default="", help="comma-separated package import paths to run (deps must exist)")
ap.add_argument("--wtflags", default=os.environ.get("WTFLAGS", ""))
ap.add_argument("--bin", default=os.path.expanduser("~/e1/bin"))
ap.add_argument("--ext", default="cwasm")
ap.add_argument("--goroot", default=os.path.expanduser("~/e1/goroot"))
a = ap.parse_args()

TOOLDIR = os.path.join(a.goroot, "pkg/tool/linux_amd64")
lines = open(a.plan).read().split("\n")

blocks, cur, order = {}, None, []
for ln in lines:
    m = re.match(r"^mkdir -p \$WORK/(b\d+)/$", ln)
    if m:
        cur = m.group(1)
        blocks[cur] = []
        order.append(cur)
    if cur is None:
        continue
    blocks[cur].append(ln)

if a.mode == "wasm":
    root = os.path.expanduser("~/e1")
    pre = "--allow-precompiled " if a.ext == "cwasm" else ""
    prelude = f"""
wt() {{ t=$1; shift; wasmtime run {a.wtflags} {pre}--dir {root}::{root} --env PWD="$PWD" --env GOROOT={a.goroot} --env GOOS=wasip1 --env GOARCH=wasm {a.bin}/$t.{a.ext} "$@"; }}
"""
    def rewrite(ln):
        ln = re.sub(r"^GOROOT='[^']*' ", "", ln)
        ln = re.sub(re.escape(TOOLDIR) + r"/(compile|asm|link) ", r"wt \1 ", ln)
        ln = ln.replace("go tool pack ", "wt pack ")
        return ln
else:
    prelude = f"pack() {{ {a.bin}/pack-native \"$@\"; }}\n"
    def rewrite(ln):
        return ln.replace("go tool pack ", "pack ")

def script(b):
    out = [prelude, "set -e", f"export WORK={a.work} GOOS=wasip1 GOARCH=wasm GOROOT={a.goroot}"]
    for ln in blocks[b]:
        if ln.startswith("go tool buildid"):
            continue
        out.append(rewrite(ln).replace("$WORK", a.work))
    return "\n".join(out) + "\n"

deps = {}
for b in order:
    refs = set(re.findall(r"\$WORK/(b\d+)", "\n".join(blocks[b])))
    refs.discard(b)
    deps[b] = refs & set(blocks)

skip = set()
if a.reuse:
    for b in order:
        if os.path.exists(os.path.join(a.work, b, "_pkg_.a")) and b != "b001":
            skip.add(b)

def pkgname(b):
    return next((l[2:].strip() for l in blocks[b] if l.startswith("# ") and l != "# import config"), b)
if a.only:
    want = set(a.only.split(","))
    skip = {b for b in order if pkgname(b) not in want}
os.makedirs(a.work, exist_ok=True)
done, running, t0 = set(skip), {}, time.time()
timing = {}

def run(b):
    s = time.time()
    p = subprocess.run(["bash", "-s"], input=script(b), capture_output=True, text=True)
    return b, p.returncode, p.stdout + p.stderr, time.time() - s

with cf.ThreadPoolExecutor(a.j) as ex:
    pending = [b for b in order if b not in done]
    while pending or running:
        for b in list(pending):
            if len(running) >= a.j:
                break
            if deps[b] <= done:
                running[ex.submit(run, b)] = b
                pending.remove(b)
        fin, _ = cf.wait(running, return_when=cf.FIRST_COMPLETED)
        for f in fin:
            b, rc, out, dt = f.result()
            del running[f]
            name = next((l[2:] for l in blocks[b] if l.startswith("# ") and l != "# import config"), b)
            timing[b] = dt
            print(f"{time.time()-t0:7.1f}s {b} {name.strip()} {dt:.1f}s rc={rc}", flush=True)
            if rc != 0:
                print(out, file=sys.stderr)
                sys.exit(1)
            done.add(b)
print(f"TOTAL {time.time()-t0:.2f}s blocks={len(order)-len(skip)} skipped={len(skip)} mode={a.mode} j={a.j}")
