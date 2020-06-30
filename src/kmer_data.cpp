#include <malloc.h>
#include <algorithm>
#include <cerrno>
#include <cstdio>
#include <cstring>
#include <iostream>
#include <random>
#include <unordered_map>

extern "C"
{
#include "fcntl.h"
#include "sys/mman.h"
#include "sys/stat.h"
#include "sys/types.h"
}

#include "types.hpp"
#include "misc_lib.h"
// #include "kmer_struct.h"
// #include "shard.h"
// #include "test_config.h"

// KSEQ_INIT(gzFile, gzread)


namespace kmercounter {
const char *POOL_FILE_FORMAT = "/local/devel/pools/%02u.bin";

extern Configuration config;

/* TODO: map to hold all generated alphanum kmers and their count*/
/* map should thread-local */

/* Generating alphanum kmers for easier debug */
std::string random_alphanum_string(size_t length)
{
  auto randchar = []() -> char {
    const char charset[] =
        "0123456789"
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz";
    const size_t max_index = (sizeof(charset) - 1);
    return charset[rand() % max_index];
  };
  std::string str(length, 0);
  std::generate_n(str.begin(), length, randchar);
  return str;
}

void generate_random_data_small_pool(__shard *sh, uint64_t small_pool_count)
{
  std::string s(KMER_DATA_LENGTH, 0);
  std::srand(0);

  // printf("[INFO] Shard %u, Populating SMALL POOL\n", sh->shard_idx);

  for (size_t i = 0; i < small_pool_count; i++)
  {
    if (config.alphanum_kmers)
      s = random_alphanum_string(KMER_DATA_LENGTH);
    else
      std::generate_n(s.begin(), KMER_DATA_LENGTH, std::rand);

    memcpy(sh->kmer_small_pool[i].data, s.data(), s.length());
  }
}

void populate_big_kmer_pool(__shard *sh, const uint64_t small_pool_count,
                            const uint64_t big_pool_count)
{
  std::random_device rd;
  std::mt19937 gen(rd());
  std::uniform_int_distribution<int> udist(0, small_pool_count - 1);

  // printf("[INFO] Shard %u, Populating kmer BIG POOL of %lu elements\n",
  // 	sh->shard_idx, big_pool_count);

  for (size_t i = 0; i < big_pool_count; i++)
  {
    if (config.alphanum_kmers)
    {
      size_t idx = udist(gen);
      std::string s =
          std::string(sh->kmer_small_pool[idx].data, KMER_DATA_LENGTH);
      memcpy(sh->kmer_big_pool[i].data, sh->kmer_small_pool[idx].data,
             KMER_DATA_LENGTH);
    }
    else
    {
      memcpy(sh->kmer_big_pool[i].data, sh->kmer_small_pool[udist(gen)].data,
             KMER_DATA_LENGTH);
    }
  }
}

void write_data(__shard *sh, const char *filename, const char *data,
                uint64_t big_pool_count)
{
  FILE *fp;
  fp = fopen(filename, "wb");
  if (!fp)
  {
    fprintf(stderr, "[ERROR] Cannot open file: %s (%d: %s)\n", filename, errno,
            strerror(errno));
    exit(-1);
  }
  int res = fwrite(data, KMER_DATA_LENGTH, big_pool_count, fp);
  if (res)
  {
    printf("[INFO] Shard %u, Wrote %d items to file: %s\n", sh->shard_idx, res,
           filename);
  }
  else
  {
    printf("[ERROR] Shard %u, cannot read data into big pool\n", sh->shard_idx);
  }
  fclose(fp);
}


char *read_data(__shard *sh, const char *filename)
{
  int fd = open(filename, O_RDONLY);
  struct stat sb;
  if (fstat(fd, &sb) == -1)
  {
    fprintf(stderr, "[ERROR] Shard %u: couldn't get file size\n",
            sh->shard_idx);
  }
  size_t f_sz = sb.st_size;
  // big_pool_count* KMER_DATA_LENGTH;

  printf("[INFO] Shard %u: %s, %lu bytes\n", sh->shard_idx, filename, f_sz);
  char *fmap = (char *)mmap(NULL, f_sz, PROT_READ, MAP_PRIVATE, fd, 0);

  touchpages(fmap, f_sz);

  mlock(fmap, f_sz);

  // printf("[INFO] Shard %u, mlock done\n", sh->shard_idx);

  return fmap;
}

// char *read_fasta(__shard *sh)
// {
//   gzFile fp;
//   kseq_t *seq;
//   int fd;
//   int read;

//   const char *filename = config.in_file.c_str();

//   fd = open(filename, O_RDONLY);
//   fp = gzdopen(fd);
//   size_t f_sz = (sh->f_end - sh->f_start);
//   printf("[INFO] Shard %u: start: %lu, end: %lu, %lu bytes\n", sh->shard_idx,
//          sh->f_start, sh->f_end, f_sz);

//   while((read = kseq_read(seq)) >=0)
//   {

//   }

//   char *fmap = (char *)mmap(NULL, f_sz, PROT_READ, MAP_PRIVATE, fd, 0);

//   __touch(fmap, f_sz);
//   mlock(fmap, f_sz);
//   return NULL;
// }

/* 	The small pool and big pool is there to carefully control the ratio of
total k-mers to unique k-mers.	*/

void create_data(__shard *sh)
{
  uint64_t KMER_BIG_POOL_COUNT =
      config.kmer_create_data_base * config.kmer_create_data_mult;
  uint64_t KMER_SMALL_POOL_COUNT = config.kmer_create_data_uniq;

  // 	printf("[INFO] Shard %u, Creating kmer SMALL POOL of %lu elements\n",
  // 		sh->shard_idx, KMER_SMALL_POOL_COUNT);

  sh->kmer_small_pool = (Kmer_s *)memalign(
      CACHE_LINE_SIZE, sizeof(Kmer_s) * KMER_SMALL_POOL_COUNT);

  if (!sh->kmer_small_pool)
  {
    printf("[ERROR] Shard %u, Cannot allocate memory for SMALL POOL\n",
           sh->shard_idx);
  }

  // 	printf("[INFO] Shard %u Creating kmer BIG POOL of %lu elements\n",
  // 		sh->shard_idx, KMER_BIG_POOL_COUNT);

  sh->kmer_big_pool = (Kmer_s *)memalign(CACHE_LINE_SIZE,
                                         sizeof(Kmer_s) * KMER_BIG_POOL_COUNT);

  if (!sh->kmer_big_pool)
  {
    printf("[ERROR] Shard %u, Cannot allocate memory for BIG POOL\n",
           sh->shard_idx);
  }

  std::string pool_filename_format =
      config.kmer_files_dir + std::string("%02u.bin");
  char pool_filename[pool_filename_format.length()];
  sprintf(pool_filename, pool_filename_format.c_str(), sh->shard_idx);

  if (config.mode == 1)
  {
    generate_random_data_small_pool(sh, KMER_SMALL_POOL_COUNT);
    populate_big_kmer_pool(sh, KMER_SMALL_POOL_COUNT, KMER_BIG_POOL_COUNT);
  }
  else if (config.mode == 2)
  {
    sh->kmer_big_pool = (Kmer_s *)read_data(sh, pool_filename);
  }
  else if (config.mode == 3)
  {
    generate_random_data_small_pool(sh, KMER_SMALL_POOL_COUNT);
    populate_big_kmer_pool(sh, KMER_SMALL_POOL_COUNT, KMER_BIG_POOL_COUNT);
    write_data(sh, pool_filename, (const char *)sh->kmer_big_pool->data,
               KMER_BIG_POOL_COUNT);
  } else if (config.mode == 5)
  {

  }


  /* We are done with small pool. From now on, only big pool matters */
  free(sh->kmer_small_pool);
}
} // namespace kmercounter
