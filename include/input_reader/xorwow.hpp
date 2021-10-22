#ifndef INPUT_READER_XORWOW_HPP
#define INPUT_READER_XORWOW_HPP

#include "misc_lib.h"
#include "input_reader.hpp"

template<class T>
class XorwowGenerator : public InputReader<T> {
    XorwowGenerator() {
        xorwow_init(&this->xw_state);
    }

    T next() override {
        return xorwow(&_xw_state);
    }

private:
    xorwow_state xw_state;
};

#endif // INPUT_READER_XORWOW_HPP
