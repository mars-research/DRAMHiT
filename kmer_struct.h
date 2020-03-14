#ifndef _KMER_STRUCT_H
#define _KMER_STRUCT_H

#define KMER_DATA_LENGTH 50

/*
4 bits per nucleotide, k=100 => 400 bits (~50 bytes)
3 bits per nucleotide, k=100 => 300 bits (~38 bytes)
*/
// kmer (key)
struct Kmer_s
{
  char data[KMER_DATA_LENGTH];
};

typedef struct Kmer_s Kmer_s;

#endif /* _KMER_STRUCT_H */
