#include "hashtables/kvtypes.hpp"

#include <iostream>

namespace kmercounter {

std::ostream& operator<<(std::ostream& os, const ItemQueue& q) {
    return os << "{key: " << q.key
              << ",value: " << q.value
              << ",key_id: " << q.key_id
              << ",idx:" << q.idx
              << ",part_id:" << q.part_id
#ifdef COMPARE_HASH
              << ",key_hash:" << q.key_hash
#endif
              << "}" << std::endl;
              ;
}
} // namespace kmercounter