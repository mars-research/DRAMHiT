#include <iostream>
#include <string_view>

#include "hashtable.h"
#include "hashtables/cas_kht.hpp"
#include "hashtables/simple_kht.hpp"

namespace kmercounter {
namespace {
constexpr auto hashtable_size = 1ull << 26;

// Tests finds of inserted elements after a flush is forced
// Avoiding asynchronous effects
// Note the off-by-one on found values
bool try_synchronous_test(BaseHashTable* ht) {
  try {
    std::cerr << "[TEST] Synchronous\n";

    constexpr auto size = 1 << 8;
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
        keys.at(j) = {1, j + 1};

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

    constexpr auto size = 1 << 8;
    static_assert(size % HT_TESTS_BATCH_LENGTH == 0,
                  "Test size is assumed to be a multiple of batch size");

    static_assert(HT_TESTS_FIND_BATCH_LENGTH == HT_TESTS_BATCH_LENGTH,
                  "Test logic assumes these batch sizes are equal");

    std::uint64_t n_inserted{};
    std::uint64_t n_insert_loops{};
    for (std::uint64_t i{}; i < size; i += HT_TESTS_BATCH_LENGTH) {
      ++n_insert_loops;
      std::array<Keys, HT_TESTS_BATCH_LENGTH> keys{};
      std::array<Values, HT_TESTS_FIND_BATCH_LENGTH> values{};
      ValuePairs found{0, values.data()};

      for (std::uint64_t j{}; j < HT_TESTS_BATCH_LENGTH; ++j)
        keys.at(j) = {1, i + j + 1};

      KeyPairs items{HT_TESTS_BATCH_LENGTH, keys.data()};
      ht->insert_batch(items);
      n_inserted += HT_TESTS_BATCH_LENGTH;
    }

    ht->flush_insert_queue();

    std::array<Values, HT_TESTS_FIND_BATCH_LENGTH> values{};
    ValuePairs found{0, values.data()};
    std::uint64_t n_found{};
    std::uint64_t n_find_loops{};
    for (std::uint64_t i{}; i < size; i += HT_TESTS_BATCH_LENGTH) {
      ++n_find_loops;
      std::array<Keys, HT_TESTS_BATCH_LENGTH> keys{};

      for (std::uint64_t j{}; j < HT_TESTS_BATCH_LENGTH; ++j)
        keys.at(j) = {1, i + j + 1};

      KeyPairs items{HT_TESTS_BATCH_LENGTH, keys.data()};
      ht->find_batch(items, found);
      n_found += found.first;
      found.first = 0;
    }

    ht->flush_find_queue(found);
    n_found += found.first;
    std::cerr << "[TEST] Ran " << n_insert_loops << " insert iterations\n";
    std::cerr << "[TEST] Ran " << n_find_loops << " find iterations\n";
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
        keys.at(j) = {i + j + 1, i + j + 1}; // Insert different values each time to force max fill

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
  Keys pair{0, 128};
  KeyPairs keys{1ull, &pair};
  ht->insert_batch(keys);
  ht->flush_insert_queue();
  std::cerr << "[TEST] Fill was: " << ht->get_fill() << "\n";
  return ht->get_fill() == 0;  // Note that the single key is not inserted
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
}  // namespace
}  // namespace kmercounter

int main(int argc, char** argv) {
  if (argc != 3) return 1;
  const std::string_view type{argv[1]};
  const std::string_view test{argv[2]};

  const auto run_test = [test]() -> bool (*)(kmercounter::BaseHashTable*) {
    if (test == "sync")
      return kmercounter::try_synchronous_test;
    else if (test == "async")
      return kmercounter::try_asynchronous_test;
    else if (test == "fill_sync")
      return kmercounter::try_fill_test;
    else if (test == "unit_fill")
      return kmercounter::try_single_insert;
    else if (test == "off_by_one")
      return kmercounter::try_off_by_one;
    else
      return nullptr;
  }();

  const auto ht = [type]() -> kmercounter::BaseHashTable* {
    if (type == "partitioned")
      return new kmercounter::PartitionedHashStore<kmercounter::Aggr_KV,
                                                   kmercounter::ItemQueue>{
          kmercounter::hashtable_size, 0};
    else if (type == "cas")
      return new kmercounter::CASHashTable<kmercounter::Aggr_KV,
                                           kmercounter::ItemQueue>{
          kmercounter::hashtable_size};
    else
      return nullptr;
  }();

  if (!(ht && run_test)) {
    std::cerr << "[TEST] Invalid test type\n";
    std::cerr << "[TEST] " << type << " " << test << "\n";
    return 1;
  }

  return !run_test(ht);
}
