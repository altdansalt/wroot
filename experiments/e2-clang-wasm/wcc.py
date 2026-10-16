#!/usr/bin/env python3
"""wcc: run the YoWASP clang/lld WASI module directly under the wasmtime CLI.

WASI preview1 has no process spawning, so the clang *driver* cannot launch
cc1/wasm-ld itself. Like YoWASP's JS runClang(), we ask the driver for its job
list with `-###`, then run each job as a separate wasmtime invocation of the
same multicall module (argv[1] selects the tool: clang, clang++, wasm-ld, ar,
nm, objdump, ...).

Usage:  wcc.py clang   [clang args...]
        wcc.py clang++ [clang args...]
        wcc.py wasm-ld|ar|nm|... [args...]     (passed straight through)

Paths given to the tools must be relative to the current directory, which is
mounted as guest "/". The sysroot is mounted at guest /usr, a scratch dir at
/tmp. Env: WCC_MODULE (llvm.cwasm or llvm.wasm), WCC_USR (sysroot dir),
WCC_WASMTIME (wasmtime binary), WCC_VERBOSE=1 to echo jobs.
"""
import os, re, shlex, subprocess, sys, tempfile

HOME = os.path.expanduser("~")
MODULE = os.environ.get("WCC_MODULE", f"{HOME}/e2/yowasp/llvm.cwasm")
USR = os.environ.get("WCC_USR", f"{HOME}/e2/yowasp/usr")
WASMTIME = os.environ.get("WCC_WASMTIME", f"{HOME}/.wasmtime/bin/wasmtime")
VERBOSE = os.environ.get("WCC_VERBOSE") == "1"
# For wasm32-wasip2 the driver wants `wasm-component-ld` (a native Rust tool).
# We emulate it fully in WASM: wasm-ld (core module) + wasm-tools.wasm
# `component new` with the wasip1->p2 command adapter.
WASM_TOOLS = os.environ.get("WCC_WASM_TOOLS", f"{HOME}/e2/tools/wasm-tools.wasm")
ADAPTER = os.environ.get("WCC_ADAPTER", f"{HOME}/e2/tools/wasi_snapshot_preview1.command.wasm")


def wasmtime_cmd(tmpdir, tool_argv):
    cmd = [WASMTIME, "run"]
    if MODULE.endswith(".cwasm"):
        cmd.append("--allow-precompiled")
    cmd += ["--dir", ".::/", "--dir", f"{USR}::/usr", "--dir", f"{tmpdir}::/tmp",
            "--env", "TMPDIR=/tmp", MODULE] + tool_argv
    return cmd


def run_tool(tmpdir, argv, **kw):
    if VERBOSE:
        print("+ " + shlex.join(argv), file=sys.stderr)
    return subprocess.run(wasmtime_cmd(tmpdir, argv), **kw)


def parse_jobs(out):
    jobs = []
    for line in out.splitlines():
        if line.startswith(' "'):
            # driver prints each arg double-quoted with \ escapes for " \ $
            args = [re.sub(r'\\(["\\$])', r"\1", m) for m in
                    re.findall(r'"((?:[^"\\]|\\.)*)"', line)]
            if args and args[0] == "":
                args = args[1:]          # in-process cc1: leading "" = argv0
            jobs.append(args)
    return jobs


def component_ld(tmpdir, args):
    # drop --wasm-ld-path X, redirect -o to a core module in /tmp
    a, out, i = [], "a.out", 0
    while i < len(args):
        if args[i] == "--wasm-ld-path":
            i += 2; continue
        if args[i] == "-o":
            out = args[i + 1]; i += 2; continue
        a.append(args[i]); i += 1
    rc = run_tool(tmpdir, ["wasm-ld"] + a + ["-o", "/tmp/core.wasm"]).returncode
    if rc:
        return rc
    cmd = [WASMTIME, "run"]
    if WASM_TOOLS.endswith(".cwasm"):
        cmd.append("--allow-precompiled")
    cmd += ["--dir", ".::/", "--dir", f"{tmpdir}::/tmp",
            "--dir", f"{os.path.dirname(ADAPTER)}::/adapter", WASM_TOOLS,
            "component", "new", "/tmp/core.wasm", "-o", out]
    # wasip2 libc imports wasi:* directly; only adapt if p1 imports remain
    # (adding the command adapter unconditionally makes wit-component panic
    # on a duplicate wasi:cli/run export).
    with open(os.path.join(tmpdir, "core.wasm"), "rb") as f:
        if b"wasi_snapshot_preview1" in f.read():
            cmd += ["--adapt", "wasi_snapshot_preview1=/adapter/" + os.path.basename(ADAPTER)]
    if VERBOSE:
        print("+ wasm-tools " + shlex.join(cmd[cmd.index("component"):]), file=sys.stderr)
    return subprocess.run(cmd).returncode


def main():
    if len(sys.argv) < 2:
        print(__doc__); return 2
    tool, args = sys.argv[1], sys.argv[2:]
    with tempfile.TemporaryDirectory(prefix="wcc-") as tmpdir:
        if tool not in ("clang", "clang++") or any(
                a in ("-###", "--version", "-help", "--help") for a in args):
            return run_tool(tmpdir, [tool] + args).returncode
        p = run_tool(tmpdir, [tool, "-###"] + args, capture_output=True, text=True)
        if p.returncode != 0:
            sys.stderr.write(p.stdout + p.stderr); return p.returncode
        out = p.stdout + p.stderr
        if "-v" in args:
            sys.stderr.write(out)
        for job in parse_jobs(out):
            if job[0] == "wasm-component-ld":
                rc = component_ld(tmpdir, job[1:])
            else:
                rc = run_tool(tmpdir, job).returncode
            if rc != 0:
                return rc
    return 0


if __name__ == "__main__":
    sys.exit(main())
