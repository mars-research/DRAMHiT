#include "xorwow.hpp"



void xorwow_init(xorwow_state *s) {
  s->a = rand();
  s->b = rand();
  s->c = rand();
  s->d = rand();
  s->counter = rand();
}

// void xorwow_init(xorwow_state *s) {
//     int fd = open("/dev/urandom", O_RDONLY);
//     if (fd < 0) {
//         perror("open /dev/urandom");
//         exit(EXIT_FAILURE);
//     }

//     size_t to_read = sizeof(*s);
//     uint8_t *buf = (uint8_t *)s;

//     while (to_read > 0) {
//         ssize_t n = read(fd, buf, to_read);
//         if (n <= 0) {
//             perror("read /dev/urandom");
//             close(fd);
//             exit(EXIT_FAILURE);
//         }
//         buf += n;
//         to_read -= n;
//     }

//     close(fd);
// }

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