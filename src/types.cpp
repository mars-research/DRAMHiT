#include "types.hpp"

#include <iostream>

#include "eth_hashjoin/src/types64.hpp"

namespace kmercounter {
std::ostream& operator<<(std::ostream& os, const InsertFindArgument& x) {
  return os << "{key: " << x.key << ", id: " << x.id
            << ", part_id: " << x.part_id << "}" << std::endl;
  ;
}

std::ostream& operator<<(std::ostream& os, const FindResult& x) {
  return os << "{value: " << x.value << ", id: " << x.id << "}" << std::endl;
  ;
}

KeyValuePair::KeyValuePair(const eth_hashjoin::tuple_t& tuple)
    : key(tuple.key), value(tuple.payload) {}

KeyValuePair::KeyValuePair(uint64_t key, uint64_t value) : key(key), value(value) {}
KeyValuePair::KeyValuePair() : key(0), value(0) {}


Key::Key(const uint64_t &key, const uint64_t &value) : key(key) {}
Key::Key() : key(0) {}

// Global config. This is a temporary dirty hack.
Configuration config;
// Extern stuff
const char* ht_type_strings[] = {
    "",
    "PARTITIONED",
    "",
    "CASHT++",
    "ARRAY_HT",
    "MULTI_HT",
    "UNIFORM_HT",
    "CLHT_HT"
};
const char* run_mode_strings[] = {
    "",
    "DRY_RUN",
    "READ_FROM_DISK",
    "WRITE_TO_DISK",
    "FASTQ_WITH_INSERT",
    "FASTQ_NO_INSERT",
    "SYNTH",
    "PREFETCH",
    "BQ_TESTS_YES_BQ",
    "BQ_TESTS_NO_BQ",
    "CACHE_MISS",
    "ZIPFIAN",
    "HASHJOIN",
};
}  // namespace kmercounter