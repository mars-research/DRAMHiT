#ifndef _HT_HELPER_H
#define _HT_HELPER_H

#include <fcntl.h>
#include <numaif.h>
#include <plog/Log.h>
#include <sys/mman.h>
#include <unistd.h>

#include <cstring>

#include "hashtables/kvtypes.hpp"
#include "numa.hpp"

namespace kmercounter {
/* AB: 1GB page table code is from
 * https://github.com/torvalds/linux/blob/master/tools/testing/selftests/vm/hugepage-mmap.c
 */

#define FILE_NAME "/mnt/huge/hugepagefile"

#define MAP_HUGE_2MB (21 << MAP_HUGE_SHIFT)
#define MAP_HUGE_1GB (30 << MAP_HUGE_SHIFT)

extern Configuration config;
constexpr auto ADDR = static_cast<void *>(0x0ULL);
constexpr auto PROT_RW = PROT_READ | PROT_WRITE;
constexpr auto MAP_FLAGS_1GB = MAP_HUGETLB | MAP_HUGE_1GB | MAP_PRIVATE | MAP_ANONYMOUS;
constexpr auto MAP_FLAGS_2MB = MAP_HUGETLB | MAP_HUGE_2MB | MAP_PRIVATE | MAP_ANONYMOUS;
constexpr auto ONEGB_PAGE_SZ = 1ULL * 1024 * 1024 * 1024;
constexpr auto TWOMB_PAGE_SZ = 2ULL * 1024 * 1024;

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

inline void distribute_mem_to_nodes(void *addr, uint64_t alloc_sz,
                                    numa_policy_threads policy) {
  // Check if there is only one NUMA node
  if (numa_num_configured_nodes() == 1) {
    PLOG_INFO.printf(
        "Only one NUMA node available, skipping memory distribution.");
    return;
  }

  if (policy == THREADS_REMOTE_NUMA_NODE) {
    unsigned long nodemask = 1UL << 1;
    unsigned long maxnode = sizeof(nodemask) * 8;

    long ret = mbind(addr, alloc_sz, MPOL_BIND, &nodemask, maxnode,
                     MPOL_MF_MOVE | MPOL_MF_STRICT);
    if (ret < 0) {
      perror("mbind");
      PLOGE.printf("mbind ret %ld | errno %d", ret, errno);
    }
  } else if ((policy == THREADS_LOCAL_NUMA_NODE ||
              policy == THREADS_NO_MEM_DISTRIBUTION)) {
    unsigned long nodemask = 1UL << 0;
    unsigned long maxnode = sizeof(nodemask) * 8;

    long ret = mbind(addr, alloc_sz, MPOL_BIND, &nodemask, maxnode,
                     MPOL_MF_MOVE | MPOL_MF_STRICT);
    if (ret < 0) {
      perror("mbind");
      PLOGE.printf("mbind ret %ld | errno %d", ret, errno);
    }
  } else if (policy == THREADS_SPLIT_EVEN_NODES) {
    int num_nodes = numa_num_configured_nodes();  // Should return 4 on your AMD
    uint64_t chunk_sz = alloc_sz / num_nodes;

    for (int i = 0; i < num_nodes; i++) {
      void *chunk_ptr = (uint8_t *)addr + (i * chunk_sz);

      // If it's the last node, take the remainder to avoid rounding errors
      uint64_t current_sz =
          (i == num_nodes - 1) ? (alloc_sz - (i * chunk_sz)) : chunk_sz;

      unsigned long nodemask = (1UL << i);
      // maxnode must be at least the highest node ID + 1
      unsigned long maxnode = i + 2;

      long ret = mbind(chunk_ptr, current_sz, MPOL_BIND, &nodemask, maxnode,
                       MPOL_MF_MOVE | MPOL_MF_STRICT);

      if (ret < 0) {
        PLOGE.printf("mbind failed for node %d: %s (addr: %p, sz: %lu)", i,
                     strerror(errno), chunk_ptr, current_sz);
        assert(0);
      } else {
        PLOGV.printf("Successfully bound %lu bytes to node %d", current_sz, i);
      }
    }
  } else {
    long ret = mbind(addr, alloc_sz, MPOL_INTERLEAVE, numa_all_nodes_ptr->maskp,
                     *numa_all_nodes_ptr->maskp, MPOL_MF_MOVE | MPOL_MF_STRICT);
    if (ret < 0) {
      perror("mbind");
      PLOGE.printf("mbind ret %ld | errno %d", ret, errno);
    }
  }

  PLOGI.printf("addr %p, alloc_sz %lu", addr, alloc_sz);
}
template <bool WRITE>
inline void prefetch_object(const void *addr, uint64_t size) {
  // uint64_t _addr = cache_block_aligned_addr((uint64_t)addr);

#if defined(PREFETCH_TWO_LINE)
  // uint64_t cache_line2_addr =
  //     cache_block_aligned_addr((uint64_t)addr + size - 1);
#endif

  // 1 -- prefetch for write (vs 0 -- read)
  // 0 -- data has no temporal locality (3 -- high temporal locality)
  //__builtin_prefetch((const void*)cache_line1_addr, 1, 1);

  // __builtin_prefetch((const void *)cache_line1_addr, WRITE, 3);
  __builtin_prefetch((const void *)addr, WRITE, 3);

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

inline size_t round_hugepage(size_t n) {
  if (n < ONEGB_PAGE_SZ) return (((n - 1) / TWOMB_PAGE_SZ) + 1) * TWOMB_PAGE_SZ;
  return (((n - 1) / ONEGB_PAGE_SZ) + 1) * ONEGB_PAGE_SZ;
}

template <class T>
T *calloc_ht(uint64_t capacity, uint16_t id, int *out_fd) {
  T *addr;
  uint64_t alloc_sz = capacity * sizeof(T);
  auto current_node = numa_node_of_cpu(sched_getcpu());

  int fd = open(FILE_NAME, O_CREAT | O_RDWR, 0755);

  if (fd < 0) {
    PLOGE.printf("Couldn't open file %s:", FILE_NAME);
    perror("");
    exit(1);
  } else {
    // PLOGI.printf("opened file %s", FILE_NAME);
  }

  if (alloc_sz % 2) {
    PLOGE.printf("alloc sz is not divisible by 2, alloc_sz %lu", alloc_sz);
    exit(-1);
  }

  int flags;
  alloc_sz = round_hugepage(alloc_sz);

  if (alloc_sz < ONEGB_PAGE_SZ) {
    flags = MAP_FLAGS_2MB;
    PLOGI.printf("allocating %lu 2mb pages bytes %lu", alloc_sz / TWOMB_PAGE_SZ,
                 alloc_sz);
  } else {
    flags = MAP_FLAGS_1GB;
    PLOGI.printf("allocating %lu 1gb pages bytes %lu", alloc_sz / ONEGB_PAGE_SZ,
                 alloc_sz);
  }

  addr = (T *)mmap(ADDR, alloc_sz, PROT_RW, flags, fd, 0);

  close(fd);
  unlink(FILE_NAME);
  if (addr == MAP_FAILED) {
    unlink(FILE_NAME);
    PLOGE.printf("mmap failed");
    exit(1);
  } else {
    PLOGI.printf("mmap returns %p", addr);
  }
  *out_fd = fd;

  if (alloc_sz >= ONEGB_PAGE_SZ) {
    distribute_mem_to_nodes(addr, alloc_sz,
                            (numa_policy_threads)config.numa_split);
  }

  memset(addr, 0, capacity * sizeof(T));
  return addr;
}

template <class T>
void free_mem(T *addr, uint64_t capacity, int id, int fd) {
  size_t alloc_sz = capacity * sizeof(T);
  alloc_sz = round_hugepage(alloc_sz);

  if (addr) {
    munmap(addr, capacity * sizeof(T));
    PLOGI.printf("%p with sz %lu unmapped", addr, capacity * sizeof(T));
  }
}

}  // namespace kmercounter

#endif  // _HT_HELPER_H
