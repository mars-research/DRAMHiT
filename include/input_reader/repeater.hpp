#ifndef INPUT_READER_REPEATER_HPP
#define INPUT_READER_REPEATER_HPP

#include "input_reader.hpp"

namespace kmercounter {
namespace input_reader {
/// Repeat the same value over and over again.
template <class T>
class Repeater : public InputReader<T> {
 public:
  Repeater(T data) : data_(data) {}

  bool next(T *data) override {
    *data = data_;
    return true;
  }

 private:
  T data_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_REPEATER_HPP
