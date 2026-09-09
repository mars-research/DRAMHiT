#include "tests/KmerTest.hpp"

#include <algorithm>
#include <atomic>
#include <barrier>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <plog/Log.h>

#include "constants.hpp"
#include "hashtables/base_kht.hpp"
#include "hashtables/kvtypes.hpp"
#include "sync.h"
#include "input_reader/fastq.hpp"
#include "input_reader/counter.hpp"
#include "types.hpp"
#include "numa.hpp"
#include "print_stats.h"
#include "utils/hugepage_arena.hpp"

namespace kmercounter {
extern ExecPhase cur_phase;
extern bool g_app_record_start;
extern uint64_t g_insert_end;
extern uint64_t g_insert_start;

constexpr uint64_t SIZE_1GB = 1ULL << 30;
constexpr uint64_t SIZE_2MB = 2ULL << 20;

/// Bytes to reserve for one shard's kmer array.
///
/// A FASTQ record is `@header\n SEQ\n +\n QUAL\n`, so a record of read length L
/// costs 2L + |header| + 6 bytes and yields L - K + 1 kmers. kmers/bytes is
/// therefore strictly below 1/2 for any well-formed FASTQ, which makes bytes/2
/// a real upper bound and not just an estimate -- the arena cannot grow, so it
/// has to be one.
static uint64_t shard_kmer_bytes(const Configuration& config) {
  return (config.in_file_sz / config.num_threads / 2 + 1) * sizeof(uint64_t);
}

void KmerTest::count_kmer(Shard* sh,
                              const Configuration& config,
                              BaseHashTable* ht,
                              std::barrier<VoidFn>* barrier){
  // HTBatchRunner used to own the batch buffer, but it re-tests
  // config.no_prefetch on every single kmer, drags in the find-side machinery
  // this test never touches, and pins the batch to the compile-time
  // HT_TESTS_BATCH_LENGTH -- so --batch-len did nothing here.
  const uint32_t batch_len = config.batch_len;
  if (batch_len == 0) {
    PLOGE.printf("--batch-len must be > 0");
    exit(-1);
  }

  // Stage this shard's kmers in hugepages before the timed section, so the
  // insert loop streams a flat uint64 array rather than walking a vector of
  // per-read std::strings. This also moves 2-bit encoding out of the measured
  // region: what is timed below is hashtable insert throughput and nothing
  // else.
  //
  // One bump arena per shard holds both the kmer array and the batch buffer,
  // sized into explicit 1GB + 2MB page counts the way the radix join does it
  // (hashjoin_test.cpp). huge_page_allocator would instead round the whole
  // request up to a multiple of 1GB once it crosses that threshold, wasting
  // most of a page per shard on a real FASTQ; and being a bump allocator the
  // arena cannot silently realloc a second copy of a huge region.
  const uint64_t kmer_bytes = shard_kmer_bytes(config);
  const uint64_t args_bytes = sizeof(InsertFindArgument) * batch_len;
  // + one 2MB page of slack so the two 64B-aligned bumps always fit.
  const uint64_t bytes_needed = kmer_bytes + args_bytes + SIZE_2MB;

  const uint64_t one_gb_needed = bytes_needed / SIZE_1GB;
  const uint64_t two_mb_needed =
      (bytes_needed - one_gb_needed * SIZE_1GB) / SIZE_2MB + 1;

  if (sh->shard_idx == 0) {
    // The arena throws/aborts if the pool is short, so say up front how much
    // this run wants -- reserve it before starting rather than after the abort.
    PLOGI.printf(
        "kmer staging: %lu bytes/shard (%lu x 1GB + %lu x 2MB hugepages) x %u "
        "shards; reserve the hugepage pool up front or the mmap will abort",
        bytes_needed, one_gb_needed, two_mb_needed, config.num_threads);
  }

  HugepageArena arena(one_gb_needed, two_mb_needed);
  if (config.numa_split == THREADS_CUSTOM) {
    arena.mem_bind(config.np_mem_node_msk);
  }

  uint64_t* kmers = (uint64_t*)arena.aligned_alloc(kmer_bytes, 64);
  // The array the arena handed back is the bound -- nothing else gets to claim
  // one, so the fill loop below can never disagree with what was allocated.
  const uint64_t kmer_capacity = kmer_bytes / sizeof(uint64_t);

  InsertFindArgument* args =
      (InsertFindArgument*)arena.aligned_alloc(args_bytes, 64);
  // Zero once: the insert loops only ever write key/value, and id/part_id would
  // otherwise be whatever the arena handed back. id lands in KVQ::key_id, which
  // only the find path reads, but garbage in it is still garbage.
  memset(args, 0, args_bytes);

  uint64_t num_kmers = 0;
  {
    // Be care of the `K` here; it's a compile time constant.
    auto reader = input_reader::MakeFastqKMerPreloadReader(config.K, config.in_file, sh->shard_idx, config.num_threads);
    for (uint64_t kmer; reader->next(&kmer);) {
      if (num_kmers == kmer_capacity) {
        // Unreachable for well-formed FASTQ (see shard_kmer_bytes). Bail loudly
        // rather than run off the array or drop kmers and report a wrong count.
        PLOGE.printf(
            "shard %u: more than %lu kmers in a %lu byte slice -- input is not "
            "shaped like FASTQ, so the staging bound does not hold",
            sh->shard_idx, kmer_capacity,
            config.in_file_sz / config.num_threads);
        exit(-1);
      }
      kmers[num_kmers++] = kmer;
    }
  }  // reader, and the std::string reservoir behind it, freed before the barrier

  const uint64_t batch_num = num_kmers / batch_len;
  const uint64_t residue_num = num_kmers - batch_num * batch_len;

  if(sh->shard_idx == 0)
  {
    cur_phase = ExecPhase::insertions;
    g_app_record_start = true;
  }

  barrier->arrive_and_wait();

  if (config.no_prefetch) {
    for (uint64_t i = 0; i < num_kmers; i++) {
      // insert_noprefetch reinterprets its argument as {key, value}, so a bare
      // KeyValuePair is all it needs.
      KeyValuePair kv(kmers[i], 0);
      ht->insert_noprefetch(&kv);
    }
  } else {
    uint64_t idx = 0;
    for (uint64_t n = 0; n < batch_num; n++) {
      for (uint32_t i = 0; i < batch_len; i++) {
        args[i].key = kmers[idx++];
        args[i].value = 0;  // the aggr table derives the count itself
      }
      ht->insert_batch(InsertFindArguments(args, batch_len));
    }
    if (residue_num > 0) {
      for (uint64_t i = 0; i < residue_num; i++) {
        args[i].key = kmers[idx++];
        args[i].value = 0;
      }
      ht->insert_batch(InsertFindArguments(args, residue_num));
    }
    ht->flush_insert_queue();
  }

  // No free here: the arena owns both allocations and unmaps them on scope
  // exit, below the second barrier rather than inside the timed region.

  if(sh->shard_idx == 0)
  {
    cur_phase = ExecPhase::insertions;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();
  sh->stats->insertions.duration = g_insert_end - g_insert_start;
  sh->stats->insertions.op_count = num_kmers;
  get_ht_stats(sh, ht);

  if (sh->shard_idx == 0) {
    PLOGI.printf("fill: %lu\n", ht->get_fill());//"get fill %.3f",
                 //(double)ht->get_fill() / ht->get_capacity());
  }
}

} // namespace kmercounter
