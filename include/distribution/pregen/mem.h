//#pragma once
#ifndef MEM_H_
#define MEM_H_

#include "distribution/common.h"

//mmap and etc?
#include <sys/mman.h>
#include <unistd.h>

//Zipf generation and data
#include "distribution/mica/zipf.h"

/*#ifdef MULTITHREAD_GENERATION
  #warning multthrd gen mem def for mem header  
#else
  #warning multthrd gen mem NOT def for mem header  
#endif
#ifdef MULTITHREAD_SUMMATION
   #warning multthrd sum mem def for mem header  
#else
  #warning multthrd sum mem NOT def for mem header  
#endif*/

uint64_t* generate(uint64_t num, uint64_t range, double theta, uint64_t seed);
int clear(uint64_t* data);

#ifdef MULTITHREAD_GENERATION
    //Multithreaded data generation
    typedef struct generate_thread_data {
    int thread_id;
    uint64_t num;
    //uint64_t seed;
    uint64_t* data;
    //uint64_t start;
    //uint64_t end;
    } generate_data;
    void next(uint64_t* data, uint64_t len, uint64_t seed);
    void* next_chunk(void* data);
#endif

#endif
