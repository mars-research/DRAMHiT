#ifndef INPUT_READER_FASTQ_HPP
#define INPUT_READER_FASTQ_HPP

#ifndef INPUT_READER_FASTX_HPP
#define INPUT_READER_FASTX_HPP

#include <array>
#include <istream>
#include <memory>
#include <utility>

#include "file.hpp"
#include "input_reader.hpp"
#include "input_reader/adaptor.hpp"
#include "input_reader/reservoir.hpp"
#include "kmer.hpp"
#include "plog/Log.h"

namespace kmercounter {
namespace input_reader {
/// Parse a fastq file and produce sequencies from it.
class FastqReader : public FileReader {
 public:
  FastqReader(std::string_view filename, uint64_t part_id, uint64_t num_parts)
      : FileReader(filename, part_id, num_parts, find_next_sequence) {}

  FastqReader(std::unique_ptr<std::istream> input_file, uint64_t part_id,
              uint64_t num_parts)
      : FileReader(std::move(input_file), part_id, num_parts,
                   find_next_sequence) {}

  FastqReader(std::string_view filename)
      : FastqReader(std::make_unique<std::ifstream>(filename.data())) {}

  FastqReader(std::unique_ptr<std::istream> input_file)
      : FastqReader(std::move(input_file), 0, 1) {}

  // Return the next sequence.
  bool next(std::string_view* data) override {
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
    if (!FileReader::next(nullptr)) {
      return false;
    }

    // Copy the second line(sequence) to `data`
    if (!FileReader::next(data)) {
      PLOG_WARNING << "Unexpected EOF. Expecting sequence.";
      return false;
    }

    // The parsing for this sequence is finished if the third line
    // is not a quality header.
    if (this->peek() != '+') {
      return true;
    }

    // Skip over the third line(quality header).
    if (!FileReader::next(nullptr)) {
      PLOG_WARNING << "Unexpected EOF. Expecting quality header.";
      return false;
    }

    // Copy the second line(sequence) to `data`
    if (!FileReader::next(nullptr)) {
      PLOG_WARNING << "Unexpected EOF. Expecting quality.";
      return false;
    }

    return true;
  }

 private:
  /// Find offset of the next find_next_sequence.
  /// Return current offset if `st` is at the beginning of a line.
  static std::streampos find_next_sequence(std::istream& st,
                                           std::streampos offset) {
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
      if (!line.empty() && line.at(0) == '+') {
        std::getline(st, line);
        break;
      }
    }
    const auto next_seq = st.tellg();

    // Restore the offset and return.
    st.seekg(old_offset);
    st.clear(old_state);
    return next_seq;
  }
};

/// Reads KMers from a Fastq file.
template <size_t K>
class FastqKMerReader : public InputReaderU64 {
 public:
  template <typename... Args>
  FastqKMerReader(Args&&... args)
      : reader_(std::make_unique<FastqReader>(std::forward<Args>(args)...)) {}

  bool next(uint64_t* data) override { return reader_.next(data); }

 private:
  KMerReader<K, std::string_view> reader_;
};

/// Produce the same output as `FastqKMerReader` but the sequencies are parsed
/// and stored in the memory before producing.
template <size_t K>
class FastqKMerPreloadReader : public InputReaderU64 {
 public:
  template <typename... Args>
  FastqKMerPreloadReader(Args&&... args)
      : reader_(std::make_unique<ReservoirMmap<std::string>>(
            std::make_unique<MemcpyAdaptor<FastqReader, std::string>>(
                FastqReader(std::forward<Args>(args)...)))) {}

  bool next(uint64_t* data) override { return reader_.next(data); }

 private:
  KMerReader<K> reader_;
};

/// Helper for instantiating a `FastqKMerReader` from a runtime `K`.
template <uint32_t CurrentK = DNAKMer<1>::MAX_K, typename... Args>
std::unique_ptr<InputReaderU64> MakeFastqKMerReader(uint32_t K,
                                                    Args&&... args) {
  // Safety check.
  if (K > DNAKMer<1>::MAX_K || K < 1) {
    PLOG_FATAL << "K=" << K << " is not a valid value";
    return nullptr;
  }

  // Found the right K.
  if (K == CurrentK) {
    return std::make_unique<FastqKMerReader<CurrentK>>(
        std::forward<Args>(args)...);
  }

  // Recurse until we found the right K.
  // Constexpr is necessary here; the compiler will go into an infinite loop
  // otherwise.
  if constexpr (CurrentK > 1) {
    return MakeFastqKMerReader<CurrentK - 1, Args...>(
        K, std::forward<Args>(args)...);
  }
  return nullptr;
}

/// Helper for instantiating a `FastqKMerPreloadReader` from a runtime `K`.
template <uint32_t CurrentK = DNAKMer<1>::MAX_K, typename... Args>
std::unique_ptr<InputReaderU64> MakeFastqKMerPreloadReader(uint32_t K,
                                                           Args&&... args) {
  // Safety check.
  if (K > DNAKMer<1>::MAX_K || K < 1) {
    PLOG_FATAL << "K=" << K << " is not a valid value";
    return nullptr;
  }

  // Found the right K.
  if (K == CurrentK) {
    return std::make_unique<FastqKMerPreloadReader<CurrentK>>(
        std::forward<Args>(args)...);
  }

  // Recurse until we found the right K.
  // Constexpr is necessary here; the compiler will go into an infinite loop
  // otherwise.
  if constexpr (CurrentK > 1) {
    return MakeFastqKMerPreloadReader<CurrentK - 1, Args...>(
        K, std::forward<Args>(args)...);
  }
  return nullptr;
}
}  // namespace input_reader
}  // namespace kmercounter
#endif  // INPUT_READER_FASTX_HPP
#endif  // INPUT_READER_FASTQ_HPP
