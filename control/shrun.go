package main

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"
)

// ---- executing a parsed command line (see sh.go) ----

// runList runs pipelines joined by && || ; with sh semantics; the job's
// exit status is that of the last pipeline that ran. A step that does not
// exit normally (trap, timeout, kill) stops everything.
func (rc *runCtx) runList(l *cmdList) error {
	status := 0
	for i, pl := range l.Pipes {
		if i > 0 {
			switch l.Ops[i-1] {
			case "&&":
				if status != 0 {
					continue
				}
			case "||":
				if status == 0 {
					continue
				}
			}
		}
		st, err := rc.runPipeline(pl, i)
		rc.status = st
		if err != nil {
			return err
		}
		status = st
	}
	return nil
}

// runPipeline runs a | b | c buffered: each stage's stdout goes to a
// temp file that is the next stage's stdin. Status = last stage's.
func (rc *runCtx) runPipeline(pl pipeline, idx int) (int, error) {
	prev := ""
	status := 0
	for k, c := range pl.Cmds {
		io := cmdIO{stdin: prev}
		var pipe string
		if k < len(pl.Cmds)-1 {
			pipe = fmt.Sprintf("%s/pipe%d-%d", rc.j.dir, idx, k)
			if err := os.WriteFile(pipe, nil, 0o644); err != nil {
				return 1, err
			}
			io.stdout = pipe
		}
		st, err := rc.runSimple(c, io)
		if prev != "" {
			os.Remove(prev)
		}
		if err != nil {
			if pipe != "" {
				os.Remove(pipe)
			}
			return st, err
		}
		status, prev = st, pipe
	}
	return status, nil
}

// runSimple runs one command with its redirections; returns its exit status.
func (rc *runCtx) runSimple(c simpleCmd, io cmdIO) (int, error) {
	ws := rc.j.Workspace
	rc.io = io
	defer func() { rc.io = cmdIO{} }()
	for _, r := range c.Redirs {
		rel, ok := cleanRel(unmark(r.Target))
		p := wsDir(ws) + "/" + rel
		if r.Op == ">&1" {
			rc.io.stderr = rc.stdoutPath()
			continue
		}
		if !ok || rel == "." {
			rc.stderr(fmt.Sprintf("wasmdev: %s: bad redirection target\n", unmark(r.Target)))
			return 1, nil
		}
		var err error
		switch r.Op {
		case "<":
			var fi os.FileInfo
			if fi, err = os.Stat(p); err == nil && fi.IsDir() {
				err = fmt.Errorf("is a directory")
			}
			rc.io.stdin = p
		case ">":
			err = os.WriteFile(p, nil, 0o644)
		case ">>":
			var f *os.File
			if f, err = os.OpenFile(p, os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0o644); err == nil {
				f.Close()
			}
		}
		if err != nil {
			rc.stderr(fmt.Sprintf("wasmdev: %s: %v\n", unmark(r.Target), errText(err)))
			return 1, nil
		}
		if r.Op != "<" {
			if r.Fd == 2 {
				rc.io.stderr = p
			} else {
				rc.io.stdout = p
			}
		}
	}
	words := expandGlobs(ws, c.Words)
	if b := builtins[words[0]]; b != nil {
		t0 := time.Now()
		st := b(rc, words[1:])
		kind := "builtin"
		rc.j.mu.Lock()
		rc.j.steps = append(rc.j.steps, stepResult{Argv: words, Kind: &kind, State: "exited", ExitCode: intp(st),
			WallMs: msSince(t0)})
		rc.j.mu.Unlock()
		return st, nil
	}
	inv, err := rc.s.resolve(ws, words[0], words[1:])
	if err != nil {
		rc.stderr(fmt.Sprintf("wasmdev: %v\n", err))
		return 127, nil
	}
	rc.nscratch++
	scratch := fmt.Sprintf("%s/tmp%d", rc.j.dir, rc.nscratch)
	defer os.RemoveAll(scratch)
	rc.fail = nil
	err = rc.execInvocation(inv, scratch)
	status := 0
	if rc.fail != nil {
		status = 1
		if rc.fail.ExitCode != nil {
			status = *rc.fail.ExitCode
		}
	}
	return status, err
}

func errText(err error) string {
	if pe, ok := err.(*os.PathError); ok {
		err = pe.Err
	}
	return err.Error()
}

// ---- builtins (run in the control plane; no wasm step) ----

var builtins map[string]func(rc *runCtx, args []string) int

func init() {
	builtins = map[string]func(rc *runCtx, args []string) int{
		"true":  func(*runCtx, []string) int { return 0 },
		"false": func(*runCtx, []string) int { return 1 },
		"echo":  builtinEcho,
		"cat":   builtinCat,
		"cmp":   builtinCmp,
		"diff":  builtinDiff,
	}
}

func isBuiltin(name string) bool { return builtins[name] != nil }

func builtinEcho(rc *runCtx, args []string) int {
	nl := "\n"
	if len(args) > 0 && args[0] == "-n" {
		nl, args = "", args[1:]
	}
	rc.stdout(strings.Join(args, " ") + nl)
	return 0
}

// readInput reads a workspace file ("-" or none = the command's stdin).
func (rc *runCtx) readInput(name string) ([]byte, error) {
	if name == "-" {
		p := rc.io.stdin
		if p == "" {
			if rc.req.Stdin == "" {
				return nil, nil
			}
			p = rc.j.dir + "/stdin"
		}
		return os.ReadFile(p)
	}
	root, err := os.OpenRoot(wsDir(rc.j.Workspace))
	if err != nil {
		return nil, err
	}
	defer root.Close()
	f, err := root.Open(strings.TrimPrefix(name, "/work/"))
	if err != nil {
		return nil, err
	}
	defer f.Close()
	return io.ReadAll(f)
}

func builtinCat(rc *runCtx, args []string) int {
	if len(args) == 0 {
		args = []string{"-"}
	}
	status := 0
	var out bytes.Buffer
	for _, a := range args {
		b, err := rc.readInput(a)
		if err != nil {
			rc.stderr(fmt.Sprintf("cat: %s: %s\n", a, errText(err)))
			status = 1
			continue
		}
		out.Write(b)
	}
	rc.stdout(out.String())
	return status
}

func twoInputs(rc *runCtx, name string, args []string) ([]byte, []byte, bool) {
	var files []string
	for _, a := range args {
		if !strings.HasPrefix(a, "-") || a == "-" {
			files = append(files, a)
		}
	}
	if len(files) != 2 {
		rc.stderr(fmt.Sprintf("usage: %s FILE1 FILE2 (\"-\" = stdin)\n", name))
		return nil, nil, false
	}
	a, err := rc.readInput(files[0])
	if err != nil {
		rc.stderr(fmt.Sprintf("%s: %s: %s\n", name, files[0], errText(err)))
		return nil, nil, false
	}
	b, err := rc.readInput(files[1])
	if err != nil {
		rc.stderr(fmt.Sprintf("%s: %s: %s\n", name, files[1], errText(err)))
		return nil, nil, false
	}
	return a, b, true
}

func builtinCmp(rc *runCtx, args []string) int {
	a, b, ok := twoInputs(rc, "cmp", args)
	if !ok {
		return 2
	}
	if bytes.Equal(a, b) {
		return 0
	}
	line := 1
	for i := 0; i < len(a) && i < len(b); i++ {
		if a[i] != b[i] {
			rc.stdout(fmt.Sprintf("%s %s differ: byte %d, line %d\n", args[0], args[1], i+1, line))
			return 1
		}
		if a[i] == '\n' {
			line++
		}
	}
	short := args[0]
	if len(b) < len(a) {
		short = args[1]
	}
	rc.stdout(fmt.Sprintf("cmp: EOF on %s after byte %d\n", short, min(len(a), len(b))))
	return 1
}

// builtinDiff prints a line diff (unified format without context lines,
// LCS-based for inputs up to a few thousand lines). Exit 0 same, 1 differ.
func builtinDiff(rc *runCtx, args []string) int {
	a, b, ok := twoInputs(rc, "diff", args)
	if !ok {
		return 2
	}
	if bytes.Equal(a, b) {
		return 0
	}
	rc.stdout(lineDiff(splitLines(string(a)), splitLines(string(b))))
	return 1
}

func splitLines(s string) []string {
	if s == "" {
		return nil
	}
	l := strings.SplitAfter(s, "\n")
	if l[len(l)-1] == "" {
		l = l[:len(l)-1]
	}
	return l
}

func lineDiff(a, b []string) string {
	var out strings.Builder
	emit := func(prefix, l string) {
		out.WriteString(prefix + l)
		if !strings.HasSuffix(l, "\n") {
			out.WriteString("\n\\ No newline at end of file\n")
		}
	}
	// trim common prefix/suffix
	p := 0
	for p < len(a) && p < len(b) && a[p] == b[p] {
		p++
	}
	sa, sb := len(a), len(b)
	for sa > p && sb > p && a[sa-1] == b[sb-1] {
		sa--
		sb--
	}
	ma, mb := a[p:sa], b[p:sb]
	if len(ma)*len(mb) > 4_000_000 {
		fmt.Fprintf(&out, "@@ -%d,%d +%d,%d @@\n", p+1, len(ma), p+1, len(mb))
		for _, l := range ma {
			emit("-", l)
		}
		for _, l := range mb {
			emit("+", l)
		}
		return out.String()
	}
	// LCS table
	n, m := len(ma), len(mb)
	t := make([][]int32, n+1)
	for i := range t {
		t[i] = make([]int32, m+1)
	}
	for i := n - 1; i >= 0; i-- {
		for j := m - 1; j >= 0; j-- {
			if ma[i] == mb[j] {
				t[i][j] = t[i+1][j+1] + 1
			} else {
				t[i][j] = max(t[i+1][j], t[i][j+1])
			}
		}
	}
	i, j := 0, 0
	for i < n || j < m {
		if i < n && j < m && ma[i] == mb[j] {
			i++
			j++
			continue
		}
		// a hunk: collect until the next common line
		hi, hj := i, j
		var del, add []string
		for i < n || j < m {
			if i < n && j < m && ma[i] == mb[j] {
				break
			}
			if j >= m || (i < n && t[i+1][j] >= t[i][j+1]) {
				del = append(del, ma[i])
				i++
			} else {
				add = append(add, mb[j])
				j++
			}
		}
		fmt.Fprintf(&out, "@@ -%d,%d +%d,%d @@\n", p+hi+1, len(del), p+hj+1, len(add))
		for _, l := range del {
			emit("-", l)
		}
		for _, l := range add {
			emit("+", l)
		}
	}
	return out.String()
}

// ---- explaining failures ----

var wasmAddrRe = regexp.MustCompile(`wasm address 0x([0-9a-f]+)`)

// explainFailure turns a host error for a failed step into an actionable
// message (the raw error is kept at the end).
func explainFailure(errMsg, trap string, stack int64) string {
	hint := ""
	switch trap {
	case "stack_overflow":
		hint = fmt.Sprintf("wasm call stack exhausted: deep or infinite recursion exceeded the call-stack limit "+
			"(max_wasm_stack = %d bytes). Raise it per run with \"max_wasm_stack\": %d (bytes, max 268435456).",
			stack, max(stack*4, 64<<20))
	case "memory_out_of_bounds":
		hint = "out-of-bounds memory access (bad pointer, buffer overrun or use-after-free)."
		if m := wasmAddrRe.FindStringSubmatch(errMsg); m != nil {
			if a, err := strconv.ParseUint(m[1], 16, 64); err == nil && a >= 0xff000000 {
				hint = "C/C++ stack overflow: the program's stack in linear memory ran below address 0 " +
					"(the fault address is just under 4 GiB). Link with a bigger stack, e.g. " +
					"-Wl,-z,stack-size=8388608 (cc/c++ default here: 1 MiB), or reduce recursion/large locals."
			}
		}
	case "unreachable":
		hint = "the program executed a wasm `unreachable` instruction: usually abort(), a failed assert(), " +
			"__builtin_trap() or a Rust/C++ panic/terminate. Check stderr above."
	case "integer_division_by_zero":
		hint = "integer division by zero."
	case "integer_overflow":
		hint = "integer overflow (e.g. INT_MIN / -1)."
	case "bad_conversion_to_integer":
		hint = "invalid float-to-integer conversion (NaN or out of range)."
	case "indirect_call_to_null", "bad_signature", "table_out_of_bounds":
		hint = "bad indirect call (null or mismatched function pointer)."
	}
	if strings.Contains(errMsg, "long_double_not_supported") {
		hint = "printf/scanf of long double needs the link flag -lc-printscan-long-double."
	}
	if hint == "" {
		return errMsg
	}
	return "wasm trap: " + hint + " Output written before the trap is kept; unflushed stdio buffers are lost. [" + errMsg + "]"
}
