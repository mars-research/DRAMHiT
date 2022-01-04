#include <iostream>
#include <string_view>
#include <memory>
#include <unordered_set>
#include <gtest/gtest.h>
#include <absl/flags/flag.h>
#include <absl/flags/parse.h>

#include "hashtable.h"
#include "hashtables/cas_kht.hpp"
#include "hashtables/simple_kht.hpp"
#include "logger.h"

/*
  - Fill depends on the *distinct* key/id pairs
  - find_batch() returns pairs of (id, count), where count is the number of
  times a particular id occurs
    - independent of key?
*/

ABSL_FLAG(int, hashtable_size, 1ull << 26,
          "size of hashtable.");
ABSL_FLAG(int, test_size, 1ull << 12,
          "size of test(number of insertions/lookup).");

namespace kmercounter {
namespace {
// Test names.
const char NO_PREFETCH_TEST[] = "No prefetch";
const char ASYNCHRONOUS_TEST[] = "Asynchronous";
const char FILL_SYNC_TEST[] = "Fill Sync";
const char UNIT_FILL_TEST[] = "Unit Fill";
const char OFF_BY_ONE_TEST[] = "Off By One";
constexpr const char* TEST_FNS [] {
  NO_PREFETCH_TEST,
  // ASYNCHRONOUS_TEST,
  // FILL_SYNC_TEST,
  // UNIT_FILL_TEST,
  OFF_BY_ONE_TEST,
};
// Hashtable names.
const char PARTITIONED_CAS_HT[] = "Partitioned CAS";
const char CAS_HT[] = "CAS";
constexpr const char* HTS [] {
  PARTITIONED_CAS_HT,
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

// Test for presence of an off-by-one error in synchronous use
void single_insert_test(BaseHashTable* ht) {
  Keys pair{1, 128};
  KeyPairs keys{1ull, &pair};
  ht->insert_batch(keys);
  ht->flush_insert_queue();
  std::cerr << "[TEST] Fill was: " << ht->get_fill() << "\n";
  ASSERT_EQ(ht->get_fill(), 1);
}

// Test demonstrating the nonintuitive difference in the interpretation of batch
// lengths between find/insert
// NOTE: also noted a very strange use of the value field
void off_by_one_test(BaseHashTable* ht) {
  
  std::array<Keys, 2> keys{Keys{1, 128}, Keys{2, 256}};
  KeyPairs keypairs{2, keys.data()};
  ht->insert_batch(keypairs); 
  ht->flush_insert_queue();


  std::array<Values, HT_TESTS_BATCH_LENGTH> values{};
  ValuePairs valuepairs{0, values.data()};
  
  ht->find_batch(keypairs, valuepairs);
  
  ht->flush_find_queue(valuepairs);
  std::cerr << "[TEST] Found " << valuepairs.first << ": "
            << valuepairs.second[0] << std::endl;

  // Note that we only insert 256 *once*, so the "value" should be 1
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

  // Get test function.
  const auto test_fn = [test_name]() -> void (*)(kmercounter::BaseHashTable*) {
    if (test_name == NO_PREFETCH_TEST)
      return kmercounter::no_prefetch_test;
    else if (test_name == UNIT_FILL_TEST)
      return kmercounter::single_insert_test;
    else if (test_name == OFF_BY_ONE_TEST)
      return kmercounter::off_by_one_test;
    else
      return nullptr;
  }();
  ASSERT_NE(test_fn, nullptr) << "Invalid test type: " << test_name;

  // Get hashtable.
  const auto ht = std::unique_ptr<kmercounter::BaseHashTable>([ht_name, hashtable_size]() -> kmercounter::BaseHashTable* {
    if (ht_name == PARTITIONED_CAS_HT)
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

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  absl::ParseCommandLine(argc, argv);
  return RUN_ALL_TESTS();
}