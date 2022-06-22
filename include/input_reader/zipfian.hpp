#ifndef INPUT_READER_ZIPFIAN_HPP
#define INPUT_READER_ZIPFIAN_HPP

#include <vector>

#include "input_reader.hpp"
#include "input_reader/container.hpp"
#include "zipf.h"
#include "zipf_distribution.hpp"

namespace kmercounter {
namespace input_reader {
/// Generate numbers in zipfian distribution.
/// The numbers are pre-generated and buffered in the
/// constructor.
class ZipfianGenerator : public InputReaderU64 {
 public:
  ZipfianGenerator(double skew, uint64_t keyrange_width, unsigned int seed)
      : distribution_(zipf_distribution{skew, keyrange_width, seed}) {}

  bool next(uint64_t *data) override {
    *data = distribution_();
    return true;
  }

 private:
  zipf_distribution distribution_;
};

class ApacheZipfianGenerator : public InputReaderU64 {
 public:
  ApacheZipfianGenerator(double skew, uint64_t keyrange_width)
      : distribution_(keyrange_width, skew) {}

  bool next(uint64_t *data) override {
    *data = distribution_.sample();
    return true;
  }

 private:
  zipf_distribution_apache distribution_;
};

}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_ZIPFIAN_HPP
