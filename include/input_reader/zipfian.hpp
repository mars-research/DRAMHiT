#ifndef INPUT_READER_ZIPFIAN_HPP
#define INPUT_READER_ZIPFIAN_HPP

#include <vector>

#include "input_reader.hpp"
#include "input_reader/container.hpp"
#include "zipf.h"

namespace kmercounter {
namespace input_reader {
/// Generate numbers in zipfian distribution.
/// The numbers are pre-generated and buffered in the
/// constructor.
template <class T>
class ZipfianGenerator : public InputReader<T> {
 public:
  ZipfianGenerator(double skew, uint64_t keyrange_width, unsigned int seed,
                   uint64_t buffsize) {
    zipf_distribution distribution{skew, keyrange_width, seed};
    values_ = std::vector<T>(buffsize);
    for (auto &value : values_) value = distribution();
    reader_ = VecReader(values);
  }

  bool next(T *data) override {
    return reader_.next(data);
  }

 private:
  std::vector<T> values_;
  VecReader<T> reader_;
  typename std::vector<T>::iterator iter_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_ZIPFIAN_HPP
