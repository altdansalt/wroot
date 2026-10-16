package main

import (
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
)

func main() {
	l, err := net.FileListener(os.NewFile(3, "listener"))
	if err != nil {
		log.Fatal(err)
	}
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "hello from a Go http server compiled by wasm toolchain; path=%s\n", r.URL.Path)
	})
	log.Fatal(http.Serve(l, nil))
}
