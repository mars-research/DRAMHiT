#ifndef ZIPF_CC_
#define ZIPF_CC_

#include "distribution/mica/zipf.h"

/*#ifdef MULTITHREAD_GENERATION
  #warning zipf.cc MULTITHREAD_GENERATION ON  
#else
  #warning zipf.cc MULTITHREAD_GENERATION OFF  
#endif
#ifdef MULTITHREAD_SUMMATION
  #warning zipf.cc MULTITHREAD_SUMMATION ON   
#else
  #warning zipf.cc MULTITHREAD_SUMMATION OFF
#endif*/

//CONSTANT (WRITE-ONCE THEN READ-ONLY)
static uint64_t (*func)(int) = NULL;
static uint64_t n_ = 0;  // number of items (input)
static double theta_ = 0.0; // skewness (input) in (0, 1); or, 0 = uniform, 1 = always zero
static double alpha_ = 0.0; // only depends on theta
static double thres_ = 0.0; // only depends on theta
static double dbl_n_ = 0.0; 
static double zetan_ = 0.0; 
static double eta_ = 0.0;
#ifdef MULTITHREAD_GENERATION
  static Rand rand_[GEN_THREADS];
#else
  static Rand rand_;
#endif


//NON-CONSTANT (READ & WRITE)
#ifdef MULTITHREAD_GENERATION
  static uint64_t seq_[GEN_THREADS] = {0}; // for sequential number generation
#else
  static uint64_t seq_ = 0; // for sequential number generation
#endif

void ZipfGen(uint64_t n, double t, uint64_t seed) {
  //printf("HERE!!!!\n");
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

    //printf("LINE: %d\n", __LINE__);
  //zetan_ = 0.;
  //eta_ = 0;

  //seq_ = 0;
  //alpha_ = 0;
  //thres_ = 0;

  //func = NULL;=
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

    //printf("LINE: %d\n", __LINE__);
  if (t == -1.) {
    //printf("LINE: %d\n", __LINE__);
    #ifdef MULTITHREAD_GENERATION
      seq_[0] = seed % n; //TODO: make for multiple threads
    #else
      seq_ = seed % n; //TODO: make for multiple threads
    #endif
    func = uniform_next;
  } 
  else if (t == 0.) {
    //printf("LINE: %d\n", __LINE__);
    func = single_next;
  } 
  else if (t > 0. && t < 1.) {
    //printf("LINE: %d\n", __LINE__);
    #ifdef MULTITHREAD_SUMMATION
      zetan_ = zeta(n_, theta_);
    #else
      zetan_ = zeta(0, zetan_, n_, theta_);
    #endif
    //printf("zetan: %f\n", zetan_);//70.561536
    eta_ = (1. - pow_approx(2. / (double)n_, 1. - theta_))/(1. - zeta(0, 0., 2, theta_) / zetan_);
    thres_ = (1. + pow_approx(0.5, t))/zetan_;

    zetan_ = 1/zetan_;
    alpha_ = 1. / (1. - t);
    func = theta_next;
  } 
  else {
    //printf("LINE: %d\n", __LINE__);
    func = large_next;
  }
}

uint64_t next() { return func(0); }
//void print_seed() {for(int i=0;i<GEN_THREADS;++i){printf("%lu ", rand_[i].state_);}printf("\n");}


uint64_t uniform_next(int id) {
  #ifdef MULTITHREAD_GENERATION
    uint64_t v = seq_[id];
    if (++seq_[id] >= n_) seq_[id] = 0;
  #else
    uint64_t v = seq_;
    if (++seq_ >= n_) seq_ = 0;
  #endif
  
  return v;
}
uint64_t single_next(int id) {
  #ifdef MULTITHREAD_GENERATION
    double u = rand_[id].next_f64();
  #else
    double u = rand_.next_f64();
  #endif
  return (uint64_t)(dbl_n_ * u);
}
uint64_t theta_next(int id) {
    //printf("LINE: %d\n", __LINE__);
  // from J. Gray et al. Quickly generating billion-record synthetic
  // databases. In SIGMOD, 1994.

  // double u = erand48(rand_state_);
  #ifdef MULTITHREAD_GENERATION
    double u = rand_[id].next_f64();

  #else
    double u = rand_.next_f64();
  #endif
  //printf("U: %f\n", u);
  //double uz = u * zetan_;
  if (u < zetan_)//1./zetan_)
  {
    //printf("U < %f(1/zetan)\n", zetan_);//1/zetan_);
    return 0UL;
  }
  else if (u < thres_)//thres_/zetan_)
  {
    //printf("Z < %f(threshold/zetan)\n", thres_);//thres_/zetan_);
    return 1UL;
  }
  else {
    //printf("LINE: %d\n", __LINE__);
    /*printf("Computing Key\n");
    printf("alpha: %f\n", alpha_);
    printf("eta: %f\n", eta_);
    printf("N: %lu\n", n_);*/
    uint64_t v = (uint64_t)(dbl_n_ * pow_approx(eta_ * (u - 1.) + 1., alpha_));
    //printf("LINE: %d\n", __LINE__);
    if (v >= n_) 
    {
      //printf("Key generated is outside range\n");
      v = n_ - 1;
    }
    return v;
  }
}
uint64_t large_next(int thread_id) {
  return 0UL;
}

#ifdef MULTITHREAD_GENERATION
  uint64_t next(int thread_id) { return func(thread_id); }
  void set_seed(uint64_t seed, int thread) {rand_[thread] = Rand(seed);}
#endif
#ifdef MULTITHREAD_SUMMATION
  void* zeta_chunk(void* data)
  {
    sum_data* td = (sum_data*) data;
    td->sum = zeta(td->last_n, 0, td->n, td->theta);
    return NULL;//pthread_exit(NULL);
  }
  double zeta(uint64_t n, double theta)
  {
    double sum = 0;
    pthread_t thread[SUM_THREADS];
    sum_data td[SUM_THREADS];
    int rc;

    for(int i = 0; i < SUM_THREADS; i++) {
        td[i].thread_id = i;
        td[i].last_n = ((double)i/SUM_THREADS)*n;
        td[i].n = ((double)(i+1)/SUM_THREADS)*n;
        td[i].theta = theta;

        rc = pthread_create(&thread[i], NULL, zeta_chunk, (void *)&td[i]);
        
        if (rc) {
          perror("Error:unable to create thread");
          exit(-1);
        }
    }

    for(int i = 0; i < SUM_THREADS; i++) {
        rc = pthread_join(thread[i], NULL);
        if (rc) {
          perror("thread join failed");
          exit(-1);
        }
        sum += td[i].sum;
    }
    return sum;
  }
#endif

#endif
