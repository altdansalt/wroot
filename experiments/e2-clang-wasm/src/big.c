#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

typedef struct s0 { int a; double b; char name[16]; } s0_t;
static double f0(s0_t *p, int n) {
  double acc = 0.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s1 { int a; double b; char name[16]; } s1_t;
static double f1(s1_t *p, int n) {
  double acc = 1.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s2 { int a; double b; char name[16]; } s2_t;
static double f2(s2_t *p, int n) {
  double acc = 2.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s3 { int a; double b; char name[16]; } s3_t;
static double f3(s3_t *p, int n) {
  double acc = 3.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s4 { int a; double b; char name[16]; } s4_t;
static double f4(s4_t *p, int n) {
  double acc = 4.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s5 { int a; double b; char name[16]; } s5_t;
static double f5(s5_t *p, int n) {
  double acc = 5.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s6 { int a; double b; char name[16]; } s6_t;
static double f6(s6_t *p, int n) {
  double acc = 6.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s7 { int a; double b; char name[16]; } s7_t;
static double f7(s7_t *p, int n) {
  double acc = 7.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s8 { int a; double b; char name[16]; } s8_t;
static double f8(s8_t *p, int n) {
  double acc = 8.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s9 { int a; double b; char name[16]; } s9_t;
static double f9(s9_t *p, int n) {
  double acc = 9.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s10 { int a; double b; char name[16]; } s10_t;
static double f10(s10_t *p, int n) {
  double acc = 10.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s11 { int a; double b; char name[16]; } s11_t;
static double f11(s11_t *p, int n) {
  double acc = 11.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s12 { int a; double b; char name[16]; } s12_t;
static double f12(s12_t *p, int n) {
  double acc = 12.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s13 { int a; double b; char name[16]; } s13_t;
static double f13(s13_t *p, int n) {
  double acc = 13.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s14 { int a; double b; char name[16]; } s14_t;
static double f14(s14_t *p, int n) {
  double acc = 14.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s15 { int a; double b; char name[16]; } s15_t;
static double f15(s15_t *p, int n) {
  double acc = 15.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s16 { int a; double b; char name[16]; } s16_t;
static double f16(s16_t *p, int n) {
  double acc = 16.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s17 { int a; double b; char name[16]; } s17_t;
static double f17(s17_t *p, int n) {
  double acc = 17.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s18 { int a; double b; char name[16]; } s18_t;
static double f18(s18_t *p, int n) {
  double acc = 18.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s19 { int a; double b; char name[16]; } s19_t;
static double f19(s19_t *p, int n) {
  double acc = 19.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s20 { int a; double b; char name[16]; } s20_t;
static double f20(s20_t *p, int n) {
  double acc = 20.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s21 { int a; double b; char name[16]; } s21_t;
static double f21(s21_t *p, int n) {
  double acc = 21.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s22 { int a; double b; char name[16]; } s22_t;
static double f22(s22_t *p, int n) {
  double acc = 22.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s23 { int a; double b; char name[16]; } s23_t;
static double f23(s23_t *p, int n) {
  double acc = 23.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s24 { int a; double b; char name[16]; } s24_t;
static double f24(s24_t *p, int n) {
  double acc = 24.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s25 { int a; double b; char name[16]; } s25_t;
static double f25(s25_t *p, int n) {
  double acc = 25.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s26 { int a; double b; char name[16]; } s26_t;
static double f26(s26_t *p, int n) {
  double acc = 26.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s27 { int a; double b; char name[16]; } s27_t;
static double f27(s27_t *p, int n) {
  double acc = 27.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s28 { int a; double b; char name[16]; } s28_t;
static double f28(s28_t *p, int n) {
  double acc = 28.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s29 { int a; double b; char name[16]; } s29_t;
static double f29(s29_t *p, int n) {
  double acc = 29.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s30 { int a; double b; char name[16]; } s30_t;
static double f30(s30_t *p, int n) {
  double acc = 30.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s31 { int a; double b; char name[16]; } s31_t;
static double f31(s31_t *p, int n) {
  double acc = 31.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s32 { int a; double b; char name[16]; } s32_t;
static double f32(s32_t *p, int n) {
  double acc = 32.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s33 { int a; double b; char name[16]; } s33_t;
static double f33(s33_t *p, int n) {
  double acc = 33.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s34 { int a; double b; char name[16]; } s34_t;
static double f34(s34_t *p, int n) {
  double acc = 34.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s35 { int a; double b; char name[16]; } s35_t;
static double f35(s35_t *p, int n) {
  double acc = 35.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s36 { int a; double b; char name[16]; } s36_t;
static double f36(s36_t *p, int n) {
  double acc = 36.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s37 { int a; double b; char name[16]; } s37_t;
static double f37(s37_t *p, int n) {
  double acc = 37.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s38 { int a; double b; char name[16]; } s38_t;
static double f38(s38_t *p, int n) {
  double acc = 38.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s39 { int a; double b; char name[16]; } s39_t;
static double f39(s39_t *p, int n) {
  double acc = 39.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s40 { int a; double b; char name[16]; } s40_t;
static double f40(s40_t *p, int n) {
  double acc = 40.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s41 { int a; double b; char name[16]; } s41_t;
static double f41(s41_t *p, int n) {
  double acc = 41.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s42 { int a; double b; char name[16]; } s42_t;
static double f42(s42_t *p, int n) {
  double acc = 42.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s43 { int a; double b; char name[16]; } s43_t;
static double f43(s43_t *p, int n) {
  double acc = 43.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s44 { int a; double b; char name[16]; } s44_t;
static double f44(s44_t *p, int n) {
  double acc = 44.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s45 { int a; double b; char name[16]; } s45_t;
static double f45(s45_t *p, int n) {
  double acc = 45.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s46 { int a; double b; char name[16]; } s46_t;
static double f46(s46_t *p, int n) {
  double acc = 46.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s47 { int a; double b; char name[16]; } s47_t;
static double f47(s47_t *p, int n) {
  double acc = 47.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s48 { int a; double b; char name[16]; } s48_t;
static double f48(s48_t *p, int n) {
  double acc = 48.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s49 { int a; double b; char name[16]; } s49_t;
static double f49(s49_t *p, int n) {
  double acc = 49.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s50 { int a; double b; char name[16]; } s50_t;
static double f50(s50_t *p, int n) {
  double acc = 50.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s51 { int a; double b; char name[16]; } s51_t;
static double f51(s51_t *p, int n) {
  double acc = 51.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s52 { int a; double b; char name[16]; } s52_t;
static double f52(s52_t *p, int n) {
  double acc = 52.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s53 { int a; double b; char name[16]; } s53_t;
static double f53(s53_t *p, int n) {
  double acc = 53.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s54 { int a; double b; char name[16]; } s54_t;
static double f54(s54_t *p, int n) {
  double acc = 54.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s55 { int a; double b; char name[16]; } s55_t;
static double f55(s55_t *p, int n) {
  double acc = 55.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s56 { int a; double b; char name[16]; } s56_t;
static double f56(s56_t *p, int n) {
  double acc = 56.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s57 { int a; double b; char name[16]; } s57_t;
static double f57(s57_t *p, int n) {
  double acc = 57.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s58 { int a; double b; char name[16]; } s58_t;
static double f58(s58_t *p, int n) {
  double acc = 58.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s59 { int a; double b; char name[16]; } s59_t;
static double f59(s59_t *p, int n) {
  double acc = 59.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s60 { int a; double b; char name[16]; } s60_t;
static double f60(s60_t *p, int n) {
  double acc = 60.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s61 { int a; double b; char name[16]; } s61_t;
static double f61(s61_t *p, int n) {
  double acc = 61.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s62 { int a; double b; char name[16]; } s62_t;
static double f62(s62_t *p, int n) {
  double acc = 62.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s63 { int a; double b; char name[16]; } s63_t;
static double f63(s63_t *p, int n) {
  double acc = 63.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s64 { int a; double b; char name[16]; } s64_t;
static double f64(s64_t *p, int n) {
  double acc = 64.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s65 { int a; double b; char name[16]; } s65_t;
static double f65(s65_t *p, int n) {
  double acc = 65.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s66 { int a; double b; char name[16]; } s66_t;
static double f66(s66_t *p, int n) {
  double acc = 66.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s67 { int a; double b; char name[16]; } s67_t;
static double f67(s67_t *p, int n) {
  double acc = 67.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s68 { int a; double b; char name[16]; } s68_t;
static double f68(s68_t *p, int n) {
  double acc = 68.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s69 { int a; double b; char name[16]; } s69_t;
static double f69(s69_t *p, int n) {
  double acc = 69.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s70 { int a; double b; char name[16]; } s70_t;
static double f70(s70_t *p, int n) {
  double acc = 70.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s71 { int a; double b; char name[16]; } s71_t;
static double f71(s71_t *p, int n) {
  double acc = 71.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s72 { int a; double b; char name[16]; } s72_t;
static double f72(s72_t *p, int n) {
  double acc = 72.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s73 { int a; double b; char name[16]; } s73_t;
static double f73(s73_t *p, int n) {
  double acc = 73.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s74 { int a; double b; char name[16]; } s74_t;
static double f74(s74_t *p, int n) {
  double acc = 74.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s75 { int a; double b; char name[16]; } s75_t;
static double f75(s75_t *p, int n) {
  double acc = 75.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s76 { int a; double b; char name[16]; } s76_t;
static double f76(s76_t *p, int n) {
  double acc = 76.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s77 { int a; double b; char name[16]; } s77_t;
static double f77(s77_t *p, int n) {
  double acc = 77.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s78 { int a; double b; char name[16]; } s78_t;
static double f78(s78_t *p, int n) {
  double acc = 78.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s79 { int a; double b; char name[16]; } s79_t;
static double f79(s79_t *p, int n) {
  double acc = 79.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s80 { int a; double b; char name[16]; } s80_t;
static double f80(s80_t *p, int n) {
  double acc = 80.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s81 { int a; double b; char name[16]; } s81_t;
static double f81(s81_t *p, int n) {
  double acc = 81.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s82 { int a; double b; char name[16]; } s82_t;
static double f82(s82_t *p, int n) {
  double acc = 82.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s83 { int a; double b; char name[16]; } s83_t;
static double f83(s83_t *p, int n) {
  double acc = 83.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s84 { int a; double b; char name[16]; } s84_t;
static double f84(s84_t *p, int n) {
  double acc = 84.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s85 { int a; double b; char name[16]; } s85_t;
static double f85(s85_t *p, int n) {
  double acc = 85.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s86 { int a; double b; char name[16]; } s86_t;
static double f86(s86_t *p, int n) {
  double acc = 86.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s87 { int a; double b; char name[16]; } s87_t;
static double f87(s87_t *p, int n) {
  double acc = 87.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s88 { int a; double b; char name[16]; } s88_t;
static double f88(s88_t *p, int n) {
  double acc = 88.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s89 { int a; double b; char name[16]; } s89_t;
static double f89(s89_t *p, int n) {
  double acc = 89.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s90 { int a; double b; char name[16]; } s90_t;
static double f90(s90_t *p, int n) {
  double acc = 90.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s91 { int a; double b; char name[16]; } s91_t;
static double f91(s91_t *p, int n) {
  double acc = 91.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s92 { int a; double b; char name[16]; } s92_t;
static double f92(s92_t *p, int n) {
  double acc = 92.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s93 { int a; double b; char name[16]; } s93_t;
static double f93(s93_t *p, int n) {
  double acc = 93.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s94 { int a; double b; char name[16]; } s94_t;
static double f94(s94_t *p, int n) {
  double acc = 94.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s95 { int a; double b; char name[16]; } s95_t;
static double f95(s95_t *p, int n) {
  double acc = 95.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s96 { int a; double b; char name[16]; } s96_t;
static double f96(s96_t *p, int n) {
  double acc = 96.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s97 { int a; double b; char name[16]; } s97_t;
static double f97(s97_t *p, int n) {
  double acc = 97.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s98 { int a; double b; char name[16]; } s98_t;
static double f98(s98_t *p, int n) {
  double acc = 98.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s99 { int a; double b; char name[16]; } s99_t;
static double f99(s99_t *p, int n) {
  double acc = 99.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s100 { int a; double b; char name[16]; } s100_t;
static double f100(s100_t *p, int n) {
  double acc = 100.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s101 { int a; double b; char name[16]; } s101_t;
static double f101(s101_t *p, int n) {
  double acc = 101.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s102 { int a; double b; char name[16]; } s102_t;
static double f102(s102_t *p, int n) {
  double acc = 102.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s103 { int a; double b; char name[16]; } s103_t;
static double f103(s103_t *p, int n) {
  double acc = 103.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s104 { int a; double b; char name[16]; } s104_t;
static double f104(s104_t *p, int n) {
  double acc = 104.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s105 { int a; double b; char name[16]; } s105_t;
static double f105(s105_t *p, int n) {
  double acc = 105.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s106 { int a; double b; char name[16]; } s106_t;
static double f106(s106_t *p, int n) {
  double acc = 106.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s107 { int a; double b; char name[16]; } s107_t;
static double f107(s107_t *p, int n) {
  double acc = 107.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s108 { int a; double b; char name[16]; } s108_t;
static double f108(s108_t *p, int n) {
  double acc = 108.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s109 { int a; double b; char name[16]; } s109_t;
static double f109(s109_t *p, int n) {
  double acc = 109.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s110 { int a; double b; char name[16]; } s110_t;
static double f110(s110_t *p, int n) {
  double acc = 110.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s111 { int a; double b; char name[16]; } s111_t;
static double f111(s111_t *p, int n) {
  double acc = 111.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s112 { int a; double b; char name[16]; } s112_t;
static double f112(s112_t *p, int n) {
  double acc = 112.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s113 { int a; double b; char name[16]; } s113_t;
static double f113(s113_t *p, int n) {
  double acc = 113.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s114 { int a; double b; char name[16]; } s114_t;
static double f114(s114_t *p, int n) {
  double acc = 114.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s115 { int a; double b; char name[16]; } s115_t;
static double f115(s115_t *p, int n) {
  double acc = 115.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s116 { int a; double b; char name[16]; } s116_t;
static double f116(s116_t *p, int n) {
  double acc = 116.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s117 { int a; double b; char name[16]; } s117_t;
static double f117(s117_t *p, int n) {
  double acc = 117.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s118 { int a; double b; char name[16]; } s118_t;
static double f118(s118_t *p, int n) {
  double acc = 118.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s119 { int a; double b; char name[16]; } s119_t;
static double f119(s119_t *p, int n) {
  double acc = 119.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s120 { int a; double b; char name[16]; } s120_t;
static double f120(s120_t *p, int n) {
  double acc = 120.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s121 { int a; double b; char name[16]; } s121_t;
static double f121(s121_t *p, int n) {
  double acc = 121.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s122 { int a; double b; char name[16]; } s122_t;
static double f122(s122_t *p, int n) {
  double acc = 122.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s123 { int a; double b; char name[16]; } s123_t;
static double f123(s123_t *p, int n) {
  double acc = 123.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s124 { int a; double b; char name[16]; } s124_t;
static double f124(s124_t *p, int n) {
  double acc = 124.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s125 { int a; double b; char name[16]; } s125_t;
static double f125(s125_t *p, int n) {
  double acc = 125.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s126 { int a; double b; char name[16]; } s126_t;
static double f126(s126_t *p, int n) {
  double acc = 126.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s127 { int a; double b; char name[16]; } s127_t;
static double f127(s127_t *p, int n) {
  double acc = 127.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s128 { int a; double b; char name[16]; } s128_t;
static double f128(s128_t *p, int n) {
  double acc = 128.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s129 { int a; double b; char name[16]; } s129_t;
static double f129(s129_t *p, int n) {
  double acc = 129.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s130 { int a; double b; char name[16]; } s130_t;
static double f130(s130_t *p, int n) {
  double acc = 130.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s131 { int a; double b; char name[16]; } s131_t;
static double f131(s131_t *p, int n) {
  double acc = 131.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s132 { int a; double b; char name[16]; } s132_t;
static double f132(s132_t *p, int n) {
  double acc = 132.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s133 { int a; double b; char name[16]; } s133_t;
static double f133(s133_t *p, int n) {
  double acc = 133.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s134 { int a; double b; char name[16]; } s134_t;
static double f134(s134_t *p, int n) {
  double acc = 134.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s135 { int a; double b; char name[16]; } s135_t;
static double f135(s135_t *p, int n) {
  double acc = 135.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s136 { int a; double b; char name[16]; } s136_t;
static double f136(s136_t *p, int n) {
  double acc = 136.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s137 { int a; double b; char name[16]; } s137_t;
static double f137(s137_t *p, int n) {
  double acc = 137.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s138 { int a; double b; char name[16]; } s138_t;
static double f138(s138_t *p, int n) {
  double acc = 138.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s139 { int a; double b; char name[16]; } s139_t;
static double f139(s139_t *p, int n) {
  double acc = 139.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s140 { int a; double b; char name[16]; } s140_t;
static double f140(s140_t *p, int n) {
  double acc = 140.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s141 { int a; double b; char name[16]; } s141_t;
static double f141(s141_t *p, int n) {
  double acc = 141.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s142 { int a; double b; char name[16]; } s142_t;
static double f142(s142_t *p, int n) {
  double acc = 142.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s143 { int a; double b; char name[16]; } s143_t;
static double f143(s143_t *p, int n) {
  double acc = 143.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s144 { int a; double b; char name[16]; } s144_t;
static double f144(s144_t *p, int n) {
  double acc = 144.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s145 { int a; double b; char name[16]; } s145_t;
static double f145(s145_t *p, int n) {
  double acc = 145.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s146 { int a; double b; char name[16]; } s146_t;
static double f146(s146_t *p, int n) {
  double acc = 146.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s147 { int a; double b; char name[16]; } s147_t;
static double f147(s147_t *p, int n) {
  double acc = 147.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s148 { int a; double b; char name[16]; } s148_t;
static double f148(s148_t *p, int n) {
  double acc = 148.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s149 { int a; double b; char name[16]; } s149_t;
static double f149(s149_t *p, int n) {
  double acc = 149.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s150 { int a; double b; char name[16]; } s150_t;
static double f150(s150_t *p, int n) {
  double acc = 150.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s151 { int a; double b; char name[16]; } s151_t;
static double f151(s151_t *p, int n) {
  double acc = 151.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s152 { int a; double b; char name[16]; } s152_t;
static double f152(s152_t *p, int n) {
  double acc = 152.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s153 { int a; double b; char name[16]; } s153_t;
static double f153(s153_t *p, int n) {
  double acc = 153.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s154 { int a; double b; char name[16]; } s154_t;
static double f154(s154_t *p, int n) {
  double acc = 154.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s155 { int a; double b; char name[16]; } s155_t;
static double f155(s155_t *p, int n) {
  double acc = 155.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s156 { int a; double b; char name[16]; } s156_t;
static double f156(s156_t *p, int n) {
  double acc = 156.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s157 { int a; double b; char name[16]; } s157_t;
static double f157(s157_t *p, int n) {
  double acc = 157.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s158 { int a; double b; char name[16]; } s158_t;
static double f158(s158_t *p, int n) {
  double acc = 158.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s159 { int a; double b; char name[16]; } s159_t;
static double f159(s159_t *p, int n) {
  double acc = 159.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s160 { int a; double b; char name[16]; } s160_t;
static double f160(s160_t *p, int n) {
  double acc = 160.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s161 { int a; double b; char name[16]; } s161_t;
static double f161(s161_t *p, int n) {
  double acc = 161.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s162 { int a; double b; char name[16]; } s162_t;
static double f162(s162_t *p, int n) {
  double acc = 162.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s163 { int a; double b; char name[16]; } s163_t;
static double f163(s163_t *p, int n) {
  double acc = 163.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s164 { int a; double b; char name[16]; } s164_t;
static double f164(s164_t *p, int n) {
  double acc = 164.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s165 { int a; double b; char name[16]; } s165_t;
static double f165(s165_t *p, int n) {
  double acc = 165.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s166 { int a; double b; char name[16]; } s166_t;
static double f166(s166_t *p, int n) {
  double acc = 166.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s167 { int a; double b; char name[16]; } s167_t;
static double f167(s167_t *p, int n) {
  double acc = 167.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s168 { int a; double b; char name[16]; } s168_t;
static double f168(s168_t *p, int n) {
  double acc = 168.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s169 { int a; double b; char name[16]; } s169_t;
static double f169(s169_t *p, int n) {
  double acc = 169.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s170 { int a; double b; char name[16]; } s170_t;
static double f170(s170_t *p, int n) {
  double acc = 170.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s171 { int a; double b; char name[16]; } s171_t;
static double f171(s171_t *p, int n) {
  double acc = 171.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s172 { int a; double b; char name[16]; } s172_t;
static double f172(s172_t *p, int n) {
  double acc = 172.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s173 { int a; double b; char name[16]; } s173_t;
static double f173(s173_t *p, int n) {
  double acc = 173.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s174 { int a; double b; char name[16]; } s174_t;
static double f174(s174_t *p, int n) {
  double acc = 174.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s175 { int a; double b; char name[16]; } s175_t;
static double f175(s175_t *p, int n) {
  double acc = 175.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s176 { int a; double b; char name[16]; } s176_t;
static double f176(s176_t *p, int n) {
  double acc = 176.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s177 { int a; double b; char name[16]; } s177_t;
static double f177(s177_t *p, int n) {
  double acc = 177.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s178 { int a; double b; char name[16]; } s178_t;
static double f178(s178_t *p, int n) {
  double acc = 178.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s179 { int a; double b; char name[16]; } s179_t;
static double f179(s179_t *p, int n) {
  double acc = 179.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s180 { int a; double b; char name[16]; } s180_t;
static double f180(s180_t *p, int n) {
  double acc = 180.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s181 { int a; double b; char name[16]; } s181_t;
static double f181(s181_t *p, int n) {
  double acc = 181.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s182 { int a; double b; char name[16]; } s182_t;
static double f182(s182_t *p, int n) {
  double acc = 182.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s183 { int a; double b; char name[16]; } s183_t;
static double f183(s183_t *p, int n) {
  double acc = 183.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s184 { int a; double b; char name[16]; } s184_t;
static double f184(s184_t *p, int n) {
  double acc = 184.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s185 { int a; double b; char name[16]; } s185_t;
static double f185(s185_t *p, int n) {
  double acc = 185.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s186 { int a; double b; char name[16]; } s186_t;
static double f186(s186_t *p, int n) {
  double acc = 186.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s187 { int a; double b; char name[16]; } s187_t;
static double f187(s187_t *p, int n) {
  double acc = 187.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s188 { int a; double b; char name[16]; } s188_t;
static double f188(s188_t *p, int n) {
  double acc = 188.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s189 { int a; double b; char name[16]; } s189_t;
static double f189(s189_t *p, int n) {
  double acc = 189.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s190 { int a; double b; char name[16]; } s190_t;
static double f190(s190_t *p, int n) {
  double acc = 190.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s191 { int a; double b; char name[16]; } s191_t;
static double f191(s191_t *p, int n) {
  double acc = 191.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s192 { int a; double b; char name[16]; } s192_t;
static double f192(s192_t *p, int n) {
  double acc = 192.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s193 { int a; double b; char name[16]; } s193_t;
static double f193(s193_t *p, int n) {
  double acc = 193.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 6 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s194 { int a; double b; char name[16]; } s194_t;
static double f194(s194_t *p, int n) {
  double acc = 194.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 7 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s195 { int a; double b; char name[16]; } s195_t;
static double f195(s195_t *p, int n) {
  double acc = 195.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 8 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s196 { int a; double b; char name[16]; } s196_t;
static double f196(s196_t *p, int n) {
  double acc = 196.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 2 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s197 { int a; double b; char name[16]; } s197_t;
static double f197(s197_t *p, int n) {
  double acc = 197.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 3 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s198 { int a; double b; char name[16]; } s198_t;
static double f198(s198_t *p, int n) {
  double acc = 198.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 4 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

typedef struct s199 { int a; double b; char name[16]; } s199_t;
static double f199(s199_t *p, int n) {
  double acc = 199.0;
  for (int k = 0; k < n; k++) {
    acc += sqrt((double)(p->a + k)) * p->b;
    if (k % 5 == 0) acc -= (double)strlen(p->name);
  }
  return acc;
}

int main(void) {
  double t = 0;
  { s0_t v = { 0, 0.5, "n0" }; t += f0(&v, 1); }
  { s1_t v = { 1, 1.5, "n1" }; t += f1(&v, 2); }
  { s2_t v = { 2, 2.5, "n2" }; t += f2(&v, 3); }
  { s3_t v = { 3, 3.5, "n3" }; t += f3(&v, 4); }
  { s4_t v = { 4, 4.5, "n4" }; t += f4(&v, 5); }
  { s5_t v = { 5, 5.5, "n5" }; t += f5(&v, 6); }
  { s6_t v = { 6, 6.5, "n6" }; t += f6(&v, 7); }
  { s7_t v = { 7, 7.5, "n7" }; t += f7(&v, 8); }
  { s8_t v = { 8, 8.5, "n8" }; t += f8(&v, 9); }
  { s9_t v = { 9, 9.5, "n9" }; t += f9(&v, 10); }
  { s10_t v = { 10, 10.5, "n10" }; t += f10(&v, 11); }
  { s11_t v = { 11, 11.5, "n11" }; t += f11(&v, 12); }
  { s12_t v = { 12, 12.5, "n12" }; t += f12(&v, 13); }
  { s13_t v = { 13, 13.5, "n13" }; t += f13(&v, 1); }
  { s14_t v = { 14, 14.5, "n14" }; t += f14(&v, 2); }
  { s15_t v = { 15, 15.5, "n15" }; t += f15(&v, 3); }
  { s16_t v = { 16, 16.5, "n16" }; t += f16(&v, 4); }
  { s17_t v = { 17, 17.5, "n17" }; t += f17(&v, 5); }
  { s18_t v = { 18, 18.5, "n18" }; t += f18(&v, 6); }
  { s19_t v = { 19, 19.5, "n19" }; t += f19(&v, 7); }
  { s20_t v = { 20, 20.5, "n20" }; t += f20(&v, 8); }
  { s21_t v = { 21, 21.5, "n21" }; t += f21(&v, 9); }
  { s22_t v = { 22, 22.5, "n22" }; t += f22(&v, 10); }
  { s23_t v = { 23, 23.5, "n23" }; t += f23(&v, 11); }
  { s24_t v = { 24, 24.5, "n24" }; t += f24(&v, 12); }
  { s25_t v = { 25, 25.5, "n25" }; t += f25(&v, 13); }
  { s26_t v = { 26, 26.5, "n26" }; t += f26(&v, 1); }
  { s27_t v = { 27, 27.5, "n27" }; t += f27(&v, 2); }
  { s28_t v = { 28, 28.5, "n28" }; t += f28(&v, 3); }
  { s29_t v = { 29, 29.5, "n29" }; t += f29(&v, 4); }
  { s30_t v = { 30, 30.5, "n30" }; t += f30(&v, 5); }
  { s31_t v = { 31, 31.5, "n31" }; t += f31(&v, 6); }
  { s32_t v = { 32, 32.5, "n32" }; t += f32(&v, 7); }
  { s33_t v = { 33, 33.5, "n33" }; t += f33(&v, 8); }
  { s34_t v = { 34, 34.5, "n34" }; t += f34(&v, 9); }
  { s35_t v = { 35, 35.5, "n35" }; t += f35(&v, 10); }
  { s36_t v = { 36, 36.5, "n36" }; t += f36(&v, 11); }
  { s37_t v = { 37, 37.5, "n37" }; t += f37(&v, 12); }
  { s38_t v = { 38, 38.5, "n38" }; t += f38(&v, 13); }
  { s39_t v = { 39, 39.5, "n39" }; t += f39(&v, 1); }
  { s40_t v = { 40, 40.5, "n40" }; t += f40(&v, 2); }
  { s41_t v = { 41, 41.5, "n41" }; t += f41(&v, 3); }
  { s42_t v = { 42, 42.5, "n42" }; t += f42(&v, 4); }
  { s43_t v = { 43, 43.5, "n43" }; t += f43(&v, 5); }
  { s44_t v = { 44, 44.5, "n44" }; t += f44(&v, 6); }
  { s45_t v = { 45, 45.5, "n45" }; t += f45(&v, 7); }
  { s46_t v = { 46, 46.5, "n46" }; t += f46(&v, 8); }
  { s47_t v = { 47, 47.5, "n47" }; t += f47(&v, 9); }
  { s48_t v = { 48, 48.5, "n48" }; t += f48(&v, 10); }
  { s49_t v = { 49, 49.5, "n49" }; t += f49(&v, 11); }
  { s50_t v = { 50, 50.5, "n50" }; t += f50(&v, 12); }
  { s51_t v = { 51, 51.5, "n51" }; t += f51(&v, 13); }
  { s52_t v = { 52, 52.5, "n52" }; t += f52(&v, 1); }
  { s53_t v = { 53, 53.5, "n53" }; t += f53(&v, 2); }
  { s54_t v = { 54, 54.5, "n54" }; t += f54(&v, 3); }
  { s55_t v = { 55, 55.5, "n55" }; t += f55(&v, 4); }
  { s56_t v = { 56, 56.5, "n56" }; t += f56(&v, 5); }
  { s57_t v = { 57, 57.5, "n57" }; t += f57(&v, 6); }
  { s58_t v = { 58, 58.5, "n58" }; t += f58(&v, 7); }
  { s59_t v = { 59, 59.5, "n59" }; t += f59(&v, 8); }
  { s60_t v = { 60, 60.5, "n60" }; t += f60(&v, 9); }
  { s61_t v = { 61, 61.5, "n61" }; t += f61(&v, 10); }
  { s62_t v = { 62, 62.5, "n62" }; t += f62(&v, 11); }
  { s63_t v = { 63, 63.5, "n63" }; t += f63(&v, 12); }
  { s64_t v = { 64, 64.5, "n64" }; t += f64(&v, 13); }
  { s65_t v = { 65, 65.5, "n65" }; t += f65(&v, 1); }
  { s66_t v = { 66, 66.5, "n66" }; t += f66(&v, 2); }
  { s67_t v = { 67, 67.5, "n67" }; t += f67(&v, 3); }
  { s68_t v = { 68, 68.5, "n68" }; t += f68(&v, 4); }
  { s69_t v = { 69, 69.5, "n69" }; t += f69(&v, 5); }
  { s70_t v = { 70, 70.5, "n70" }; t += f70(&v, 6); }
  { s71_t v = { 71, 71.5, "n71" }; t += f71(&v, 7); }
  { s72_t v = { 72, 72.5, "n72" }; t += f72(&v, 8); }
  { s73_t v = { 73, 73.5, "n73" }; t += f73(&v, 9); }
  { s74_t v = { 74, 74.5, "n74" }; t += f74(&v, 10); }
  { s75_t v = { 75, 75.5, "n75" }; t += f75(&v, 11); }
  { s76_t v = { 76, 76.5, "n76" }; t += f76(&v, 12); }
  { s77_t v = { 77, 77.5, "n77" }; t += f77(&v, 13); }
  { s78_t v = { 78, 78.5, "n78" }; t += f78(&v, 1); }
  { s79_t v = { 79, 79.5, "n79" }; t += f79(&v, 2); }
  { s80_t v = { 80, 80.5, "n80" }; t += f80(&v, 3); }
  { s81_t v = { 81, 81.5, "n81" }; t += f81(&v, 4); }
  { s82_t v = { 82, 82.5, "n82" }; t += f82(&v, 5); }
  { s83_t v = { 83, 83.5, "n83" }; t += f83(&v, 6); }
  { s84_t v = { 84, 84.5, "n84" }; t += f84(&v, 7); }
  { s85_t v = { 85, 85.5, "n85" }; t += f85(&v, 8); }
  { s86_t v = { 86, 86.5, "n86" }; t += f86(&v, 9); }
  { s87_t v = { 87, 87.5, "n87" }; t += f87(&v, 10); }
  { s88_t v = { 88, 88.5, "n88" }; t += f88(&v, 11); }
  { s89_t v = { 89, 89.5, "n89" }; t += f89(&v, 12); }
  { s90_t v = { 90, 90.5, "n90" }; t += f90(&v, 13); }
  { s91_t v = { 91, 91.5, "n91" }; t += f91(&v, 1); }
  { s92_t v = { 92, 92.5, "n92" }; t += f92(&v, 2); }
  { s93_t v = { 93, 93.5, "n93" }; t += f93(&v, 3); }
  { s94_t v = { 94, 94.5, "n94" }; t += f94(&v, 4); }
  { s95_t v = { 95, 95.5, "n95" }; t += f95(&v, 5); }
  { s96_t v = { 96, 96.5, "n96" }; t += f96(&v, 6); }
  { s97_t v = { 97, 97.5, "n97" }; t += f97(&v, 7); }
  { s98_t v = { 98, 98.5, "n98" }; t += f98(&v, 8); }
  { s99_t v = { 99, 99.5, "n99" }; t += f99(&v, 9); }
  { s100_t v = { 100, 100.5, "n100" }; t += f100(&v, 10); }
  { s101_t v = { 101, 101.5, "n101" }; t += f101(&v, 11); }
  { s102_t v = { 102, 102.5, "n102" }; t += f102(&v, 12); }
  { s103_t v = { 103, 103.5, "n103" }; t += f103(&v, 13); }
  { s104_t v = { 104, 104.5, "n104" }; t += f104(&v, 1); }
  { s105_t v = { 105, 105.5, "n105" }; t += f105(&v, 2); }
  { s106_t v = { 106, 106.5, "n106" }; t += f106(&v, 3); }
  { s107_t v = { 107, 107.5, "n107" }; t += f107(&v, 4); }
  { s108_t v = { 108, 108.5, "n108" }; t += f108(&v, 5); }
  { s109_t v = { 109, 109.5, "n109" }; t += f109(&v, 6); }
  { s110_t v = { 110, 110.5, "n110" }; t += f110(&v, 7); }
  { s111_t v = { 111, 111.5, "n111" }; t += f111(&v, 8); }
  { s112_t v = { 112, 112.5, "n112" }; t += f112(&v, 9); }
  { s113_t v = { 113, 113.5, "n113" }; t += f113(&v, 10); }
  { s114_t v = { 114, 114.5, "n114" }; t += f114(&v, 11); }
  { s115_t v = { 115, 115.5, "n115" }; t += f115(&v, 12); }
  { s116_t v = { 116, 116.5, "n116" }; t += f116(&v, 13); }
  { s117_t v = { 117, 117.5, "n117" }; t += f117(&v, 1); }
  { s118_t v = { 118, 118.5, "n118" }; t += f118(&v, 2); }
  { s119_t v = { 119, 119.5, "n119" }; t += f119(&v, 3); }
  { s120_t v = { 120, 120.5, "n120" }; t += f120(&v, 4); }
  { s121_t v = { 121, 121.5, "n121" }; t += f121(&v, 5); }
  { s122_t v = { 122, 122.5, "n122" }; t += f122(&v, 6); }
  { s123_t v = { 123, 123.5, "n123" }; t += f123(&v, 7); }
  { s124_t v = { 124, 124.5, "n124" }; t += f124(&v, 8); }
  { s125_t v = { 125, 125.5, "n125" }; t += f125(&v, 9); }
  { s126_t v = { 126, 126.5, "n126" }; t += f126(&v, 10); }
  { s127_t v = { 127, 127.5, "n127" }; t += f127(&v, 11); }
  { s128_t v = { 128, 128.5, "n128" }; t += f128(&v, 12); }
  { s129_t v = { 129, 129.5, "n129" }; t += f129(&v, 13); }
  { s130_t v = { 130, 130.5, "n130" }; t += f130(&v, 1); }
  { s131_t v = { 131, 131.5, "n131" }; t += f131(&v, 2); }
  { s132_t v = { 132, 132.5, "n132" }; t += f132(&v, 3); }
  { s133_t v = { 133, 133.5, "n133" }; t += f133(&v, 4); }
  { s134_t v = { 134, 134.5, "n134" }; t += f134(&v, 5); }
  { s135_t v = { 135, 135.5, "n135" }; t += f135(&v, 6); }
  { s136_t v = { 136, 136.5, "n136" }; t += f136(&v, 7); }
  { s137_t v = { 137, 137.5, "n137" }; t += f137(&v, 8); }
  { s138_t v = { 138, 138.5, "n138" }; t += f138(&v, 9); }
  { s139_t v = { 139, 139.5, "n139" }; t += f139(&v, 10); }
  { s140_t v = { 140, 140.5, "n140" }; t += f140(&v, 11); }
  { s141_t v = { 141, 141.5, "n141" }; t += f141(&v, 12); }
  { s142_t v = { 142, 142.5, "n142" }; t += f142(&v, 13); }
  { s143_t v = { 143, 143.5, "n143" }; t += f143(&v, 1); }
  { s144_t v = { 144, 144.5, "n144" }; t += f144(&v, 2); }
  { s145_t v = { 145, 145.5, "n145" }; t += f145(&v, 3); }
  { s146_t v = { 146, 146.5, "n146" }; t += f146(&v, 4); }
  { s147_t v = { 147, 147.5, "n147" }; t += f147(&v, 5); }
  { s148_t v = { 148, 148.5, "n148" }; t += f148(&v, 6); }
  { s149_t v = { 149, 149.5, "n149" }; t += f149(&v, 7); }
  { s150_t v = { 150, 150.5, "n150" }; t += f150(&v, 8); }
  { s151_t v = { 151, 151.5, "n151" }; t += f151(&v, 9); }
  { s152_t v = { 152, 152.5, "n152" }; t += f152(&v, 10); }
  { s153_t v = { 153, 153.5, "n153" }; t += f153(&v, 11); }
  { s154_t v = { 154, 154.5, "n154" }; t += f154(&v, 12); }
  { s155_t v = { 155, 155.5, "n155" }; t += f155(&v, 13); }
  { s156_t v = { 156, 156.5, "n156" }; t += f156(&v, 1); }
  { s157_t v = { 157, 157.5, "n157" }; t += f157(&v, 2); }
  { s158_t v = { 158, 158.5, "n158" }; t += f158(&v, 3); }
  { s159_t v = { 159, 159.5, "n159" }; t += f159(&v, 4); }
  { s160_t v = { 160, 160.5, "n160" }; t += f160(&v, 5); }
  { s161_t v = { 161, 161.5, "n161" }; t += f161(&v, 6); }
  { s162_t v = { 162, 162.5, "n162" }; t += f162(&v, 7); }
  { s163_t v = { 163, 163.5, "n163" }; t += f163(&v, 8); }
  { s164_t v = { 164, 164.5, "n164" }; t += f164(&v, 9); }
  { s165_t v = { 165, 165.5, "n165" }; t += f165(&v, 10); }
  { s166_t v = { 166, 166.5, "n166" }; t += f166(&v, 11); }
  { s167_t v = { 167, 167.5, "n167" }; t += f167(&v, 12); }
  { s168_t v = { 168, 168.5, "n168" }; t += f168(&v, 13); }
  { s169_t v = { 169, 169.5, "n169" }; t += f169(&v, 1); }
  { s170_t v = { 170, 170.5, "n170" }; t += f170(&v, 2); }
  { s171_t v = { 171, 171.5, "n171" }; t += f171(&v, 3); }
  { s172_t v = { 172, 172.5, "n172" }; t += f172(&v, 4); }
  { s173_t v = { 173, 173.5, "n173" }; t += f173(&v, 5); }
  { s174_t v = { 174, 174.5, "n174" }; t += f174(&v, 6); }
  { s175_t v = { 175, 175.5, "n175" }; t += f175(&v, 7); }
  { s176_t v = { 176, 176.5, "n176" }; t += f176(&v, 8); }
  { s177_t v = { 177, 177.5, "n177" }; t += f177(&v, 9); }
  { s178_t v = { 178, 178.5, "n178" }; t += f178(&v, 10); }
  { s179_t v = { 179, 179.5, "n179" }; t += f179(&v, 11); }
  { s180_t v = { 180, 180.5, "n180" }; t += f180(&v, 12); }
  { s181_t v = { 181, 181.5, "n181" }; t += f181(&v, 13); }
  { s182_t v = { 182, 182.5, "n182" }; t += f182(&v, 1); }
  { s183_t v = { 183, 183.5, "n183" }; t += f183(&v, 2); }
  { s184_t v = { 184, 184.5, "n184" }; t += f184(&v, 3); }
  { s185_t v = { 185, 185.5, "n185" }; t += f185(&v, 4); }
  { s186_t v = { 186, 186.5, "n186" }; t += f186(&v, 5); }
  { s187_t v = { 187, 187.5, "n187" }; t += f187(&v, 6); }
  { s188_t v = { 188, 188.5, "n188" }; t += f188(&v, 7); }
  { s189_t v = { 189, 189.5, "n189" }; t += f189(&v, 8); }
  { s190_t v = { 190, 190.5, "n190" }; t += f190(&v, 9); }
  { s191_t v = { 191, 191.5, "n191" }; t += f191(&v, 10); }
  { s192_t v = { 192, 192.5, "n192" }; t += f192(&v, 11); }
  { s193_t v = { 193, 193.5, "n193" }; t += f193(&v, 12); }
  { s194_t v = { 194, 194.5, "n194" }; t += f194(&v, 13); }
  { s195_t v = { 195, 195.5, "n195" }; t += f195(&v, 1); }
  { s196_t v = { 196, 196.5, "n196" }; t += f196(&v, 2); }
  { s197_t v = { 197, 197.5, "n197" }; t += f197(&v, 3); }
  { s198_t v = { 198, 198.5, "n198" }; t += f198(&v, 4); }
  { s199_t v = { 199, 199.5, "n199" }; t += f199(&v, 5); }
  printf("total=%f\n", t);
  return 0;
}
