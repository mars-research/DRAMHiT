#ifndef INPUT_READER_INPUT_READER_BASE_HPP
#define INPUT_READER_INPUT_READER_BASE_HPP

#include <cstddef>
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

    virtual ~InputReader() = default;
};
using InputReaderU64 = InputReader<uint64_t>;

/// InputReader but the size is known.
template<class T>
class SizedInputReader : public virtual InputReader<T> {
public:
    /// Returns the number of elements in the reader.
    virtual size_t size() = 0;

    virtual ~SizedInputReader() = default;
};
} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_INPUT_READER_BASE_HPP
