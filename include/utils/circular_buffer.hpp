#ifndef UTILS_CIRCULAR_BUFFER_HPP
#define UTILS_CIRCULAR_BUFFER_HPP

#include <array>
#include <cstring>

namespace kmercounter {
/// An always-full circular buffer.
template <typename T, size_t N>
class CircularBuffer {
public:
  CircularBuffer() : offset_(0) {}
  CircularBuffer(const std::array<T, N>& data) : data_(data), offset_(N - 1) {}

  void push(T data) {
    data_[offset_] = data;
    offset_ = (offset_ + 1) % N;
  }

  void copy_to(T *dst) {
    // Copy first half.
    const auto first_half_size = N - offset_ - 1;
    memcpy(dst, data_.data() + offset, first_half_size * sizeof(T));
    // Copy second half.
    const auto second_half_size = N - first_half_size;
    memcpy(dst + first_half_size, data_.data(), second_half_size * sizeof(T));
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
