// Package strutil has string helpers.
package strutil

import "strings"

// Reverse reverses s by runes.
func Reverse(s string) string {
	r := []rune(s)
	for i, j := 0, len(r)-1; i < j; i, j = i+1, j-1 {
		r[i], r[j] = r[j], r[i]
	}
	return string(r)
}

// Title upper-cases the first letter of each word.
func Title(s string) string {
	f := strings.Fields(s)
	for i, w := range f {
		f[i] = strings.ToUpper(w[:1]) + w[1:]
	}
	return strings.Join(f, " ")
}
