

#include <string.h>

#define BUFFERSIZE 512
#define CACHELINESIZE 512

typedef struct 
{
    char data[CACHELINESIZE];  
} cacheline_t; 

typedef struct 
{
    uint buffer_sz;
    uint mem_sz;
    char* buffer;
    cacheline_t* mempool;
} partition_t;

void partition_init(partition_t* p)
{

} 

void partition_free(partition_t* p)
{

}

void insert_one(partition_t* p, char* e, uint sz)
{  
    // insert one     
    if()
}


void partitioning(uint* kmers, partition_t* parts, uint num_parts) 
{

}