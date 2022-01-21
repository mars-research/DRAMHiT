#ifndef INPUT_READER_XORWOW_HPP
#define INPUT_READER_XORWOW_HPP

#include "misc_lib.h"
#include "input_reader_base.hpp"

namespace kmercounter {
namespace input_reader {
template<class T>
class XorwowGenerator : public InputReader<T> {
    XorwowGenerator() {
        xorwow_init(&this->xw_state);
    }

    std::optional<T> next() override {
        return xorwow(&_xw_state);
    }

private:
    xorwow_state _xw_state;
};
} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_XORWOW_HPP
