
#include "misc_lib.h"
#include "numa.hpp"
#include "plog/Log.h"
#include "tests/BandwidthTest.hpp"
#include "types.hpp"
#include "utils/hugepage_allocator.hpp"

namespace kmercounter {

extern ExecPhase cur_phase;
extern bool g_app_record_start;
extern uint64_t g_find_start, g_find_end;

using Cacheline = struct {
  char pad[64];
};
using BWHugepageAlloc = huge_page_allocator<Cacheline>;
using Vec = std::vector<Cacheline, BWHugepageAlloc>;
BWHugepageAlloc hugepage_allocator_inst_bw;

inline uint64_t knuth64(uint64_t x) { return x * 11400714819323198485ULL; }

inline void prefetch(const Vec &vec, uint64_t idx) {
#if L1_PREFETCH
  __builtin_prefetch(&vec[idx], false, 3);
#elif L2_PREFETCH
  __builtin_prefetch(&vec[idx], false, 2);
#elif L3_PREFETCH
  __builtin_prefetch(&vec[idx], false, 1);
#elif NTA_PREFETCH
  __builtin_prefetch(&vec[idx], false, 0);
#else
  __builtin_prefetch(&vec[idx], false, 2);
#endif
}

/**
 * Forces the migration of a hugepage-backed vector to a remote NUMA node.
 * * @param arr The vector to migrate.
 * @param current_node The NUMA node the thread is currently executing on.
 * @return true if migration succeeded, false otherwise.
 */
void BandwidthTest::run(Shard *sh, const Configuration &config,
                        std::barrier<VoidFn> *barrier) {
  uint64_t size = utils::next_pow2(config.ht_size);

  if (sh->shard_idx == 0) {
    PLOGI.printf("allocating %lu mb per thread",
                 (size * 64ULL / (1024ULL * 1024ULL)));
  }

  // Initialize
  Vec arr(size, hugepage_allocator_inst_bw);
  for (uint64_t i = 0; i < size; i++) {
    arr[i].pad[0] = 'c';
  }

  if (config.numa_split == THREADS_REMOTE_NUMA_NODE ||
      config.numa_split == THREADS_ALL_NODES_REMOTE_ACCESS) {
    int to_node;
    if ((to_node = find_remote_node(sh->numa_node)) < 0) {
      PLOGE.printf("failed to find remote node");
      abort();
    }

    uint64_t SIZE_2MB = 2ULL * 1024 * 1024;
    uint64_t SIZE_1GB = 1ULL * 1024 * 1024 * 1024;
    uint64_t bytes = size * sizeof(Cacheline);
    if (bytes > SIZE_1GB) {
      bytes = (((bytes - 1) / SIZE_1GB) + 1) * SIZE_1GB;
    } else {
      bytes = (((bytes - 1) / SIZE_2MB) + 1) * SIZE_2MB;
    }

    if (!move_memory_to_node((void *)(&arr[0]), bytes, to_node)) {
      PLOGE.printf("failed to migrate workload into remote memory");
      abort();
    }
  }

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = true;
    PLOGI.printf("Bandwidth test start");
  }
  barrier->arrive_and_wait();

  if (config.sequential) {
    for (uint64_t i = 0; i < size; i++) {
      prefetch(arr, i);
    }
  } else {
    uint64_t idx = 0;
    for (uint64_t i = 0; i < size; i++) {
      idx = knuth64(i) & (size - 1);
      prefetch(arr, idx);
    }
  }

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = false;
    PLOGI.printf("Bandwidth test end");
  }
  barrier->arrive_and_wait();

  sh->stats->finds.op_count = size;
  sh->stats->finds.duration = g_find_end - g_find_start;

}  // run

}  // namespace kmercounter
