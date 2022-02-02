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

#include "input_reader_base.hpp"

namespace kmercounter {
namespace input_reader {

/// Find offset of next line.
/// Return current offset if `st` is at the beginning of a line.
std::streampos find_next_line(std::istream& st, std::streampos offset) {
  // Beginning of a file is the beginning of a line.
  if (offset == 0) {
    return offset;
  }

  // Save the current offset.
  const auto old_state = st.rdstate();
  const auto old_offset = st.tellg();
  // Check if we are already at the beginning of a line.
  st.seekg(offset - std::streamoff(1));
  char c = st.get();
  if (c != '\n') {
    std::string tmp;
    std::getline(st, tmp);
  }
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
  /// Takes a istream and return the offset of the boundary base
  /// on the corrent offset of the istream.
  using find_bound_t =
      std::function<std::streampos(std::istream& st, std::streampos offset)>;

 public:
  PartitionedFileReader(std::string_view filename, uint64_t part_id,
                        uint64_t num_parts,
                        find_bound_t find_bound = find_next_line)
      : PartitionedFileReader(std::make_unique<std::ifstream>(filename.data()),
                              part_id, num_parts, find_bound) {
    PLOG_FATAL_IF(this->input_file->fail())
        << "Failed to open file " << filename;
  }

  PartitionedFileReader(std::unique_ptr<std::istream> input_file,
                        uint64_t part_id, uint64_t num_parts,
                        find_bound_t find_bound = find_next_line)
      : input_file(std::move(input_file)),
        part_id_(part_id),
        num_parts_(num_parts) {
    // Get the size of the file and calculate the range of this partition.
    // We are doing it here for now because I don't want to mess with the
    // parameter passing.
    this->input_file->seekg(0, std::ios::end);
    const uint64_t file_size = this->input_file->tellg();
    this->input_file->seekg(0);
    const uint64_t part_start = (double)file_size / num_parts * part_id;
    this->part_end = (double)file_size / num_parts * (part_id + 1);
    PLOG_DEBUG << part_id << "/" << num_parts << ": start " << part_start
               << ", end " << this->part_end;

    // Adjust the partition end.
    this->part_end = find_bound(*this->input_file, this->part_end);
    // Adjust the current offset of the actual partition start.
    const auto adjusted_part_start = find_bound(*this->input_file, part_start);
    PLOG_DEBUG << part_id << "/" << num_parts << ": adj_start "
               << adjusted_part_start << ", adj_end " << this->part_end;
    this->input_file->seekg(adjusted_part_start);
  }

  bool next(std::string* data) override {
    return ((uint64_t)this->input_file->tellg() < this->part_end) &&
           std::getline(*this->input_file, *data);
  }

  uint64_t num_parts() { return num_parts_; }

  uint64_t part_id() { return part_id_; }

 private:
  std::unique_ptr<std::istream> input_file;
  uint64_t part_end;
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

#endif // INPUT_READER_FILE_HPP
