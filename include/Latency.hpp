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
    if (id == sentinel)
      return;

    static constexpr auto max_time = std::numeric_limits<std::uint8_t>::max();
    const auto time = stop - timers.at(id);
    free(id);
    push(time <= max_time ? static_cast<std::uint8_t>(time) : max_time);
  }

 private:
  alignas(64) std::array<std::uint64_t, capacity> timers{};
  alignas(64) std::array<std::uint64_t, capacity / 64> bitmap{};

  // cachelines
  alignas(64) std::array<std::array<std::uint8_t, 64>, 1 << 16> log{};

  // cacheline
  alignas(64) std::uint8_t next_slot{};
  std::uint64_t next_log_entry{};

  void free(std::uint64_t id) {
    const auto i = id >> 6;
    const auto bit = id & 0b111111;
    bitmap[i] &= ~(1ull << bit);
  }

  std::uint64_t allocate() {
    auto skipped = 0ull;
    for (; skipped < bitmap.size() && bitmap[skipped] == sentinel; ++skipped)
      ;

    if (skipped == bitmap.size()) return sentinel;
    const auto leftmost_zero = __builtin_ctzll(bitmap[skipped]) - 1;
    bitmap[skipped] |= 1ull << leftmost_zero;

    return skipped * 64 + leftmost_zero;
  }

  void push(std::uint8_t time) {
    if (next_slot == 64) {
      if (next_log_entry == log.size() - 1)
        return;

      next_slot = 0;
      ++next_log_entry;
    }

    log[next_log_entry][next_slot++] = time;
  }
};
}  // namespace kvstore

#endif
