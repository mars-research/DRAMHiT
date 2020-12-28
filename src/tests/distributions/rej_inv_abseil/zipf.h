#ifndef ZIPF_H_
#define ZIPF_H_

#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <time.h>

#include "../common.h"
#include "../rand.h"


#include "sync.h"

// ZipfGen(range, theta, seed);

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

// static int first = 1;      // Static first time flag
/*static double c = 0;       // Normalization constant
static double *sum_probs;  // Pre-calculated sum of probabilities
static uint64_t n;
static double alpha;*/


static Rand r;

static double q = 1.5; //q > 1
static double v = 1.5; //v > 0
static double q_not;
static double q_not_inv;
static double H_x0;
static double s;
static double H_Imax;

inline double H(double x)
{
  //return exp(q_not*log(v+x))*q_not_inv;
  return pow(v+x, q_not)*q_not_inv;
}
inline double H_inv(double x)
{
  //return -v+exp(q_not_inv*log(q_not*x));
  return pow(x*q_not, q_not_inv)-v;
}
/*inline double H_inv2(double x)
{
  
  printf("x: %f\n", x);
  printf("x*q_not: %f\n", x*q_not);
  printf("q_not_inv: %f\n", q_not_inv);


  printf("pow(1, 1): %f\n", pow(0.7, -2));
  printf("pow(0.7, 2): %f\n", pow(0.7, 2));
  printf("pow(1, -2): %f\n", pow(1, -2));
  printf("pow(0.7, -2): %f\n", pow(0.7, -2));
  printf("pow(0.7, -2): %f\n", pow(0.7, -2.0));
  printf("pow(0.703841, -2.000000): %f\n", pow(0.703841, -2.000000));
  printf("pow(x*q_not, q_not_inv): %f\n", pow(x*q_not, q_not_inv));
  printf("pow(x*q_not, q_not_inv)-v: %f\n", pow(x*q_not, q_not_inv)-v);
  return pow(x*q_not, q_not_inv)-v;
}*/
//static double p;
//static int max_count = 1;
//static uint64_t t = 0;

void ZipfGen(uint64_t range, double theta, uint64_t seed) {
  q = 1.5;
  v = 1.5;

    printf("LINE: %d\n", __LINE__);
  q_not = 1-q;
  q_not_inv = 1/q_not;
    //printf("LINE: %d\n", __LINE__);
    /*printf("LINE: %d\n", __LINE__);
  printf("H(3.0/2): %f\n", H(3.0/2));
  printf("exp(log(v+1)*(-q)): %f\n", exp(log(v+1)*(-q)));
  printf("H(3.0/2)-exp(log(v+1)*(-q)): %f\n", H(3.0/2)-exp(log(v+1)*(-q)));
  printf("H_inv2(H(3.0/2)-exp(log(v+1)*(-q))): %f\n", H_inv2(H(3.0/2)-exp(log(v+1)*(-q))));
  printf("1 - H_inv2(H(3.0/2)-exp(log(v+1)*(-q))): %f\n", 1 - H_inv2(H(3.0/2)-exp(log(v+1)*(-q))));*/
  s = 1 - H_inv(H(3.0/2)-exp(log(v+1)*(-q)));
    //printf("LINE: %d\n", __LINE__);
  H_Imax = H(INT32_MAX+1.0/2);
  H_x0 = (H(1.0/2) - exp(log(v)*(-q))) - H_Imax;

    //printf("LINE: %d\n", __LINE__);

  /*n = range;
  alpha = theta;
  for (uint64_t i = 1; i <= n; i++) c = c + (1.0 / pow((double)i, alpha));
  c = 1.0 / c;
  //
  sum_probs = new double[(n + 1) * sizeof(*sum_probs)];
  sum_probs[0] = 0;
  for (uint64_t i = 1; i <= n; i++) {
    #ifdef BINARY
      sum_probs[i] = sum_probs[i - 1] + c / pow((double)i, alpha);
    #else
      sum_probs[i] = sum_probs[i - 1] + 1.0 / pow((double)i, alpha);
    #endif
  }*/
  r = Rand(seed);
}


inline uint64_t next() {
  double U, X, K;             // Uniform random number (0 < z < 1)
  int zipf_value = -1;  // Computed exponential value to be returned

  /*uint64_t t_start, t_end;

  t_start = RDTSC_START();*/
  // Pull a uniform random number (0 < z < 1)
  //p = 1 - p;
    //printf("LINE: %d\n", __LINE__);
  while(true)
  {
    U = r.next_f64();//p;//0.839587;//r.next_f64();
    //U = H_Imax + U*(H_x0 - H_Imax);
    U = H_Imax + U*H_x0;
    //printf("LINE: %d\n", __LINE__);
    X = H_inv(U);
    //printf("H_inv1(%f) = %f\tH_inv2(%f) = %f\n", U, H_inv1(U), U, H_inv2(U));
    K = floor(X+1.0/2);
    if(K-X <= s)
    {
      return K;
    }
    //else if(U >= H(K+1.0/2)-exp(-log(v+K)*q))
    else if(U >= H(K+1.0/2)-pow(v+K,-q))
    {
      return K;
    }
  }
  /*do {
    z = p;//((double)rand())/RAND_MAX;//0.5;//r.next_f64();
  } while ((z == 0) || (z == 1));*/

  return zipf_value;
}

#endif