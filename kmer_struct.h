#ifndef _KMER_STRUCT_H
#define _KMER_STRUCT_H

#define LENGTH				50
#define CACHE_LINE_SIZE			64

// kmer (key)
struct 	Kmer_s {
	union{
		struct {
			char data[LENGTH];
			char padding[CACHE_LINE_SIZE - LENGTH];
		};
		uint64_t data_64bit;
	};
};

typedef struct Kmer_s Kmer_s;

#endif /* _KMER_STRUCT_H */
