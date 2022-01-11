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

#include "types.hpp"
#include "base_kht.hpp"
#include "input_reader/csv.hpp"
#include "hashtables/kvtypes.hpp"

namespace kmercounter {

// Only primary-foreign key join is supported.
void part_join_partsupp(BaseHashTable *ht) {
  input_reader::CsvReader t1("part.tbl", "|");
  input_reader::CsvReader t2("partsupp.tbl", "|");

  // Build hashtable from t1.
  uint64_t k = 0;
  __attribute__((aligned(64))) Keys keys[HT_TESTS_FIND_BATCH_LENGTH] = {0};
  for (std::optional<input_reader::Row*> pair; pair = t1.next();) {
    const auto& [key, row] = **pair;
    keys[k].key = key;
    keys[k].id = (uint64_t)row.data();
    PLOG_DEBUG << "Left " << keys[k] << (char*)keys[k].id;
    if (++k == HT_TESTS_BATCH_LENGTH) {
      KeyPairs kp = std::make_pair(HT_TESTS_BATCH_LENGTH, keys);
      ht->insert_batch(kp);
      k = 0;
    }
  }
  ht->flush_insert_queue();

  // Helper function for checking the result of the batch finds.
  std::ofstream output_file("join.tbl");
  auto join_rows = [&output_file] (const ValuePairs& vp) {
    PLOG_DEBUG << "Found " << vp.first << " keys";
    for (uint32_t i = 0; i < vp.first; i++) {
      const Values& value = vp.second[i];
      PLOG_DEBUG << "We found " << value;
      const char* left_row = (char*)value.value;
      const char* right_row = (char*)value.id;
      output_file << left_row << "|" << right_row << std::endl;
      PLOG_DEBUG << "Joined " << left_row << "|" << right_row;
    }
  };

  // Probe.
  __attribute__((aligned(64))) Values values[HT_TESTS_FIND_BATCH_LENGTH] = {0};
  for (std::optional<input_reader::Row*> pair; pair = t2.next();) {
    const auto& [key, row] = **pair;
    keys[k].key = key;
    keys[k].id = (uint64_t)row.c_str();
    PLOG_DEBUG << "Right " << keys[k];
    if (++k == HT_TESTS_BATCH_LENGTH) {
      KeyPairs kp = std::make_pair(HT_TESTS_BATCH_LENGTH, keys);
      ValuePairs valuepairs{0, values};
      ht->find_batch(kp, valuepairs);
      join_rows(valuepairs);
      k = 0;
    }
  }

  // Flush the rest of the queue.
  ValuePairs valuepairs{0, values};
  do {
    valuepairs.first = 0;
    ht->flush_find_queue(valuepairs);
    join_rows(valuepairs);
  } while (valuepairs.first);
}

}  // namespace kmercounter