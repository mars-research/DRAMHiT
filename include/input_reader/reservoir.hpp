#ifndef INPUT_READER_RESERVIOR_HPP
#define INPUT_READER_RESERVIOR_HPP

#include <memory>
#include <vector>

#include "input_reader.hpp"
#include "input_reader/container.hpp"

namespace kmercounter {
namespace input_reader {
/// Empty a input reader into a vector and produce the content from the vector.
/// This is good for preloading the dataset into memory
/// before running experiments.
template <typename T>
class Reservoir : public InputReader<T> {
 public:
  Reservoir(std::unique_ptr<InputReader<T>> reader) : reader_(reservoir_) {
    for (T data; reader->next(&data);) {
      reservoir_.push_back(data);
    }
    reader_ = VecReader<T>(reservoir_);
  }

  bool next(T *output) override {
    return reader_.next(output);
  }

  size_t size() {
    return reservoir_.size();
  }

 private:
  std::vector<T> reservoir_;
  VecReader<T> reader_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_RESERVIOR_HPP
