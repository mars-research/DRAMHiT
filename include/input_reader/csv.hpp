#ifndef INPUT_READER_CSV_HPP
#define INPUT_READER_CSV_HPP

#include <fstream>
#include <variant>

#include "input_reader_base.hpp"

namespace kmercounter {
namespace input_reader {

/// A field in a row.
using Field = std::variant<uint8_t, uint16_t, uint32_t, uint64_t, float, double>;

/// A row in a table.
// TODO: support other datatype
class Row {
public:
  std::vector<uint64_t> fields;
};

/// Read a CSV file.
/// All data are cached in memory to save I/O.
/// WIP; only reads the first integer column at this moment. 
class CsvReader : public InputReader<uint64_t> {
    public:
    CsvReader(std::string_view filename, std::string_view delimiter) {
      // Read CSV line by line into memory.
      std::fstream ifile(filename.data());
      for (std::string line; std::getline(ifile, line); /*noop*/) {
        const std::string field_str = line.substr(0, line.find(delimiter));
        const uint64_t field = std::stoull(field_str);
        data.push_back(field);
      }

      this->iter = this->data.begin();
    }

    std::optional<uint64_t> next() override {
        if (this->iter == this->data.end()) {
          return std::nullopt;
        } else {
          return *(this->iter++);
        }
    }

private:
    std::vector<uint64_t> data;
    std::vector<uint64_t>::iterator iter;
};

} // namespace input_reader
} // namespace kmercounter

#endif // INPUT_READER_CSV_HPP
