#include "input_reader/reservoir.hpp"

#include <vector>

#include <gtest/gtest.h>

#include "input_reader_test_utils.hpp"

namespace kmercounter {
namespace input_reader {

namespace {

TEST(ContainerReaderTest, SimpleTest) {
  std::vector vec{1, 3, 5, 7};
  {
    auto reader = std::make_unique<RangeReader<decltype(vec.begin())>>(vec.begin(), vec.end());
    auto reservoir = std::make_unique<Reservoir<int>>(std::move(reader));
    EXPECT_EQ(4, reader_size(std::move(reservoir)));
  }

  vec.push_back(123);
  {
    auto reader = std::make_unique<RangeReader<decltype(vec.begin())>>(vec.begin(), vec.end());
    EXPECT_EQ(5, reader_size(std::move(reader)));
  }

  {
    auto reader = std::make_unique<RangeReader<decltype(vec.begin())>>(vec.begin() + 1, vec.end());
    EXPECT_EQ(4, reader_size(std::move(reader)));
  }

  {
    auto reader = std::make_unique<RangeReader<decltype(vec.begin())>>(vec.begin(), vec.end());
    for (auto expected_val : vec) {
      int val;
      EXPECT_TRUE(reader->next(&val));
      EXPECT_EQ(expected_val, val);
    }
  }

}




} // namespace
} // namespace input_reader
} // namespace kmercounter