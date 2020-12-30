// #pragma once
#ifndef MEM_CC_
#define MEM_CC_

/*#include <sys/mman.h>
#include <unistd.h>

#include <cassert>
#include <cmath>
#include <cstdio>*/

#include "distribution/pregen/mem.h"
//#define MULTITHREAD_GENERATION_CC_ MULTITHREAD_GENERATION_H_
//#define MULTITHREAD_SUMMATION_CC_ MULTITHREAD_SUMMATION_H_

/*#define NONE 0
#define MICA 1
#define STCKOVRFLW 2
#define TOOBIASED 3
#define REJ_INV 4*/

//#define MEM
#define MMAP
#define HUGEPAGES
//#define FILE_MMAP
/*#define HEADER MICA//REJ_INV//STCKOVRFLW//MICA//TOOBIASED//

#ifndef HEADER
  #include "../distributions/zipf.h"
#elif HEADER == MICA
  /*extern void ZipfGen(uint64_t n, double t, uint64_t seed);
  extern uint64_t next();
  extern void set_seed(uint64_t seed, int thread_id);* /
#elif HEADER == STCKOVRFLW
  #include "../distributions/stackoverflow/zipf.h"
#elif HEADER == TOOBIASED
  #include "../distributions/toobiased/zipf.h"
#elif HEADER == REJ_INV
  #include "../distributions/rej_inv_abseil/zipf.h"
#endif*/

#ifdef HUGEPAGES
#define PG_SIZE (getpagesize() * 512)
#else
#define PG_SIZE (getpagesize())
#endif

uint64_t* generate(uint64_t num, uint64_t range, double theta, uint64_t seed) {
#if defined(MEM)
  uint64_t* data = new uint64_t[num];
#elif defined(MMAP) || defined(FILE_MMAP)
#ifdef FILE_MMAP
  int fd = open("test", O_RDWR | O_CREAT, S_IRWXU);
  if (fd == -1) {
    perror("Opening file Failed.");
    return NULL;
  }
  ++num;
#endif
  size_t pagesize = PG_SIZE;

  uint64_t num_pages = (((num+1) * sizeof(uint64_t)) / pagesize) + 1;
  uint64_t* data = (uint64_t*)mmap(
      (void*)(pagesize * (1 << 20)),  // Map from the start of the 2^20th page
      num_pages * pagesize,           // for one page length
      PROT_READ | PROT_WRITE,         //|PROT_EXEC,
      MAP_ANON | MAP_PRIVATE
#ifdef HUGEPAGES
          | MAP_HUGETLB
#endif
      ,  // to a private block of hardware memory
      0
#ifdef FILE_MMAP
          | fd
#endif
      ,
      0);
  if (data == MAP_FAILED) {
    perror("Map Failed.");
#ifdef FILE_MMAP
    int result = close(fd);
    if (result != 0) {
      perror("Could not close file");
      return NULL;
    }
#endif
    return NULL;
  }
  data[0] = num_pages * pagesize;
  ++data;
#ifdef FILE_MMAP
  data[0] = fd;
  ++data;
#endif
#endif

  // data[0] =  1+(1<<12);//num;
  // ZipfGen* zg = new
  uint64_t t_start = RDTSC_START();
  ZipfGen(range, theta, seed);
  uint64_t t_end = RDTSCP();
  #ifdef MULTITHREAD_SUMMATION
    printf("[INFO] Sum computed in %lu cycles (%f ms) with %d threads\n", t_end-t_start, (double)(t_end-t_start) * one_cycle_ns / 1000000.0, SUM_THREADS);
  #else
    printf("[INFO] Sum computed in %lu cycles (%f ms) with no threading\n", t_end-t_start, (double)(t_end-t_start) * one_cycle_ns / 1000000.0);
  #endif
    
    /*printf("LINE: %d\n", __LINE__);
    printf("Main thread: ");
    print_seed();*/
  /*uint64_t nmbr = 1LL<<32;
    printf("1<<32: %lu\n", nmbr);
    nmbr = 1LL<<63;
    printf("1<<64: %lu\n", nmbr);*/
  // Base_ZipfGen* zg = ZipfGen(range, theta, seed);
  t_start = RDTSC_START();
  //printf("i goes from %lu - %lu\n", 0, num-1);
  #ifdef MULTITHREAD_GENERATION
    next(data, num, seed);
  #else
    for (uint64_t i = 0; i < num; ++i) {
      // seed = zg->next();
      
      //printf("Iteration: %lu\n", i);
      data[i] = next();  // ZipfGen2(range, theta, seed); //seed;
      //printf("key: %lu\n", data[i]);
      //printf("\n");
      //printf("%lu\n", data[i]);
    }
  #endif
  t_end = RDTSCP();
  #ifdef MULTITHREAD_GENERATION
    printf("[INFO] Data generated in %lu cycles (%f ms) at rate of %lu cycles/element with %d threads\n", t_end-t_start, (double)(t_end-t_start) * one_cycle_ns / 1000000.0, (t_end-t_start)/num, GEN_THREADS);
  #else
    printf("[INFO] Data generated in %lu cycles (%f ms) at rate of %lu cycles/element with no threading\n", t_end-t_start, (double)(t_end-t_start) * one_cycle_ns / 1000000.0, (t_end-t_start)/num);
  #endif
  // delete zg;
  return data;
}

int clear(uint64_t* data) {
#if defined(MEM)
  delete[] data;
#elif defined(MMAP) || defined(FILE_MMAP)
#ifdef FILE_MMAP
  uint64_t fd = data[-1];
  int result = munmap(data - 2, data[-2]);
#else
  int result = munmap(data - 1, data[-1]);
#endif
  if (result != 0) {
    perror("Could not munmap");
#ifdef FILE_MMAP
    result = close(fd);
    if (result != 0) {
      perror("Could not close file");
      return 1;
    }
#endif
    return 1;
  }
#ifdef FILE_MMAP
  result = close(fd);
  if (result != 0) {
    perror("Could not close file");
    return 1;
  }
#endif
#endif
  return 0;
}


//#define NUM_THREADS 1
#ifdef MULTITHREAD_GENERATION
  void* next_chunk(void* data)
  {
    generate_data* td = (generate_data*) data;

    //printf("LINE: %d\n", __LINE__);
    //printf("LINE: %d\n", __LINE__);
    //td->sum = zeta(td->last_n, 0, td->n, td->theta);
    /*printf("Thread %d: seed=%lu\n", td->thread_id, rand_[td->thread_id].state_);
    printf("Thread %d: ", td->thread_id);
      print_seed();
    printf("Thread %d: i goes from %lu - %lu\n", td->thread_id, 0, td->num-1);*/
    //int count = 0;
    for (uint64_t i = 0; i < td->num; ++i) {
      td->data[i] = next(td->thread_id);
      //++count;
    }
    /*printf("td->num: %lu\n", td->num);
    printf("count: %d\n", count);*/
    //printf("LINE: %d\n", __LINE__);
    return NULL;//pthread_exit(NULL);
  }
  void next(uint64_t* data, uint64_t len, uint64_t seed)
  {
    //printf("LINE: %d\n", __LINE__);
    pthread_t thread[GEN_THREADS];
    generate_data td[GEN_THREADS];
    int rc;
    uint64_t start, end;


    //printf("LINE: %d\n", __LINE__);
    for(int i = 0; i < GEN_THREADS; i++) {
    //printf("LINE: %d\n", __LINE__);
        td[i].thread_id = i;
    //printf("LINE: %d\n", __LINE__);
        //td[i].seed = seed % (len/i);
        if(i)
        {
          //uint64_t tmp = next();
          set_seed(next(), td[i].thread_id);//tmp, td[i].thread_id);
          //printf("tmp: %lu\n", tmp);
        }
        //printf("Thread %d: ", i);
      //print_seed();
    //printf("LINE: %d\n", __LINE__);
        //td[i].num = len/GEN_THREADS;
    //printf("LINE: %d\n", __LINE__);
        //td[i].data = data + i*td[i].num;
    //printf("LINE: %d\n", __LINE__);
        start = ((double)i/GEN_THREADS)*len;
        end = ((double)(i+1)/GEN_THREADS)*len;
        td[i].num = end - start;
        td[i].data = data + start;
    //printf("LINE: %d\n", __LINE__);

        rc = pthread_create(&thread[i], NULL, next_chunk, (void *)&td[i]);
        
    //printf("LINE: %d\n", __LINE__);
        if (rc) {
          perror("Error:unable to create thread");
          exit(-1);
        }
    }

    //printf("LINE: %d\n", __LINE__);
    for(int i = 0; i < GEN_THREADS; i++) {
        rc = pthread_join(thread[i], NULL);
        if (rc) {
          perror("thread join failed");
          exit(-1);
        }
    }
  }
#endif


#endif
