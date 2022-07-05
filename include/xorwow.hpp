/// Xorwow Random Number Generator

#ifndef XORWOW_HPP
#define XORWOW_HPP

#include <cstdint>
#include <limits>

struct xorwow_state {
  uint32_t a, b, c, d;
  uint32_t counter;
};

void xorwow_init(xorwow_state *);
uint32_t xorwow(xorwow_state *);

class xorwow_urbg {
 public:
  using result_type = decltype(xorwow(nullptr));

  result_type operator()() noexcept { return xorwow(&state); }

  constexpr auto min() noexcept {
    return std::numeric_limits<result_type>::min();
  }

  constexpr auto max() noexcept {
    return std::numeric_limits<result_type>::max();
  }

 private:
  xorwow_state state{[] {
    xorwow_state state;
    xorwow_init(&state);
    return state;
  }()};
};

#endif /* XORWOW_HPP */
