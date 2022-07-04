#include <absl/container/flat_hash_set.h>
#include <absl/flags/flag.h>
#include <absl/flags/parse.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <plog/Log.h>

#include <cassert>
#include <initializer_list>
#include <iostream>
#include <memory>
#include <span>
#include <string_view>
#include <utility>

#include "hashtable.h"
#include "hashtables/batch_runner/batch_runner.hpp"
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

// Helper for checking the find results.
class FindResultChecker {
 public:
  FindResultChecker() : FindResultChecker({}) {}
  FindResultChecker(std::initializer_list<kmercounter::FindResult> init)
      : set_(std::make_shared<absl::flat_hash_set<kmercounter::FindResult>>(
            init)) {
    // Ensure keys are unique.
    assert(init.size() == set_->size());
  }
  ~FindResultChecker() { assert(set_->empty()); }

  void add(const kmercounter::FindResult& result) {
    ASSERT_TRUE(set_->insert(result).second);
  }

  void add(uint64_t id, uint64_t value) { this->add(FindResult(id, value)); }

  void add(std::initializer_list<kmercounter::FindResult> list) {
    // Write a for-loop here to ensure the values are added.
    for (const auto& e : list) {
      this->add(e);
    }
  }

  kmercounter::HTBatchRunner<>::FindCallback checker() {
    return [set = set_](const kmercounter::FindResult& result) {
      ASSERT_EQ(set->erase(result), 1)
          << set->size() << "Result not found: " << result;
    };
  }

 private:
  std::shared_ptr<absl::flat_hash_set<kmercounter::FindResult>> set_;
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
    batch_runner_ = HTBatchRunner<>(ht_.get());
  }

  std::unique_ptr<kmercounter::BaseHashTable> ht_;
  HTBatchRunner<> batch_runner_;
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

  InsertFindArgument argument;
  argument.part_id = 0;
  for (uint64_t i = 0; i < test_size; i++) {
    argument.key = i;
    auto ptr = (Item*)ht_->find_noprefetch(&argument);
    ASSERT_NE(ptr, nullptr);
    EXPECT_FALSE(ptr->is_empty()) << "Cannot find " << i;
    EXPECT_EQ(ptr->get_value(), i * i) << "Invalid value for key " << i;
  }
}

TEST_P(HashtableTest, SIMPLE_BATCH_INSERT_TEST) {
  // Setup checker.
  FindResultChecker checker{FindResult(123, 128), FindResult(321, 256)};
  batch_runner_.set_callback(checker.checker());

  // Insertion.
  batch_runner_.insert(12, 128);
  batch_runner_.insert(23, 256);
  batch_runner_.flush_insert();

  // Look up.
  batch_runner_.find(12, 123);
  batch_runner_.find(23, 321);
  batch_runner_.flush_find();
}

TEST_P(HashtableTest, SIMPLE_BATCH_UPDATE_TEST) {
  // Setup checker.
  FindResultChecker checker({FindResult(123, 1025), FindResult(321, 4097)});
  batch_runner_.set_callback(checker.checker());

  // Insertion.
  batch_runner_.insert(12, 128);
  batch_runner_.insert(23, 256);
  batch_runner_.flush_insert();

  // Update.
  batch_runner_.insert(12, 1025);
  batch_runner_.insert(23, 4097);
  batch_runner_.flush_insert();

  // Look up.
  batch_runner_.find(12, 123);
  batch_runner_.find(23, 321);
  batch_runner_.flush_find();
}

TEST_P(HashtableTest, SIMPLE_FIND_AGAIN_TEST) {
  // Setup checker.
  FindResultChecker checker{FindResult(123, 128), FindResult(321, 256)};
  batch_runner_.set_callback(checker.checker());

  // Insertion.
  batch_runner_.insert(12, 128);
  batch_runner_.insert(23, 256);
  batch_runner_.flush_insert();

  // Look up.
  batch_runner_.find(12, 123);
  batch_runner_.find(23, 321);
  batch_runner_.flush_find();

  // Look up again.
  checker.add({FindResult(123, 128), FindResult(321, 256)});
  batch_runner_.find(12, 123);
  batch_runner_.find(23, 321);
  batch_runner_.flush_find();
}

TEST_P(HashtableTest, BATCH_QUERY_TEST) {
  // Setup checker
  FindResultChecker checker;
  batch_runner_.set_callback(checker.checker());

  // Insert test data.
  uint64_t test_size = absl::GetFlag(FLAGS_test_size);
  for (uint64_t i = 0; i < test_size; i++) {
    const uint64_t key = i;
    const uint64_t value = i * i;
    const uint64_t id = 2 * i;
    batch_runner_.insert(key, value);
    checker.add(id, value);
  }
  batch_runner_.flush_insert();

  // Finds.
  for (uint64_t i = 0; i < test_size; i++) {
    const auto key = i;
    const auto id = 2 * i;
    batch_runner_.find(key, id);
  }
  batch_runner_.flush_find();
}

INSTANTIATE_TEST_CASE_P(TestAllHashtables, HashtableTest,
                        ::testing::ValuesIn(HTS));

}  // namespace
}  // namespace kmercounter
