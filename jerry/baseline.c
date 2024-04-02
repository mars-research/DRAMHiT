#include <stdio.h>
#include <stdlib.h>
#include <x86intrin.h> 
#include <stdint.h>
#include <time.h>

#define LEN 1024
uint arr[LEN];
uint idx[LEN];

int main(int argc, char** argv) 
{
    srand(time(NULL));
    int workload = atoi(argv[1]); 
    for(int i=0; i < LEN; i++) 
        idx[i] = rand() % LEN;  

    unsigned long long a = __rdtsc();
    uint c;
    for(int i=0; i < workload; i++)
    {
        c = idx[i&(LEN-1)];
        arr[c] = c;
    } 
    unsigned long long b = __rdtsc(); 

    unsigned long long cycle = b - a;
    printf("Cycle: %llu Workload: %d CPO: %lld\n", cycle, workload, cycle / workload);
}