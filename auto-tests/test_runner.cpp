#include <iostream>
#include <string_view>
#include <gtest/gtest.h>

#include "hashtable.h"
#include "hashtables/cas_kht.hpp"
#include "hashtables/simple_kht.hpp"

/*
  - Fill depends on the *distinct* key/id pairs
  - find_batch() returns pairs of (id, count), where count is the number of
  times a particular id occurs
    - independent of key?
*/

namespace kmercounter {
namespace {
// Test size.
constexpr auto hashtable_size = 1ull << 26;
// Test names.
const char SYNCHRONOUS_TEST[] = "Synchronous";
const char ASYNCHRONOUS_TEST[] = "Asynchronous";
const char FILL_SYNC_TEST[] = "Fill Sync";
const char UNIT_FILL_TEST[] = "Unit Fill";
const char OFF_BY_ONE_TEST[] = "Off By One";
constexpr const char* TEST_FNS [] {
  SYNCHRONOUS_TEST,
  ASYNCHRONOUS_TEST,
  FILL_SYNC_TEST,
  UNIT_FILL_TEST,
  OFF_BY_ONE_TEST,
};
// Hashtable names.
const char PARTITIONED_CAS_HT[] = "Partitioned CAS";
const char CAS_HT[] = "CAS";
constexpr const char* HTS [] {
  PARTITIONED_CAS_HT,
  CAS_HT,
};


// Tests finds of inserted elements after a flush is forced
// Avoiding asynchronous effects
// Note the off-by-one on found values
bool try_synchronous_test(BaseHashTable* ht) {
  try {
    std::cerr << "[TEST] Synchronous\n";

    constexpr auto size = 1 << 12;
    static_assert(size % HT_TESTS_BATCH_LENGTH == 0,
                  "Test size is assumed to be a multiple of batch size");

    static_assert(HT_TESTS_FIND_BATCH_LENGTH == HT_TESTS_BATCH_LENGTH,
                  "Test logic assumes these batch sizes are equal");

    std::uint64_t n_inserted{};
    std::uint64_t n_found{};
    std::uint64_t count{};
    for (std::uint64_t i{}; i < size; i += HT_TESTS_BATCH_LENGTH) {
      ++count;

      std::array<Keys, size> keys{};
      std::array<Values, HT_TESTS_FIND_BATCH_LENGTH> values{};
      ValuePairs found{0, values.data()};
      for (std::uint64_t j{}; j < HT_TESTS_BATCH_LENGTH; ++j)
        keys.at(j) = {1, i * HT_TESTS_BATCH_LENGTH + j + 1};

      KeyPairs items{HT_TESTS_BATCH_LENGTH, keys.data()};
      n_inserted += items.first;
      ht->insert_batch(items);
      ht->flush_insert_queue();
      ht->find_batch(items, found);
      if (found.first != 0) {
        std::cerr << "[TEST] Unexpected pending finds.\n";
        return false;
      }

      ht->flush_find_queue(found);
      n_found += found.first;
      std::cerr << "[TEST] Batch " << i << "\n";
      for (std::uint64_t j{}; j < found.first; ++j) {
        auto& value = found.second[j];
        std::cerr << "[TEST] (" << value.id << ", " << value.value << ")\n";
      }

      if (n_found != n_inserted) {
        std::cerr << "[TEST] Not all inserted values were found\n";
        std::cerr << "[TEST] Found " << n_found << "!=" << n_inserted << "\n";
        return false;
      }
    }

    std::cerr << "[TEST] Ran " << count << " iterations\n";
  } catch (...) {
    std::cerr << "Exception thrown\n";
    return false;
  }

  return true;
}

bool try_asynchronous_test(BaseHashTable* ht) {
  try {
    std::cerr << "[TEST] Asynchronous\n";

    std::uint64_t n_inserted{};
    std::uint64_t n_found{};
    constexpr auto size = 1 << 12;
    static_assert(size % HT_TESTS_BATCH_LENGTH == 0,
                  "Test size is assumed to be a multiple of batch size");

    static_assert(HT_TESTS_FIND_BATCH_LENGTH == HT_TESTS_BATCH_LENGTH,
                  "Test logic assumes these batch sizes are equal");

    for (std::uint64_t i{}; i < size; i += HT_TESTS_BATCH_LENGTH) {
      std::array<Keys, HT_TESTS_BATCH_LENGTH> keys{};

      for (std::uint64_t j{}; j < HT_TESTS_BATCH_LENGTH; ++j)
        keys.at(j) = {1, i * HT_TESTS_BATCH_LENGTH + j + 1};

      KeyPairs items{HT_TESTS_BATCH_LENGTH, keys.data()};
      ht->insert_batch(items);
      n_inserted += HT_TESTS_BATCH_LENGTH;

      ht->flush_insert_queue();

      std::array<Values, HT_TESTS_FIND_BATCH_LENGTH> values{};
      ValuePairs found{0, values.data()};
      ht->find_batch(items, found);
      n_found += found.first;
      found.first = 0;

      ht->flush_find_queue(found);
      n_found += found.first;
    }

    if (n_found != n_inserted) {
      std::cerr << "[TEST] Not all inserted values were found\n";
      std::cerr << "[TEST] Found " << n_found << " != " << n_inserted << "\n";
      return false;
    }
  } catch (...) {
    std::cerr << "Exception thrown\n";
    return false;
  }

  return true;
}

bool try_fill_test(BaseHashTable* ht) {
  try {
    std::cerr << "[TEST] Synchronous fill test\n";

    constexpr auto size = 1 << 8;
    static_assert(size % HT_TESTS_BATCH_LENGTH == 0,
                  "Test size is assumed to be a multiple of batch size");

    static_assert(HT_TESTS_FIND_BATCH_LENGTH == HT_TESTS_BATCH_LENGTH,
                  "Test logic assumes these batch sizes are equal");

    std::uint64_t n_inserted{};
    std::uint64_t count{};
    for (std::uint64_t i{}; i < size; i += HT_TESTS_BATCH_LENGTH) {
      ++count;

      std::array<Keys, size> keys{};
      for (std::uint64_t j{}; j < HT_TESTS_BATCH_LENGTH; ++j)
        keys.at(j) = {
            i + j + 1,
            i + j + 1};  // Insert different values each time to force max fill

      KeyPairs items{HT_TESTS_BATCH_LENGTH, keys.data()};
      n_inserted += items.first;
      ht->insert_batch(items);
    }

    ht->flush_insert_queue();

    std::cerr << "[TEST] Ran " << count << " iterations\n";
    if (ht->get_fill() != n_inserted) {
      std::cerr << "[TEST] Not all values were inserted\n";
      std::cerr << "[TEST] Found " << n_inserted << "!=" << ht->get_fill()
                << "\n";
      return false;
    }
  } catch (...) {
    std::cerr << "Exception thrown\n";
    return false;
  }

  return true;
}

// Test for presence of an off-by-one error in synchronous use
bool try_single_insert(BaseHashTable* ht) {
  Keys pair{1, 128};
  KeyPairs keys{1ull, &pair};
  ht->insert_batch(keys);
  ht->flush_insert_queue();
  std::cerr << "[TEST] Fill was: " << ht->get_fill() << "\n";
  return ht->get_fill() == 1;
}

// Test demonstrating the nonintuitive difference in the interpretation of batch
// lengths between find/insert
// NOTE: also noted a very strange use of the value field
bool try_off_by_one(BaseHashTable* ht) {
  std::array<Keys, 2> keys{Keys{1, 128}, Keys{0xdeadbeef, 256}};
  KeyPairs keypairs{2, keys.data()};
  ht->insert_batch(keypairs);
  ht->flush_insert_queue();
  std::array<Values, HT_TESTS_BATCH_LENGTH> values{};
  ValuePairs valuepairs{0, values.data()};
  ht->find_batch(keypairs, valuepairs);
  ht->flush_find_queue(valuepairs);
  std::cerr << "[TEST] Found " << valuepairs.first << ": {"
            << valuepairs.second->id << ", " << valuepairs.second->value
            << "}\n";

  // Note that we only insert 256 *once*, so the "value" should be 1
  return valuepairs.first == 2 && valuepairs.second[0].id == 128 &&
         valuepairs.second[0].value == 1 && valuepairs.second[1].id == 256 &&
         valuepairs.second[1].value == 1;
}

class CombinationsTest :
    public ::testing::TestWithParam<std::tuple<const char*, const char*>> {};

TEST_P(CombinationsTest, TestFnAndHashtableCombination) {
  // Get input.
  const auto [test_name, ht_name] = GetParam();

  // Get test function.
  const auto test_fn = [test_name]() -> bool (*)(kmercounter::BaseHashTable*) {
    if (test_name == SYNCHRONOUS_TEST)
      return kmercounter::try_synchronous_test;
    else if (test_name == ASYNCHRONOUS_TEST)
      return kmercounter::try_asynchronous_test;
    else if (test_name == FILL_SYNC_TEST)
      return kmercounter::try_fill_test;
    else if (test_name == UNIT_FILL_TEST)
      return kmercounter::try_single_insert;
    else if (test_name == OFF_BY_ONE_TEST)
      return kmercounter::try_off_by_one;
    else
      return nullptr;
  }();
  ASSERT_NE(test_fn, nullptr) << "Invalid test type: " << test_name;

  // Get hashtable.
  const auto ht = [ht_name]() -> kmercounter::BaseHashTable* {
    if (ht_name == PARTITIONED_CAS_HT)
      return new kmercounter::PartitionedHashStore<kmercounter::Aggr_KV,
                                                   kmercounter::ItemQueue>{
          kmercounter::hashtable_size, 0};
    else if (ht_name == CAS_HT)
      return new kmercounter::CASHashTable<kmercounter::Aggr_KV,
                                           kmercounter::ItemQueue>{
          kmercounter::hashtable_size};
    else
      return nullptr;
  }();
  ASSERT_NE(ht, nullptr) << "Invalid hashtable type: " << ht_name;

  // Run test and clean up.
  ASSERT_TRUE(test_fn(ht));
  delete ht;
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

