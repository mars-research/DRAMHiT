#include "input_reader/container.hpp"

#include <gtest/gtest.h>

#include <vector>

#include "input_reader_test_utils.hpp"

namespace kmercounter {
namespace input_reader {

namespace {

TEST(ContainerReaderTest, SimpleTest) {
  std::vector vec{1, 3, 5, 7};
  {
    auto reader = std::make_unique<RangeReader<decltype(vec.begin())>>(
        vec.begin(), vec.end());
    EXPECT_EQ(4, reader_size(std::move(reader)));
  }

  vec.push_back(123);
  {
    auto reader = std::make_unique<RangeReader<decltype(vec.begin())>>(
        vec.begin(), vec.end());
    EXPECT_EQ(5, reader_size(std::move(reader)));
  }

  {
    auto reader = std::make_unique<RangeReader<decltype(vec.begin())>>(
        vec.begin() + 1, vec.end());
    EXPECT_EQ(4, reader_size(std::move(reader)));
  }

  {
    auto reader = std::make_unique<RangeReader<decltype(vec.begin())>>(
        vec.begin(), vec.end());
    for (auto expected_val : vec) {
      int val;
      EXPECT_TRUE(reader->next(&val));
      EXPECT_EQ(expected_val, val);
    }
  }
}

TEST(VecReaderTest, SimpleTest) {
  std::vector vec{1, 3, 5, 7};
  {
    auto reader = std::make_unique<VecReader<int>>(vec);
    for (auto expected_val : vec) {
      int val;
      EXPECT_TRUE(reader->next(&val));
      EXPECT_EQ(expected_val, val);
    }
  }
}

}  // namespace
}  // namespace input_reader
}  // namespace kmercounter