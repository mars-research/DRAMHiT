#ifndef SIMPLE_HT
#define SIMPLE_HT

/**
 Hashtable with linear collision
*/
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

// Define a structure for a key-value pair
typedef struct KeyValuePair {
    uint64_t key;
    uint64_t value;
    uint8_t occupied;
} KeyValuePair;

// Define the HashTable structure
typedef struct {
    KeyValuePair* table;
    uint64_t count; // number of elements
    uint64_t size;  // max number of elements
    uint64_t collision_count;
} HashTable;

// Hash function
uint64_t hash(uint64_t x) {
    x = (x ^ (x >> 30)) * UINT64_C(0xbf58476d1ce4e5b9);
    x = (x ^ (x >> 27)) * UINT64_C(0x94d049bb133111eb);
    x = x ^ (x >> 31);
    return x;
}

// Initialize the hash table
void initHashTable(HashTable* ht, uint64_t size) {
    ht->table =  (KeyValuePair*) aligned_alloc(4096, size * sizeof(KeyValuePair));
    ht->size = size;
    ht->count = 0;
    ht->collision_count = 0;
}

void destroyHashtable(HashTable* ht)
{
    free(ht->table);
}

// Upsert operation: insert or update key-value pair
int upsert(HashTable* ht, uint64_t key, uint64_t value) {

    if(ht->count == ht->size)
        return -1;

    // collision. linear probing find next spot in the array.  
    uint64_t start_index = hash(key) % ht->size; 
    uint64_t index = start_index;
    KeyValuePair* current;  
    while(1)  
    {
        current = &ht->table[index];
        if (!current->occupied) 
        {
            current->key = key;
            current->value = value;
            current->occupied = 1;
            ht->count++; 
            return value;
        }

        if(current->key == key){
            current->value += value;
            return value;
        } 

        index = (index + 1) % ht->size;
        ht->collision_count++;
        if(index == start_index)
            return -1; 
    }
}

// Retrieve value associated with a key
int get(HashTable* ht, uint64_t key, uint64_t* value) {
    uint64_t start_index = hash(key) % ht->size; 
    uint64_t index = start_index;
    KeyValuePair* current; 
    while(1)  
    {
        current = &ht->table[index];
    
        if(current->key == key){
            *value = current->value;
            return 1;
        } 

        index = (index + 1) % ht->size;
        if(index == start_index)
            return -1; 
    }
}


#endif