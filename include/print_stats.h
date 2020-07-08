#ifndef _PRINT_STATS_H
#define _PRINT_STATS_H

#include "base_kht.hpp"

namespace kmercounter {
/*From /proc/cpuinfo*/
#define CPUFREQ_MHZ (2200.0)
static const float one_cycle_ns = ((float)1000 / CPUFREQ_MHZ);

inline void get_ht_stats(Shard *sh, KmerHashTable *kmer_ht) {
  sh->stats->ht_fill = kmer_ht->get_fill();
  sh->stats->ht_capacity = kmer_ht->get_capacity();
  sh->stats->max_count = kmer_ht->get_max_count();

#ifdef CALC_STATS
  sh->stats->num_reprobes = kmer_ht->num_reprobes;
  sh->stats->num_memcmps = kmer_ht->num_memcmps;
  sh->stats->num_memcpys = kmer_ht->num_memcpys;
  sh->stats->num_queue_flushes = kmer_ht->num_queue_flushes;
  sh->stats->num_hashcmps = kmer_ht->num_hashcmps;
  sh->stats->avg_distance_from_bucket =
      (double)(kmer_ht->sum_distance_from_bucket / sh->stats->ht_fill);
  sh->stats->max_distance_from_bucket = kmer_ht->max_distance_from_bucket;
#endif
}

inline void print_stats(Shard *all_sh, Configuration &config) {
  uint64_t all_total_cycles = 0;
  double all_total_time_ns = 0;
  uint64_t all_total_num_inserts = 0;

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
        "%lu cycles (%f ms) for %lu insertions (%lu cycles/insert) "
        "{ fill: %lu of %lu (%f %%) }"
#ifdef CALC_STATS
        "["
        "num_reprobes: %lu, "
        "num_memcmps: %lu, "
        "num_memcpys: %lu, "
        "num_queue_flushes: %lu, "
        "num_hashcmps: %lu, "
        "max_distance_from_bucket: %lu, "
        "avg_distance_from_bucket: %f,"
        "avg_read_length: %lu,"
        "num_sequences :%lu"
        "]"
#endif  // CALC_STATS
        "\n",
        all_sh[k].shard_idx, all_sh[k].stats->insertion_cycles,
        (double)all_sh[k].stats->insertion_cycles * one_cycle_ns / 1000000.0,
        all_sh[k].stats->num_inserts,
        all_sh[k].stats->num_inserts == 0
            ? 0
            : all_sh[k].stats->insertion_cycles / all_sh[k].stats->num_inserts,
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
        all_sh[k].stats->avg_read_length, all_sh[k].stats->num_sequences
#endif  // CALC_STATS
    );
    all_total_cycles += all_sh[k].stats->insertion_cycles;
    all_total_time_ns +=
        (double)all_sh[k].stats->insertion_cycles * one_cycle_ns;
    all_total_num_inserts += all_sh[k].stats->num_inserts;

#ifdef CALC_STATS
    all_total_num_sequences += all_sh[k].stats->num_sequences;
    all_total_avg_read_length += all_sh[k].stats->avg_read_length;
    all_total_reprobes += all_sh[k].stats->num_reprobes;
    all_total_find_cycles += all_sh[k].stats->find_cycles;
    all_total_find_time_ns =
        (double)all_sh[k].stats->find_cycles * one_cycle_ns;
#endif  // CALC_STATS
  }
  printf("===============================================================\n");
  printf(
      "Average  : %lu cycles (%f ms) for %lu insertions (%lu cycles/insert) "
      "(fill = %u %%)\n",
      all_total_cycles / config.num_threads,
      (double)all_total_time_ns / 1000000.0 / config.num_threads,
      all_total_num_inserts / config.num_threads,
      all_total_cycles / all_total_num_inserts, config.ht_fill);
  // printf(
  //     "Average (find): %lu cycles (%f ms) for %lu finds (%lu cycles per "
  //     "find)\n",
  //     all_total_find_cycles / config.num_threads,
  //     (double)all_total_find_time_ns * one_cycle_ns / 1000,
  //     kmer_big_pool_size_per_shard,
  //     all_total_find_cycles / config.num_threads /
  //         kmer_big_pool_size_per_shard);
  printf("===============================================================\n");
  printf("Total  : %lu cycles (%f ms) for %lu insertions\n", all_total_cycles,
         (double)all_total_time_ns / 1000000.0, all_total_num_inserts);
  // printf(
  //     "Average (find): %lu cycles (%f ms) for %lu finds (%lu cycles per "
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
