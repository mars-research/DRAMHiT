// Your First C++ Program

#include <barrier>
#include <iostream>
#include <x86gprintrin.h>
#include <bitset>
#include <climits>
#include <cstring>
#include <fcntl.h>
#include <thread>
#include <vector>
#include <unistd.h>
#include <sys/mman.h>
#include <functional>
#include <numa.h> 

#include <pthread.h>
#define PAGE_SIZE 4096
#define FILE_NAME "/mnt/huge/hugepagefile%d"

#define MAP_HUGE_2MB    (21 << MAP_HUGE_SHIFT)
#define MAP_HUGE_1GB    (30 << MAP_HUGE_SHIFT)

constexpr auto ADDR = static_cast<void *>(0x0ULL);
constexpr auto PROT_RW = PROT_READ | PROT_WRITE;
constexpr auto MAP_FLAGS =
    MAP_HUGETLB | MAP_HUGE_1GB | MAP_PRIVATE | MAP_ANONYMOUS;
constexpr auto ONEGB_PAGE_SZ = 1ULL * 1024 * 1024 * 1024;

using VoidFn = std::function<void()>;

void bar() {

    auto first = std::aligned_alloc(PAGE_SIZE, 1 << 30);
    auto start = _rdtsc();
    // auto addr = std::aligned_alloc(PAGE_SIZE, 1 << 30);


    int fd;
    char mmap_path[256] = {0};
    snprintf(mmap_path, sizeof(mmap_path), FILE_NAME, 1);
    fd = open(mmap_path, O_CREAT | O_RDWR, 0755);
    if (fd < 0) {
      exit(1);
    }
    auto addr = mmap(ADDR, /* 256*1024*1024*/ 1 << 30, PROT_RW,
        MAP_FLAGS, fd, 0);
    
    auto end = _rdtsc() - start;
    std::memset(addr, 0, 1 << 30);
    printf("Cycles: %llu addr: %llu, first: %llu\n", end, (unsigned long long) addr, (unsigned long long)first);
}

void sync_complete(void) {
}

int main() {

    // std::vector<numa_node_t> nodes = Numa::get_node_config();
    // std::barrier barrier(64, sync_complete);
    cpu_set_t cpuset;
    std::vector<std::thread> threads;
    for (int i = 0; i < 64; i++) {
        // bar();
      CPU_ZERO(&cpuset);
      auto t = std::thread(bar);
      pthread_setaffinity_np(t.native_handle(), sizeof(cpu_set_t), &cpuset);
      threads.push_back(std::move(t));
    }
    for (auto& t : threads) {
     t.join();
    }
    return 0; 
}

