#include <stdio.h>
#include "greet.h"
const char *greeting(const char *who) {
  static char buf[128];
  snprintf(buf, sizeof buf, "hello, %s, from C compiled by clang running as wasm", who);
  return buf;
}
