
#ifndef __BANDWIDTH_TEST_HPP__
#define __BANDWIDTH_TEST_HPP__

#include <barrier>
#include "types.hpp"

namespace kmercounter {

class BandwidthTest {
 public:
  /// Load and join two tables from filesystem.
  void run(Shard *sh, const Configuration &config, std::barrier<VoidFn> *barrier);
};

}  // namespace kmercounter

#endif  // __HASHJOIN_TEST_HPP__
