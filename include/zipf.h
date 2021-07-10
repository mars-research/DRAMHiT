#ifndef __ZIPF_H__
#define __ZIPF_H__

#include <cmath>
#include <cstdint>
#include <limits>

namespace kmercounter {
/*  Adapted from the code included on Sebastian Vigna's website */
// From: https://en.wikipedia.org/wiki/Xorshift
namespace xoshiro256 {
    std::uint64_t rol64(std::uint64_t x, int k) noexcept
    {
        return (x << k) | (x >> (64 - k));
    }

    struct state {
        std::uint64_t s[4];
    };

    std::uint64_t next(struct state *state) noexcept
    {
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
}

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

// Computes with a skewness of 1
template <std::uint64_t width>
class zipf_distribution {
 public:
  zipf_distribution() : m_n_harmonic{harmonic(width + 1)}, m_uniform{} {}

  std::uint64_t operator()() noexcept {
    return inverse_harmonic((m_n_harmonic - euler_mascheroni) * m_uniform() +
                            euler_mascheroni) -
           1;
  }

 private:
  constexpr static auto euler_mascheroni = 0.577215664901532860606512090082;

  double m_n_harmonic{};
  xoshiro_real m_uniform{};

  // The range of this function is [1, width]
  // This is the source of the apparent dip in the log-log graph: near the head,
  // this is a poorer approximation
  std::uint64_t inverse_harmonic(double n) {
    return static_cast<std::uint64_t>(std::exp(n - euler_mascheroni));
  }

  // Approximate computation of the Nth harmonic number
  constexpr double harmonic(std::uint64_t n) {
    return euler_mascheroni + std::log(n);
  }
};
}  // namespace kmercounter

#endif
