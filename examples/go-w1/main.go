// Command w1 is a small multi-package Go program for the wasmdev demo.
package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"

	"example.com/w1/calc"
	"example.com/w1/strutil"
)

func main() {
	name := "world"
	if len(os.Args) > 1 {
		name = os.Args[1]
	}
	fmt.Printf("hello, %s! sum(1..10)=%d fib(30)=%d\n", strutil.Title(name), calc.Sum(1, 10), calc.Fib(30))
	// count words on stdin, if any
	sc := bufio.NewScanner(os.Stdin)
	words := 0
	for sc.Scan() {
		words += len(strings.Fields(sc.Text()))
	}
	if words > 0 {
		fmt.Printf("stdin words: %d, reversed name: %s\n", words, strutil.Reverse(name))
	}
}
