#ifndef INPUT_READER_ITERATOR_HPP
#define INPUT_READER_ITERATOR_HPP

#include "input_reader.hpp"

#include <iterator>

namespace kmercounter {
namespace input_reader {
/// Repeat the same value over and over again.
template<class ForwardIterator, typename T = std::iterator_traits<ForwardIterator>::value_type>
class IterReader : public InputReader<T> {
public:
    IterReader(ForwardIterator begin, ForwardIterator end) : curr_(begin), end_(end) {}

    bool next(T *data) override {
        if (curr_ == end_) {
            return false;
        }
        *data = *(curr_++);
        return true;
    }

private:
    ForwardIterator curr_;
    ForwardIterator end_;
};
} // namespace input_reader
} // namespace kmercounter
#endif // INPUT_READER_ITERATOR_HPP
