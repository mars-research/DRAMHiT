#pragma once

// adapted from https://rigtorp.se/hugepages/

#include <sys/mman.h> // mmap, munmap

template <typename T> struct huge_page_allocator {
  constexpr static std::size_t huge_page_size_2mb = 1 << 21; // 2 MiB
  constexpr static std::size_t huge_page_size_1gb = 1 << 30; // 1 GiB
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

    auto MAP_FLAGS = MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB
        | (is_1gb ? MAP_HUGE_1GB : MAP_HUGE_2MB);

    PLOGI.printf("n = %lu raw_alloc_sz %zu | alloc_sz %zu, is_1gb %d", n, raw_alloc_sz, alloc_sz, is_1gb);
    auto p = static_cast<T *>(mmap( nullptr, alloc_sz, PROT_READ | PROT_WRITE,
          MAP_FLAGS, -1, 0));

    if (p == MAP_FAILED) {
      printf("map failed %d\n", errno);
      perror("mmap");
      throw std::bad_alloc();
    } else {
      size_t len_split = alloc_sz >> 1;
      void *addr_split = (char *)p + len_split;
      unsigned long nodemask[4096] = {0};
      auto current_node = numa_node_of_cpu(sched_getcpu());

      nodemask[0] = 1 << (!current_node);

      PLOGI.printf("Moving half the memory to node %d", !current_node);

      long ret = mbind(addr_split, len_split, MPOL_BIND, nodemask, 4096,
          MPOL_MF_MOVE | MPOL_MF_STRICT);

      PLOGI.printf("calling mbind with addr %p | len %zu | nodemask %p",
            addr_split, len_split, nodemask);
      if (ret < 0) {
        perror("mbind");
        PLOGE.printf("mbind ret %ld | errno %d", ret, errno);
      }
    }
    return p;
  }

  void deallocate(T *p, std::size_t n) {
    auto raw_alloc_sz = n * sizeof(T);
    uint64_t alloc_sz;
    bool is_1gb;
    std::tie(is_1gb, alloc_sz) = get_rounded_alloc_size(raw_alloc_sz);

    munmap(p, alloc_sz);
  }
};

