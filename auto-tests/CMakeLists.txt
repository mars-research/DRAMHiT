add_executable(find_inserted find_inserted.cpp ../src/hashers/xx/xxhash.cpp)
target_link_libraries(find_inserted numa)
add_test(partitioned_find_inserted find_inserted partitioned)
add_test(cas_find_inserted find_inserted cas)
