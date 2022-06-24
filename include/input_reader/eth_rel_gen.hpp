/// Adapter for ETH relation generator in
/// https://github.com/mars-research/eth-hashjoin

#ifndef INPUT_READER_ETH_REL_GEN_HPP
#define INPUT_READER_ETH_REL_GEN_HPP

#include <mutex>
#include <string>
#include <string_view>
#include <unordered_map>

#include "eth_hashjoin/src/generator64.hpp"
#include "input_reader.hpp"
#include "input_reader/span.hpp"
#include "logging.hpp"
#include "types.hpp"

namespace kmercounter {
namespace input_reader {

class EthRelationReader : public SpanReader<KeyValuePair> {
 public:
  EthRelationReader()
      : EthRelationReader(relation_t{tuples : nullptr, num_tuples : 0}) {}

  EthRelationReader(relation_t relation)
      : SpanReader<KeyValuePair>((KeyValuePair *)relation.tuples,
                                 relation.num_tuples) {}
};
// Static assert that we can do a direct cast between `tuple_t*` and
// `KeyValuePair*`.
static_assert(sizeof(tuple_t) == sizeof(KeyValuePair));
static_assert(offsetof(tuple_t, key) == offsetof(KeyValuePair, key));
static_assert(offsetof(tuple_t, payload) == offsetof(KeyValuePair, value));
static_assert(sizeof(tuple_t::key) == sizeof(KeyValuePair::key));
static_assert(sizeof(tuple_t::payload) == sizeof(KeyValuePair::value));

class EthRelationGenerator : public SizedInputReader<KeyValuePair> {
 public:
  EthRelationGenerator(unsigned int seed, uint64_t ntuples, uint32_t nthreads) {
    seed_generator(seed);
    relation_t relation;
    parallel_create_relation(&relation, ntuples, nthreads, ntuples);
    reader_ = EthRelationReader(relation);
  }

  bool next(KeyValuePair *data) override { return reader_.next(data); }

  size_t size() override { return reader_.size(); }

 private:
  EthRelationReader reader_;
};

/// Helper class for `ParitionedEthRelationReader`.
/// It computes the pointer and the size of the partitioned relation.
class PartitionedRelation {
 public:
  PartitionedRelation(relation_t relation, uint64_t part_id,
                      uint64_t num_parts) {
    PLOG_WARNING_ONCE_IF(relation.num_tuples % num_parts)
        << "Partition with size " << relation.num_tuples
        << " does not divide evenly by " << num_parts << " partitions.";
    uint64_t num_tuples_per_part = relation.num_tuples / num_parts;
    relation_.tuples = relation.tuples + part_id * num_tuples_per_part;
    relation_.num_tuples = num_tuples_per_part;
    if (part_id == num_parts) {
      // The last partition will get the left over stuff if num_tuples can't be
      // divided evenly.
      relation_.num_tuples += relation.num_tuples % num_parts;
    }
  }

  relation_t relation_;
};

class PartitionedEthRelationReader : public PartitionedRelation,
                                    public EthRelationReader {
 public:
  PartitionedEthRelationReader(relation_t relation, uint64_t part_id,
                              uint64_t num_parts)
      : PartitionedRelation(relation, part_id, num_parts),
        EthRelationReader(PartitionedRelation::relation_) {}
};

/// Helper class ensuring the same relation only get created once.
class SingletonEthRelationGenerator {
 public:
  SingletonEthRelationGenerator(std::string_view identifier, unsigned int seed,
                                uint64_t ntuples, uint32_t nthreads) {
    const std::string id(identifier);
    std::lock_guard guard(mutex_);
    if (!relations_.contains(id)) {
      relation_t relation;
      seed_generator(seed);
      parallel_create_relation(&relation, ntuples, nthreads, ntuples);
      relations_[id] = relation;
    }
    relation_ = relations_[id];
  }

  relation_t relation_;

 private:
  static std::mutex mutex_;
  static std::unordered_map<std::string, relation_t> relations_;
};

/// Generate one relation per unique `identifier`.
/// Each relation is generated with `num_parts` number of threads. 
// TODO: the relations generated are not cleaned up after.
class PartitionedEthRelationGenerator : private SingletonEthRelationGenerator,
                                       public PartitionedEthRelationReader {
 public:
  PartitionedEthRelationGenerator(std::string_view identifier, unsigned int seed,
                                 uint64_t ntuples, uint64_t part_id,
                                 uint64_t num_parts)
      : SingletonEthRelationGenerator(identifier, seed, ntuples, num_parts),
        PartitionedEthRelationReader(SingletonEthRelationGenerator::relation_,
                                    part_id, num_parts) {}
};

}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_ETH_REL_GEN_HPP
