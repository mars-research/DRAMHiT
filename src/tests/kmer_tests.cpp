#include "tests/KmerTest.hpp"

#include <algorithm>
#include <cstdint>
#include <plog/Log.h>

#include "constants.hpp"
#include "hashtables/base_kht.hpp"
#include "hashtables/kvtypes.hpp"
#include "sync.h"
#include "input_reader/fastq.hpp"
#include "types.hpp"

namespace kmercounter {
OpTimings KmerTest::shard_thread(Shard *sh, const Configuration &cfg, BaseHashTable *kmer_ht, bool insert) {
  auto k = 0;
  uint64_t inserted = 0lu;
  constexpr uint64_t K = 4;
  uint64_t kmer;
  std::string tmp;
  input_reader::FastqKMerPreloadReader<K> reader("../SRR077487.2.fastq", sh->shard_idx, cfg.num_threads);
  __attribute__((aligned(64))) Keys _items[HT_TESTS_FIND_BATCH_LENGTH] = {0};

  const auto t_start = RDTSC_START();
  if (insert) {
    for (; reader.next(&kmer);) {
      inserted++;
      _items[k].key = kmer;

      if (++k == HT_TESTS_BATCH_LENGTH) {
        KeyPairs kp = std::make_pair(HT_TESTS_BATCH_LENGTH, &_items[0]);
        kmer_ht->insert_batch(kp);

        k = 0;
      }
    }
    kmer_ht->flush_insert_queue();
  } else {
    for (; reader.next(&kmer);) {
      inserted++;
    }
  }

  // input_reader::FastqReader freader("../ERR024163_1.fastq", sh->shard_idx, cfg.num_threads);
  // for (; freader.next(&tmp);){inserted++;}

  const auto t_end = RDTSCP();
  const auto duration = t_end - t_start;
  PLOG_INFO << "inserted "<< inserted << " items in " << duration << " cycles. " << duration / std::max(1ul, inserted) << " cpo";
  sh->stats->num_inserts = inserted;
  return {duration, inserted};
}

} // namespace kmercounter