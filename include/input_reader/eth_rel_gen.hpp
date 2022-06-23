/// Adapter for ETH relation generator in
/// https://github.com/mars-research/eth-hashjoin

#ifndef INPUT_READER_ETH_REL_GEN_HPP
#define INPUT_READER_ETH_REL_GEN_HPP

#include "eth_hashjoin/src/generator64.hpp"
#include "input_reader.hpp"
#include "input_reader/span.hpp"

namespace kmercounter {
namespace input_reader {
class EthRelationGenerator : public InputReader<tuple_t> {
  EthRelationGenerator(unsigned int seed, uint64_t ntuples, uint32_t nthreads) {
    seed_generator(seed);
    parallel_create_relation(&relation_, ntuples, nthreads, ntuples);
    reader_ = SpanReader(relation_.tuples, relation_.num_tuples);
  }

  bool next(tuple_t *data) override { return reader_.next(data); }

 private:
  relation_t relation_;
  SpanReader<tuple_t> reader_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_ETH_REL_GEN_HPP
