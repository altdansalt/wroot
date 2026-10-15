package calc

import "testing"

// Uploaded by the demo to show a failing test.
func TestSumWrong(t *testing.T) {
	if got := Sum(1, 3); got != 7 {
		t.Errorf("Sum(1,3) = %d, want 7 (deliberately wrong expectation)", got)
	}
}
