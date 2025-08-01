cmake_minimum_required(VERSION 3.13)
project(dramhit VERSION 0.1.0)

# To select SIMD or CMOV type for partitioned hashtable, use -DBRANCH= To set the variable.

# Declare options
option(SANITIZE "Enable ASAN." OFF)
option(SANITIZE_TESTING "Enable ASAN for tests." ON)
option(BUILD_APP "Build the main application, dramhit." ON)
option(BUILD_TESTING "Build tests." OFF)
option(BUILD_EXAMPLE "Build examples." OFF)

option(AGGR "Use aggregation hashtable (histogram)" OFF)
option(BQUEUE "Enable bqueue tests" OFF)
option(XORWOW "Xorwow" OFF)
option(BQ_ZIPFIAN "Enable global zipfian distribution generation" ON)
option(BQ_ZIPFIAN_LOCAL "Enable local zipfian distribution generation" OFF)
option(CALC_STATS "Enable hashtable statistics" OFF)
option(ZIPF_FAST "Enable faster zipfian distribution generation" ON)
option(LATENCY_COLLECTION "Enable latency data collection" OFF)
option(BQ_KMER_TEST "Bqueue kmer test" OFF)
option(AVX_SUPPORT "SIMD" ON)
option(UNIFORM_PROBING "Uniform hashing" OFF)
option(FAST_RANGE "fast range" OFF)
option(PART_ID "partition id for multilevel and partition hashtable" OFF)
option(OLD_DRAMHiT "dramhit, no bucket, no simd, just branch" OFF)
option(DRAMHiT_MANUAL_INLINE "dramhit inlined" OFF)
option(BUCKETIZATION "buckets" OFF)
option(BUDDY_QUEUE "remote access experiment" OFF)
option(REMOTE_QUEUE "remote prefetch engine" OFF)
option(READ_BEFORE_CAS "read before cas" OFF)
option(INCREMENT "Increment idx for hashtable test" OFF)

if(INCREMENT)
    add_definitions(-DINCREMENT)
endif()

if(READ_BEFORE_CAS)
    add_definitions(-DREAD_BEFORE_CAS)
endif()

if(REMOTE_QUEUE)
    add_definitions(-DREMOTE_QUEUE)
endif()

if(BUDDY_QUEUE)
    add_definitions(-DBUDDY_QUEUE)
endif() 

if(OLD_DRAMHiT)
    add_definitions(-DDRAMHiT_2023)
else()
    if(DRAMHiT_MANUAL_INLINE) 
    else()
        add_definitions(-DDRAMHiT_2025)
    endif()
endif() 

if(BUCKETIZATION)
    add_definitions(-DBUCKETIZATION)
endif() 

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
    -march=native
    -fcf-protection=none
    -fno-stack-protector
    -funroll-all-loops
    #-rdynamic
    #-mpreferred-stack-boundary=6
)
# Enable lto
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)

# A standalone library without any of the benchmarking/application code.
add_library(dramhit_lib
    "src/hashtables/kvtypes.cpp"
    "src/input_reader/eth_rel_gen.cpp"
    "src/types.cpp"
    "src/zipf_distribution.cpp"
    "src/misc_lib.cpp"
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
    )


endif()

# Declare include directory.
include_directories(include/ lib/ lib/cityhash/src/)

# Declare string type options.
set(hasher_types city crc xxhash wyhash citycrc xxhash3 fnv direct_index)


set(HASHER "crc" CACHE STRING "Hasher")
#set(HASHER "direct_index" CACHE STRING "Hasher")
set_property(CACHE HASHER PROPERTY STRINGS ${hasher_types})
if (NOT HASHER IN_LIST hasher_types)
    message(FATAL_ERROR "hasher type must be one of: ${hasher_types}; but get ${HASHER}")
else()
    message(WARNING "Hasher type selected was: ${HASHER}")
endif()

if(FAST_RANGE)
    message(WARNING "fastrange on")
    add_definitions(-DFAST_RANGE)
endif() 

if(PART_ID)
    message(WARNING "part_id enabled")
    add_definitions(-DPART_ID)
endif() 

if(UNIFORM_PROBING)
    message(WARNING "uniform hashtable")
    add_definitions(-DUNIFORM_HT_SUPPORT)
endif() 

if(AVX_SUPPORT)
    message(WARNING "SIMD supported, you may set BRANCH variable to simd")
    add_definitions(-DAVX_SUPPORT)
else()
    message(WARNING "SIMD not supported")
endif() 

set(branch_types simd cmov branched)

if(AVX_SUPPORT)
    set(BRANCH branched CACHE STRING "Branch style")
else()
    set(BRANCH cmov CACHE STRING "Branch style")
endif() 

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
    add_definitions(-DCAS_SIMD)
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



# Benchmark backend

set(BENCHMARK_BACKEND "NONE" CACHE STRING "Benchmark backend to use (PERFCPP, PCM, LEGACY_PAPI, HIGH_LEVEL_PAPI, VTUNE, NONE)")

set(VALID_BACKENDS PERFCPP PCM LEGACY_PAPI HIGH_LEVEL_PAPI VTUNE NONE)

list(FIND VALID_BACKENDS ${BENCHMARK_BACKEND} BACKEND_INDEX)
if(BENCHMARK_BACKEND AND BACKEND_INDEX EQUAL -1)
    message(STATUS "No benchmarking backend selected.")
elseif(BENCHMARK_BACKEND)
    message(STATUS "Selected benchmarking backend: ${BENCHMARK_BACKEND}")
else()
    message(STATUS "No benchmarking backend selected.")
endif()

if (BENCHMARK_BACKEND STREQUAL "LEGACY_PAPI")
    message(WARNING "PAPI support is currently broken!")
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE papi)
    target_link_directories(${CMAKE_PROJECT_NAME} PRIVATE papi/src/)
    include_directories(papi/src/)
    add_definitions(-DWITH_PAPI_LIB)
elseif (BENCHMARK_BACKEND STREQUAL "HIGH_LEVEL_PAPI")
    message(WARNING "Enabled high-level PAPI support")
    target_link_directories(${CMAKE_PROJECT_NAME} PRIVATE papi/src/)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE papi)
    include_directories(papi/src/)
    add_definitions(-DENABLE_HIGH_LEVEL_PAPI)
elseif (BENCHMARK_BACKEND STREQUAL "PCM")
    set(PCM_LIB_PATH "${CMAKE_SOURCE_DIR}/pcm/build/src/libpcm.a")
    set(PCM_INCLUDE_PATH "${CMAKE_SOURCE_DIR}/pcm/src/")

    if (NOT EXISTS ${PCM_LIB_PATH})
        message(STATUS "libpcm.a not found. Running PCM build script...")

        # Run your PCM build script (make sure it's executable)
        execute_process(
            COMMAND ${CMAKE_SOURCE_DIR}/scripts/build_pcm.sh
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/scripts
            RESULT_VARIABLE PCM_BUILD_RESULT
        )

        if (NOT PCM_BUILD_RESULT EQUAL 0)
            message(FATAL_ERROR "PCM build script failed with exit code ${PCM_BUILD_RESULT}")
        endif()
    endif()

    message(WARNING "Building with intel pcm from ${PCM_LIB_PATH}")

    target_link_libraries(dramhit PRIVATE ${PCM_LIB_PATH})
    target_include_directories(dramhit PRIVATE ${PCM_INCLUDE_PATH})

    add_definitions(-DWITH_PCM)
elseif (BENCHMARK_BACKEND STREQUAL "PERFCPP")
    message(WARNING "Building with perf-cpp from ${CMAKE_CURRENT_BINARY_DIR}")

    # Add the perf-cpp subdirectory (make sure the path to the perf-cpp source is correct)
    add_subdirectory(${CMAKE_SOURCE_DIR}/perf-cpp ${CMAKE_CURRENT_BINARY_DIR}/perf-cpp-build)

    # Include perf-cpp headers
    target_include_directories(dramhit PRIVATE ${CMAKE_SOURCE_DIR}/perf-cpp/include)

    # Link perf-cpp static library
    target_link_libraries(dramhit PRIVATE perf-cpp)

    # Add the define for using perf-cpp
    add_definitions(-DWITH_PERFCPP)
elseif (BENCHMARK_BACKEND STREQUAL "VTUNE")
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
