package main

import (
	"bytes"
	"fmt"
	"os"
	"regexp"
	"strings"
)

// clang driver: WASI has no process spawning, so the clang driver (which
// runs in-process cc1 fine, but must spawn wasm-ld / wasm-component-ld)
// can't complete a compile+link on its own. Like YoWASP's JS runClang and
// our e2 wcc.py, we ask the driver for its job list with -### and run
// each job as a separate wasm execution of the same multicall module,
// sharing one scratch dir (/tmp) for intermediate objects.
//
// wasm-component-ld (wasip2 link) is a native Rust tool upstream; we
// emulate it in wasm: wasm-ld -> core module, then the componentizer tool
// (wasm-tools.wasm) `component new`.

// clangConf is the "clang" section of a tool manifest: sysroot-specific
// knowledge kept as data.
type clangConf struct {
	// Tool used to turn a core module into a component (wasip2).
	Componentizer string `json:"componentizer,omitempty"` // e.g. "wasm-tools"
	// Guest path (inside the componentizer's mounts) of the wasip1->p2
	// command adapter; only used if the core module still imports
	// wasi_snapshot_preview1.
	Adapter string `json:"adapter,omitempty"`
	// Extra flags for C++ on wasip1 unless -fno-exceptions is given
	// (YoWASP's own libc++ has no EH; the wasi-sdk EH libc++ needs the
	// standardized exnref encoding, the only one wasmtime accepts).
	CxxCompileFlags []string `json:"cxx_compile_flags,omitempty"`
	CxxLinkFlags    []string `json:"cxx_link_flags,omitempty"`
	// Stack size (bytes) of linked programs unless the user sets one
	// (-Wl,-z,stack-size=N / -z stack-size=N). wasm-ld's default is 64 KiB,
	// whose overflow shows up as a confusing out-of-bounds fault.
	DefaultStackSize int64 `json:"default_stack_size,omitempty"`
}

// hasStackSize reports whether the link args already set the stack size.
func hasStackSize(args []string) bool {
	for _, a := range args {
		if strings.Contains(a, "stack-size") {
			return true
		}
	}
	return false
}

// Flags after which clang only compiles (no link job).
var noLinkFlags = map[string]bool{"-c": true, "-S": true, "-E": true, "-fsyntax-only": true,
	"-M": true, "-MM": true, "--precompile": true}

// Invocations that don't compile anything: run the driver directly.
var passthroughFlags = map[string]bool{"-###": true, "--version": true, "-help": true, "--help": true,
	"-dumpversion": true, "-dumpmachine": true, "-print-targets": true, "--print-targets": true}

var jobArgRe = regexp.MustCompile(`"((?:[^"\\]|\\.)*)"`)
var unescapeRe = regexp.MustCompile(`\\(["\\$])`)

// parseJobs extracts the job lines of `clang -###` output; other lines
// (banner, diagnostics) are returned separately.
func parseJobs(out string) (jobs [][]string, other []string) {
	for _, line := range strings.Split(out, "\n") {
		if !strings.HasPrefix(line, ` "`) {
			if line != "" {
				other = append(other, line)
			}
			continue
		}
		var args []string
		for _, m := range jobArgRe.FindAllStringSubmatch(line, -1) {
			args = append(args, unescapeRe.ReplaceAllString(m[1], "$1"))
		}
		if len(args) > 0 && args[0] == "" {
			args = args[1:] // in-process cc1: leading "" is argv0
		}
		if len(args) > 0 {
			jobs = append(jobs, args)
		}
	}
	return jobs, other
}

var bannerPrefixes = []string{"clang version ", "Target: ", "Thread model: ", "InstalledDir: ", "Build config: "}

func isBanner(line string) bool {
	for _, p := range bannerPrefixes {
		if strings.HasPrefix(line, p) {
			return true
		}
	}
	return false
}

func clangDriver(rc *runCtx, t *toolManifest, prog string, args []string, scratch string) error {
	ws := rc.j.Workspace
	run := func(argv []string, capture bool) (*stepResult, string, string, error) {
		spec, err := rc.s.toolSpec(ws, rc.req, t, argv, scratch)
		if err != nil {
			return nil, "", "", err
		}
		return rc.step(spec, capture)
	}
	if (prog != "clang" && prog != "clang++") || len(args) == 0 {
		_, _, _, err := run(append([]string{prog}, args...), false)
		return err
	}
	link, verbose, target, noExc := true, false, "", false
	for i, a := range args {
		switch {
		case passthroughFlags[a] || strings.HasPrefix(a, "-print-") || strings.HasPrefix(a, "--print-"):
			_, _, _, err := run(append([]string{prog}, args...), false)
			return err
		case noLinkFlags[a]:
			link = false
		case a == "-v":
			verbose = true
		case a == "-fno-exceptions":
			noExc = true
		case strings.HasPrefix(a, "--target="):
			target = a[len("--target="):]
		case a == "-target" && i+1 < len(args):
			target = args[i+1]
		}
	}
	wasip2 := strings.Contains(target, "wasip2")
	conf := t.Clang
	if conf == nil {
		conf = &clangConf{}
	}
	if prog == "clang++" && !wasip2 && !noExc {
		extra := append([]string{}, conf.CxxCompileFlags...)
		args = append(extra, args...)
		if link {
			args = append(args, conf.CxxLinkFlags...)
		}
	}
	if link && conf.DefaultStackSize > 0 && !hasStackSize(args) {
		args = append(args, fmt.Sprintf("-Wl,-z,stack-size=%d", conf.DefaultStackSize))
	}

	sr, out, errOut, err := run(append([]string{prog, "-###"}, args...), true)
	if err != nil {
		return err
	}
	jobs, other := parseJobs(out + errOut)
	var diag strings.Builder
	for _, l := range other {
		if verbose || !isBanner(l) {
			diag.WriteString(l + "\n")
		}
	}
	rc.stderr(diag.String())
	if sr.ExitCode == nil || *sr.ExitCode != 0 {
		return nil // rc.fail is set; the driver's error is in stderr
	}
	for _, job := range jobs {
		if verbose {
			rc.stderr(" " + strings.Join(job, " ") + "\n")
		}
		if job[0] == "wasm-component-ld" {
			if err := componentLd(rc, t, conf, job[1:], scratch, run); err != nil || rc.fail != nil {
				return err
			}
			continue
		}
		if _, _, _, err := run(job, false); err != nil || rc.fail != nil {
			return err
		}
	}
	return nil
}

// componentLd emulates wasm-component-ld: wasm-ld to a core module in the
// scratch dir, then `wasm-tools component new`.
func componentLd(rc *runCtx, t *toolManifest, conf *clangConf, args []string, scratch string,
	run func([]string, bool) (*stepResult, string, string, error)) error {
	ld := []string{"wasm-ld"}
	out := "a.out"
	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "--wasm-ld-path":
			i++
		case "-o":
			if i+1 < len(args) {
				out = args[i+1]
				i++
			}
		default:
			ld = append(ld, args[i])
		}
	}
	tmpGuest := t.Scratch
	core := tmpGuest + "/wasmdev-core.wasm"
	if _, _, _, err := run(append(ld, "-o", core), false); err != nil || rc.fail != nil {
		return err
	}
	ct := rc.s.tools.tool(conf.Componentizer)
	if ct == nil {
		rc.stderr("wasmdev: wasip2 link needs the componentizer tool \"" + conf.Componentizer + "\" (not registered)\n")
		rc.fail = &stepResult{State: "exited", ExitCode: intp(1)}
		return nil
	}
	argv := []string{"component", "new", core, "-o", out}
	// wasip2 libc imports wasi:* directly; only adapt if p1 imports
	// remain (adapting unconditionally makes wit-component fail on a
	// duplicate wasi:cli/run export).
	if b, err := os.ReadFile(scratch + "/wasmdev-core.wasm"); err == nil &&
		bytes.Contains(b, []byte("wasi_snapshot_preview1")) && conf.Adapter != "" {
		argv = append(argv, "--adapt", "wasi_snapshot_preview1="+conf.Adapter)
	}
	spec, err := rc.s.toolSpec(rc.j.Workspace, rc.req, ct, argv, scratch)
	if err != nil {
		return err
	}
	// the core module lives in the clang tool's scratch dir
	if ct.Scratch == "" {
		spec.Dirs = append(spec.Dirs, Mount{Host: scratch, Guest: tmpGuest})
	}
	_, _, _, err = rc.step(spec, false)
	return err
}
