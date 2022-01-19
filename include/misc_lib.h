#ifndef _MISC_LIB_H
#define _MISC_LIB_H

#include <x86intrin.h>

#include "types.hpp"

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

class xorwow_urbg {
 public:
  auto operator()() noexcept
  {
    return xorwow(&state);
  }

 private:
  xorwow_state state{[] {
    xorwow_state state;
    xorwow_init(&state);
    return state;
  }()};
};

#endif  //_MISC_LIB_H
