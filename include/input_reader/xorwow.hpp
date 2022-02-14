#ifndef INPUT_READER_XORWOW_HPP
#define INPUT_READER_XORWOW_HPP

#include "input_reader.hpp"
#include "misc_lib.h"

namespace kmercounter {
namespace input_reader {
template <class T>
class XorwowGenerator : public InputReader<T> {
  XorwowGenerator() { xorwow_init(&this->xw_state_); }

  bool next(T *data) override {
    *data = xorwow(&xw_state_);
    return true;
  }

 private:
  xorwow_state xw_state_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_XORWOW_HPP
