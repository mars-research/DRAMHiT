#ifndef INPUT_READER_INPUT_READER_TEST_UTILS_HPP
#define INPUT_READER_INPUT_READER_TEST_UTILS_HPP

#include <memory>
#include <type_traits>

#include "input_reader/input_reader.hpp"

namespace kmercounter {
namespace input_reader {

/// Consumes the reader and return the size of it.
// TODO: add constrains that looks like `requires
// std::is_base_of_v<InputReader<T>, InputReader_t>`
template <typename InputReader_t,
          typename T = typename InputReader_t::value_type>
size_t reader_size(std::unique_ptr<InputReader_t> reader) {
  size_t size = 0;
  T tmp;
  while (reader->next(&tmp)) {
    size++;
  }
  return size;
}

}  // namespace input_reader
}  // namespace kmercounter
#endif  // INPUT_READER_INPUT_READER_TEST_UTILS_HPP
