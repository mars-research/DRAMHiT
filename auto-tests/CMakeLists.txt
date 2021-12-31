find_package(absl REQUIRED)

add_executable(aggregation_test aggregation_test.cpp)
target_link_libraries(aggregation_test ht_lib gtest numa xxhash cityhash absl::flags absl::flags_parse)

add_executable(hashmap_test hashmap_test.cpp)
target_link_libraries(hashmap_test ht_lib gtest_main gtest numa xxhash cityhash absl::flags absl::flags_parse)

include(GoogleTest)
gtest_discover_tests(aggregation_test)
gtest_discover_tests(hashmap_test)
