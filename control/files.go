package main

import (
	"archive/tar"
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"io/fs"
	"net/http"
	"os"
	"path"
	"regexp"
	"sort"
	"strings"
)

var idRe = regexp.MustCompile(`^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,63}$`)

func wsDir(id string) string { return dataDir + "/ws/" + id }

// wsRoot opens a workspace as an os.Root so that file operations cannot
// escape it via "..", absolute paths or symlinks created by workloads.
func wsRoot(w http.ResponseWriter, id string) *os.Root {
	if !idRe.MatchString(id) {
		httpErr(w, 400, "bad workspace id")
		return nil
	}
	root, err := os.OpenRoot(wsDir(id))
	if err != nil {
		httpErr(w, 404, "no such workspace")
		return nil
	}
	return root
}

func cleanRel(p string) (string, bool) {
	p = path.Clean("/" + p)[1:]
	return p, p != "" && p != "."
}

func (s *server) createWorkspace(w http.ResponseWriter, r *http.Request) {
	id := "w" + randHex(6)
	if err := os.MkdirAll(wsDir(id), 0o755); err != nil {
		httpErr(w, 500, err.Error())
		return
	}
	writeJSON(w, 201, map[string]string{"id": id, "mount": "/work"})
}

func (s *server) listWorkspaces(w http.ResponseWriter, r *http.Request) {
	ents, _ := os.ReadDir(dataDir + "/ws")
	ids := []string{}
	for _, e := range ents {
		if e.IsDir() {
			ids = append(ids, e.Name())
		}
	}
	writeJSON(w, 200, map[string]any{"workspaces": ids})
}

func (s *server) deleteWorkspace(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if !idRe.MatchString(id) {
		httpErr(w, 400, "bad workspace id")
		return
	}
	if err := os.RemoveAll(wsDir(id)); err != nil {
		httpErr(w, 500, err.Error())
		return
	}
	w.WriteHeader(204)
}

func writeInRoot(root *os.Root, rel string, data io.Reader) error {
	if dir := path.Dir(rel); dir != "." {
		if err := root.MkdirAll(dir, 0o755); err != nil {
			return err
		}
	}
	f, err := root.OpenFile(rel, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0o644)
	if err != nil {
		return err
	}
	if _, err := io.Copy(f, data); err != nil {
		f.Close()
		return err
	}
	return f.Close()
}

func (s *server) putFile(w http.ResponseWriter, r *http.Request) {
	root := wsRoot(w, r.PathValue("id"))
	if root == nil {
		return
	}
	defer root.Close()
	rel, ok := cleanRel(r.PathValue("path"))
	if !ok {
		httpErr(w, 400, "bad path")
		return
	}
	if err := writeInRoot(root, rel, r.Body); err != nil {
		httpErr(w, 400, err.Error())
		return
	}
	writeJSON(w, 200, map[string]string{"path": rel})
}

type fileEntry struct {
	Path string `json:"path"`
	Size int64  `json:"size"`
	Dir  bool   `json:"dir,omitempty"`
}

// getFile returns raw file contents, or a recursive JSON listing for a
// directory (use path "" or "." for the workspace root).
func (s *server) getFile(w http.ResponseWriter, r *http.Request) {
	root := wsRoot(w, r.PathValue("id"))
	if root == nil {
		return
	}
	defer root.Close()
	rel, ok := cleanRel(r.PathValue("path"))
	if !ok {
		rel = "."
	}
	st, err := root.Stat(rel)
	if err != nil {
		httpErr(w, 404, "not found")
		return
	}
	if st.IsDir() {
		entries := []fileEntry{}
		fs.WalkDir(root.FS(), rel, func(p string, d fs.DirEntry, err error) error {
			if err != nil || p == rel {
				return nil
			}
			info, _ := d.Info()
			e := fileEntry{Path: p, Dir: d.IsDir()}
			if info != nil && !d.IsDir() {
				e.Size = info.Size()
			}
			entries = append(entries, e)
			return nil
		})
		writeJSON(w, 200, map[string]any{"entries": entries})
		return
	}
	f, err := root.Open(rel)
	if err != nil {
		httpErr(w, 404, err.Error())
		return
	}
	defer f.Close()
	w.Header().Set("Content-Type", "application/octet-stream")
	io.Copy(w, f)
}

func (s *server) deleteFile(w http.ResponseWriter, r *http.Request) {
	root := wsRoot(w, r.PathValue("id"))
	if root == nil {
		return
	}
	defer root.Close()
	rel, ok := cleanRel(r.PathValue("path"))
	if !ok {
		httpErr(w, 400, "bad path")
		return
	}
	if err := root.RemoveAll(rel); err != nil {
		httpErr(w, 400, err.Error())
		return
	}
	w.WriteHeader(204)
}

// putFiles accepts many files at once: a tar archive (Content-Type
// application/x-tar) or JSON {"files": {"path": "utf-8 content", ...}}.
func (s *server) putFiles(w http.ResponseWriter, r *http.Request) {
	root := wsRoot(w, r.PathValue("id"))
	if root == nil {
		return
	}
	defer root.Close()
	var written []string
	var err error
	if strings.Contains(r.Header.Get("Content-Type"), "tar") {
		written, err = extractTar(root, r.Body)
	} else {
		var req struct {
			Files map[string]string `json:"files"`
		}
		if err = json.NewDecoder(r.Body).Decode(&req); err == nil {
			keys := make([]string, 0, len(req.Files))
			for k := range req.Files {
				keys = append(keys, k)
			}
			sort.Strings(keys)
			for _, k := range keys {
				rel, ok := cleanRel(k)
				if !ok {
					err = errors.New("bad path " + k)
					break
				}
				if err = writeInRoot(root, rel, strings.NewReader(req.Files[k])); err != nil {
					break
				}
				written = append(written, rel)
			}
		}
	}
	if err != nil {
		httpErr(w, 400, err.Error())
		return
	}
	writeJSON(w, 200, map[string]any{"written": written})
}

func extractTar(root *os.Root, body io.Reader) ([]string, error) {
	var written []string
	tr := tar.NewReader(body)
	for {
		h, err := tr.Next()
		if err == io.EOF {
			return written, nil
		}
		if err != nil {
			return written, err
		}
		rel, ok := cleanRel(h.Name)
		if !ok {
			continue
		}
		switch h.Typeflag {
		case tar.TypeDir:
			if err := root.MkdirAll(rel, 0o755); err != nil {
				return written, err
			}
		case tar.TypeReg:
			if err := writeInRoot(root, rel, tr); err != nil {
				return written, err
			}
			if h.Mode&0o111 != 0 {
				root.Chmod(rel, 0o755)
			}
			written = append(written, rel)
		default:
			// symlinks/devices are ignored on purpose
		}
	}
}

func isTar(b []byte) bool {
	return len(b) > 262 && bytes.Equal(b[257:262], []byte("ustar"))
}
