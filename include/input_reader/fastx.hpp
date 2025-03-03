/// readfq library adaptor for https://github.com/lh3/readfq.
/// Deprecated.
/// Use fastq.hpp instead.

#ifndef INPUT_READER_FASTX_HPP
#define INPUT_READER_FASTX_HPP

#include <array>

#include "file.hpp"
#include "input_reader.hpp"
#include "plog/Log.h"
#include "readfq/kseq.h"

namespace kmercounter {
namespace input_reader {

KSEQ_INIT(int, read)
/// Read a file in fasta/fastq format.
/// Return a single KMer a time.
template <class T>
class FastxReader : public InputReader<T> {
 public:
  /// The size of the output. AKA, The `K` in KMer.
  static constexpr size_t K = sizeof(T);

  FastxReader(const std::string& file, uint32_t k) : offset_(0) {
    int fd = open(file.c_str(), O_RDONLY);
    seq_ = kseq_init(fd);
  }

  // Return a kmer.
  bool next(T* data) override {
    // Read a new sequence if the current sequence is exhausted.
    if (offset_ >= seq_->seq.l) {
      read_new_sequence();
    }

    // Check if the file is exhausted.
    if (eof_) {
      return false;
    }

    // Shift kmer by one and read in the next mer.
    // TODO: maybe it's faster to copy without shifting.
    this->shl_kmer();
    *kmer_.rbegin() = seq_->seq.s[offset_++];

    *data = *(T*)kmer_.data();
    return true;
  }

  ~FastxReader() { kseq_destroy(seq_); }

 private:
  /// Read a new sequence.
  void read_new_sequence() {
    /// Read until found a seq with at least K in size.
    while (true) {
      int len = kseq_read(seq_);
      if (len < 0) {
        eof_ = true;
        return;
      } else if (len < K) {
        PLOG_WARNING << "Skipping sequence with length " << len
                     << ", which is less than K=" << K << ": " << seq_->seq.s;
      } else {
        break;
      }
    }

    // And prepare `kmer` for a new sequence by
    // reading K-1 mers into kmer[1, K].
    for (int i = 1; i < K; i++) {
      kmer_[i] = seq_->seq.s[offset_++];
    }
  }

  /// Left shift the kmer by one mer.
  /// This is useful for reserving space for the next mer.
  void shl_kmer() {
    for (int i = 0; i < kmer_.size() - 1; i++) {
      kmer_[i] = kmer_[i + 1];
    }
  }

  /// Handle to the fastx parser.
  kseq_t* seq_;
  /// Current offset into `seq->seq->s`.
  size_t offset_;
  /// Indicate that we have reached the end of the file.
  bool eof_;
  /// The kmer returned by the last `next()` call.
  std::array<uint8_t, K> kmer_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_FASTX_HPP
