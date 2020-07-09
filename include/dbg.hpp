#ifndef __DBG_HPP__
#define __DBG_HPP__

#define dbg(format, ...)                                                  \
  do {                                                                    \
    fprintf(stderr, "[DEBUG] [%s:%d (%s)] : " format, __FILE__, __LINE__, \
            __func__, ##__VA_ARGS__);                                     \
  } while (0)

#endif  // __DBG_HPP__
