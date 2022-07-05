#ifndef CONSTANTS_HPP
#define CONSTANTS_HPP

#include <cstdint>

namespace kmercounter {
constexpr int FLUSH_THRESHOLD = 32;
constexpr int INS_FLUSH_THRESHOLD = 32;
constexpr int KV_SIZE = 16;  // 8-byte key + 8-byte value

constexpr uint32_t PREFETCH_QUEUE_SIZE = 64;
constexpr uint32_t PREFETCH_FIND_QUEUE_SIZE = 64;

constexpr uint32_t HT_TESTS_BATCH_LENGTH = 16;
constexpr uint32_t HT_TESTS_FIND_BATCH_LENGTH = 16;
constexpr uint32_t HT_TESTS_MAX_STRIDE = 2;
} // namespace kmercounter

#endif /* CONSTANTS_HPP */
