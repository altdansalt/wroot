package strutil

import (
	"fmt"
	"testing"
)

func TestReverse(t *testing.T) {
	for _, c := range []struct{ in, want string }{{"abc", "cba"}, {"", ""}, {"héllo", "olléh"}} {
		if got := Reverse(c.in); got != c.want {
			t.Errorf("Reverse(%q) = %q, want %q", c.in, got, c.want)
		}
	}
}

func ExampleShout() {
	fmt.Println(Shout("hi"))
	// Output: HI!
}
