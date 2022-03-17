#ifndef UTILS_CIRCULAR_BUFFER_HPP
#define UTILS_CIRCULAR_BUFFER_HPP

#include <array>
#include <cstring>
#include <cstdint>
#include <iterator>

#include "plog/Log.h"

namespace kmercounter {
// A DNA KMer.
template <size_t K>
class DNAKMer {
public:
  DNAKMer() : DNAKMer(uint64_t{}) {}
  DNAKMer(uint64_t kmer) : buffer_{kmer} {}

  // Push a character mer into the buffer.
  // Does nothing and returns false if it's not a valid mer.
  bool push(const uint8_t mer) {
    const auto code = ENCODE_MAP[mer];
    // LOG_INFO << "code " << (int)code
    if (code < 0) {
      return false;
    }

    // Shift left and insert the mer in the right-most entry.
    this->shift_left();
    buffer_ |= code;
    return true;
  }

  uint64_t data() const {
    return buffer_;
  }

  std::string to_string() const {
    std::string str;
    uint64_t mask = MER_MASK << ((K - 1) * MER_SIZE); 
    for (int i = K; i > 0; i--) {
      const auto mer = (buffer_ & mask) >> ((i-1) * MER_SIZE);
      const uint8_t decoded_mer = DECODE_MAP[mer];
      str.push_back(decoded_mer);
      mask >>= MER_SIZE;
    }
    return str;
  }

  static std::string decode(uint64_t kmer) {
    return DNAKMer(kmer).to_string();
  }

  // Size of a mer in bits
  constexpr static size_t MER_SIZE = 2; 
  // Size of the kmer in bits
  constexpr static size_t KMER_SIZE = 2 * K;
  // Max number of mers that a byte can hold.
  constexpr static size_t MER_PER_BYTE = 8 / MER_SIZE;
  static_assert(MER_PER_BYTE == 4);
  // Size of buffer to holder the kmer in bytes.
  constexpr static size_t BUFFER_LEN = (K + MER_PER_BYTE - 1) / MER_PER_BYTE; 
  static_assert(BUFFER_LEN <= sizeof(uint64_t), "Large K support is not implemented");
  // Mask to obtain one mer.
  constexpr static uint8_t MER_MASK = 0b11;
  // Mask to remove unused bits of a kmer.
  constexpr static uint64_t KMER_MASK = ~((uint64_t)(0ull) - (1 << KMER_SIZE));

private:
  // Shift left by one mer.
  void shift_left() {
    buffer_ <<= MER_SIZE;
    buffer_ &= KMER_MASK;
  }

  // Currently assumes only uint64_t for simplicity.
  uint64_t buffer_; 
  static_assert(K < 32, "K >= 32 is not yet implemented");

  // Borrowed from https://github.com/gmarcais/Jellyfish/blob/master/include/jellyfish/mer_dna.hpp
  enum Code {
    R = -1,
    I = -2,
    O = -3,
    A = 0,
    C = 1,
    G = 2,
    T = 3,
  };

  constexpr static int ENCODE_MAP[256] = {
    O, O, O, O, O, O, O, O, O, O, I, O, O, O, O, O,
    O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O,
    O, O, O, O, O, O, O, O, O, O, O, O, O, R, O, O,
    O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O,
    O, A, R, C, R, O, O, G, R, O, O, R, O, R, R, O,
    O, O, R, R, T, O, R, R, R, R, O, O, O, O, O, O,
    O, A, R, C, R, O, O, G, R, O, O, R, O, R, R, O,
    O, O, R, R, T, O, R, R, R, R, O, O, O, O, O, O,
    O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O,
    O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O,
    O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O,
    O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O,
    O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O,
    O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O,
    O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O,
    O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O
  };

 constexpr static uint8_t DECODE_MAP[4] = { 'A', 'C', 'G', 'T' };
};
static_assert(DNAKMer<3>::BUFFER_LEN == 1);
static_assert(DNAKMer<4>::BUFFER_LEN == 1);
static_assert(DNAKMer<5>::BUFFER_LEN == 2);
static_assert(DNAKMer<1>::KMER_MASK == 0b11);
static_assert(DNAKMer<2>::KMER_MASK == 0b1111);
static_assert(DNAKMer<3>::KMER_MASK == 0b111111);
static_assert(DNAKMer<4>::KMER_MASK == 0b11111111);

/// An always-full circular buffer.
/// Use memmove to keep the head at the beginning of the buffer.
/// Maybe faster than the offset variant.
template <typename T, size_t N>
class CircularBufferMove {
 public:
  CircularBufferMove() { data_.fill(T()); }
  CircularBufferMove(const std::array<T, N> &data) : data_(data) {}

  void push(const T &data) {
    this->shl();
    data_[N - 1] = data;
  }

  // Insert the data without shifting
  void insert(const size_t i, const T& data) {
    data_[i] = data;
  }

  void copy_to(std::array<T, N> *dst) { copy_to(*dst); }

  void copy_to(std::array<T, N> &dst) { dst = data_; }

  void copy_to(T *dst) { memcpy(dst, data_.data(), N * sizeof(T)); }

 private:
  /// Shift `data_` to the left by 1.
  void shl() {
    if constexpr (N == 1) {
      // noop
    } else if constexpr (sizeof(T) == 1 && N <= 3) {
      // optimization.
      uint16_t *dst = (uint16_t *)(data_.data());
      uint16_t *src = (uint16_t *)(data_.data() + 1);
      *dst = *src;
    } else if constexpr (sizeof(T) == 1 && N <= 5) {
      // Possible issue with misalignment?
      uint32_t *dst = (uint32_t *)(data_.data());
      uint32_t *src = (uint32_t *)(data_.data() + 1);
      *dst = *src;
    } else if constexpr (sizeof(T) == 1 && N <= 9) {
      uint64_t *dst = (uint64_t *)(data_.data());
      uint64_t *src = (uint64_t *)(data_.data() + 1);
      *dst = *src;
    } else {
      // General case
      memmove(data_.data(), data_.data() + 1, N - 1);
    }
  }

  std::array<T, N> data_;
  // One more element to reserve memory for the shl optimization.
  T dummy_;
};

/// An always-full circular buffer.
/// Use offset to keep track of head and tail.
template <typename T, size_t N>
class CircularBuffer {
 public:
  CircularBuffer() : offset_(0) { data_.fill(T()); }
  CircularBuffer(const std::array<T, N> &data) : data_(data), offset_(N - 1) {}

  void push(const T &data) {
    data_[offset_] = data;
    offset_ = (offset_ + 1) % N;
  }

  void copy_to(std::array<T, N> *dst) { copy_to(*dst); }

  void copy_to(std::array<T, N> &dst) { copy_to(dst.data()); }

  // For example, let `|` be the offset:
  // N=3, offset_=2: [1 2 | 3] -> [3 1 2]
  // N=3, offset_=0: [1 2 3 |] -> [1 2 3]
  void copy_to(T *dst) {
    // Copy first half.
    const auto first_half_size = N - offset_;
    memcpy(dst, data_.data() + offset_, first_half_size * sizeof(T));
    // Copy second half.
    const auto second_half_size = N - first_half_size;
    memcpy(dst + first_half_size, data_.data(), second_half_size * sizeof(T));
    // PLOG_INFO << "Offset " << offset_ << " first half " << first_half_size <<
    // " second half " << second_half_size; for (int i = 0 ; i < N; i ++ ) {
    //   std::cerr << data_[i] << " ";
    // }
    // std::cerr << std::endl;
  }

  uint32_t offset() { return offset_; }

 private:
  std::array<T, N> data_;
  /// Indicate the current tail
  /// Range: [0, N)
  uint32_t offset_;
  static_assert(N < (1 << (sizeof(offset_) * 8 - 1)),
                "N is too large; not addressable by offset_");
};

template <size_t N>
using CircularBufferU8 = CircularBuffer<uint8_t, N>;

}  // namespace kmercounter
#endif  // UTILS_CIRCULAR_BUFFER_HPP
