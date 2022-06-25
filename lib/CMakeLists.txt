# Add CityHash
set(CITY_CONFIG_H ${CMAKE_CURRENT_SOURCE_DIR}/cityhash/config.h)
add_custom_command(
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/cityhash
  OUTPUT ${CITY_CONFIG_H}
  COMMAND ./configure --enable-sse4.2
  #DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/cityhash/config.h.in
)
add_library(cityhash "cityhash/src/city.cc" ${CITY_CONFIG_H})
target_include_directories(cityhash PRIVATE cityhash/ cityhash/src/)

# Add eth_hashjoin
set(ETH_HASHJOIN_CONFIG_H ${CMAKE_CURRENT_SOURCE_DIR}/eth_hashjoin/config.h)
add_custom_command(
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/eth_hashjoin
  OUTPUT ${ETH_HASHJOIN_CONFIG_H}
  COMMAND ./configure --enable-key8B=yes
)
set(ETH_SOURCE_FILES
  "eth_hashjoin/src/cpu_mapping.c"
  "eth_hashjoin/src/generator.c"
)
# Set the source files to c++ files to avoid linkage errors.
set_source_files_properties(${ETH_SOURCE_FILES} PROPERTIES LANGUAGE CXX)
add_library(eth_hashjoin 
  ${ETH_HASHJOIN_CONFIG_H}
  ${ETH_SOURCE_FILES} 
)
target_compile_options(eth_hashjoin PRIVATE -DKEY_8B)

# Add FNV
add_library(fnv "fnv/fnv.c")

# Add XXHASH
add_library(xxhash "xxHash/xxhash.c")