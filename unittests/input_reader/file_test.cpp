#include "input_reader/file.hpp"

#include <absl/strings/str_join.h>
#include <gtest/gtest.h>

#include <array>
#include <boost/range/adaptor/transformed.hpp>
#include <boost/range/irange.hpp>
#include <boost/range/numeric.hpp>
#include <sstream>

#include "input_reader_test_utils.hpp"

using boost::accumulate;
using boost::irange;
using boost::adaptors::transformed;

namespace kmercounter {
namespace input_reader {

namespace {
/// Generate comma seperated a CSV file.
std::string generate_csv(uint64_t num_rows, uint64_t num_cols = 3) {
  std::string csv;
  for (uint64_t row = 0; row < num_rows; row++) {
    std::vector<uint64_t> fields;
    for (uint64_t col = 0; col < num_cols; col++) {
      fields.push_back(row + col * col);
    }
    csv += absl::StrJoin(fields, ",");
    csv += '\n';
  }
  return csv;
}

TEST(FileTest, SimplePartitionTest) {
  const char* data = R"(line 1
this is line 2
3

line 4 is me)";

  // Test 1 partition.
  {
    std::unique_ptr<std::istream> file =
        std::make_unique<std::istringstream>(data);
    auto reader =
        std::make_unique<FileReader>(std::move(file), 0, 1);
    std::string_view str;
    EXPECT_TRUE(reader->next(&str));
    EXPECT_EQ("line 1", str);
    EXPECT_TRUE(reader->next(&str));
    EXPECT_EQ("this is line 2", str);
    EXPECT_TRUE(reader->next(&str));
    EXPECT_EQ("3", str);
    EXPECT_TRUE(reader->next(&str));
    EXPECT_EQ("", str);
    EXPECT_TRUE(reader->next(&str));
    EXPECT_EQ("line 4 is me", str);
    EXPECT_FALSE(reader->next(&str));
  }
}

TEST(FileTest, PartitionTest) {
  constexpr auto num_liness =
      std::to_array({1, 2, 3, 4, 6, 9, 13, 17, 19, 21, 22, 24, 100, 1000});
  constexpr auto num_partss =
      std::to_array({1, 2, 3, 4, 5, 6, 9, 13, 17, 19, 64});

  for (const auto num_lines : num_liness) {
    std::string csv = generate_csv(num_lines);
    for (const auto num_parts : num_partss) {
      auto readers =
          irange(num_parts) | transformed([&csv, num_parts](uint64_t part_id) {
            std::unique_ptr<std::istream> file =
                std::make_unique<std::istringstream>(csv);
            auto reader = std::make_unique<FileReader>(
                std::move(file), part_id, num_parts);
            return reader;
          });

      auto lines_read = readers | transformed([](auto reader) {
                          const uint64_t lines_read =
                              reader_size(std::move(reader));
                          return lines_read;
                        });

      const uint64_t total_lines_read = accumulate(lines_read, 0ul);
      ASSERT_EQ(num_lines, total_lines_read)
          << "Incorrect number of lines read for " << num_parts
          << " partitions.";
    }
  }
}

}  // namespace
}  // namespace input_reader
}  // namespace kmercounter