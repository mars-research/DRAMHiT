#include "misc_lib.h"
#include "print_stats.h"

uint64_t get_file_size(const char *fn) {
  int fd = open(fn, O_RDONLY);
  struct stat sb;
  if (fstat(fd, &sb) == -1) {
    fprintf(stderr, "[ERROR] Couldn't stat file size\n");
    exit(-1);
  }
  return sb.st_size;
}

uint64_t round_down(uint64_t n, uint64_t m) {
  return n >= 0 ? (n / m) * m : ((n - m + 1) / m) * m;
}

uint64_t round_up(uint64_t n, uint64_t m) {
  return n >= 0 ? ((n + m - 1) / m) * m : (n / m) * m;
}

// TODO max value of k to support?s
uint64_t calc_num_kmers(uint64_t l, uint8_t k) { return (l - k + 1); }

int find_last_N(const char *c) {
  if (!c) return -1;
  int i = KMER_DATA_LENGTH;
  while (--i >= 0) {
    if (c[i] == 'N' || c[i] == 'n') {
      return i;
    }
  }
  return -1;
}

/*	Touching pages bring mmaped pages into memory. Possibly because we
have lot of memory, pages are never swapped out. mlock itself doesn't
seem to bring pages into memory (it should as per the man page)
TODO look into this.	*/
uint64_t __attribute__((optimize("O0"))) touchpages(char *fmap, size_t sz) {
  uint64_t sum = 0;
  for (uint64_t i = 0; i < sz; i += PAGE_SIZE) sum += fmap[i];
  return sum;
}

#include <numaif.h>

#include "numa.hpp"
#include "types.hpp"
#include "hashtables/kvtypes.cpp"
#include "all_ht_types.hpp"

namespace kmercounter {

extern Configuration config;
extern std::vector<key_type> *g_zipf_values;

void distribute_mem_to_nodes(void *addr, uint64_t alloc_sz,
                             numa_policy_threads policy) {
  // Check if there is only one NUMA node
  if (numa_num_configured_nodes() == 1) {
    PLOG_INFO.printf(
        "Only one NUMA node available, skipping memory distribution.");
    return;
  }

  if (policy == THREADS_REMOTE_NUMA_NODE) {
    unsigned long nodemask = 1UL << 1;
    unsigned long maxnode = sizeof(nodemask) * 8;

    long ret = mbind(addr, alloc_sz, MPOL_BIND, &nodemask, maxnode,
                     MPOL_MF_MOVE | MPOL_MF_STRICT);
    if (ret < 0) {
      perror("mbind");
      PLOGE.printf("mbind ret %ld | errno %d", ret, errno);
    }
  } else if ((policy == THREADS_LOCAL_NUMA_NODE ||
              policy == THREADS_NO_MEM_DISTRIBUTION)) {
    unsigned long nodemask = 1UL << 0;
    unsigned long maxnode = sizeof(nodemask) * 8;

    long ret = mbind(addr, alloc_sz, MPOL_BIND, &nodemask, maxnode,
                     MPOL_MF_MOVE | MPOL_MF_STRICT);
    if (ret < 0) {
      perror("mbind");
      PLOGE.printf("mbind ret %ld | errno %d", ret, errno);
    }
  } else if (policy == THREADS_SPLIT_EVEN_NODES) {
    uint64_t sz = alloc_sz >> 1;
    void *u_addr = addr + sz;

    unsigned long nodemask = 1UL << 0;
    unsigned long maxnode = sizeof(nodemask) * 8;

    long ret = mbind(addr, sz, MPOL_BIND, &nodemask, maxnode,
                     MPOL_MF_MOVE | MPOL_MF_STRICT);
    if (ret < 0) {
      perror("mbind");
      PLOGE.printf("mbind ret %ld | errno %d | addr: %p | sz: %lu", ret, errno,
                   addr, sz);
    }

    nodemask = 1UL << 1;
    maxnode = sizeof(nodemask) * 8;

    ret = mbind(u_addr, sz, MPOL_BIND, &nodemask, maxnode,
                MPOL_MF_MOVE | MPOL_MF_STRICT);
    if (ret < 0) {
      perror("mbind");
      PLOGE.printf("mbind ret %ld | errno %d", ret, errno);
    }
  } else {
    long ret = mbind(addr, alloc_sz, MPOL_INTERLEAVE, numa_all_nodes_ptr->maskp,
                     *numa_all_nodes_ptr->maskp, MPOL_MF_MOVE | MPOL_MF_STRICT);
    if (ret < 0) {
      perror("mbind");
      PLOGE.printf("mbind ret %ld | errno %d", ret, errno);
    }
  }

  PLOGI.printf("addr %p, alloc_sz %lu", addr, alloc_sz);
}

// g_zipf_values is global ....
uint64_t calculate_expected_join_size(uint64_t r_size, uint64_t s_size) {
  // Map to store frequency of each 64-bit key
  std::unordered_map<key_type, uint64_t> r_key_counts;

  // 1. Build Phase
  for (uint64_t i = 0; i < r_size; ++i) {
    r_key_counts[g_zipf_values->at(i)]++;
  }

  uint64_t expected_join_size = 0;
  uint64_t s_end = r_size + s_size;

  // 2. Probe Phase
  for (uint64_t j = r_size; j < s_end; ++j) {
    auto it = r_key_counts.find(g_zipf_values->at(j));
    if (it != r_key_counts.end()) {
      expected_join_size++;
    }
  }

  return expected_join_size;
}

void print_stats(Shard *all_sh, Configuration &config) {
  uint64_t total_inserts = 0;
  uint64_t total_insert_cycles = 0;
  uint64_t total_find_cycles = 0;
  uint64_t total_finds = 0;
  uint64_t total_found = 0;

  uint64_t max_find_duration = 0;
  uint64_t max_insert_duration = 0;

  uint64_t avg_find_duration = 0;
  uint64_t avg_insert_duration = 0;

  uint64_t total_upsert_cycles = 0;
  uint64_t total_upsert = 0;

  uint64_t ht_fill = 0;
  uint64_t ht_capacity = 0;

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
    total_found += all_sh[k].stats->found;

    ht_fill += all_sh[k].stats->ht_fill;
    ht_capacity += all_sh[k].stats->ht_capacity;

    max_find_duration = all_sh[k].stats->finds.duration > max_find_duration
                            ? all_sh[k].stats->finds.duration
                            : max_find_duration;
    max_insert_duration =
        all_sh[k].stats->insertions.duration > max_insert_duration
            ? all_sh[k].stats->insertions.duration
            : max_insert_duration;
#ifdef CALC_STATS
    // all_total_num_sequences += all_sh[k].stats->num_sequences;
    // all_total_avg_read_length += all_sh[k].stats->avg_read_length;
    all_total_reprobes += all_sh[k].stats->num_reprobes;
    // all_total_find_time_ns =
    //(double)all_sh[k].finds.duration * one_cycle_ns;
#endif
  }  // end for loop across all threads.

#ifdef CALC_STATS

  printf(
      "{total_reprobes : %llu, total_finds : %llu, avg_cachelines_accessed : "
      "%.4f}\n",
      (unsigned long long)all_total_reprobes, (unsigned long long)total_finds,
      (all_total_reprobes + total_finds) / (double)total_finds);
  printf("{reprobe_factor : %.4f}\n",
         (all_total_reprobes + total_finds) / (double)total_finds);

  // printf("{Avg cycles: %.4f}\n", (double)total_find_cycles/
  // (double)config.num_threads);

#endif

  ht_fill = ht_fill / config.num_threads;
  ht_capacity = ht_capacity / config.num_threads;
  uint64_t find_mops = 0, insert_mops = 0;

  uint64_t cycles_per_insert = 0;
  uint64_t cycles_per_find = 0;

  if (total_finds > 0) {
    cycles_per_find = total_find_cycles / total_finds;
  }

  if (total_inserts > 0) {
    cycles_per_insert = total_insert_cycles / total_inserts;
  }

  uint64_t num_threads = config.num_threads;

  avg_find_duration = total_find_cycles / num_threads;
  avg_insert_duration = total_insert_cycles / num_threads;

  find_mops = ((CPUFREQ_MHZ * total_finds) / avg_find_duration);
  insert_mops = ((CPUFREQ_MHZ * total_inserts) / avg_insert_duration);

  if (config.mode == HASHJOIN) {
    if (config.test) {
      uint64_t join_answer = calculate_expected_join_size(
          config.relation_r_size, config.relation_s_size);

      if (total_found != join_answer) {
        PLOGE.printf("hashjoin failed, solution: %lu answer: %lu", join_answer,
                     total_found);
      } else {
        PLOGI.printf("hashjoin passed, solution: %lu answer: %lu", join_answer,
                     total_found);
      }
    }

    uint64_t sum_op = total_finds + total_inserts;
    uint64_t join_cycles = avg_find_duration + avg_insert_duration;
    uint64_t throughput = ((CPUFREQ_MHZ * sum_op) / join_cycles);
    PLOGI.printf(
        "\n"
        "============================================\n"
        "build_phrase_mops : %lu, cycle_per_op : %lu\n"
        "probe_phrase_mops : %lu, cycle_per_op : %lu\n"
        "joined : %lu out of %lu, %.2f%%\n"
        "fill : %lu out of %lu, %.2f%%\n"
        "throughput_mops : %lu, ops: %lu, duration: %lu\n"
        "============================================\n",
        insert_mops, cycles_per_insert, find_mops, cycles_per_find, total_found,
        config.relation_s_size, total_found * 100.0 / config.relation_s_size,
        ht_fill, ht_capacity, ht_fill * 100.0 / ht_capacity, throughput, sum_op, join_cycles);
  } else {
    uint64_t expected_found = config.ht_size * config.ht_fill / 100 * config.read_factor;
    PLOGI.printf(
        "\n"
        "============================================\n"
        "found : %lu, expected_found : %lu\n"
        "global_find_cycle : %lu, find_ops : %lu\n"
        "global_insert_cycle : %lu, insert_ops : %lu\n"
        "set_cycles : %lu, get_cycles : %lu, "
        "set_mops : %lu, get_mops : %lu\n"
        "============================================\n",
        total_found, expected_found, avg_find_duration,
        total_finds, avg_insert_duration, total_inserts, cycles_per_insert,
        cycles_per_find, insert_mops, find_mops);
  }
#ifdef COMMENT_OUT
  printf("===============================================================\n");

  if (config.insert_factor > 0) {
    uint64_t op_per_iter = total_inserts / config.insert_factor;

    uint64_t total_insert_duration_over_all_run = 0;
    for (int i = 0; i < config.insert_factor; i++) {
      total_insert_duration_over_all_run += g_insert_durations[i];
    }
    printf(
        "average_insert_task_duration : %lu, total_insert_tas_duration : %lu\n",
        total_insert_duration_over_all_run / config.insert_factor,
        total_insert_duration_over_all_run);

    printf("insert_ops : %lu, insert_ops_per_run : %lu\n", total_inserts,
           op_per_iter);

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
    uint64_t total_find_duration_over_all_run = 0;
    for (int i = 0; i < config.read_factor; i++) {
      total_find_duration_over_all_run += g_find_durations[i];
    }
    printf("average_find_task_duration : %lu, total_find_duration : %lu\n",
           total_find_duration_over_all_run / config.read_factor,
           total_find_duration_over_all_run);

    printf("find_ops : %lu, find_ops_per_run : %lu\n", total_finds,
           op_per_iter);

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
#endif

#ifdef WITH_PCM
  if (config.read_factor > 0) {
    double avg_bw = 0;

    for (int i = 0; i < config.read_factor; i++) {
      // printf("iter: %d, bw:%.3f\n", i, g_find_bw[i]);
      avg_bw += g_find_bw[i];
    }
    avg_bw = avg_bw / config.read_factor;
    printf("{ find_avg_bw : %.3f}\n", avg_bw);
  }
#endif
}

BaseHashTable *init_ht(const uint64_t sz, uint8_t id) {
  BaseHashTable *kmer_ht = NULL;

  // Create hash table
  switch (config.ht_type) {
#ifdef PART_ID
    case MULTI_HT:
      kmer_ht = new MultiHashTable<KVType, ItemQueue>(sz);
      break;
    case PARTITIONED_HT:
      kmer_ht = new PartitionedHashStore<KVType, ItemQueue>(sz, id);
      break;
#endif
    case CAS23HTPP:
#ifdef CAS_NO_ABSTRACT
      PLOGE.printf("cas 23 doesn't support no abstract methods feature");
      abort();
#endif
      kmer_ht = new CAS23HashTable<KVType, ItemQueue>(sz);
      break;
#ifdef GROWT
    case GROWHT:
      kmer_ht = new GrowtHashTable(sz);
      break;
    case TBB_HT:
      kmer_ht = new TBB_HashTable(sz);
      break;
#endif
    case CASHTPP:
      kmer_ht =
          new CASHashTable<KVType, ItemQueue>(sz, config.find_queue_sz, id);
      break;
    case ARRAY_HT:
      kmer_ht = new ArrayHashTable<Value, ItemQueue>(sz);
      break;
#ifdef CLHT
    case CLHT_HT:
      // clht_create already allocates mem
      kmer_ht = new CLHT_HashTable(sz);
      break;
#endif
    default:
      PLOG_FATAL.printf("HT type not implemented");
      exit(-1);
      break;
  }

  return kmer_ht;
}
}  // namespace kmercounter
