#ifndef XORWOW_HPP
#define XORWOW_HPP

#include <cstdint>

struct xorwow_state {
  uint32_t a, b, c, d;
  uint32_t counter;
};

void xorwow_init(xorwow_state *);
uint32_t xorwow(xorwow_state *);

#endif /* XORWOW_HPP */
