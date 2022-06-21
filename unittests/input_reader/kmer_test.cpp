#include "input_reader/kmer.hpp"

#include <gtest/gtest.h>

#include <array>
#include <memory>
#include <sstream>
#include <string_view>
#include <vector>

#include "input_reader/file.hpp"
#include "input_reader_test_utils.hpp"

namespace kmercounter {
namespace input_reader {
namespace {
TEST(KmerTest, SimpleTest) {
  const char* data = R"(ATCG
TAGNAC
)";

  const size_t K = 2;
  std::unique_ptr<std::istream> file =
      std::make_unique<std::istringstream>(data);
  auto file_reader = std::make_unique<FileReader>(std::move(file), 0, 1);
  KMerReader<2, std::string_view> kmer_reader(std::move(file_reader));
  uint64_t kmer;
  EXPECT_TRUE(kmer_reader.next(&kmer));
  EXPECT_EQ("AT", DNAKMer<K>::decode(kmer));
  EXPECT_TRUE(kmer_reader.next(&kmer));
  EXPECT_EQ("TC", DNAKMer<K>::decode(kmer));
  EXPECT_TRUE(kmer_reader.next(&kmer));
  EXPECT_EQ("CG", DNAKMer<K>::decode(kmer));
  EXPECT_TRUE(kmer_reader.next(&kmer));
  EXPECT_EQ("TA", DNAKMer<K>::decode(kmer));
  EXPECT_TRUE(kmer_reader.next(&kmer));
  EXPECT_EQ("AG", DNAKMer<K>::decode(kmer));
  EXPECT_TRUE(kmer_reader.next(&kmer));
  EXPECT_EQ("AC", DNAKMer<K>::decode(kmer));
  EXPECT_FALSE(kmer_reader.next(&kmer));
}

}  // namespace
}  // namespace input_reader
}  // namespace kmercounter