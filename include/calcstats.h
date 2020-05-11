#ifndef _STATS_H
#define _STATS_H

/*From /proc/cpuinfo*/
#define CPUFREQ_MHZ (2200.0)
static const float one_cycle_ns = ((float)1000 / CPUFREQ_MHZ);

void print_stats(__shard *all_sh)
{
  // uint64_t kmer_big_pool_size_per_shard =
  //     (config.kmer_create_data_base * config.kmer_create_data_mult);
  // uint64_t total_kmer_big_pool_size =
  //     (kmer_big_pool_size_per_shard * config.num_threads);

  // uint64_t kmer_small_pool_size_per_shard = config.kmer_create_data_uniq;
  // uint64_t total_kmer_small_pool_size =
  //     (kmer_small_pool_size_per_shard * config.num_threads);

  uint64_t all_total_cycles = 0;
  double all_total_time_ns = 0;
  uint64_t all_total_num_inserts = 0;
  // uint64_t all_total_reprobes = 0;

  //   uint64_t all_total_find_cycles = 0;
  //   double all_total_find_time_ns = 0;

  //  printf("[INFO] Thread %u. cycles/insertion: %lu, fill: %lu of %lu (%f %)
  //  \n",
  //        sh->shard_idx,
  //        sh->stats->insertion_cycles / kmer_big_pool_size_per_shard,
  //        sh->stats->ht_fill, sh->stats->ht_capacity,
  //        (double)sh->stats->ht_fill / sh->stats->ht_capacity * 100);
  printf("===============================================================\n");
  for (size_t k = 0; k < config.num_threads; k++) {
    printf(
        "Thread %2d: "
        "%lu cycles (%f ms) for %lu insertions (%lu cycles/insert) "
        // "%lu cycles/find "
        "{ fill: %lu of %lu (%f %) }"
#ifdef CALC_STATS
        " [num_reprobes: %lu, "
        "num_memcmps: %lu, "
        "num_memcpys: %lu, "
        "num_queue_flushes: %lu, "
        "num_hashcmps: %lu, "
        "max_distance_from_bucket: %lu, "
        "avg_distance_from_bucket: %f]"
#endif  // CALC_STATS
        "\n",
        all_sh[k].shard_idx, 
        all_sh[k].stats->insertion_cycles,
        (double)all_sh[k].stats->insertion_cycles * one_cycle_ns / 1000000.0,
        all_sh[k].stats->num_inserts,
        all_sh[k].stats->insertion_cycles / all_sh[k].stats->num_inserts,
        // all_sh[k].stats->find_cycles / all_sh[k].stats->num_inserts,
        all_sh[k].stats->ht_fill, all_sh[k].stats->ht_capacity,
        (double)all_sh[k].stats->ht_fill / all_sh[k].stats->ht_capacity * 100
#ifdef CALC_STATS
        ,
        all_sh[k].stats->num_reprobes, all_sh[k].stats->num_memcmps,
        all_sh[k].stats->num_memcpys, all_sh[k].stats->num_queue_flushes,
        all_sh[k].stats->num_hashcmps,
        all_sh[k].stats->max_distance_from_bucket,
        all_sh[k].stats->avg_distance_from_bucket
#endif  // CALC_STATS
    );
    all_total_cycles += all_sh[k].stats->insertion_cycles;
    all_total_time_ns +=
        (double)all_sh[k].stats->insertion_cycles * one_cycle_ns;
    all_total_num_inserts += all_sh[k].stats->num_inserts;
    // all_total_reprobes += all_sh[k].stats->num_reprobes;

    // all_total_find_cycles += all_sh[k].stats->find_cycles;
    // all_total_find_time_ns =
    //     (double)all_sh[k].stats->find_cycles * one_cycle_ns;
  }
  printf("===============================================================\n");
  printf(
      "Average  : %lu cycles (%f ms) for %lu insertions (%lu cycles/insert)\n",
      all_total_cycles / config.num_threads,
      (double)all_total_time_ns / 1000000.0 / config.num_threads,
      all_total_num_inserts / config.num_threads,
      all_total_cycles / all_total_num_inserts);
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

#endif  // _STATS_H
