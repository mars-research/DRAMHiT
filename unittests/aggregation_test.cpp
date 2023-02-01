#include <absl/flags/flag.h>
#include <absl/flags/parse.h>
#include <gtest/gtest.h>

#include <iostream>
#include <memory>
#include <string_view>

#include "hashtables/cas_kht.hpp"
#include "hashtables/simple_kht.hpp"
#include "test_lib.hpp"

/*
  - Fill depends on the *distinct* key/id pairs
  - find_batch() returns pairs of (id, count), where count is the number of
  times a particular id occurs
    - independent of key?
*/

namespace kmercounter {
namespace {
// Hashtable names.
const char PARTITIONED_HT[] = "Partitioned HT";
const char CAS_HT[] = "CAS";
constexpr const char* HTS[]{
    PARTITIONED_HT,
    CAS_HT,
};

class AggregationTest : public ::testing::TestWithParam<const char*> {
 protected:
  void SetUp() override {
    const auto ht_name = GetParam();
    const auto hashtable_size = absl::GetFlag(FLAGS_hashtable_size);
    // Get hashtable.
    ht_ = std::unique_ptr<kmercounter::BaseHashTable>(
        [ht_name, hashtable_size]() -> kmercounter::BaseHashTable* {
          if (ht_name == PARTITIONED_HT)
            return new kmercounter::PartitionedHashStore<
                kmercounter::Aggr_KV, kmercounter::ItemQueue>{hashtable_size,
                                                              0};
          else if (ht_name == CAS_HT)
            return new kmercounter::CASHashTable<kmercounter::Aggr_KV,
                                                 kmercounter::ItemQueue>{
                hashtable_size};
          else
            return nullptr;
        }());
    ASSERT_NE(ht_, nullptr) << "Invalid hashtable type: " << ht_name;
  }

  std::unique_ptr<kmercounter::BaseHashTable> ht_;
};

// Tests finds of inserted elements after a flush is forced
// Avoiding asynchronous effects
// Note the off-by-one on found values
TEST_P(AggregationTest, SYNCHRONOUS_TEST) {
  const auto size = absl::GetFlag(FLAGS_test_size);
  ASSERT_EQ(size % HT_TESTS_BATCH_LENGTH, 0)
      << "Test size is assumed to be a multiple of batch size";

  static_assert(HT_TESTS_FIND_BATCH_LENGTH == HT_TESTS_BATCH_LENGTH,
                "Test logic assumes these batch sizes are equal");

  std::uint64_t n_inserted{};
  std::uint64_t n_found{};
  std::uint64_t count{};
  collector_type *const collector{};

  for (std::uint64_t i{}; i < size; i += HT_TESTS_BATCH_LENGTH) {
    ++count;

    std::array<InsertFindArgument, HT_TESTS_FIND_BATCH_LENGTH> arguments{};
    std::array<FindResult, HT_TESTS_FIND_BATCH_LENGTH> results{};
    ValuePairs found{0, results.data()};
    for (std::uint64_t j{}; j < HT_TESTS_BATCH_LENGTH; ++j)
      arguments.at(j) = {1, i * HT_TESTS_BATCH_LENGTH + j + 1};

    InsertFindArguments items(arguments);
    n_inserted += items.size();
    ht_->insert_batch(items, collector);
    ht_->flush_insert_queue(collector);
    ht_->find_batch(items, found, collector);
    ASSERT_EQ(found.first, 0) << "Unexpected pending finds.";

    ht_->flush_find_queue(found, collector);
    n_found += found.first;
    // std::cerr << "[TEST] Batch " << i << "\n";
    // for (std::uint64_t j{}; j < found.first; ++j) {
    //   auto& value = found.second[j];
    //   std::cerr << "[TEST] (" << value.id << ", " << value.value << ")\n";
    // }

    ASSERT_EQ(n_found, n_inserted) << "Not all inserted values were found";
  }
}

TEST_P(AggregationTest, ASYNCHRONOUS_TEST) {
  std::uint64_t n_inserted{};
  std::uint64_t n_found{};
  constexpr auto size = 1 << 12;
  collector_type *const collector{};
  static_assert(size % HT_TESTS_BATCH_LENGTH == 0,
                "Test size is assumed to be a multiple of batch size");

  static_assert(HT_TESTS_FIND_BATCH_LENGTH == HT_TESTS_BATCH_LENGTH,
                "Test logic assumes these batch sizes are equal");

  for (std::uint64_t i{}; i < size; i += HT_TESTS_BATCH_LENGTH) {
    std::array<InsertFindArgument, HT_TESTS_BATCH_LENGTH> arguments{};

    for (std::uint64_t j{}; j < HT_TESTS_BATCH_LENGTH; ++j)
      arguments.at(j) = {1, i * HT_TESTS_BATCH_LENGTH + j + 1};

    InsertFindArguments items(arguments);
    ht_->insert_batch(items, collector);
    n_inserted += HT_TESTS_BATCH_LENGTH;

    ht_->flush_insert_queue(collector);

    std::array<FindResult, HT_TESTS_FIND_BATCH_LENGTH> values{};
    ValuePairs found{0, values.data()};
    ht_->find_batch(items, found, collector);
    n_found += found.first;
    found.first = 0;

    ht_->flush_find_queue(found, collector);
    n_found += found.first;
  }

  ASSERT_EQ(n_found, n_inserted) << "Not all inserted values were found";
}

TEST_P(AggregationTest, FILL_SYNC_TEST) {
  constexpr auto size = 1 << 8;
  static_assert(size % HT_TESTS_BATCH_LENGTH == 0,
                "Test size is assumed to be a multiple of batch size");

  static_assert(HT_TESTS_FIND_BATCH_LENGTH == HT_TESTS_BATCH_LENGTH,
                "Test logic assumes these batch sizes are equal");

  std::uint64_t n_inserted{};
  std::uint64_t count{};
  for (std::uint64_t i{}; i < size; i += HT_TESTS_BATCH_LENGTH) {
    ++count;

    std::array<InsertFindArgument, HT_TESTS_BATCH_LENGTH> arguments{};
    for (std::uint64_t j{}; j < HT_TESTS_BATCH_LENGTH; ++j) {
      // Insert different values each time to force max fill
      arguments.at(j) = {i + j + 1, i + j + 1};
    }

    InsertFindArguments items(arguments);
    n_inserted += items.size();
    ht_->insert_batch(items);
  }

  ht_->flush_insert_queue();

  ASSERT_EQ(ht_->get_fill(), n_inserted) << "Not all values were inserted.";
}

// Test for presence of an off-by-one error in synchronous use
TEST_P(AggregationTest, SINGLE_INSERT_TEST) {
  InsertFindArgument argument[] = {{1, 128}};
  InsertFindArguments keys{argument};
  ht_->insert_batch(keys);
  ht_->flush_insert_queue();
  ASSERT_EQ(ht_->get_fill(), 1);
}

// Test demonstrating the nonintuitive difference in the interpretation of batch
// lengths between find/insert
// NOTE: also noted a very strange use of the value field
TEST_P(AggregationTest, OFF_BY_ONE_TEST) {
  std::array<InsertFindArgument, 2> arguments{
      InsertFindArgument{key : 1, id : 128},
      InsertFindArgument{key : 0xdeadbeef, id : 256}};
  InsertFindArguments keypairs(arguments);
  ht_->insert_batch(keypairs);
  ht_->flush_insert_queue();
  std::array<FindResult, HT_TESTS_BATCH_LENGTH> values{};
  ValuePairs valuepairs{0, values.data()};
  ht_->find_batch(keypairs, valuepairs);
  ht_->flush_find_queue(valuepairs);

  // Note that we only insert 256 *once*, so the "value" should be 1
  ASSERT_EQ(valuepairs.first, 2);
  ASSERT_EQ(valuepairs.second[0].id, 128);
  ASSERT_EQ(valuepairs.second[0].value, 1);
  ASSERT_EQ(valuepairs.second[1].id, 256);
  ASSERT_EQ(valuepairs.second[1].value, 1);
}

INSTANTIATE_TEST_CASE_P(TestAllCombinations, AggregationTest,
                        ::testing::ValuesIn(HTS));

}  // namespace
}  // namespace kmercounter
