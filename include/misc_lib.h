#ifndef _MISC_LIB_H
#define _MISC_LIB_H

#include "types.hpp"
#include <x86intrin.h>
#include "numa.hpp"

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

int find_remote_node(int current_node);
bool move_memory_to_node(void* addr, uint64_t size, int to_node);

#include "all_ht_types.hpp"
namespace kmercounter{
BaseHashTable* init_ht(const uint64_t sz, uint8_t id);
}
#endif  //_MISC_LIB_H
