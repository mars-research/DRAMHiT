#ifndef INPUT_READER_COUNTER_HPP
#define INPUT_READER_COUNTER_HPP

#include "input_reader.hpp"

/// Sequentially incrementin counter.
template<class T>
class Counter : public InputReader<T> {
    public:
    Counter(T start) : data(start) {}

    std::optional<T> next() override {
        return data++;
    }

private:
    T data;
};

#endif // INPUT_READER_COUNTER_HPP
