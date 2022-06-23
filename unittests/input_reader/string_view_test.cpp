#include "input_reader/string_view.hpp"

#include <gtest/gtest.h>

#include <string_view>
#include <vector>

#include "input_reader_test_utils.hpp"

namespace kmercounter {
namespace input_reader {

namespace {

TEST(StringViewReaderTest, SimpleTest) {
  std::vector vec{1, 3, 5, 7, 123, 125125, 2315};
  {
    std::basic_string_view<int> sv(vec.data(), vec.size());
    auto reader = std::make_unique<StringViewReader<int>>(sv);
    EXPECT_EQ(vec.size(), reader_size(std::move(reader)));
  }

  {
    std::basic_string_view<int> sv(vec.data(), 3);
    auto reader = std::make_unique<StringViewReader<int>>(sv);
    EXPECT_EQ(3, reader_size(std::move(reader)));
  }

  {
    std::basic_string_view<int> sv(vec.data() + 1, 1);
    auto reader = std::make_unique<StringViewReader<int>>(sv);
    EXPECT_EQ(1, reader_size(std::move(reader)));
  }

  {
    std::basic_string_view<int> sv(vec.data(), 0);
    auto reader = std::make_unique<StringViewReader<int>>(sv);
    EXPECT_EQ(0, reader_size(std::move(reader)));
  }
}

}  // namespace
}  // namespace input_reader
}  // namespace kmercounter