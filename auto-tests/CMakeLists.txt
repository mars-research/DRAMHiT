add_executable(test_runner test_runner.cpp)
find_package(absl REQUIRED)
target_link_libraries(test_runner gtest_main gtest numa xxhash cityhash absl::flags absl::flags_parse)

include(GoogleTest)
gtest_discover_tests(test_runner)
