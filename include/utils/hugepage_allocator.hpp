#pragma once

// adapted from https://rigtorp.se/hugepages/

#include <sys/mman.h>  // mmap, munmap

#define HUGEPAGE_FILE "/mnt/huge/hugepagefile"
template <typename T>
struct huge_page_allocator {
  constexpr static std::size_t huge_page_size_2mb = 1 << 21;  // 2 MiB
  constexpr static std::size_t huge_page_size_1gb = 1 << 30;  // 1 GiB

  using value_type = T;

  huge_page_allocator() = default;
  template <class U>
  constexpr huge_page_allocator(const huge_page_allocator<U> &) noexcept {}

  uint64_t round_to_huge_page_size(size_t n, bool is_1gb) {
    if (is_1gb) {
      return (((n - 1) / huge_page_size_1gb) + 1) * huge_page_size_1gb;
    }
    return (((n - 1) / huge_page_size_2mb) + 1) * huge_page_size_2mb;
  }

  std::pair<bool, size_t> get_rounded_alloc_size(size_t raw_alloc_sz) {
    auto is_1gb = false;
    uint64_t alloc_sz = 0;
    // FIXME: Preallocate enough 2MiB pages instead of transparent pages
    // somehow it fails to allocate even 100+ 2MiB pages through mmap.
    // maybe mmap doesn't do transparent and expects preconfigured pages.
    if (raw_alloc_sz > (huge_page_size_2mb * 100)) {
      is_1gb = true;
      alloc_sz = round_to_huge_page_size(raw_alloc_sz, is_1gb);
    } else {
      alloc_sz = round_to_huge_page_size(raw_alloc_sz, false);
    }
    return std::make_pair(is_1gb, alloc_sz);
  }

  T *allocate(std::size_t n) {
    if (n > std::numeric_limits<std::size_t>::max() / sizeof(T)) {
      throw std::bad_alloc();
    }

    auto raw_alloc_sz = n * sizeof(T);
    uint64_t alloc_sz;
    bool is_1gb;

    std::tie(is_1gb, alloc_sz) = get_rounded_alloc_size(raw_alloc_sz);

    int fd = open(HUGEPAGE_FILE, O_CREAT | O_RDWR, 0755);

    if (fd < 0) {
      PLOGE.printf("Couldn't open file %s:", HUGEPAGE_FILE);
      perror("");
      exit(1);
    }

    auto MAP_FLAGS = MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB |
                     (is_1gb ? MAP_HUGE_1GB : MAP_HUGE_2MB);

    auto p = static_cast<T *>(
        mmap(nullptr, alloc_sz, PROT_READ | PROT_WRITE, MAP_FLAGS, fd, 0));
    close(fd);
    unlink(HUGEPAGE_FILE);

    if (p == MAP_FAILED) {
      PLOGE.printf("map failed %d", errno);
      throw std::bad_alloc();
    }

    PLOGV.printf("huge page %p with sz %lu mapped", p, alloc_sz);

    return p;
  }

  void deallocate(T *p, std::size_t n) {
    auto raw_alloc_sz = n * sizeof(T);
    uint64_t alloc_sz;
    bool is_1gb;
    std::tie(is_1gb, alloc_sz) = get_rounded_alloc_size(raw_alloc_sz);

    if (p) {
      munmap(p, alloc_sz);
      PLOGV.printf("huge page %p with sz %lu unmapped", p, alloc_sz);
    }
  }
};
