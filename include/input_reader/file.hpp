#ifndef INPUT_READER_FILE_HPP
#define INPUT_READER_FILE_HPP

#include <plog/Log.h>

#include <cassert>
#include <fstream>
#include <functional>
#include <iostream>
#include <limits>
#include <memory>
#include <string>
#include <string_view>
#include <vector>

#include "input_reader.hpp"

namespace kmercounter {
namespace input_reader {
/// Read file one whole line at a time within the partition.
/// The file is sliced up evenly among the partitions.
/// `find_bound` is used to find the boundary of each partition.
class FileReader : public InputReader<std::string_view> {
 public:
  /// Takes a istream and return the offset of the boundary base
  /// on the corrent offset of the istream.
  using find_bound_t =
      std::function<std::streampos(std::istream& st, std::streampos offset)>;

  FileReader(std::string_view filename, uint64_t part_id, uint64_t num_parts,
             find_bound_t find_bound = find_next_line)
      : FileReader(std::make_unique<std::ifstream>(open_file(filename)),
                   part_id, num_parts, find_bound) {}

  FileReader(std::unique_ptr<std::ifstream> input_file, uint64_t part_id,
             uint64_t num_parts, find_bound_t find_bound = find_next_line)
      : FileReader(std::shared_ptr<std::ifstream>(std::move(input_file)),
                   part_id, num_parts, find_bound) {}

  FileReader(std::unique_ptr<std::istream> input_file, uint64_t part_id,
             uint64_t num_parts, find_bound_t find_bound = find_next_line)
      : FileReader(std::shared_ptr<std::istream>(std::move(input_file)),
                   part_id, num_parts, find_bound) {}

  /// Single partition variant.
  FileReader(std::string_view filename) : FileReader(filename, 0, 1) {}

  /// Single partition variant.
  FileReader(std::unique_ptr<std::istream> input_file)
      : FileReader(std::move(input_file), 0, 1) {}

  ~FileReader() {
    if(offset_ != part_end_)
    {
        PLOG_INFO << "Offset mismatch: expected " << part_end_ << "; actual: " << offset_;
    }
  }

  /// Copy the next line to `output` and advance the offset.
  bool next(std::string_view* output) override {
    // Check if we reached end of partitioned.
    if (this->eof()) {
      return false;
    }

    // Skip the line instead of copying it if `output` is nullptr.
    if (output == nullptr) {
      return this->skip_to_next_line();
    }

    input_file_->getline(buffer_.data(), buffer_.size());
    // Resize if doesn't fit.
    // WARNING: not tested.
    while (input_file_->fail()) {
      const size_t old_size = buffer_.size();
      PLOG_DEBUG << "Resizing buffer with old size " << old_size;
      const size_t bytes_read_so_far = old_size - 1;
      buffer_.resize(old_size * 2);
      input_file_->clear();
      input_file_->getline(buffer_.data() + bytes_read_so_far,
                           buffer_.size() - bytes_read_so_far);
    }

    const size_t bytes_read = input_file_->gcount();
    // The last character is the terminator.
    const char last_char = buffer_[bytes_read - 1];
    if (last_char == '\n' || last_char == '\0') {
      *output =
          std::string_view(const_cast<char*>(buffer_.data()), bytes_read - 1);
    } else {
      *output = std::string_view(const_cast<char*>(buffer_.data()), bytes_read);
    }
    offset_ += bytes_read;
    return (bool)input_file_;
  }

  /// Skip to next line.
  bool skip_to_next_line() {
    input_file_->ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    offset_ += input_file_->gcount();
    return (bool)input_file_;
  }

  int peek() { return input_file_->peek(); }

  int get() {
    int rtn = input_file_->get();
    offset_ += input_file_->gcount();
    return rtn;
  }

  bool good() { return input_file_->good(); }

  bool eof() { return (offset_ >= part_end_) || input_file_->eof(); }

  uint64_t num_parts() { return num_parts_; }

  uint64_t part_id() { return part_id_; }

 private:
  /// Helper constructor that sets the buffer for file I/O.
  FileReader(std::shared_ptr<std::ifstream> input_file, uint64_t part_id,
             uint64_t num_parts, find_bound_t find_bound = find_next_line)
      : FileReader(std::shared_ptr<std::istream>(input_file), part_id,
                   num_parts, find_bound) {
    // input_file_->rdbuf()->pubsetbuf(io_buffer_.data(), io_buffer_.size());
  }

  FileReader(std::shared_ptr<std::istream> input_file, uint64_t part_id,
             uint64_t num_parts, find_bound_t find_bound = find_next_line)
      : input_file_(std::move(input_file)),
        // io_buffer_(64 * 1024 * 1024),
        part_id_(part_id),
        num_parts_(num_parts),
        buffer_(4096) {
    if(part_id  >= num_parts)
    {
      PLOG_FATAL << "part_id(" << part_id << " ) >= num_parts(" << num_parts << ")";
    }
        
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
    const auto adjusted_part_end = find_bound(*input_file_, part_end_);
    part_end_ = std::min(uint64_t(adjusted_part_end),
                         file_size);  // adjusted_part_end will be -1 if EOF.
    // Adjust the current offset of the actual partition start.
    const auto adjusted_part_start = find_bound(*input_file_, part_start);
    PLOG_DEBUG << part_id << "/" << num_parts << ": adj_start "
               << adjusted_part_start << ", adj_end " << part_end_;
    input_file_->seekg(adjusted_part_start);
    offset_ = adjusted_part_start;
  }

  /// Creats a ifstream and log if fail.
  static std::ifstream open_file(std::string_view filename) {
    std::ifstream file(filename.data());        
      
    if(file.fail())
    {
      PLOG_FATAL << "Failed to open file " << filename << ": " << file.rdstate();
    }
    return file;
  }

  /// Find offset of next line.
  static std::streampos find_next_line(std::istream& st,
                                       std::streampos offset) {
    // Beginning of a file is the beginning of a line.
    if (offset == 0) {
      return offset;
    }

    // Save the current offset.
    const auto old_state = st.rdstate();
    const auto old_offset = st.tellg();
    // Check if we are already at the beginning of a line.
    st.seekg(offset);
    st.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    const auto next_line = st.tellg();
    // Restore the offset and return.
    st.seekg(old_offset);
    st.clear(old_state);
    return next_line;
  }

 private:
  std::shared_ptr<std::istream> input_file_;
  /// Buffer for file I/O.
  /// Currently unused since our benchmark reads from memory.
  // std::vector<char> io_buffer_;
  uint64_t offset_;
  uint64_t part_end_;
  uint64_t part_id_;
  uint64_t num_parts_;
  /// Buffer for return value.
  std::vector<char> buffer_;
};

}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_FILE_HPP
