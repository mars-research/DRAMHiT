#ifndef __PARSER_TEST_HPP__
#define __PARSER_TEST_HPP__

#include "base_kht.hpp"
#include "types.hpp"

namespace kmercounter {

class ParserTest {
 public:
  void shard_thread_parse_no_inserts_v3(Shard *sh, Configuration &cfg);
  void shard_thread_parse_no_inserts(Shard *sh);
  void shard_thread_parse_and_insert(Shard *sh, KmerHashTable *kmer_ht);
};

}  // namespace kmercounter

#endif  // __PARSER_TEST_HPP__
