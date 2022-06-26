#ifndef INPUT_READER_ADAPTOR_HPP
#define INPUT_READER_ADAPTOR_HPP

#include <memory>
#include <string>

#include "input_reader.hpp"

namespace kmercounter {
namespace input_reader {
// Convert one InputReader to another via casting.
// TODO: use concept to constrain base class.
template <class FromReader, class ToValue>
class MemcpyAdaptor : public InputReader<ToValue> {
 public:
  MemcpyAdaptor(FromReader&& reader) : reader_(reader) {}

  bool next(ToValue* data) override {
    if (!reader_.next(&tmp_)) {
      return false;
    }
    *data = tmp_;
    return true;
  }

 private:
  FromReader reader_;
  typename FromReader::value_type tmp_;
};

// Convert one InputReader to another via pointer cast.
// TODO: use concept to constrain base class.
template <class FromReader, typename ToReader>
class 
[[deprecated("This doesn't work since there's no way to have FromReader's constructor relies on ToReader without modification.")]]
PointerAdaptor : public ToReader {
 public:
  using FromValue = typename FromReader::value_type;
  using ToValue = typename ToReader::value_type;

  template <typename... Args>
  PointerAdaptor(FromReader&& reader, Args&&... args) : ToReader(args...), reader_(reader) {}

  bool next(ToValue* data) override { return reader_.next((FromValue*)data); }

 private:
  FromReader reader_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_ADAPTOR_HPP
