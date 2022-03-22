#pragma once

#include <cstdlib>

namespace kmercounter {
namespace utils {

constexpr void *zero_aligned_alloc(std::size_t alignment, std::size_t size) {
  void *mem = std::aligned_alloc(alignment, size);
  memset(mem, 0x0, size);
  return mem;
}
constexpr uint64_t next_pow2(uint64_t v) {
  return (1ULL << (64 - __builtin_clzl(v - 1)));
}

}  // namespace utils
}  // namespace kmercounter
