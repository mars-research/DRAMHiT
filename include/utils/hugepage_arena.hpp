#pragma once

#include <sys/mman.h>

#include <cstdint>
#include <cstring>
#include <new>

// Standard definitions in case they are missing from your environment's headers
#ifndef MAP_HUGE_2MB
#define MAP_HUGE_2MB (21 << MAP_HUGE_SHIFT)
#endif
#ifndef MAP_HUGE_1GB
#define MAP_HUGE_1GB (30 << MAP_HUGE_SHIFT)
#endif

template <typename T>
class HugepageArena {
 private:
  constexpr static uint64_t SIZE_2MB = 1ULL << 21;
  constexpr static uint64_t SIZE_1GB = 1ULL << 30;
  constexpr static uint64_t THRESHOLD = 4ULL * 1024 * 1024;  // 128 MB

  uint64_t capacity_1gb;
  uint64_t capacity_2mb;

  char* arena_1gb;
  char* arena_2mb;

  // Tracks the current allocation position within each arena
  uint64_t offset_1gb;
  uint64_t offset_2mb;

 public:
  // Constructor takes the number of 1GB pages and 2MB pages
  HugepageArena(uint64_t num_1gb, uint64_t num_2mb) {
    capacity_1gb = num_1gb * SIZE_1GB;
    capacity_2mb = num_2mb * SIZE_2MB;

    arena_1gb = nullptr;
    arena_2mb = nullptr;
    offset_1gb = 0;
    offset_2mb = 0;

    int base_flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB;

    // Allocate 1GB Arena if requested
    if (capacity_1gb > 0) {
      void* ptr = mmap(nullptr, capacity_1gb, PROT_READ | PROT_WRITE,
                       base_flags | MAP_HUGE_1GB, -1, 0);
      if (ptr == MAP_FAILED) {
        PLOGE.printf("fail to map 2mb pages");
        throw std::bad_alloc();
      }
      arena_1gb = static_cast<char*>(ptr);
      memset(arena_1gb, 0, capacity_1gb);
    }

    // Allocate 2MB Arena if requested
    if (capacity_2mb > 0) {
      void* ptr = mmap(nullptr, capacity_2mb, PROT_READ | PROT_WRITE,
                       base_flags | MAP_HUGE_2MB, -1, 0);
      if (ptr == MAP_FAILED) {
        // Clean up the 1GB arena if the 2MB allocation fails
        if (arena_1gb) munmap(arena_1gb, capacity_1gb);
        PLOGE.printf("fail to map 1gb pages");
        std::abort();
      }
      arena_2mb = static_cast<char*>(ptr);
      memset(arena_2mb, 0, capacity_2mb);
    }
  }

  ~HugepageArena() {
    if (arena_1gb) {
      munmap(arena_1gb, capacity_1gb);
    }
    if (arena_2mb) {
      munmap(arena_2mb, capacity_2mb);
    }
  }

  // Delete copy constructors to prevent accidental double-munmap
  HugepageArena(const HugepageArena&) = delete;
  HugepageArena& operator=(const HugepageArena&) = delete;

  T* alloc_internal(uint64_t alloc_bytes, uint64_t alignment) {

    if (arena_2mb != nullptr) {
      uint64_t aligned_offset = (offset_2mb + alignment - 1) & ~(alignment - 1);

      // Check if 2MB arena has enough remaining space
      if (aligned_offset + alloc_bytes <= capacity_2mb) {
        char* result = arena_2mb + aligned_offset;
        offset_2mb = aligned_offset + alloc_bytes;
        return reinterpret_cast<T*>(result);
      }
    }

    if (arena_1gb != nullptr) {
      uint64_t aligned_offset = (offset_1gb + alignment - 1) & ~(alignment - 1);

      if (aligned_offset + alloc_bytes <= capacity_1gb) {
        char* result = arena_1gb + aligned_offset;
        offset_1gb = aligned_offset + alloc_bytes;
        return reinterpret_cast<T*>(result);
      }
    }

    PLOGE.printf("OOM");
    std::bad_alloc();
  }

  T* aligned_alloc(uint64_t sz, uint64_t alignment) {
    uint64_t alloc_bytes = sz * sizeof(T);
    uint64_t type_alignment = alignof(T);
    // check alignment is multiple of type_alignemtn
    if(alignment % type_alignment) {
        PLOGE.printf("bad alignment user wanted %lu natural type %lu\n", alignment, type_alignment);
        std::bad_alloc();
    }
    return alloc_internal(alloc_bytes, alignment);
  }

  T* alloc(uint64_t sz) {
    uint64_t alloc_bytes = sz * sizeof(T);
    uint64_t alignment = alignof(T);

    return alloc_internal(alloc_bytes, alignment);
  }

  // Reset offsets to reuse both slabs without unmapping
  void reset() {
    offset_1gb = 0;
    offset_2mb = 0;
  }

  // Getters for debugging/telemetry
  uint64_t get_capacity_1gb() const { return capacity_1gb; }
  uint64_t get_capacity_2mb() const { return capacity_2mb; }
  uint64_t get_used_1gb() const { return offset_1gb; }
  uint64_t get_used_2mb() const { return offset_2mb; }
};
