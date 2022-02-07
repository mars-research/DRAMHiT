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
class KMerSplitter : public InputReader<std::array<uint8_t, K>> {
 public:
  KMerSplitter(std::unique_ptr<InputReader<std::string>> lines) : lines_(lines) {
   PLOG_WARNING_IF(!lines_->next(&current_line_)) << "Empty input.";
   current_line_iter_ = current_line_.begin();

   // Intiialize the kmer buffer.
   for (size_t i = 0; i < K; i++) {
     if (current_line_iter_ == current_line_.end()) {
       return;
     }
     kmer_.push(*(current_line_iter_++));
   }
  }

  // Return the next kmer.
  bool next(std::array<uint8_t, K>* data) override {
    if (current_line_iter_ == current_line_.end()) {
      // Fetch the next line.
      if (!lines_->next(&current_line_)) {
        // Run out of lines.
        return false;
      }
    }

    kmer_.push(*(current_line_iter_++));
    kmer_.copy_to(data);
    return true;
  }


 private:
  std::unique_ptr<InputReader<std::string>> lines_;
  std::string current_line_;
  std::string::iterator current_line_iter_;
  CircularBuffer<uint8_t, K> kmer_;
};
} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_KMER_HPP
