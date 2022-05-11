#ifndef INPUT_READER_CSV_HPP
#define INPUT_READER_CSV_HPP

#include <plog/Log.h>

#include <fstream>
#include <variant>
#include <vector>
#include <string_view>
#include <charconv>

#include "file.hpp"
#include "input_reader.hpp"

namespace kmercounter {
namespace input_reader {

/// The first field(key) of the row and the raw row itself.
using Row = std::pair<uint64_t, std::string_view>;

/// Read a CSV file.
/// All data are cached in memory to save I/O.
/// WIP; only reads the first integer column at this moment.
class PartitionedCsvReader : public InputReader<Row*> {
 public:
  PartitionedCsvReader(std::string_view filename, uint64_t part_id, uint64_t num_parts,
                        std::string_view delimiter = ",") {
    // Read CSV line by line into memory.
    FileReader file(filename, part_id, num_parts);
    for (std::string_view line; file.next(&line); /*noop*/) {
      const std::string_view key_str = line.substr(0, line.find(delimiter));
      uint64_t key{};
      std::from_chars(key_str.begin(), key_str.end(), key);
      data_.push_back(std::make_pair(key, line));
    }

    iter_ = data_.begin();
  }

  bool next(Row **data) override {
    if (iter_ == data_.end()) {
      return false;
    } else {
      *data = &*(iter_++);
      return true;
    }
  }

  uint64_t size() { return data_.size(); }

  const std::vector<Row>& rows() const {
    return data_;
  }

 private:
  std::vector<Row> data_;
  std::vector<Row>::iterator iter_;
};

class CsvReader : public PartitionedCsvReader {
 public:
  CsvReader(std::string_view filename, uint64_t num_parts, uint64_t part_id,
            std::string_view delimiter)
      : PartitionedCsvReader(filename, 1, 1, delimiter) {}
};

}  // namespace input_reader
}  // namespace kmercounter

#endif /* INPUT_READER_CSV_HPP */
