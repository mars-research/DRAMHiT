#include "hashtables/kvtypes.hpp"

#include <iostream>

namespace kmercounter {

BQUEUE_LOAD bq_load = BQUEUE_LOAD::None;

std::ostream& operator<<(std::ostream& os, const ItemQueue& q) {
  return os << "{key: " << q.key << ",value: " << q.value
            << ",key_id: " << q.key_id << ",idx:" << q.idx
            << ",part_id:" << q.part_id
#ifdef COMPARE_HASH
            << ",key_hash:" << q.key_hash
#endif
            << "}";
}

std::ostream& operator<<(std::ostream& os, const KVPair& x) {
  return os << "{key: " << x.key << ",value: " << x.value << "}" << std::endl;
}
}  // namespace kmercounter