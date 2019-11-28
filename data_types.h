#ifndef _DATA_TYPES_H
#define _DATA_TYPES_H

typedef struct {
  unsigned high: 4;
  unsigned low: 4;
} __attribute__((packed)) base_4bit_t ;


// kmer data (value)
struct Kmer_value_t {
  uint64_t counter;
};

#endif /* _DATA_TYPES_H */
