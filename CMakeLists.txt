cmake_minimum_required(VERSION 3.13)
project(dramhit VERSION 0.1.0)

# Declare options
option(SANITIZE "Enable ASAN." OFF)
option(SANITIZE_TESTING "Enable ASAN for tests." ON)
option(BUILD_APP "Build the main application, dramhit." ON)
option(BUILD_TESTING "Build tests." OFF)
option(BUILD_EXAMPLE "Build examples." OFF)
option(LEGACY_PAPI "Use Vikram's PAPI stuff to do performance monitering." OFF)
option(HIGH_LEVEL_PAPI "Use PAPI high-level monitoring" OFF)
option(VTUNE "Use VTUNE to do performance monitering." OFF)
option(AGGR "Use aggregation hashtable (histogram)" ON)
option(BQUEUE "Enable bqueue tests" OFF)
option(XORWOW "Xorwow" OFF)
option(BQ_ZIPFIAN "Enable global zipfian distribution generation" ON)
option(BQ_ZIPFIAN_LOCAL "Enable local zipfian distribution generation" OFF)
option(CALC_STATS "Enable hashtable statistics" ON)
option(ZIPF_FAST "Enable faster zipfian distribution generation" ON)
option(LATENCY_COLLECTION "Enable latency data collection" OFF)
option(BQ_KMER_TEST "Bqueue kmer test" OFF)

# Check g++ version
if(CMAKE_CXX_COMPILER_ID STREQUAL GNU AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS 8.0)
    message(FATAL_ERROR "g++ must be version 8.0 or above")
endif()

# Setup default build type to release with debug information
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "" FORCE)
  endif()
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

find_package(Threads REQUIRED)
find_package(Boost 1.67 REQUIRED program_options)
find_package(absl)

# Set up toolchain
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Export compile commands for clang-tidy
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_compile_options(
    -O3
    -Wall
    -g
    -fdiagnostics-color=always
    -mprefetchwt1
    -march=native
    -fcf-protection=none
    -fno-stack-protector
    -funroll-all-loops
    #-rdynamic
)
# Enable lto
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)

# A standalone library without any of the benchmarking/application code.
add_library(dramhit_lib
    "src/hashtables/kvtypes.cpp"
    "src/input_reader/eth_rel_gen.cpp"
    "src/types.cpp"
    "src/zipf_distribution.cpp"
)
target_include_directories(dramhit_lib PUBLIC include lib/plog/include/ lib)
target_link_libraries(dramhit_lib PRIVATE 
    eth_hashjoin
    numa
)

if(BUILD_APP)
    # Build all the source files for the executable.
    add_executable(dramhit
        "src/tests/queue_tests.cpp"
        "src/tests/hashtable_tests.cpp"
        "src/tests/prefetch_tests.cpp"
        "src/tests/cachemiss_test.cpp"
        "src/tests/kmer_tests.cpp"
        "src/tests/kmer_radix_tests.cpp"
        "src/tests/hashjoin_test.cpp"
        "src/tests/rw_ratio.cpp"
        "src/tests/synth_test.cpp"
        "src/misc_lib.cpp"
        "src/xorwow.cpp"
        "src/Application.cpp"
        "src/dramhit.cpp"
        "src/zipf_distribution.cpp"
        "src/Latency.cpp"
    )

    # Add subdirectory
    target_link_directories(dramhit PRIVATE lib/)
    target_link_libraries(dramhit PRIVATE
        dramhit_lib
        fnv
        xxhash
        cityhash
        capstone
        boost_program_options
        Threads::Threads
        absl::flat_hash_map
    )
endif()

# Declare include directory.
include_directories(include/ lib/ lib/cityhash/src/)

# Declare string type options.
set(hasher_types city crc xxhash wyhash citycrc xxhash3 fnv direct_index)
set(HASHER "city" CACHE STRING "Hasher")
#set(HASHER "direct_index" CACHE STRING "Hasher")
set_property(CACHE HASHER PROPERTY STRINGS ${hasher_types})
if (NOT HASHER IN_LIST hasher_types)
    message(FATAL_ERROR "hasher type must be one of: ${hasher_types}; but get ${HASHER}")
else()
    message(WARNING "Hasher type selected was: ${HASHER}")
endif()

set(branch_types simd cmov branched)
set(BRANCH branched CACHE STRING "Branch style")
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
    add_definitions(-DDRAMHIT_ACTIVE_EXPERIMENT=experiment_type::${experiment})
endif()

set(KEY_LEN "8" CACHE STRING "Size of key/value for join benchmarks in bytes")
add_definitions(-DKEY_LEN=${KEY_LEN})

if(KEY_LEN STREQUAL 8)
add_definitions(-DKEY_8B)
endif()

set(KMER_LEN "8" CACHE STRING "The K in KMer")
add_definitions(-DKMER_LEN=${KMER_LEN})

if(ZIPF_FAST)
    message(WARNING "Using fast zipfian")
    add_definitions(-DZIPF_FAST)
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

if(BQ_ZIPFIAN_LOCAL)
    message(WARNING "Zipfian Bqueues")
    add_definitions(-DBQ_TESTS_INSERT_ZIPFIAN_LOCAL)
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
elseif(HASHER STREQUAL "direct_index")
    add_definitions(-DDIRECT_INDEX)
elseif(HASHER STREQUAL "citycrc")
    add_definitions(-DCITY_CRC_HASH)
elseif(HASHER STREQUAL "wyhash")
    add_definitions(-DWYHASH)
endif()

if (LEGACY_PAPI)
    message(WARNING "PAPI support is currently broken!")
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE papi)
    target_link_directories(${CMAKE_PROJECT_NAME} PRIVATE papi/src/)
    include_directories(papi/src/)
    add_definitions(-DWITH_PAPI_LIB)
endif ()

if (HIGH_LEVEL_PAPI)
    message(WARNING "Enabled high-level PAPI support")
    target_link_directories(${CMAKE_PROJECT_NAME} PRIVATE papi/src/)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE papi)
    include_directories(papi/src/)
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
    target_link_libraries(dramhit PRIVATE ${VTUNE_ROOT}/lib64/libittnotify.a dl)
    add_definitions(-DWITH_VTUNE_LIB)
endif ()

if (NOT AGGR)
    add_definitions(-DNOAGGR)
endif ()

if (BQUEUE)
    message(WARNING "Enabling bqueues")
    add_definitions(-DBQ_TESTS_DO_HT_INSERTS)
    #add_definitions(-DBQ_KEY_UPPER_BITS_HAS_HASH)
endif()

if (CALC_STATS)
    message(WARNING "Enabling CALC_STATS")
    add_definitions(-DCALC_STATS)
endif()

if (SANITIZE)
    message(WARNING "Enabling ASAN")
    add_compile_options(-fsanitize=address)
    add_link_options(-fsanitize=address)
endif()

if (LATENCY_COLLECTION)
    message(WARNING "Latency collection enabled")
    add_definitions(-DLATENCY_COLLECTION)
endif()

if (BQ_KMER_TEST)
    message(WARNING "Bqueue kmer test")
    add_definitions(-DBQUEUE_KMER_TEST)
endif()
# Copied from https://github.com/mars-research/kmer-counting-hash-table/blob/129b03a50fa86497f971b43ba91841d830a07faf/Makefile#L32
add_definitions(-D__MMAP_FILE)
add_definitions(-DSERIAL_SCAN)
add_definitions(-DPREFETCH_WITH_PREFETCH_INSTR)
#add_definitions(-DCONFIG_ALIGN_BQUEUE_METADATA)
add_definitions(-DCONFIG_BQUEUE_SECTION)
# add_definitions(-DCONFIG_NUMA_AFFINITY)
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

# Import 3p libraries
add_subdirectory(lib)

if (BUILD_TESTING)
    enable_testing()
    add_subdirectory(unittests)
endif()

if (BUILD_EXAMPLE)
    add_subdirectory(examples)
endif()
