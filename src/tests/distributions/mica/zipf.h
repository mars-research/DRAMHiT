#pragma once
#ifndef ZIPF_H_
#define ZIPF_H_

#include <cassert>
#include <cmath>
#include <cstdio>

#include "../common.h"
#include "../rand.h"

double pow_approx(double a, double b);
double zeta(uint64_t last_n, double last_sum, uint64_t n, double theta);
void change_n(uint64_t n);
uint64_t uniform_next();
uint64_t single_next();
uint64_t theta_next();
uint64_t large_next();

// static uint64_t next() = NULL;
static uint64_t (*func)(void) = NULL;
static uint64_t n_ = 0;  // number of items (input)
static double theta_ =
    0.0;  // skewness (input) in (0, 1); or, 0 = uniform, 1 = always zero
static double alpha_ = 0.0;   // only depends on theta
static double thres_ = 0.0;   // only depends on theta
static uint64_t last_n_ = 0;  // last n used to calculate the following
static double dbl_n_ = 0.0;
static double zetan_ = 0.0;
static double eta_ = 0.0;
static uint64_t seq_ = 0;  // for sequential number generation
static Rand rand_;
void ZipfGen(uint64_t n, double alpha, uint64_t seed) {
  assert(n > 0);
  if (alpha > 0.992 && alpha < 1)
    fprintf(stderr,
            "warning: theta > 0.992 will be inaccurate due to approximation\n");
  if (alpha >= 1. && alpha < 40.) {
    fprintf(stderr, "error: theta in [1., 40.) is not supported\n");
    assert(false);
    theta_ = 0;  // unused
    alpha_ = 0;  // unused
    thres_ = 0;  // unused
    return;
  }
  assert(alpha == -1. || (alpha >= 0. && alpha < 1.) || alpha >= 40.);
  n_ = n;
  theta_ = alpha;
  if (alpha == -1.) {
    seq_ = seed % n;
    alpha_ = 0;  // unused
    thres_ = 0;  // unused
  } else if (alpha > 0. && alpha < 1.) {
    seq_ = 0;  // unused
    alpha_ = 1. / (1. - alpha);
    thres_ = 1. + pow_approx(0.5, alpha);
  } else {
    seq_ = 0;     // unused
    alpha_ = 0.;  // unused
    thres_ = 0.;  // unused
  }
  last_n_ = 0;
  zetan_ = 0.;
  eta_ = 0;
  // rand_state_[0] = (unsigned short)(rand_seed >> 0);
  // rand_state_[1] = (unsigned short)(rand_seed >> 16);
  // rand_state_[2] = (unsigned short)(rand_seed >> 32);
  rand_ = Rand(seed);
  if (alpha == -1.) {
    func = uniform_next;
  } else if (alpha == 0.) {
    func = single_next;
  } else if (alpha > 0. && alpha < 1.) {
    func = theta_next;
  } else {
    func = large_next;
  }
}

uint64_t next() { return func(); }

double pow_approx(double a, double b) {
  // from
  // http://martin.ankerl.com/2012/01/25/optimized-approximative-pow-in-c-and-cpp/

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
/*void test(double theta) {
  double zetan = 0.;
  const uint64_t n = 1000000UL;
  uint64_t i;

  for (i = 0; i < n; i++) zetan += 1. / pow((double)i + 1., theta);

  if (theta < 1. || theta >= 40.) {
    Base_ZipfGen* zg = ZipfGen(n, theta, 0);

    uint64_t num_key0 = 0;
    const uint64_t num_samples = 10000000UL;
    if (theta < 1. || theta >= 40.) {
      for (i = 0; i < num_samples; i++)
        if (zg->next() == 0) num_key0++;
    }

    printf("theta = %lf; using pow(): %.10lf", theta, 1. / zetan);
    if (theta < 1. || theta >= 40.)
      printf(", using approx-pow(): %.10lf",
             (double)num_key0 / (double)num_samples);
    printf("\n");
  }
}*/
double zeta(uint64_t last_n, double last_sum, uint64_t n, double theta) {
  if (last_n > n) {
    last_n = 0;
    last_sum = 0.;
  }
  while (last_n < n) {
    last_sum += 1. / pow_approx((double)last_n + 1., theta);
    last_n++;
  }
  return last_sum;
}
void change_n(uint64_t n) { n_ = n; }

uint64_t uniform_next() {
  if (last_n_ != n_) {
    last_n_ = n_;
    dbl_n_ = (double)n_;
  }

  uint64_t v = seq_;
  if (++seq_ >= n_) seq_ = 0;
  return v;
}
uint64_t single_next() {
  if (last_n_ != n_) {
    last_n_ = n_;
    dbl_n_ = (double)n_;
  }

  double u = rand_.next_f64();
  return (uint64_t)(dbl_n_ * u);
}
uint64_t theta_next() {
  if (last_n_ != n_) {
    zetan_ = zeta(last_n_, zetan_, n_, theta_);
    eta_ = (1. - pow_approx(2. / (double)n_, 1. - theta_)) /
           (1. - zeta(0, 0., 2, theta_) / zetan_);
    last_n_ = n_;
    dbl_n_ = (double)n_;
  }

  // from J. Gray et al. Quickly generating billion-record synthetic
  // databases. In SIGMOD, 1994.

  // double u = erand48(rand_state_);
  double u = 0.5;//rand_.next_f64();
  double uz = u * zetan_;
  if (uz < 1.)
    return 0UL;
  else if (uz < thres_)
    return 1UL;
  else {
    uint64_t v = (uint64_t)(dbl_n_ * pow_approx(eta_ * (u - 1.) + 1., alpha_));
    if (v >= n_) v = n_ - 1;
    return v;
  }
}
uint64_t large_next() {
  if (last_n_ != n_) {
    last_n_ = n_;
    dbl_n_ = (double)n_;
  }

  return 0UL;
}

/*class Base_ZipfGen {
 public:
  Base_ZipfGen(uint64_t n, double theta, uint64_t rand_seed);
  Base_ZipfGen(const Base_ZipfGen& src);
  Base_ZipfGen(const Base_ZipfGen& src, uint64_t rand_seed);
  Base_ZipfGen& operator=(const Base_ZipfGen& src);

  void change_n(uint64_t n);
  virtual uint64_t next() = 0;

  static void test(double theta);

 protected:
  static double pow_approx(double a, double b);

  static double zeta(uint64_t last_n, double last_sum, uint64_t n,
                     double theta);

  uint64_t n_ = 0;  // number of items (input)
  double theta_ = 0.0;  // skewness (input) in (0, 1); or, 0 = uniform, 1 =
always zero double alpha_ = 0.0;     // only depends on theta double thres_ =
0.0;     // only depends on theta uint64_t last_n_ = 0;  // last n used to
calculate the following double dbl_n_ = 0.0; double zetan_ = 0.0; double eta_ =
0.0;
  // unsigned short rand_state[3];    // prng state
  uint64_t seq_ = 0;  // for sequential number generation
  Rand rand_ = Rand();
} __attribute__((aligned(128)));  // To prevent false sharing caused by
                                  // adjacent cacheline prefetching.

Base_ZipfGen* ZipfGen(uint64_t, double, uint64_t);
class Uniform_ZipfGen : public Base_ZipfGen
{
  public:
        Uniform_ZipfGen(uint64_t n, double theta, uint64_t
rand_seed):Base_ZipfGen(n, theta, rand_seed){} uint64_t next();
};
class Single_ZipfGen : public Base_ZipfGen
{
  public:
        Single_ZipfGen(uint64_t n, double theta, uint64_t
rand_seed):Base_ZipfGen(n, theta, rand_seed){} uint64_t next();
};
class Theta_ZipfGen : public Base_ZipfGen
{
  public:
        Theta_ZipfGen(uint64_t n, double theta, uint64_t
rand_seed):Base_ZipfGen(n, theta, rand_seed){} uint64_t next();
};
class Large_ZipfGen : public Base_ZipfGen
{
  public:
        Large_ZipfGen(uint64_t n, double theta, uint64_t
rand_seed):Base_ZipfGen(n, theta, rand_seed){} uint64_t next();
};*/

#endif
