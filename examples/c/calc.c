#include "calc.h"
int gcd(int a, int b) { while (b) { int t = a % b; a = b; b = t; } return a < 0 ? -a : a; }
int is_prime(int n) {
  if (n < 2) return 0;
  for (int d = 2; d * d <= n; d++) if (n % d == 0) return 0;
  return 1;
}
long long fib(int n) { long long a = 0, b = 1; while (n-- > 0) { long long t = a + b; a = b; b = t; } return a; }
