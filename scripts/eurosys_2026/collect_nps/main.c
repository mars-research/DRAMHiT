#define _GNU_SOURCE // Required for pthread_barrier on some systems
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sys/mman.h>
#include <numa.h>
#include <numaif.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>

#define HUGE_PAGE_SIZE (2 * 1024 * 1024) // 2MB
#ifndef MAP_HUGE_2MB
#define MAP_HUGE_2MB (21 << 26)
#endif

#define MAX_PATTERNS 64
#define MAX_REGIONS 64
#define NUM_ITERATIONS 100 // Adjust as needed

typedef struct {
    int cpu_node;
    int mem_node;
    int num_threads;
} pattern_t;

typedef struct {
    int mem_node;
    int assigned_threads;
} mem_region_t;

typedef struct {
    int thread_id;
    int cpu_node;
    int mem_node;
    size_t chunk_size;
    uint64_t *buffer;
} thread_arg_t;

// Global Synchronization Barriers
pthread_barrier_t init_barrier;
pthread_barrier_t start_barrier;
pthread_barrier_t end_barrier;

// Global dummy variable to prevent compiler from optimizing away the reads
volatile uint64_t global_sink = 0; 

size_t parse_size(const char *str) {
    char *endptr;
    double val = strtod(str, &endptr);
    if (*endptr != '\0') {
        if (*endptr == 'k' || *endptr == 'K') val *= 1024;
        else if (*endptr == 'm' || *endptr == 'M') val *= 1024 * 1024;
        else if (*endptr == 'g' || *endptr == 'G') val *= 1024 * 1024 * 1024;
    }
    return (size_t)val;
}

// Worker Thread: Allocation, Binding, Initialization, and Reading
void *mem_worker(void *arg) {
    thread_arg_t *t = (thread_arg_t *)arg;

    // 1. Pin Thread to requested CPU NUMA node
    if (numa_run_on_node(t->cpu_node) != 0) {
        perror("numa_run_on_node failed");
        pthread_exit(NULL);
    }

    // 2. Delayed Allocation (Each thread maps its own chunk of huge pages)
    t->buffer = mmap(NULL, t->chunk_size, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | MAP_HUGE_2MB, -1, 0);
    if (t->buffer == MAP_FAILED) {
        perror("mmap failed in thread (Are enough 2MB huge pages allocated?)");
        pthread_exit(NULL);
    }

    // 3. Bind strictly to the target memory NUMA node
    unsigned long nodemask = (1UL << t->mem_node);
    if (mbind(t->buffer, t->chunk_size, MPOL_BIND, &nodemask, sizeof(nodemask)*8, MPOL_MF_STRICT) != 0) {
        perror("mbind failed in thread");
        pthread_exit(NULL);
    }

    // 4. Write into the memory to force OS to fault physical pages on the target node
    memset(t->buffer, 0, t->chunk_size);

    // ==========================================
    // SYNC POINT 1: Wait for all threads to finish allocation
    pthread_barrier_wait(&init_barrier);

    // SYNC POINT 2: Wait for main thread to snap the start time
    pthread_barrier_wait(&start_barrier);
    // ==========================================

    size_t num_elements = t->chunk_size / sizeof(uint64_t);
    uint64_t local_dummy = 0;

    // 5. The Read-Only Benchmark Loop
    for (int iter = 0; iter < NUM_ITERATIONS; iter++) {
        for (size_t i = 0; i < num_elements; i += 8) { // 64-byte stride (1 cache line)
            local_dummy += t->buffer[i]; 
        }
    }

    // Accumulate to global to avoid compiler optimizations
    __sync_fetch_and_add(&global_sink, local_dummy);

    // ==========================================
    // SYNC POINT 3: Wait for all threads to finish reading before clock stops
    pthread_barrier_wait(&end_barrier);
    // ==========================================

    // Cleanup local memory
    munmap(t->buffer, t->chunk_size);
    pthread_exit(NULL);
}

int main(int argc, char *argv[]) {
    if (numa_available() < 0) {
        fprintf(stderr, "Error: NUMA support is not available.\n");
        return -1;
    }

    size_t raw_size = 0;
    char *pattern_str = NULL;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-size") == 0 && i + 1 < argc) raw_size = parse_size(argv[++i]);
        else if (strcmp(argv[i], "-pattern") == 0 && i + 1 < argc) pattern_str = argv[++i];
    }

    if (raw_size == 0 || pattern_str == NULL) {
        fprintf(stderr, "Usage: %s -size <total_size> -pattern \"n0a0t4 n1a1t4 ...\"\n", argv[0]);
        return -1;
    }

    // Parse Patterns & Count unique regions
    pattern_t patterns[MAX_PATTERNS];
    int num_patterns = 0;
    mem_region_t regions[MAX_REGIONS];
    int num_regions = 0;
    int total_threads = 0;

    char *pattern_copy = strdup(pattern_str);
    char *token = strtok(pattern_copy, ", ");
    
    while (token != NULL && num_patterns < MAX_PATTERNS) {
        if (sscanf(token, "n%da%dt%d", &patterns[num_patterns].cpu_node, 
                   &patterns[num_patterns].mem_node, &patterns[num_patterns].num_threads) == 3) {
            
            int region_idx = -1;
            for (int r = 0; r < num_regions; r++) {
                if (regions[r].mem_node == patterns[num_patterns].mem_node) {
                    region_idx = r; break;
                }
            }
            if (region_idx == -1) {
                regions[num_regions].mem_node = patterns[num_patterns].mem_node;
                regions[num_regions].assigned_threads = 0;
                region_idx = num_regions;
                num_regions++;
            }
            regions[region_idx].assigned_threads += patterns[num_patterns].num_threads;
            total_threads += patterns[num_patterns].num_threads;
            num_patterns++;
        }
        token = strtok(NULL, ", ");
    }
    free(pattern_copy);

    // Initialize Barriers (Total threads + 1 for the main control thread)
    pthread_barrier_init(&init_barrier, NULL, total_threads + 1);
    pthread_barrier_init(&start_barrier, NULL, total_threads + 1);
    pthread_barrier_init(&end_barrier, NULL, total_threads + 1);

    // Subdivide memory size mathematically (No allocations yet)
    size_t size_per_region = raw_size / num_regions;
    
    pthread_t threads[256];
    thread_arg_t thread_args[256];
    int t_idx = 0;
    size_t actual_total_allocated = 0;

    for (int p = 0; p < num_patterns; p++) {
        int r_idx = 0;
        for (int r = 0; r < num_regions; r++) {
            if (regions[r].mem_node == patterns[p].mem_node) r_idx = r;
        }

        // Divide region size among the threads assigned to this region
        size_t raw_chunk_per_thread = size_per_region / regions[r_idx].assigned_threads;
        // MUST round up to 2MB boundary for Huge Pages
        size_t chunk_per_thread = ((raw_chunk_per_thread + HUGE_PAGE_SIZE - 1) / HUGE_PAGE_SIZE) * HUGE_PAGE_SIZE;

        for (int t = 0; t < patterns[p].num_threads; t++) {
            thread_args[t_idx].thread_id = t_idx;
            thread_args[t_idx].cpu_node = patterns[p].cpu_node;
            thread_args[t_idx].mem_node = patterns[p].mem_node;
            thread_args[t_idx].chunk_size = chunk_per_thread;
            
            actual_total_allocated += chunk_per_thread;
            pthread_create(&threads[t_idx], NULL, mem_worker, &thread_args[t_idx]);
            t_idx++;
        }
    }

    printf("Setup: Spawning %d threads across %d memory regions.\n", total_threads, num_regions);
    printf("Total memory logically partitioned: ~%zu MB.\n", actual_total_allocated / (1024*1024));

    // ==========================================
    // Phase 1: Wait for workers to map, bind, and memset their memory
    pthread_barrier_wait(&init_barrier);
    printf("-> [1/2] All threads allocated and wrote to local 2MB huge pages.\n");

    // Phase 2: Start the timer, then drop the start barrier
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    printf("-> [2/2] Timer started. Beginning dummy reads.\n");
    pthread_barrier_wait(&start_barrier);
    
    // Phase 3: Wait exactly for all read loops to finish, snap the end timer
    pthread_barrier_wait(&end_barrier);
    clock_gettime(CLOCK_MONOTONIC, &end);
    // ==========================================

    // Join threads just to cleanly close out
    for (int i = 0; i < total_threads; i++) {
        pthread_join(threads[i], NULL);
    }

    // Bandwidth Calculation
    double time_taken = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
    size_t total_bytes_read = actual_total_allocated * NUM_ITERATIONS;
    double gb_read = (double)total_bytes_read / (1024.0 * 1024.0 * 1024.0);
    double bandwidth = gb_read / time_taken;

    printf("\n============================================\n");
    printf("Total Data Read : %.2f GB\n", gb_read);
    printf("Time Taken      : %.4f seconds\n", time_taken);
    printf("Bandwidth       : %.2f GB/s\n", bandwidth);
    printf("============================================\n");

    pthread_barrier_destroy(&init_barrier);
    pthread_barrier_destroy(&start_barrier);
    pthread_barrier_destroy(&end_barrier);
    return 0;
}
