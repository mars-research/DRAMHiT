#ifndef _KMER_STRUCT_H
#define _KMER_STRUCT_H

#define LENGTH					50
#define CACHE_LINE_SIZE			64

// kmer (key)
struct 	Kmer_s {
		char data[LENGTH];
};

typedef struct Kmer_s Kmer_s;

#endif /* _KMER_STRUCT_H */
