#ifndef INPUT_READER_ITERATOR_HPP
#define INPUT_READER_ITERATOR_HPP

#include <iterator>
#include <vector>

#include "input_reader.hpp"

namespace kmercounter {
namespace input_reader {
/// Produce the values within the iterators [begin, end).
template <class ForwardIterator,
          typename T = std::iterator_traits<ForwardIterator>::value_type>
class RangeReader : public InputReader<T> {
 public:
  RangeReader(ForwardIterator begin, ForwardIterator end)
      : curr_(begin), end_(end) {}

  bool next(T* data) override {
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

template <class T, class iterator = std::vector<T>::const_iterator>
class VecReader : public RangeReader<iterator> {
 public:
  VecReader(const std::vector<T>& data_)
      : RangeReader<iterator>(data_.begin(), data_.end()) {}
};
}  // namespace input_reader
}  // namespace kmercounter
#endif  // INPUT_READER_ITERATOR_HPP
