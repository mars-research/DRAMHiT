#ifndef __PREFETCH_TEST_HPP__
#define __PREFETCH_TEST_HPP__

#include "hashtables/simple_kht.hpp"
#include "types.hpp"

namespace kmercounter {
struct Prefetch_KV {
  Kmer_base_t kb;            // 20 + 2 bytes
  uint32_t kmer_hash;        // 4 bytes (4B enties is enough)
  volatile char padding[6];  // 3 bytes // TODO remove hardcode
  uint8_t _pad[32];
} __attribute__((packed));

inline std::ostream &operator<<(std::ostream &strm, const Prefetch_KV &k) {
  return strm << std::string(k.kb.kmer.data, KMER_DATA_LENGTH) << " : "
              << k.kb.count;
}

class PrefetchTest {
 public:
  void prefetch_test_run_exec(Shard *sh, Configuration &cfg);
  uint64_t prefetch_test_run(SimpleKmerHashTable<Prefetch_KV> *ktable);
};

}  // namespace kmercounter

#endif  // __PREFETCH_TEST_HPP__
