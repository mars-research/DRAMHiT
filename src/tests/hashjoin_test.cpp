/// This file implements Hash Join.
// Relevant resources:
// * Hash join: https://dev.mysql.com/worklog/task/?id=2241
// * Add support for hash outer, anti and semi join: https://dev.mysql.com/worklog/task/?id=13377
// * Optimize hash table in hash join: https://dev.mysql.com/worklog/task/?id=13459

#include <optional>
#include <iostream>
#include <plog/Log.h>
#include <unordered_set>
#include <fstream>
#include <atomic>

#include "types.hpp"
#include "base_kht.hpp"
#include "input_reader/csv.hpp"
#include "hashtables/kvtypes.hpp"
#include "sync.h"

namespace kmercounter {

// Only primary-foreign key join is supported.
void part_join_partsupp(Shard *sh, Configuration *config, BaseHashTable *ht, std::atomic_uint8_t* thread_synker) {
  input_reader::PartitionedCsvReader t1("part.tbl", sh->shard_idx, config->num_threads, "|");
  input_reader::PartitionedCsvReader t2("partsupp.tbl", sh->shard_idx, config->num_threads, "|");
  PLOG_INFO << "Shard " << (int)sh->shard_idx << "/" << config->num_threads << " t1 " << t1.size() << " t2 " << t2.size(); 

  // Build hashtable from t1.
  uint64_t k = 0;
  __attribute__((aligned(64))) Keys keys[HT_TESTS_FIND_BATCH_LENGTH] = {0};
  const auto t1_start = RDTSC_START();
  for (std::optional<input_reader::Row*> pair; (pair = t1.next());) {
    const auto& [key, row] = **pair;
    keys[k].key = key;
    keys[k].id = (uint64_t)row.data();
    PLOG_INFO << "Left " << keys[k] << (char*)keys[k].id;
    if (++k == HT_TESTS_BATCH_LENGTH) {
      KeyPairs kp = std::make_pair(k, keys);
      ht->insert_batch(kp);
      k = 0;
    }
  }
  if (k != 0) {
    KeyPairs kp = std::make_pair(k, keys);
    ht->insert_batch(kp);
    k = 0;
  }
  ht->flush_insert_queue();

  {
    const auto duration = RDTSCP() - t1_start;
    std::cerr << "Thread " << (int)sh->shard_idx << " takes " << duration  << " to insert " << t1.size() << ". Avg " << duration / t1.size()  << std::endl;
  }

  // Make sure insertions is finished before probing.
  thread_synker->fetch_add(1, std::memory_order_seq_cst);
  while (thread_synker->load(std::memory_order_seq_cst) < config->num_threads) {
    // spin
  } 

  // Helper function for checking the result of the batch finds.
  // std::ofstream output_file(std::to_string((int)sh->shard_idx) + "_join.tbl");
  const auto t2_rows = t2.rows();
  const auto t2_start = RDTSC_START();
  auto join_rows = [&t2_rows] (const ValuePairs& vp) {
    PLOG_DEBUG << "Found " << vp.first << " keys";
    for (uint32_t i = 0; i < vp.first; i++) {
      const Values& value = vp.second[i];
      PLOG_WARNING << "We found " << value;
      const char* left_row = (char*)value.value;
      const char* right_row = t2_rows[value.id].second.c_str();
      PLOG_INFO << "Left row " << left_row;
      PLOG_INFO << "Right row " << right_row;
      // output_file << left_row << "|" << right_row << "\n";
    }
  };

  // Probe.
  __attribute__((aligned(64))) Values values[HT_TESTS_FIND_BATCH_LENGTH] = {0};
  const auto t2_size = t2_rows.size();
  for (size_t i = 0; i < t2_size; i++) {
    const auto& [key, row] = t2_rows[i];
    keys[k].key = key;
    keys[k].id = i;
    // keys[k].part_id = (uint64_t)row.c_str();
    PLOG_INFO << "Right " << keys[k];
    if (++k == HT_TESTS_BATCH_LENGTH) {
      KeyPairs kp = std::make_pair(HT_TESTS_BATCH_LENGTH, keys);
      ValuePairs valuepairs{0, values};
      ht->find_batch(kp, valuepairs);
      join_rows(valuepairs);
      k = 0;
    }
  }
  if (k != 0) {
    KeyPairs kp = std::make_pair(k, keys);
    ValuePairs valuepairs{0, values};
    ht->find_batch(kp, valuepairs);
    k = 0;
    join_rows(valuepairs);
  }

  // Flush the rest of the queue.
  ValuePairs valuepairs{0, values};
  do {
    valuepairs.first = 0;
    ht->flush_find_queue(valuepairs);
    join_rows(valuepairs);
  } while (valuepairs.first);

  {
    const auto duration = RDTSCP() - t2_start;
    std::cerr << "Thread " << (int)sh->shard_idx << " takes " << duration << " to join " << t1.size() << ". Avg " << duration / t1.size() << std::endl;
  }

  {
    const auto duration = RDTSCP() - t1_start;
    std::cerr << "Thread " << (int)sh->shard_idx << " takes " << duration << " to output " << t1.size() << ". Avg " << duration / t1.size() << std::endl;
  }

}

}  // namespace kmercounter
