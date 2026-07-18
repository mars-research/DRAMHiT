#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <unistd.h>
#include <numa.h>
#include <numaif.h>
#include <x86intrin.h>
#include <string.h>
#include <getopt.h>

#include <fcntl.h>
#include <unistd.h>
#define ONE_GB (1024ULL * 1024ULL * 1024ULL)
#define CACHE_LINE_SIZE 64
#define TOTAL_LINES (ONE_GB / CACHE_LINE_SIZE)

// Reads the Linux pagemap to find the true Physical Address of our HugePage
// and calculates where it lands inside the AMD 12MB hardware cycle.
uint64_t get_12mb_cycle_offset(void *vaddr) {
    int fd = open("/proc/self/pagemap", O_RDONLY);
    if (fd < 0) {
        perror("Failed to open pagemap (Run as root!)");
        exit(EXIT_FAILURE);
    }

    // A standard page frame is 4KB
    uint64_t page_size = sysconf(_SC_PAGESIZE);
    uint64_t vpn = (uint64_t)vaddr / page_size;
    uint64_t pfn_item;

    if (pread(fd, &pfn_item, sizeof(pfn_item), vpn * sizeof(pfn_item)) != sizeof(pfn_item)) {
        perror("Failed to read pagemap");
        exit(EXIT_FAILURE);
    }
    close(fd);

    // Check if page is present (Bit 63)
    if ((pfn_item & (1ULL << 63)) == 0) {
        fprintf(stderr, "Page not present in physical memory.\n");
        exit(EXIT_FAILURE);
    }

    // Extract Physical Frame Number (Bits 0-54)
    uint64_t pfn = pfn_item & ((1ULL << 55) - 1);
    uint64_t phys_addr = pfn * page_size + ((uint64_t)vaddr % page_size);

    // Calculate which 1MB Region (0 through 11) this physical address starts at
    uint64_t start_mb = phys_addr / (1024 * 1024);
    uint64_t offset_in_12mb = start_mb % 12;

    printf("[*] HugePage Physical Address: 0x%lx\n", phys_addr);
    printf("[*] HugePage starts at 12MB Cycle Region: %lu\n", offset_in_12mb);

    return offset_in_12mb;
}
int main(int argc, char *argv[]) {
    int opt;
    char *pattern_str = NULL;
    uint64_t num_access = 0;

    // 1. Parse command-line arguments
    while ((opt = getopt(argc, argv, "p:n:")) != -1) {
        switch (opt) {
            case 'p':
                pattern_str = strdup(optarg); // Duplicate so we can safely tokenize
                break;
            case 'n':
                num_access = strtoull(optarg, NULL, 10);
                break;
            default:
                fprintf(stderr, "Usage: %s -p \"x,y,z\" -n <num_accesses>\n", argv[0]);
                return EXIT_FAILURE;
        }
    }

    if (!pattern_str || num_access == 0) {
        fprintf(stderr, "Error: Both -p \"pattern\" and -n <num_accesses> are required.\n");
        fprintf(stderr, "Example: %s -p \"0,1,2,3,12,13,14,15\" -n 1000\n", argv[0]);
        return EXIT_FAILURE;
    }

    // 2. Parse the comma-separated pattern string into an array
    uint64_t *pattern = NULL;
    size_t pattern_len = 0;

    char *token = strtok(pattern_str, ",");
    while (token != NULL) {
        pattern = realloc(pattern, sizeof(uint64_t) * (pattern_len + 1));
        if (!pattern) {
            perror("realloc failed");
            return EXIT_FAILURE;
        }
        pattern[pattern_len++] = strtoull(token, NULL, 10);
        token = strtok(NULL, ",");
    }
    free(pattern_str);

    if (pattern_len == 0) {
        fprintf(stderr, "Error: No valid numbers found in pattern.\n");
        return EXIT_FAILURE;
    }

    printf("[*] Pattern length: %zu. Total Accesses: %lu\n", pattern_len, num_access);

    // 3. Force thread execution onto NUMA Node 0
    printf("[*] Binding process to NUMA Node 0...\n");
    if (numa_available() < 0) {
        fprintf(stderr, "Error: NUMA library not supported on this system\n");
        return EXIT_FAILURE;
    }
    struct bitmask *mask = numa_allocate_nodemask();
    numa_bitmask_setbit(mask, 0);
    numa_bind(mask);
    numa_free_nodemask(mask);

    // 4. Allocate 1GB Hugepage strictly on NUMA Node 0
    printf("[*] Allocating 1GB Hugepage...\n");
    void *ptr = mmap(NULL, ONE_GB, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | (30 << MAP_HUGE_SHIFT), -1, 0);

    if (ptr == MAP_FAILED) {
        perror("mmap 1GB hugepage failed. Ensure 1GB hugepages are reserved");
        return EXIT_FAILURE;
    }


    int mem_node = 0;
    struct bitmask *nodemask = numa_allocate_nodemask();
    numa_bitmask_setbit(nodemask, mem_node);
    if (mbind(ptr, ONE_GB, MPOL_BIND, nodemask->maskp, nodemask->size + 1, 0) < 0) {
        perror("mbind failed");
        munmap(ptr, ONE_GB);
        return EXIT_FAILURE;
    }
    numa_free_nodemask(nodemask);

    typedef char cacheline_t[CACHE_LINE_SIZE];
    cacheline_t *mem_space = (cacheline_t *)ptr;

    // 5. Initialize Memory
    printf("[*] Initializing memory and flushing...\n");
    memset(ptr, 1, ONE_GB);
    for (uint64_t i = 0; i < TOTAL_LINES; i++) {
        _mm_clflush(&mem_space[i][0]);
    }
    // Ensure all flushes hit the data fabric before starting
    _mm_sfence();

    get_12mb_cycle_offset(ptr);

    sleep(1);

    // 6. Main Memory Access Loop (Using Pattern Array)
    printf("[*] Access loop starting now!\n");
    uint64_t accumulator_counter = 0;

    for (uint64_t i = 0; i < num_access; i++) {
        // Find which number in our pattern to use, looping back to the start if needed
        uint64_t target_line = pattern[i % pattern_len];

        // Prevent out-of-bounds access just in case pattern contains a number > TOTAL_LINES
        target_line = target_line % TOTAL_LINES;

        char *addr = &mem_space[target_line][0];

        // Read, write, and flush to guarantee Data Fabric round-trip
        accumulator_counter += *addr;
        *addr = (char)(i % 255) + 1;

        _mm_clflush(addr);
    }

    // Barrier to ensure all requested memory operations retire
    _mm_sfence();

    printf("[*] Loop finished. Accumulator counter total: %lu\n", accumulator_counter);

    // Cleanup
    free(pattern);
    munmap(ptr, ONE_GB);
    return 0;
}
