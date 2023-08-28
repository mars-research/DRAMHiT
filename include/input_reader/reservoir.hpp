#ifndef INPUT_READER_RESERVIOR_HPP
#define INPUT_READER_RESERVIOR_HPP

#include <memory>
#include <vector>

#include "types.hpp"
#include "input_reader.hpp"
#include "input_reader/container.hpp"

namespace kmercounter {
namespace input_reader {

template <typename T> 
class DynamicArray {
    public:
    T* array;
    size_t cap;
    size_t cap_size;
    size_t len;
    DynamicArray(size_t hint = 1 << 25): len(0), cap(hint), cap_size(hint * sizeof(T)) {
        array = alloc(cap_size);
    }

    T* alloc(size_t size) {
        // 1GB page
        auto array = (T*) mmap(nullptr, /* 256*1024*1024*/ size, PROT_READ | PROT_WRITE, MAP_HUGETLB | (30 << MAP_HUGE_SHIFT) | MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        return array;
    }

    void push_back(T p) {
        if (len == cap) {
            T* new_array = alloc(cap * 2);
            memcpy(new_array, array, cap_size);
            munmap(array, cap_size);
            array = new_array;
            cap *= 2;
            cap_size *= 2;
        } 
        array[len] = p;
        len++;
    }

    size_t size() {
        return len;
    }
};

/// Empty a input reader into a vector and produce the content from the vector.
/// This is good for preloading the dataset into memory
/// before running experiments.
template <typename T>
class Reservoir : public SizedInputReader<T> {
 public:
  Reservoir(std::unique_ptr<InputReader<T>> reader) : reader_(reservoir_) {
    for (T data; reader->next(&data);) {
      reservoir_.push_back(data);
    }
    reader_ = VecReader<T>(reservoir_);
  }

  bool next(T *output) override { return reader_.next(output); }

  size_t size() override { return reservoir_.size(); }

 private:
  std::vector<T> reservoir_;
  VecReader<T> reader_;
};

template <typename T>
class ReservoirMmap : public SizedInputReader<T> {
 public:
  ReservoirMmap(std::unique_ptr<InputReader<T>> reader) {
    for (T data; reader->next(&data);) {
      reservoir_.push_back(data);
    }
    // reader_ = VecReader<T>(reservoir_);
  }

  bool next(T *output) override { 
      if (cur == reservoir_.size()) {
          return false;
      } else {
          *output = reservoir_.array[cur++];
          return true;
      }
  }

  size_t size() override { return reservoir_.size(); }

 private:
  DynamicArray<T> reservoir_;
  size_t cur = 0;
  // VecReader<T> reader_;
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_RESERVIOR_HPP
