#include "types.hpp"

#include <gtest/gtest.h>


#include <absl/hash/hash_testing.h>

namespace kmercounter {
namespace {
TEST(FindResult, Hash) {
  EXPECT_TRUE(absl::VerifyTypeImplementsAbslHashCorrectly({
      FindResult(),
      FindResult(1, 2),
      FindResult(2, 3),
      FindResult(0, 0),
  }));
}
}  // namespace
}  // namespace kmercounter
