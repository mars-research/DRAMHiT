#ifndef INPUT_READER_INPUT_READER_HPP
#define INPUT_READER_INPUT_READER_HPP

/// Base class for input ingestion.
template<class T>
class InputReader {
public:
    virtual T next() = 0;
};

#endif // INPUT_READER_INPUT_READER_HPP
