// Recursion depth demo: wasm call-stack limit (max_wasm_stack) and the
// C linear-memory stack (-Wl,-z,stack-size).
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int depth(int n) { return n == 0 ? 0 : 1 + depth(n - 1); }

static int big_frame(int n) {
    char buf[1536 * 1024]; /* 1.5 MiB on the C stack */
    memset(buf, n, sizeof buf);
    return buf[n] + buf[sizeof buf - 1];
}

int main(int argc, char **argv) {
    printf("start\n");
    fflush(stdout);
    if (argc > 1 && strcmp(argv[1], "big") == 0) {
        printf("big frame: %d\n", big_frame(3));
        return 0;
    }
    int n = argc > 1 ? atoi(argv[1]) : 1000;
    printf("depth %d\n", depth(n));
    return 0;
}
