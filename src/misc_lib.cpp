#include "misc_lib.h"

uint64_t get_file_size(const char *fn) {
  int fd = open(fn, O_RDONLY);
  struct stat sb;
  if (fstat(fd, &sb) == -1) {
    fprintf(stderr, "[ERROR] Couldn't stat file size\n");
    exit(-1);
  }
  return sb.st_size;
}

uint64_t round_down(uint64_t n, uint64_t m) {
  return n >= 0 ? (n / m) * m : ((n - m + 1) / m) * m;
}

uint64_t round_up(uint64_t n, uint64_t m) {
  return n >= 0 ? ((n + m - 1) / m) * m : (n / m) * m;
}

// TODO max value of k to support?s
uint64_t calc_num_kmers(uint64_t l, uint8_t k) { return (l - k + 1); }

int find_last_N(const char *c) {
  if (!c) return -1;
  int i = KMER_DATA_LENGTH;
  while (--i >= 0) {
    if (c[i] == 'N' || c[i] == 'n') {
      return i;
    }
  }
  return -1;
}

/*	Touching pages bring mmaped pages into memory. Possibly because we
have lot of memory, pages are never swapped out. mlock itself doesn't
seem to bring pages into memory (it should as per the man page)
TODO look into this.	*/
uint64_t __attribute__((optimize("O0"))) touchpages(char *fmap, size_t sz) {
  uint64_t sum = 0;
  for (uint64_t i = 0; i < sz; i += PAGE_SIZE) sum += fmap[i];
  return sum;
}

#include <numaif.h>

#include "numa.hpp"
#include "types.hpp"

namespace kmercounter {

extern Configuration config;



void distribute_mem_to_nodes(void *addr, uint64_t alloc_sz, numa_policy_threads policy) {

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
  }
  else if ((policy == THREADS_LOCAL_NUMA_NODE  || policy == THREADS_NO_MEM_DISTRIBUTION)){

    unsigned long nodemask = 1UL << 0;
    unsigned long maxnode = 1;//sizeof(nodemask) * 8;

    long ret = mbind(addr, alloc_sz, MPOL_BIND, &nodemask, maxnode,
                     MPOL_MF_MOVE | MPOL_MF_STRICT);
    if (ret < 0) {
      perror("mbind");
      PLOGE.printf("mbind ret %ld | errno %d", ret, errno);
    }
  }
  else if (policy == THREADS_SPLIT_EVEN_NODES)
  {
    uint64_t sz = alloc_sz >> 1;
    void* u_addr = addr + sz;

    unsigned long nodemask = 1UL << 0;
    unsigned long maxnode = sizeof(nodemask) * 8; 

    long ret = mbind(addr, sz, MPOL_BIND, &nodemask, maxnode,
                     MPOL_MF_MOVE | MPOL_MF_STRICT);
    if (ret < 0) {
      perror("mbind");
      PLOGE.printf("mbind ret %ld | errno %d | addr: %p | sz: %lu", ret, errno, addr, sz);
    }

    nodemask = 1UL << 1;
    maxnode = sizeof(nodemask) * 8; 

    ret = mbind(u_addr, sz, MPOL_BIND, &nodemask, maxnode,
                     MPOL_MF_MOVE | MPOL_MF_STRICT);
    if (ret < 0) {
      perror("mbind");
      PLOGE.printf("mbind ret %ld | errno %d", ret, errno);
    }
  }
  else {
      long ret = mbind(addr, alloc_sz, MPOL_INTERLEAVE, numa_all_nodes_ptr->maskp,
                   *numa_all_nodes_ptr->maskp, MPOL_MF_MOVE | MPOL_MF_STRICT);
      if (ret < 0) {
        perror("mbind");
        PLOGE.printf("mbind ret %ld | errno %d", ret, errno);
      }
  }

  PLOGI.printf("addr %p, alloc_sz %lu", addr, alloc_sz);
}

}  // namespace kmercounter
