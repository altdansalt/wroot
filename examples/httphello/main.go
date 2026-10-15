// httphello: wasip1 net/http service. The host passes a listening socket;
// its fd number is in $WASMDEV_LISTEN_FD.
package main

import (
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"strconv"
	"sync/atomic"
)

func main() {
	fd, err := strconv.Atoi(os.Getenv("WASMDEV_LISTEN_FD"))
	if err != nil {
		log.Fatal("WASMDEV_LISTEN_FD not set")
	}
	ln, err := net.FileListener(os.NewFile(uintptr(fd), "listener"))
	if err != nil {
		log.Fatal(err)
	}
	var hits atomic.Int64
	log.Printf("httphello serving on fd %d", fd)
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		n := hits.Add(1)
		fmt.Fprintf(w, "hello from a wasm service! path=%s hit=%d\n", r.URL.Path, n)
	})
	log.Fatal(http.Serve(ln, nil))
}
