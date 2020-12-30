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

/*#ifdef MULTITHREAD_GENERATION
  #warning mem.h MULTITHREAD_GENERATION ON  
#else
  #warning mem.h MULTITHREAD_GENERATION OFF  
#endif
#ifdef MULTITHREAD_SUMMATION
  #warning mem.h MULTITHREAD_SUMMATION ON   
#else
  #warning mem.h MULTITHREAD_SUMMATION OFF
#endif*/

uint64_t* generate(uint64_t num, uint64_t range, double theta, uint64_t seed);
int clear(uint64_t* data);

#ifdef MULTITHREAD_GENERATION
    //Multithreaded data generation
    typedef struct generate_thread_data {
      int thread_id;
      uint64_t num;
      
      uint64_t* data;
    } generate_data;
    void* next_chunk(void* data);
    void next(uint64_t* data, uint64_t len, uint64_t seed);
#endif

#endif
