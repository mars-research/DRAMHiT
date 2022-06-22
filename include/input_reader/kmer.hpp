#ifndef INPUT_READER_KMER_HPP
#define INPUT_READER_KMER_HPP

#include <array>
#include <memory>
#include <string>

#include "input_reader.hpp"
#include "utils/circular_buffer.hpp"

namespace kmercounter {
namespace input_reader {
/// Generate KMer from a sequence.
template <size_t K, class Input=std::string>
class KMerReader : public InputReaderU64 {
 public:
  KMerReader(std::unique_ptr<InputReader<Input>> lines)
      : lines_(std::move(lines)), eof_(false) {
    PLOG_WARNING_IF(!this->fetch_and_prep_new_line()) << "Empty input.";
  }

  // Return the next kmer.
  bool next(uint64_t* data) override {
    if (eof_) {
      return false;
    }
    *data = kmer_.data();

    if (current_line_iter_ == current_line_end_) {
      // This sequence is exhausted. Fetch the next sequence.
      if (!(this->fetch_and_prep_new_line())) {
        // All sequences are exhausted.
        eof_ = true;
        return true;
      } else {
        // Successfully fetched a new sequence and refill the buffer.
        return true;
      }
    }

    // Update the buffer for next kmer.
    const uint8_t mer = *current_line_iter_;
    current_line_iter_++;
    if (!kmer_.push(mer)) {
      if (refill_buffer()) {
        // Successfully refilled a buffer
        return true;
      } else {
        // Failed to refill a buffer.
        // Try to fetch a new sequence and try again.
        fetch_and_prep_new_line();
        // Either fetched a new line and the buffer is refilled successfully
        // or it failed. `eof_` is set according in `fetch_and_prep_new_line()`
        return true;
      }
    }
    return true;
  }

 private:
  // Fetch a newline and refill buffer.
  // Repeat until the buffer is fully refilled.
  bool fetch_and_prep_new_line() {
    while (lines_->next(&current_line_)) {
      current_line_iter_ = current_line_.begin();
      current_line_end_ = current_line_.end();

      // Refill the kmer buffer.
      if (!refill_buffer()) {
        continue;
      }
      return true;
    }
    // All seqs are exhausted.
    eof_ = true;
    return false;
  }

  // Refill the buffer because of a new sequence or a 'N'.
  bool refill_buffer() {
    for (size_t i = 0; i < K; i++) {
      if (current_line_iter_ == current_line_end_) {
        return false;
      }
      const uint8_t mer = *current_line_iter_;
      current_line_iter_++;
      // TODO(tian): shifting is not necessary.
      if (!kmer_.push(mer)) {
        return refill_buffer();
      }
    }
    return true;
  }

  std::unique_ptr<InputReader<Input>> lines_;
  Input current_line_;
  Input::iterator current_line_iter_;
  Input::iterator current_line_end_;
  DNAKMer<K> kmer_;
  bool eof_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_KMER_HPP
