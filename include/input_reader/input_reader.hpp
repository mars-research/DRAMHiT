#ifndef INPUT_READER_INPUT_READER_BASE_HPP
#define INPUT_READER_INPUT_READER_BASE_HPP

#include <cstdint>

namespace kmercounter {
namespace input_reader {
/// Base class for input ingestion.
template<class T>
class InputReader {
public:
    using value_type = T;
    /// Copy the input into `data` and advance to the next input.
    /// Returns true if success, false if the input is exhausted.
    virtual bool next(T *data) = 0;
};

using InputReaderU64 = InputReader<uint64_t>;
} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_INPUT_READER_BASE_HPP
