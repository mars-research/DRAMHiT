#pragma once

/**
* Given a value "word", produces an integer in [0,p) without division.
* The function is as fair as possible in the sense that if you iterate
* through all possible values of "word", then you will generate all
* possible outputs as uniformly as possible.
*/
static inline uint64_t fastrange64(uint64_t word, uint64_t p) {
#ifdef __SIZEOF_INT128__ // then we know we have a 128-bit int
	return (uint64_t)(((__uint128_t)word * (__uint128_t)p) >> 64);
#elif defined(_MSC_VER) && defined(_WIN64)
	// supported in Visual Studio 2005 and better
	uint64_t highProduct;
	_umul128(word, p, &highProduct); // ignore output
	return highProduct;
	unsigned __int64 _umul128(
		unsigned __int64 Multiplier,
		unsigned __int64 Multiplicand,
		unsigned __int64 *HighProduct
	);
#else
	return word % p; // fallback
#endif // __SIZEOF_INT128__
}
