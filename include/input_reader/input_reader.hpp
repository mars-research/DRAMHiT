#ifndef INPUT_READER_INPUT_READER_HPP
#define INPUT_READER_INPUT_READER_HPP

#include <optional>

/// Base class for input ingestion.
template<class T>
class InputReader {
public:
    /// Returns the next element from the input.
    /// Returns `std::nullopt` if the input is exhausted.
    virtual std::optional<T> next() = 0;
};

#endif // INPUT_READER_INPUT_READER_HPP
