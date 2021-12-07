#ifndef INPUT_READER_ZIPFIAN_HPP
#define INPUT_READER_ZIPFIAN_HPP

#include <vector>

#include "input_reader.hpp"

/// Generate numbers in zipfian distribution.
/// The numbers are pre-generated and buffered in the 
/// constructor.
template<class T>
class ZipfianGenerator : public InputReader {
public:
    ZipfianGenerator(double skew, uint64_t keyrange_width, unsigned int seed, uint64_t buffsize) {
        zipf_distribution distribution{skew, keyrange_width, seed};
        this->value = std::vector<T>(buffsize);
        for (auto &value : this->values) value = distribution();
        this->iter = values.begin();
    }

    std::optional<T> next() override {
        if (this->iter == this->values.end()) {
            return std::nullopt;
        }
        return *(this->iter++);
    }

private:
    std::vector<T> values;
    std::vector<T>::iterator iter;
}


  

#endif // INPUT_READER_ZIPFIAN_HPP
