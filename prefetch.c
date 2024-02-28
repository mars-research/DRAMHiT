#include <stdio.h>
#include <stdlib.h>
#include <x86intrin.h>
#include <stdint.h>
#include <time.h>


#define GARBAGE_ARRAY_SIZE (1 << 25)
uint64_t garbage_array[GARBAGE_ARRAY_SIZE] __attribute__((aligned(4096)));;

#define LARGE_ARRAY_SIZE (1 << 23) 
uint64_t large_array[LARGE_ARRAY_SIZE] __attribute__((aligned(4096)));; 

#define CACHE_ARRAY_SIZE (1 << 17)
uint64_t cache_array[CACHE_ARRAY_SIZE] __attribute__((aligned(4096)));; 

#define SMALL_ARRAY_SIZE (1 << 10)
uint64_t small_array[SMALL_ARRAY_SIZE] __attribute__((aligned(4096)));; 

uint64_t min(uint64_t a, uint64_t b) {
    return a < b ? a : b;
}

void pollute() 
{
    for (uint64_t i = 0; i < GARBAGE_ARRAY_SIZE; i++) {
        garbage_array[i] = i;
    }
}

// Function to perform software prefetching
void prefetch(const int *ptr) {
    _mm_prefetch((const char*) ptr, _MM_HINT_T0);
}

/**
Observation:
    access close to each other is better. ( locality )
*/
void test1() 
{
    unsigned long long start_cycle; 
    unsigned long long end_cycle; 
    unsigned long long sum = 0;
    for (int i = 0; i < LARGE_ARRAY_SIZE; i++) {
        large_array[i] = 1;
    }

    printf("#stride    cycle   sum     \n"); 

    for(int stride = 1; stride < 10; stride += 1)
    {
        pollute(); 
        start_cycle = __rdtsc();
        sum = 0;
        for (int i = 0; i < LARGE_ARRAY_SIZE; i+=stride) {
            sum += large_array[i];
        }
        end_cycle = __rdtsc();
        printf("%d %llu    %llu    \n", stride, end_cycle - start_cycle, sum); 
    }
}

void sequential_access(uint64_t num_access, uint64_t* arr, uint64_t arr_len)
{
    unsigned long long start_cycle; 
    unsigned long long end_cycle; 
    unsigned long long cycles; 

    unsigned long long sum = 0;
    for (int i = 0; i < arr_len; i++) {
        arr[i] = 1;
    }
    pollute(); 

    start_cycle = __rdtsc();
    sum = 0;
    for (int i = 0; i < num_access; i++) {
        sum += arr[i%arr_len];
    }
    end_cycle = __rdtsc();

    cycles = end_cycle - start_cycle;

    printf("sequential - num_access: %lu, cycles: %llu, access: %llu, cpa: %lu \n", num_access, cycles, sum, (uint64_t) (cycles/sum)); 
}

void random_access(uint64_t num_access, uint64_t* arr, uint64_t arr_len)
{
    srand(time(NULL));
    unsigned long long start_cycle; 
    unsigned long long end_cycle; 
    unsigned long long cycles; 

    unsigned long long sum = 0;
    uint64_t modulo = min(num_access, arr_len);

    for (int i = 0; i < arr_len; i++) {
        arr[i] = 1;
    }

    pollute(); 
    start_cycle = __rdtsc();
    sum = 0;
    for (int i = 0; i < num_access; i++) {
        sum += arr[(rand() % modulo)];
    }
    end_cycle = __rdtsc();

    cycles = end_cycle - start_cycle;
    printf("random - num_access: %lu, cycles: %llu, sum: %llu, cpa: %lu \n", num_access, cycles, sum, (uint64_t) (cycles / sum)); 
}

// read test.
/**

Observation: 

    sequential access performance is NOT dependent array size, ~30 cycles if locality is perserved. 
    random access performance is dependent on if array size can fit in cache.  
*/
void test2() 
{
    uint64_t num_access = (1 << 25);
    printf("large\n");
    sequential_access(num_access, large_array, LARGE_ARRAY_SIZE);
    random_access(num_access, large_array, LARGE_ARRAY_SIZE);

    printf("cache\n");
    sequential_access(num_access, cache_array, CACHE_ARRAY_SIZE);
    random_access(num_access, cache_array, CACHE_ARRAY_SIZE);

    printf("small\n");
    sequential_access(num_access, small_array, SMALL_ARRAY_SIZE);
    random_access(num_access, small_array, SMALL_ARRAY_SIZE);
}

void random_write(uint64_t num_write, uint64_t* arr, uint64_t arr_len)
{
    srand(time(NULL));
    unsigned long long start_cycle; 
    unsigned long long end_cycle; 
    unsigned long long cycles; 

    unsigned long long sum = 0;
    uint64_t modulo = min(num_write, arr_len);

    for (int i = 0; i < arr_len; i++) {
        arr[i] = 0;
    }

    pollute(); 
    start_cycle = __rdtsc();
    for (int i = 0; i < num_write; i++) {
        arr[(rand() % modulo)] = 1;
        sum++;
    }
    end_cycle = __rdtsc();

    cycles = end_cycle - start_cycle;
    printf("random - num_write: %lu, cycles: %llu, write: %llu, cpw: %lu \n", num_write, cycles, sum, (uint64_t) (cycles / sum)); 
}

/**
 RandomAccess: Performance drops around l2 size 32 mb, (1 << 25) L2 cache size. 
 Random Read/Write: Min: ~90 cycles per write (Per Core)  if array size is less than 
*/
void test3() 
{
    uint64_t num_access = (1 << 25);
    uint64_t size;
    for(uint64_t shift = 15; shift < 31; shift++)
    {
        size = 1 << shift; 
        printf("size: %lu shift: %lu\n", size, shift);
        uint64_t* arr = (uint64_t*) aligned_alloc(4096, sizeof(uint64_t) * size);
        random_access(num_access, arr, size);
        free(arr); 
    }
}

typedef struct {
    unsigned long long cycles;  
    unsigned long long op_count; 
    unsigned long long inner_total_cycle; 

    uint64_t cpo;
} stats_t; 

void seq_read_random_write(uint64_t* src, uint64_t src_len, uint64_t* dst, uint64_t dst_len, stats_t* stat)
{
    srand(time(NULL));
    unsigned long long start_cycle; 
    unsigned long long end_cycle; 
    unsigned long long cycles; 

    unsigned long long op_count = 0;
    for (int i = 0; i < src_len; i++) {
        src[i] = 1;
    }
    
    pollute(); 
    start_cycle = __rdtsc();
    for (int i = 0; i < src_len; i++) {
        dst[(rand() % dst_len)] = src[i]; 
        op_count++;
    }
    end_cycle = __rdtsc();

    cycles = end_cycle - start_cycle;
     
    stat->cycles += cycles; 
    stat->op_count += op_count;
    stat->cpo +=  (uint64_t) (cycles / op_count); 
    // printf("r/w - cycles: %llu, write: %llu, cpo: %lu \n", cycles, op_count, (uint64_t) (cycles / op_count)); 
}

/**
size: 16, shift: 4, cpo: 173 
size: 32, shift: 5, cpo: 140 
size: 64, shift: 6, cpo: 119 
size: 128, shift: 7, cpo: 108 
size: 256, shift: 8, cpo: 104 
size: 512, shift: 9, cpo: 121 
size: 1024, shift: 10, cpo: 113 
size: 2048, shift: 11, cpo: 113 
size: 4096, shift: 12, cpo: 100 
size: 8192, shift: 13, cpo: 110 
size: 16384, shift: 14, cpo: 108 
size: 32768, shift: 15, cpo: 108 
size: 65536, shift: 16, cpo: 108 
size: 131072, shift: 17, cpo: 109 
size: 262144, shift: 18, cpo: 112 
size: 524288, shift: 19, cpo: 107 
size: 1048576, shift: 20, cpo: 108 
size: 2097152, shift: 21, cpo: 122 
size: 4194304, shift: 22, cpo: 161 
size: 8388608, shift: 23, cpo: 194 
size: 16777216, shift: 24, cpo: 208 

*/
void test4() 
{
    uint64_t num_access = (1 << 25);
    uint64_t size;
    uint64_t times = 10;
    stats_t stat;

    for(uint64_t shift = 4; shift < 25; shift++)
    {
        stat.cycles = 0;
        stat.op_count = 0;
        stat.cpo = 0;
        size = 1 << shift; 
        for(int i = 0; i < times; i++)
        {
            uint64_t* src = (uint64_t*) aligned_alloc(4096, sizeof(uint64_t) * size);
            uint64_t* dst = (uint64_t*) aligned_alloc(4096, sizeof(uint64_t) * size);
            seq_read_random_write(src, size, dst, size, &stat);
            free(src); 
            free(dst);
        }
        printf("size: %lu, shift: %lu, cpo: %lu \n",  size, shift, (uint64_t) (stat.cycles / stat.op_count));
    }
}

void group_seq_read_random_write(uint64_t** srcs, uint64_t** dsts, uint64_t len, uint64_t len_len, stats_t* stat)
{
    srand(time(NULL));
    unsigned long long start_cycle; 
    unsigned long long end_cycle;

    unsigned long long inner_total_cycle = 0;
    unsigned long long inner_start_cycle; 
    unsigned long long inner_end_cycle;

    unsigned long long cycles; 
    unsigned long long op_count = 0;

    pollute(); 
    start_cycle = __rdtsc();

    for(int i=0; i<len; i++)
    {
        uint64_t* src = srcs[i];
        uint64_t* dst = dsts[i];

        inner_start_cycle = __rdtsc();
        for (int j = 0; j < len_len; j++) {
            dst[(rand() % len_len)] = src[j]; 
            op_count++;
        }
        inner_end_cycle = __rdtsc();

        inner_total_cycle += inner_end_cycle - inner_start_cycle;
    }
    
    end_cycle = __rdtsc();

    cycles = end_cycle - start_cycle;
    stat->cycles = cycles; 
    stat->op_count = op_count;
    stat->cpo =  (uint64_t) (cycles / op_count); 
    stat->inner_total_cycle = inner_total_cycle;
}

/**
*
* Simulation of practice, cpo is ~ 120 
*/
void test5() 
{
    uint64_t times = 3;
    uint64_t num = (1 << 10); // 1GB 
    uint64_t size = (1 << 20); // 1MB

    for(int time = 0; time < times; time++)
    {
        stats_t stat;
        uint64_t** srcs = (uint64_t**) aligned_alloc(4096, sizeof(uint64_t*) * num);
        uint64_t** dsts = (uint64_t**) aligned_alloc(4096, sizeof(uint64_t*) * num);
        for(int i=0; i<num; i++)
        {
            srcs[i] = (uint64_t*) aligned_alloc(4096, sizeof(uint64_t) * size);
            dsts[i] = (uint64_t*) aligned_alloc(4096, sizeof(uint64_t) * size);
            for(int j=0; j<size; j++) 
                srcs[i][j] = 1;
        }

        group_seq_read_random_write(srcs, dsts, num, size, &stat);
        printf("cpo: %lu inner cpo: %lu \n", (uint64_t) (stat.cycles / stat.op_count), (uint64_t) (stat.inner_total_cycle / stat.op_count));

        for(int i=0; i<num; i++)
        {
            free(srcs[i]);
            free(dsts[i]); 
        }
        free(srcs); 
        free(dsts);
    }
}

/**
*  
* From above, we observe  
* seq Read + random Write 
* 25       + 95          = 120 cycles per operation. 
*
* For 64 cores machine:
* 120 / 64 = 2 cycles per insertion
* 
* Each core is 2.6Ghz:
* 2.6 * 10^9 / 2 / 2^6 = 1300 mops 
* 
* Thus in theory: we can get up to 1300 mops 
* 
*
*/

int main() {
    
    test5();
    return 0;
}