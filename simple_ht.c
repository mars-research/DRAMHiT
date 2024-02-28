
// Main function for testing

#include "simple_ht.h"
#include <x86intrin.h>


void perf_ht_test_insertion(uint64_t size, uint64_t insertion_count, uint64_t times)
{
    HashTable ht;

    initHashTable(&ht, size);
    unsigned long long start_cycle;  
    unsigned long long end_cycle; 
    unsigned long long total_cycle = 0;  


    start_cycle = __rdtsc();
    // Upsert some key-value pairs
    for(int time = 0; time < times; time++)
    {
        for(int i=0; i< insertion_count; i++)
        {
            if(upsert(&ht, i, 1) < 0){
                printf("upsert failed @ index %d\n", i); 
                break; 
            }
        }
    }
    end_cycle = __rdtsc();
    total_cycle = end_cycle - start_cycle; 


    printf("Insertion: %lu Size: %lu\n", insertion_count, size);
    printf(">>>> cycle: %llu cpi: %lu collison count: %lu\n", total_cycle, (uint64_t) total_cycle / (insertion_count * times), ht.collision_count / times);

    uint64_t value = 0;
    for(int i=0; i< insertion_count; i++)
    {
        if(get(&ht, i, &value) < 0) 
        {
            printf("get failed @ index %d\n", i); 
        }

        if(value != 1 * times) 
        {
            printf("error at index %d value %lu\n", i, value); 
            break;
        }
    }
    
    if(insertion_count != ht.count)
        printf("error insertion count: %lu and ht->count: %lu doesn't match\n", insertion_count, ht.count);

    destroyHashtable(&ht); 
}

int main() {
    /**
     ht size 1 << 20 
     insertion count 1 << 18 is about 100 cycles per insertions. 
    */
    uint64_t size;
    uint64_t insertion_count;

    // size = 1 << 24;
    // for(int shift = 19; shift < 24; shift++)
    // {
    //      insertion_count = 1 << shift;
    //      perf_ht_test_insertion(size, insertion_count, 5);
    // }


    insertion_count = 1 << 18;
    for(int shift = 19; shift < 24; shift++)
    {
         size = 1 << shift;
         perf_ht_test_insertion(size, insertion_count, 5);
    }

    return 0;
}