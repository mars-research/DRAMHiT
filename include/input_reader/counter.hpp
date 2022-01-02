#ifndef INPUT_READER_COUNTER_HPP
#define INPUT_READER_COUNTER_HPP

#include "input_reader_base.hpp"

namespace kmercounter {
namespace input_reader {
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
} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_COUNTER_HPP
