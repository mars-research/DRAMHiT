#ifndef PARSER_TESTS
#define PARSER_TESTS

void shard_thread_parse_no_inserts(__shard *sh)
{
  uint64_t t_start, t_end;
  kseq seq;
  int l = 0;
  uint64_t num_inserts = 0;
  int found_N = 0;
  char *kmer;
  t_start = RDTSC_START();

  kstream ks(sh->shard_idx, sh->f_start, sh->f_end);

  while ((l = ks.readseq(seq)) >= 0) {
    for (int i = 0; i < (l - KMER_DATA_LENGTH + 1); i++) {
      kmer = seq.seq.data() + i;
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

  t_start = RDTSC_START();

  kstream ks(sh->shard_idx, sh->f_start, sh->f_end);

  while ((l = ks.readseq(seq)) >= 0) {
    // std::cout << seq.seq << std::endl;
    for (int i = 0; i < (l - KMER_DATA_LENGTH + 1); i++) {
      kmer = seq.seq.data() + i;

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
  get_ht_stats(sh, kmer_ht);
  printf("[INFO] Shard %u: DONE\n", sh->shard_idx);
}

#endif