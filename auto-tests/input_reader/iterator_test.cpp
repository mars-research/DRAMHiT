#include "input_reader/iterator.hpp"

#include <vector>

#include <gtest/gtest.h>

#include "input_reader_test_utils.hpp"

namespace kmercounter {
namespace input_reader {

namespace {

TEST(IteratorReaderTest, SimpleTest) {
  std::vector vec{1, 3, 5, 7};
  {
    auto reader = std::make_unique<IterReader<decltype(vec.begin())>>(vec.begin(), vec.end());
    EXPECT_EQ(4, reader_size(std::move(reader)));
  }

  vec.push_back(123);
  {
    auto reader = std::make_unique<IterReader<decltype(vec.begin())>>(vec.begin(), vec.end());
    EXPECT_EQ(5, reader_size(std::move(reader)));
  }
}


} // namespace
} // namespace input_reader
} // namespace kmercounter