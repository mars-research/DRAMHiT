#include "tests/SynthTest.hpp"

#include <algorithm>
#include <cstdint>
#include <plog/Log.h>
#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif
#include "constants.hpp"
#include "hashtables/base_kht.hpp"
#include "hashtables/kvtypes.hpp"
#include "print_stats.h"
#include "sync.h"
#include "xorwow.hpp"
#include "batch_inserter.hpp"
#include "utils/profiler.hpp"
#ifdef ENABLE_HIGH_LEVEL_PAPI
#include <papi.h>
#endif

#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

namespace kmercounter {

extern Configuration config;
extern uint64_t HT_TESTS_HT_SIZE;
extern uint64_t HT_TESTS_NUM_INSERTS;

OpTimings SynthTest::synth_run(BaseHashTable *ktable, uint8_t start) {
  auto inserted = 0lu;

  HTBatchInserter<HT_TESTS_BATCH_LENGTH> inserter(ktable);


  Profiler profiler(std::string(ht_type_strings[config.ht_type]) + "_insertions");
  for (auto j = 0u; j < config.insert_factor; j++) {
    uint64_t count = std::max(static_cast<uint64_t>(1), HT_TESTS_NUM_INSERTS * start);


    for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
      
    }
    PLOG_INFO.printf("inserted %lu items", inserted);
    // flush the last batch explicitly
    // printf("%s calling flush queue\n", __func__);
#if !defined(NO_PREFETCH)
    ktable->flush_insert_queue();
#endif

  }
  const auto duration = profiler.end();



  return {duration, HT_TESTS_NUM_INSERTS * config.insert_factor};
}


} // namespace kmercounter
