#ifndef ZIPF_H_
#define ZIPF_H_

#include "../common.h"
#include "../rand.h"

#include <cstdio>
#include <cstdlib>

//ZipfGen(range, theta, seed);

//static int first = 1;      // Static first time flag
static double c = 0;          // Normalization constant
static double *sum_probs;     // Pre-calculated sum of probabilities
static Rand r;
static uint64_t n;
void ZipfGen(uint64_t range, double alpha, uint64_t seed)
{
    n = range;
    for (uint64_t i=1; i<=n; i++)
      c = c + (1.0 / pow((double) i, alpha));
    c = 1.0 / c;
//
    sum_probs = new double[(n+1)*sizeof(*sum_probs)];
    sum_probs[0] = 0;
    for (uint64_t i=1; i<=n; i++) {
      sum_probs[i] = sum_probs[i-1] + c / pow((double) i, alpha);
    }
    r = Rand(seed);
}

uint64_t next()
{
    double z;                     // Uniform random number (0 < z < 1)
    int zipf_value = -1;               // Computed exponential value to be returned
    //int    i;                     // Loop counter
    int low, high, mid;           // Binary-search bounds

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
        if (sum_probs[mid] >= z && sum_probs[mid-1] < z) 
        {
            zipf_value = mid;
            break;
        } 
        else if (sum_probs[mid] >= z) 
        {
            high = mid-1;
        } 
        else 
        {
            low = mid+1;
        }
    } while (low <= high);

    // Assert that zipf_value is between 1 and N
    //assert((zipf_value >=1) && (zipf_value <= n));

    return zipf_value;
}

/*int ZipfGen2(uint64_t n, double alpha, uint64_t seed)
{
  static int first = 1;      // Static first time flag
  static double c = 0;          // Normalization constant
  static double *sum_probs;     // Pre-calculated sum of probabilities
  static Rand r;
  double z;                     // Uniform random number (0 < z < 1)
  int zipf_value = -1;               // Computed exponential value to be returned
  int    i;                     // Loop counter
  int low, high, mid;           // Binary-search bounds

  // Compute normalization constant on first call only
  if (first)
  {
    //printf("first\n");
    for (i=1; i<=n; i++)
      c = c + (1.0 / pow((double) i, alpha));
    c = 1.0 / c;

    sum_probs = new double[(n+1)*sizeof(*sum_probs)];
    sum_probs[0] = 0;
    for (i=1; i<=n; i++) {
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
  low = 1, high = n, mid;
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
}*/

#endif