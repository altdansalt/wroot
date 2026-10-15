package main

import (
	"bufio"
	"log"
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"path"
	"sort"
	"sync"
	"time"
)

// ---- tool registry ----
//
// A tool is a directory /data/tools/<name>/ with a tool.json manifest and
// the files it references. Tools are run by name (POST .../run
// {"module": "<name>"}) or through one of the commands they export
// ("cc", "c++", "ar", ...), which may be handled by a driver (see cc.go).

type toolManifest struct {
	Name        string            `json:"name"`
	Module      string            `json:"module"` // relative to tool dir
	Argv0       string            `json:"argv0,omitempty"`
	Mounts      []toolMount       `json:"mounts,omitempty"`
	Env         map[string]string `json:"env,omitempty"`
	Description string            `json:"description,omitempty"`
	// Scratch, if set, is a guest path where each invocation gets a fresh
	// writable scratch dir (e.g. "/tmp" for clang's temporary objects).
	// One driver invocation shares it across all its steps.
	Scratch string `json:"scratch,omitempty"`
	// Commands exported by this tool: command name -> argv prefix after
	// argv0. E.g. the llvm multicall module exports
	// {"cc": ["clang"], "ar": ["ar"]}.
	Commands map[string][]string `json:"commands,omitempty"`
	// Driver handles commands whose prefix starts with one of its
	// programs instead of running them directly (e.g. "clang").
	Driver string     `json:"driver,omitempty"`
	Clang  *clangConf `json:"clang,omitempty"`
	// Spawn: the tool runs child processes (wasmdev_proc), e.g. cmd/go
	// spawning compile/link and test binaries. Children see the same
	// mounts; the run's max_wasm_stack applies to them.
	Spawn bool `json:"spawn,omitempty"`
	// ScratchCompiler: compiler for modules spawned from the scratch dir
	// (freshly built, run once: Go test binaries) - "winch" compiles ~5x
	// faster than Cranelift. Such modules are cached in memory only.
	ScratchCompiler string `json:"scratch_compiler,omitempty"`
	// Shared: persistent read-write dirs shared by every invocation of
	// the tool in every workspace (e.g. GOCACHE, which is content-addressed
	// and safe to share). Stored in /data/cache/<tool>/<name>.
	Shared []toolShared `json:"shared,omitempty"`
	// PrecompileModules: more modules (relative to the tool dir) to compile
	// into the host cache at registration, e.g. the tools cmd/go spawns.
	PrecompileModules []string `json:"precompile_modules,omitempty"`
	// Warm: run once after precompiling (in a scratch workspace) so the
	// first real call is fast, e.g. build+vet+test a program that imports
	// net/http and testing to fill GOCACHE with the std library.
	Warm *toolWarm `json:"warm,omitempty"`
	// Env values may contain {cpus} (host cores).

	Precompile *toolPrecompile `json:"precompile,omitempty"` // runtime status, not stored
}

type toolShared struct {
	Name  string `json:"name"`
	Guest string `json:"guest"`
}

type toolWarm struct {
	Files map[string]string `json:"files"`
	Cmd   string            `json:"cmd"`
}

func sharedDir(tool, name string) string { return dataDir + "/cache/" + tool + "/" + name }

type toolMount struct {
	Path  string `json:"path"`  // relative to tool dir
	Guest string `json:"guest"` // e.g. /usr
}

type toolPrecompile struct {
	State   string  `json:"state"` // running | warming | done | failed
	Cache   *string `json:"cache,omitempty"`
	LoadMs  float64 `json:"load_ms,omitempty"`
	Modules int     `json:"modules,omitempty"` // modules compiled/loaded
	Ms      float64 `json:"ms,omitempty"`      // total precompile time
	WarmMs  float64 `json:"warm_ms,omitempty"`
	Error   *string `json:"error,omitempty"`
	done    chan struct{}
}

func toolDir(name string) string { return dataDir + "/tools/" + name }

func (m *toolManifest) modulePath() string {
	return toolDir(m.Name) + "/" + path.Clean("/" + m.Module)[1:]
}

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
	m.Precompile = nil
	return &m, nil
}

// toolRegistry caches manifests and the command index; it is rebuilt
// whenever a tool is added or removed.
type toolRegistry struct {
	mu       sync.Mutex
	tools    map[string]*toolManifest
	commands map[string]toolCommand
	pre      map[string]*toolPrecompile
}

type toolCommand struct {
	Tool   *toolManifest
	Prefix []string
}

func (r *toolRegistry) reload() {
	ents, _ := os.ReadDir(dataDir + "/tools")
	tools := map[string]*toolManifest{}
	names := []string{}
	for _, e := range ents {
		if m, err := loadTool(e.Name()); err == nil {
			tools[m.Name] = m
			names = append(names, m.Name)
		}
	}
	sort.Strings(names)
	cmds := map[string]toolCommand{}
	for _, n := range names {
		for c, prefix := range tools[n].Commands {
			if _, dup := cmds[c]; !dup {
				cmds[c] = toolCommand{tools[n], prefix}
			}
		}
	}
	r.mu.Lock()
	r.tools, r.commands = tools, cmds
	if r.pre == nil {
		r.pre = map[string]*toolPrecompile{}
	}
	r.mu.Unlock()
}

func (r *toolRegistry) tool(name string) *toolManifest {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.tools[name]
}

func (r *toolRegistry) command(name string) (toolCommand, bool) {
	r.mu.Lock()
	defer r.mu.Unlock()
	c, ok := r.commands[name]
	return c, ok
}

// withStatus returns a copy of m with its precompile status filled in.
func (r *toolRegistry) withStatus(m *toolManifest) *toolManifest {
	c := *m
	r.mu.Lock()
	if p := r.pre[m.Name]; p != nil {
		pc := *p
		c.Precompile = &pc
	}
	r.mu.Unlock()
	return &c
}

// precompile asks the host to compile the tool's modules into its cache
// (memory + disk) in the background, so the first real invocation does
// not pay for compiling a 75 MB module (~100-250 s for clang), then runs
// the tool's warm-up if it has one and it hasn't run yet. The host
// serializes compiles, so registering several big tools is safe on a
// small VM. Returns a channel closed when done.
func (s *server) precompile(m *toolManifest, forceWarm bool) <-chan struct{} {
	r := s.tools
	p := &toolPrecompile{State: "running", done: make(chan struct{})}
	r.mu.Lock()
	r.pre[m.Name] = p
	r.mu.Unlock()
	set := func(f func()) {
		r.mu.Lock()
		f()
		r.mu.Unlock()
	}
	go func() {
		defer close(p.done)
		t0 := time.Now()
		mods := append([]string{m.Module}, m.PrecompileModules...)
		for i, rel := range mods {
			h, err := host.Start(&ExecSpec{Module: toolDir(m.Name) + "/" + path.Clean("/" + rel)[1:],
				Args: []string{rel}, PrecompileOnly: true})
			var st *ExecStatus
			if err == nil {
				st, err = waitDone(h, nil)
				host.Release(h)
			}
			if err == nil && st.State != "exited" {
				err = fmt.Errorf("%s: %s", rel, deref(st.Error))
			}
			if err != nil {
				e := err.Error()
				set(func() { p.State, p.Error = "failed", &e })
				return
			}
			set(func() {
				p.Modules = i + 1
				if i == 0 {
					p.Cache, p.LoadMs = st.Cache, st.LoadMs
				}
			})
		}
		set(func() { p.Ms = msSince(t0) })
		if m.Warm == nil {
			set(func() { p.State = "done" })
			return
		}
		marker := sharedDir(m.Name, ".warm-done")
		if _, err := os.Stat(marker); err == nil && !forceWarm {
			set(func() { p.State = "done" })
			return
		}
		set(func() { p.State = "warming" })
		t1 := time.Now()
		res, err := s.warmTool(m)
		set(func() {
			p.WarmMs = msSince(t1)
			if err != nil {
				e := err.Error()
				p.State, p.Error = "failed", &e
				return
			}
			p.State = "done"
		})
		if err == nil {
			os.MkdirAll(path.Dir(marker), 0o755)
			os.WriteFile(marker, []byte(res), 0o644)
		}
	}()
	return p.done
}

// warmTool runs the tool's warm-up command in a scratch workspace,
// through the same job machinery as an API run.
func (s *server) warmTool(m *toolManifest) (string, error) {
	ws := "warm-" + m.Name
	dir := wsDir(ws)
	os.RemoveAll(dir)
	defer os.RemoveAll(dir)
	for name, body := range m.Warm.Files {
		rel, ok := cleanRel(name)
		if !ok {
			return "", fmt.Errorf("warm: bad file name %q", name)
		}
		os.MkdirAll(path.Dir(dir+"/"+rel), 0o755)
		if err := os.WriteFile(dir+"/"+rel, []byte(body), 0o644); err != nil {
			return "", err
		}
	}
	req := &runRequest{Cmd: m.Warm.Cmd}
	j, err := s.startJob(ws, req)
	if err != nil {
		return "", fmt.Errorf("warm: %v", err)
	}
	<-j.done
	res := s.jobResult(j)
	s.mu.Lock()
	delete(s.jobs, j.ID)
	s.mu.Unlock()
	os.RemoveAll(j.dir)
	b, _ := json.MarshalIndent(res, "", "  ")
	if ec, _ := res["exit_code"].(*int); res["state"] != "exited" || ec == nil || *ec != 0 {
		return "", fmt.Errorf("warm-up %q failed: %s", m.Warm.Cmd, b)
	}
	log.Printf("tool %s warmed in %.1f s", m.Name, res["wall_ms"].(float64)/1e3)
	return string(b), nil
}

func deref(p *string) string {
	if p == nil {
		return ""
	}
	return *p
}

func msSince(t time.Time) float64 { return float64(time.Since(t).Microseconds()) / 1e3 }

// warmAll precompiles (or loads from the host's disk cache) every
// registered tool; called at startup.
func (s *server) warmAll() {
	r := s.tools
	r.mu.Lock()
	list := make([]*toolManifest, 0, len(r.tools))
	for _, m := range r.tools {
		list = append(list, m)
	}
	r.mu.Unlock()
	sort.Slice(list, func(a, b int) bool { return list[a].Name < list[b].Name })
	for _, m := range list {
		s.precompile(m, false) // host serializes the compiles
	}
}

func (s *server) listTools(w http.ResponseWriter, r *http.Request) {
	s.tools.mu.Lock()
	names := make([]string, 0, len(s.tools.tools))
	for n := range s.tools.tools {
		names = append(names, n)
	}
	s.tools.mu.Unlock()
	sort.Strings(names)
	tools := []*toolManifest{}
	for _, n := range names {
		if m := s.tools.tool(n); m != nil {
			tools = append(tools, s.tools.withStatus(m))
		}
	}
	writeJSON(w, 200, map[string]any{"tools": tools})
}

func (s *server) getTool(w http.ResponseWriter, r *http.Request) {
	m := s.tools.tool(r.PathValue("name"))
	if m == nil {
		httpErr(w, 404, "no such tool")
		return
	}
	if r.URL.Query().Get("wait") == "1" {
		s.tools.mu.Lock()
		p := s.tools.pre[m.Name]
		s.tools.mu.Unlock()
		if p != nil {
			select {
			case <-p.done:
			case <-r.Context().Done():
			}
		}
	}
	writeJSON(w, 200, s.tools.withStatus(m))
}

func (s *server) deleteTool(w http.ResponseWriter, r *http.Request) {
	name := r.PathValue("name")
	if !idRe.MatchString(name) {
		httpErr(w, 400, "bad tool name")
		return
	}
	os.RemoveAll(toolDir(name))
	s.tools.reload()
	w.WriteHeader(204)
}

// putTool registers a tool from either a raw wasm module (body starts with
// "\0asm") or a tar archive containing tool.json + files. Query params
// argv0 and description fill in the manifest for raw modules. The body is
// streamed (toolchain tars are ~200 MB). The module is then precompiled in
// the background; ?wait=1 blocks until that is done.
func (s *server) putTool(w http.ResponseWriter, r *http.Request) {
	name := r.PathValue("name")
	if !idRe.MatchString(name) {
		httpErr(w, 400, "bad tool name")
		return
	}
	body := bufio.NewReaderSize(r.Body, 1<<16)
	head, _ := body.Peek(512)
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
	t0 := time.Now()
	switch {
	case bytes.HasPrefix(head, []byte("\x00asm")):
		if err := writeInRoot(root, name+".wasm", body); err != nil {
			httpErr(w, 500, err.Error())
			return
		}
		m := toolManifest{Name: name, Module: name + ".wasm", Argv0: r.URL.Query().Get("argv0"),
			Description: r.URL.Query().Get("description")}
		b, _ := json.MarshalIndent(m, "", "  ")
		os.WriteFile(tmp+"/tool.json", b, 0o644)
	case isTar(head):
		if _, err := extractTar(root, body); err != nil {
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
	upload := time.Since(t0)
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
	if _, err := os.Stat(m.modulePath()); err != nil {
		httpErr(w, 400, "tool module not found: "+m.Module)
		return
	}
	s.tools.reload()
	done := s.precompile(m, true)
	if r.URL.Query().Get("wait") == "1" {
		select {
		case <-done:
		case <-r.Context().Done():
		}
	}
	res := s.tools.withStatus(m)
	writeJSON(w, 201, map[string]any{"tool": res, "upload_ms": float64(upload.Microseconds()) / 1e3})
}
