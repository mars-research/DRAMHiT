/// Adapter for ETH relation generator in
/// https://github.com/mars-research/eth-hashjoin

#ifndef INPUT_READER_ETH_REL_GEN_HPP
#define INPUT_READER_ETH_REL_GEN_HPP

#include "eth_hashjoin/src/generator64.hpp"
#include "input_reader.hpp"
#include "input_reader/span.hpp"
#include "logging.hpp"

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

class ParitionedEthRelationReader : public PartitionedRelation,
                                    public EthRelationReader {
 public:
  ParitionedEthRelationReader(relation_t relation, uint64_t part_id,
                              uint64_t num_parts)
      : PartitionedRelation(relation, part_id, num_parts),
        EthRelationReader(PartitionedRelation::relation_) {}
};

}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_ETH_REL_GEN_HPP
