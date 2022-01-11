#ifndef INPUT_READER_CSV_HPP
#define INPUT_READER_CSV_HPP

#include <fstream>
#include <variant>
#include <vector>
#include <plog/Log.h>

#include "file.hpp"
#include "input_reader_base.hpp"

namespace kmercounter {
namespace input_reader {

/// A field in a row.
using Field = std::variant<uint8_t, uint16_t, uint32_t, uint64_t, float, double>;

/// A row in a table.
// TODO: support other datatype
// class Row {
// public:
//   std::vector<uint64_t> fields;
// };

/// The first field(key) of the row and the raw row itself.
using Row = std::pair<uint64_t, std::string>;

/// Read a CSV file.
/// All data are cached in memory to save I/O.
/// WIP; only reads the first integer column at this moment. 
class CsvReader : public InputReader<Row*> {
    public:
    CsvReader(std::string_view filename, std::string_view delimiter) {
      // Read CSV line by line into memory.
      FileReader file(filename);
      for (std::optional<std::string> line_op; line_op = file.next(); /*noop*/) {
        std::string line = *line_op;
        const std::string field_str = line.substr(0, line.find(delimiter));
        const uint64_t field = std::stoull(field_str);
        this->data.push_back(std::make_pair(field, line));
      }

      this->iter = this->data.begin();
    }

    std::optional<Row*> next() override {
        if (this->iter == this->data.end()) {
          return std::nullopt;
        } else {
          return &*(this->iter++);
        }
    }

private:
    std::vector<Row> data;
    std::vector<Row>::iterator iter;
};

} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_CSV_HPP
