#ifndef _PRINT_STATS_H
#define _PRINT_STATS_H

#include <cstdint>
#include <iostream>
#include <unordered_map>
#include <vector>

#include "hashtables/base_kht.hpp"
#include "types.hpp"

namespace kmercounter {

// I hate this ....

#if defined(WITH_PCM)
extern double *g_find_bw;
#endif

// #define CPUFREQ_MHZ defined by cmake
static const float one_cycle_ns = ((float)1000 / CPUFREQ_MHZ);

inline void get_ht_stats(Shard *sh, BaseHashTable *kmer_ht) {
  // sh->stats->ht_fill = kmer_ht->get_fill();
  // sh->stats->ht_capacity = kmer_ht->get_capacity();
  //  sh->stats->max_count = kmer_ht->get_max_count();

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

uint64_t calculate_expected_join_size(uint64_t r_size, uint64_t s_size);

void print_stats(Shard *all_sh, Configuration &config);
}  // namespace kmercounter
#endif  // _STATS_H
