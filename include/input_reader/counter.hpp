#ifndef INPUT_READER_COUNTER_HPP
#define INPUT_READER_COUNTER_HPP

#include "input_reader.hpp"

namespace kmercounter {
namespace input_reader {
/// Sequentially incrementin counter.
template<class T>
class Counter : public InputReader<T> {
    public:
    Counter(T start) : data_(start) {}

    bool next(T *data) override {
        *data = data_++;
        return true;
    }

private:
    T data_;
};
} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_COUNTER_HPP
