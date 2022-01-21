#ifndef INPUT_READER_INPUT_READER_BASE_HPP
#define INPUT_READER_INPUT_READER_BASE_HPP

#include <optional>

namespace kmercounter {
namespace input_reader {
/// Base class for input ingestion.
template<class T>
class InputReader {
public:
    /// Returns the next element from the input.
    /// Returns `std::nullopt` if the input is exhausted.
    virtual std::optional<T> next() = 0;
};
} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_INPUT_READER_BASE_HPP
