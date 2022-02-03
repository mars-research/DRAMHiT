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


} // namespace
} // namespace input_reader
} // namespace kmercounter