#ifndef PARSER_TESTS
#define PARSER_TESTS

#include "ParserTest.hpp"
#include "ac_kseq.h"
#include "ac_kstream.h"
#include "base_kht.hpp"
#include "print_stats.h"
#include "sync.h"

namespace kmercounter {
/* https://bioinformatics.stackexchange.com/questions/5359/what-is-the-most-compact-data-structure-for-canonical-k-mers-with-the-fastest-lo?noredirect=1&lq=1
 */

extern void get_ht_stats(__shard *, KmerHashTable *);

static unsigned char seq_nt4_table[128] = {  // Table to change "ACGTN" to 01234
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0,
    4, 1, 4, 4, 4, 2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 4, 4, 4,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 4, 1, 4, 4, 4, 2, 4, 4, 4, 4, 4, 4,
    4, 4, 4, 4, 4, 4, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4};

void ParserTest::shard_thread_parse_no_inserts_v3(__shard *sh,
                                                  Configuration &config) {
  uint64_t t_start, t_end;
  kseq seq;
  uint64_t num_inserts = 0;
  int len = 0;

  kstream ks(sh->shard_idx, sh->f_start, sh->f_end);

#ifdef CALC_STATS
  std::string first_seq;
  std::string last_seq;
  uint64_t num_sequences = 0;
#endif

  t_start = RDTSC_START();
  while ((len = ks.readseq(seq)) >= 0) {
    int i, l;
    uint64_t x[2] = {0};
    uint64_t mask = (1ULL << config.K * 2) - 1;
    uint64_t shift = (config.K - 1) * 2;

    for (i = l = 0, x[0] = x[1] = 0; i < len; ++i) {
      int c = (uint8_t)seq.seq.data()[i] < 128
                  ? seq_nt4_table[(uint8_t)seq.seq.data()[i]]
                  : 4;
      if (c < 4) {                                      // not an "N" base
        x[0] = (x[0] << 2 | c) & mask;                  // forward strand
        x[1] = x[1] >> 2 | (uint64_t)(3 - c) << shift;  // reverse strand
        if (++l >= config.K) {                          // we find a k-mer
          uint64_t y = x[0] < x[1] ? x[0] : x[1];
          /* Perform the "insert" */
          num_inserts++;
        }
      } else
        l = 0, x[0] = x[1] = 0;  // if there is an "N", restart
    }
#ifdef CALC_STATS
    num_sequences++;
    if (first_seq.length() == 0) first_seq = seq.seq;
    last_seq = seq.seq;
#endif
  }
  t_end = RDTSCP();

#ifdef CALC_STATS
  printf("[INFO] Shard %u, num_sequences: %lu, first seq: %s\n", sh->shard_idx,
         num_sequences, first_seq.c_str());
  printf("[INFO] Shard %u, num_sequences: %lu, last seq: %s\n", sh->shard_idx,
         num_sequences, last_seq.c_str());
#endif

  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = num_inserts;

  sh->stats->ht_fill = 0;
  sh->stats->ht_capacity = 0;
  sh->stats->max_count = 0;
}

void ParserTest::shard_thread_parse_no_inserts(__shard *sh) {
  uint64_t t_start, t_end;
  kseq seq;
  int l = 0;
  uint64_t num_inserts = 0;
  int found_N = 0;
  char *kmer;

  kstream ks(sh->shard_idx, sh->f_start, sh->f_end);

#ifdef CALC_STATS
  std::string first_seq;
  std::string last_seq;
  uint64_t num_sequences = 0;
  uint64_t avg_read_length = 0;
#endif

  t_start = RDTSC_START();

  while ((l = ks.readseq(seq)) >= 0) {
    for (int i = 0; i < (l - KMER_DATA_LENGTH + 1); i++) {
#ifndef CHAR_ARRAY_PARSE_BUFFER
      kmer = seq.seq.data() + i;
#else
      kmer = seq.seq + i;
#endif
      if (found_N != -1) {
        found_N = find_last_N(kmer);
        if (found_N >= 0) {
          i += found_N;
          continue;
        }
      }
      char last_char = kmer[KMER_DATA_LENGTH - 1];
      if (last_char == 'N' || last_char == 'n') {
        found_N = KMER_DATA_LENGTH - 1;
        i += found_N;
        continue;
      }
      /*** Perform the "insert ***/
      num_inserts++;
#ifdef CALC_STATS
      if (!avg_read_length) {
        avg_read_length = seq.seq.length();
      } else {
        avg_read_length = (avg_read_length + seq.seq.length()) / 2;
      }
#endif
    }
#ifdef CALC_STATS
    num_sequences++;
    if (first_seq.length() == 0) first_seq = seq.seq;
    last_seq = seq.seq;
#endif
    found_N = 0;
  }
  t_end = RDTSCP();

#ifdef CALC_STATS
  printf("[INFO] Shard %u, num_sequences: %lu, first seq: %s\n", sh->shard_idx,
         num_sequences, first_seq.c_str());
  printf("[INFO] Shard %u, num_sequences: %lu, last seq: %s\n", sh->shard_idx,
         num_sequences, last_seq.c_str());
#endif

  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = num_inserts;

  sh->stats->ht_fill = 0;
  sh->stats->ht_capacity = 0;
  sh->stats->max_count = 0;
}

void ParserTest::shard_thread_parse_and_insert(__shard *sh,
                                               KmerHashTable *kmer_ht) {
  uint64_t t_start, t_end;
  kseq seq;
  int l = 0;
  int res;
  uint64_t num_inserts = 0;
  int found_N = 0;
  char *kmer;

#ifdef CALC_STATS
  uint64_t avg_read_length = 0;
  uint64_t num_sequences = 0;
#endif

  kstream ks(sh->shard_idx, sh->f_start, sh->f_end);
  t_start = RDTSC_START();

  while ((l = ks.readseq(seq)) >= 0) {
    // std::cout << seq.seq << std::endl;
    for (int i = 0; i < (l - KMER_DATA_LENGTH + 1); i++) {
#ifndef CHAR_ARRAY_PARSE_BUFFER
      kmer = seq.seq.data() + i;
#else
      kmer = seq.seq + i;
#endif

      /*  search through whole string of N if first kmer OR if we found an N
       as last character of previous kmer */
      if (found_N != -1) {
        found_N = find_last_N(kmer);
        if (found_N >= 0) {
          i += found_N;
          continue;
        }
      }

      /* if last charcter is a kmer skip this kmer*/
      char last_char = kmer[KMER_DATA_LENGTH - 1];
      if (last_char == 'N' || last_char == 'n') {
        found_N = KMER_DATA_LENGTH - 1;
        i += found_N;
        continue;
      }

      res = kmer_ht->insert((void *)kmer);
      if (!res) {
        printf("FAIL\n");
      } else {
        num_inserts++;
      }

#ifdef CALC_STATS
      if (!avg_read_length) {
        avg_read_length = seq.seq.length();
      } else {
        avg_read_length = (avg_read_length + seq.seq.length()) / 2;
      }
#endif
    }
    found_N = 0;
  }
  t_end = RDTSCP();

  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = num_inserts;

#ifdef CALC_STATS
  sh->stats->avg_read_length = avg_read_length;
  sh->stats->num_sequences = num_sequences;
#endif

  kmercounter::get_ht_stats(sh, kmer_ht);
  printf("[INFO] Shard %u: DONE\n", sh->shard_idx);
}

}  // namespace kmercounter
#endif
