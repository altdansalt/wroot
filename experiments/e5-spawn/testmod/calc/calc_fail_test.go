//go:build failing

package calc

import "testing"

// Enabled with -tags failing: the "one variant that fails".
func TestMulWrong(t *testing.T) {
	if got := Mul(2, 2); got != 5 {
		t.Errorf("Mul(2,2) = %d, want 5", got)
	}
}
