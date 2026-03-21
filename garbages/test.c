#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sched.h>
#include <time.h>
#include <stdint.h>

#define BUFFER_SIZE 1024 * 2  // 2kb shared buffer
#define NUM_ITERATIONS 1000000   // Number of reads per thread

char shared_buffer[BUFFER_SIZE]; // Shared memory buffer

void *thread_func(void *arg) {
    int thread_id = *(int *)arg;
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(0, &cpuset);  // Bind to core 0
    pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);

    struct timespec start, end;
    volatile char dummy;

    clock_gettime(CLOCK_MONOTONIC, &start);
    for (size_t i = 0; i < NUM_ITERATIONS; i++) {
        dummy = shared_buffer[i % BUFFER_SIZE];
    }
    clock_gettime(CLOCK_MONOTONIC, &end);

    double time_taken = (end.tv_sec - start.tv_sec) + 
                        (end.tv_nsec - start.tv_nsec) / 1e9;
    printf("Thread %d: Time taken = %.6f seconds\n", thread_id, time_taken);
    return NULL;
}

int main() {
    pthread_t thread1, thread2;
    int id1 = 1, id2 = 2;
    
    // Initialize shared buffer with dummy data
    for (size_t i = 0; i < BUFFER_SIZE; i++) {
        shared_buffer[i] = (char)(i % 256);
    }

    pthread_create(&thread1, NULL, thread_func, &id1);
    pthread_create(&thread2, NULL, thread_func, &id2);
    
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
    
    return 0;
}
