package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"path"
	"sort"
	"strings"
	"time"
)

const maxOutput = 1 << 20 // bytes of stdout/stderr returned inline

type runRequest struct {
	Module    string            `json:"module"` // tool name or path in workspace
	Args      []string          `json:"args"`
	Env       map[string]string `json:"env"`
	Stdin     string            `json:"stdin"`
	TimeoutMs int64             `json:"timeout_ms"`
	MemoryMb  int64             `json:"memory_mb"`
}

// ---- tools ----

type toolManifest struct {
	Name        string            `json:"name"`
	Module      string            `json:"module"` // relative to tool dir
	Argv0       string            `json:"argv0,omitempty"`
	Mounts      []toolMount       `json:"mounts,omitempty"`
	Env         map[string]string `json:"env,omitempty"`
	Description string            `json:"description,omitempty"`
}

type toolMount struct {
	Path  string `json:"path"`  // relative to tool dir
	Guest string `json:"guest"` // e.g. /sysroot
}

func toolDir(name string) string { return dataDir + "/tools/" + name }

func loadTool(name string) (*toolManifest, error) {
	if !idRe.MatchString(name) {
		return nil, os.ErrNotExist
	}
	b, err := os.ReadFile(toolDir(name) + "/tool.json")
	if err != nil {
		return nil, err
	}
	var m toolManifest
	if err := json.Unmarshal(b, &m); err != nil {
		return nil, fmt.Errorf("tool %s: bad tool.json: %v", name, err)
	}
	m.Name = name
	return &m, nil
}

func (s *server) listTools(w http.ResponseWriter, r *http.Request) {
	ents, _ := os.ReadDir(dataDir + "/tools")
	tools := []*toolManifest{}
	for _, e := range ents {
		if m, err := loadTool(e.Name()); err == nil {
			tools = append(tools, m)
		}
	}
	writeJSON(w, 200, map[string]any{"tools": tools})
}

func (s *server) getTool(w http.ResponseWriter, r *http.Request) {
	m, err := loadTool(r.PathValue("name"))
	if err != nil {
		httpErr(w, 404, "no such tool")
		return
	}
	writeJSON(w, 200, m)
}

func (s *server) deleteTool(w http.ResponseWriter, r *http.Request) {
	name := r.PathValue("name")
	if !idRe.MatchString(name) {
		httpErr(w, 400, "bad tool name")
		return
	}
	os.RemoveAll(toolDir(name))
	w.WriteHeader(204)
}

// putTool registers a tool from either a raw wasm module (body starts with
// "\0asm") or a tar archive containing tool.json + files. Query params
// argv0 and description fill in the manifest for raw modules.
func (s *server) putTool(w http.ResponseWriter, r *http.Request) {
	name := r.PathValue("name")
	if !idRe.MatchString(name) {
		httpErr(w, 400, "bad tool name")
		return
	}
	body, err := io.ReadAll(r.Body)
	if err != nil {
		httpErr(w, 400, err.Error())
		return
	}
	dir := toolDir(name)
	tmp := dir + ".tmp-" + randHex(4)
	if err := os.MkdirAll(tmp, 0o755); err != nil {
		httpErr(w, 500, err.Error())
		return
	}
	defer os.RemoveAll(tmp)
	root, err := os.OpenRoot(tmp)
	if err != nil {
		httpErr(w, 500, err.Error())
		return
	}
	defer root.Close()
	switch {
	case bytes.HasPrefix(body, []byte("\x00asm")):
		if err := os.WriteFile(tmp+"/"+name+".wasm", body, 0o644); err != nil {
			httpErr(w, 500, err.Error())
			return
		}
		m := toolManifest{Name: name, Module: name + ".wasm", Argv0: r.URL.Query().Get("argv0"),
			Description: r.URL.Query().Get("description")}
		b, _ := json.MarshalIndent(m, "", "  ")
		os.WriteFile(tmp+"/tool.json", b, 0o644)
	case isTar(body):
		if _, err := extractTar(root, bytes.NewReader(body)); err != nil {
			httpErr(w, 400, err.Error())
			return
		}
		if _, err := os.Stat(tmp + "/tool.json"); err != nil {
			httpErr(w, 400, "tar must contain tool.json")
			return
		}
	default:
		httpErr(w, 400, "body must be a wasm module or a tar archive")
		return
	}
	os.RemoveAll(dir)
	if err := os.Rename(tmp, dir); err != nil {
		httpErr(w, 500, err.Error())
		return
	}
	m, err := loadTool(name)
	if err != nil {
		httpErr(w, 400, err.Error())
		return
	}
	writeJSON(w, 201, m)
}

// ---- building exec specs ----

// buildSpec resolves module (tool name or workspace path) into a host
// ExecSpec for workspace ws. The workspace is mounted at /work (also the
// cwd via $PWD).
func (s *server) buildSpec(ws string, req *runRequest, runDir string) (*ExecSpec, error) {
	if !idRe.MatchString(ws) {
		return nil, errors.New("bad workspace id")
	}
	if _, err := os.Stat(wsDir(ws)); err != nil {
		return nil, errors.New("no such workspace")
	}
	if req.Module == "" {
		return nil, errors.New("module is required")
	}
	spec := &ExecSpec{
		Env:           map[string]string{"PWD": "/work", "HOME": "/work"},
		Dirs:          []Mount{{Host: wsDir(ws), Guest: "/work"}},
		TimeoutMs:     req.TimeoutMs,
		MemoryLimitMb: req.MemoryMb,
		Stdout:        runDir + "/stdout",
		Stderr:        runDir + "/stderr",
	}
	if tool, err := loadTool(req.Module); err == nil {
		spec.Module = toolDir(tool.Name) + "/" + path.Clean("/" + tool.Module)[1:]
		argv0 := tool.Argv0
		if argv0 == "" {
			argv0 = tool.Name
		}
		spec.Args = append([]string{argv0}, req.Args...)
		for k, v := range tool.Env {
			spec.Env[k] = v
		}
		for _, m := range tool.Mounts {
			spec.Dirs = append(spec.Dirs, Mount{
				Host: toolDir(tool.Name) + "/" + path.Clean("/" + m.Path)[1:], Guest: m.Guest, Readonly: true})
		}
	} else {
		rel, ok := cleanRel(req.Module)
		if !ok {
			return nil, errors.New("bad module path")
		}
		if _, err := os.Stat(wsDir(ws) + "/" + rel); err != nil {
			return nil, fmt.Errorf("module %q is neither a registered tool nor a file in the workspace", req.Module)
		}
		spec.Module = wsDir(ws) + "/" + rel
		spec.Args = append([]string{rel}, req.Args...)
	}
	for k, v := range req.Env {
		spec.Env[k] = v
	}
	if err := os.MkdirAll(runDir, 0o755); err != nil {
		return nil, err
	}
	if req.Stdin != "" {
		if err := os.WriteFile(runDir+"/stdin", []byte(req.Stdin), 0o644); err != nil {
			return nil, err
		}
		spec.Stdin = runDir + "/stdin"
	}
	return spec, nil
}

// ---- runs / jobs ----

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

func (s *server) jobResult(j *job, st *ExecStatus) map[string]any {
	res := map[string]any{
		"job_id": j.ID, "state": st.State, "done": st.Done, "exit_code": st.ExitCode,
		"error": st.Error, "wall_ms": st.WallMs, "load_ms": st.LoadMs, "cache": st.Cache,
	}
	if st.Done {
		out, t1 := readCapped(j.dir + "/stdout")
		errOut, t2 := readCapped(j.dir + "/stderr")
		res["stdout"], res["stderr"] = out, errOut
		if t1 || t2 {
			res["truncated"] = true
		}
	}
	return res
}

func (s *server) run(w http.ResponseWriter, r *http.Request) {
	var req runRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpErr(w, 400, "bad JSON: "+err.Error())
		return
	}
	j := &job{ID: s.newID("j"), Kind: "run", Workspace: r.PathValue("id"), Module: req.Module,
		Args: req.Args, Started: time.Now()}
	j.dir = dataDir + "/runs/" + j.ID
	spec, err := s.buildSpec(j.Workspace, &req, j.dir)
	if err != nil {
		httpErr(w, 400, err.Error())
		return
	}
	j.handle, err = host.Start(spec)
	if err != nil {
		httpErr(w, 500, err.Error())
		return
	}
	s.mu.Lock()
	s.jobs[j.ID] = j
	s.mu.Unlock()
	if r.URL.Query().Get("async") == "1" {
		writeJSON(w, 202, map[string]any{"job_id": j.ID, "state": "running"})
		return
	}
	st, err := waitDone(j.handle, r.Context().Done())
	if err != nil {
		httpErr(w, 500, err.Error())
		return
	}
	writeJSON(w, 200, s.jobResult(j, st))
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
		waitDone(j.handle, r.Context().Done())
	}
	st, err := host.Status(j.handle)
	if err != nil {
		httpErr(w, 500, err.Error())
		return
	}
	writeJSON(w, 200, s.jobResult(j, st))
}

func (s *server) killJob(w http.ResponseWriter, r *http.Request) {
	j := s.lookup(s.jobs, r.PathValue("id"))
	if j == nil {
		httpErr(w, 404, "no such job")
		return
	}
	host.Kill(j.handle)
	w.WriteHeader(202)
}

func (s *server) listJobs(w http.ResponseWriter, r *http.Request) {
	s.mu.Lock()
	list := make([]map[string]any, 0, len(s.jobs))
	for _, j := range s.jobs {
		st, _ := host.Status(j.handle)
		e := map[string]any{"job": j}
		if st != nil {
			e["state"], e["exit_code"] = st.State, st.ExitCode
		}
		list = append(list, e)
	}
	s.mu.Unlock()
	sort.Slice(list, func(a, b int) bool {
		return list[a]["job"].(*job).Started.Before(list[b]["job"].(*job).Started)
	})
	writeJSON(w, 200, map[string]any{"jobs": list})
}

// ---- services ----

func (s *server) serviceInfo(j *job) map[string]any {
	st, _ := host.Status(j.handle)
	info := map[string]any{"service_id": j.ID, "workspace": j.Workspace, "module": j.Module,
		"args": j.Args, "started": j.Started}
	if st != nil {
		info["state"], info["exit_code"], info["error"] = st.State, st.ExitCode, st.Error
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
	j := &job{ID: s.newID("s"), Kind: "service", Workspace: r.PathValue("id"), Module: req.Module,
		Args: req.Args, Started: time.Now()}
	j.dir = dataDir + "/runs/" + j.ID
	spec, err := s.buildSpec(j.Workspace, &req, j.dir)
	if err != nil {
		httpErr(w, 400, err.Error())
		return
	}
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

// ---- index ----

func (s *server) index(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/markdown; charset=utf-8")
	w.Write([]byte(strings.TrimSpace(apiDoc) + "\n"))
}

const apiDoc = `
# wasmdev — WebAssembly-native dev service for coding agents

Everything runs as WebAssembly (wasip1 core modules) executed natively by
the host's wasmtime. Upload files to a workspace, then run wasm modules
(your own, or registered tools like compilers) against it.

Auth: send "Authorization: Bearer <token>" on every /v1 request.
All bodies are JSON unless noted. Errors: {"error": "..."}.

## Workspaces
- POST   /v1/workspaces                         -> {"id"}   (mounted at /work, also $PWD)
- GET    /v1/workspaces
- DELETE /v1/workspaces/{id}
- PUT    /v1/workspaces/{id}/files/{path}       raw body = file contents
- GET    /v1/workspaces/{id}/files/{path}       raw contents; a directory (or "" / ".") -> JSON listing
- DELETE /v1/workspaces/{id}/files/{path}
- POST   /v1/workspaces/{id}/files              many files: {"files": {"a/b.txt": "text"}} or a tar (Content-Type: application/x-tar)

## Running
- POST /v1/workspaces/{id}/run
    {"module": "<tool name or path in workspace>", "args": [...], "env": {...},
     "stdin": "...", "timeout_ms": 60000, "memory_mb": 512}
  -> {"exit_code", "stdout", "stderr", "wall_ms", "state", "error", "cache", "load_ms"}
  state: exited | failed (trap/instantiation error, see "error") | killed | timeout
  Add ?async=1 to get {"job_id"} immediately, then:
- GET    /v1/jobs/{id}        (add ?wait=1 to block until done)
- DELETE /v1/jobs/{id}        kill
- GET    /v1/jobs

Modules must be wasip1 command modules (e.g. GOOS=wasip1 GOARCH=wasm, or
rustc --target wasm32-wasip1). They see only /work (+ tool mounts). No
network except for services. argv[0] is the module path or tool argv0.

## Services (long-running servers)
- POST /v1/workspaces/{id}/services  {"module", "args", "env"}
  -> {"service_id", "port", "url"}
  The host binds a TCP port and passes it as a preopened listening socket.
  Its fd number is in $WASMDEV_LISTEN_FD (3 + number of preopened dirs;
  normally 4 because /work is fd 3). In Go:
      fd, _ := strconv.Atoi(os.Getenv("WASMDEV_LISTEN_FD"))
      ln, _ := net.FileListener(os.NewFile(uintptr(fd), "l"))
      http.Serve(ln, handler)
  The socket starts non-blocking (what Go expects).
- GET    /v1/services
- GET    /v1/services/{id}
- GET    /v1/services/{id}/logs   -> {"stdout", "stderr"}
- DELETE /v1/services/{id}

## Tools (registry of wasm programs, e.g. compilers)
- GET    /v1/tools
- GET    /v1/tools/{name}
- PUT    /v1/tools/{name}    body = raw .wasm (optional ?argv0=&description=)
                             or a tar with tool.json + files:
     {"module": "bin/clang.wasm", "argv0": "clang",
      "mounts": [{"path": "sysroot", "guest": "/sysroot"}], "env": {}}
- DELETE /v1/tools/{name}
Run a tool by passing its name as "module". Tool mounts are read-only.

## Admin
- POST /v1/tokens {"agent": "name"} (admin token only) -> {"token"}
`
