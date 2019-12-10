#ifndef _KMER_CLASS_H_
#define _KMER_CLASS_H_

#include <cstring>
#include "city/city.h"
#include "tbb/scalable_allocator.h"
#include "tbb/tbb_allocator.h"
#include "data_types.h"

#define KMER_ALIGNMENT		64

#define CONFIG_ALIGNED_ALLOC

class Kmer {
  public:
    Kmer() { }
    Kmer(const base_4bit_t *data, unsigned len) : kmer_len(len)
    {
	allocmem(len);
#ifndef NDEBUG
	std::cout << "constructor called this: " << this << " data: "  << _data << std::endl;
#endif
	memcpy(_data, data, kmer_len);
	_hash = CityHash128((const char*)data, len);
    }
    inline const uint64_t hash() const {
	return _hash.first;
    }

    Kmer(const Kmer &obj) : _hash(obj._hash), kmer_len(obj.kmer_len) {
	allocmem(kmer_len);
	memcpy(_data, obj._data, kmer_len);
#ifndef NDEBUG
	std::cout << "copy constructor " << this << " called from obj: " << &obj << " obj._data " << obj._data << " _data : " << _data << std::endl;
#endif
    }

    void allocmem(unsigned len) {
#ifdef CONFIG_ALIGNED_ALLOC
	_data = (base_4bit_t*) scalable_aligned_malloc(len, KMER_ALIGNMENT);
#else
	_data = (base_4bit_t*) malloc(len);
#endif
    }

    void freemem(void) {
#ifdef CONFIG_ALIGNED_ALLOC
	    scalable_aligned_free(_data);
#else
	    free(_data);
#endif
    }

    Kmer(Kmer &&obj) :_hash(obj._hash), kmer_len(obj.kmer_len), _data(obj._data) {
#ifndef NDEBUG
	std::cout << "move constructor " << this << " called from obj: " << &obj << std::endl;
#endif
	obj._data = nullptr;
    }

    ~Kmer() {
#ifndef NDEBUG
	     std::cout << "destructor called this: " << this << " _data: " << _data << std::endl;
#endif
	     if(_data != nullptr) {
		freemem();
		_data = nullptr;
	     }
    }

    inline bool operator== (const Kmer &x) const {
	return x._hash == _hash;
    }
    const uint128 full_hash() const {
	return _hash;
    }
  private:
     base_4bit_t *_data;
     uint128 _hash;
     uint8_t kmer_len;
};

// hash and compare function - using cityhash
struct Kmer_hash_compare {
	inline size_t hash( const Kmer &k ) {
		return k.hash();
	}
	//! True if strings are equal
	inline bool equal( const Kmer & x, const Kmer &y ) const {
		return x.hash() == y.hash();
	}
};

struct Kmer_hash {
	//! True if strings are equal
	inline size_t operator()(const Kmer & k) const {
		return k.hash();
	}
	typedef ska::power_of_two_hash_policy hash_policy;
};

struct Kmer_str_hash {
	inline size_t operator()(const std::string & s) const {
		return CityHash128((const char*)s.data(), s.size()).first;
	}
	typedef ska::power_of_two_hash_policy hash_policy;
};

struct Kmer_equal {
	//! True if strings are equal
	inline bool operator()( const Kmer &x, const Kmer &y ) const {
		return x.hash() == y.hash();
	}
};

struct Kmer_str_equal {
	//! True if strings are equal
	inline bool operator()( const std::string &s1, const std::string &s2 ) const {
		return s1 == s2;
	}
};

size_t hash_to_cpu(Kmer &k, uint32_t threadIdx, uint32_t numCons)
{
	uint32_t queueNo = ((k.hash() * 11400714819323198485llu) >> 58) % numCons;
	//send_to_queue(queueNo, threadIdx, k);
}

#endif /* _KMER_H_ */
