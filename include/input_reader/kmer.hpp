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
template <size_t K>
class KMerReader : public InputReader<std::array<uint8_t, K>> {
 public:
  KMerReader(std::unique_ptr<InputReader<std::string_view>> lines)
      : lines_(std::move(lines)), eof_(false) {
    PLOG_WARNING_IF(!lines_->next(&current_line_)) << "Empty input.";
    this->prep_new_line();
  }

  // Return the next kmer.
  bool next(std::array<uint8_t, K>* data) override {
    if (eof_) {
      return false;
    }
    kmer_.copy_to(data);

    if (current_line_iter_ == current_line_end_) {
      // This sequence is exhausted. Fetch the next sequence.
      if (!(lines_->next(&current_line_) && this->prep_new_line())) {
        // All sequences are exhausted.
        eof_ = true;
      } else {
        // Successfully fetched a new sequence and refill the buffer.
        return true;
      }
    }

    uint8_t mer = *current_line_iter_;
    current_line_iter_++;
    if (mer == 'N') {
      return refill_buffer();
    }
    kmer_.push(mer);
    return true;
  }

 private:
  bool prep_new_line() {
    current_line_iter_ = current_line_.begin();
    current_line_end_ = current_line_.end();

    // Intiialize the kmer buffer.
    for (size_t i = 0; i < K; i++) {
      if (current_line_iter_ == current_line_end_) {
        eof_ = true;
        return false;
      }
      kmer_.push(*current_line_iter_);
      current_line_iter_++;
    }
    return true;
  }

  // Refill the buffer because of a new sequence or a 'N'.
  bool refill_buffer() {
    for (size_t i = 0; i < K; i++) {
      if (current_line_iter_ == current_line_end_) {
        eof_ = true;
        return false;
      }
      const uint8_t mer = *current_line_iter_;
      if (mer == 'N') {
        return refill_buffer();
      }
      kmer_.insert(i, mer);
      current_line_iter_++;
    }
    return true;
  }

  std::unique_ptr<InputReader<std::string_view>> lines_;
  std::string_view current_line_;
  std::string_view::iterator current_line_iter_;
  std::string_view::iterator current_line_end_;
  CircularBufferMove<uint8_t, K> kmer_;
  bool eof_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_KMER_HPP
