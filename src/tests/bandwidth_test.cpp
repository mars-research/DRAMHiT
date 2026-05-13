
#include "misc_lib.h"
#include "numa.hpp"
#include "plog/Log.h"
#include "sync.h"
#include "tests/BandwidthTest.hpp"
#include "types.hpp"
#include "utils/hugepage_allocator.hpp"
#include "helper.hpp"

namespace kmercounter {

extern ExecPhase cur_phase;
extern bool g_app_record_start;
extern uint64_t g_find_start, g_find_end;
extern uint64_t g_insert_start, g_insert_end;

using Cacheline = struct {
  char pad[64];
};
using BWHugepageAlloc = huge_page_allocator<Cacheline>;

inline uint64_t knuth64(uint64_t x) { return x * 11400714819323198485ULL; }

inline void prefetch(const Cacheline* vec, uint64_t idx) {
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
void BandwidthTest::run(Shard* sh, const Configuration& config,
                        std::barrier<VoidFn>* barrier) {
  uint64_t size = utils::next_pow2(config.ht_size);
  uint64_t start, end;
  if (sh->shard_idx == 0) {
      PLOGI.printf("allocating %lu mb per thread",
                   (size * sizeof(Cacheline)) / (1024ULL * 1024ULL));
    start = RDTSC_START();
  }

  BWHugepageAlloc hugepage_allocator_inst_bw;
  Cacheline* arr = hugepage_allocator_inst_bw.allocate(size);

  if (config.numa_split == THREADS_REMOTE_NUMA_NODE ||
      config.numa_split == THREADS_ALL_NODES_REMOTE_ACCESS) {
    int to_node = sh->numa_node;
    if ((to_node = find_remote_node(sh->numa_node)) < 0) {
      PLOGE.printf("failed to find remote node");
      abort();
    }

    if (!move_memory_to_node((void*)(&arr[0]),
                             hugepage_allocator_inst_bw.get_actual_bytes(size),
                             to_node)) {
      PLOGE.printf("failed to migrate workload memory");
      abort();
    }
  }else if(config.numa_split == THREADS_SPLIT_EVEN_NODES)
  {
      if(!distribute_memory_to_nodes((void*)arr, hugepage_allocator_inst_bw.get_actual_bytes(size))){
          PLOGE.printf("failed to distribute workload memory");
          abort();
      }
  }

  hugepage_allocator_inst_bw.prefault(arr, size);

  if (sh->shard_idx == 0) {
    end = RDTSCP();
    PLOGI.printf("took %lu cycles per cacheline on mmap and mbind",
                 (end - start) / size);
  }

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::insertions;
    g_app_record_start = true;
  }
  barrier->arrive_and_wait();

  __m512i zero_vec_512 = _mm512_setzero_si512();

  for (uint64_t i = 0; i < size; i++) {
    _mm512_stream_si512((__m512i*)&arr[i], zero_vec_512);
  }

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::insertions;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();
  if (sh->shard_idx == 0) {
    PLOGI.printf("took %lu cycles per cacheline on write",
                 (g_insert_end - g_insert_start) / size);
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
  if (sh->shard_idx == 0) {
    PLOGI.printf("took %lu cycles per cacheline on read",
                 (g_find_end - g_find_start) / size);
  }

  hugepage_allocator_inst_bw.deallocate(arr, size);

}  // run

}  // namespace kmercounter
