#include "types.hpp"

#include <iostream>

std::ostream& operator<<(std::ostream& os, const Keys& x) {
  return os << "{key: " << x.key
        << ", id: " << x.id
        << ", part_id: " << x.part_id
        << "}" << std::endl;
        ;
}

std::ostream& operator<<(std::ostream& os, const Values& x) {
  return os << "{value: " << x.value
          << ", id: " << x.id
          << "}" << std::endl;
          ;
}
