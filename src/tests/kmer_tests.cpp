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
#include <numa.h>

#include "numa.hpp"
#include "print_stats.h"
#include "utils/hugepage_arena.hpp"
#include "utils/kmer_staging.hpp"

namespace kmercounter {
extern ExecPhase cur_phase;
extern bool g_app_record_start;
extern uint64_t g_insert_end;
extern uint64_t g_insert_start;

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
  //
  // The two pools together cover bytes_needed, but the arena serves any single
  // allocation from one pool or the other and never across both -- so the kmer
  // array is split into chunks that mirror the pool layout (see
  // utils/kmer_staging.hpp). Asking for it in one piece fails for any input
  // where in_file_sz > num_threads * 512MiB, with the pool sitting half unused.
  const uint64_t kmer_bytes =
      staging::shard_kmer_bytes(config.in_file_sz, config.num_threads);
  const uint64_t args_bytes = sizeof(InsertFindArgument) * batch_len;
  // + one 2MB page of slack so the two 64B-aligned bumps always fit.
  const uint64_t bytes_needed = staging::shard_arena_bytes(kmer_bytes, args_bytes);

  const uint64_t one_gb_needed = staging::one_gb_pages(bytes_needed);
  const uint64_t two_mb_needed = staging::two_mb_pages(bytes_needed);

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

  // Split to match the pool layout: the arena serves an allocation out of the
  // 1GB pool or the 2MB pool but never across both, so a single kmer_bytes
  // request fits neither once it exceeds 1GiB. Built before `args` because the
  // arena is greedy on the 1GB pool -- a small allocation first would push a
  // whole-1GiB chunk out of it.
  staging::StagingBuffer kmers(arena, kmer_bytes, batch_len);
  const uint64_t kmer_capacity = kmers.capacity();

  if (sh->shard_idx == 0) {
    PLOGI.printf("kmer staging: %lu chunk(s), %lu kmers capacity",
                 kmers.num_chunks(), kmer_capacity);
  }

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
      kmers.push(kmer);
      num_kmers++;
    }
  }  // reader, and the std::string reservoir behind it, freed before the barrier

  // One line per shard, same reasoning as the prod/cons path: outside the
  // timed region, and it shows where each shard's pages actually came from.
  PLOGI.printf(
      "kmer staging alloc: shard %u cpu %d node %d -> %lu bytes "
      "(%lu x 1GB + %lu x 2MB), %lu chunk(s), %lu kmers staged",
      sh->shard_idx, sched_getcpu(), numa_node_of_cpu(sched_getcpu()),
      bytes_needed, one_gb_needed, two_mb_needed, kmers.num_chunks(),
      num_kmers);

  if(sh->shard_idx == 0)
  {
    cur_phase = ExecPhase::insertions;
    g_app_record_start = true;
  }

  barrier->arrive_and_wait();

  // Every chunk but the last holds a whole multiple of batch_len kmers, so a
  // batch never straddles a chunk boundary and this stays a flat pointer walk.
  if (config.no_prefetch) {
    for (uint64_t c = 0; c < kmers.num_chunks(); c++) {
      const uint64_t* chunk = kmers.chunks()[c].data;
      const uint64_t len = kmers.filled_len(c, num_kmers);
      for (uint64_t i = 0; i < len; i++) {
        // insert_noprefetch reinterprets its argument as {key, value}, so a
        // bare KeyValuePair is all it needs.
        KeyValuePair kv(chunk[i], 0);
        ht->insert_noprefetch(&kv);
      }
    }
  } else {
    for (uint64_t c = 0; c < kmers.num_chunks(); c++) {
      const uint64_t* chunk = kmers.chunks()[c].data;
      const uint64_t len = kmers.filled_len(c, num_kmers);
      const uint64_t chunk_batches = len / batch_len;
      const uint64_t chunk_residue = len - chunk_batches * batch_len;

      uint64_t idx = 0;
      for (uint64_t n = 0; n < chunk_batches; n++) {
        for (uint32_t i = 0; i < batch_len; i++) {
          args[i].key = chunk[idx++];
          args[i].value = 0;  // the aggr table derives the count itself
        }
        ht->insert_batch(InsertFindArguments(args, batch_len));
      }
      // Only the final chunk can leave a partial batch; the others are sized to
      // a whole multiple of batch_len.
      if (chunk_residue > 0) {
        for (uint64_t i = 0; i < chunk_residue; i++) {
          args[i].key = chunk[idx++];
          args[i].value = 0;
        }
        ht->insert_batch(InsertFindArguments(args, chunk_residue));
      }
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
    // One table shared by every thread here, so shard 0's fill is the run-wide
    // figure -- unlike the prod/cons path, where each consumer reports its own
    // private table and the totals have to be summed.
    const size_t fill = ht->get_fill();
    const size_t cap = ht->get_capacity();
    PLOGI.printf("Shard %u: ht-fill: %lu, ht-sz: %lu, fill-factor: %.4f",
                 sh->shard_idx, fill, cap,
                 cap ? (double)fill / (double)cap : 0.0);
  }
}

} // namespace kmercounter
