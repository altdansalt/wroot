package strutil

import "fmt"

// Uploaded by the demo to show go vet finding a bug.
func Describe(n int) string {
	return fmt.Sprintf("%s items", n)
}
