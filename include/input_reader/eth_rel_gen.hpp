/// Adapter for ETH relation generator in
/// https://github.com/mars-research/eth-hashjoin

#ifndef INPUT_READER_ETH_REL_GEN_HPP
#define INPUT_READER_ETH_REL_GEN_HPP

#include <mutex>
#include <string>
#include <string_view>
#include <unordered_map>

#include "eth_hashjoin/src/generator64.hpp"
#include "eth_hashjoin/src/types64.hpp"
#include "input_reader.hpp"
#include "input_reader/adaptor.hpp"
#include "input_reader/span.hpp"
#include "logging.hpp"
#include "types.hpp"

namespace kmercounter {
namespace input_reader {

class EthRelationReader : public SpanReader<KeyValuePair> {
 public:
  EthRelationReader(eth_hashjoin::relation_t relation)
      : SpanReader<KeyValuePair>((KeyValuePair*)relation.tuples,
                                 relation.num_tuples) {}
};

// Static assert that we can do a direct cast between `tuple_t*` and
// `KeyValuePair*`.
static_assert(sizeof(eth_hashjoin::tuple_t) == sizeof(KeyValuePair));
static_assert(offsetof(eth_hashjoin::tuple_t, key) ==
              offsetof(KeyValuePair, key));
static_assert(offsetof(eth_hashjoin::tuple_t, payload) ==
              offsetof(KeyValuePair, value));
static_assert(sizeof(eth_hashjoin::tuple_t::key) == sizeof(KeyValuePair::key));
static_assert(sizeof(eth_hashjoin::tuple_t::payload) ==
              sizeof(KeyValuePair::value));

class PartitionedEthRelationReader
    : public PartitionedSpanReader<eth_hashjoin::tuple_t>,
      public EthRelationReader {
 public:
  PartitionedEthRelationReader(eth_hashjoin::relation_t relation,
                               uint64_t part_id, uint64_t num_parts)
      : PartitionedSpanReader<eth_hashjoin::tuple_t>(relation, part_id,
                                                     num_parts),
        EthRelationReader(partitioned_span_) {}

  // Explicit implementatio here to resolve ambiguitiy.
  size_t size() override { return EthRelationReader::size(); }
};

/// Helper class ensuring the same relation only get created once.
class SingletonEthRelationGenerator {
 public:
  SingletonEthRelationGenerator(std::string_view identifier, unsigned int seed,
                                uint64_t ntuples, uint32_t nthreads,
                                uint64_t max_id) {
    const std::string id(identifier);
    std::lock_guard guard(mutex_);
    if (!relations_.contains(id)) {
      eth_hashjoin::relation_t relation;
      eth_hashjoin::seed_generator(seed);
      eth_hashjoin::parallel_create_relation(&relation, ntuples, nthreads,
                                             max_id);
      relations_[id] = relation;
    }
    relation_ = relations_[id];
  }

  eth_hashjoin::relation_t relation_;

 private:
  static std::mutex mutex_;
  static std::unordered_map<std::string, eth_hashjoin::relation_t> relations_;
};

/// Generate one relation per unique `identifier`.
/// Each relation is generated with `num_parts` number of threads.
// TODO: the relations generated are not cleaned up after.
class PartitionedEthRelationGenerator : private SingletonEthRelationGenerator,
                                        public PartitionedEthRelationReader {
 public:
  PartitionedEthRelationGenerator(std::string_view identifier,
                                  unsigned int seed, uint64_t ntuples,
                                  uint64_t part_id, uint64_t num_parts,
                                  uint64_t max_id)
      : SingletonEthRelationGenerator(identifier, seed, ntuples, num_parts,
                                      max_id),
        PartitionedEthRelationReader(SingletonEthRelationGenerator::relation_,
                                     part_id, num_parts) {}
};

}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_ETH_REL_GEN_HPP
