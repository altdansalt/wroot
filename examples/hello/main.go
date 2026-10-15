// hello: tiny wasip1 command used by the demo. Echoes args, env, stdin and
// lists /work.
package main

import (
	"fmt"
	"io"
	"os"
	"strings"
)

func main() {
	fmt.Printf("hello from wasm! args=%q\n", os.Args)
	if v := os.Getenv("GREETING"); v != "" {
		fmt.Println("GREETING=" + v)
	}
	if len(os.Args) > 1 && os.Args[1] == "stdin" {
		b, _ := io.ReadAll(os.Stdin)
		fmt.Println("stdin:", strings.ToUpper(string(b)))
	}
	if len(os.Args) > 1 && os.Args[1] == "write" {
		if err := os.WriteFile("/work/out.txt", []byte("written by wasm\n"), 0o644); err != nil {
			fmt.Fprintln(os.Stderr, "write:", err)
			os.Exit(2)
		}
	}
	if len(os.Args) > 1 && os.Args[1] == "spin" {
		for {
		}
	}
	if len(os.Args) > 1 && os.Args[1] == "fail" {
		fmt.Fprintln(os.Stderr, "failing on purpose")
		os.Exit(3)
	}
}
