package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"net/http"
	"os"
	"path"
	"sort"
	"strings"
	"sync"
	"time"
)

const maxOutput = 1 << 20 // bytes of stdout/stderr returned inline

type runRequest struct {
	// Either Module (+Args), or Cmd: a command line such as
	// "cc -O2 -o app.wasm *.c && ./app.wasm < in.txt > out.txt". See sh.go
	// for the supported syntax.
	Module    string            `json:"module"` // tool name, command, or path in workspace
	Args      []string          `json:"args"`
	Cmd       string            `json:"cmd"`
	Env       map[string]string `json:"env"`
	Stdin     string            `json:"stdin"`
	TimeoutMs int64             `json:"timeout_ms"`
	MemoryMb  int64             `json:"memory_mb"`
	// MaxWasmStack: wasm call-stack limit in bytes for the run's own
	// programs (workspace modules and what spawning tools like go run).
	MaxWasmStack int64 `json:"max_wasm_stack"`
	// Compiler for workspace modules: "cranelift" | "winch" (default: service policy).
	Compiler string `json:"compiler"`
	// Services only: block until the service accepts connections.
	WaitReady      bool  `json:"wait_ready"`
	ReadyTimeoutMs int64 `json:"ready_timeout_ms"`
}

// ---- jobs ----
//
// A run job is a goroutine executing one or more steps; each step is one
// wasm execution on the host. Plain runs are a single step; drivers (cc),
// command lists and pipelines are several. Output of all steps is
// concatenated into the job's stdout/stderr (unless redirected), like a
// shell would.

type job struct {
	ID        string    `json:"id"`
	Kind      string    `json:"kind"` // run | service
	Workspace string    `json:"workspace"`
	Module    string    `json:"module"`
	Args      []string  `json:"args"`
	Started   time.Time `json:"started"`
	dir       string    // /data/runs/<id>

	mu       sync.Mutex
	handle   int64 // current host exec (a service's only one)
	killed   bool
	deadline time.Time
	steps    []stepResult
	done     chan struct{}
	res      *runResult
	readyMs  *float64 // services: time to first accepted connection
}

type stepResult struct {
	Argv     []string `json:"argv"`
	Kind     *string  `json:"kind,omitempty"`
	State    string   `json:"state"`
	ExitCode *int     `json:"exit_code"`
	Error    *string  `json:"error,omitempty"`
	Trap     *string  `json:"trap,omitempty"`
	WallMs   float64  `json:"wall_ms"`
	LoadMs   float64  `json:"load_ms"`
	Cache    *string  `json:"cache"`
	Compiler *string  `json:"compiler,omitempty"`
}

type runResult struct {
	State    string
	ExitCode *int
	Error    *string
	Trap     *string
	WallMs   float64
}

var errStop = errors.New("stop")

// cmdIO is where the current command's stdio goes (data-dir paths).
type cmdIO struct {
	stdin  string // "" = the request's stdin
	stdout string // file to append to; "" = the job's stdout
	stderr string // "" = the job's stderr
}

// runCtx is what a job's program uses to run steps.
type runCtx struct {
	s     *server
	j     *job
	req   *runRequest
	nstep int
	io    cmdIO
	// last failing step of the current command (state != exited or exit != 0)
	fail *stepResult
	// a step that did not exit normally (trap, timeout, ...): stops the job
	abn      *stepResult
	status   int // exit status of the last command
	nscratch int
}

func (rc *runCtx) stdoutPath() string {
	if rc.io.stdout != "" {
		return rc.io.stdout
	}
	return rc.j.dir + "/stdout"
}

func (rc *runCtx) stderrPath() string {
	if rc.io.stderr != "" {
		return rc.io.stderr
	}
	return rc.j.dir + "/stderr"
}

// step runs one wasm execution described by spec (module, args, env,
// mounts; stdio is filled in here). Its stdout/stderr are appended to the
// command's output unless capture is set, in which case they are returned.
// Returns errStop if the job must stop (killed, timed out, trapped, failed
// to run); a nonzero exit is not an error, check the result.
func (rc *runCtx) step(spec *ExecSpec, capture bool) (*stepResult, string, string, error) {
	j := rc.j
	rc.nstep++
	n := rc.nstep
	spec.Stdout = fmt.Sprintf("%s/%d.out", j.dir, n)
	spec.Stderr = fmt.Sprintf("%s/%d.err", j.dir, n)
	if rc.io.stdin != "" {
		spec.Stdin = rc.io.stdin
	} else if rc.req.Stdin != "" {
		spec.Stdin = j.dir + "/stdin"
	}
	j.mu.Lock()
	if j.killed {
		j.mu.Unlock()
		return nil, "", "", errStop
	}
	if !j.deadline.IsZero() {
		left := time.Until(j.deadline).Milliseconds()
		if left <= 0 {
			j.mu.Unlock()
			rc.fail = &stepResult{Argv: spec.Args, State: "timeout", Error: strp("timeout")}
			rc.abn = rc.fail
			return rc.fail, "", "", errStop
		}
		spec.TimeoutMs = left
	}
	h, err := host.Start(spec)
	if err != nil {
		j.mu.Unlock()
		return nil, "", "", err
	}
	j.handle = h
	j.mu.Unlock()
	st, err := waitDone(h, nil)
	host.Release(h)
	if err != nil {
		return nil, "", "", err
	}
	sr := stepResult{Argv: spec.Args, Kind: st.Kind, State: st.State, ExitCode: st.ExitCode, Error: st.Error,
		Trap: st.Trap, WallMs: st.WallMs, LoadMs: st.LoadMs, Cache: st.Cache, Compiler: st.Compiler}
	if st.State == "failed" {
		sr.Error = strp(explainFailure(deref(st.Error), deref(st.Trap), rc.stackLimit(spec)))
	}
	j.mu.Lock()
	j.steps = append(j.steps, sr)
	j.mu.Unlock()
	var out, errOut string
	if capture {
		out, _ = readCapped(spec.Stdout)
		errOut, _ = readCapped(spec.Stderr)
		os.Remove(spec.Stdout)
		os.Remove(spec.Stderr)
	} else {
		// Output produced before a trap is kept (unflushed libc buffers
		// are lost, as with a native crash).
		appendFile(rc.stdoutPath(), spec.Stdout)
		appendFile(rc.stderrPath(), spec.Stderr)
	}
	if st.State != "exited" || (st.ExitCode != nil && *st.ExitCode != 0) {
		rc.fail = &sr
	}
	if st.State != "exited" {
		rc.abn = &sr
		return &sr, out, errOut, errStop
	}
	return &sr, out, errOut, nil
}

func (rc *runCtx) stackLimit(spec *ExecSpec) int64 {
	if spec.MaxWasmStack > 0 {
		return spec.MaxWasmStack
	}
	return rc.s.defStack
}

// stderr appends text to the command's stderr (driver diagnostics).
func (rc *runCtx) stderr(text string) { appendText(rc.stderrPath(), text) }

// stdout appends text to the command's stdout (builtins).
func (rc *runCtx) stdout(text string) { appendText(rc.stdoutPath(), text) }

func appendText(p, text string) {
	if text == "" {
		return
	}
	f, err := os.OpenFile(p, os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0o644)
	if err == nil {
		f.WriteString(text)
		f.Close()
	}
}

// appendFile moves (first time) or appends src onto dst.
func appendFile(dst, src string) {
	if _, err := os.Stat(dst); errors.Is(err, fs.ErrNotExist) {
		if os.Rename(src, dst) == nil {
			return
		}
	}
	in, err := os.Open(src)
	if err != nil {
		return
	}
	defer in.Close()
	out, err := os.OpenFile(dst, os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0o644)
	if err != nil {
		return
	}
	io.Copy(out, in)
	out.Close()
	os.Remove(src)
}

func strp(s string) *string { return &s }
func intp(i int) *int       { return &i }

// ---- resolving what to run ----

// invocation is one resolved command: a tool (optionally via one of its
// commands/driver) or a workspace module.
type invocation struct {
	tool   *toolManifest
	prefix []string // argv after argv0 that selects the command
	file   string   // workspace-relative module path (if not a tool)
	args   []string
}

func (s *server) resolve(ws, module string, args []string) (*invocation, error) {
	if module == "" {
		return nil, errors.New("module is required")
	}
	if t := s.tools.tool(module); t != nil {
		return &invocation{tool: t, args: args}, nil
	}
	if c, ok := s.tools.command(module); ok {
		return &invocation{tool: c.Tool, prefix: c.Prefix, args: args}, nil
	}
	rel, ok := cleanRel(module)
	if !ok {
		return nil, errors.New("bad module path")
	}
	if fi, err := os.Stat(wsDir(ws) + "/" + rel); err != nil || fi.IsDir() {
		return nil, fmt.Errorf("%s: command not found (neither a registered tool/command, a builtin, nor a file in the workspace)", module)
	}
	return &invocation{file: rel, args: args}, nil
}

// baseSpec is the common part of every step in workspace ws: the
// workspace is mounted at /work (fd 3, $PWD for Go) and also at / (fd 4),
// because wasi-libc ignores $PWD and resolves relative paths against "/".
func (s *server) baseSpec(ws string, req *runRequest) *ExecSpec {
	return &ExecSpec{
		Env:           map[string]string{"PWD": "/work", "HOME": "/work"},
		Dirs:          []Mount{{Host: wsDir(ws), Guest: "/work"}, {Host: wsDir(ws), Guest: "/"}},
		MemoryLimitMb: req.MemoryMb,
	}
}

// userEnv applies the request's env last, so it overrides tool defaults.
func userEnv(spec *ExecSpec, req *runRequest) {
	for k, v := range req.Env {
		spec.Env[k] = v
	}
}

// moduleSpec builds the spec to run workspace module file.
func (s *server) moduleSpec(ws string, req *runRequest, file string, args []string) *ExecSpec {
	spec := s.baseSpec(ws, req)
	spec.Module = wsDir(ws) + "/" + file
	spec.Args = append([]string{file}, args...)
	spec.MaxWasmStack = req.MaxWasmStack
	// Workspace modules are rebuilt often: keep their compiled code in
	// memory only (bounded), not in the disk cache.
	spec.Ephemeral = true
	// Measured (notes/w1.md): Winch compiles ~5x faster than Cranelift but
	// its code runs ~2x slower. Fresh builds are often run once (tests,
	// one-shot tools), so start with Winch and let the host tier up to
	// Cranelift in the background for repeated runs.
	c := req.Compiler
	if c == "" {
		c = s.userCompiler
	}
	switch c {
	case "", "tiered":
		spec.Compiler, spec.TierUp = "winch", true
	default:
		spec.Compiler = c
	}
	userEnv(spec, req)
	return spec
}

// toolSpec builds the spec to run tool t with argv[1:] = args. scratch is
// the per-invocation scratch dir (created on demand) if the tool wants one.
func (s *server) toolSpec(ws string, req *runRequest, t *toolManifest, args []string, scratch string) (*ExecSpec, error) {
	spec := s.baseSpec(ws, req)
	spec.Module = t.modulePath()
	argv0 := t.Argv0
	if argv0 == "" {
		argv0 = t.Name
	}
	spec.Args = append([]string{argv0}, args...)
	for k, v := range t.Env {
		spec.Env[k] = strings.ReplaceAll(v, "{cpus}", fmt.Sprint(s.cpus))
	}
	for _, m := range t.Mounts {
		spec.Dirs = append(spec.Dirs, Mount{
			Host: strings.TrimSuffix(toolDir(t.Name)+"/"+path.Clean("/" + m.Path)[1:], "/"), Guest: m.Guest, Readonly: true})
	}
	for _, sh := range t.Shared {
		d := sharedDir(t.Name, sh.Name)
		if err := os.MkdirAll(d, 0o755); err != nil {
			return nil, err
		}
		spec.Dirs = append(spec.Dirs, Mount{Host: d, Guest: sh.Guest})
	}
	if t.Scratch != "" {
		if err := os.MkdirAll(scratch, 0o755); err != nil {
			return nil, err
		}
		spec.Dirs = append(spec.Dirs, Mount{Host: scratch, Guest: t.Scratch, Compiler: t.ScratchCompiler})
		spec.Env["TMPDIR"] = t.Scratch
	}
	if t.Spawn {
		// The tool runs the user's code (test binaries): the run's stack
		// limit applies to it and its children.
		spec.Spawn = true
		spec.MaxWasmStack = req.MaxWasmStack
	}
	userEnv(spec, req)
	return spec, nil
}

// execInvocation runs one resolved command as one or more steps.
func (rc *runCtx) execInvocation(inv *invocation, scratch string) error {
	s, ws := rc.s, rc.j.Workspace
	if inv.tool == nil {
		_, _, _, err := rc.step(s.moduleSpec(ws, rc.req, inv.file, inv.args), false)
		return err
	}
	args := append(append([]string{}, inv.prefix...), inv.args...)
	if d := driver(inv.tool.Driver); d != nil && len(inv.prefix) > 0 {
		return d(rc, inv.tool, inv.prefix[0], inv.args, scratch)
	}
	spec, err := s.toolSpec(ws, rc.req, inv.tool, args, scratch)
	if err != nil {
		return err
	}
	_, _, _, err = rc.step(spec, false)
	return err
}

// driver returns the implementation of commands that need more than one
// execution (tools that can't spawn processes themselves), by
// toolManifest.Driver. (A function, not a package-level map: a map
// initializer would make the drivers - and through them the wasmdev host
// imports - reachable in every binary, including `go test` binaries, which
// then can't be instantiated outside the control plane.)
func driver(name string) func(rc *runCtx, t *toolManifest, prog string, args []string, scratch string) error {
	switch name {
	case "clang":
		return clangDriver
	}
	return nil
}

// expandGlobs expands unquoted glob words against the workspace; like sh,
// a pattern that matches nothing is passed through literally.
func expandGlobs(ws string, words []string) []string {
	var out []string
	fsys := os.DirFS(wsDir(ws))
	for _, w := range words {
		if !strings.ContainsRune(w, 0) {
			out = append(out, w)
			continue
		}
		pat := strings.ReplaceAll(w, "\x00", "")
		// mark-free version of quoted metachars was written without \x00,
		// so escape those for fs.Glob.
		var b strings.Builder
		rs := []rune(w)
		for i := 0; i < len(rs); i++ {
			if rs[i] == 0 && i+1 < len(rs) {
				i++
				b.WriteRune(rs[i])
			} else if rs[i] == '*' || rs[i] == '?' || rs[i] == '[' || rs[i] == '\\' {
				b.WriteRune('\\')
				b.WriteRune(rs[i])
			} else {
				b.WriteRune(rs[i])
			}
		}
		m, _ := fs.Glob(fsys, strings.TrimPrefix(b.String(), "./"))
		if len(m) == 0 {
			out = append(out, pat)
			continue
		}
		sort.Strings(m)
		out = append(out, m...)
	}
	return out
}

// ---- runs ----

func readCapped(p string) (string, bool) {
	f, err := os.Open(p)
	if err != nil {
		return "", false
	}
	defer f.Close()
	b, _ := io.ReadAll(io.LimitReader(f, maxOutput+1))
	if len(b) > maxOutput {
		return string(b[:maxOutput]), true
	}
	return string(b), false
}

// waitDone polls the host with exponential backoff (50µs .. 5ms).
// TODO: replace with a host->guest completion notification fd so that
// waiting goroutines block in the netpoller instead of polling.
func waitDone(h int64, ctxDone <-chan struct{}) (*ExecStatus, error) {
	d := 50 * time.Microsecond
	for {
		st, err := host.Status(h)
		if err != nil || st.Done {
			return st, err
		}
		select {
		case <-ctxDone:
			return st, errors.New("client went away")
		case <-time.After(d):
		}
		if d < 5*time.Millisecond {
			d *= 2
		}
	}
}

func (s *server) jobResult(j *job) map[string]any {
	j.mu.Lock()
	res, steps := j.res, append([]stepResult(nil), j.steps...)
	j.mu.Unlock()
	out := map[string]any{"job_id": j.ID, "done": res != nil, "steps": steps}
	if res == nil {
		out["state"] = "running"
		out["wall_ms"] = float64(time.Since(j.Started).Microseconds()) / 1e3
		return out
	}
	out["state"], out["exit_code"], out["error"], out["wall_ms"] = res.State, res.ExitCode, res.Error, res.WallMs
	if res.Trap != nil {
		out["trap"] = *res.Trap
	}
	// load_ms/cache of the main (last) step, for single-module runs
	if len(steps) > 0 {
		last := steps[len(steps)-1]
		out["load_ms"], out["cache"], out["kind"] = last.LoadMs, last.Cache, last.Kind
	}
	o, t1 := readCapped(j.dir + "/stdout")
	e, t2 := readCapped(j.dir + "/stderr")
	out["stdout"], out["stderr"] = o, e
	if t1 || t2 {
		out["truncated"] = true
	}
	return out
}

func (s *server) run(w http.ResponseWriter, r *http.Request) {
	var req runRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpErr(w, 400, "bad JSON: "+err.Error())
		return
	}
	ws := r.PathValue("id")
	if !idRe.MatchString(ws) {
		httpErr(w, 400, "bad workspace id")
		return
	}
	if _, err := os.Stat(wsDir(ws)); err != nil {
		httpErr(w, 404, "no such workspace")
		return
	}
	j, err := s.startJob(ws, &req)
	if err != nil {
		httpErr(w, 400, err.Error())
		return
	}
	if r.URL.Query().Get("async") == "1" {
		writeJSON(w, 202, map[string]any{"job_id": j.ID, "state": "running"})
		return
	}
	select {
	case <-j.done:
	case <-r.Context().Done():
		return
	}
	writeJSON(w, 200, s.jobResult(j))
}

// startJob validates a run request and starts it in the background.
// Errors are usage errors (bad syntax, unknown first command).
func (s *server) startJob(ws string, req *runRequest) (*job, error) {
	var l *cmdList
	var err error
	if req.Cmd != "" {
		if req.Module != "" {
			return nil, errors.New("give either module or cmd, not both")
		}
		if l, err = parseCmd(req.Cmd); err != nil {
			return nil, fmt.Errorf("bad cmd: %v", err)
		}
	} else {
		words := []string{strings.ReplaceAll(req.Module, "\x00", "")}
		for _, a := range req.Args {
			words = append(words, strings.ReplaceAll(a, "\x00", ""))
		}
		l = &cmdList{Pipes: []pipeline{{Cmds: []simpleCmd{{Words: words}}}}}
	}
	if req.Compiler != "" && req.Compiler != "cranelift" && req.Compiler != "winch" {
		return nil, errors.New(`compiler must be "cranelift" or "winch"`)
	}
	// Only the first command is resolved eagerly: later ones may name
	// files that earlier ones create (cc -o app.wasm ... && ./app.wasm).
	first := expandGlobs(ws, l.Pipes[0].Cmds[0].Words)
	eager := true // a usage error is a 400 unless the command line handles failure itself
	for _, op := range l.Ops {
		eager = eager && op == "&&"
	}
	if eager && !isBuiltin(first[0]) {
		if _, err := s.resolve(ws, first[0], first[1:]); err != nil {
			return nil, err
		}
	}
	j := &job{ID: s.newID("j"), Kind: "run", Workspace: ws, Module: first[0], Args: first[1:],
		Started: time.Now(), done: make(chan struct{})}
	if req.Cmd != "" {
		j.Module, j.Args = "sh", []string{"-c", req.Cmd}
	}
	j.dir = dataDir + "/runs/" + j.ID
	if err := os.MkdirAll(j.dir, 0o755); err != nil {
		return nil, err
	}
	if req.Stdin != "" {
		if err := os.WriteFile(j.dir+"/stdin", []byte(req.Stdin), 0o644); err != nil {
			return nil, err
		}
	}
	if req.TimeoutMs > 0 {
		j.deadline = j.Started.Add(time.Duration(req.TimeoutMs) * time.Millisecond)
	}
	s.mu.Lock()
	s.jobs[j.ID] = j
	s.mu.Unlock()
	go s.drive(j, req, l)
	return j, nil
}

// drive runs a job's command list and records the result.
func (s *server) drive(j *job, req *runRequest, l *cmdList) {
	rc := &runCtx{s: s, j: j, req: req}
	err := rc.runList(l)
	res := &runResult{State: "exited", ExitCode: intp(rc.status)}
	j.mu.Lock()
	killed := j.killed
	j.mu.Unlock()
	switch {
	case killed:
		res = &runResult{State: "killed", Error: strp("killed")}
	case rc.abn != nil:
		res = &runResult{State: rc.abn.State, ExitCode: rc.abn.ExitCode, Error: rc.abn.Error, Trap: rc.abn.Trap}
	case err != nil && err != errStop:
		res = &runResult{State: "failed", Error: strp(err.Error())}
	}
	res.WallMs = float64(time.Since(j.Started).Microseconds()) / 1e3
	j.mu.Lock()
	j.res = res
	j.mu.Unlock()
	close(j.done)
}

func (s *server) lookup(m map[string]*job, id string) *job {
	s.mu.Lock()
	defer s.mu.Unlock()
	return m[id]
}

func (s *server) getJob(w http.ResponseWriter, r *http.Request) {
	j := s.lookup(s.jobs, r.PathValue("id"))
	if j == nil {
		httpErr(w, 404, "no such job")
		return
	}
	if r.URL.Query().Get("wait") == "1" {
		select {
		case <-j.done:
		case <-r.Context().Done():
			return
		}
	}
	writeJSON(w, 200, s.jobResult(j))
}

func (s *server) killJob(w http.ResponseWriter, r *http.Request) {
	j := s.lookup(s.jobs, r.PathValue("id"))
	if j == nil {
		httpErr(w, 404, "no such job")
		return
	}
	j.mu.Lock()
	j.killed = true
	h := j.handle
	j.mu.Unlock()
	if h != 0 {
		host.Kill(h)
	}
	w.WriteHeader(202)
}

func (s *server) listJobs(w http.ResponseWriter, r *http.Request) {
	s.mu.Lock()
	jobs := make([]*job, 0, len(s.jobs))
	for _, j := range s.jobs {
		jobs = append(jobs, j)
	}
	s.mu.Unlock()
	sort.Slice(jobs, func(a, b int) bool { return jobs[a].Started.Before(jobs[b].Started) })
	list := make([]map[string]any, 0, len(jobs))
	for _, j := range jobs {
		e := map[string]any{"job": j}
		j.mu.Lock()
		if j.res != nil {
			e["state"], e["exit_code"] = j.res.State, j.res.ExitCode
		} else {
			e["state"] = "running"
		}
		j.mu.Unlock()
		list = append(list, e)
	}
	writeJSON(w, 200, map[string]any{"jobs": list})
}
