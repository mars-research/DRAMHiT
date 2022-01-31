#ifndef INPUT_READER_ZIPFIAN_HPP
#define INPUT_READER_ZIPFIAN_HPP

#include <vector>

#include "input_reader_base.hpp"
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
        this->value = std::vector<T>(buffsize);
        for (auto &value : this->values) value = distribution();
        this->iter = values.begin();
    }

    bool next(T *data) override {
        if (this->iter == this->values.end()) {
            return false;
        }
        *data = *(this->iter++);
        return true;
    }

private:
    std::vector<T> values;
    typename std::vector<T>::iterator iter;
};
} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_ZIPFIAN_HPP
