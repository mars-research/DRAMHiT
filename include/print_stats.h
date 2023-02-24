#ifndef _PRINT_STATS_H
#define _PRINT_STATS_H

#include "hashtables/base_kht.hpp"

namespace kmercounter {
/*From /proc/cpuinfo*/
#define CPUFREQ_MHZ (2200.0)
static const float one_cycle_ns = ((float)1000 / CPUFREQ_MHZ);

inline void get_ht_stats(Shard *sh, BaseHashTable *kmer_ht) {
  sh->stats->ht_fill = kmer_ht->get_fill();
  sh->stats->ht_capacity = kmer_ht->get_capacity();
  sh->stats->max_count = kmer_ht->get_max_count();

#ifdef CALC_STATS
  sh->stats->num_reprobes = kmer_ht->num_reprobes;
  sh->stats->num_memcmps = kmer_ht->num_memcmps;
  sh->stats->num_memcpys = kmer_ht->num_memcpys;
  sh->stats->num_queue_flushes = kmer_ht->num_queue_flushes;
  sh->stats->num_hashcmps = kmer_ht->num_hashcmps;
  if (sh->stats->ht_fill)
    sh->stats->avg_distance_from_bucket =
      (double)(kmer_ht->sum_distance_from_bucket / sh->stats->ht_fill);
  sh->stats->max_distance_from_bucket = kmer_ht->max_distance_from_bucket;
#endif
}

inline void print_stats(Shard *all_sh, Configuration &config) {
  uint64_t all_total_cycles = 0;
  double all_total_time_ns = 0;
  uint64_t all_total_num_inserts = 0;
  uint64_t total_find_cycles = 0;
  uint64_t total_finds = 0;

#ifdef CALC_STATS
  uint64_t all_total_avg_read_length = 0;
  uint64_t all_total_num_sequences = 0;
  uint64_t all_total_reprobes = 0;
  uint64_t all_total_find_cycles = 0;
  [[maybe_unused]] double all_total_find_time_ns = 0;
#endif

  size_t k = 0;
  // if (config.mode == BQ_TESTS_YES_BQ) {
  //  k = producer_count;
  //}

  printf("===============================================================\n");
  for (; k < config.num_threads; k++) {
    printf(
        "Thread %2d: "
        "%" PRIu64 " cycles (%f ms) for %" PRIu64 " insertions (%" PRIu64 " cycles/insert) | (%" PRIu64 " cycles/enqueue) "
        "{ fill: %" PRIu64 " of %" PRIu64 " (%f %%) }"
#ifdef CALC_STATS
        "["
        "num_reprobes: %" PRIu64 ", "
        "num_memcmps: %" PRIu64 ", "
        "num_memcpys: %" PRIu64 ", "
        "num_queue_flushes: %" PRIu64 ", "
        "num_hashcmps: %" PRIu64 ", "
        "max_distance_from_bucket: %" PRIu64 ", "
        "avg_distance_from_bucket: %f,"
        "avg_distance_from_bucket (adjusted): %f,"
        "avg_read_length: %" PRIu64 ","
        "num_sequences :%" PRIu64 ""
        "]"
#endif  // CALC_STATS
        "\n",
        all_sh[k].shard_idx, all_sh[k].stats->insertions.duration,
        (double)all_sh[k].stats->insertions.duration * one_cycle_ns / 1000000.0,
        all_sh[k].stats->insertions.op_count,
        all_sh[k].stats->insertions.op_count == 0
            ? 0
            : all_sh[k].stats->insertions.duration /
                  all_sh[k].stats->insertions.op_count,
        all_sh[k].stats->enqueues.op_count == 0
            ? 0
            : all_sh[k].stats->enqueues.duration /
                  all_sh[k].stats->enqueues.op_count,
        all_sh[k].stats->ht_fill, all_sh[k].stats->ht_capacity,
        all_sh[k].stats->ht_capacity == 0
            ? 0
            : (double)all_sh[k].stats->ht_fill / all_sh[k].stats->ht_capacity *
                  100
#ifdef CALC_STATS
        ,
        all_sh[k].stats->num_reprobes, all_sh[k].stats->num_memcmps,
        all_sh[k].stats->num_memcpys, all_sh[k].stats->num_queue_flushes,
        all_sh[k].stats->num_hashcmps,
        all_sh[k].stats->max_distance_from_bucket,
        all_sh[k].stats->avg_distance_from_bucket,
        all_sh[k].stats->avg_distance_from_bucket / config.insert_factor,
        all_sh[k].stats->avg_read_length, all_sh[k].stats->num_sequences
#endif  // CALC_STATS
    );
    all_total_cycles += all_sh[k].stats->insertions.duration;
    all_total_time_ns +=
        (double)all_sh[k].stats->insertions.duration * one_cycle_ns;
    all_total_num_inserts += all_sh[k].stats->insertions.op_count;
    total_finds += all_sh[k].stats->finds.op_count;
    total_find_cycles += all_sh[k].stats->finds.duration;

#ifdef CALC_STATS
    all_total_num_sequences += all_sh[k].stats->num_sequences;
    all_total_avg_read_length += all_sh[k].stats->avg_read_length;
    all_total_reprobes += all_sh[k].stats->num_reprobes;
    //all_total_find_time_ns =
        //(double)all_sh[k].finds.duration * one_cycle_ns;
#endif  // CALC_STATS
  }

  const volatile auto a = config.num_threads;
  const volatile auto b = all_total_num_inserts;
  printf("%u %" PRIu64 "\n", config.num_threads, all_total_num_inserts);
  printf("===============================================================\n");
  printf(
      "Average  : %" PRIu64 " cycles (%f ms) for %" PRIu64 " insertions (%" PRIu64 " cycles/insert) "
      "(fill = %u %%)\n",
      all_total_cycles / config.num_threads,
      (double)all_total_time_ns / 1000000.0 / config.num_threads,
      all_total_num_inserts / config.num_threads,
      all_total_cycles / all_total_num_inserts, config.ht_fill);
  // printf(
  //     "Average (find): %" PRIu64 " cycles (%f ms) for %" PRIu64 " finds (%" PRIu64 " cycles per "
  //     "find)\n",
  //     all_total_find_cycles / config.num_threads,
  //     (double)all_total_find_time_ns * one_cycle_ns / 1000,
  //     kmer_big_pool_size_per_shard,
  //     all_total_find_cycles / config.num_threads /
  //         kmer_big_pool_size_per_shard);
  printf("===============================================================\n");
  printf("Total  : %" PRIu64 " cycles (%f ms) for %" PRIu64 " insertions\n", all_total_cycles,
         (double)all_total_time_ns / 1000000.0, all_total_num_inserts);
  double find_mops = 0.0, insert_mops = 0.0;

  {
    uint64_t cycles_per_insert = all_total_cycles / all_total_num_inserts;

    uint64_t cycles_per_find = 0;

    if (total_finds > 0) {
      cycles_per_find = total_find_cycles / total_finds;
      printf(
          "===============================================================\n");
      printf("Average  : %" PRIu64 " cycles for %" PRIu64 " combined R/W (%" PRIu64 " cycles/op)\n",
             total_find_cycles / config.n_prod,
             total_finds / config.n_prod, cycles_per_find);
      printf(
          "===============================================================\n");
    }

    uint64_t num_threads = config.num_threads;
    // for inserts, we only use n_cons
    if (config.mode == BQ_TESTS_YES_BQ) {
      num_threads = config.n_cons;
    }
    insert_mops = ((double)2600 / cycles_per_insert) * num_threads;
    printf("Number of insertions per sec (Mops/s): %.3f\n", insert_mops);

    // for find, we use all threads
    if (config.mode == BQ_TESTS_YES_BQ) {
      num_threads = config.n_cons + config.n_prod;
    }
    find_mops = ((double)2600 / cycles_per_find) * config.n_prod;
    printf("%s, num_threads %" PRIu64 "\n", __func__, num_threads);
    printf("Number of finds per sec (Mops/s): %.3f\n", find_mops);

    printf("{ set_cycles : %" PRIu64 ", get_cycles : %" PRIu64 ",", cycles_per_insert, cycles_per_find);
    printf(" set_mops : %.3f, get_mops : %.3f }\n", insert_mops, find_mops);
  }

  // printf(
  //     "Average (find): %" PRIu64 " cycles (%f ms) for %" PRIu64 " finds (%" PRIu64 " cycles per "
  //     "find)\n",
  //     all_total_find_cycles / config.num_threads,
  //     (double)all_total_find_time_ns * one_cycle_ns / 1000,
  //     kmer_big_pool_size_per_shard,
  //     all_total_find_cycles / config.num_threads /
  //         kmer_big_pool_size_per_shard);
  printf("===============================================================\n");
}

}  // namespace kmercounter
#endif  // _STATS_H
