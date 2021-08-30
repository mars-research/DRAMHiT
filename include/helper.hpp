#ifndef __HELPER_HPP__
#define __HELPER_HPP__

namespace kmercounter {
constexpr uint64_t next_pow2(uint64_t v) {
  return (1ULL << (64 - __builtin_clzl(v - 1)));
}

}  // namespace kmercounter

#endif  // __HELPER_HPP__
