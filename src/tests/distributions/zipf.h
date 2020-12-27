#ifndef ZIPF_H_
#define ZIPF_H_

#include <cmath>

#include "common.h"
#include "rand.h"

// used as declaration for Zipfian distribution generation
void ZipfGen(uint64_t n, double alpha, uint64_t seed);
uint64_t next();

#endif