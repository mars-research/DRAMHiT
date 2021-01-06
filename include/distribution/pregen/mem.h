//#pragma once
#ifndef MEM_H_
#define MEM_H_

#include "distribution/common.h"

//mmap and etc?
#include <sys/mman.h>
#include <unistd.h>

//file mmapping
#include <fcntl.h>

//Zipf generation and data
#include "distribution/mica/zipf.h"

uint64_t* allocate(uint64_t num, uint64_t range, double theta, uint64_t seed);
int clear(uint64_t* data);

#endif
