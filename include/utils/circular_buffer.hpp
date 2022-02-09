#ifndef UTILS_CIRCULAR_BUFFER_HPP
#define UTILS_CIRCULAR_BUFFER_HPP

#include <array>
#include <cstring>

#include "plog/Log.h"

namespace kmercounter {
/// An always-full circular buffer.
template <typename T, size_t N>
class CircularBuffer {
public:
  CircularBuffer() : offset_(0) {}
  CircularBuffer(const std::array<T, N>& data) : data_(data), offset_(N - 1) {}

  void push(const T& data) {
    data_[offset_] = data;
    offset_ = (offset_ + 1) % N;
  }

  void copy_to(std::array<T, N> *dst) {
    copy_to(*dst);
  }

  void copy_to(std::array<T, N> &dst) {
    copy_to(dst.data());
  }

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
    // PLOG_INFO << "Offset " << offset_ << " first half " << first_half_size << " second half " << second_half_size;
    // for (int i = 0 ; i < N; i ++ ) {
    //   std::cerr << data_[i] << " "; 
    // }
    // std::cerr << std::endl;
  }

  uint32_t offset() {
    return offset_;
  }

private:
  std::array<T, N> data_;
  /// Indicate the current tail
  /// Range: [0, N)
  uint32_t offset_;
  static_assert(N < (1 << (sizeof(offset_)*8 - 1)), "N is too large; not addressable by offset_");
};

template <size_t N>
using CircularBufferU8 = CircularBuffer<uint8_t, N>;

} // namespace kmercounter
#endif // UTILS_CIRCULAR_BUFFER_HPP
