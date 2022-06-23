#ifndef INPUT_READER_ADAPTOR_HPP
#define INPUT_READER_ADAPTOR_HPP

#include <memory>
#include <string>

#include "input_reader.hpp"

namespace kmercounter {
namespace input_reader {
// Convert one InputReader to another.
template <class From, class To>
class Adaptor : public InputReader<To> {
 public:
  Adaptor(std::unique_ptr<InputReader<From>> reader)
      : reader_(std::move(reader)) {}

  bool next(To *data) override {
    From tmp;
    if (!reader_->next(&tmp)) {
      return false;
    }
    *data = tmp;
    return true;
  }

 private:
  std::unique_ptr<InputReader<From>> reader_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_ADAPTOR_HPP
