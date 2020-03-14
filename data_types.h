#ifndef _DATA_TYPES_H
#define _DATA_TYPES_H

typedef struct
{
  unsigned high : 4;
  unsigned low : 4;
} __attribute__((packed)) base_4bit_t;

// kmer data (value)
struct Kmer_value_t
{
  uint64_t counter;
};

/* Test config */
struct Configuration
{
  uint64_t kmer_create_data_base;
  uint32_t kmer_create_data_mult;
  uint64_t kmer_create_data_uniq;
  uint32_t num_threads;
  uint32_t read_write_kmers;
  std::string kmer_files_dir;
  bool alphanum_kmers;
  bool numa_split;
  std::string stats_file;
  std::string ht_file;
};

#endif /* _DATA_TYPES_H */
