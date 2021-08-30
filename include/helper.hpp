#ifndef __HELPER_HPP__
#define __HELPER_HPP__

namespace kmercounter {
constexpr uint64_t next_pow2(uint64_t v) {
  return (1ULL << (64 - __builtin_clzl(v - 1)));
}

inline uint64_t skipmod(uint64_t v, uint64_t max)
{
  if (v < max)
    return v;
  else if (v < 2 * max)
    return v - max;
  else
    return v % max;
}

}  // namespace kmercounter

#endif  // __HELPER_HPP__
