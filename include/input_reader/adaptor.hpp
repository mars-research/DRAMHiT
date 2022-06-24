#ifndef INPUT_READER_ADAPTOR_HPP
#define INPUT_READER_ADAPTOR_HPP

#include <memory>
#include <string>

#include "input_reader.hpp"

namespace kmercounter {
namespace input_reader {
// Convert one InputReader to another via memcpy.
// TODO: use concept to constrain base class.
template <class FromReader, class ToValue>
class Adaptor : public InputReader<ToValue> {
 public:
  Adaptor(FromReader&& reader) : reader_(reader) {}

  bool next(ToValue* data) override {
    if (!reader_.next(&tmp_)) {
      return false;
    }
    *data = tmp_;
    return true;
  }

 private:
  FromReader reader_;
  FromReader::value_type tmp_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_ADAPTOR_HPP
