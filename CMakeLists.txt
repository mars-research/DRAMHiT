cmake_minimum_required(VERSION 3.0.0)
project(kmercounter VERSION 0.1.0)

# Ensure g++
if(NOT CMAKE_CXX_COMPILER_ID STREQUAL GNU)
    message(FATAL_ERROR "Currently only gcc builds are supported")
endif()

# Check g++ version
if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 8.0)
    message(FATAL_ERROR "g++ must be version 8.0 or above")
endif()

find_package(Threads REQUIRED)

# Set up toolchain
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
add_compile_options(-Wall -mprefetchwt1 -march=native -fcf-protection=none)

# Build all the source files.
add_executable(${CMAKE_PROJECT_NAME}
    "src/bqueue.cpp"
    "src/hashers/xx/xxhash.cpp"
    "src/tests/bq_tests.cpp"
    "src/tests/hashtable_tests.cpp"
	"src/tests/parser_tests.cpp"
	"src/tests/prefetch_tests.cpp"
	"src/tests/cachemiss_test.cpp"
    "src/misc_lib.cpp"
    "src/ac_kseq.cpp"
    "src/ac_kstream.cpp"
    "src/Application.cpp"
    "src/kmercounter.cpp")

# Declare include directory.
include_directories(include/ include/xx include/city)

# Declare options
option(PAPI "Use PAPI to do performance monitering." OFF)
option(VTUNE "Use VTUNE to do performance monitering." OFF)
option(AGGR "Something about AGGR" ON)
option(PREFETCH "Enable prefetching" ON)
option(BQUEUE "Enable bqueue tests" OFF)
set(BRANCH "" CACHE STRING "Branch style")

if(BRANCH STREQUAL "simd")
    message(WARNING "Building with SIMD branchless")
    add_definitions(-DBRANCHLESS_SIMD)
elseif(BRANCH STREQUAL "cmov")
    message(WARNING "Building with CMOVE branchless")
    add_definitions(-DBRANCHLESS_CMOVE)
endif()

# set(LIBPAPI libpapi.a)
# set(PAPILIBDIR ${CMAKE_CURRENT_SOURCE_DIR}/papi/src/install/lib/)
# set(PAPILIB ${PAPILIBDIR}/${LIBPAPI}) 
# if (PAPI)
#     target_link_libraries(${CMAKE_PROJECT_NAME} ${PAPILIB})
#     include_directories(${CMAKE_CURRENT_SOURCE_DIR}/papi/src/install/include/)
#     add_definitions(-DWITH_PAPI_LIB)
# endif ()

set(VTUNE_ROOT /opt/vtune/vtune_profiler_2020.1.0.607630)
if (VTUNE)
    target_link_libraries(${CMAKE_PROJECT_NAME} dl ittnotify)
    include_directories(${VTUNE_ROOT}/include/)
    add_definitions(-DWITH_VTUNE_LIB)
endif ()

if (NOT AGGR)
    add_definitions(-DNOAGGR)
endif ()

if(NOT PREFETCH)
    message(WARNING "Disabling prefetching")
    add_definitions(-DNO_PREFETCH)
endif()

if (BQUEUE)
    message(WARNING "Enabling bqueues")
    add_definitions(-DBQ_TESTS_DO_HT_INSERTS)
endif()

# Copied from https://github.com/mars-research/kmer-counting-hash-table/blob/129b03a50fa86497f971b43ba91841d830a07faf/Makefile#L32
# add_definitions(-DCALC_STATS)
add_definitions(-D__MMAP_FILE)
# add_definitions(-DTOUCH_DEPENDENCY)
add_definitions(-DSERIAL_SCAN)
# add_definitions(-DXORWOW_SCAN)
add_definitions(-DPREFETCH_WITH_PREFETCH_INSTR)
# add_definitions(-DSAME_KMER)
# add_definitions(-DPREFETCH_TWOLINE)
# add_definitions(-DPREFETCH_WITH_WRITE)
# add_definitions(-DPREFETCH_RUN)
add_definitions(-DHUGE_1GB_PAGES)
# add_definitions(-DCITY_HASH)
# add_definitions(-DFNV_HASH)
add_definitions(-DXX_HASH)
# add_definitions(-DXX_HASH_3)
# add_definitions(-DBQ_TESTS_INSERT_XORWOW)
# add_definitions(-DCHAR_ARRAY_PARSE_BUFFER)
# add_definitions(-DNO_CORNER_CASES)
add_definitions(-DBQ_TESTS_DO_HT_INSERTS)
# add_definitions(-DBQ_TESTS_USE_HALT)
# add_definitions(-DUSE_ATOMICS)

# Config branching option
set(BRANCH "")
if ("${BRANCH}" STREQUAL "cmov")
    add_definitions(-DBRANCHLESS_CMOVE)
elseif ("${BRANCH}" STREQUAL "simd")
    add_definitions(-DBRANCHLESS_SIMD) 
endif ()

target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE boost_program_options numa Threads::Threads)
