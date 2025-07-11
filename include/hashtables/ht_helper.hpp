#ifndef _HT_HELPER_H
#define _HT_HELPER_H

#include "base_kht.hpp"
#include "hashtables/kvtypes.hpp"

#include <fcntl.h>
#include <numa.h>
#include <unistd.h>
#include <sys/mman.h>
#include <plog/Log.h>

#include <cstring>

namespace kmercounter {
/* AB: 1GB page table code is from
 * https://github.com/torvalds/linux/blob/master/tools/testing/selftests/vm/hugepage-mmap.c
 */

#define FILE_NAME "/mnt/huge/hugepagefile%d"

#define MAP_HUGE_2MB    (21 << MAP_HUGE_SHIFT)
#define MAP_HUGE_1GB    (30 << MAP_HUGE_SHIFT)

extern Configuration config;
constexpr auto ADDR = static_cast<void *>(0x0ULL);
constexpr auto PROT_RW = PROT_READ | PROT_WRITE;
constexpr auto MAP_FLAGS =
    MAP_HUGETLB | MAP_HUGE_1GB | MAP_PRIVATE | MAP_ANONYMOUS;
constexpr auto ONEGB_PAGE_SZ = 1ULL * 1024 * 1024 * 1024;

constexpr uint64_t CACHE_BLOCK_BITS = 6;
constexpr uint64_t CACHE_BLOCK_MASK = (1ULL << CACHE_BLOCK_BITS) - 1;

// Which byte offset in its cache block does this address reference?
constexpr uint64_t cache_block_offset(uint64_t addr) {
  return addr & CACHE_BLOCK_MASK;
}
// Address of 64 byte block brought into the cache when ADDR accessed
constexpr uint64_t cache_block_aligned_addr(uint64_t addr) {
  return addr & ~CACHE_BLOCK_MASK;
}

void distribute_mem_to_nodes(void *addr, size_t alloc_sz, numa_policy_threads policy);


template <bool WRITE>
inline void prefetch_object(const void *addr, uint64_t size) {
  //uint64_t _addr = cache_block_aligned_addr((uint64_t)addr);

#if defined(PREFETCH_TWO_LINE)
  //uint64_t cache_line2_addr =
  //    cache_block_aligned_addr((uint64_t)addr + size - 1);
#endif

  // 1 -- prefetch for write (vs 0 -- read)
  // 0 -- data has no temporal locality (3 -- high temporal locality)
  //__builtin_prefetch((const void*)cache_line1_addr, 1, 1);

  // __builtin_prefetch((const void *)cache_line1_addr, WRITE, 3);
  __builtin_prefetch((const void *)addr, WRITE, 1);

  //__builtin_prefetch(addr, 1, 0);
#if defined(PREFETCH_TWO_LINE)
  if (cache_line1_addr != cache_line2_addr)
    __builtin_prefetch((const void *)cache_line2_addr, 1, 0);
#endif
}

static inline void prefetch_with_write(Kmer_KV *k) {
  /* if I write occupied I get
   * Prefetch stride: 0, cycles per insertion:122
   * Prefetch stride: 1, cycles per insertion:36
   * Prefetch stride: 2, cycles per insertion:46
   * Prefetch stride: 3, cycles per insertion:44
   * Prefetch stride: 4, cycles per insertion:45
   * Prefetch stride: 5, cycles per insertion:46
   * Prefetch stride: 6, cycles per insertion:46
   * Prefetch stride: 7, cycles per insertion:47
   */
  //  k->occupied = 1;
  /* If I write padding I get
   * Prefetch stride: 0, cycles per insertion:123
   * Prefetch stride: 1, cycles per insertion:104
   * Prefetch stride: 2, cycles per insertion:84
   * Prefetch stride: 3, cycles per insertion:73
   * Prefetch stride: 4, cycles per insertion:66
   * Prefetch stride: 5, cycles per insertion:61
   * Prefetch stride: 6, cycles per insertion:57
   * Prefetch stride: 7, cycles per insertion:55
   * Prefetch stride: 8, cycles per insertion:54
   * Prefetch stride: 9, cycles per insertion:53
   * Prefetch stride: 10, cycles per insertion:53
   * Prefetch stride: 11, cycles per insertion:53
   * Prefetch stride: 12, cycles per insertion:52
   */
  k->padding[0] = 1;
}

template <class T>
T *calloc_ht(uint64_t capacity, uint16_t id, int *out_fd) {
  T *addr;
  uint64_t alloc_sz = capacity * sizeof(T);
  auto current_node = numa_node_of_cpu(sched_getcpu());

  

  if (alloc_sz < ONEGB_PAGE_SZ) {
    PLOGI.printf("Allocating memory on node %d", current_node);
    addr = (T *)(aligned_alloc(PAGE_SIZE, capacity * sizeof(T)));
    if (!addr) {
      perror("aligned_alloc:");
      exit(1);
    }
    if (alloc_sz < (2 * PAGE_SIZE)) {
      goto skip_mbind;
    }
  } else {
    int fd;
    char mmap_path[256] = {0};
    snprintf(mmap_path, sizeof(mmap_path), FILE_NAME, id);

    fd = open(mmap_path, O_CREAT | O_RDWR, 0755);

    if (fd < 0) {
      PLOGE.printf("Couldn't open file %s:", mmap_path);
      perror("");
      exit(1);
    } else {
      PLOGV.printf("opened file %s", mmap_path);
    }

    PLOGI.printf("requesting to mmap %lu bytes", alloc_sz);
    addr = (T *)mmap(ADDR, /* 256*1024*1024*/ alloc_sz, PROT_RW,
        MAP_FLAGS, fd, 0);
    if (addr == MAP_FAILED) {
      perror("mmap");
      unlink(mmap_path);
      exit(1);
    } else {
      PLOGI.printf("mmap returns %p", addr);
    }
    *out_fd = fd;
  }
  if (config.ht_type == CASHTPP && (config.numa_split != 2)) {
      distribute_mem_to_nodes(addr, alloc_sz, (kmercounter::numa_policy_threads)config.numa_split);
  }
skip_mbind:
  memset(addr, 0, capacity * sizeof(T));
  return addr;
}

template <class T>
void free_mem(T *addr, uint64_t capacity, int id, int fd) {
  auto alloc_sz = capacity * sizeof(T);

  if (alloc_sz < ONEGB_PAGE_SZ) {
    free(addr);
  } else {
    char mmap_path[256] = {0};
    PLOGI.printf("Entering!");
    snprintf(mmap_path, sizeof(mmap_path), FILE_NAME, id);
    if (addr) {
      munmap(addr, capacity * sizeof(T));
    }
    if (fd > 0) {
      close(fd);
    }
    unlink(FILE_NAME);
  }
}

}  // namespace kmercounter

#endif  // _HT_HELPER_H
