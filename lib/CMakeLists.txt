# Add FNV
add_library(fnv "fnv/fnv.c")

# Add XXHASH
add_library(xxhash "xxHash/xxhash.c")

# Add CityHash
set(CITY_CONFIG_H ${CMAKE_CURRENT_SOURCE_DIR}/cityhash/config.h)
add_custom_command(
  OUTPUT ${CITY_CONFIG_H}
  COMMAND ./configure --enable-sse4.2
  #DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/cityhash/config.h.in
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/cityhash
)
add_library(cityhash "cityhash/src/city.cc" ${CITY_CONFIG_H})
target_include_directories(cityhash PRIVATE cityhash/ cityhash/src/)