#ifndef INPUT_READER_REPEATER_HPP
#define INPUT_READER_REPEATER_HPP

#include "input_reader_base.hpp"

namespace kmercounter {
namespace input_reader {
/// Repeat the same value over and over again.
template<class T>
class Repeater : public InputReader<T> {
public:
    Repeater(T data) : data(data) {}

    std::optional<T> next() override {
        return data;
    }


private:
    T data;
};
} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_REPEATER_HPP
