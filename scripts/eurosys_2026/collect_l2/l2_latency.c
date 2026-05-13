#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <x86intrin.h> // For __rdtsc()
#include <sys/mman.h>  // For mmap()

// 2MB Huge Page Size
#define HUGE_PAGE_SIZE (2 * 1024 * 1024)

// Standard AMD/Intel cache line size
#define CACHE_LINE_SIZE 64

// Working sizes in bytes
#define TARGET_SIZE_BYTES   (512 * 1024)  // 512 KiB
#define WORKLOAD_SIZE_BYTES (256 * 1024)  // 256 KiB

// Define a structure that exactly matches a 64-byte cache line
typedef struct {
    uint32_t value;                                    // 4 bytes for our data
    uint8_t padding[CACHE_LINE_SIZE - sizeof(uint32_t)]; // 60 bytes of dead space
} __attribute__((aligned(CACHE_LINE_SIZE))) cache_line_t;

// Number of elements
// Target array now has far fewer elements (512KiB / 64B = 8,192 elements)
#define TARGET_ELEMENTS   (TARGET_SIZE_BYTES / sizeof(cache_line_t))
// Workload array still uses 4-byte integers (256KiB / 4B = 65,536 elements)
#define WORKLOAD_ELEMENTS (WORKLOAD_SIZE_BYTES / sizeof(uint32_t))

// Number of times to repeat the measurement loop
#define ITERATIONS 10000

int main() {
    // Allocate using mmap with MAP_HUGETLB to force 2MB huge pages
    volatile cache_line_t *target = (volatile cache_line_t *)mmap(NULL,
                                                                  HUGE_PAGE_SIZE,
                                                                  PROT_READ | PROT_WRITE,
                                                                  MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB,
                                                                  -1, 0);

    uint32_t *workload = (uint32_t *)mmap(NULL,
                                          HUGE_PAGE_SIZE,
                                          PROT_READ | PROT_WRITE,
                                          MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB,
                                          -1, 0);

    if (target == MAP_FAILED || workload == MAP_FAILED) {
        fprintf(stderr, "mmap failed! Ensure Huge Pages are configured in the OS.\n");
        fprintf(stderr, "Run: sudo sysctl -w vm.nr_hugepages=10\n");
        return 1;
    }

    // 1. Initialize target array to handle page faults early
    for (uint32_t i = 0; i < TARGET_ELEMENTS; i++) {
        target[i].value = 0;
    }

    // 2. Prepopulate workload with random indices.
    // It will pick a random cache line from the 8,192 available.
    for (uint32_t i = 0; i < WORKLOAD_ELEMENTS; i++) {
        workload[i] = rand() % TARGET_ELEMENTS;
    }

    // 3. Warm-up phase (Pulls data into L2 cache and warms up the TLB)
    for (uint32_t i = 0; i < WORKLOAD_ELEMENTS; i++) {
        target[workload[i]].value = workload[i];
    }

    // 4. Measurement phase
    unsigned int ui;
    uint64_t start_cycles = __rdtscp(&ui);

    for (int iter = 0; iter < ITERATIONS; iter++) {
        for (uint32_t i = 0; i < WORKLOAD_ELEMENTS; i++) {
            // Read workload index, write into the specific cache line
            target[workload[i]].value = workload[i];
        }
    }

    uint64_t end_cycles = __rdtscp(&ui);

    // 5. Calculate results
    uint64_t total_cycles = end_cycles - start_cycles;
    uint64_t total_operations = (uint64_t)ITERATIONS * WORKLOAD_ELEMENTS;
    double cycles_per_iteration = (double)total_cycles / total_operations;

    printf("--- L2 Cache Write Experiment (64-Byte Strided) ---\n");
    printf("Target Array Size:   %u KiB (%lu elements @ 64 Bytes each)\n", TARGET_SIZE_BYTES / 1024, TARGET_ELEMENTS);
    printf("Workload Array Size: %u KiB (%lu elements @ 4 Bytes each)\n", WORKLOAD_SIZE_BYTES / 1024, WORKLOAD_ELEMENTS);
    printf("Total Operations:    %lu\n", total_operations);
    printf("Total Cycles:        %lu\n", total_cycles);
    printf("\nCycles per iteration (Read + Write): %.2f\n", cycles_per_iteration);

    // Clean up
    munmap((void*)target, HUGE_PAGE_SIZE);
    munmap(workload, HUGE_PAGE_SIZE);

    return 0;
}
