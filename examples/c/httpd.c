/* Tiny HTTP/1.0 server in C for wasm32-wasip2 (wasi:sockets via wasi-libc).
 * Binds 0.0.0.0:$PORT (the service port assigned by wasmdev), answers
 * every request with the method, path and a request counter.
 *
 *   cc --target=wasm32-wasip2 -O2 -o httpd.wasm httpd.c
 */
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

int main(void) {
  const char *p = getenv("PORT");
  int port = p ? atoi(p) : 8080;
  int lfd = socket(AF_INET, SOCK_STREAM, 0);
  if (lfd < 0) { perror("socket"); return 1; }
  struct sockaddr_in a = {0};
  a.sin_family = AF_INET;
  a.sin_port = htons(port);
  a.sin_addr.s_addr = htonl(INADDR_ANY);
  if (bind(lfd, (struct sockaddr *)&a, sizeof a) < 0) { perror("bind"); return 1; }
  if (listen(lfd, 64) < 0) { perror("listen"); return 1; }
  fprintf(stderr, "httpd: listening on port %d\n", port);
  for (unsigned long n = 1;; n++) {
    int c = accept(lfd, NULL, NULL);
    if (c < 0) { perror("accept"); continue; }
    char req[2048];
    ssize_t len = read(c, req, sizeof req - 1);
    req[len > 0 ? len : 0] = 0;
    char method[16] = "?", path[256] = "?";
    sscanf(req, "%15s %255s", method, path);
    char body[512];
    int blen = snprintf(body, sizeof body, "hello from C on wasip2: %s %s (request #%lu)\n", method, path, n);
    char head[256];
    int hlen = snprintf(head, sizeof head,
                        "HTTP/1.0 200 OK\r\nContent-Type: text/plain\r\nContent-Length: %d\r\nConnection: close\r\n\r\n", blen);
    write(c, head, hlen);
    write(c, body, blen);
    close(c);
    fprintf(stderr, "httpd: %s %s\n", method, path);
  }
}
