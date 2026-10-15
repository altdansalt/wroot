/* Unit tests for calc.c. Exit status = number of failed checks. */
#include <stdio.h>
#include "calc.h"

static int failed, passed;
#define CHECK(expr) do { if (expr) passed++; else { failed++; \
  fprintf(stderr, "FAIL %s:%d: %s\n", __FILE__, __LINE__, #expr); } } while (0)

int main(void) {
  CHECK(gcd(12, 18) == 6);
  CHECK(gcd(-4, 6) == 2);
  CHECK(gcd(7, 0) == 7);
  CHECK(is_prime(2) && is_prime(3) && is_prime(97));
  CHECK(!is_prime(1) && !is_prime(0) && !is_prime(91));
  CHECK(!is_prime(9) && !is_prime(25) && !is_prime(49));
  CHECK(fib(0) == 0 && fib(1) == 1 && fib(10) == 55);
  CHECK(fib(50) == 12586269025LL);
  printf("%d passed, %d failed\n", passed, failed);
  return failed;
}
