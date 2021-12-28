#ifndef _LATENCY_HPP
#define _LATENCY_HPP

#include <array>
#include <cassert>
#include <cstddef>
#include <cstdint>
#include <numeric>

namespace kvstore {
template <std::size_t capacity>
class LatencyCollector {
  static constexpr auto sentinel = std::numeric_limits<std::uint64_t>::max();

 public:
  std::uint64_t start(std::uint64_t time) {
    const auto id = allocate();
    if (id == sentinel) return id;
    timers.at(id) = time;
    return id;
  }

  void end(std::uint64_t stop, std::uint64_t id) {
    static constexpr auto max_time = std::numeric_limits<std::uint8_t>::max();
    const auto time = stop - timers.at(id);
    free(id);
    push(time <= max_time ? static_cast<std::uint8_t>(time) : max_time);
  }

 private:
  alignas(64) std::array<std::uint64_t, capacity> timers{};
  alignas(64) std::array<std::uint64_t, capacity / 64> bitmap{};

  // cacheline
  alignas(64) std::array<std::uint8_t, 64> line_a{};
  static_assert(sizeof(line_a) == 64);

  // cacheline
  alignas(64) std::array<std::uint8_t, 64> line_b{};
  static_assert(sizeof(line_b) == 64);

  // cacheline
  alignas(64) bool use_line_a{};
  std::uint8_t next_slot{};
  std::uint64_t next_log_entry{};

  void free(std::uint64_t id) {}

  std::uint64_t allocate() {
    auto skipped = 0ull;
    for (; skipped < bitmap.size() && bitmap[skipped] == sentinel; ++skipped)
      ;

    if (skipped == bitmap.size()) return sentinel;
    const auto leftmost_zero = __builtin_ctzll(bitmap[skipped]) - 1;
    bitmap[skipped] |= 1ull << leftmost_zero;

    return skipped * 64 + leftmost_zero;
  }

  void push(std::uint8_t time) {}
};
}  // namespace kvstore

#endif
