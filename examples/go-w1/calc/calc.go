// Package calc has small arithmetic helpers.
package calc

// Sum returns a + (a+1) + ... + b.
func Sum(a, b int) int {
	s := 0
	for i := a; i <= b; i++ {
		s += i
	}
	return s
}

// Fib returns the n-th Fibonacci number (iteratively).
func Fib(n int) int {
	a, b := 0, 1
	for i := 0; i < n; i++ {
		a, b = b, a+b
	}
	return a
}
