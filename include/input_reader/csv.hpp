#ifndef INPUT_READER_CSV_HPP
#define INPUT_READER_CSV_HPP

#include <variant>

#include "input_reader_base.hpp"

namespace kmercounter {
namespace input_reader {

/// A field in a row.
using Field = std::variant<uint8_t, uint16_t, uint32_t, uint64_t, float, double>;

/// A row in a table.
// TODO: maybe a more compact representation to improve performance.
class Row {
public:
  std::vector<Field> fields;
};

/// Sequentially incrementin counter.
template<class T>
class CsvReader : public InputReader<T> {
    public:
    CsvReader(std::string_view filename) {

    }

    std::optional<T> next() override {
        return data++;
    }

private:
    T data;
};

} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_CSV_HPP
