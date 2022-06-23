#ifndef INPUT_READER_STRING_VIEW_HPP
#define INPUT_READER_STRING_VIEW_HPP

#include <string_view>

#include "input_reader.hpp"
#include "input_reader/container.hpp"

namespace kmercounter {
namespace input_reader {
template <class T>
class StringViewReader : public SizedInputReader<T> {
 public:
  StringViewReader(std::basic_string_view<T> data)
      : data_(data), iter_(data_.begin(), data_.end()) {}

  bool next(T *data) override { return iter_.next(data); }

  size_t size() override { return data_.size(); }

 private:
  std::basic_string_view<T> data_;
  RangeReader<decltype(data_.begin()), T> iter_;
};
}  // namespace input_reader
}  // namespace kmercounter
#endif  // INPUT_READER_STRING_VIEW_HPP
