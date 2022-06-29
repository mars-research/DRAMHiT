#include <absl/flags/flag.h>
#include <absl/flags/parse.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <plog/Log.h>

#include <iostream>
#include <memory>
#include <span>
#include <string_view>
#include <unordered_map>

#include "hashtable.h"
#include "hashtables/batch_inserter.hpp"
#include "hashtables/cas_kht.hpp"
#include "hashtables/simple_kht.hpp"
#include "test_lib.hpp"

namespace kmercounter {
namespace {

using testing::UnorderedElementsAre;

// Hashtable names.
const char PARTITIONED_HT[] = "Partitioned HT";
const char CAS_HT[] = "CAS HT";
constexpr const char* HTS[]{
    PARTITIONED_HT,
    CAS_HT,
};

class HashtableTest : public ::testing::TestWithParam<const char*> {
 protected:
  void SetUp() override {
    const auto ht_name = GetParam();
    const auto hashtable_size = absl::GetFlag(FLAGS_hashtable_size);
    // Get hashtable.
    ht_ = std::unique_ptr<kmercounter::BaseHashTable>(
        [ht_name, hashtable_size]() -> kmercounter::BaseHashTable* {
          if (ht_name == PARTITIONED_HT)
            return new kmercounter::PartitionedHashStore<
                kmercounter::Item, kmercounter::ItemQueue>{hashtable_size, 0};
          else if (ht_name == CAS_HT)
            return new kmercounter::CASHashTable<kmercounter::Item,
                                                 kmercounter::ItemQueue>{
                hashtable_size};
          else
            return nullptr;
        }());
    ASSERT_NE(ht_, nullptr) << "Invalid hashtable type: " << ht_name;
    inserter_ = HTBatchInserter<>(ht_.get());
  }

  std::unique_ptr<kmercounter::BaseHashTable> ht_;
  HTBatchInserter<> inserter_;
};

/// Correctness test for insertion and lookup without prefetch.
/// In other words, no queue is used.
TEST_P(HashtableTest, NO_PREFETCH_TEST) {
  // Disable for now because of a bug.
  // https://github.com/mars-research/kvstore/issues/16
  GTEST_SKIP();

  const auto test_size = absl::GetFlag(FLAGS_test_size);
  for (uint64_t i = 0; i < test_size; i++) {
    ItemQueue data;
    data.key = i;
    data.value = i * i;
    ht_->insert_noprefetch(&data);
  }

  for (uint64_t i = 0; i < test_size; i++) {
    auto ptr = (Item*)ht_->find_noprefetch(&i);
    EXPECT_FALSE(ptr->is_empty()) << "Cannot find " << i;
    EXPECT_EQ(ptr->get_value(), i * i) << "Invalid value for key " << i;
  }
}

TEST_P(HashtableTest, SIMPLE_BATCH_INSERT_TEST) {
  // Insertion.
  inserter_.insert(12, 128);
  inserter_.insert(23, 256);
  inserter_.flush();

  // Look up.
  std::array<InsertFindArgument, 2> arguments{
      InsertFindArgument{key : 12, id : 123},
      InsertFindArgument{key : 23, id : 321}};
  std::array<FindResult, HT_TESTS_BATCH_LENGTH> results{};
  ValuePairs valuepairs{0, results.data()};
  ht_->find_batch(arguments, valuepairs);
  ht_->flush_find_queue(valuepairs);

  // Check for correctness.
  ASSERT_EQ(valuepairs.first, 2);
  constexpr auto expected_results =
      std::to_array({FindResult(123, 128), FindResult(321, 256)});
  ASSERT_THAT(expected_results,
              testing::UnorderedElementsAreArray(valuepairs.second, 2));
}

TEST_P(HashtableTest, SIMPLE_BATCH_UPDATE_TEST) {
  // Insertion.
  inserter_.insert(12, 128);
  inserter_.insert(23, 256);
  inserter_.flush();

  // Update.
  inserter_.insert(12, 1025);
  inserter_.insert(23, 4097);
  inserter_.flush();

  // Look up.
  std::array<InsertFindArgument, 2> arguments{
      InsertFindArgument{key : 12, id : 123},
      InsertFindArgument{key : 23, id : 321}};
  std::array<FindResult, HT_TESTS_BATCH_LENGTH> values{};
  ValuePairs valuepairs{0, values.data()};
  ht_->find_batch(arguments, valuepairs);
  ht_->flush_find_queue(valuepairs);

  // Check for correctness.
  EXPECT_EQ(valuepairs.first, 2);
  EXPECT_EQ(valuepairs.second[0].id, 123);
  EXPECT_EQ(valuepairs.second[0].value, 1025);
  EXPECT_EQ(valuepairs.second[1].id, 321);
  EXPECT_EQ(valuepairs.second[1].value, 4097);
}

TEST_P(HashtableTest, BATCH_QUERY_TEST) {
  // A known correct implementation of hashmap.
  std::unordered_map<uint64_t, uint64_t> reference_map;

  // Insert test data.
  uint64_t k = 0;
  InsertFindArgument arguments[HT_TESTS_FIND_BATCH_LENGTH] = {0};
  uint64_t test_size = absl::GetFlag(FLAGS_test_size);
  for (uint64_t i = 0; i < test_size; i++) {
    const uint64_t key = i;
    const uint64_t value = i * i;
    const uint64_t id = 2 * i;
    inserter_.insert(key, value);
    reference_map[value] = id;
  }
  inserter_.flush();

  // Helper function for checking the result of the batch finds.
  auto check_valuepairs = [&reference_map](const ValuePairs& vp) {
    for (uint32_t i = 0; i < vp.first; i++) {
      const FindResult& value = vp.second[i];
      auto iter = reference_map.find(value.value);
      EXPECT_NE(iter, reference_map.end())
          << "Found unexpected value: " << value;
      if (iter != reference_map.end()) {
        EXPECT_EQ(iter->second, value.id) << "Found unexpected id: " << value;
        reference_map.erase(iter);
      }
    }
  };

  // Finds.
  FindResult values[HT_TESTS_FIND_BATCH_LENGTH] = {};
  for (uint64_t i = 0; i < test_size; i++) {
    arguments[k].key = i;
    arguments[k].id = 2 * i;
    if (++k == HT_TESTS_BATCH_LENGTH) {
      ValuePairs valuepairs{0, values};
      ht_->find_batch(InsertFindArguments(arguments), valuepairs);
      check_valuepairs(valuepairs);
      k = 0;
    }
  }
  if (k != 0) {
    ValuePairs valuepairs{0, values};
    ht_->find_batch(InsertFindArguments(arguments, k), valuepairs);
    k = 0;
    check_valuepairs(valuepairs);
  }

  // Flush the rest of the queue.
  ValuePairs valuepairs{0, values};
  do {
    valuepairs.first = 0;
    ht_->flush_find_queue(valuepairs);
    check_valuepairs(valuepairs);
  } while (valuepairs.first);

  // Make sure we found all of them.
  for (const auto pair : reference_map) {
    EXPECT_TRUE(false) << "Couldn't find talue <" << pair.first << "> id <"
                       << pair.second << "> pair";
  }
}

INSTANTIATE_TEST_CASE_P(TestAllHashtables, HashtableTest,
                        ::testing::ValuesIn(HTS));

}  // namespace
}  // namespace kmercounter
