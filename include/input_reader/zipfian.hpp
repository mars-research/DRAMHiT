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
  ZipfianGenerator(double skew, uint64_t keyrange_width, unsigned int seed)
      : distribution_(zipf_distribution{skew, keyrange_width, seed}) {}

  bool next(T *data) override {
    *data = distribution_();
    return true;
  }

 private:
  zipf_distribution distribution_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_ZIPFIAN_HPP
