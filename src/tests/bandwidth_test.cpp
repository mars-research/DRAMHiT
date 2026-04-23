
#include "helper.hpp"
#include "tests/BandwidthTest.hpp"
#include "utils/hugepage_allocator.hpp"
#include "plog/Log.h"

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

inline void prefetch(const Vec& vec, uint64_t idx) {
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

void BandwidthTest::run(Shard *sh, const Configuration &config, std::barrier<VoidFn> *barrier)
{
  uint64_t size = utils::next_pow2(config.ht_size);

  if (sh->shard_idx == 0) {
      PLOGI.printf("allocating %lu mb", (size*64ULL/(1024ULL*1024ULL)));
  }

  Vec arr(size,hugepage_allocator_inst_bw);
  for (uint64_t i = 0; i < size; i++) {
      arr[i].pad[0] = 'c';
  }

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = true;
  }
  barrier->arrive_and_wait();

  if (config.sequential) {
    for (uint64_t i = 0; i < size; i++) {
      prefetch(arr, i);
    }
  } else {
    uint64_t idx = 0;
    for (uint64_t i = 0; i < size; i++) {
        idx = knuth64(i)&(size-1);
        prefetch(arr, idx);
    }
  }

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();

  sh->stats->finds.op_count = size;
  sh->stats->finds.duration = g_find_end - g_find_start;

} // run

}  // namespace bw
