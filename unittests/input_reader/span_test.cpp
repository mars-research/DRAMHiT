#include "input_reader/span.hpp"

#include <gtest/gtest.h>

#include <vector>
#include <array>
#include <boost/range/adaptor/transformed.hpp>
#include <boost/range/irange.hpp>
#include <boost/range/numeric.hpp>

#include "input_reader_test_utils.hpp"

using boost::accumulate;
using boost::irange;
using boost::adaptors::transformed;

namespace kmercounter {
namespace input_reader {

namespace {

TEST(SpanReaderTest, SimpleTest) {
  std::vector vec{1, 3, 5, 7, 123, 125125, 2315};
  {
    std::span<int> sv(vec.data(), vec.size());
    auto reader = std::make_unique<SpanReader<int>>(sv);
    EXPECT_EQ(vec.size(), reader_size(std::move(reader)));
  }

  {
    auto reader = std::make_unique<SpanReader<int>>(vec.data(), 3);
    EXPECT_EQ(3, reader_size(std::move(reader)));
  }

  {
    auto reader = std::make_unique<SpanReader<int>>(vec.data() + 1, 1);
    EXPECT_EQ(1, reader_size(std::move(reader)));
  }

  {
    auto reader = std::make_unique<SpanReader<int>>();
    EXPECT_EQ(0, reader_size(std::move(reader)));
  }
}

TEST(PartitionedSpanReaderTest, SizeTest) {
  constexpr auto num_elementss =
      std::to_array({1, 2, 3, 4, 6, 9, 13, 17, 19, 21, 22, 24, 100, 1000});
  constexpr auto num_partss =
      std::to_array({1, 2, 3, 4, 5, 6, 9, 13, 17, 19, 64});

  for (const auto num_elements : num_elementss) {
    for (const auto num_parts : num_partss) {
      std::span<uint8_t> data((uint8_t*)nullptr, num_elements);
      auto readers =
          irange(num_parts) | transformed([&data, num_parts](uint64_t part_id) {
            auto reader = std::make_unique<PartitionedSpanReader<uint8_t>>(data, part_id,
                                                       num_parts);
            return reader;
          });

      auto partition_sizes = readers | transformed([](auto reader) {
                          return reader->size();
                        });

      const uint64_t actual_total_elements = accumulate(partition_sizes, 0ul);
      ASSERT_EQ(num_elements, actual_total_elements)
          << "Incorrect number of elements for " << num_parts
          << " partitions.";
    }
  }
}

}  // namespace
}  // namespace input_reader
}  // namespace kmercounter