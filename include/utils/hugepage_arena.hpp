#pragma once

#include <cstdint>
#include <new>
#include <sys/mman.h>
#include <cstring>

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
    constexpr static uint64_t THRESHOLD_128MB = 128ULL * 1024 * 1024; // 128 MB

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

    T* alloc(uint64_t sz) {
        uint64_t alloc_bytes = sz * sizeof(T);
        uint64_t alignment = alignof(T);

        // 1. Try to allocate from the 2MB arena if size < 128MB
        if (alloc_bytes < THRESHOLD_128MB && arena_2mb != nullptr) {
            uint64_t aligned_offset = (offset_2mb + alignment - 1) & ~(alignment - 1);

            // Check if 2MB arena has enough remaining space
            if (aligned_offset + alloc_bytes <= capacity_2mb) {
                char* result = arena_2mb + aligned_offset;
                offset_2mb = aligned_offset + alloc_bytes;
                return reinterpret_cast<T*>(result);
            }
        }

        // 2. Fallback to 1GB arena (either because it's >= 128MB, or the 2MB arena was full)
        if (arena_1gb != nullptr) {
            uint64_t aligned_offset = (offset_1gb + alignment - 1) & ~(alignment - 1);

            if (aligned_offset + alloc_bytes <= capacity_1gb) {
                char* result = arena_1gb + aligned_offset;
                offset_1gb = aligned_offset + alloc_bytes;
                return reinterpret_cast<T*>(result);
            }
        }

        // 3. If neither pool can fulfill the request, throw
        PLOGE.printf("Arena out of memory");
        std::abort();
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
