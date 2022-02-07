#ifndef INPUT_READER_FASTQ_HPP
#define INPUT_READER_FASTQ_HPP


#ifndef INPUT_READER_FASTX_HPP
#define INPUT_READER_FASTX_HPP

#include <array>
#include <istream>
#include <memory>

#include "file.hpp"
#include "input_reader_base.hpp"
#include "plog/Log.h"

namespace kmercounter {
namespace input_reader {

/// Find offset of the next find_next_sequence.
/// Return current offset if `st` is at the beginning of a line.
std::streampos find_next_sequence(std::istream& st, std::streampos offset) {
  // Beginning of a file is the beginning of a line.
  if (offset == 0) {
    return offset;
  }

  // Save the current offset.
  const auto old_state = st.rdstate();
  const auto old_offset = st.tellg();
  // Find the quality header from the `offset`.
  st.seekg(offset);
  for (std::string line; std::getline(st, line);) {
    // Consume quality line after hitting the quality header.
    // This will lead us to the next sequence.
    if (line == "+") {
      std::getline(st, line);
    }
  }
  const auto next_seq = st.tellg();

  // Restore the offset and return.
  st.seekg(old_offset);
  st.clear(old_state);
  return next_seq;
}

class PartitionedFastqReader : public PartitionedFileReader {
 public:
  PartitionedFastqReader(
      std::string_view filename, uint64_t part_id, uint64_t num_parts,
      PartitionedFileReader::find_bound_t find_bound = find_next_sequence)
      : PartitionedFastqReader(std::make_unique<std::ifstream>(filename.data()),
                               part_id, num_parts, find_bound) {}

  PartitionedFastqReader(
      std::unique_ptr<std::istream> input_file, uint64_t part_id,
      uint64_t num_parts,
      PartitionedFileReader::find_bound_t find_bound = find_next_sequence)
      : PartitionedFileReader(std::move(input_file), part_id, num_parts,
                              find_bound) {}

  // Return the next sequence.
  bool next(std::string* data) override {
    // Skip over the first line(sequence identifier).
    if (this->eof()) {
      return false;
    }
    int next_char = this->peek();
    if (next_char != '@') {
      PLOG_WARNING << "Unexpected character " << next_char
                   << ". Expecting sequence identifier "
                      "line which begins with '@'.";
      return false;
    }
    if (!PartitionedFileReader::next(nullptr)) {
      return false;
    }

    // Copy the second line(sequence) to `data`
    if (!PartitionedFileReader::next(data)) {
      PLOG_WARNING << "Unexpected EOF. Expecting sequence.";
      return false;
    }

    // The parsing for this sequence is finished if the third line
    // is not a quality header.
    if (this->peek() != '+') {
      return true;
    }

    // Skip over the third line(quality header).
    PartitionedFileReader::input_file_->get();
    next_char = PartitionedFileReader::input_file_->get();
    if (next_char != '\n') {
      PLOG_WARNING << "Unexpected character " << next_char
                   << ". The quanlity header line should "
                      "only be {'+', '\n'}.";
      return false;
    }

    // Copy the second line(sequence) to `data`
    if (!PartitionedFileReader::next(nullptr)) {
      PLOG_WARNING << "Unexpected EOF. Expecting sequence.";
      return false;
    }

    return true;
  }
};

class FastqReader : public PartitionedFastqReader {
 public:
  FastqReader(std::string_view filename)
      : PartitionedFastqReader(filename, 0, 1) {}

  FastqReader(std::unique_ptr<std::istream> input_file)
      : PartitionedFastqReader(std::move(input_file), 0, 1) {}
};

}  // namespace input_reader
}  // namespace kmercounter
#endif  // INPUT_READER_FASTX_HPP
#endif // INPUT_READER_FASTQ_HPP
