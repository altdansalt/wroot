package main

import (
	"errors"
	"fmt"
	"strings"
)

// The "cmd" mini-shell. Grammar (a small, predictable subset of sh):
//
//	list     = pipeline { ("&&" | "||" | ";") pipeline }
//	pipeline = command { "|" command }
//	command  = word { word | redir }
//	redir    = "<" file | ">" file | ">>" file | "2>" file | "2>>" file | "2>&1"
//
// Words support '...' and "..." quoting and backslash escapes; unquoted
// * ? [ are globs, expanded against the workspace. No variables,
// substitutions, subshells, loops or background jobs.
//
// Pipes are buffered: the stages run one after another, each reading the
// previous stage's complete output (fine for build/test pipelines, not
// for endless producers).

type redir struct {
	Fd     int    // 0 stdin, 1 stdout, 2 stderr
	Op     string // "<", ">", ">>", ">&1"
	Target string // workspace-relative path (glob-marked like words)
}

type simpleCmd struct {
	Words  []string
	Redirs []redir
}

type pipeline struct {
	Cmds []simpleCmd
}

// cmdList is pipelines joined by operators: Ops[i] joins Pipes[i] and Pipes[i+1].
type cmdList struct {
	Pipes []pipeline
	Ops   []string // "&&" | "||" | ";"
}

type tokKind int

const (
	tWord tokKind = iota
	tOp
)

type token struct {
	kind tokKind
	val  string
}

// lex splits a command line into words and operators. Unquoted glob
// metacharacters in words are prefixed with \x00 (see expandGlobs).
func lex(line string) ([]token, error) {
	var toks []token
	var cur strings.Builder
	inWord, quoted, quote := false, false, rune(0)
	flush := func() {
		if inWord {
			toks = append(toks, token{tWord, cur.String()})
			cur.Reset()
			inWord, quoted = false, false
		}
	}
	op := func(v string) {
		flush()
		toks = append(toks, token{tOp, v})
	}
	rs := []rune(line)
	at := func(i int, s string) bool { return strings.HasPrefix(string(rs[i:]), s) }
	for i := 0; i < len(rs); i++ {
		c := rs[i]
		switch {
		case quote != 0:
			if c == quote {
				quote = 0
			} else if c == '\\' && quote == '"' && i+1 < len(rs) && strings.ContainsRune(`"\$`+"`", rs[i+1]) {
				i++
				cur.WriteRune(rs[i])
			} else {
				cur.WriteRune(c)
			}
		case c == '\'' || c == '"':
			quote, inWord, quoted = c, true, true
		case c == '\\' && i+1 < len(rs):
			i++
			cur.WriteRune(rs[i])
			inWord, quoted = true, true
		case c == ' ' || c == '\t' || c == '\n' || c == '\r':
			flush()
		case at(i, "&&"), at(i, "||"):
			op(string(rs[i : i+2]))
			i++
		case c == ';' || c == '|' || c == '<':
			op(string(c))
		case c == '>':
			fd := ""
			if inWord && !quoted && cur.String() == "2" {
				fd = "2"
				cur.Reset()
				inWord = false
			}
			switch {
			case at(i, ">&1") && fd == "2":
				op("2>&1")
				i += 2
			case at(i, ">>"):
				op(fd + ">>")
				i++
			default:
				op(fd + ">")
			}
		case c == '&' || c == '`' || c == '$' || c == '(' || c == ')':
			return nil, fmt.Errorf("unsupported shell syntax %q (supported: words, quotes, globs, && || ; | < > >> 2> 2>&1)", c)
		default:
			// mark globs so quoted '*' is left alone
			if c == '*' || c == '?' || c == '[' {
				cur.WriteRune(0)
			}
			cur.WriteRune(c)
			inWord = true
		}
	}
	if quote != 0 {
		return nil, errors.New("unterminated quote")
	}
	flush()
	return toks, nil
}

// parseCmd parses a command line into a cmdList.
func parseCmd(line string) (*cmdList, error) {
	toks, err := lex(line)
	if err != nil {
		return nil, err
	}
	l := &cmdList{}
	var pl pipeline
	var sc simpleCmd
	endCmd := func(what string) error {
		if len(sc.Words) == 0 {
			if len(sc.Redirs) > 0 {
				return errors.New("syntax error: redirection without a command")
			}
			return fmt.Errorf("syntax error near %s", what)
		}
		pl.Cmds = append(pl.Cmds, sc)
		sc = simpleCmd{}
		return nil
	}
	for i := 0; i < len(toks); i++ {
		t := toks[i]
		if t.kind == tWord {
			sc.Words = append(sc.Words, t.val)
			continue
		}
		switch t.val {
		case "|":
			if err := endCmd("|"); err != nil {
				return nil, err
			}
		case "&&", "||", ";":
			if err := endCmd(t.val); err != nil {
				return nil, err
			}
			l.Pipes = append(l.Pipes, pl)
			l.Ops = append(l.Ops, t.val)
			pl = pipeline{}
		case "2>&1":
			sc.Redirs = append(sc.Redirs, redir{Fd: 2, Op: ">&1"})
		default: // < > >> 2> 2>>
			if i+1 >= len(toks) || toks[i+1].kind != tWord {
				return nil, fmt.Errorf("syntax error: %s needs a file name", t.val)
			}
			i++
			r := redir{Fd: 1, Op: strings.TrimPrefix(t.val, "2"), Target: toks[i].val}
			if t.val == "<" {
				r.Fd = 0
			} else if strings.HasPrefix(t.val, "2") {
				r.Fd = 2
			}
			sc.Redirs = append(sc.Redirs, r)
		}
	}
	if len(sc.Words) > 0 || len(sc.Redirs) > 0 || len(pl.Cmds) > 0 {
		if err := endCmd("end of line"); err != nil {
			return nil, err
		}
		l.Pipes = append(l.Pipes, pl)
	} else if len(l.Ops) > 0 {
		if last := l.Ops[len(l.Ops)-1]; last == ";" {
			l.Ops = l.Ops[:len(l.Ops)-1]
		} else {
			return nil, fmt.Errorf("syntax error: trailing %s", last)
		}
	}
	if len(l.Pipes) == 0 {
		return nil, errors.New("empty command")
	}
	return l, nil
}

// unmark removes glob marks from a word that is used literally.
func unmark(w string) string { return strings.ReplaceAll(w, "\x00", "") }
