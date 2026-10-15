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
	// "cc -O2 -o app.wasm *.c && ./app.wasm arg". Cmd supports quoting,
	// globs (relative to the workspace) and && chaining; no pipes or
	// redirections.
	Module    string            `json:"module"` // tool name, command, or path in workspace
	Args      []string          `json:"args"`
	Cmd       string            `json:"cmd"`
	Env       map[string]string `json:"env"`
	Stdin     string            `json:"stdin"`
	TimeoutMs int64             `json:"timeout_ms"`
	MemoryMb  int64             `json:"memory_mb"`
}

// ---- jobs ----
//
// A run job is a goroutine executing one or more steps; each step is one
// wasm execution on the host. Plain runs are a single step; drivers (cc)
// and && chains are several. Output of all steps is concatenated into
// the job's stdout/stderr, like a shell would.

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
}

type stepResult struct {
	Argv     []string `json:"argv"`
	Kind     *string  `json:"kind,omitempty"`
	State    string   `json:"state"`
	ExitCode *int     `json:"exit_code"`
	Error    *string  `json:"error,omitempty"`
	WallMs   float64  `json:"wall_ms"`
	LoadMs   float64  `json:"load_ms"`
	Cache    *string  `json:"cache"`
}

type runResult struct {
	State    string
	ExitCode *int
	Error    *string
	WallMs   float64
}

var errStop = errors.New("stop")

// runCtx is what a job's program uses to run steps.
type runCtx struct {
	s     *server
	j     *job
	req   *runRequest
	nstep int
	// result of the last failing step (non-"exited" state or exit != 0)
	fail *stepResult
}

// step runs one wasm execution described by spec (module, args, env,
// mounts; stdio is filled in here). Its stdout/stderr are appended to the
// job's output unless capture is set, in which case they are returned.
// Returns errStop if the job must stop (killed, timed out, step failed to
// run); a nonzero exit is not an error, check the result.
func (rc *runCtx) step(spec *ExecSpec, capture bool) (*stepResult, string, string, error) {
	j := rc.j
	rc.nstep++
	n := rc.nstep
	spec.Stdout = fmt.Sprintf("%s/%d.out", j.dir, n)
	spec.Stderr = fmt.Sprintf("%s/%d.err", j.dir, n)
	if rc.req.Stdin != "" {
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
		WallMs: st.WallMs, LoadMs: st.LoadMs, Cache: st.Cache}
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
		appendFile(j.dir+"/stdout", spec.Stdout)
		appendFile(j.dir+"/stderr", spec.Stderr)
	}
	if st.State != "exited" || (st.ExitCode != nil && *st.ExitCode != 0) {
		rc.fail = &sr
	}
	if st.State != "exited" {
		return &sr, out, errOut, errStop
	}
	return &sr, out, errOut, nil
}

// stderr appends text to the job's stderr (driver diagnostics).
func (rc *runCtx) stderr(text string) {
	if text == "" {
		return
	}
	f, err := os.OpenFile(rc.j.dir+"/stderr", os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0o644)
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
	if _, err := os.Stat(wsDir(ws) + "/" + rel); err != nil {
		return nil, fmt.Errorf("%q is neither a registered tool/command nor a file in the workspace", module)
	}
	return &invocation{file: rel, args: args}, nil
}

// baseSpec is the common part of every step in workspace ws: the
// workspace is mounted at /work (fd 3, $PWD for Go) and also at / (fd 4),
// because wasi-libc ignores $PWD and resolves relative paths against "/".
func (s *server) baseSpec(ws string, req *runRequest) *ExecSpec {
	spec := &ExecSpec{
		Env:           map[string]string{"PWD": "/work", "HOME": "/work"},
		Dirs:          []Mount{{Host: wsDir(ws), Guest: "/work"}, {Host: wsDir(ws), Guest: "/"}},
		MemoryLimitMb: req.MemoryMb,
	}
	for k, v := range req.Env {
		spec.Env[k] = v
	}
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
		spec.Env[k] = v
	}
	for _, m := range t.Mounts {
		spec.Dirs = append(spec.Dirs, Mount{
			Host: strings.TrimSuffix(toolDir(t.Name)+"/"+path.Clean("/" + m.Path)[1:], "/"), Guest: m.Guest, Readonly: true})
	}
	if t.Scratch != "" {
		if err := os.MkdirAll(scratch, 0o755); err != nil {
			return nil, err
		}
		spec.Dirs = append(spec.Dirs, Mount{Host: scratch, Guest: t.Scratch})
		spec.Env["TMPDIR"] = t.Scratch
	}
	return spec, nil
}

// execInvocation runs one resolved command as one or more steps.
func (rc *runCtx) execInvocation(inv *invocation, scratch string) error {
	s, ws := rc.s, rc.j.Workspace
	if inv.tool == nil {
		spec := s.baseSpec(ws, rc.req)
		spec.Module = wsDir(ws) + "/" + inv.file
		spec.Args = append([]string{inv.file}, inv.args...)
		_, _, _, err := rc.step(spec, false)
		return err
	}
	args := append(append([]string{}, inv.prefix...), inv.args...)
	if d := drivers[inv.tool.Driver]; d != nil && len(inv.prefix) > 0 {
		return d(rc, inv.tool, inv.prefix[0], inv.args, scratch)
	}
	spec, err := s.toolSpec(ws, rc.req, inv.tool, args, scratch)
	if err != nil {
		return err
	}
	_, _, _, err = rc.step(spec, false)
	return err
}

// drivers implement commands that need more than one execution (wasm
// can't spawn processes). Keyed by toolManifest.Driver.
var drivers = map[string]func(rc *runCtx, t *toolManifest, prog string, args []string, scratch string) error{
	"clang": clangDriver,
}

// ---- command lines ----

// splitCmd splits a command line into && separated commands of words.
// Supports '...' and "..." quoting and backslash escapes.
func splitCmd(line string) ([][]string, error) {
	var cmds [][]string
	var words []string
	var cur strings.Builder
	inWord, quote := false, rune(0)
	flush := func() {
		if inWord {
			words = append(words, cur.String())
			cur.Reset()
			inWord = false
		}
	}
	rs := []rune(line)
	for i := 0; i < len(rs); i++ {
		c := rs[i]
		switch {
		case quote != 0:
			if c == quote {
				quote = 0
			} else if c == '\\' && quote == '"' && i+1 < len(rs) {
				i++
				cur.WriteRune(rs[i])
			} else {
				cur.WriteRune(c)
			}
		case c == '\'' || c == '"':
			quote, inWord = c, true
		case c == '\\' && i+1 < len(rs):
			i++
			cur.WriteRune(rs[i])
			inWord = true
		case c == ' ' || c == '\t' || c == '\n':
			flush()
		case c == '&' && i+1 < len(rs) && rs[i+1] == '&':
			flush()
			if len(words) == 0 {
				return nil, errors.New("syntax error near &&")
			}
			cmds = append(cmds, words)
			words = nil
			i++
		case c == '|' || c == '>' || c == '<' || c == ';' || c == '&' || c == '`' || c == '$':
			return nil, fmt.Errorf("unsupported shell syntax %q (only words, quotes, globs and && are supported)", c)
		default:
			// mark globs so quoted '*' is left alone
			if c == '*' || c == '?' || c == '[' {
				cur.WriteRune(0)
			}
			cur.WriteRune(c)
			inWord = true
		}
	}
	if quote != 0 {
		return nil, errors.New("unterminated quote")
	}
	flush()
	if len(words) > 0 {
		cmds = append(cmds, words)
	} else if len(cmds) > 0 {
		return nil, errors.New("syntax error: trailing &&")
	}
	return cmds, nil
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
	// Resolve everything up front so usage errors are a 400.
	var cmds [][]string
	if req.Cmd != "" {
		if req.Module != "" {
			httpErr(w, 400, "give either module or cmd, not both")
			return
		}
		var err error
		if cmds, err = splitCmd(req.Cmd); err != nil || len(cmds) == 0 {
			httpErr(w, 400, fmt.Sprintf("bad cmd: %v", err))
			return
		}
		for i := range cmds {
			cmds[i] = expandGlobs(ws, cmds[i])
		}
	} else {
		cmds = [][]string{append([]string{req.Module}, req.Args...)}
	}
	// Only the first command is resolved eagerly: later ones may name
	// files that earlier ones create (cc -o app.wasm ... && app.wasm).
	if _, err := s.resolve(ws, cmds[0][0], cmds[0][1:]); err != nil {
		httpErr(w, 400, err.Error())
		return
	}
	j := &job{ID: s.newID("j"), Kind: "run", Workspace: ws, Module: cmds[0][0], Args: cmds[0][1:],
		Started: time.Now(), done: make(chan struct{})}
	if req.Cmd != "" {
		j.Module, j.Args = "sh", []string{"-c", req.Cmd}
	}
	j.dir = dataDir + "/runs/" + j.ID
	if err := os.MkdirAll(j.dir, 0o755); err != nil {
		httpErr(w, 500, err.Error())
		return
	}
	if req.Stdin != "" {
		if err := os.WriteFile(j.dir+"/stdin", []byte(req.Stdin), 0o644); err != nil {
			httpErr(w, 500, err.Error())
			return
		}
	}
	if req.TimeoutMs > 0 {
		j.deadline = j.Started.Add(time.Duration(req.TimeoutMs) * time.Millisecond)
	}
	s.mu.Lock()
	s.jobs[j.ID] = j
	s.mu.Unlock()
	go s.drive(j, &req, cmds)
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

// drive runs a job's commands (&& semantics) and records the result.
func (s *server) drive(j *job, req *runRequest, cmds [][]string) {
	rc := &runCtx{s: s, j: j, req: req}
	var err error
	for i, words := range cmds {
		var inv *invocation
		if inv, err = s.resolve(j.Workspace, words[0], words[1:]); err != nil {
			rc.stderr(fmt.Sprintf("wasmdev: %v\n", err))
			rc.fail = &stepResult{State: "exited", ExitCode: intp(127)}
			break
		}
		scratch := fmt.Sprintf("%s/tmp%d", j.dir, i)
		if err = rc.execInvocation(inv, scratch); err != nil || rc.fail != nil {
			break
		}
	}
	os.RemoveAll(j.dir + "/tmp0") // scratch dirs (object files etc.)
	for i := 1; i < len(cmds); i++ {
		os.RemoveAll(fmt.Sprintf("%s/tmp%d", j.dir, i))
	}
	res := &runResult{State: "exited", ExitCode: intp(0)}
	j.mu.Lock()
	killed := j.killed
	j.mu.Unlock()
	switch {
	case killed:
		res = &runResult{State: "killed", Error: strp("killed")}
	case rc.fail != nil:
		res = &runResult{State: rc.fail.State, ExitCode: rc.fail.ExitCode, Error: rc.fail.Error}
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

// ---- services ----

func (s *server) serviceInfo(j *job) map[string]any {
	st, _ := host.Status(j.handle)
	info := map[string]any{"service_id": j.ID, "workspace": j.Workspace, "module": j.Module,
		"args": j.Args, "started": j.Started}
	if st != nil {
		info["state"], info["exit_code"], info["error"], info["kind"] = st.State, st.ExitCode, st.Error, st.Kind
		if st.Port != nil {
			info["port"] = *st.Port
			info["url"] = fmt.Sprintf("http://%s:%d/", s.pubHost, *st.Port)
		}
	}
	return info
}

func (s *server) startService(w http.ResponseWriter, r *http.Request) {
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
	inv, err := s.resolve(ws, req.Module, req.Args)
	if err != nil {
		httpErr(w, 400, err.Error())
		return
	}
	j := &job{ID: s.newID("s"), Kind: "service", Workspace: ws, Module: req.Module,
		Args: req.Args, Started: time.Now()}
	j.dir = dataDir + "/runs/" + j.ID
	if err := os.MkdirAll(j.dir, 0o755); err != nil {
		httpErr(w, 500, err.Error())
		return
	}
	var spec *ExecSpec
	if inv.tool != nil {
		spec, err = s.toolSpec(ws, &req, inv.tool, append(append([]string{}, inv.prefix...), inv.args...), j.dir+"/tmp")
		if err != nil {
			httpErr(w, 500, err.Error())
			return
		}
	} else {
		spec = s.baseSpec(ws, &req)
		spec.Module = wsDir(ws) + "/" + inv.file
		spec.Args = append([]string{inv.file}, inv.args...)
	}
	spec.Stdout, spec.Stderr = j.dir+"/stdout", j.dir+"/stderr"
	if req.Stdin != "" {
		os.WriteFile(j.dir+"/stdin", []byte(req.Stdin), 0o644)
		spec.Stdin = j.dir + "/stdin"
	}
	spec.TimeoutMs = req.TimeoutMs
	spec.Listen = true
	j.handle, err = host.Start(spec)
	if err != nil {
		httpErr(w, 500, err.Error())
		return
	}
	st, err := host.Status(j.handle)
	if err != nil || st.Port == nil {
		msg := "service failed to start"
		if st != nil && st.Error != nil {
			msg += ": " + *st.Error
		}
		host.Release(j.handle)
		httpErr(w, 500, msg)
		return
	}
	s.mu.Lock()
	s.services[j.ID] = j
	s.mu.Unlock()
	writeJSON(w, 201, s.serviceInfo(j))
}

func (s *server) listServices(w http.ResponseWriter, r *http.Request) {
	s.mu.Lock()
	svcs := make([]*job, 0, len(s.services))
	for _, j := range s.services {
		svcs = append(svcs, j)
	}
	s.mu.Unlock()
	sort.Slice(svcs, func(a, b int) bool { return svcs[a].Started.Before(svcs[b].Started) })
	list := []map[string]any{}
	for _, j := range svcs {
		list = append(list, s.serviceInfo(j))
	}
	writeJSON(w, 200, map[string]any{"services": list})
}

func (s *server) getService(w http.ResponseWriter, r *http.Request) {
	j := s.lookup(s.services, r.PathValue("id"))
	if j == nil {
		httpErr(w, 404, "no such service")
		return
	}
	writeJSON(w, 200, s.serviceInfo(j))
}

func (s *server) serviceLogs(w http.ResponseWriter, r *http.Request) {
	j := s.lookup(s.services, r.PathValue("id"))
	if j == nil {
		httpErr(w, 404, "no such service")
		return
	}
	out, _ := readCapped(j.dir + "/stdout")
	errOut, _ := readCapped(j.dir + "/stderr")
	writeJSON(w, 200, map[string]any{"stdout": out, "stderr": errOut})
}

func (s *server) stopService(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	j := s.lookup(s.services, id)
	if j == nil {
		httpErr(w, 404, "no such service")
		return
	}
	host.Kill(j.handle)
	st, _ := waitDone(j.handle, r.Context().Done())
	info := s.serviceInfo(j)
	host.Release(j.handle)
	s.mu.Lock()
	delete(s.services, id)
	s.mu.Unlock()
	if st != nil {
		info["state"] = st.State
	}
	writeJSON(w, 200, info)
}
