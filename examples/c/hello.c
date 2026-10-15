/* wasip1 C program: args, env, and a file in the workspace (relative path). */
#include <stdio.h>
#include <stdlib.h>
#include "greet.h"

int main(int argc, char **argv) {
  const char *who = argc > 1 ? argv[1] : "world";
  printf("%s\n", greeting(who));
  FILE *f = fopen("data/input.txt", "r");
  if (!f) { perror("data/input.txt"); return 1; }
  char line[256];
  int n = 0;
  while (fgets(line, sizeof line, f)) n++;
  fclose(f);
  printf("input.txt has %d lines\n", n);
  return 0;
}
