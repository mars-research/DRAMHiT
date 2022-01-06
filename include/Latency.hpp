#ifndef _LATENCY_HPP
#define _LATENCY_HPP

#include <plog/Log.h>
#include <x86intrin.h>

#include <array>
#include <cassert>
#include <cstddef>
#include <cstdint>
#include <fstream>
#include <numeric>
#include <sstream>
#include <thread>

#include "sync.h"

namespace kvstore {
template <std::size_t capacity>
class LatencyCollector {
  using timer_type = std::uint16_t;
  static constexpr auto sentinel = std::numeric_limits<std::uint64_t>::max();

 public:
  std::uint64_t start() {
    const auto time = __rdtsc();
    _mm_lfence();  // Ensure that the later element loads occur after the
                   // timestamp read
    const auto id = allocate();
    if (id == sentinel) {
      PLOG_ERROR << "Invalid time id\n";
      std::terminate();
    }

    assert(timers.at(id) == 0);
    timers.at(id) = time;
    return id;
  }

  void end(std::uint64_t id) {
    unsigned int aux;
    const auto stop =
        __rdtscp(&aux);  // all prior loads will have completed by now
    if (id == sentinel) return;
    static constexpr auto max_time = std::numeric_limits<timer_type>::max();
    assert(timers.at(id) != 0);
    const auto time = stop - timers.at(id);
    timers.at(id) = 0;
    free(id);
    push(time <= max_time ? static_cast<timer_type>(time) : max_time);
  }

  void dump() {
    std::stringstream stream{};
    stream << "latencies/" << std::this_thread::get_id() << ".dat";
    std::ofstream stats{stream.str().c_str()};
    for (const auto& line : log)
      for (auto time : line) stats << static_cast<unsigned int>(time) << "\n";
  }

 private:
  alignas(64) std::array<std::uint64_t, capacity> timers{};
  alignas(64) std::array<std::uint64_t, capacity / 64> bitmap{};

  // cachelines
  alignas(64)
      std::array<std::array<timer_type, 64 / sizeof(timer_type)>, 4096> log{};

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

    if (skipped == bitmap.size()) std::terminate();
    const auto leftmost_zero =
        bitmap[skipped] ? __builtin_ctzll(bitmap[skipped]) - 1
                        : 63;  // Mysteriously, this sometimes returns -1

    // For some reason, the bitmap appears to start filling from the 31st--not the 63rd--bit
    if (leftmost_zero < 0 || leftmost_zero > 63) {
      PLOG_ERROR << "Leftmost zero was: " << leftmost_zero;
      PLOG_ERROR << "Skipped was: " << skipped;
      PLOG_ERROR << "Bitmap was: " << bitmap[skipped];
      std::terminate();
    }

    bitmap[skipped] |= 1ull << leftmost_zero;

    return skipped * 64 + leftmost_zero;
  }

  void push(timer_type time) {
    if (next_slot == log.front().size()) {
      if (next_log_entry == log.size() - 1) return;

      next_slot = 0;
      ++next_log_entry;
    }

    log[next_log_entry][next_slot++] = time;
  }
};

#ifdef LATENCY_COLLECTION
constexpr auto pool_size = 2048;
extern thread_local LatencyCollector<pool_size> collector;
#endif
}  // namespace kvstore

#endif
