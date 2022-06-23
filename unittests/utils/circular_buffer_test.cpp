#include "utils/circular_buffer.hpp"

#include <gtest/gtest.h>

#include <cstdint>

namespace kmercounter {
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

template <size_t size>
void cross_check_for_size() {
  std::array<uint8_t, size> buffer;
  std::array<uint8_t, size> bufferm;
  CircularBufferMove<uint8_t, size> cbm;
  CircularBuffer<uint8_t, size> cb;
  for (int i = 0; i < 100; i++) {
    cb.push(i);
    cbm.push(i);
    cb.copy_to(buffer);
    cbm.copy_to(bufferm);
    EXPECT_EQ(buffer, bufferm)
        << "Cross check failed; size=" << size << "; i=" << i;
  }
}

TEST(CircularBufferMoveTest, CrossCheck) {
  cross_check_for_size<2>();
  cross_check_for_size<3>();
  cross_check_for_size<4>();
  cross_check_for_size<5>();
  cross_check_for_size<6>();
  cross_check_for_size<7>();
  cross_check_for_size<8>();
  cross_check_for_size<9>();
  cross_check_for_size<10>();
}

TEST(DNAKmer, PushTest) {
  {
    DNAKMer<3> kmer;
    EXPECT_TRUE(kmer.push('A'));
    EXPECT_TRUE(kmer.push('T'));
    EXPECT_TRUE(kmer.push('C'));
    EXPECT_EQ(kmer.to_string(), "ATC");
    EXPECT_TRUE(kmer.push('G'));
    EXPECT_EQ(kmer.to_string(), "TCG");
    EXPECT_FALSE(kmer.push('N'));
    EXPECT_EQ(kmer.to_string(), "TCG");
    EXPECT_TRUE(kmer.push('G'));
    EXPECT_EQ(kmer.to_string(), "CGG");
  }
  {
    DNAKMer<4> kmer;
    EXPECT_TRUE(kmer.push('A'));
    EXPECT_TRUE(kmer.push('T'));
    EXPECT_TRUE(kmer.push('C'));
    EXPECT_TRUE(kmer.push('G'));
    EXPECT_EQ(kmer.to_string(), "ATCG");
    EXPECT_FALSE(kmer.push('N'));
    EXPECT_EQ(kmer.to_string(), "ATCG");
    EXPECT_TRUE(kmer.push('G'));
    EXPECT_EQ(kmer.to_string(), "TCGG");
  }
}

}  // namespace
}  // namespace kmercounter