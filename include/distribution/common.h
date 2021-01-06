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

#endif
