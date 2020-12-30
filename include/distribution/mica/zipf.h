#ifndef ZIPF_H_
#define ZIPF_H_

#include "distribution/common.h"
#include "distribution/rand.h"

/*#ifdef MULTITHREAD_GENERATION
  #warning multthrd gen def for zipf header  
#else
  #warning multthrd gen NOT def for zipf header  
#endif
#ifdef MULTITHREAD_SUMMATION
  #warning multthrd sum def for zipf header  
#else
  #warning multthrd sum NOT def for zipf header  
#endif*/



//Main functions
void ZipfGen(uint64_t n, double t, uint64_t seed);
uint64_t next();

//Classes of next functions 
uint64_t uniform_next(int);
uint64_t single_next(int);
uint64_t theta_next(int);
uint64_t large_next(int);

#ifdef MULTITHREAD_GENERATION
  uint64_t next(int);
  void set_seed(uint64_t seed, int thread);
#endif

#ifdef MULTITHREAD_SUMMATION
  //Multithreaded Summation computation
  typedef struct summation_thread_data {
    int  thread_id;
    uint64_t last_n;
    uint64_t n;
    double theta;

    double sum;
  } sum_data;
  void* zeta_chunk(void* data);
  double zeta(uint64_t n, double theta);
  //void print_seed();
#endif


//Helper functions
static double pow_approx(double a, double b) {
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

static double zeta(uint64_t last_n, double last_sum, uint64_t n, double theta) {
  if (last_n > n) {
    last_n = 0;
    last_sum = 0.;
  }

  while (last_n < n) {
    last_sum += 1. / pow_approx((double)(++last_n), theta);
  }
  return last_sum;
}

#endif
