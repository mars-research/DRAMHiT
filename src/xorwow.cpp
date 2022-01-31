#include "xorwow.hpp"

#include <cstdlib>

void xorwow_init(xorwow_state *s) {
  s->a = rand();
  s->b = rand();
  s->c = rand();
  s->d = rand();
  s->counter = rand();
}

/* The state array must be initialized to not be all zero in the first four
 * words */
uint32_t xorwow(xorwow_state *state) {
  /* Algorithm "xorwow" from p. 5 of Marsaglia, "Xorshift RNGs" */
  uint32_t t = state->d;

  uint32_t const s = state->a;
  state->d = state->c;
  state->c = state->b;
  state->b = s;

  t ^= t >> 2;
  t ^= t << 1;
  t ^= s ^ (s << 4);
  state->a = t;

  state->counter += 362437;
  return t + state->counter;
}