#ifndef INPUT_READER_FASTX
#define INPUT_READER_FASTX

#include <array>

#include "input_reader_base.hpp"
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

  FastxReader(const std::string& file, uint32_t k) : offset(0) {
    int fd = open(file.c_str(), O_RDONLY);
    this->seq = kseq_init(fd);
  }

  // Return a kmer.
  std::optional<T> next() override {
    // Read a new sequence if the current sequence is exhausted.
    if (this->offset >= this->seq->seq.l) {
      read_new_sequence();
    }

    // Check if the file is exhausted.
    if (this->eof) {
      return std::nullopt;
    }

    // Shift kmer by one and read in the next mer.
    this->shl_kmer();
    *this->kmer.rbegin() = this->seq->seq.s[this->offset++];

    return *(T*)kmer.data();
  }

  ~FastxReader() { kseq_destroy(this->seq); }

 private:
  /// Read a new sequence.
  void read_new_sequence() {
    /// Read until found a seq with at least K in size.
    while (true) {
      int len = kseq_read(this->seq);
      if (len < 0) {
        this->eof = true;
        return;
      } else if (len < K) {
        PLOG_WARNING << "Skipping sequence with length " << len
                     << ", which is less than K=" << K << ": "
                     << this->seq->seq.s;
      } else {
        break;
      }
    }

    // And prepare `kmer` for a new sequence by
    // reading K-1 mers into kmer[1, K].
    for (int i = 1; i < K; i++) {
      this->kmer[i] = this->seq->seq.s[this->offset++];
    }
  }

  /// Left shift the kmer by one mer.
  /// This is useful for reserving space for the next mer.
  void shl_kmer() {
    for (int i = 0; i < this->kmer.size() - 1; i++) {
      this->kmer[i] = this->kmer[i + 1];
    }
  }

  /// Handle to the fastx parser.
  kseq_t* seq;
  /// Current offset into `seq->seq->s`.
  size_t offset;
  /// Indicate that we have reached the end of the file.
  bool eof;
  /// The kmer returned by the last `next()` call.
  std::array<uint8_t, K> kmer;
};
} // namespace input_reader
} // namespace kmercounter

#endif /* INPUT_READER_FASTX */
