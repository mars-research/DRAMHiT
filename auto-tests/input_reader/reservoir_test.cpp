#include "input_reader/reservoir.hpp"

#include <vector>

#include <gtest/gtest.h>

#include "input_reader_test_utils.hpp"

namespace kmercounter {
namespace input_reader {

namespace {

TEST(RangeReader, SimpleTest) {
  std::vector vec{1, 3, 5, 7};
  {
    auto reader = std::make_unique<RangeReader<decltype(vec.begin())>>(vec.begin(), vec.end());
    EXPECT_EQ(4, reader_size(std::move(reader)));
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

TEST(VecReader, SimpleTest) {
  std::vector vec{1, 3, 5, 7};
  {
    auto reader = std::make_unique<VecReader<int>>(vec);
    for (auto expected_val : vec) {
      int val;
      EXPECT_TRUE(reader->next(&val));
      EXPECT_EQ(expected_val, val);
    }
    int val;
    EXPECT_FALSE(reader->next(&val));
  }

  vec.push_back(123);
  {
    auto reader = std::make_unique<VecReader<int>>(vec);
    for (auto expected_val : vec) {
      int val;
      EXPECT_TRUE(reader->next(&val));
      EXPECT_EQ(expected_val, val);
    }
    int val;
    EXPECT_FALSE(reader->next(&val));
  }
}

TEST(ReserviorReader, SimpleTest) {
  std::vector vec{1, 3, 5, 7};
  {
    auto reader = std::make_unique<VecReader<int>>(vec);
    auto reservoir = std::make_unique<Reservoir<int>>(std::move(reader));
    int val;
    for (auto expected_val : vec) {
      EXPECT_TRUE(reservoir->next(&val));
      EXPECT_EQ(expected_val, val);
    }
    EXPECT_FALSE(reservoir->next(&val));
  }

  vec.push_back(123);
  {
    auto reader = std::make_unique<VecReader<int>>(vec);
    auto reservoir = std::make_unique<Reservoir<int>>(std::move(reader));
    int val;
    for (auto expected_val : vec) {
      EXPECT_TRUE(reservoir->next(&val));
      EXPECT_EQ(expected_val, val);
    }
    EXPECT_FALSE(reservoir->next(&val));
  }
}

} // namespace
} // namespace input_reader
} // namespace kmercounter