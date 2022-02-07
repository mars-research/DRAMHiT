#include "input_reader/fastx.hpp"

#include <gtest/gtest.h>

#include <string_view>
#include <vector>

#include "input_reader_test_utils.hpp"

namespace kmercounter {
namespace input_reader {
namespace {
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

TEST(PartitionFastqReaderTest, SingleParition) {
  std::unique_ptr<std::istream> input =
      std::make_unique<std::istringstream>(FIVE_SEQS);
  auto reader = std::make_unique<FastqReader>(std::move(input));
  EXPECT_EQ(5, reader_size(std::move(reader)));
}

}  // namespace
}  // namespace input_reader
}  // namespace kmercounter