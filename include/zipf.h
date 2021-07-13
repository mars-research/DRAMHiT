#ifndef __ZIPF_H__
#define __ZIPF_H__

#include <cmath>
#include <cstdint>
#include <limits>

namespace kmercounter {
/*  Adapted from the code included on Sebastian Vigna's website */
// From: https://en.wikipedia.org/wiki/Xorshift
namespace xoshiro256 {
std::uint64_t rol64(std::uint64_t x, int k) noexcept {
  return (x << k) | (x >> (64 - k));
}

struct state {
  std::uint64_t s[4];
};

std::uint64_t next(struct state *state) noexcept {
  std::uint64_t *s = state->s;
  std::uint64_t const result = rol64(s[1] * 5, 7) * 9;
  std::uint64_t const t = s[1] << 17;

  s[2] ^= s[0];
  s[3] ^= s[1];
  s[1] ^= s[2];
  s[0] ^= s[3];

  s[2] ^= t;
  s[3] = rol64(s[3], 45);

  return result;
}
}  // namespace xoshiro256

class xoshiro {
 public:
  using result_type = std::uint64_t;

  xoshiro() : m_state{{0x0, 0x0, 0x0, 0x1}} {}

  static constexpr auto min() noexcept {
    return std::numeric_limits<std::uint64_t>::min();
  }

  static constexpr auto max() noexcept {
    return std::numeric_limits<std::uint64_t>::max();
  }

  std::uint64_t operator()() noexcept { return xoshiro256::next(&m_state); }

 private:
  xoshiro256::state m_state{};
};

class xoshiro_real {
 public:
  auto operator()() noexcept {
    return (m_uniform() >> 11) *
           0x1.0p-53;  // Don't ask, got this from Marsaglia et al
  }

 private:
  xoshiro m_uniform{};
};

class zipf_distribution {
 public:
  zipf_distribution() = default;

  zipf_distribution(double skew, unsigned int maximum) : zipf_distribution{} {
    double value{};
    m_harmonics.reserve(maximum + 1);
    m_harmonics.emplace_back();
    for (int i{1}; i <= maximum; ++i) {
      value += 1 / std::pow(i, skew);
      m_harmonics.emplace_back(value);
    }

    m_n_harmonic = value;
  }

  std::uint64_t operator()() {
    return inverse_harmonic(m_n_harmonic * m_uniform()) - 1;
  }

 private:
  std::vector<double> m_harmonics{};
  double m_n_harmonic{};
  xoshiro_real m_uniform{};

  std::uint64_t inverse_harmonic(double n) const {
    std::size_t left{};
    std::size_t right{m_harmonics.size()};
    while (left < right - 1) {
      const auto middle = (right + left) / 2;
      if (m_harmonics.at(middle) > n)
        right = middle;
      else
        left = middle;
    }

    return left + 1;
  }
};
}  // namespace kmercounter

#endif
