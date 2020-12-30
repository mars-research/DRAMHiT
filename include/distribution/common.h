//#pragma once
#ifndef COMMON_H_
#define COMMON_H_

//Needed for uint64_t and etc.
#include <cinttypes>
#include <cstddef>
#include <cstdint>

//asserts
#include <cassert>

//math operations
#include <cmath>

//printf
#include <cstdio>

//timing analysis
#include "sync.h"
/*From /proc/cpuinfo*/
#define CPUFREQ_MHZ (2200.0)
static const float one_cycle_ns = ((float)1000 / CPUFREQ_MHZ);

//Needed for zipf.h and mem.h
#include <pthread.h>

//Threads to use in zipf and mem
#define MULTITHREAD_SUMMATION
#define MULTITHREAD_GENERATION
#define MULTITHREAD_INSERTION

//Generation and Insertion method (chunking or interleaving)
//#define GENERATION_CHUNKING
//#define INSERTION_CHUNKING

//Number of threads for each section
#define NUM_THREADS 3
#define SUM_THREADS 2//NUM_THREADS//
#define GEN_THREADS NUM_THREADS//2//
#define INS_THREADS NUM_THREADS//2//

#endif
