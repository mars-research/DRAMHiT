#ifndef INPUT_READER_SPAN_HPP
#define INPUT_READER_SPAN_HPP

#include <span>

#include "input_reader.hpp"
#include "input_reader/container.hpp"
#include "logging.hpp"

namespace kmercounter {
namespace input_reader {
namespace internal {
/// Helper class for `PartitionedSpanReader`.
/// It computes the pointer and the size of the partitioned relation.
template <class T>
class PartitionedSpan {
 public:
  PartitionedSpan(const std::span<T>& span, uint64_t part_id,
                  uint64_t num_parts) {
    PLOG_WARNING_ONCE_IF(span.size() % num_parts)
        << "Partition with size " << span.size()
        << " does not divide evenly by " << num_parts << " partitions.";
    uint64_t num_tuples_per_part = span.size() / num_parts;
    T* pointer = span.data() + part_id * num_tuples_per_part;
    size_t size = num_tuples_per_part;
    if (part_id == num_parts - 1) {
      // The last partition will get the left over stuff if num_tuples can't be
      // divided evenly.
      size += span.size() % num_parts;
    }
    partitioned_span_ = std::span<T>(pointer, size);
  }

  // protected:
  std::span<T> partitioned_span_;
};
}  // namespace internal

template <class T>
class SpanReader : public SizedInputReader<T> {
 public:
  SpanReader(T* data, size_t size) : SpanReader(std::span<T>(data, size)) {}
  SpanReader(const std::span<T>& data)
      : data_(data), iter_(data_.begin(), data_.end()) {}

  bool next(T* data) override { return iter_.next(data); }

  size_t size() override { return data_.size(); }

  void reset() { 
    iter_ = RangeReader<decltype(data_.begin()), T>(data_.begin(), data_.end());
  }

 private:
  std::span<T> data_;
  RangeReader<decltype(data_.begin()), T> iter_;
};

template <class T>
class PartitionedSpanReader : public internal::PartitionedSpan<T>,
                              public SpanReader<T> {
 public:
  PartitionedSpanReader(const std::span<T>& span, uint64_t part_id,
                        uint64_t num_parts)
      : internal::PartitionedSpan<T>(span, part_id, num_parts),
        SpanReader<T>(internal::PartitionedSpan<T>::partitioned_span_) {}
};
}  // namespace input_reader
}  // namespace kmercounter

#endif  // INPUT_READER_SPAN_HPP
