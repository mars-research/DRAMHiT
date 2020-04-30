#ifndef _MISC_LIB_H
#define _MISC_LIB_H

extern "C"
{
#include "fcntl.h"
#include "sys/mman.h"
#include "sys/stat.h"
#include "sys/types.h"
#include "stdio.h"
}


uint64_t get_file_size(const char *fn)
{
  int fd = open(fn, O_RDONLY);
  struct stat sb;
  if (fstat(fd, &sb) == -1)
  {
    fprintf(stderr, "[ERROR]couldn't get file size\n");
  }
  return sb.st_size;
}

uint64_t round_down(uint64_t n, uint64_t m)
{
  return n >= 0 ? (n / m) * m : ((n - m + 1) / m) * m;
}

uint64_t round_up(uint64_t n, uint64_t m)
{
  return n >= 0 ? ((n + m - 1) / m) * m : (n / m) * m;
}

// TODO max value of k to support?s
uint64_t calc_num_kmers(uint64_t l, uint8_t k)
{
    return (l - k + 1);
}


#endif //_MISC_LIB_H