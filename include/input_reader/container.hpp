#ifndef INPUT_READER_ITERATOR_HPP
#define INPUT_READER_ITERATOR_HPP

#include <iterator>
#include <vector>

#include "input_reader.hpp"

namespace kmercounter {
namespace input_reader {
/// Produce the values within the iterators [begin, end).
template <class ForwardIterator,
          typename T =
              typename std::iterator_traits<ForwardIterator>::value_type>
class RangeReader : public SizedInputReader<T> {
 public:
  RangeReader(ForwardIterator begin, ForwardIterator end)
      : curr_(begin), end_(end), size_(end - begin) {}

  bool next(T* data) override {
    if (curr_ == end_) {
      return false;
    }
    *data = *(curr_++);
    return true;
  }

  size_t size() override { return size_; }

 private:
  ForwardIterator curr_;
  ForwardIterator end_;
  size_t size_;
};

template <class T, class iterator = typename std::vector<T>::const_iterator>
class VecReader : public RangeReader<iterator> {
 public:
  VecReader(const std::vector<T>& data_)
      : RangeReader<iterator>(data_.begin(), data_.end()) {}
};
}  // namespace input_reader
}  // namespace kmercounter
#endif  // INPUT_READER_ITERATOR_HPP
