#ifndef INPUT_READER_SPAN_HPP
#define INPUT_READER_SPAN_HPP

#include <span>

#include "input_reader.hpp"
#include "input_reader/container.hpp"

namespace kmercounter {
namespace input_reader {
template <class T>
class SpanReader : public SizedInputReader<T> {
 public:
  SpanReader() : SpanReader(nullptr, 0) {}
  SpanReader(T* data, size_t size) : SpanReader(std::span<T>(data, size)) {}
  SpanReader(std::span<T> data)
      : data_(data), iter_(data_.begin(), data_.end()) {}

  bool next(T* data) override { return iter_.next(data); }

  size_t size() override { return data_.size(); }

 private:
  std::span<T> data_;
  RangeReader<decltype(data_.begin()), T> iter_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_SPAN_HPP
