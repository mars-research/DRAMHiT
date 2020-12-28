#ifndef ZIPF_H_
#define ZIPF_H_

#include <cstdio>
#include <cstdlib>
//#include <cmath>
#include <time.h>

#include "../common.h"
#include "../rand.h"


#include "sync.h"

// ZipfGen(range, theta, seed);

double pow(double a, double b) {
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
static double c = 0;       // Normalization constant
static double *sum_probs;  // Pre-calculated sum of probabilities
static Rand r;
static uint64_t n;
static double alpha;

//static double p;
//static int max_count = 1;
//static uint64_t t = 0;

void ZipfGen(uint64_t range, double theta, uint64_t seed) {
  n = range;
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
  }
  r = Rand(seed);
  //p = r.next_f64();
  //p = 0.007788;
  //printf("rand is %f\n", p);
  //p = r.next_f64();
  //printf("max_count is %d\n", max_count);

  //printf("longest insertion was %lu cycles\n", t);
}


inline uint64_t next() {
  double z;             // Uniform random number (0 < z < 1)
  int zipf_value = -1;  // Computed exponential value to be returned

  /*uint64_t t_start, t_end;

  t_start = RDTSC_START();*/
  // Pull a uniform random number (0 < z < 1)
  //p = 1 - p;

  z = r.next_f64();//p;//0.839587;//r.next_f64();
  /*do {
    z = p;//((double)rand())/RAND_MAX;//0.5;//r.next_f64();
  } while ((z == 0) || (z == 1));*/

  // Map z to the value
  #ifdef BINARY
    int low = 1, high = n, mid; // Binary-search bounds
    //int count=0;
    do {
      mid = floor((low + high) / 2);
      //++count;
      if (sum_probs[mid] >= z && sum_probs[mid - 1] < z) {
        zipf_value = mid;
        break;
      } else if (sum_probs[mid] >= z) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    } while (low <= high);
  #else
    //printf("LINE: %d\n", __LINE__);

    //initial guess
    int64_t k_o, k = (n>>1);//z*n;//(double) (n>>1);//

    z /= c;
    //printf("LINE: %d\t k: %f\n", __LINE__, k);
    do
    {
      //++i;
      k_o = k;
      //printf("LINE: %d\t i: %lu\t k: %f\n", __LINE__, i, k);
      //printf("LINE: %d\t i: %lu\t k_o: %f\n", __LINE__, i, k_o);
      if(k_o > (int64_t) n){k_o = (int64_t) n;}
      else if(k_o <= 0){k_o = 1;}
      //printf("LINE: %d\t i: %lu\t k_o: %f\n", __LINE__, i, k_o);
      if (sum_probs[k_o] >= 0 && sum_probs[k_o - 1] < 0) {
        break;
      }
      /*tmp = pow(k_o,alpha)*(sum_probs[(uint64_t)k_o]-z);
      printf("LINE: %d\t i: %lu\t pow(k_o,alpha)*(sum_probs[(uint64_t)k_o]-z: %f\n", __LINE__, i, tmp);
      tmp = k_o-tmp;
      printf("LINE: %d\t i: %lu\t k_o-tmp: %f\n", __LINE__, i, tmp);*/
      /*k = k - k^theta*(sum_probs[k]-z)*/
      k = (int64_t)(k_o - pow(k_o,alpha)*(sum_probs[k_o]-z));
      /*printf("LINE: %d\t i: %lu\t k_o - pow(k_o,alpha)*(sum_probs[k_o]-z): %f\n", __LINE__, i, (double)((double)k_o - (double)(pow(k_o,alpha)*(sum_probs[(uint64_t)k_o]-z))));

      printf("LINE: %d\t i: %lu\t k: %f\n", __LINE__, i, k);
      printf("LINE: %d\t i: %lu\t k_o: %f\n", __LINE__, i, k_o);

      printf("LINE: %d\t i: %lu\t k-k_o: %f\n", __LINE__, i, k-k_o);
      printf("LINE: %d\t i: %lu\t abs(k-k_o): %f\n", __LINE__, i, abs(k-k_o));*/
    } while (abs(k-k_o)>1.0);// && i<=25);
    zipf_value = (uint64_t)k_o;
    //printf("LINE: %d\n", __LINE__);
  #endif
  /*if(count>max_count)
  {
    max_count = count;
    //p = z;
  }*/

  /*t_end = RDTSCP();
  if(t_end-t_start>t)
  {
    t = t_end-t_start;
    
  }*/
  // Assert that zipf_value is between 1 and N
  // assert((zipf_value >=1) && (zipf_value <= n));

  return zipf_value;
}

int ZipfGen2(uint64_t n, double alpha, uint64_t seed)
{
  static int first = 1;      // Static first time flag
  static double c = 0;          // Normalization constant
  static double *sum_probs;     // Pre-calculated sum of probabilities
  static Rand r;
  double z;                     // Uniform random number (0 < z < 1)
  int zipf_value = -1;               // Computed exponential value to be
  // int    i;                     // Loop counter
  int low, high, mid;  // Binary-search bounds

  // Compute normalization constant on first call only
  if (first)
  {
    //printf("first\n");
    for (uint64_t i=1; i<=n; i++)
      c = c + (1.0 / pow((double) i, alpha));
    c = 1.0 / c;

    sum_probs = new double[(n+1)*sizeof(*sum_probs)];
    sum_probs[0] = 0;
    for (uint64_t i=1; i<=n; i++) {
      sum_probs[i] = sum_probs[i-1] + c / pow((double) i, alpha);
    }
    r = Rand(seed);
    first = 0;
  }

  // Pull a uniform random number (0 < z < 1)
  do
  {
    z = r.next_f64();
  }
  while ((z == 0) || (z == 1));

  // Map z to the value
  low = 1, high = n;//, mid;
  do {
    mid = floor((low+high)/2);
    if (sum_probs[mid] >= z && sum_probs[mid-1] < z) {
      zipf_value = mid;
      break;
    } else if (sum_probs[mid] >= z) {
      high = mid-1;
    } else {
      low = mid+1;
    }
  } while (low <= high);

  // Assert that zipf_value is between 1 and N
  //assert((zipf_value >=1) && (zipf_value <= n));

    //printf("%d\n",zipf_value);
  return zipf_value;
}

#endif