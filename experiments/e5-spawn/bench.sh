#!/usr/bin/env bash
# E5 timing matrix: cmd/go in wasm spawning wasm tools via wasmdev_proc.
# Assumes the compiled-module cache is warm (run any go build/test once first)
# so these numbers exclude one-time Cranelift compiles of the tools.
# Prints: label, wall seconds, exit code, CPU steal % during the run, peak RSS.
set -uo pipefail
here=$(cd "$(dirname "$0")/../.." && pwd)
export HOST=${HOST:-$here/host/target/release/wasmdev-host}
export TC=${TC:-$here/build/go-wasip1/goroot}
export STATE=${STATE:-$here/build/e5-state}
GO=$here/experiments/e5-spawn/run-go.sh
M=${M:-$here/experiments/e5-spawn/testmod}
LOGS=${LOGS:-$here/build/e5-bench-logs}
mkdir -p "$LOGS"

cpu() { awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8+$9, $9}' /proc/stat; }
run() {
	local label=$1
	shift
	local a b t0 t1 rc rss
	a=$(cpu)
	t0=$(date +%s.%N)
	/usr/bin/time -f %M -o "$LOGS/rss" "$@" >"$LOGS/$label.log" 2>&1
	rc=$?
	t1=$(date +%s.%N)
	b=$(cpu)
	rss=$(tail -1 "$LOGS/rss")
	awk -v l="$label" -v t0="$t0" -v t1="$t1" -v rc="$rc" -v rss="$rss" -v a="$a" -v b="$b" 'BEGIN{
		split(a,x," "); split(b,y," ");
		st=(y[1]-x[1])>0 ? 100*(y[2]-x[2])/(y[1]-x[1]) : 0;
		printf "%-28s %8.1fs  rc=%d  steal=%3.0f%%  rss=%4.0fMB\n", l, t1-t0, rc, st, rss/1024 }'
}
edit() { printf '\nfunc Sub(a, b int) int { return a - b } // %s\n' "$(date +%s%N)" >>"$M/calc/calc.go"; }
restore() { git -C "$M" checkout -q -- calc/calc.go 2>/dev/null || sed -i '/^func Sub/d' "$M/calc/calc.go"; }

for p in ${PS:-1 2}; do
	rm -rf "$STATE/gocache"
	run "build-cold-p$p" "$GO" "$M" build -p "$p" -o /state/out.wasm .
done
run "build-warm-noop" "$GO" "$M" build -p 2 -o /state/out.wasm .
edit
run "build-warm-edit-calc" "$GO" "$M" build -p 2 -o /state/out.wasm .
restore
for p in ${PS:-1 2}; do
	rm -rf "$STATE/gocache"
	run "test-cold-p$p" "$GO" "$M" test -p "$p" ./...
done
run "test-warm-cached" "$GO" "$M" test ./...
run "test-warm-count1" "$GO" "$M" test -count=1 -p 2 ./...
edit
run "test-warm-edit-calc" "$GO" "$M" test -p 2 ./...
restore
run "test-failing-variant" "$GO" "$M" test -p 2 -tags failing ./...
run "vet-warm" "$GO" "$M" vet ./...

# Native baseline (same machine, same target), only if a native go exists.
if command -v go >/dev/null && [ -z "${NO_NATIVE:-}" ]; then
	for p in ${PS:-1 2}; do
		d=$(mktemp -d)
		run "native-build-cold-p$p" env GOCACHE="$d" GOOS=wasip1 GOARCH=wasm GOFLAGS= go -C "$M" build -p "$p" -o "$d/out.wasm" .
		run "native-test-c-cold-p$p" env GOCACHE="$d.t" GOOS=wasip1 GOARCH=wasm GOFLAGS= go -C "$M" test -p "$p" -c -o "$d/" ./...
		rm -rf "$d" "$d.t"
	done
fi
