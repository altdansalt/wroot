// spawntest exercises the wasmdev_proc spawn capability through os/exec,
// the way cmd/go uses it. Build with the patched GOROOT (GOOS=wasip1).
//
//	wasmdev-host exec --dir D -- D/spawntest.wasm D/spawntest.wasm
package main

import (
	"bytes"
	"context"
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"sync"
	"time"
)

func main() {
	if len(os.Args) > 2 && os.Args[2] == "child" {
		fmt.Println("out:", strings.Join(os.Args[3:], " "))
		fmt.Fprintln(os.Stderr, "err: pwd", os.Getenv("PWD"))
		if len(os.Args) > 3 && os.Args[3] == "big" {
			os.Stdout.Write(bytes.Repeat([]byte("x"), 1<<20))
		}
		if len(os.Args) > 3 && os.Args[3] == "sleep" {
			time.Sleep(time.Hour)
		}
		if len(os.Args) > 3 && os.Args[3] == "fail" {
			os.Exit(3)
		}
		return
	}
	self := os.Args[1]
	t0 := time.Now()
	only := os.Getenv("ONLY")
	step := func(name string, f func() error) {
		if only != "" && !strings.Contains(name, only) {
			return
		}
		t := time.Now()
		err := f()
		fmt.Printf("%-22s err=%v (%.0fms)\n", name, err, float64(time.Since(t).Microseconds())/1e3)
	}
	step("lookpath", func() error { _, err := exec.LookPath(self); return err })
	step("run-inherit", func() error {
		c := exec.Command(self, self, "child", "inherit")
		c.Stdout, c.Stderr = os.Stdout, os.Stderr
		return c.Run()
	})
	step("output", func() error {
		out, err := exec.Command(self, self, "child", "a", "b").Output()
		fmt.Printf("  got %q\n", out)
		return err
	})
	step("combined+fail", func() error {
		out, err := exec.Command(self, self, "child", "fail").CombinedOutput()
		fmt.Printf("  got %q\n", out)
		return err
	})
	step("big output", func() error {
		out, err := exec.Command(self, self, "child", "big").Output()
		fmt.Printf("  got %d bytes\n", len(out))
		return err
	})
	step("ctx+waitdelay", func() error {
		ctx, cancel := context.WithTimeout(context.Background(), time.Minute)
		defer cancel()
		var b bytes.Buffer
		c := exec.CommandContext(ctx, self, self, "child", "ctx")
		c.Stdout, c.Stderr = &b, &b
		c.WaitDelay = 5 * time.Second
		c.Dir = "/st"
		err := c.Run()
		fmt.Printf("  got %q\n", b.String())
		return err
	})
	step("kill", func() error {
		ctx, cancel := context.WithTimeout(context.Background(), 500*time.Millisecond)
		defer cancel()
		return exec.CommandContext(ctx, self, self, "child", "sleep").Run()
	})
	step("parallel x4", func() error {
		var wg sync.WaitGroup
		errs := make([]error, 4)
		for i := range 4 {
			wg.Add(1)
			go func() {
				defer wg.Done()
				_, errs[i] = exec.Command(self, self, "child", fmt.Sprint(i)).Output()
			}()
		}
		wg.Wait()
		return fmt.Errorf("%v", errs)
	})
	step("signal+output", func() error {
		c := make(chan os.Signal, 1)
		signal.Notify(c, os.Interrupt)
		_, err := exec.Command(self, self, "child", "sig").Output()
		return err
	})
	fmt.Printf("total %.0fms\n", float64(time.Since(t0).Microseconds())/1e3)
}
