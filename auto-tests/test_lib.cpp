#include <absl/flags/flag.h>
#include <absl/flags/parse.h>
#include <gtest/gtest.h>

#include "logger.h"

ABSL_FLAG(uint64_t, hashtable_size, 1ull << 11,
          "size of hashtable.");
ABSL_FLAG(uint64_t, test_size, 1ull << 10,
          "size of test(number of insertions/lookup).");

int main(int argc, char **argv) {
  initializeLogger();
  ::testing::InitGoogleTest(&argc, argv);
  absl::ParseCommandLine(argc, argv);
  return RUN_ALL_TESTS();
}