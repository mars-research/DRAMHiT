#ifndef INPUT_READER_FILE_HPP
#define INPUT_READER_FILE_HPP

#include <fstream>
#include <string>
#include <string_view>
#include <limits>

#include "input_reader_base.hpp"

namespace kmercounter {
namespace input_reader {

/// Read file one whole line at a time within the partition.
/// The file is sliced up evenly among the partitions
class PartitionedFile : public InputReader<std::string> {
 public:
  PartitionedFile(std::string_view filename, uint64_t num_partitions, uint64_t part_id)
      : input_file(filename.data()) {
    // Get the size of the file and calculate the range of this partition.
    // We are doing it here for now because I don't want to mess with the parameter passing.
    input_file.seekg(0, std::ios::end);
    const uint64_t file_size = input_file.tellg();
    const uint64_t part_start = (double)part_id / file_size * num_partitions;
    this->part_end = [&]() -> uint64_t {
      if (part_id == num_partitions) {
        return std::numeric_limits<uint64_t>::max();
      } else {
        // This is same as `file_size` but I am worrying about error cause by floating precision.
        return (double)file_size / num_partitions * (part_id + 1);
      }
    }();

    // If `start` is not 0 and `start - 1` is not a newline,
    // seek to the next newline and start reading from there.
    if (part_start != 0) {
      this->input_file.seekg(part_start - 1);
      char c;
      input_file >> c;
      if (c != '\n') {
        std::string tmp;
        std::getline(this->input_file, tmp);
      }
    }
  }

  std::optional<std::string> next() override {
    std::string str;
    if ((this->input_file.tellg() >= this->part_end) || std::getline(input_file, str)) {
      return std::nullopt;
    } else {
      return str;
    }
  }

 private:
  std::ifstream input_file;
  uint64_t part_end;
};

/// Read one line at a time.
class File : public PartitionedFile {
  File(std::string_view filename) : PartitionedFile(filename, 1, 1) {}
};

}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_FILE_HPP
