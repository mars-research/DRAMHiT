#include <string>

#include "hashtable.h"
#include "hashtables/cas_kht.hpp"
#include "hashtables/simple_kht.hpp"

namespace kmercounter {
namespace {
bool try_test(BaseHashTable* ht) {
  try {
    constexpr auto size = 1 << 8;
    for (std::uint64_t i{}; i < size; i += HT_TESTS_BATCH_LENGTH) {
      static_assert(HT_TESTS_FIND_BATCH_LENGTH == HT_TESTS_BATCH_LENGTH,
                    "Test logic assumes these batch sizes are equal");

      std::array<Keys, size> keys{};
      std::array<Values, HT_TESTS_FIND_BATCH_LENGTH> values{};
      ValuePairs found{0, values.data()};

      for (std::uint64_t j{}; j < HT_TESTS_BATCH_LENGTH; ++j)
        keys.at(j) = {i + j, (i + j) * 2};

      KeyPairs items{HT_TESTS_BATCH_LENGTH, keys.data()};
      ht->insert_batch(items);
      ht->flush_insert_queue();
      ht->find_batch(items, found);
      if (found.first != 0) {
        std::cerr << "[TEST] Unexpected pending finds.\n";
        return false;
      }

      ht->flush_find_queue(found);
      if (found.first != HT_TESTS_FIND_BATCH_LENGTH) {
        std::cerr << "[TEST] Not all inserted values were found\n";
        std::cerr << "[TEST] Found " << found.first << "\n";
        return false;
      }
    }
  } catch (...) {
    std::cerr << "Exception thrown\n";
    return false;
  }

  return true;
}
}  // namespace
}  // namespace kmercounter

int main(int argc, char** argv) {
  if (argc != 2) return 0;

  constexpr auto size = 1ull << 26;
  const std::string type{argv[1]};
  if (type == "partitioned")
    return !kmercounter::try_test(
        new kmercounter::PartitionedHashStore<kmercounter::Aggr_KV,
                                              kmercounter::ItemQueue>{size, 0});
  else if (type == "cas")
    return !kmercounter::try_test(
        new kmercounter::CASHashTable<kmercounter::Aggr_KV,
                                      kmercounter::ItemQueue>{size});

  return 1;
}
