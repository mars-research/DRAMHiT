#include "input_reader/eth_rel_gen.hpp"

#include <gtest/gtest.h>

#include <array>
#include <boost/range/adaptor/transformed.hpp>
#include <boost/range/irange.hpp>
#include <boost/range/numeric.hpp>
#include <vector>

#include "eth_hashjoin/src/types.h"
#include "input_reader_test_utils.hpp"

using boost::accumulate;
using boost::irange;
using boost::adaptors::transformed;

namespace kmercounter {
namespace input_reader {
namespace {

TEST(EthRelationReader, SizeTest) {
  std::vector<eth_hashjoin::tuple_t> vec(64);
  {
    eth_hashjoin::relation_t relation(vec.data(), vec.size());
    auto reader = std::make_unique<EthRelationReader>(relation);
    EXPECT_EQ(vec.size(), reader_size(std::move(reader)));
  }
}

}  // namespace
}  // namespace input_reader
}  // namespace kmercounter