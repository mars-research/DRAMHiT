#ifndef _PRINT_STATS_H
#define _PRINT_STATS_H

#include "hashtables/base_kht.hpp"

namespace kmercounter {

extern uint64_t *g_find_durations;
extern uint64_t *g_insert_durations;

// CHANGE ME DEPENDING ON MACHINE
/*From /proc/cpuinfo*/
#define CPUFREQ_MHZ (2500.0)
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

inline void print_stats(Shard *all_sh, Configuration &config) {
  uint64_t total_inserts = 0;
  uint64_t total_insert_cycles = 0;
  uint64_t total_find_cycles = 0;
  uint64_t total_finds = 0;

  uint64_t max_find_duration = 0;
  uint64_t max_insert_duration = 0;

  uint64_t avg_find_duration = 0;
  uint64_t avg_insert_duration = 0;

  uint64_t total_upsert_cycles = 0;
  uint64_t total_upsert = 0;

#ifdef CALC_STATS
  uint64_t all_total_avg_read_length = 0;
  uint64_t all_total_num_sequences = 0;
  uint64_t all_total_reprobes = 0;
  uint64_t all_total_find_cycles = 0;
  [[maybe_unused]] double all_total_find_time_ns = 0;
#endif

  for (int k = 0; k < config.num_threads; k++) {
    total_insert_cycles += all_sh[k].stats->insertions.duration;
    total_inserts += all_sh[k].stats->insertions.op_count;
    total_finds += all_sh[k].stats->finds.op_count;
    total_find_cycles += all_sh[k].stats->finds.duration;
    total_upsert += all_sh[k].stats->upsertions.op_count;
    total_upsert_cycles += all_sh[k].stats->upsertions.duration;

    max_find_duration = all_sh[k].stats->finds.duration > max_find_duration
                            ? all_sh[k].stats->finds.duration
                            : max_find_duration;
    max_insert_duration =
        all_sh[k].stats->insertions.duration > max_insert_duration
            ? all_sh[k].stats->insertions.duration
            : max_insert_duration;
  }

  double find_mops = 0.0, insert_mops = 0.0, upsert_mops = 0.0;

  uint64_t cycles_per_insert = 0;
  uint64_t cycles_per_find = 0;
  uint64_t cycles_per_upsert = 0;

  if (total_finds > 0) {
    cycles_per_find = total_find_cycles / total_finds;
  }

  if (total_inserts > 0) {
    cycles_per_insert = total_insert_cycles / total_inserts;
  }

  if (total_upsert > 0) cycles_per_upsert = total_upsert_cycles / total_upsert;

  uint64_t num_threads = config.num_threads;

  avg_find_duration = total_find_cycles / num_threads;
  avg_insert_duration = total_insert_cycles / num_threads;
  find_mops = (double)((CPUFREQ_MHZ * total_finds) / avg_find_duration);
  insert_mops = (double)((CPUFREQ_MHZ * total_inserts) / avg_insert_duration);

  printf("===============================================================\n");

  if (config.insert_factor > 0) {
    uint64_t op_per_iter = total_inserts / config.insert_factor;
    printf("insert op per iter %lu, avg insert cpu cycles per iter: %lu\n",
           op_per_iter, total_insert_cycles / config.insert_factor);
    if (config.insert_snapshot > 0) {
      printf(
          "=========================Snapshot "
          "info============================\n");

      for (int i = 0; i < config.insert_factor; i++) {
        uint64_t snapshot_duration = g_insert_durations[i];
        printf(
            "Insert snapshot iter %lu, duration %lu, op %lu, cpo %lu, mops "
            "%lu\n",
            i, snapshot_duration, op_per_iter,
            (snapshot_duration * config.num_threads) / op_per_iter,
            ((uint64_t)(CPUFREQ_MHZ * op_per_iter) / snapshot_duration));
      }
      printf(
          "===============================================================\n");
    }
  }

  if (config.read_factor > 0) {
    uint64_t op_per_iter = total_finds / config.read_factor;
    printf("read op per iter %lu, avg find cpu cycles per iter: %lu\n",
           op_per_iter, total_find_cycles / config.read_factor);
    if (config.read_snapshot > 0) {
      printf(
          "=====================Snapshot info============================\n");

      for (int i = 0; i < config.read_factor; i++) {
        uint64_t snapshot_duration = g_find_durations[i];
        printf(
            "Read snapshot iter %lu, duration %lu, op %lu, cpo %lu, mops %lu\n",
            i, snapshot_duration, op_per_iter,
            (snapshot_duration * config.num_threads) / op_per_iter,
            ((uint64_t)(CPUFREQ_MHZ * op_per_iter) / snapshot_duration));
      }
      printf(
          "===============================================================\n");
    }
  }

  printf(
      "Insert stats: total op %lu, total cpu cycles %lu, op per thread %lu\n",
      total_inserts, total_insert_cycles, total_inserts / num_threads);

  printf("Find stats: total op %lu, total cpu cycles %lu, op per thread %lu\n",
         total_finds, total_find_cycles, total_finds / num_threads);

  printf("{ set_cycles : %" PRIu64 ", get_cycles : %" PRIu64
         ", upsert_cycles : %" PRIu64 ",",
         cycles_per_insert, cycles_per_find, cycles_per_upsert);
  printf(" set_mops : %.3f, get_mops : %.3f, upsert_mops : %.3f }\n",
         insert_mops, find_mops, upsert_mops);

  printf("===============================================================\n");
}

}  // namespace kmercounter
#endif  // _STATS_H
