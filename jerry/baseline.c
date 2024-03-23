#include <stdio.h>
#include <stdlib.h>
#include <x86intrin.h> 
#include <stdint.h>

uint64_t rdtsc() {
    uint32_t low, high;
    asm volatile ("mfence\n\trdtsc" : "=a" (low), "=d" (high));
    return ((uint64_t)high << 32) | low;
}

int main(int argc, char** argv) 
{
    int workload = atoi(argv[1]); 

    unsigned long long a = __rdtsc();
   // for(int i=0; i < workload; i++);
    unsigned long long b = __rdtsc(); 

    printf("Cycle: %llu Workload: %d \n", b-a, workload);
}