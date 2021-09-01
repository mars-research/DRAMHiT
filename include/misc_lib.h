#ifndef _MISC_LIB_H
#define _MISC_LIB_H

#include "types.hpp"
#include "xxhash.h"

#include <x86intrin.h>

extern "C" {
#include "fcntl.h"
#include "stdio.h"
#include "sys/mman.h"
#include "sys/stat.h"
}

struct xorwow_state {
  uint32_t a, b, c, d;
  uint32_t counter;
};

uint64_t get_file_size(const char *fn);
uint64_t round_down(uint64_t n, uint64_t m);
uint64_t round_up(uint64_t n, uint64_t m);
uint64_t calc_num_kmers(uint64_t l, uint8_t k);
int find_last_N(const char *c);
uint64_t __attribute__((optimize("O0"))) touchpages(char *fmap, size_t sz);

void xorwow_init(xorwow_state *);
uint32_t xorwow(xorwow_state *);

inline uint64_t hash_function(const void *k, std::uint64_t size) {
  uint64_t hash_val;
#if defined(CITY_HASH)
  hash_val = CityHash64((const char *)k, size);
#elif defined(FNV_HASH)
  hash_val = hval = fnv_32a_buf(k, size, hval);
#elif defined(XX_HASH)
  hash_val = XXH64(k, size, 0);
#elif defined(XX_HASH_3)
  hash_val = XXH3_64bits(k, size);
#elif defined(CRC32)
  hash_val = _mm_crc32_u64(0xffffffff, *static_cast<const std::uint64_t *>(k));
#endif
  return hash_val;
}

#endif  //_MISC_LIB_H
