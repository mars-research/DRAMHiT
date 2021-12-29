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
find_package(Boost 1.67 REQUIRED program_options)

# Set up toolchain
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
add_compile_options(
    -Wall
    -mprefetchwt1
    -march=native
    -fcf-protection=none
)

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
include_directories(include/ lib/ lib/cityhash/src/ lib/plog/include/)

# Declare options
option(BUILD_TESTING "Build tests." OFF)
option(HUGEPAGES "Enable hugepages allocation." ON)
option(LEGACY_PAPI "Use Vikram's PAPI stuff to do performance monitering." OFF)
option(HIGH_LEVEL_PAPI "Use PAPI high-level monitoring" OFF)
option(VTUNE "Use VTUNE to do performance monitering." OFF)
option(AGGR "Use aggregation hashtable (histogram)" ON)
option(PREFETCH "Enable prefetching" ON)
option(BQUEUE "Enable bqueue tests" OFF)
option(XORWOW "Xorwow" OFF)
option(BQ_ZIPFIAN "Enable bqueue zipfian generation" OFF)
option(CALC_STATS "Enable hashtable statistics" OFF)

set(hasher_types city crc xxhash wyhash citycrc xxhash3 fnv)
set(HASHER "xxhash" CACHE STRING "Hasher")
set_property(CACHE HASHER PROPERTY STRINGS ${hasher_types})
if (NOT HASHER IN_LIST hasher_types)
    message(FATAL_ERROR "hasher type must be one of: ${hasher_types}")
else()
    message(WARNING "Hasher type selected was: ${HASHER}")
endif()

set(branch_types simd cmov branched)
set(BRANCH simd CACHE STRING "Branch style")
set_property(CACHE BRANCH PROPERTY STRINGS ${branch_types})
if (NOT BRANCH IN_LIST branch_types)
    message(FATAL_ERROR "branching type must be one of: ${branch_types}")
else()
    message(WARNING "Branch type selected was: ${BRANCH}")
endif()

set(experiments none prefetch_only nop_insert insert_dry_run aggr_kv_write_key_only)
set(experiment none CACHE STRING "Benchmarking experiment")
set_property(CACHE experiment PROPERTY STRINGS ${experiments})
if (NOT experiment IN_LIST experiments)
    message(FATAL_ERROR "experiment must be one of: ${experiments}")
else()
    message(WARNING "Building for experiment: ${experiment}")
    if (NOT experiment STREQUAL none AND NOT BRANCH STREQUAL branched)
        message(FATAL_ERROR "Branchless insertion not supported by all experiments")
    endif()
    add_definitions(-DKVSTORE_ACTIVE_EXPERIMENT=experiment_type::${experiment})
endif()

if (HUGEPAGES)
    message(WARNING "Enabling hugepages allocation.")
    add_definitions(-DHUGE_1GB_PAGES)
endif()

if(XORWOW)
    message(WARNING "Xorwow synthetic tests")
    add_definitions(-DXORWOW)
    add_definitions(-DBQ_TESTS_INSERT_XORWOW_NEW)
endif()

if(BQ_ZIPFIAN)
    message(WARNING "Zipfian Bqueues")
    add_definitions(-DBQ_TESTS_INSERT_ZIPFIAN)
endif()

if(BRANCH STREQUAL "simd")
    add_definitions(-DBRANCHLESS_SIMD)
elseif(BRANCH STREQUAL "cmov")
    add_definitions(-DBRANCHLESS_CMOVE)
elseif(BRANCH STREQUAL "branched")
endif()

if(HASHER STREQUAL "city")
    add_definitions(-DCITY_HASH)
elseif(HASHER STREQUAL "xxhash")
    add_definitions(-DXX_HASH)
elseif(HASHER STREQUAL "xxhash3")
    add_definitions(-DXX_HASH_3)
elseif(HASHER STREQUAL "fnv")
    add_definitions(-DFNV_HASH)
elseif(HASHER STREQUAL "crc")
    add_definitions(-DCRC_HASH)
elseif(HASHER STREQUAL "citycrc")
    add_definitions(-DCITY_CRC_HASH)
elseif(HASHER STREQUAL "wyhash")
    add_definitions(-DWYHASH)
endif()

if (LEGACY_PAPI)
    message(WARNING "PAPI support is currently broken!")
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE papi)
    add_definitions(-DWITH_PAPI_LIB)
endif ()

if (HIGH_LEVEL_PAPI)
    message(WARNING "Enabled high-level PAPI support")
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE papi)
    add_definitions(-DENABLE_HIGH_LEVEL_PAPI)
endif ()

if (VTUNE)
    if (NOT VTUNE_ROOT)
        set(VTUNE_ROOT "/opt/intel/oneapi/vtune/latest/")
    endif ()

    message(WARNING "Using VTUNE_ROOT: ${VTUNE_ROOT}")

    find_file(ITT_HEADER NAMES "ittnotify.h" PATHS "${VTUNE_ROOT}/include/")
    find_file(ITT_LIB NAMES "libittnotify.a" PATHS "${VTUNE_ROOT}/lib64/")

    if (ITT_HEADER STREQUAL "ITT_HEADER-NOTFOUND" OR ITT_LIB STREQUAL "ITT_LIB-NOTFOUND")
        message(FATAL_ERROR "Could not find itt libs/headers! Check ${VTUNE_ROOT} directory")
    endif ()

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

if (CALC_STATS)
    message(WARNING "Enabling CALC_STATS")
    add_definitions(-DCALC_STATS)
endif()

# Copied from https://github.com/mars-research/kmer-counting-hash-table/blob/129b03a50fa86497f971b43ba91841d830a07faf/Makefile#L32
add_definitions(-D__MMAP_FILE)
add_definitions(-DSERIAL_SCAN)
add_definitions(-DPREFETCH_WITH_PREFETCH_INSTR)
add_definitions(-DCONFIG_ALIGN_BQUEUE_METADATA)
# add_definitions(-DXX_HASH)
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

if (BUILD_TESTING)
    enable_testing()
    add_subdirectory(auto-tests)
endif()
