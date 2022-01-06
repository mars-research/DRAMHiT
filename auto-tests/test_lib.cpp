#include <absl/flags/flag.h>
#include <absl/flags/parse.h>
#include <gtest/gtest.h>

#include "logger.h"

ABSL_FLAG(int, hashtable_size, 1ull << 26,
          "size of hashtable.");
ABSL_FLAG(int, test_size, 1ull << 12,
          "size of test(number of insertions/lookup).");

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  absl::ParseCommandLine(argc, argv);
  initializeLogger();
  return RUN_ALL_TESTS();
}