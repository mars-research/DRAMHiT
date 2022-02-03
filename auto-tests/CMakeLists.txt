find_package(absl REQUIRED)
include(GoogleTest)

add_library(test_lib test_lib.cpp)
target_link_libraries(test_lib PUBLIC
  ht_lib
  absl::flags
  absl::flags_parse
  absl::strings
  Boost::boost
  gtest
)

function(add_kvstore_test test_name)
  add_executable(${test_name} ${test_name}.cpp)
  target_link_libraries(${test_name} test_lib)
  gtest_discover_tests(${test_name})
endfunction()

add_kvstore_test(aggregation_test)
add_kvstore_test(hashmap_test)

subdirs(input_reader)
subdirs(utils)


