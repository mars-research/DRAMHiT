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

#include "misc_lib.h"
#include "sync.h"

namespace kvstore {
using timer_type = std::uint16_t;

template <std::size_t capacity>
class LatencyCollector {
  static constexpr auto sentinel = std::numeric_limits<std::uint64_t>::max();

 public:
  std::uint64_t start() {
    if (reject_sample()) return sentinel;

    const auto id = allocate();
    const auto time = __rdtsc();
    timers[id] = time;
    _mm_lfence();

    return id;
  }

  void end(std::uint64_t id) {
    if (id == sentinel) return;

    unsigned int aux;
    const auto stop =
        __rdtscp(&aux);  // all prior loads will have completed by now

    const auto time = stop - timers[id];
    free(id);

    static constexpr auto max_time = std::numeric_limits<timer_type>::max();
    push(time <= max_time ? static_cast<timer_type>(time) : max_time);
  }

  std::uint64_t sync_start() {
    if (reject_sample()) return sentinel;
    const auto time = __rdtsc();
    _mm_lfence();
    return time;
  }

  void sync_end(std::uint64_t start) {
    if (start == sentinel) return;

    unsigned int aux;
    const auto stop =
        __rdtscp(&aux);  // all prior loads will have completed by now

    const auto time = stop - start;

    static constexpr auto max_time = std::numeric_limits<timer_type>::max();
    push(time <= max_time ? static_cast<timer_type>(time) : max_time);
  }

  void dump() {
    std::stringstream stream{};
    stream << "latencies/" << std::this_thread::get_id() << ".dat";
    std::ofstream stats{stream.str().c_str()};
    for (auto i = 0u; i <= next_log_entry && i < log.size(); ++i) {
      const auto length = i < next_log_entry ? log.front().size() : next_slot;
      for (auto j = 0u; j < length; ++j) stats << static_cast<unsigned int>(log[i][j]) << "\n";
    }
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

  alignas(64) xorwow_state rand_state{[] {
    xorwow_state state{};
    xorwow_init(&state);
    return state;
  }()};

  bool reject_sample() {
    constexpr auto pow2 = 4u;
    constexpr auto bitmask = (1ull << pow2) - 1;
    return xorwow(&rand_state) & bitmask;
  }

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
    const auto rightmost_zero = __builtin_ctzll(~bitmap[skipped]);

    // For some reason, the bitmap appears to start filling from the 31st--not
    // the 63rd--bit
    if (rightmost_zero < 0 || rightmost_zero > 63) {
      PLOG_ERROR << "Rightmost zero was: " << rightmost_zero;
      PLOG_ERROR << "Skipped was: " << skipped;
      PLOG_ERROR << "Bitmap was: " << bitmap[skipped];
      std::terminate();
    }

    bitmap[skipped] |= 1ull << rightmost_zero;

    return skipped * 64 + rightmost_zero;
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
