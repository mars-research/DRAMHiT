// #pragma once
#ifndef MEM_CC_
#define MEM_CC_

/*#include <sys/mman.h>
#include <unistd.h>

#include <cassert>
#include <cmath>
#include <cstdio>*/

#include "distribution/pregen/mem.h"

#define MAP_HUGE_2MB (21 << MAP_HUGE_SHIFT)
#define MAP_HUGE_1GB (30 << MAP_HUGE_SHIFT)

//#define MEM
#define MMAP
//#define HUGEPAGES_1GB
#define HUGEPAGES_2MB
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

uint64_t* allocate(uint64_t num, uint64_t range, double theta, uint64_t seed){

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
  //printf("size: %lu\n", num_pages * pagesize );
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

#endif
