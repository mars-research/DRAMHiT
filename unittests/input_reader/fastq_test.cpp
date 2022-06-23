#include "input_reader/fastq.hpp"

#include <absl/strings/str_join.h>
#include <gtest/gtest.h>

#include <boost/range/adaptor/transformed.hpp>
#include <boost/range/irange.hpp>
#include <boost/range/numeric.hpp>
#include <string_view>
#include <vector>

#include "input_reader_test_utils.hpp"

using boost::accumulate;
using boost::irange;
using boost::adaptors::transformed;

namespace kmercounter {
namespace input_reader {
namespace {
const char SMALL_SEQ[] = R"(@ERR024163.1 EAS51_210:1:1:1072:4554/1
AGGAGGTAA
+
EFFDEFFFF
)";
// A small sequence with 'N'
const char SMALL_SEQ_N[] = R"(@seq
AGGNNAGGTANA
+
EFFDEFFFFFFF
)";
const char FIVE_SEQS_N[] = R"(@seq0
AGGNNAGGTANA
+
EFFDEFFFFFFF
@seq1
ANANANANANAN
+
EFFDEFFFFFFF
@seq2
NNNNNNNNNNNN
+
EFFDEFFFFFFF
@seq3
AGGNNAGGTANA
+
EFFDEFFFFFFF
@seq4
NNNNNNNNNNNN
+
EFFDEFFFFFFF
)";
const char ONE_SEQ[] =
    R"(@SRR077487.2.1 HWUSI-EAS635_105240777:5:1:943:17901 length=200
NAGGAGAAAAAAGAGGCAATCAGAAAAGGGCATGGTTTGACTNNNTTTGAATGTGGTTTCGTTGGCAGCAAATGTGTCTTCACTTTTTAATGAAAAAGTCAGATACTTTGTCACCAGGCAGAGGGCAATATCCTGTCTGTTATGACAAATGCTAATTGACAGCTCCCCCACAGGAAGTCGTCTGTCCTGGTGTGGGGGGG
+SRR077487.2.1 HWUSI-EAS635_105240777:5:1:943:17901 length=200
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%@D?GGG=EGGBGDDB@:D:GB<EEEGD:@8>EEEDA7BB36B?:=A?+;>=:7>7B3D>,?3?=BB<DAADD8;+?%%%%%%%%%%%%%%%%%%%%%%%%
)";
const char FIVE_SEQS[] = R"(@ERR024163.1 EAS51_210:1:1:1072:4554/1
AGGAGGTAAATCTATCTTGAGCNAGTNAGNTNNNNNNNNAGGCATTATNNNANCTGACTTCAANATATATAACACAGCTATAGNAATCANNANANCNTNN
+
EFFDEFFFFFDAEDBDFD?B@@!@C/!77!7!!!!!!!!6961=7AA;!!!<!AAB>=B?>?@!CAAAACBD5CBC?AEAA?A!#####!!#!#!#!#!!
@ERR024163.2 EAS51_210:1:1:1072:12749/1
AGTGATTATTGGTACTAGTCACNAAGNGANGNNNNNNNNCAATCTTAANNNANATGATACTTTNAAAGATCAGCTCAAAACCTNCAATTNNANANANANN
+
EE?BEFFFFDDE?EEE=EEC==!?=7!<5!;!!!!!!!!7;:@<>??,!!!7!877::71;?;!;;<=?=-CEB?ABECA###!#####!!#!#!#!#!!
@ERR024163.3 EAS51_210:1:1:1072:8819/1
CTATGCAGCCATAAAAAAGGATNGGTNCANGNNNNNNNNAGGGACGTGNNNGNAGCTGGAAACNATCATTCTCAGAAAACTATNACAAGNNCNGNANANN
+
ADFBFE5DBDED:ED>>A>DB6!>65!7*!?!!!!!!!!A6668@<9>!!!/!:/.51*?958!;9=<B>:D:B:,@@95@@@!@####!!#!#!#!#!!
@ERR024163.4 EAS51_210:1:1:1073:14372/1
CTATGGGCAATGGGTACAAAGTNACANTTAANNNNNNNNAATCAGTTCNNNTNCCCTACTGTANAGTAAGGTAACTGTAATCANCAATANNANTNTATNN
+
EDEEDBEEE?FFFFDDBACE@C!?=1!?94;!!!!!!!!;7?::=7@;!!!9!8857:79>;>!9><;;=B4B??AA?CB66?!#####!!#!#!###!!
@ERR024163.5 EAS51_210:1:1:1073:1650/1
GATTAATCTTTGGACCACCACANCACNGCCANNNNNNNNTAGATAAAANNNANTTGGATTGAANAGGACTGAATTACTCACACNTATGGNNTNANCNTNN
+
A?:A>@D@DDC?C=A-?;9A;>!7>?!?###!!!!!!!!#########!!!#!##########!###################!#####!!#!#!#!#!!
)";
const char HOMO_FIVE_SEQS[] =
    R"(@SRR077487.2.1 HWUSI-EAS635_105240777:5:1:943:17901 length=200
NAGGAGAAAAAAGAGGCAATCAGAAAAGGGCATGGTTTGACTNNNTTTGAATGTGGTTTCGTTGGCAGCAAATGTGTCTTCACTTTTTAATGAAAAAGTCAGATACTTTGTCACCAGGCAGAGGGCAATATCCTGTCTGTTATGACAAATGCTAATTGACAGCTCCCCCACAGGAAGTCGTCTGTCCTGGTGTGGGGGGG
+SRR077487.2.1 HWUSI-EAS635_105240777:5:1:943:17901 length=200
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%@D?GGG=EGGBGDDB@:D:GB<EEEGD:@8>EEEDA7BB36B?:=A?+;>=:7>7B3D>,?3?=BB<DAADD8;+?%%%%%%%%%%%%%%%%%%%%%%%%
@SRR077487.2.2 HWUSI-EAS635_105240777:5:1:944:19337 length=200
NGTTTTGTTCATTTATTTTTGCAGTTTAGAGTGTTTATATCTNNNAGGAAATTTCATTAAAGAAATCCCACCAGAATTAGGAAATCTGCCTTCTCTGAATACTTACTTTGAGAATATCTAATTCTTTTCTACATATAAAAACATGTGAGTGAATACAAGACAATAATTACTAAGCATAGATGTCTGCGTATATACAAATG
+SRR077487.2.2 HWUSI-EAS635_105240777:5:1:944:19337 length=200
!+'+(*+*((<:<<:@22222:<<899877:::::::3::((!!!*'+')999998::<:@@@222@@@7<22<:@@@@%%%%%%%%%%%%%%%%%%%%%GDGD:BGGGEGGGEGG@EGGGGGDGGDEEDDG>BGGEGG>DDADEBG@GGGGBGGGBG<GGBBDGG@<DBGBGGB@D>@+DGDGGDGEDGGD>G>BG>@G
@SRR077487.2.3 HWUSI-EAS635_105240777:5:1:944:6200 length=200
NATTTATTTTTGCTATAACTTTTATTATTTATTCTATTTTGCNNNCTTTATGCCTATGCTGCTCTCTTTTCTCTCGTTTTCTGAGTAGAATATGTAGAGATGAAAGTATAGCTTATCAAAATTTATGAAATACAGTGAAAGGAATGGTTAAAAGGGAATTTACAGTATGGAATGCATAGATTAGTATAAAAGAATAGTGG
+SRR077487.2.3 HWUSI-EAS635_105240777:5:1:944:6200 length=200
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%:EEBDB?:8DDBEE?G:?@GDBBE4D?:D,B:>:BGGGGEBB<<<EEEEB-B>BA+?,C@;;4*>>1-AA<1?B-6:368>A%%%%%%%%%%%%%%%%%%
@SRR077487.2.4 HWUSI-EAS635_105240777:5:1:944:9659 length=200
NAAGTCATGTCACCTGCGAGCCCCTGTCTTCCAGTCTGCATCNNNGGGAGACTCAATCCCCATGTAAAAGGAAGCACCCACCTCCCACCACGAACCACAAAATTAAAACTCTGTAGACTTATGTCAGTTCAGGTTGGGTGTTGGCACCAATGAGTACCAAAACAAATTTCATTTTTCAGATCTAATTGAATTTCAGACTT
+SRR077487.2.4 HWUSI-EAS635_105240777:5:1:944:9659 length=200
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%DDB:BD4=DDDBDDD=1D=DD@DDD-BBB>3DDDDD@D@@DBDD:D>DDDDB<<2DD8<3B>D>>=+>BD<0-B<B7;+;BA<0>>B>3<<>>B%%%%%%
@SRR077487.2.5 HWUSI-EAS635_105240777:5:1:944:16987 length=200
NGAGCCACGAAGACATTGTTATCCTCTCTGACTCAGTTCTTTNNNACTCCTGGCCCTGTCCTCTCTCCCTCCCGCTAGTTCCCGGGTCCATCAAACTACAAGCCCTCATCACTCACTGCAGGGGCAGAAGCAAGAGGATTCCACCCTCCCCGCAACAGAGCGCCAGTCAAGAGCCCAGTAATCAGCATTGATGTGGGGGC
+SRR077487.2.5 HWUSI-EAS635_105240777:5:1:944:16987 length=200
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%DD-:BD@DDD@:D@D@4DBD8B=4=DDDDBD<DDDDD8DDD>@D6>>B79@%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
)";

std::string build_seqs(int n) {
  std::string str;
  for (int i = 0; i < n; i++) {
    str += ONE_SEQ;
  }
  return str;
}

TEST(FastqReaderTest, SingleParition) {
  {
    std::unique_ptr<std::istream> input =
        std::make_unique<std::istringstream>(ONE_SEQ);
    auto reader = std::make_unique<FastqReader>(std::move(input));
    EXPECT_EQ(1, reader_size(std::move(reader)));
  }

  {
    std::unique_ptr<std::istream> input =
        std::make_unique<std::istringstream>(FIVE_SEQS);
    auto reader = std::make_unique<FastqReader>(std::move(input));
    EXPECT_EQ(5, reader_size(std::move(reader)));
  }

  {
    std::unique_ptr<std::istream> input =
        std::make_unique<std::istringstream>(HOMO_FIVE_SEQS);
    auto reader = std::make_unique<FastqReader>(std::move(input));
    EXPECT_EQ(5, reader_size(std::move(reader)));
  }
}

TEST(FastqReaderTest, MultiParition) {
  constexpr auto num_seqss =
      std::to_array({1, 2, 3, 4, 6, 9, 13, 17, 19, 21, 22, 24, 100, 1000});
  constexpr auto num_partss =
      std::to_array({1, 2, 3, 4, 5, 6, 9, 13, 17, 19, 64});

  for (const auto num_seqs : num_seqss) {
    LOG_INFO << "Building sequencies with size " << num_seqs;
    std::string seqs = build_seqs(num_seqs);
    for (const auto num_parts : num_partss) {
      auto readers =
          irange(num_parts) | transformed([&seqs, num_parts](uint64_t part_id) {
            std::unique_ptr<std::istream> file =
                std::make_unique<std::istringstream>(seqs);
            auto reader = std::make_unique<FastqReader>(std::move(file),
                                                        part_id, num_parts);
            return reader;
          });

      auto seqs_read = readers | transformed([](auto reader) {
                         const uint64_t lines_read =
                             reader_size(std::move(reader));
                         return lines_read;
                       });

      const uint64_t total_seqs_read = accumulate(seqs_read, 0ul);
      LOG_INFO << "Read " << total_seqs_read << " seqs in total";
      ASSERT_EQ(num_seqs, total_seqs_read)
          << "Incorrect number of seqs read for " << num_parts
          << " partitions.";
    }
  }

  std::unique_ptr<std::istream> input =
      std::make_unique<std::istringstream>(build_seqs(10));
  auto reader = std::make_unique<FastqReader>(std::move(input));
  EXPECT_EQ(10, reader_size(std::move(reader)));
}

TEST(FastqKmerReaderTest, SinglePartitionTest) {
  // 4mers
  {
    constexpr size_t K = 4;
    std::unique_ptr<std::istream> input =
        std::make_unique<std::istringstream>(SMALL_SEQ);
    auto reader = std::make_unique<FastqKMerReader<K>>(std::move(input));
    uint64_t kmer;
    // AGGAGGTAA
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'A', 'G', 'G', 'A'}), DNAKMer<K>::decode(kmer));
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'G', 'G', 'A', 'G'}), DNAKMer<K>::decode(kmer));
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'G', 'A', 'G', 'G'}), DNAKMer<K>::decode(kmer));
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'A', 'G', 'G', 'T'}), DNAKMer<K>::decode(kmer));
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'G', 'G', 'T', 'A'}), DNAKMer<K>::decode(kmer));
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'G', 'T', 'A', 'A'}), DNAKMer<K>::decode(kmer));
    EXPECT_FALSE(reader->next(&kmer));
  }

  // 8mers
  {
    constexpr size_t K = 8;
    std::unique_ptr<std::istream> input =
        std::make_unique<std::istringstream>(SMALL_SEQ);
    auto reader = std::make_unique<FastqKMerReader<K>>(std::move(input));
    uint64_t kmer;
    // AGGAGGTAA
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'A', 'G', 'G', 'A', 'G', 'G', 'T', 'A'}),
              DNAKMer<K>::decode(kmer));
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'G', 'G', 'A', 'G', 'G', 'T', 'A', 'A'}),
              DNAKMer<K>::decode(kmer));
    EXPECT_FALSE(reader->next(&kmer));
  }
}

TEST(FastqKMerPreloadReader, SinglePartitionTest) {
  // 4mers
  {
    constexpr size_t K = 4;
    std::unique_ptr<std::istream> input =
        std::make_unique<std::istringstream>(SMALL_SEQ);
    auto reader = std::make_unique<FastqKMerPreloadReader<K>>(std::move(input));
    uint64_t kmer;
    // AGGAGGTAA
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'A', 'G', 'G', 'A'}), DNAKMer<K>::decode(kmer));
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'G', 'G', 'A', 'G'}), DNAKMer<K>::decode(kmer));
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'G', 'A', 'G', 'G'}), DNAKMer<K>::decode(kmer));
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'A', 'G', 'G', 'T'}), DNAKMer<K>::decode(kmer));
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'G', 'G', 'T', 'A'}), DNAKMer<K>::decode(kmer));
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'G', 'T', 'A', 'A'}), DNAKMer<K>::decode(kmer));
    EXPECT_FALSE(reader->next(&kmer));
  }

  // 8mers
  {
    constexpr size_t K = 8;
    std::unique_ptr<std::istream> input =
        std::make_unique<std::istringstream>(SMALL_SEQ);
    auto reader = std::make_unique<FastqKMerPreloadReader<K>>(std::move(input));
    uint64_t kmer;
    // AGGAGGTAA
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'A', 'G', 'G', 'A', 'G', 'G', 'T', 'A'}),
              DNAKMer<K>::decode(kmer));
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'G', 'G', 'A', 'G', 'G', 'T', 'A', 'A'}),
              DNAKMer<K>::decode(kmer));
    EXPECT_FALSE(reader->next(&kmer));
  }
}

TEST(FastqKMerPreloadReader, ParseNTest) {
  // 4mers
  {
    constexpr size_t K = 4;
    std::unique_ptr<std::istream> input =
        std::make_unique<std::istringstream>(SMALL_SEQ_N);
    auto reader = std::make_unique<FastqKMerPreloadReader<K>>(std::move(input));
    uint64_t kmer;
    // AGGNNAGGTANA
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'A', 'G', 'G', 'T'}), DNAKMer<K>::decode(kmer));
    EXPECT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'G', 'G', 'T', 'A'}), DNAKMer<K>::decode(kmer));
    EXPECT_FALSE(reader->next(&kmer));
  }

  // 8mers
  {
    constexpr size_t K = 8;
    std::unique_ptr<std::istream> input =
        std::make_unique<std::istringstream>(SMALL_SEQ_N);
    auto reader = std::make_unique<FastqKMerPreloadReader<K>>(std::move(input));
    uint64_t kmer;
    // AGGNNAGGTANA
    EXPECT_FALSE(reader->next(&kmer));
  }
}

TEST(FastqKMerPreloadReader, MultiseqParseNTest) {
  // 4mers
  {
    constexpr size_t K = 4;
    std::unique_ptr<std::istream> input =
        std::make_unique<std::istringstream>(FIVE_SEQS_N);
    auto reader = std::make_unique<FastqKMerPreloadReader<K>>(std::move(input));
    uint64_t kmer;
    ASSERT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'A', 'G', 'G', 'T'}), DNAKMer<K>::decode(kmer));
    ASSERT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'G', 'G', 'T', 'A'}), DNAKMer<K>::decode(kmer));
    ASSERT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'A', 'G', 'G', 'T'}), DNAKMer<K>::decode(kmer));
    ASSERT_TRUE(reader->next(&kmer));
    EXPECT_EQ(std::string({'G', 'G', 'T', 'A'}), DNAKMer<K>::decode(kmer));
    ASSERT_FALSE(reader->next(&kmer));
  }

  // 8mers
  {
    constexpr size_t K = 8;
    std::unique_ptr<std::istream> input =
        std::make_unique<std::istringstream>(FIVE_SEQS_N);
    auto reader = std::make_unique<FastqKMerPreloadReader<K>>(std::move(input));
    uint64_t kmer;
    EXPECT_FALSE(reader->next(&kmer));
  }
}

}  // namespace
}  // namespace input_reader
}  // namespace kmercounter