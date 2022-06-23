#include "input_reader/span.hpp"

#include <gtest/gtest.h>

#include <vector>

#include "input_reader_test_utils.hpp"

namespace kmercounter {
namespace input_reader {

namespace {

TEST(StringViewReaderTest, SimpleTest) {
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

}  // namespace
}  // namespace input_reader
}  // namespace kmercounter