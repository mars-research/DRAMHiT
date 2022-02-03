#include <gtest/gtest.h>

#include "utils/circular_buffer.hpp"


namespace kmercounter {
namespace input_reader {
namespace {

TEST(CircularBufferTest, PushTest) {
  {
    CircularBufferU8<3> cb;
    EXPECT_EQ(cb.offset(), 0);
    cb.push(0);
    EXPECT_EQ(cb.offset(), 1);
    cb.push(0);
    EXPECT_EQ(cb.offset(), 2);
    cb.push(0);
    EXPECT_EQ(cb.offset(), 0);
    cb.push(0);
    EXPECT_EQ(cb.offset(), 1);
  }

  {
    CircularBufferU8<4> cb;
    EXPECT_EQ(cb.offset(), 0);
    cb.push(0);
    EXPECT_EQ(cb.offset(), 1);
    cb.push(0);
    EXPECT_EQ(cb.offset(), 2);
    cb.push(0);
    EXPECT_EQ(cb.offset(), 3);
    cb.push(0);
    EXPECT_EQ(cb.offset(), 0);
    cb.push(0);
    EXPECT_EQ(cb.offset(), 1);
  }
}

TEST(CircularBufferTest, CopyTest) {
  int iter = 1;
  std::array<int, 3> buffer;
  CircularBuffer<int, 3> cb;
  cb.push(0);
  cb.push(0);
  cb.push(0);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array({0, 0, 0}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array({0, 0, 1}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array({0, 1, 2}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array({1, 2, 3}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array({2, 3, 4}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array({3, 4, 5}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array({4, 5, 6}), buffer);
}


} // namespace
} // namespace input_reader
} // namespace kmercounter