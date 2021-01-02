#ifndef __LOCK_TEST_HPP__
#define __LOCK_TEST_HPP__

#include "types.hpp"

namespace kmercounter {

constexpr inline std::size_t NUM_INCREMENTS = 1'000'000;

struct LockTest {
  void spinlock_increment_test_run(Configuration const&);
  void atomic_increment_test_run(Configuration const&);
  void uncontended_increment_test_run(Configuration const&);
  void uncontended_lock_test_run(Configuration const&);
};

} // namespace kmercounter

#endif // __LOCK_TEST_HPP__
