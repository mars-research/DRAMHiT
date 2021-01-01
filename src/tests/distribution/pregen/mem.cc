// #pragma once
#ifndef MEM_CC_
#define MEM_CC_

/*#include <sys/mman.h>
#include <unistd.h>

#include <cassert>
#include <cmath>
#include <cstdio>*/

#include "distribution/pregen/mem.h"

/*#ifdef MULTITHREAD_GENERATION
  #warning mem.cc MULTITHREAD_GENERATION ON  
#else
  #warning mem.cc MULTITHREAD_GENERATION OFF  
#endif
#ifdef MULTITHREAD_SUMMATION
  #warning mem.cc MULTITHREAD_SUMMATION ON   
#else
  #warning mem.cc MULTITHREAD_SUMMATION OFF
#endif*/

#define MAP_HUGE_2MB (21 << MAP_HUGE_SHIFT)
#define MAP_HUGE_1GB (30 << MAP_HUGE_SHIFT)

//#define MEM
#define MMAP
#define HUGEPAGES_1GB
//#define HUGEPAGES_2MB
#define FILE_MMAP

#ifdef HUGEPAGES_1GB
	#define PG_SIZE (getpagesize()*512*512)
	#define HUGEPAGES MAP_HUGE_1GB
#else
	#ifdef HUGEPAGES_2MB
		#define PG_SIZE (getpagesize()*512)
		#define HUGEPAGES MAP_HUGE_2MB
	#else
		#define PG_SIZE (getpagesize())
	#endif
#endif

uint64_t* generate(uint64_t num, uint64_t range, double theta, uint64_t seed) {

uint64_t data_size = num;
#if defined(MEM)
  uint64_t* data = new uint64_t[num];
#elif defined(MMAP) || defined(FILE_MMAP)
#ifdef FILE_MMAP
  #ifdef HUGEPAGES
    int fd = open("/mnt/huge/kmer_zipf_distr", O_RDWR|O_CREAT, S_IRWXU);
  #else
    int fd = open("test", O_RDWR|O_CREAT, S_IRWXU);
  #endif
  if (fd == -1)
  {
    perror("Opening file Failed.");
    return NULL;
  }
  ++data_size;
#endif
  size_t pagesize = PG_SIZE;

  uint64_t num_pages = (((++data_size) * sizeof(uint64_t)) / pagesize) + 1;
  #ifdef FILE_MMAP
    if(ftruncate(fd, num_pages*pagesize))
    {
      perror("Couldn't resize file.");
      return NULL;
    }
  #endif
  printf("size: %lu\n", num_pages * pagesize );
  uint64_t* data = (uint64_t*)mmap(
      NULL, //(void*)(pagesize * (1 << 20)),  // Map from the start of the 2^20th page
      num_pages * pagesize,
      PROT_READ | PROT_WRITE,         //|PROT_EXEC,
      MAP_PRIVATE//MAP_SHARED
			#ifndef FILE_MMAP
				MAP_ANON|
			#endif
      #ifdef HUGEPAGES
        |MAP_HUGETLB|HUGEPAGES
      #endif
      ,  // to a private block of hardware memory
      0
      #ifdef FILE_MMAP
        |fd
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
  

  void next(uint64_t* data, uint64_t len, uint64_t seed)
  {
    cpu_set_t cpuset;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_t thread[GEN_THREADS];
    generate_data td[GEN_THREADS];
    int rc;
    uint64_t start, end;


    //printf("LINE: %d\n", __LINE__);
    for(int i = 0, cpu = 0; i < GEN_THREADS; ++i, cpu = (cpu+1)%std::thread::hardware_concurrency()) {
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
        #ifdef GENERATION_CHUNKING
          td[i].data = data + start;
        #else
          td[i].data = data + i;
        #endif
    //printf("LINE: %d\n", __LINE__);
        
        CPU_ZERO(&cpuset);
        if(cpu == 1)
        {
          ++cpu;
        }
        CPU_SET(cpu, &cpuset);
        rc = pthread_attr_setaffinity_np(&attr, sizeof(cpu_set_t), &cpuset);//thread[i], sizeof(cpu_set_t), &cpuset);
        if (rc) {
          perror("Error:unable to set thread affinity");
          exit(-1);
        }

        rc = pthread_create(&thread[i], &attr, next_chunk, (void *)&td[i]);
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
  void* next_chunk(void* data)
  {
    //unsigned cpu;
    //uint64_t t_start, t_end;
    generate_data* td = (generate_data*) data;

    //printf("LINE: %d\n", __LINE__);
    //printf("LINE: %d\n", __LINE__);
    //td->sum = zeta(td->last_n, 0, td->n, td->theta);
    /*printf("Thread %d: seed=%lu\n", td->thread_id, rand_[td->thread_id].state_);
    printf("Thread %d: ", td->thread_id);
      print_seed();
    printf("Thread %d: i goes from %lu - %lu\n", td->thread_id, 0, td->num-1);*/
    //printf("Thread %d: i goes from %lu - %lu\n", td->thread_id, 0, td->num-1);
    //int count = 0;
    //t_start = RDTSC_START();
    for (uint64_t i = 0; i < td->num; ++i) {
      #ifdef GENERATION_CHUNKING
        td->data[i] = next(td->thread_id);
      #else
        td->data[i] = next(td->thread_id);
        //td->data[GEN_THREADS*i] = next(td->thread_id);
      #endif
      //printf("%lu\n", td->data[i]);
      //++count;
    }
    /*t_end = RDTSCP();
    getcpu(&cpu, NULL);
    printf("Thread %d: Gen data in %lu cycles (%f ms) on CPU #%d\n", td->thread_id, t_end-t_start, (double)(t_end-t_start) * one_cycle_ns / 1000000.0, cpu);*/
    /*printf("td->num: %lu\n", td->num);*/
    //printf("generate count: %d\n", count);
    //printf("LINE: %d\n", __LINE__);
    return NULL;//pthread_exit(NULL);
  }
  
  
#endif


#endif
