#ifndef _PRINT_STATS_H
#define _PRINT_STATS_H

/*From /proc/cpuinfo*/
#define CPUFREQ_MHZ (2200.0)
static const float one_cycle_ns = ((float)1000 / CPUFREQ_MHZ);

void get_ht_stats(__shard *sh, KmerHashTable *kmer_ht)
{
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
      (double)(kmer_ht->sum_distance_from_bucket / ht_size);
  sh->stats->max_distance_from_bucket = kmer_ht->max_distance_from_bucket;
  sh->stats->avg_read_length = avg_read_length;
  sh->stats->num_sequences = num_sequences;
#endif
}

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

#ifdef CALC_STATS
  uint64_t all_total_avg_read_length = 0;
  uint64_t all_total_num_sequences = 0;
  // uint64_t all_total_reprobes = 0;
#endif

  //   uint64_t all_total_find_cycles = 0;
  //   double all_total_find_time_ns = 0;

  printf("===============================================================\n");
  for (size_t k = 0; k < config.num_threads; k++) {
    if (all_sh[k].stats->num_inserts == 0) {
      printf("Thread %2d: No inserts \n", all_sh[k].shard_idx);
      continue;
    }

    printf(
        "Thread %2d: "
        "%lu cycles (%f ms) for %lu insertions (%lu cycles/insert) "
        "{ fill: %lu of %lu (%f %%) }"
#ifdef CALC_STATS
        "\n["
        "\nnum_reprobes: %lu, "
        "\nnum_memcmps: %lu, "
        "\nnum_memcpys: %lu, "
        "\nnum_queue_flushes: %lu, "
        "\nnum_hashcmps: %lu, "
        "\nmax_distance_from_bucket: %lu, "
        "\navg_distance_from_bucket: %f,"
        "\navg_read_length: %lu,"
        "\nnum_sequences :%lu"
        "\n]"
#endif  // CALC_STATS
        "\n",
        all_sh[k].shard_idx, all_sh[k].stats->insertion_cycles,
        (double)all_sh[k].stats->insertion_cycles * one_cycle_ns / 1000000.0,
        all_sh[k].stats->num_inserts,
        all_sh[k].stats->insertion_cycles / all_sh[k].stats->num_inserts,
        all_sh[k].stats->ht_fill, all_sh[k].stats->ht_capacity,
        (double)all_sh[k].stats->ht_fill / all_sh[k].stats->ht_capacity * 100
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
#endif  // CALC_STATS

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

#endif  // _STATS_H
