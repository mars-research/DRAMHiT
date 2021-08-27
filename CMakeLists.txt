cmake_minimum_required(VERSION 3.13)
project(kvstore VERSION 0.1.0)

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
add_executable(kvstore
    "src/bqueue.cpp"
    "src/tests/bq_tests.cpp"
    "src/tests/hashtable_tests.cpp"
	"src/tests/prefetch_tests.cpp"
	"src/tests/cachemiss_test.cpp"
    "src/misc_lib.cpp"
    "src/Application.cpp"
    "src/kvstore.cpp"
)

# Add subdirectory
add_subdirectory(lib)
target_link_directories(kvstore PRIVATE lib/)
target_link_libraries(kvstore PRIVATE fnv xxhash cityhash)

# Declare include directory.
include_directories(include/ lib/)

# Declare options
option(PAPI "Use PAPI to do performance monitering." OFF)
option(VTUNE "Use VTUNE to do performance monitering." OFF)
option(AGGR "Something about AGGR" ON)
option(PREFETCH "Enable prefetching" ON)
option(BQUEUE "Enable bqueue tests" OFF)
option(XORWOW "Xorwow" OFF)
option(BQ_ZIPFIAN "Enable bqueue zipfian generation" OFF)
set(BRANCH "simd" CACHE STRING "Branch style")
set(HASHER "xxhash" CACHE STRING "Hasher")

if(XORWOW)
    message(WARNING "Xorwow synthetic tests")
    add_definitions(-DXORWOW)
endif()

if(BQ_ZIPFIAN)
    message(WARNING "Zipfian Bqueues")
    add_definitions(-DBQ_TESTS_INSERT_ZIPFIAN)
endif()

if(BRANCH STREQUAL "simd")
    message(WARNING "Building with SIMD branchless")
    add_definitions(-DBRANCHLESS_SIMD)
elseif(BRANCH STREQUAL "cmov")
    message(WARNING "Building with CMOVE branchless")
    add_definitions(-DBRANCHLESS_CMOVE)
endif()

if(HASHER STREQUAL "city")
    message(WARNING "Building with HASHER city")
    add_definitions(-DCITY_HASH)
elseif(HASHER STREQUAL "xxhash")
    message(WARNING "Building with HASHER xxhash")
    add_definitions(-DXX_HASH)
elseif(HASHER STREQUAL "xxhash3")
    message(WARNING "Building with HASHER xxhash3")
    add_definitions(-DXX_HASH_3)
elseif(HASHER STREQUAL "fnv")
    message(FATAL_ERROR "FNV is slow. Don't use.")
    add_definitions(-DFNV_HASH)
elseif(HASHER STREQUAL "crc")
    message(WARNING "Building with HASHER crc")
    add_definitions(-DCRC_HASH)
else()
    message(FATAL_ERROR "Invalid HASHER: ${HASHER}")
endif()

# set(LIBPAPI libpapi.a)
# set(PAPILIBDIR ${CMAKE_CURRENT_SOURCE_DIR}/papi/src/install/lib/)
# set(PAPILIB ${PAPILIBDIR}/${LIBPAPI}) 
# if (PAPI)
#     target_link_libraries(${CMAKE_PROJECT_NAME} ${PAPILIB})
#     include_directories(${CMAKE_CURRENT_SOURCE_DIR}/papi/src/install/include/)
#     add_definitions(-DWITH_PAPI_LIB)
# endif ()

set(VTUNE_ROOT "/opt/intel/oneapi/vtune/latest/")
if (VTUNE)
    message(WARNING "Building with vtune")
    include_directories(${VTUNE_ROOT}/include/)
    target_link_libraries(kvstore PRIVATE ${VTUNE_ROOT}/lib64/libittnotify.a dl)
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
add_definitions(-DSERIAL_SCAN)
add_definitions(-DPREFETCH_WITH_PREFETCH_INSTR)
add_definitions(-DHUGE_1GB_PAGES)
add_definitions(-DBQ_TESTS_DO_HT_INSERTS)
# add_definitions(-DTOUCH_DEPENDENCY)
# add_definitions(-DXORWOW_SCAN)
# add_definitions(-DSAME_KMER)
# add_definitions(-DPREFETCH_TWOLINE)
# add_definitions(-DPREFETCH_WITH_WRITE)
# add_definitions(-DPREFETCH_RUN)
# add_definitions(-DBQ_TESTS_INSERT_XORWOW)
# add_definitions(-DCHAR_ARRAY_PARSE_BUFFER)
# add_definitions(-DNO_CORNER_CASES)
# add_definitions(-DBQ_TESTS_USE_HALT)
# add_definitions(-DUSE_ATOMICS)

target_link_libraries(kvstore PRIVATE boost_program_options numa Threads::Threads)

enable_testing()
add_subdirectory(auto-tests)
