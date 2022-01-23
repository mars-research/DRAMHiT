#ifndef INPUT_READER_FILE_HPP
#define INPUT_READER_FILE_HPP

#include <iostream>
#include <fstream>
#include <string>
#include <string_view>
#include <limits>
#include <memory>
#include <plog/Log.h>

#include "input_reader_base.hpp"

namespace kmercounter {
namespace input_reader {

/// Read file one whole line at a time within the partition.
/// The file is sliced up evenly among the partitions
class PartitionedFileReader : public InputReader<std::string> {
 public:
  PartitionedFileReader(std::string_view filename, uint64_t part_id, uint64_t num_parts) 
  :
  PartitionedFileReader(std::make_unique<std::ifstream>(filename.data()), part_id, num_parts)
  {
    PLOG_FATAL_IF(this->input_file->fail()) << "Failed to open file " << filename;
  }

  PartitionedFileReader(std::unique_ptr<std::istream> input_file, uint64_t part_id, uint64_t num_parts)
      : input_file(std::move(input_file)) {

    // Get the size of the file and calculate the range of this partition.
    // We are doing it here for now because I don't want to mess with the parameter passing.
    this->input_file->seekg(0, std::ios::end);
    const uint64_t file_size = this->input_file->tellg();
    this->input_file->seekg(0);
    const uint64_t part_start = (double)file_size / num_parts * part_id;
    this->part_end = [&]() -> uint64_t {
      if (part_id == num_parts) {
        return std::numeric_limits<uint64_t>::max();
      } else {
        // This is same as `file_size` but I am worrying about error cause by floating precision.
        return (double)file_size / num_parts * (part_id + 1);
      }
    }();
    PLOG_DEBUG << part_id << "/" << num_parts << ": " << part_start << ", " << part_end;

    // If `start` is not 0 and `start - 1` is not a newline,
    // seek to the next newline and start reading from there.
    if (part_start != 0) {
      this->input_file->seekg(part_start - 1);
      char c;
      *this->input_file >> c;
      if (c != '\n') {
        std::string tmp;
        std::getline(*this->input_file, tmp);
      }
    }
  }

  std::optional<std::string> next() override {
    std::string str;
    if (((uint64_t)this->input_file->tellg() >= this->part_end) || !std::getline(*this->input_file, str)) {
      return std::nullopt;
    } else {
      return str;
    }
  }

  uint64_t num_parts() {
    return num_parts_;
  }

  uint64_t part_id() {
    return part_id_;
  }

 private:
  std::unique_ptr<std::istream> input_file;
  uint64_t part_end;
  uint64_t part_id_;
  uint64_t num_parts_;
};

/// Read one line at a time.
class FileReader : public PartitionedFileReader {
public:
  FileReader(std::string_view filename) : PartitionedFileReader(filename, 0, 1) {}
  FileReader(std::unique_ptr<std::istream> input_file) : PartitionedFileReader(std::move(input_file), 0, 1) {}
};

}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_FILE_HPP
