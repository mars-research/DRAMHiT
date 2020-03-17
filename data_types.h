#ifndef _DATA_TYPES_H
#define _DATA_TYPES_H

#define __CACHE_LINE_SIZE 64
#define __PAGE_SIZE 4096

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
  uint32_t ht_type;
};

#endif /* _DATA_TYPES_H */
