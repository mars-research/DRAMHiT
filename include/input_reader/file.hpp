#ifndef INPUT_READER_FILE_HPP
#define INPUT_READER_FILE_HPP

#include <plog/Log.h>

#include <fstream>
#include <functional>
#include <iostream>
#include <limits>
#include <memory>
#include <string>
#include <string_view>

#include "input_reader.hpp"

namespace kmercounter {
namespace input_reader {

/// Find offset of next line.
std::streampos find_next_line(std::istream& st, std::streampos offset) {
  // Beginning of a file is the beginning of a line.
  if (offset == 0) {
    return offset;
  }

  // Save the current offset.
  const auto old_state = st.rdstate();
  const auto old_offset = st.tellg();
  // Check if we are already at the beginning of a line.
  st.seekg(offset);
  std::string tmp;
  std::getline(st, tmp);
  const auto next_line = st.tellg();
  // Restore the offset and return.
  st.seekg(old_offset);
  st.clear(old_state);
  return next_line;
}

/// Read file one whole line at a time within the partition.
/// The file is sliced up evenly among the partitions.
/// `find_bound` is used to find the boundary of each partition.
class PartitionedFileReader : public InputReader<std::string> {
 public:
  /// Takes a istream and return the offset of the boundary base
  /// on the corrent offset of the istream.
  using find_bound_t =
      std::function<std::streampos(std::istream& st, std::streampos offset)>;

  PartitionedFileReader(std::string_view filename, uint64_t part_id,
                        uint64_t num_parts,
                        find_bound_t find_bound = find_next_line)
      : PartitionedFileReader(std::make_unique<std::ifstream>(filename.data()),
                              part_id, num_parts, find_bound) {
    PLOG_FATAL_IF(input_file_->fail()) << "Failed to open file " << filename;
  }

  PartitionedFileReader(std::unique_ptr<std::istream> input_file,
                        uint64_t part_id, uint64_t num_parts,
                        find_bound_t find_bound = find_next_line)
      : input_file_(std::move(input_file)),
        part_id_(part_id),
        num_parts_(num_parts) {
    // Get the size of the file and calculate the range of this partition.
    // We are doing it here for now because I don't want to mess with the
    // parameter passing.
    input_file_->seekg(0, std::ios::end);
    const uint64_t file_size = input_file_->tellg();
    input_file_->seekg(0);
    const uint64_t part_start = (double)file_size / num_parts * part_id;
    part_end_ = (double)file_size / num_parts * (part_id + 1);
    PLOG_DEBUG << part_id << "/" << num_parts << ": start " << part_start
               << ", end " << part_end_;

    // Adjust the partition end.
    part_end_ = find_bound(*input_file_, part_end_);
    // Adjust the current offset of the actual partition start.
    const auto adjusted_part_start = find_bound(*input_file_, part_start);
    PLOG_DEBUG << part_id << "/" << num_parts << ": adj_start "
               << adjusted_part_start << ", adj_end " << part_end_;
    input_file_->seekg(adjusted_part_start);
  }

  /// Copy the next line to `data` and advance the offset.
  bool next(std::string* data) override {
    // Check if we reached end of partitioned.
    if (this->eof()) {
      return false;
    }

    // Skip the line instead of copying it if `data` is nullptr.
    if (data == nullptr) {
      return this->skip_to_next_line();
    }

    return (bool)std::getline(*input_file_, *data);
  }

  /// Skip to next line.
  bool skip_to_next_line() {
    return (bool)input_file_->ignore(
        std::numeric_limits<std::streamsize>::max(), '\n');
  }

  int peek() { return input_file_->peek(); }

  bool good() { return input_file_->good(); }

  bool eof() {
    return ((uint64_t)input_file_->tellg() >= part_end_) || input_file_->eof();
  }

  uint64_t num_parts() { return num_parts_; }

  uint64_t part_id() { return part_id_; }

 protected:
  std::unique_ptr<std::istream> input_file_;

 private:
  uint64_t part_end_;
  uint64_t part_id_;
  uint64_t num_parts_;
};

/// Read one line at a time.
class FileReader : public PartitionedFileReader {
 public:
  FileReader(std::string_view filename)
      : PartitionedFileReader(filename, 0, 1) {}
  FileReader(std::unique_ptr<std::istream> input_file)
      : PartitionedFileReader(std::move(input_file), 0, 1) {}
};

}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_FILE_HPP
