#include "./include/misc_lib.h"

uint64_t get_file_size(const char* fn)
{
  int fd = open(fn, O_RDONLY);
  struct stat sb;
  if (fstat(fd, &sb) == -1) {
    fprintf(stderr, "[ERROR] Couldn't stat file size\n");
    exit(-1);
  }
  return sb.st_size;
}

uint64_t round_down(uint64_t n, uint64_t m)
{
  return n >= 0 ? (n / m) * m : ((n - m + 1) / m) * m;
}

uint64_t round_up(uint64_t n, uint64_t m)
{
  return n >= 0 ? ((n + m - 1) / m) * m : (n / m) * m;
}

// TODO max value of k to support?s
uint64_t calc_num_kmers(uint64_t l, uint8_t k) { return (l - k + 1); }

int find_last_N(const char* c)
{
  if (!c) return -1;
  int i = KMER_DATA_LENGTH;
  while (--i >= 0) {
    if (c[i] == 'N' || c[i] == 'n') {
      return i;
    }
  }
  return -1;
}

/*	Touching pages bring mmaped pages into memory. Possibly because we
have lot of memory, pages are never swapped out. mlock itself doesn't
seem to bring pages into memory (it should as per the man page)
TODO look into this.	*/
uint64_t __attribute__((optimize("O0"))) touchpages(char *fmap, size_t sz)
{
  uint64_t sum = 0; 
  for (uint64_t i = 0; i < sz; i += __PAGE_SIZE)
    sum += fmap[i];
  return sum; 
}


