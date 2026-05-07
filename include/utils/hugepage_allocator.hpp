#pragma once

// adapted from https://rigtorp.se/hugepages/

#include <fcntl.h>
#include <sys/mman.h>  // mmap, munmap
#include <cstdint>

#include "plog/Log.h"

#define HUGEPAGE_FILE "/mnt/huge/hugepagefile"
#define MAP_HUGE_2MB (21 << MAP_HUGE_SHIFT)
#define MAP_HUGE_1GB (30 << MAP_HUGE_SHIFT)

template <typename T>
struct huge_page_allocator {
  // Explicitly tell C++ containers to use uint64_t instead of size_t
  using value_type = T;
  using size_type = uint64_t;
  using difference_type = int64_t;

  constexpr static uint64_t huge_page_size_2mb = 1ULL << 21;  // 2 MiB
  constexpr static uint64_t huge_page_size_1gb = 1ULL << 30;  // 1 GiB

  huge_page_allocator() = default;

  template <class U>
  constexpr huge_page_allocator(const huge_page_allocator<U> &) noexcept {}

  uint64_t round_to_huge_page_size(uint64_t n, bool is_1gb) {
    if (is_1gb) {
      return (((n - 1) / huge_page_size_1gb) + 1) * huge_page_size_1gb;
    }
    return (((n - 1) / huge_page_size_2mb) + 1) * huge_page_size_2mb;
  }

  std::pair<bool, uint64_t> get_rounded_alloc_size(uint64_t raw_alloc_sz) {
    auto is_1gb = false;
    uint64_t alloc_sz = 0;

    if (raw_alloc_sz > (huge_page_size_2mb * 100)) {
      is_1gb = true;
      alloc_sz = round_to_huge_page_size(raw_alloc_sz, is_1gb);
    } else {
      alloc_sz = round_to_huge_page_size(raw_alloc_sz, false);
    }
    return std::make_pair(is_1gb, alloc_sz);
  }

  T *allocate(uint64_t n) {
    if (n > std::numeric_limits<uint64_t>::max() / sizeof(T)) {
      throw std::bad_alloc();
    }

    uint64_t raw_alloc_sz = n * sizeof(T);
    uint64_t alloc_sz;
    bool is_1gb;

    std::tie(is_1gb, alloc_sz) = get_rounded_alloc_size(raw_alloc_sz);


    auto MAP_FLAGS = MAP_PRIVATE | MAP_HUGETLB | MAP_ANONYMOUS |
                     (is_1gb ? MAP_HUGE_1GB : MAP_HUGE_2MB);

    auto p = static_cast<T *>(
        mmap(nullptr, alloc_sz, PROT_READ | PROT_WRITE, MAP_FLAGS, -1, 0));

    if (p == MAP_FAILED) {
        PLOGE.printf("allocating %lu bytes, requested %lu bytes, is_1gb %u failed", alloc_sz, raw_alloc_sz, is_1gb);
        std::abort();
    }

    return p;
  }

  void deallocate(T *p, uint64_t n) {
      if (n > std::numeric_limits<uint64_t>::max() / sizeof(T)) {
        throw std::bad_alloc();
      }
    uint64_t raw_alloc_sz = n * sizeof(T);
    uint64_t alloc_sz;
    bool is_1gb;
    std::tie(is_1gb, alloc_sz) = get_rounded_alloc_size(raw_alloc_sz);
    if (p) {
      munmap(p, alloc_sz);
    }
  }

  uint64_t get_actual_bytes(uint64_t n)
  {
      uint64_t raw_alloc_sz = n * sizeof(T);
      uint64_t alloc_sz;
      bool is_1gb;
      std::tie(is_1gb, alloc_sz) = get_rounded_alloc_size(raw_alloc_sz);
      return alloc_sz;
  }

  void prefault(T *p, uint64_t n) {
      if (n > std::numeric_limits<uint64_t>::max() / sizeof(T)) {
        throw std::bad_alloc();
      }
      uint64_t raw_alloc_sz = n * sizeof(T);
      uint64_t alloc_sz;
      bool is_1gb;
      std::tie(is_1gb, alloc_sz) = get_rounded_alloc_size(raw_alloc_sz);

      uint64_t page_size = is_1gb ? huge_page_size_1gb : huge_page_size_2mb;

      // Fixed undefined variables 'arr' and 'bytes'
      volatile char* fault_ptr = reinterpret_cast<volatile char*>(p);

      for (uint64_t offset = 0; offset < alloc_sz; offset += page_size) {
        fault_ptr[offset] = 0;
      }
  }
};
