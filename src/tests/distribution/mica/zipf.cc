#ifndef ZIPF_CC_
#define ZIPF_CC_

#include "distribution/mica/zipf.h"

//CONSTANT (WRITE-ONCE THEN READ-ONLY)
static uint64_t (*func)(int) = NULL;
static uint64_t n_ = 0;  // number of items (input)
static double theta_ = 0.0; // skewness (input) in (0, 1); or, 0 = uniform, 1 = always zero
static double alpha_ = 0.0; // only depends on theta
static double thres_ = 0.0; // only depends on theta
static double dbl_n_ = 0.0; 
static double zetan_ = 0.0; 
volatile uint8_t zeta_sum_ready = 0;
volatile double zetan_partial_sum = 0.0;
static double eta_ = 0.0;
#ifdef MULTITHREAD_GENERATION
  static Rand rand_[GEN_THREADS];
#else
  static thread_local Rand rand_;
#endif


//NON-CONSTANT (READ & WRITE)
#ifdef MULTITHREAD_GENERATION
  static uint64_t seq_[GEN_THREADS] = {0}; // for sequential number generation
#else
  static uint64_t seq_ = 0; // for sequential number generation
#endif

void until_sum(uint8_t tid)
{
  while(zeta_sum_ready!=tid){}
}

double zeta(uint64_t n, double theta, uint8_t tid, uint8_t num_threads) {
  return zeta(((double)tid/num_threads)*n, 0, ((double)(tid+1)/num_threads)*n, theta);
}

void ZipfGen(uint64_t n, double t, uint64_t seed, uint8_t tid, uint8_t num_threads) {
  assert(n > 0);
  if (t > 0.992 && t < 1)
    fprintf(stderr,
            "warning: theta > 0.992 will be inaccurate due to approximation\n");
  if (t >= 1. && t < 40.) {
    fprintf(stderr, "error: theta in [1., 40.) is not supported\n");
    assert(false);
    theta_ = 0;  // unused
    alpha_ = 0;  // unused
    thres_ = 0;  // unused
    return;
  }
  assert(t == -1. || (t >= 0. && t < 1.) || t >= 40.);

  alpha_ = 0.0; // only depends on theta
  thres_ = 0.0; // only depends on theta
  zetan_ = 0.0; 
  eta_ = 0.0;

  n_ = n;
  theta_ = t;
  dbl_n_ = (double)n_;

  #ifdef MULTITHREAD_GENERATION
    set_seed(seed, 0); //TODO: make for multiple threads
  #else
    rand_ = Rand(seed);
  #endif

  if (t == -1.) {
    #ifdef MULTITHREAD_GENERATION
      seq_[0] = seed % n; //TODO: make for multiple threads
    #else
      seq_ = seed % n; //TODO: make for multiple threads
    #endif
    func = uniform_next;
  } 
  else if (t == 0.) {
    func = single_next;
  } 
  else if (t > 0. && t < 1.) {
    double zetan_partial = zeta(n_, theta_, tid, num_threads);


    //printf("THREAD %u: zetan_partial: %f\n", tid, zetan_partial);//70.561536
    until_sum(tid);
    zetan_partial_sum += zetan_partial;
    ++zeta_sum_ready;
    //printf("THREAD %u: zeta_sum_ready: %lu\n", tid, zeta_sum_ready);//70.561536
    until_sum(num_threads);

    zetan_ = zetan_partial_sum;
    //printf("THREAD %u: zetan: %f\n", tid, zetan_);//70.561536

    eta_ = (1. - pow_approx(2. / (double)n_, 1. - theta_))/(1. - zeta(0, 0., 2, theta_) / zetan_);
    thres_ = (1. + pow_approx(0.5, t))/zetan_;

    zetan_ = 1/zetan_;
    alpha_ = 1. / (1. - t);
    func = theta_next;
  } 
  else {
    func = large_next;
  }
}

void generate(uint64_t* m, uint64_t start, uint64_t end)
{
  //pregenerate the indices/keys
  for(uint64_t i = start; i < end; ++i) 
  {
      //next returns a number from [0 - config.range]
      //insert has issues if key inserted is 0 so add 1
      m[i] = next()+1; //TODO: modify to return key instead i.e. "keys[next()]"
      printf("%lu\n", m[i]);
  }
}

uint64_t next() { return func(0); }


uint64_t uniform_next(int id) {
  #ifdef MULTITHREAD_GENERATION
    uint64_t v = seq_[id];
    if (++seq_[id] >= n_) seq_[id] = 0;
  #else
    uint64_t v = seq_;
    if (++seq_ >= n_) seq_ = 0;
  #endif
  
  return v+1;
}
uint64_t single_next(int id) {
  #ifdef MULTITHREAD_GENERATION
    double u = rand_[id].next_f64();
  #else
    double u = rand_.next_f64();
  #endif
  return (uint64_t)(dbl_n_ * u) +1;
}
uint64_t theta_next(int id) {
  // from J. Gray et al. Quickly generating billion-record synthetic
  // databases. In SIGMOD, 1994.

  double u = rand_.next_f64();
  if (u < zetan_)
  {
    return 0UL;//1UL;//
  }
  else if (u < thres_)
  {
    return 1UL;//2UL;//
  }
  else {

    printf("[INFO]]Core %u: Creating Node allocation thread\n", id);
    uint64_t v = (uint64_t)(dbl_n_ * pow_approx(eta_ * (u - 1.) + 1., alpha_));
    if (v >= n_) 
    {
      v = n_ - 1;
    }
    return v;
  }
}
uint64_t large_next(int thread_id) {
  return 1UL;//0UL;
}

#endif
