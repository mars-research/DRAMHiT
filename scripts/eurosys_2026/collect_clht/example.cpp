#include <iostream>
#include <thread>
#include <vector>

// Pick one variant by switching the include line:
//
// Lock-based, resizable:
//   #include "clht_lb_res.h"
// Lock-based, no resize:
//   #include "clht_lb.h"
// Lock-free, resizable:
//   #include "clht_lf_res.h"
// Lock-free, no resize (can infinite loop when full ):
//   #include "clht_lf.h"

extern "C" {
// #include "clht_lf.h"   // <--- change here for other variants
#include "clht_lf_res.h"
}

clht_t* hashtable;

void worker(long tid) {
    // Each thread must call this before using the table
    clht_gc_thread_init(hashtable, tid);

    // Insert 5 key/value pairs
    for (int i = 0; i < 5; i++) {
        long key = tid * 100 + i;
        long val = key * 10 +1; // +1 cuz it shoudln't be 0 cuz 0 is error I think
        clht_put(hashtable, key, val);
        std::cout << "Thread " << tid
                  << " inserted key=" << key
                  << " val=" << val << "\n";
    }

    // Verify lookups
    for (int i = 0; i < 5; i++) {
        long key = tid * 100 + i;
        long val = clht_get(hashtable->ht, key);

        if(!val){
            abort();
        }
        else{
        std::cout << "Thread " << tid
                  << " found key=" << key
                  << " val=" << val << "\n";
        }
    }
}

int main() {

    int num_threads = 2;
    // Create table with 16 buckets
    hashtable = clht_create(100);
          printf("%s\n", clht_type_desc());
        fflush(stdout);

    // Launch 2 threads
    std::vector<std::thread> threads;
    for (long t = 0; t < num_threads; t++) {
        threads.emplace_back(worker, t);
    }
    for (auto& th : threads) {
        th.join();
    }

    // Print final contents
    // std::cout << "\nFinal table:\n";
    // clht_print(hashtable->ht);

    // Cleanup
    // clht_gc_destroy(hashtable);
    return 0;
}


//CUSTOME ALLOCATOR? for clht_If.c
/* 

printf("Custom allocator enabled.\n");
fflush(stdout);
size_t page_size = 1ULL << 30; // 1GB huge pages
size_t alloc_size = ((num_buckets * sizeof(bucket_t) + page_size - 1) / page_size) * page_size;
hashtable->table = (bucket_t*) mmap(NULL, alloc_size,
                                    PROT_READ | PROT_WRITE,
                                    MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | (30 << MAP_HUGE_SHIFT),
                                    -1, 0);
*/
