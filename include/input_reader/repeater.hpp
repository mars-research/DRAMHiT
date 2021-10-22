#ifndef INPUT_READER_REPEATER_HPP
#define INPUT_READER_REPEATER_HPP

#include "input_reader.hpp"

/// Repeat the same value over and over again.
template<class T>
class Repeater : public InputReader<T> {
public:
    Repeater(T data) : data(data) {}

    T next() override {
        return data;
    }


private:
    T data;
};

#endif // INPUT_READER_REPEATER_HPP
