
#include "hashtables/ht_helper.hpp"
#include "helper.hpp"
#include "misc_lib.h"
#include "numa.hpp"
#include "plog/Log.h"
#include "sync.h"
#include "tests/BandwidthTest.hpp"
#include "types.hpp"
#include "utils/hugepage_allocator.hpp"
#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

namespace kmercounter {

enum AccessPattern {
  READ = 0,
  SEQUENTIAL_READ = 1,
  RW = 2,
  RATIO_RW = 3,
  SEQ_READ_WRITE = 4,
  STREAMING_KEYS_RANDOM_READ = 5,
  CAS_INSERT = 6
};

extern ExecPhase cur_phase;
extern bool g_app_record_start;
extern uint64_t g_find_start, g_find_end;
extern uint64_t g_insert_start, g_insert_end;

using Cacheline = struct {
  char pad[64];
};
using BWHugepageAlloc = huge_page_allocator<Cacheline>;

inline uint64_t knuth64(uint64_t x) { return x * 11400714819323198485ULL; }

inline uint64_t read_ratio;

inline void prefetch(const Cacheline* vec, uint64_t idx) {
#if L1_PREFETCH
  __builtin_prefetch(&vec[idx], false, 3);
#elif L2_PREFETCH
  __builtin_prefetch(&vec[idx], false, 2);
#elif L3_PREFETCH
  __builtin_prefetch(&vec[idx], false, 1);
#elif NTA_PREFETCH
  __builtin_prefetch(&vec[idx], false, 0);
#else
  __builtin_prefetch(&vec[idx], false, 2);
#endif
}

int find_local_node(int current_node) {
  if (numa_available() < 0) {
    return -1;
  }

  if (numa_bitmask_isbitset(numa_all_nodes_ptr, current_node)) {
    return current_node;
  }

  return -1;
}

/**
 * Forces the migration of a hugepage-backed vector to a remote NUMA node.
 * * @param arr The vector to migrate.
 * @param current_node The NUMA node the thread is currently executing on.
 * @return true if migration succeeded, false otherwise.
 */
void BandwidthTest::run(Shard* sh, const Configuration& config,
                        std::barrier<VoidFn>* barrier) {
  uint64_t size = utils::next_pow2(config.ht_size);
  uint64_t total_bytes = size * sizeof(Cacheline);

  // Round up total_bytes to the nearest 2MB (2 * 1024 * 1024 = 2097152 bytes)
  constexpr uint64_t HUGEPAGE_2MB = 2ULL * 1024ULL * 1024ULL;
  constexpr uint64_t HUGEPAGE_1GB = 1024ULL * 1024ULL * 1024ULL;
  uint64_t alloc_size_1gb_pages =
      (total_bytes + HUGEPAGE_1GB - 1) & ~(HUGEPAGE_1GB - 1);
  uint64_t alloc_size_2mb_pages =
      (total_bytes + HUGEPAGE_2MB - 1) & ~(HUGEPAGE_2MB - 1);

  uint64_t start, end;

  constexpr auto MAP_FLAGS =
      MAP_HUGETLB | MAP_HUGE_1GB | MAP_PRIVATE | MAP_ANONYMOUS;
  uint64_t alloc_size = alloc_size_1gb_pages;
  Cacheline* stream_arr;
  Cacheline* arr = (Cacheline*)mmap(nullptr, alloc_size, PROT_READ | PROT_WRITE,
                                    MAP_FLAGS, -1, 0);

  if (arr == MAP_FAILED) {
    PLOGE.printf("fail to map 1GB pages");
    throw std::bad_alloc();
  }
  if (sh->shard_idx == 0) {
    PLOGI.printf("allocating %lu mb per thread",
                 alloc_size / (1024ULL * 1024ULL));
    start = RDTSC_START();
  }

  if (config.numa_split == THREADS_LOCAL_NUMA_NODE) {
    int to_node = find_local_node(sh->numa_node);
    if (to_node < 0) {
      PLOGE.printf("failed to find local node");
      abort();
    }

    if (!move_memory_to_node((void*)arr, alloc_size, to_node)) {
      PLOGE.printf("failed to bind workload memory to local node");
      abort();
    }
  }

  else if (config.numa_split == THREADS_REMOTE_NUMA_NODE ||
           config.numa_split == THREADS_ALL_NODES_REMOTE_ACCESS) {
    int to_node = sh->numa_node;
    if ((to_node = find_remote_node(sh->numa_node)) < 0) {
      PLOGE.printf("failed to find remote node");
      abort();
    }

    if (!move_memory_to_node((void*)(&arr[0]), alloc_size, to_node)) {
      PLOGE.printf("failed to migrate workload memory");
      abort();
    }
  } else if (config.numa_split == THREADS_SPLIT_EVEN_NODES ||
             config.numa_split == THREADS_MIXED_NUMA_NODE) {
    if (!distribute_memory_to_nodes((void*)arr, alloc_size)) {
      PLOGE.printf("failed to distribute workload memory");
      abort();
    }
  }

  volatile char* fault_ptr = reinterpret_cast<volatile char*>(arr);
  for (uint64_t offset = 0; offset < alloc_size; offset += HUGEPAGE_2MB) {
    fault_ptr[offset] = 0;
  }

  if (sh->shard_idx == 0) {
    end = RDTSCP();
    PLOGI.printf("took %lu cycles per cacheline on mmap and mbind",
                 (end - start) / size);
  }

  // Allocate extra buffer, which we will read sequentially to illustrate
  // zipfian keys streaming
  if (config.sequential == STREAMING_KEYS_RANDOM_READ) {
    stream_arr = (Cacheline*)mmap(
        nullptr, alloc_size, PROT_READ | PROT_WRITE,
        MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | MAP_HUGE_2MB, -1, 0);

    if (stream_arr == MAP_FAILED) {
      PLOGE.printf("fail to map 2mb pages");
      throw std::bad_alloc();
    }

    if (config.numa_split == THREADS_LOCAL_NUMA_NODE) {
      int to_node = find_local_node(sh->numa_node);
      if (to_node < 0) {
        PLOGE.printf("failed to find local node");
        abort();
      }

      if (!move_memory_to_node((void*)arr, alloc_size, to_node)) {
        PLOGE.printf("failed to bind workload memory to local node");
        abort();
      }
    }

    else if (config.numa_split == THREADS_REMOTE_NUMA_NODE ||
             config.numa_split == THREADS_ALL_NODES_REMOTE_ACCESS) {
      int to_node = sh->numa_node;
      if ((to_node = find_remote_node(sh->numa_node)) < 0) {
        PLOGE.printf("failed to find remote node");
        abort();
      }

      if (!move_memory_to_node((void*)(&stream_arr[0]), alloc_size, to_node)) {
        PLOGE.printf("failed to migrate workload memory");
        abort();
      }
    } else if (config.numa_split == THREADS_SPLIT_EVEN_NODES ||
               config.numa_split == THREADS_MIXED_NUMA_NODE) {
      if (!distribute_memory_to_nodes((void*)stream_arr, alloc_size)) {
        PLOGE.printf("failed to distribute workload memory");
        abort();
      }
    }

    fault_ptr = reinterpret_cast<volatile char*>(stream_arr);
    for (uint64_t offset = 0; offset < alloc_size; offset += HUGEPAGE_2MB) {
      fault_ptr[offset] = 0;
    }
  }  // end allocating/bdinding streaming array

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::insertions;
    g_app_record_start = true;
  }
  barrier->arrive_and_wait();

#ifdef AVX_SUPPORT

  __m512i zero_vec_512 = _mm512_setzero_si512();

  for (uint64_t i = 0; i < size; i++) {
    _mm512_stream_si512((__m512i*)&arr[i], zero_vec_512);
  }
  if (config.sequential == STREAMING_KEYS_RANDOM_READ) {
    for (uint64_t i = 0; i < size; i++) {
      _mm512_stream_si512((__m512i*)&stream_arr[i], zero_vec_512);
    }
  }
#else
  std::cerr << "AVX_SUPPORT not enabled but in bandwidth_test.cpp" << std::endl;
  std::abort();
#endif

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::insertions;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();
  if (sh->shard_idx == 0) {
    PLOGI.printf("took %lu cycles per cacheline on write",
                 (g_insert_end - g_insert_start) / size);
  }

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = true;
    PLOGI.printf("Bandwidth test start");
  }
  barrier->arrive_and_wait();

#ifdef WITH_VTUNE_LIB
  static const auto vtune_event =
      __itt_event_create("find_workload", strlen("find_workload"));
  __itt_event_start(vtune_event);
#endif

  for (int repeat_iterations = 0; repeat_iterations < config.read_factor;
       repeat_iterations++) {
    // Sequential Reads

    if (config.sequential == SEQUENTIAL_READ) {
      uint64_t dummy_sum = 0;
      uint64_t idx = 0;
      uint64_t stride = 128;

      for (uint64_t i = 0; (i + stride) < size; i += stride) {
        uint64_t offset = i + stride;
        for (uint64_t j = i; j < offset; j++) {
          prefetch(arr, j);
        }
        // we have to do this so amd doesn't ignore prefetches
        for (uint64_t k = i; k < offset; k++) {
          dummy_sum += *(reinterpret_cast<const uint64_t*>(&arr[k]));
        }
      }
      // so it doesn't optimize out
      asm volatile("" : : "g"(dummy_sum) : "memory");

    } else if (config.sequential == STREAMING_KEYS_RANDOM_READ) {
      uint64_t stride = 64;
      uint64_t dummy_sum = 0;
      uint64_t idx = 0;
      uint64_t stream_idx = 0;
      for (uint64_t i = 0; (i + stride) < size; i += stride) {
        uint64_t offset = i + stride;
        for (uint64_t j = i; j < offset; j++) {
          idx = knuth64(j) & (size - 1);
          prefetch(arr, idx);

          // every 4th ie j % 4 != 0
          if (j & 3) prefetch(stream_arr, j);
        }

        // for (uint64_t j = i; j < offset; j++) {
        //   if (j & 3)
        //     dummy_sum += *(reinterpret_cast<const
        //     uint64_t*>(&stream_arr[j]));
        // }

        for (uint64_t k = i; k < offset; k++) {
          idx = knuth64(k) & (size - 1);
          *(uint64_t*)&arr[idx] = 14;
        }
      }

      // so it doesn't optimize out
      // asm volatile("" : : "g"(dummy_sum) : "memory");
    }  // end STREAMING_KEYS_RANDOM_READ

    // Random Reads
    else if (config.sequential == READ) {
      uint64_t dummy_sum = 0;
      uint64_t idx = 0;
      uint64_t stride = 64;

      for (uint64_t i = 0; (i + stride) < size; i += stride) {
        uint64_t offset = i + stride;
        for (uint64_t j = i; j < offset; j++) {
          idx = knuth64(j) & (size - 1);
          prefetch(arr, idx);
        }

        for (uint64_t k = i; k < offset; k++) {
          idx = knuth64(k) & (size - 1);
          dummy_sum += *(reinterpret_cast<const uint64_t*>(&arr[idx]));
        }
      }
      // so it doesn't optimize out
      asm volatile("" : : "g"(dummy_sum) : "memory");

    } else if (config.sequential == CAS_INSERT) {
      // printf("josh\n");
      uint64_t stride = 64;
      uint64_t idx = 0;
      for (uint64_t i = 0; (i + stride) < size; i += stride) {
        uint64_t offset = i + stride;
        for (uint64_t j = i; j < offset; j++) {
          idx = knuth64(j) & (size - 1);
          prefetch(arr, idx);
        }

        for (uint64_t k = i; k < offset; k++) {
          idx = knuth64(k) & (size - 1);

          uint64_t* ptr = (uint64_t*)&arr[idx];

          uint64_t expected;
          uint64_t desired = k;

          do {
            expected = *ptr;
          } while (!__sync_bool_compare_and_swap(ptr, expected, desired));
        }
      }

    }

    // 1Read + 1Write
    else if (config.sequential == RW) {
      uint64_t stride = 64;
      uint64_t idx = 0;
      for (uint64_t i = 0; (i + stride) < size; i += stride) {
        uint64_t offset = i + stride;
        for (uint64_t j = i; j < offset; j++) {
          idx = knuth64(j) & (size - 1);
          prefetch(arr, idx);
        }

        for (uint64_t k = i; k < offset; k++) {
          idx = knuth64(k) & (size - 1);
          *(uint64_t*)&arr[idx] = 14;
        }
      }
    }
    // 1.X ratio Read  1 Write
    else if (config.sequential == RATIO_RW) {
      uint64_t dummy_sum = 0;
      uint64_t idx = 0;
      uint64_t stride = 64;
      // write_ratio = 1/X=1.5 , or whatever ratio u want
      uint64_t write_ratio = 42;
      read_ratio = stride / write_ratio;
      for (uint64_t i = 0; (i + stride) < size; i += stride) {
        uint64_t offset = i + stride;
        for (uint64_t j = i; j < offset; j++) {
          idx = knuth64(j) & (size - 1);
          prefetch(arr, idx);
        }

        uint64_t write_offset = i + write_ratio;

        for (uint64_t k = i; k < write_offset; k++) {
          idx = knuth64(k) & (size - 1);
          *(uint64_t*)&arr[idx] = 14;
        }

        // read rest of non-written cachelines, without this loop prefetches are
        // dropped on AMD
        uint64_t read_offset = write_offset;
        for (uint64_t k = read_offset; k < offset; k++) {
          idx = knuth64(k) & (size - 1);
          dummy_sum += *(reinterpret_cast<const uint64_t*>(&arr[idx]));
        }
        asm volatile("" : : "g"(dummy_sum) : "memory");
      }
    }

    // 1Read + 1Write sequential
    else if (config.sequential == SEQ_READ_WRITE) {
      uint64_t idx = 0;
      uint64_t stride = 128;

      for (uint64_t i = 0; (i + stride) < size; i += stride) {
        uint64_t offset = i + stride;
        for (uint64_t j = i; j < offset; j++) {
          prefetch(arr, j);
        }
        for (uint64_t k = i; k < offset; k++) {
          *(uint64_t*)&arr[k] = 14;
        }
      }
    }

  }  // end repeat experiment iterations

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = false;
    PLOGI.printf("Bandwidth test end");
  }

#ifdef WITH_VTUNE_LIB
  __itt_event_end(vtune_event);
#endif
  barrier->arrive_and_wait();

  if (config.sequential == RW || config.sequential == 4) {
    // account that we are doing 2 memory transactions, ie, 1 read and 1 write
    sh->stats->finds.op_count = (size * config.read_factor) * 2;
  } else if (config.sequential == RATIO_RW) {
    sh->stats->finds.op_count = (size * config.read_factor) * 2;
  }

  else if (config.sequential == STREAMING_KEYS_RANDOM_READ) {
    // too account that every 4th read we perform an extra sequential read. ie 1
    // read + 1 write + .25 read note this is not the same as 1.2 ratio read, as
    // the .25 read is sequential read of a private array
    sh->stats->finds.op_count = (size * config.read_factor) * 2.25;
  } else {
    sh->stats->finds.op_count = size * config.read_factor;
  }

  sh->stats->finds.duration = g_find_end - g_find_start;
  if (sh->shard_idx == 0) {
    PLOGI.printf("took %lu cycles per cacheline on read",
                 (g_find_end - g_find_start) / size);
  }

  munmap(arr, alloc_size);

}  // run

}  // namespace kmercounter
