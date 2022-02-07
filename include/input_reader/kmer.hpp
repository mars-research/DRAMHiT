#ifndef INPUT_READER_KMER_HPP
#define INPUT_READER_KMER_HPP

#include "input_reader.hpp"

#include <array>
#include <memory>
#include <string>

#include "utils/circular_buffer.hpp"

namespace kmercounter {
namespace input_reader {
/// Generate KMer from a sequence.
template <size_t K>
class KMerReader : public InputReader<std::array<uint8_t, K>> {
 public:
  KMerReader(std::unique_ptr<InputReader<std::string>> lines) : lines_(std::move(lines)), eof_(false) {
   PLOG_WARNING_IF(!lines_->next(&current_line_)) << "Empty input.";
   this->prep_new_line();
  }

  // Return the next kmer.
  bool next(std::array<uint8_t, K>* data) override {
    if (eof_) {
      return false;
    }
    kmer_.copy_to(data);

    if (current_line_iter_ == current_line_.end()) {
      // Fetch the next line.
      if (!(lines_->next(&current_line_) && this->prep_new_line())) {
        // Run out of lines.
        eof_ = true;
      } else {
        return true;
      }
    }

    kmer_.push(*(current_line_iter_++));
    return true;
  }


 private:
  bool prep_new_line() {
    current_line_iter_ = current_line_.begin();

    // Intiialize the kmer buffer.
    for (size_t i = 0; i < K; i++) {
      if (current_line_iter_ == current_line_.end()) {
        eof_ = true;
        return false;
      }
      kmer_.push(*(current_line_iter_++));
    }
    return true;
  }



  std::unique_ptr<InputReader<std::string>> lines_;
  std::string current_line_;
  std::string::iterator current_line_iter_;
  CircularBuffer<uint8_t, K> kmer_;
  bool eof_;
};
} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_KMER_HPP
