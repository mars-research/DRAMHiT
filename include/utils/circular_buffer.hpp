#ifndef UTILS_CIRCULAR_BUFFER_HPP
#define UTILS_CIRCULAR_BUFFER_HPP

#include <array>

/// A always-full circular buffer.
template <size_t N>
class CircularBuffer {
public:
  CircularBuffer() = default;
  CircularBuffer(const std::array<uint8_t, N>& data) : data_(data), offset_(N - 1) {}

private:
  std::array<uint8_t, N> data_;
  uint32_t offset_;
};

#endif // UTILS_CIRCULAR_BUFFER_HPP
