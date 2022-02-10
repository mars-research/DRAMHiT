#include "utils/circular_buffer.hpp"

#include <cstdint>

#include <gtest/gtest.h>

namespace kmercounter {
namespace input_reader {
namespace {

TEST(CircularBufferTest, PushTest) {
  {
    CircularBuffer<uint8_t, 3> cb;
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
    CircularBuffer<uint8_t, 4> cb;
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
  std::array<uint8_t, 3> buffer;
  CircularBuffer<uint8_t, 3> cb;
  cb.push(0);
  cb.push(0);
  cb.push(0);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({0, 0, 0}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({0, 0, 1}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({0, 1, 2}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({1, 2, 3}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({2, 3, 4}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({3, 4, 5}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({4, 5, 6}), buffer);
}

TEST(CircularBufferMoveTest, PushCopyTest) {
  int iter = 1;
  std::array<uint8_t, 3> buffer;
  CircularBufferMove<uint8_t, 3> cb;
  cb.push(0);
  cb.push(0);
  cb.push(0);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({0, 0, 0}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({0, 0, 1}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({0, 1, 2}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({1, 2, 3}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({2, 3, 4}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({3, 4, 5}), buffer);
  cb.push(iter++);
  cb.copy_to(buffer);
  EXPECT_EQ(std::to_array<uint8_t>({4, 5, 6}), buffer);
}

TEST(CircularBufferMoveTest, CrossCheck) {
  {
    constexpr size_t size = 2;
    std::array<uint8_t, size> buffer;
    std::array<uint8_t, size> bufferm;
    CircularBufferMove<uint8_t, size> cbm;
    CircularBuffer<uint8_t, size> cb;
    for (int i = 0; i < 100; i++) {
      cb.push(i);
      cbm.push(i);
      cb.copy_to(buffer);
      cbm.copy_to(bufferm);
      EXPECT_EQ(buffer, bufferm) << "Cross check failed; i=" << i;
    }
  }

  {
    constexpr size_t size = 3;
    std::array<uint8_t, size> buffer;
    std::array<uint8_t, size> bufferm;
    CircularBufferMove<uint8_t, size> cbm;
    CircularBuffer<uint8_t, size> cb;
    for (int i = 0; i < 100; i++) {
      cb.push(i);
      cbm.push(i);
      cb.copy_to(buffer);
      cbm.copy_to(bufferm);
      EXPECT_EQ(buffer, bufferm) << "Cross check failed; i=" << i;
    }
  }

  {
    constexpr size_t size = 4;
    std::array<uint8_t, size> buffer;
    std::array<uint8_t, size> bufferm;
    CircularBufferMove<uint8_t, size> cbm;
    CircularBuffer<uint8_t, size> cb;
    for (int i = 0; i < 100; i++) {
      cb.push(i);
      cbm.push(i);
      cb.copy_to(buffer);
      cbm.copy_to(bufferm);
      EXPECT_EQ(buffer, bufferm) << "Cross check failed; i=" << i;
    }
  }

  {
    constexpr size_t size = 5;
    std::array<uint8_t, size> buffer;
    std::array<uint8_t, size> bufferm;
    CircularBufferMove<uint8_t, size> cbm;
    CircularBuffer<uint8_t, size> cb;
    for (int i = 0; i < 100; i++) {
      cb.push(i);
      cbm.push(i);
      cb.copy_to(buffer);
      cbm.copy_to(bufferm);
      EXPECT_EQ(buffer, bufferm) << "Cross check failed; i=" << i;
    }
  }
}


} // namespace
} // namespace input_reader
} // namespace kmercounter