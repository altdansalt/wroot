package calc

import "testing"

func TestAdd(t *testing.T) {
	if got := Add(2, 3); got != 5 {
		t.Fatalf("Add(2,3) = %d", got)
	}
}

func TestMul(t *testing.T) {
	if got := Mul(4, 5); got != 20 {
		t.Fatalf("Mul(4,5) = %d", got)
	}
}
