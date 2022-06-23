#include <absl/flags/flag.h>
#include <absl/flags/parse.h>
#include <gtest/gtest.h>

#include "logging.hpp"

ABSL_FLAG(uint64_t, hashtable_size, 1ull << 11, "size of hashtable.");
ABSL_FLAG(uint64_t, test_size, 1ull << 10,
          "size of test(number of insertions/lookup).");
ABSL_FLAG(
    int, log_level, plog::info,
    "Log level of plog. See "
    "https://github.com/SergiusTheBest/plog/blob/master/include/plog/Severity.h"
    "for more options");

int main(int argc, char **argv) {
  initializeLogger();
  ::testing::InitGoogleTest(&argc, argv);
  absl::ParseCommandLine(argc, argv);
  plog::get()->setMaxSeverity(plog::info);
  return RUN_ALL_TESTS();
}