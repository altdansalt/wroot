/* Probes the wasmdev socket policy from a wasip2 component: which binds
 * and connects are allowed. Prints one line per probe and exits. */
#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

static void probe_bind(const char *ip, int port) {
  int fd = socket(AF_INET, SOCK_STREAM, 0);
  struct sockaddr_in a = {0};
  a.sin_family = AF_INET; a.sin_port = htons(port); inet_pton(AF_INET, ip, &a.sin_addr);
  int r = bind(fd, (struct sockaddr *)&a, sizeof a);
  if (r == 0) r = listen(fd, 1);
  printf("bind+listen %s:%d -> %s\n", ip, port, r == 0 ? "ok" : strerror(errno));
  close(fd);
}

static void probe_connect(const char *ip, int port) {
  int fd = socket(AF_INET, SOCK_STREAM, 0);
  struct sockaddr_in a = {0};
  a.sin_family = AF_INET; a.sin_port = htons(port); inet_pton(AF_INET, ip, &a.sin_addr);
  int r = connect(fd, (struct sockaddr *)&a, sizeof a);
  printf("connect %s:%d -> %s\n", ip, port, r == 0 ? "ok" : strerror(errno));
  close(fd);
}

int main(int argc, char **argv) {
  const char *p = getenv("PORT");
  int port = p ? atoi(p) : 8100;
  printf("PORT=%s\n", p ? p : "(unset)");
  probe_bind("0.0.0.0", port);
  probe_bind("0.0.0.0", port + 1);
  probe_bind("127.0.0.1", port);
  int ctl = argc > 1 ? atoi(argv[1]) : 8781;
  probe_connect("127.0.0.1", ctl);
  probe_connect("1.1.1.1", 80);
  int udp = socket(AF_INET, SOCK_DGRAM, 0);
  printf("udp socket -> %s\n", udp >= 0 ? "ok (created)" : strerror(errno));
  fflush(stdout);
  return 0;
}
