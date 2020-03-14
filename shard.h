#ifndef _SHARDS_H
#define _SHARDS_H

#include "kmer_struct.h"

typedef struct
{
  Kmer_s* kmer_big_pool;
  Kmer_s* kmer_small_pool;
  uint32_t shard_idx;
} Shard;

#endif /*_SHARDS_H*/