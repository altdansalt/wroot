package calc

import "testing"

func TestSum(t *testing.T) {
	if got := Sum(1, 10); got != 55 {
		t.Fatalf("Sum(1,10) = %d, want 55", got)
	}
}

func TestFib(t *testing.T) {
	for n, want := range []int{0, 1, 1, 2, 3, 5, 8, 13} {
		if got := Fib(n); got != want {
			t.Errorf("Fib(%d) = %d, want %d", n, got, want)
		}
	}
}
