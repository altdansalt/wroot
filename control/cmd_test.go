package main

import (
	"reflect"
	"testing"
)

func TestSplitCmd(t *testing.T) {
	got, err := splitCmd(`cc -O2 -o "my app.wasm" 'a b.c' x\ y.c -DX=\"s\" && ./app.wasm "*.c"`)
	if err != nil {
		t.Fatal(err)
	}
	want := [][]string{{"cc", "-O2", "-o", "my app.wasm", "a b.c", "x y.c", `-DX="s"`}, {"./app.wasm", "*.c"}}
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("got %q", got)
	}
	for _, bad := range []string{"a | b", "a > f", "a && ", "&& a", `"open`, "a; b"} {
		if _, err := splitCmd(bad); err == nil {
			t.Errorf("%q: expected error", bad)
		}
	}
}

func TestParseJobs(t *testing.T) {
	out := "clang version 22.1.0\nTarget: wasm32-unknown-wasip1\nwarning: foo\n" +
		` "" "clang" "-cc1" "-o" "/tmp/a.o" "-D" "X=\"q\"" "a.c"` + "\n" +
		` "wasm-ld" "-m" "wasm32" "/tmp/a.o" "-o" "a.wasm"` + "\n"
	jobs, other := parseJobs(out)
	want := [][]string{{"clang", "-cc1", "-o", "/tmp/a.o", "-D", `X="q"`, "a.c"}, {"wasm-ld", "-m", "wasm32", "/tmp/a.o", "-o", "a.wasm"}}
	if !reflect.DeepEqual(jobs, want) {
		t.Fatalf("jobs %q", jobs)
	}
	if len(other) != 3 || isBanner(other[2]) || !isBanner(other[0]) {
		t.Fatalf("other %q", other)
	}
}
