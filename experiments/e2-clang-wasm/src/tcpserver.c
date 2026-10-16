/* Minimal TCP echo-ish HTTP server. On wasip1 it uses a preopened listening
 * socket (fd 3 from `wasmtime run --tcplisten`); on wasip2 it binds itself. */
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
int main(void) {
  int lfd;
#if defined(__wasip2__) || !defined(__wasi__)
  lfd = socket(AF_INET, SOCK_STREAM, 0);
  int one = 1; setsockopt(lfd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof one);
  struct sockaddr_in a = {0}; a.sin_family = AF_INET; a.sin_port = htons(8089);
  if (bind(lfd, (struct sockaddr*)&a, sizeof a) < 0) { perror("bind"); return 1; }
  if (listen(lfd, 16) < 0) { perror("listen"); return 1; }
#else
  lfd = 3; /* preopened by --tcplisten */
#endif
  fprintf(stderr, "listening on fd %d\n", lfd);
  for (int i = 0; i < 2; i++) {
    int c = accept(lfd, NULL, NULL);
    if (c < 0) { perror("accept"); return 1; }
    char buf[1024]; ssize_t n = read(c, buf, sizeof buf);
    const char *body = "hello from wasm tcp server\n";
    char resp[256]; int len = snprintf(resp, sizeof resp,
      "HTTP/1.0 200 OK\r\nContent-Length: %zu\r\n\r\n%s", strlen(body), body);
    write(c, resp, len); close(c);
    fprintf(stderr, "served request %d (%zd bytes in)\n", i, n);
  }
  return 0;
}
