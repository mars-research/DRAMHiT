#ifndef _MISC_LIB_H
#define _MISC_LIB_H

#include <x86intrin.h>

#include "fastrange.h"
#include "types.hpp"

extern "C" {
#include "fcntl.h"
#include "stdio.h"
#include "sys/mman.h"
#include "sys/stat.h"
}

uint64_t get_file_size(const char *fn);
uint64_t round_down(uint64_t n, uint64_t m);
uint64_t round_up(uint64_t n, uint64_t m);
uint64_t calc_num_kmers(uint64_t l, uint8_t k);
int find_last_N(const char *c);
uint64_t __attribute__((optimize("O0"))) touchpages(char *fmap, size_t sz);

inline auto hash_to_cpu(std::uint32_t hash, unsigned int count) {
  return fastrange32(_mm_crc32_u32(0xffffffff, hash), count);
};

#endif  //_MISC_LIB_H
