package main

import (
	"fmt"
	"os"

	"example.com/testmod/calc"
	"example.com/testmod/strutil"
)

func main() {
	fmt.Println(strutil.Reverse("olleh"), calc.Add(2, 3), calc.Mul(4, 5))
	fmt.Fprintln(os.Stderr, "args:", os.Args[1:])
}
