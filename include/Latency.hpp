#ifndef _LATENCY_HPP
#define _LATENCY_HPP

#include <array>
#include <cstddef>
#include <cstdint>

namespace kvstore {
template <std::size_t capacity>
class LatencyCollector {
 public:
 private:
  alignas(64) std::array<std::uint64_t, capacity> timers {};
  alignas(64) std::array<std::uint64_t, capacity / 64> bitmap {};

  // cacheline
  alignas(64) std::array<std::uint8_t, 64> line_a {};
  static_assert(sizeof(line_a) == 64);

  // cacheline
  alignas(64) std::array<std::uint8_t, 64> line_b {};
  static_assert(sizeof(line_b) == 64);

  // cacheline
  alignas(64) bool use_line_a {};
  std::uint8_t next_slot {};
  std::uint64_t next_log_entry {};
};
}  // namespace kvstore

#endif
