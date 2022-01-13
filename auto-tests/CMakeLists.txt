find_package(absl REQUIRED)
include(GoogleTest)

add_library(test_lib test_lib.cpp)
target_link_libraries(test_lib ht_lib gtest absl::flags absl::flags_parse)

add_executable(aggregation_test aggregation_test.cpp)
target_link_libraries(aggregation_test test_lib)
gtest_discover_tests(aggregation_test)

add_executable(hashmap_test hashmap_test.cpp)
target_link_libraries(hashmap_test test_lib)
gtest_discover_tests(hashmap_test)

