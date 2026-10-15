package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"sort"
	"time"
)

// ---- services ----

func (s *server) serviceInfo(j *job) map[string]any {
	st, _ := host.Status(j.handle)
	info := map[string]any{"service_id": j.ID, "workspace": j.Workspace, "module": j.Module,
		"args": j.Args, "started": j.Started}
	if st != nil {
		info["state"], info["exit_code"], info["error"], info["kind"] = st.State, st.ExitCode, st.Error, st.Kind
		if st.Trap != nil {
			info["trap"] = *st.Trap
		}
		if st.Port != nil {
			info["port"] = *st.Port
			// url: what a client should use (the public HTTPS proxy when
			// the service has a public host); local_url: on this machine.
			info["local_url"] = fmt.Sprintf("http://127.0.0.1:%d/", *st.Port)
			if s.pubURL != "" {
				info["url"] = fmt.Sprintf("%s:%d/", s.pubURL, *st.Port)
			} else {
				info["url"] = info["local_url"]
			}
		}
	}
	j.mu.Lock()
	if j.readyMs != nil {
		info["ready"], info["ready_ms"] = true, *j.readyMs
	}
	j.mu.Unlock()
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
		// Same tiering as runs: a service started right after a build
		// starts fast (Winch); a restart uses Cranelift code once ready.
		spec = s.moduleSpec(ws, &req, inv.file, inv.args)
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
	go s.watchReady(j)
	if !req.WaitReady {
		writeJSON(w, 201, s.serviceInfo(j))
		return
	}
	timeout := 30 * time.Second
	if req.ReadyTimeoutMs > 0 {
		timeout = time.Duration(req.ReadyTimeoutMs) * time.Millisecond
	}
	info := s.waitReady(j, timeout, r.Context().Done())
	writeJSON(w, 201, info)
}

// watchReady records when service j first accepts connections (wasip1:
// it called accept on its listener; wasip2: its port accepts a TCP
// connection). Polls with backoff; gives up when the service exits.
func (s *server) watchReady(j *job) {
	d := 200 * time.Microsecond
	for {
		if host.Ready(j.handle) == 1 {
			ms := msSince(j.Started)
			j.mu.Lock()
			j.readyMs = &ms
			j.mu.Unlock()
			return
		}
		st, err := host.Status(j.handle)
		if err != nil || st.Done {
			return
		}
		time.Sleep(d)
		if d < 50*time.Millisecond {
			d *= 2
		}
	}
}

// waitReady blocks until service j is ready, has exited, or timeout.
func (s *server) waitReady(j *job, timeout time.Duration, cancel <-chan struct{}) map[string]any {
	deadline := time.Now().Add(timeout)
	for {
		info := s.serviceInfo(j)
		if info["ready"] == true {
			return info
		}
		if st, _ := host.Status(j.handle); st == nil || st.Done || time.Now().After(deadline) {
			info["ready"] = false
			if st != nil && !st.Done {
				info["error"] = fmt.Sprintf("not accepting connections after %v (still running; check logs)", timeout)
			}
			out, _ := readCapped(j.dir + "/stdout")
			errOut, _ := readCapped(j.dir + "/stderr")
			info["stdout"], info["stderr"] = tail(out, 4096), tail(errOut, 4096)
			return info
		}
		select {
		case <-cancel:
			return info
		case <-time.After(2 * time.Millisecond):
		}
	}
}

func tail(s string, n int) string {
	if len(s) > n {
		return s[len(s)-n:]
	}
	return s
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
