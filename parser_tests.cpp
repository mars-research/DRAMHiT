#ifndef PARSER_TESTS
#define PARSER_TESTS

#include <deque>

#if 0
void shard_thread_parse_no_inserts_v2(__shard* sh)
{
  uint64_t t_start, t_end;
  kseq seq;
  int l = 0;
  uint64_t num_inserts = 0;
  std::string n("N");

  kstream ks(sh->shard_idx, sh->f_start, sh->f_end);
  t_start = RDTSC_START();

  while ((l = ks.readseq(seq)) >= 0) {
    std::transform(seq.seq.begin(), seq.seq.end(), seq.seq.begin(), ::toupper);
    std::deque<char> window(seq.seq.begin(),
                            seq.seq.begin() + KMER_DATA_LENGTH);

    // walk over all windows across sequence
    for (size_t i = KMER_DATA_LENGTH; i <= seq.seq.length(); ++i) {
      std::string mer_f(window.begin(), window.end());
      // #ifdef DEBUG
      //     std::fprintf(stderr, "[%s]\n", mer_f.c_str());
      // #endif
      window.pop_front();
      window.push_back(seq.seq[i]);
      std::size_t n_found = mer_f.find(n);
      if (n_found != std::string::npos) {
        continue;
      }
      // std::string mer_r(mer_f);
      // reverse_complement_string(mer_r);
      // #ifdef DEBUG
      //     std::fprintf(
      //         stderr, "PRE  [%s : %d]\t[%s : %d]\n", mer_f.c_str(),
      //         (mer_count(mer_f) == 0 ? 0 :
      //         this->mer_counts().find(mer_f)->second), mer_r.c_str(),
      //         (mer_count(mer_r) == 0 ? 0 :
      //         this->mer_counts().find(mer_r)->second));
      // #endif

      /*** Perform the "insert" ***/
      num_inserts++;

#if 0
    if ((mer_count(mer_f) == 0) && (mer_count(mer_r) == 0)) {
// #ifdef DEBUG
//       std::fprintf(stderr, "INITIALIZING [%s]\n", mer_f.c_str());
// #endif
      set_mer_count(mer_f, 1);
      // we don't want to add a palindrome twice

      if ((mer_f.compare(mer_r) == 0) && (!this->double_count_palindromes)) {
// #ifdef DEBUG
//         std::fprintf(
//             stderr, "POST %d [%s : %d]\t[%s : %d]\n-----------------\n",
//             (this->double_count_palindromes ? 1 : 0), mer_f.c_str(),
//             (mer_count(mer_f) == 0 ? 0
//                                    : this->mer_counts().find(mer_f)->second),
//             mer_r.c_str(),
//             (mer_count(mer_r) == 0 ? 0
//                                    : this->mer_counts().find(mer_r)->second));
// #endif
        continue;
      }

// #ifdef DEBUG
//       std::fprintf(stderr, "INITIALIZING [%s]\n", mer_r.c_str());
// #endif
      if (mer_count(mer_r) == 0) {
        set_mer_count(mer_r, 1);
      } else if (this->double_count_palindromes) {
        increment_mer_count(mer_r);
      }
    } else if ((mer_count(mer_f) == 1) || (mer_count(mer_r) == 1)) {
// #ifdef DEBUG
//       std::fprintf(stderr, "INCREMENTING [%s]\n", mer_f.c_str());
// #endif
      increment_mer_count(mer_f);
      if ((mer_f.compare(mer_r) == 0) && (!this->double_count_palindromes)) {
// #ifdef DEBUG
//         std::fprintf(
//             stderr, "POST %d [%s : %d]\t[%s : %d]\n-----------------\n",
//             (this->double_count_palindromes ? 1 : 0), mer_f.c_str(),
//             (mer_count(mer_f) == 0 ? 0
//                                    : this->mer_counts().find(mer_f)->second),
//             mer_r.c_str(),
//             (mer_count(mer_r) == 0 ? 0
//                                    : this->mer_counts().find(mer_r)->second));
// #endif
        continue;
      }
// #ifdef DEBUG
//       std::fprintf(stderr, "INCREMENTING [%s]\n", mer_r.c_str());
// #endif
      increment_mer_count(mer_r);
    }
#endif
      // #ifdef DEBUG
      //     std::fprintf(
      //         stderr, "POST [%s : %d]\t[%s : %d]\n-----------------\n",
      //         mer_f.c_str(), (mer_count(mer_f) == 0 ? 0 :
      //         this->mer_counts().find(mer_f)->second), mer_r.c_str(),
      //         (mer_count(mer_r) == 0 ? 0 :
      //         this->mer_counts().find(mer_r)->second));
      // #endif
    }
  }
  t_end = RDTSCP();

  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = num_inserts;

  sh->stats->ht_fill = 0;
  sh->stats->ht_capacity = 0;
  sh->stats->max_count = 0;

}

#endif

void shard_thread_parse_no_inserts(__shard *sh)
{
  uint64_t t_start, t_end;
  kseq seq;
  int l = 0;
  uint64_t num_inserts = 0;
  int found_N = 0;
  char *kmer;

  kstream ks(sh->shard_idx, sh->f_start, sh->f_end);

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
      /*** Perform the "insert" ***/
      num_inserts++;
    }
    found_N = 0;
  }
  t_end = RDTSCP();

  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = num_inserts;

  sh->stats->ht_fill = 0;
  sh->stats->ht_capacity = 0;
  sh->stats->max_count = 0;
}

void shard_thread_parse_and_insert(__shard *sh, KmerHashTable *kmer_ht)
{
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

  get_ht_stats(sh, kmer_ht);
  printf("[INFO] Shard %u: DONE\n", sh->shard_idx);
}

#endif