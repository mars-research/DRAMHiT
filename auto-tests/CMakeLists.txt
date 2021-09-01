add_executable(test_runner test_runner.cpp)
target_link_libraries(test_runner gtest_main gtest numa xxhash cityhash)

include(GoogleTest)
gtest_discover_tests(test_runner)
