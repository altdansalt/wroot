package main

import (
	"reflect"
	"strings"
	"testing"
)

// words strips glob marks, for comparing parsed commands.
func words(sc simpleCmd) []string {
	var w []string
	for _, x := range sc.Words {
		w = append(w, unmark(x))
	}
	return w
}

func TestParseCmdWords(t *testing.T) {
	l, err := parseCmd(`cc -O2 -o "my app.wasm" 'a b.c' x\ y.c -DX=\"s\" && ./app.wasm "*.c"`)
	if err != nil {
		t.Fatal(err)
	}
	if len(l.Pipes) != 2 || !reflect.DeepEqual(l.Ops, []string{"&&"}) {
		t.Fatalf("got %+v", l)
	}
	got := [][]string{words(l.Pipes[0].Cmds[0]), words(l.Pipes[1].Cmds[0])}
	want := [][]string{{"cc", "-O2", "-o", "my app.wasm", "a b.c", "x y.c", `-DX="s"`}, {"./app.wasm", "*.c"}}
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("got %q", got)
	}
	// quoted glob characters are not marked for expansion; unquoted ones are
	if strings.ContainsRune(l.Pipes[1].Cmds[0].Words[1], 0) {
		t.Errorf("quoted glob was marked")
	}
	l, _ = parseCmd(`cc *.c`)
	if !strings.ContainsRune(l.Pipes[0].Cmds[0].Words[1], 0) {
		t.Errorf("unquoted glob not marked")
	}
}

func TestParseCmdOperators(t *testing.T) {
	l, err := parseCmd(`./gen.wasm 10 | ./sort.wasm > out.txt 2>&1 || echo failed; cat < in.txt >> log 2> err.txt`)
	if err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(l.Ops, []string{"||", ";"}) || len(l.Pipes) != 3 {
		t.Fatalf("ops %q pipes %d", l.Ops, len(l.Pipes))
	}
	p0 := l.Pipes[0]
	if len(p0.Cmds) != 2 || !reflect.DeepEqual(words(p0.Cmds[1]), []string{"./sort.wasm"}) {
		t.Fatalf("pipeline %+v", p0)
	}
	wantR := []redir{{Fd: 1, Op: ">", Target: "out.txt"}, {Fd: 2, Op: ">&1"}}
	if !reflect.DeepEqual(p0.Cmds[1].Redirs, wantR) {
		t.Fatalf("redirs %+v", p0.Cmds[1].Redirs)
	}
	c := l.Pipes[2].Cmds[0]
	wantR = []redir{{Fd: 0, Op: "<", Target: "in.txt"}, {Fd: 1, Op: ">>", Target: "log"}, {Fd: 2, Op: ">", Target: "err.txt"}}
	if !reflect.DeepEqual(words(c), []string{"cat"}) || !reflect.DeepEqual(c.Redirs, wantR) {
		t.Fatalf("cmd %+v", c)
	}
	// "2" is only a fd when unquoted and directly before >
	l, _ = parseCmd(`echo 2 > f && echo "2"> g && echo a2>h`)
	if got := words(l.Pipes[0].Cmds[0]); !reflect.DeepEqual(got, []string{"echo", "2"}) {
		t.Errorf("echo 2 > f: %q", got)
	}
	if r := l.Pipes[1].Cmds[0].Redirs[0]; r.Fd != 1 {
		t.Errorf(`"2">: %+v`, r)
	}
	if got := words(l.Pipes[2].Cmds[0]); !reflect.DeepEqual(got, []string{"echo", "a2"}) {
		t.Errorf("a2>h: %q", got)
	}
	// trailing ; is allowed
	if l, err := parseCmd(`true;`); err != nil || len(l.Pipes) != 1 {
		t.Errorf("trailing ;: %v %+v", err, l)
	}
}

func TestParseCmdErrors(t *testing.T) {
	for _, bad := range []string{"a &&", "&& a", `"open`, "a | | b", "a > ", "< in", "a & b",
		"echo $HOME", "echo `x`", "(a)", "a || ", "", "   "} {
		if _, err := parseCmd(bad); err == nil {
			t.Errorf("%q: expected error", bad)
		}
	}
}

func TestLineDiff(t *testing.T) {
	a := splitLines("a\nb\nc\nd\n")
	b := splitLines("a\nB\nc\nd\ne\n")
	got := lineDiff(a, b)
	want := "@@ -2,1 +2,1 @@\n-b\n+B\n@@ -5,0 +5,1 @@\n+e\n"
	if got != want {
		t.Fatalf("got\n%s\nwant\n%s", got, want)
	}
	if got := lineDiff(splitLines("x"), splitLines("x\n")); !strings.Contains(got, "No newline") {
		t.Fatalf("no-newline case: %q", got)
	}
}

func TestExplainFailure(t *testing.T) {
	m := explainFailure("error while executing at wasm backtrace: ... memory fault at wasm address 0xffffff60 in linear memory of size 0x20000", "memory_out_of_bounds", 8<<20)
	if !strings.Contains(m, "stack-size") {
		t.Errorf("linear stack overflow not recognized: %s", m)
	}
	m = explainFailure("memory fault at wasm address 0x10 in linear memory", "memory_out_of_bounds", 8<<20)
	if strings.Contains(m, "stack-size") || !strings.Contains(m, "out-of-bounds") {
		t.Errorf("plain OOB: %s", m)
	}
	m = explainFailure("call stack exhausted", "stack_overflow", 8<<20)
	if !strings.Contains(m, "max_wasm_stack") || !strings.Contains(m, "8388608") {
		t.Errorf("stack overflow: %s", m)
	}
	if m := explainFailure("some host error", "", 0); m != "some host error" {
		t.Errorf("passthrough: %s", m)
	}
}

func TestHasStackSize(t *testing.T) {
	if !hasStackSize([]string{"-O2", "-Wl,-z,stack-size=4194304"}) || hasStackSize([]string{"-O2", "-o", "a.wasm"}) {
		t.Fatal("hasStackSize")
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
