#include <string>

#include "hashtable.h"
#include "hashtables/cas_kht.hpp"
#include "hashtables/simple_kht.hpp"

namespace kmercounter {
  namespace {
    bool try_test(BaseHashTable* ht)
    {
      return true;
    }
  }
}

int main(int argc, char** argv) {
  if (argc != 2) return 0;

  constexpr auto size = 1ull << 26;
  const std::string type {argv[1]};
  if (type == "std")
    return kmercounter::try_test(new kmercounter::PartitionedHashStore<kmercounter::Aggr_KV, kmercounter::ItemQueue> {size, 0});
}
