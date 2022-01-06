#include <iostream>
#include <string_view>
#include <memory>
#include <unordered_set>
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
const char SIMPLE_BATCH_QUERY_TEST[] = "Simple batch query";
constexpr const char* TEST_FNS [] {
  NO_PREFETCH_TEST,
  SIMPLE_BATCH_QUERY_TEST,
};
// Hashtable names.
const char PARTITIONED_HT[] = "Partitioned HT";
const char CAS_HT[] = "CAS HT";
constexpr const char* HTS [] {
  PARTITIONED_HT,
  CAS_HT,
};


/// Correctness test for insertion and lookup without prefetch.
/// In other words, no queue is used.
void no_prefetch_test(BaseHashTable* ht) {
  std::cerr << "[TEST] Synchronous\n";

  const auto size = absl::GetFlag(FLAGS_test_size);
  
  for (std::uint64_t i{}; i < size; i++) {
    ItemQueue data;
    data.key = i;
    data.value = i * i;
    ht->insert_noprefetch(&data);
  }

  for (std::uint64_t i{}; i < size; i++) {
    auto ptr = (KVType*)ht->find_noprefetch(&i);
    EXPECT_FALSE(ptr->is_empty()) << "Cannot find " << i;
    EXPECT_EQ(ptr->get_value(), i * i) << "Invalid value for key " << i;
  }
}

void simple_batch_query_test(BaseHashTable* ht) {
  // Insertion.
  std::array<Keys, 2> keys{Keys{1, 128}, Keys{2, 256}};
  KeyPairs keypairs{2, keys.data()};
  ht->insert_batch(keypairs); 
  ht->flush_insert_queue();

  // Look up.
  std::array<Values, HT_TESTS_BATCH_LENGTH> values{};
  ValuePairs valuepairs{0, values.data()};
  ht->find_batch(keypairs, valuepairs);
  ht->flush_find_queue(valuepairs);

  // Check for correctness.
  EXPECT_EQ(valuepairs.first, 2);
  EXPECT_EQ(valuepairs.second[0].id, 1);
  EXPECT_EQ(valuepairs.second[0].value, 128);
  EXPECT_EQ(valuepairs.second[1].id, 2);
  EXPECT_EQ(valuepairs.second[1].value, 256);
}

class CombinationsTest :
    public ::testing::TestWithParam<std::tuple<const char*, const char*>> {};

TEST_P(CombinationsTest, TestFnAndHashtableCombination) {
  // Get input.
  const auto [test_name, ht_name] = GetParam();
  const auto hashtable_size = absl::GetFlag(FLAGS_hashtable_size);
  PLOG_INFO << "Running test <" << test_name << " with hashtable <" << ht_name << ">";

  // Get test function.
  const auto test_fn = [test_name]() -> void (*)(kmercounter::BaseHashTable*) {
    if (test_name == NO_PREFETCH_TEST)
      return kmercounter::no_prefetch_test;
    else if (test_name == SIMPLE_BATCH_QUERY_TEST)
      return kmercounter::simple_batch_query_test;
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

