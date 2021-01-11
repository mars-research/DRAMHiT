#ifndef ZIPF_H_
#define ZIPF_H_

#include "distribution/common.h"
#include "distribution/rand.h"

//Main functions
void ZipfGen(uint64_t n, double t, uint64_t seed, uint8_t tid, uint8_t num_threads);

void gen_keys(uint64_t* key, uint64_t start, uint64_t end);
void gen_keys(uint64_t* key, uint64_t start, uint64_t end, uint64_t (*key_map)(uint64_t));

uint64_t next();


//Classes of next functions based on input theta value
uint64_t uniform_next(int);
uint64_t single_next(int);
uint64_t theta_next(int);
uint64_t large_next(int);


//Helper functions
inline double pow_approx(double a, double b)
{
  // from http://martin.ankerl.com/2012/01/25/optimized-approximative-pow-in-c-and-cpp/

  // calculate approximation with fraction of the exponent
  int e = (int)b;
  union {
    double d;
    int x[2];
  } u = {a};
  u.x[1] = (int)((b - (double)e) * (double)(u.x[1] - 1072632447) + 1072632447.);
  u.x[0] = 0;

  // exponentiation by squaring with the exponent's integer part
  // double r = u.d makes everything much slower, not sure why
  // TODO: use popcount?
  double r = 1.;
  while (e) {
    if (e & 1) r *= a;
    a *= a;
    e >>= 1;
  }

  return r * u.d;
}

inline double zeta(uint64_t last_n, double last_sum, uint64_t n, double theta) {
  if (last_n > n) {
    last_n = 0;
    last_sum = 0.;
  }
//printf("LINE: %d\n", __LINE__);

//printf("last_n: %lu\tn: %lu\n", last_n, n);
  while (last_n < n) {
    last_sum += 1. / pow_approx((double)(++last_n), theta);
  }
  //printf("LINE: %d\n", __LINE__);
  return last_sum;
}

#endif
