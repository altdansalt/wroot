// Command srv is a Go net/http service for wasmdev (wasip1): it serves on
// the listening socket the host passes in $WASMDEV_LISTEN_FD.
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"strconv"
	"sync/atomic"

	"example.com/w1/calc"
)

func listener() net.Listener {
	fd, err := strconv.Atoi(os.Getenv("WASMDEV_LISTEN_FD"))
	if err != nil { // not under wasmdev: normal TCP
		l, err := net.Listen("tcp", ":8080")
		if err != nil {
			log.Fatal(err)
		}
		return l
	}
	l, err := net.FileListener(os.NewFile(uintptr(fd), "listener"))
	if err != nil {
		log.Fatal(err)
	}
	return l
}

func main() {
	var hits atomic.Int64
	mux := http.NewServeMux()
	mux.HandleFunc("GET /fib/{n}", func(w http.ResponseWriter, r *http.Request) {
		n, err := strconv.Atoi(r.PathValue("n"))
		if err != nil || n < 0 || n > 90 {
			http.Error(w, "bad n", 400)
			return
		}
		hits.Add(1)
		json.NewEncoder(w).Encode(map[string]int{"n": n, "fib": calc.Fib(n)})
	})
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "ok hits=%d\n", hits.Load())
	})
	log.Printf("serving on fd %s", os.Getenv("WASMDEV_LISTEN_FD"))
	log.Fatal(http.Serve(listener(), mux))
}
