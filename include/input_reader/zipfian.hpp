#ifndef INPUT_READER_ZIPFIAN_HPP
#define INPUT_READER_ZIPFIAN_HPP

#include <vector>

#include "input_reader.hpp"
#include "zipf.h"

namespace kmercounter {
namespace input_reader {
/// Generate numbers in zipfian distribution.
/// The numbers are pre-generated and buffered in the 
/// constructor.
template<class T>
class ZipfianGenerator : public InputReader<T> {
public:
    ZipfianGenerator(double skew, uint64_t keyrange_width, unsigned int seed, uint64_t buffsize) {
        zipf_distribution distribution{skew, keyrange_width, seed};
        values_ = std::vector<T>(buffsize);
        for (auto &value : values_) value = distribution();
        iter_ = values_.begin();
    }

    bool next(T *data) override {
        if (iter_ == values_.end()) {
            return false;
        }
        *data = *(iter_++);
        return true;
    }

private:
    std::vector<T> values_;
    typename std::vector<T>::iterator iter_;
};
} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_ZIPFIAN_HPP
