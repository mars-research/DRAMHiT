#include <gtest/gtest.h>
#include <sstream>

#include "input_reader/file.hpp"

namespace kmercounter {
namespace input_reader {

namespace {

template<typename T>
size_t reader_size(InputReader<T> *reader) {
  size_t size = 0;
  while (reader->next()) {
    size++;
  }
  return size;
}

TEST(PartitionedFileTest, SimplePartitionTest) {
  const char* data = R"(line 1
    line 2
    line 3
    line 4
    line 5)";
  const size_t line_count = 5;

  // Test 1 partition.
  {
    std::unique_ptr<std::istream> file = std::make_unique<std::istringstream>(data);
    PartitionedFileReader reader(std::move(file), 0, 1);
    EXPECT_EQ(line_count, reader_size(&reader));
  }
}

} // namespace
} // namespace input_reader
} // namespace kmercounter