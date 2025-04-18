find_package(absl REQUIRED)
include(GoogleTest)

add_library(test_lib test_lib.cpp)
target_link_libraries(test_lib PUBLIC
  absl::flags
  absl::flags_parse
  absl::strings
  absl::flat_hash_map
  Boost::boost
  gmock
  gtest
)
target_include_directories(test_lib PUBLIC ../lib/plog/include/)


function(add_dramhit_test test_name)
  add_executable(${test_name} ${test_name}.cpp)
  target_link_libraries(${test_name} test_lib dramhit_lib)
  gtest_discover_tests(${test_name})
  if (SANITIZE_TESTING)
    target_compile_options(${test_name} PRIVATE -fsanitize=address)
    target_link_options(${test_name} PRIVATE -fsanitize=address)
  endif()
endfunction()

function(add_test1 test_name)
  add_executable(${test_name} ${test_name}.cpp)
  target_link_libraries(${test_name} test_lib)
  gtest_discover_tests(${test_name})
  if (SANITIZE_TESTING)
    target_compile_options(${test_name} PRIVATE -fsanitize=address)
    target_link_options(${test_name} PRIVATE -fsanitize=address)
  endif()
endfunction()

add_dramhit_test(aggregation_test)
add_dramhit_test(hashmap_test)
add_dramhit_test(types_test)

subdirs(input_reader)
subdirs(utils)


