/// This file implements Hash Join.
// Relevant resources:
// * Hash join: https://dev.mysql.com/worklog/task/?id=2241
// * Add support for hash outer, anti and semi join: https://dev.mysql.com/worklog/task/?id=13377
// * Optimize hash table in hash join: https://dev.mysql.com/worklog/task/?id=13459

#include <optional>
#include <iostream>
#include <plog/Log.h>
#include <unordered_set>

#include "types.hpp"
#include "base_kht.hpp"
#include "input_reader/csv.hpp"
#include "hashtables/kvtypes.hpp"

namespace kmercounter {

// Only primary-foreign key join is supported.
void part_join_partsupp(BaseHashTable *kt) {
  input_reader::CsvReader t1("part.tbl", "|");
  input_reader::CsvReader t2("partsupp.tbl", "|");

  // Build hashtable from t1.
  uint64_t k = 0;
  __attribute__((aligned(64))) Keys batch[HT_TESTS_FIND_BATCH_LENGTH] = {0};
  for (std::optional<uint64_t> value; value = t1.next();) {
    batch[k].key = *value;
    if (++k == HT_TESTS_BATCH_LENGTH) {
      KeyPairs kp = std::make_pair(HT_TESTS_BATCH_LENGTH, &batch[0]);
      kt->insert_batch(kp);
      k = 0;
    }
  }
  kt->flush_insert_queue();

  // Probe hashtable from t2.
  uint64_t counter = 0;
  for (std::optional<uint64_t> value; value = t2.next();) {
    auto ptr = (KVType*)kt->find_noprefetch(&*value);
    PLOG_WARNING_IF(ptr->is_empty()) << "Cannot find " << *value;
    counter += !ptr->is_empty();
  }
  PLOG_INFO << "Number of output rows: " << counter;  // // Build hashtable from t1.


  // // Build hashtable from t1.
  // std::unordered_set<uint64_t> m;
  // for (std::optional<uint64_t> value; value = t1.next();) {
  //   m.insert(*value);
  // }

  // // Probe hashtable from t2.
  // uint64_t counter = 0;
  // for (std::optional<uint64_t> value; value = t2.next();) {
  //   const auto found = m.contains(*value);
  //   PLOG_WARNING_IF(!found) << "Cannot find " << *value;
  //   counter += found;
  // }
  // PLOG_INFO << "Number of output rows: " << counter;
}

}  // namespace kmercounter
