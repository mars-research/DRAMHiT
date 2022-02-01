#include <iostream>
#include <string_view>
#include <memory>
#include <unordered_map>
#include <gtest/gtest.h>
#include <absl/flags/flag.h>
#include <absl/flags/parse.h>
#include <plog/Log.h>

#include "test_lib.hpp"
#include "hashtable.h"
#include "hashtables/cas_kht.hpp"
#include "hashtables/simple_kht.hpp"

namespace kmercounter {
namespace {
// Test names.
const char NO_PREFETCH_TEST[] = "No prefetch";
const char SIMPLE_BATCH_INSERT_TEST[] = "Simple batch insert";
const char SIMPLE_BATCH_UPDATE_TEST[] = "Simple batch update";
const char BATCH_QUERY_TEST[] = "Batch query";
constexpr const char* TEST_FNS [] {
  // Disable for now because of a bug.
  // https://github.com/mars-research/kvstore/issues/16
  // NO_PREFETCH_TEST,
  SIMPLE_BATCH_INSERT_TEST,
  SIMPLE_BATCH_UPDATE_TEST,
  BATCH_QUERY_TEST,
};
// Hashtable names.
const char PARTITIONED_HT[] = "Partitioned HT";
const char CAS_HT[] = "CAS HT";
constexpr const char* HTS [] {
  // PARTITIONED_HT,
  CAS_HT,
};


/// Correctness test for insertion and lookup without prefetch.
/// In other words, no queue is used.
void no_prefetch_test(BaseHashTable* ht) {
  const auto test_size = absl::GetFlag(FLAGS_test_size);
  
  for (uint64_t i = 1; i <= test_size; i++) {
    ItemQueue data;
    data.key = i;
    data.value = i * i;
    ht->insert_noprefetch(&data);
  }

  for (uint64_t i = 1; i <= test_size; i++) {
    auto ptr = (Item*)ht->find_noprefetch(&i);
    EXPECT_FALSE(ptr->is_empty()) << "Cannot find " << i;
    EXPECT_EQ(ptr->get_value(), i * i) << "Invalid value for key " << i;
  }
}

void simple_batch_insert_test(BaseHashTable* ht) {
  // Insertion.
  std::array<Keys, 2> keys{Keys{key: 12, value: 128}, Keys{key: 23, value: 256}};
  KeyPairs keypairs{2, keys.data()};
  ht->insert_batch(keypairs); 
  ht->flush_insert_queue();

  // Look up.
  keys[0].id = 123;
  keys[1].id = 321;
  std::array<Values, HT_TESTS_BATCH_LENGTH> values{};
  ValuePairs valuepairs{0, values.data()};
  ht->find_batch(keypairs, valuepairs);
  ht->flush_find_queue(valuepairs);

  // Check for correctness.
  EXPECT_EQ(valuepairs.first, 2);
  EXPECT_EQ(valuepairs.second[0].id, 123);
  EXPECT_EQ(valuepairs.second[0].value, 128);
  EXPECT_EQ(valuepairs.second[1].id, 321);
  EXPECT_EQ(valuepairs.second[1].value, 256);
}

void simple_batch_update_test(BaseHashTable* ht) {
  // Insertion.
  std::array<Keys, 2> keys{Keys{key: 12, value: 128}, Keys{key: 23, value: 256}};
  KeyPairs keypairs{2, keys.data()};
  ht->insert_batch(keypairs); 

  // Update.
  keys[0].value = 1025;
  keys[1].value = 4097;
  ht->insert_batch(keypairs); 
  ht->flush_insert_queue();

  // Look up.
  keys[0].id = 123;
  keys[1].id = 321;
  std::array<Values, HT_TESTS_BATCH_LENGTH> values{};
  ValuePairs valuepairs{0, values.data()};
  ht->find_batch(keypairs, valuepairs);
  ht->flush_find_queue(valuepairs);

  // Check for correctness.
  EXPECT_EQ(valuepairs.first, 2);
  EXPECT_EQ(valuepairs.second[0].id, 123);
  EXPECT_EQ(valuepairs.second[0].value, 1025);
  EXPECT_EQ(valuepairs.second[1].id, 321);
  EXPECT_EQ(valuepairs.second[1].value, 4097);
}

void batch_query_test(BaseHashTable* ht) {
  // A known correct implementation of hashmap.
  std::unordered_map<uint64_t, uint64_t> reference_map;

  // Insert test data.
  uint64_t k = 0;
  Keys keys[HT_TESTS_FIND_BATCH_LENGTH] = {0};
  uint64_t test_size = absl::GetFlag(FLAGS_test_size);
  for (uint64_t i = 1; i <= test_size; i++) {
    const uint64_t key = i;
    const uint64_t value = i * i;
    const uint64_t id = 2 * i;
    keys[k].key = key;
    keys[k].value = value;
    reference_map[value] = id;
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

  // Helper function for checking the result of the batch finds.
  auto check_valuepairs = [&reference_map] (const ValuePairs& vp) {
    for (uint32_t i = 0; i < vp.first; i++) {
      const Values& value = vp.second[i];
      auto iter = reference_map.find(value.value);
      EXPECT_NE(iter, reference_map.end()) << "Found unexpected value: " << value;
      if (iter != reference_map.end()) {
        EXPECT_EQ(iter->second, value.id) << "Found unexpected id: " << value;
        reference_map.erase(iter);
      }
    }
  };

  // Finds.
  Values values[HT_TESTS_FIND_BATCH_LENGTH] = {0};
  for (uint64_t i = 1; i <= test_size; i++) {
    keys[k].key = i;
    keys[k].id = 2 * i;
    keys[k].part_id = 3 * i;
    if (++k == HT_TESTS_BATCH_LENGTH) {
      KeyPairs kp = std::make_pair(k, keys);
      ValuePairs valuepairs{0, values};
      ht->find_batch(kp, valuepairs);
      check_valuepairs(valuepairs);
      k = 0;
    }
  }
  if (k != 0) {
    KeyPairs kp = std::make_pair(k, keys);
    ValuePairs valuepairs{0, values};
    ht->find_batch(kp, valuepairs);
    k = 0;
    check_valuepairs(valuepairs);
  }

  // Flush the rest of the queue.
  ValuePairs valuepairs{0, values};
  do {
    valuepairs.first = 0;
    ht->flush_find_queue(valuepairs);
    check_valuepairs(valuepairs);
  } while (valuepairs.first);

  // Make sure we found all of them.
  for (const auto pair : reference_map) {
    EXPECT_TRUE(false) << "Couldn't find talue <" << pair.first << "> id <" << pair.second << "> pair";
  }
}
  

class CombinationsTest :
    public ::testing::TestWithParam<std::tuple<const char*, const char*>> {};

TEST_P(CombinationsTest, TestFnAndHashtableCombination) {
  // Get input.
  const auto [test_name, ht_name] = GetParam();
  const auto hashtable_size = absl::GetFlag(FLAGS_hashtable_size);
  PLOG_INFO << "Running test <" << test_name << "> with hashtable <" << ht_name << ">";

  // Get test function.
  const auto test_fn = [test_name]() -> void (*)(kmercounter::BaseHashTable*) {
    if (test_name == NO_PREFETCH_TEST)
      return kmercounter::no_prefetch_test;
    else if (test_name == SIMPLE_BATCH_INSERT_TEST)
      return kmercounter::simple_batch_insert_test;    
    else if (test_name == SIMPLE_BATCH_UPDATE_TEST)
      return kmercounter::simple_batch_update_test;
    else if (test_name == BATCH_QUERY_TEST)
      return kmercounter::batch_query_test;
    else
      return nullptr;
  }();
  ASSERT_NE(test_fn, nullptr) << "Invalid test type: " << test_name;

  // Get hashtable.
  const auto ht = std::unique_ptr<kmercounter::BaseHashTable>([ht_name, hashtable_size]() -> kmercounter::BaseHashTable* {
    if (ht_name == PARTITIONED_HT)
      return new kmercounter::PartitionedHashStore<kmercounter::Item,
                                                   kmercounter::ItemQueue>{
          hashtable_size, 0};
    else if (ht_name == CAS_HT)
      return new kmercounter::CASHashTable<kmercounter::Item,
                                           kmercounter::ItemQueue>{
          hashtable_size};
    else
      return nullptr;
  }());
  ASSERT_NE(ht, nullptr) << "Invalid hashtable type: " << ht_name;

  // Run test and clean up.
  if (ht_name == PARTITIONED_HT && test_name == NO_PREFETCH_TEST) {
    PLOG_INFO << "no_prefetch is not implemented in PartitionedHT. Skipping.";
  }
  ASSERT_NO_THROW(test_fn(ht.get()));
}

INSTANTIATE_TEST_CASE_P(TestAllCombinations,
                        CombinationsTest,
                        ::testing::Combine(
                          ::testing::ValuesIn(TEST_FNS),
                          ::testing::ValuesIn(HTS)
                        )
);

}  // namespace
}  // namespace kmercounter

