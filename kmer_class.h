#ifndef _KMER_CLASS_H_
#define _KMER_CLASS_H_

#define KMER_ALIGNMENT		32
#include "data_types.h"
#include "city.h"

class Kmer {

private:
	base_4bit_t *_data;
	uint128 _hash;
	uint8_t kmer_len;

public:
	Kmer();

	Kmer(const base_4bit_t *data, unsigned len);

	uint64_t hash() const {
		return _hash.first;
	}

	inline bool operator==(const Kmer x) {
		return x._hash == _hash;
	}
};

// hash and compare function - using cityhash
// struct Kmer_hash_compare {
// 	inline size_t hash( const Kmer &k ) {}
// 	inline bool equal( const Kmer & x, const Kmer &y ) const {}
// };

// struct Kmer_hash {
// 	//! True if strings are equal
// 	inline bool operator()(const Kmer & k) const {
// 		return k.hash();
// 	}
// 	typedef ska::power_of_two_hash_policy hash_policy;
// };

// struct Kmer_equal {
// 	//! True if strings are equal
// 	inline bool operator()( const Kmer x, const Kmer y ) const {
// 		return x.hash() == y.hash();
// 	}
// };

// size_t hash_to_cpu(Kmer &k, uint32_t threadIdx, uint32_t numCons)
// {
// 	uint32_t queueNo = ((k.hash() * 11400714819323198485llu) >> 58) % numCons;
// 	//send_to_queue(queueNo, threadIdx, k);
// }

#endif /* _KMER_H_ */
