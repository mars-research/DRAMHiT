#include "types.hpp"

#include <iostream>

std::ostream& operator<<(std::ostream& os, const Values& x) {
  return os << "{value: " << x.value
          << ", id: " << x.id
          << "}" << std::endl;
          ;
}
