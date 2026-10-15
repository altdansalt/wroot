// Command control is the wasmdev control plane. It is compiled to wasip1
// and runs inside wasmdev-host, which hands it:
//
//   - a listening TCP socket (fd $WASMDEV_LISTEN_FD),
//   - the data dir preopened at /data,
//   - the `wasmdev` imports to run other wasm modules natively.
//
// Everything here is ordinary Go: net/http, encoding/json, os.
package main

import (
	"crypto/rand"
	"crypto/subtle"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"
)

const dataDir = "/data"

type ExecSpec struct {
	Module        string            `json:"module"`
	Args          []string          `json:"args"`
	Env           map[string]string `json:"env,omitempty"`
	Dirs          []Mount           `json:"dirs,omitempty"`
	Stdin         string            `json:"stdin,omitempty"`
	Stdout        string            `json:"stdout,omitempty"`
	Stderr        string            `json:"stderr,omitempty"`
	TimeoutMs     int64             `json:"timeout_ms,omitempty"`
	MemoryLimitMb int64             `json:"memory_limit_mb,omitempty"`
	Listen        bool              `json:"listen,omitempty"`
}

type Mount struct {
	Host     string `json:"host"`
	Guest    string `json:"guest"`
	Readonly bool   `json:"readonly,omitempty"`
}

type ExecStatus struct {
	Handle   int64   `json:"handle"`
	State    string  `json:"state"`
	Done     bool    `json:"done"`
	ExitCode *int    `json:"exit_code"`
	Error    *string `json:"error"`
	WallMs   float64 `json:"wall_ms"`
	LoadMs   float64 `json:"load_ms"`
	Cache    *string `json:"cache"`
	Port     *int    `json:"port"`
	ListenFd *int    `json:"listen_fd"`
}

var host hostImpl

type server struct {
	mu       sync.Mutex
	nextID   int
	jobs     map[string]*job
	services map[string]*job
	tokens   *tokenStore
	pubHost  string
}

type job struct {
	ID        string    `json:"id"`
	Kind      string    `json:"kind"` // run | service
	Workspace string    `json:"workspace"`
	Module    string    `json:"module"`
	Args      []string  `json:"args"`
	Started   time.Time `json:"started"`
	handle    int64
	dir       string // /data/runs/<id>
}

func main() {
	log.SetFlags(log.Lmicroseconds)
	fd := 3
	if v := os.Getenv("WASMDEV_LISTEN_FD"); v != "" {
		fd, _ = strconv.Atoi(v)
	}
	ln, err := net.FileListener(os.NewFile(uintptr(fd), "listener"))
	if err != nil {
		log.Fatalf("listener fd %d: %v", fd, err)
	}
	for _, d := range []string{"ws", "runs", "tools"} {
		if err := os.MkdirAll(dataDir+"/"+d, 0o755); err != nil {
			log.Fatal(err)
		}
	}
	s := &server{
		jobs:     map[string]*job{},
		services: map[string]*job{},
		tokens:   loadTokens(os.Getenv("WASMDEV_TOKEN")),
		pubHost:  os.Getenv("WASMDEV_PUBLIC_HOST"),
	}
	if s.pubHost == "" {
		s.pubHost = "127.0.0.1"
	}
	log.Printf("wasmdev control plane listening (fd %d, %s)", fd, ln.Addr())
	log.Fatal(http.Serve(ln, s.routes()))
}

func (s *server) routes() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /{$}", s.index)
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("ok\n")) })
	a := func(pattern string, h http.HandlerFunc) { mux.Handle(pattern, s.auth(h)) }
	a("POST /v1/tokens", s.createToken)
	a("POST /v1/workspaces", s.createWorkspace)
	a("GET /v1/workspaces", s.listWorkspaces)
	a("DELETE /v1/workspaces/{id}", s.deleteWorkspace)
	a("PUT /v1/workspaces/{id}/files/{path...}", s.putFile)
	a("GET /v1/workspaces/{id}/files/{path...}", s.getFile)
	a("DELETE /v1/workspaces/{id}/files/{path...}", s.deleteFile)
	a("POST /v1/workspaces/{id}/files", s.putFiles)
	a("POST /v1/workspaces/{id}/run", s.run)
	a("GET /v1/jobs", s.listJobs)
	a("GET /v1/jobs/{id}", s.getJob)
	a("DELETE /v1/jobs/{id}", s.killJob)
	a("POST /v1/workspaces/{id}/services", s.startService)
	a("GET /v1/services", s.listServices)
	a("GET /v1/services/{id}", s.getService)
	a("GET /v1/services/{id}/logs", s.serviceLogs)
	a("DELETE /v1/services/{id}", s.stopService)
	a("GET /v1/tools", s.listTools)
	a("GET /v1/tools/{name}", s.getTool)
	a("PUT /v1/tools/{name}", s.putTool)
	a("DELETE /v1/tools/{name}", s.deleteTool)
	return mux
}

// ---- auth ----

type tokenStore struct {
	mu     sync.Mutex
	admin  string
	agents map[string]string // token -> agent name
}

const tokensFile = dataDir + "/tokens.json"

func loadTokens(admin string) *tokenStore {
	t := &tokenStore{admin: admin, agents: map[string]string{}}
	if b, err := os.ReadFile(tokensFile); err == nil {
		json.Unmarshal(b, &t.agents)
	}
	return t
}

// check returns the agent name for a token ("admin" for the admin token).
func (t *tokenStore) check(tok string) (string, bool) {
	t.mu.Lock()
	defer t.mu.Unlock()
	if t.admin != "" && subtle.ConstantTimeCompare([]byte(tok), []byte(t.admin)) == 1 {
		return "admin", true
	}
	name, ok := t.agents[tok]
	return name, ok
}

func (s *server) auth(h http.HandlerFunc) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		tok, ok := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer ")
		who, valid := "", false
		if ok {
			who, valid = s.tokens.check(tok)
		}
		if !valid {
			w.Header().Set("WWW-Authenticate", "Bearer")
			httpErr(w, http.StatusUnauthorized, "missing or invalid bearer token")
			return
		}
		r.Header.Set("X-Wasmdev-Agent", who)
		h(w, r)
	})
}

func (s *server) createToken(w http.ResponseWriter, r *http.Request) {
	if r.Header.Get("X-Wasmdev-Agent") != "admin" {
		httpErr(w, http.StatusForbidden, "only the admin token can mint agent tokens")
		return
	}
	var req struct {
		Agent string `json:"agent"`
	}
	json.NewDecoder(r.Body).Decode(&req)
	if req.Agent == "" {
		req.Agent = "agent"
	}
	tok := randHex(16)
	t := s.tokens
	t.mu.Lock()
	t.agents[tok] = req.Agent
	b, _ := json.MarshalIndent(t.agents, "", " ")
	t.mu.Unlock()
	if err := os.WriteFile(tokensFile, b, 0o600); err != nil {
		httpErr(w, 500, err.Error())
		return
	}
	writeJSON(w, 201, map[string]string{"agent": req.Agent, "token": tok})
}

// ---- helpers ----

func randHex(n int) string {
	b := make([]byte, n)
	rand.Read(b)
	return hex.EncodeToString(b)
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	enc := json.NewEncoder(w)
	enc.SetIndent("", "  ")
	enc.Encode(v)
}

func httpErr(w http.ResponseWriter, code int, msg string) {
	writeJSON(w, code, map[string]string{"error": msg})
}

func (s *server) newID(prefix string) string {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.nextID++
	return fmt.Sprintf("%s%d-%s", prefix, s.nextID, randHex(3))
}
