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

#if 1

#include "numa.hpp"
#include "types.hpp"
#include <numaif.h>

namespace kmercounter {
extern Configuration config;

void distribute_mem_to_nodes(void *addr, size_t alloc_sz) {
    void *_addr = addr;
    Numa *n = new Numa();
    auto num_nodes = n->get_num_nodes();
    size_t split_den = std::min(config.num_threads, static_cast<uint32_t>(num_nodes));
    size_t len_split = ((alloc_sz / split_den) + (PAGE_SIZE - 1)) & ~(PAGE_SIZE - 1);

    struct bitmask *b = numa_allocate_nodemask();

    PLOGV.printf("nodemask %lx | all_nodes %lx", *b->maskp, *numa_all_nodes_ptr->maskp);
    for (int i = 0; i < split_den; i++) {
      void *addr_split = (char *)_addr + len_split * i;
      unsigned long nodemask[4096] = {0};

      nodemask[0] = 1 << i;

      PLOGV.printf("Moving half the memory to node %lu", nodemask[0]);

      long ret = mbind(addr_split, len_split, MPOL_BIND, nodemask, 4096,
          MPOL_MF_MOVE | MPOL_MF_STRICT);

      //PLOGV.printf("mmap_addr %p | len %zu", _addr, capacity * sizeof(T));
      PLOGV.printf("calling mbind with addr %p | len %zu | nodemask %p", addr_split,
          len_split, nodemask);
      if (ret < 0) {
        perror("mbind");
        PLOGE.printf("mbind ret %ld | errno %d", ret, errno);
      }
    }
}
} // namespace
#endif
