#include <functional>
#include <mutex>
#include <numeric>
#include <thread>
#include <vector>

#include "LockTest.hpp"
#include "sync.h"

namespace kmercounter {

namespace {

// Credit: https://rigtorp.se/spinlock/
struct spinlock {
  std::atomic<bool> lock_ = {0};

  void lock() noexcept {
    for (;;) {
      // Optimistically assume the lock is free on the first try
      if (!lock_.exchange(true, std::memory_order_acquire)) {
        return;
      }
      // Wait for lock to be released without generating cache misses
      while (lock_.load(std::memory_order_relaxed)) {
        // Issue X86 PAUSE or ARM YIELD instruction to reduce contention between
        // hyper-threads
        __builtin_ia32_pause();
      }
    }
  }

  void unlock() noexcept { lock_.store(false, std::memory_order_release); }
};

struct CAS_counter {
  uint64_t count;

  CAS_counter& operator++() {
    auto old = count;
    while (!__sync_bool_compare_and_swap(&count, old, old + 1)) {
      old = count;
    }
    return *this;
  }

  void increment() {
    auto old = count;
    while (!__sync_bool_compare_and_swap(&count, old, old + 1)) {
      old = count;
    }
  }
};

// a counter that is padded such that every instance is in
// a different cacheline
struct Cacheline_aligned_counter {
  uint64_t count;
  char padding[CACHE_LINE_SIZE - sizeof(count)];
};

// spinlock
// global counter, and associated spinlock
volatile std::size_t spinlock_counter{0};
spinlock slock;

void spinlock_increment(std::size_t id, std::atomic<std::size_t>& cycles) {
  uint64_t t_start = RDTSC_START();
  for (uint64_t i = 0; i < NUM_INCREMENTS; i++) {
    slock.lock();
    (void)spinlock_counter++;
    slock.unlock();
  }
  uint64_t t_end = RDTSCP();

  printf("[INFO]: thread: %zu cycles: %zu\n", id, t_end - t_start);
  cycles += (t_end - t_start);
}

// atomic increment
// global counter
volatile std::atomic<std::size_t> atomic_counter{0};

void atomic_increment(std::size_t id, std::atomic<std::size_t>& cycles) {
  uint64_t t_start = RDTSC_START();
  for (uint64_t i = 0; i < NUM_INCREMENTS; i++) {
    (void)++atomic_counter;
  }
  uint64_t t_end = RDTSCP();

  printf("[INFO]: thread: %zu cycles: %zu\n", id, t_end - t_start);
  cycles += (t_end - t_start);
}

// cas increment
// global counter
CAS_counter cas_counter{};

void cas_increment(std::size_t id, std::atomic<std::size_t>& cycles) {
  uint64_t t_start = RDTSC_START();
  for (uint64_t i = 0; i < NUM_INCREMENTS; i++) {
    cas_counter.increment();
  }
  uint64_t t_end = RDTSCP();

  printf("[INFO]: thread: %zu cycles: %zu\n", id, t_end - t_start);
  cycles += (t_end - t_start);
}

// uncontended lock
void uncontended_lock_increment(std::size_t id,
                                std::atomic<std::size_t>& cycles) {
  // counter is volatile to avoid optimizations that prevent
  // us from accurately measuring cycles per increment
  volatile auto counter = Cacheline_aligned_counter{};
  std::mutex m;

  uint64_t t_start = RDTSC_START();
  for (uint64_t i = 0; i < NUM_INCREMENTS; i++) {
    std::scoped_lock lock(m);
    counter.count++;
  }
  uint64_t t_end = RDTSCP();

  printf("[INFO]: thread: %zu cycles: %zu\n", id, t_end - t_start);
  cycles += (t_end - t_start);
}

// uncontended increment
void uncontended_increment(std::size_t id, std::atomic<std::size_t>& cycles) {
  // counter is volatile to avoid optimizations that prevent
  // us from accurately measuring cycles per increment
  volatile auto counter = Cacheline_aligned_counter{};

  uint64_t t_start = RDTSC_START();
  for (uint64_t i = 0; i < NUM_INCREMENTS; i++) {
    counter.count++;
  }
  uint64_t t_end = RDTSCP();

  printf("[INFO]: thread: %zu cycles: %zu\n", id, t_end - t_start);
  cycles += (t_end - t_start);
}

constexpr auto TEST_REPS = 5;

}  // unnamed namespace

void LockTest::spinlock_increment_test_run(Configuration const& cfg) {
  printf("[INFO] Spinlock increment test run: threads %u, insertions:%lu\n",
         cfg.num_threads, NUM_INCREMENTS);
  auto avgs = std::vector<double>{};
  for (auto i = 0; i < TEST_REPS; i++) {
    auto cycles = std::atomic<std::size_t>{0};
    auto threads = std::vector<std::thread>{};

    // start threads
    for (std::size_t i = 0; i < cfg.num_threads; i++) {
      threads.emplace_back(spinlock_increment, i, std::ref(cycles));
    }

    // wait for them to finish executing
    for (auto& thread : threads) {
      thread.join();
    }

    // each thread increments cycles by the number of cycles it took
    // for all increment operations; compute average
    auto avg = static_cast<double>(cycles) / (NUM_INCREMENTS * cfg.num_threads);

    printf("[INFO] Quick stats: cycles per increment: %f\n", avg);
    avgs.push_back(avg);
  }
  double total = std::accumulate(avgs.begin(), avgs.end(), 0.0);
  printf("[INFO] Final stats: average cycles per increment: %f\n", total / TEST_REPS);
}

void LockTest::atomic_increment_test_run(Configuration const& cfg) {
  printf("[INFO] Atomic increment test run: threads %u, insertions:%lu\n",
         cfg.num_threads, NUM_INCREMENTS);
  auto avgs = std::vector<double>{};
  for (auto i = 0; i < TEST_REPS; i++) {
    auto cycles = std::atomic<std::size_t>{0};
    auto threads = std::vector<std::thread>{};

    // start threads
    for (std::size_t i = 0; i < cfg.num_threads; i++) {
      threads.emplace_back(atomic_increment, i, std::ref(cycles));
    }

    // wait for them to finish executing
    for (auto& thread : threads) {
      thread.join();
    }

    // each thread increments cycles by the number of cycles it took
    // for all increment operations; compute average
    auto avg = static_cast<double>(cycles) / (NUM_INCREMENTS * cfg.num_threads);

    printf("[INFO] Quick stats: cycles per increment: %f\n", avg);
    avgs.push_back(avg);
  }
  double total = std::accumulate(avgs.begin(), avgs.end(), 0.0);
  printf("[INFO] Final stats: average cycles per increment: %f\n", total / TEST_REPS);
}

void LockTest::cas_increment_test_run(Configuration const& cfg) {
  printf("[INFO] CAS increment test run: threads %u, insertions:%lu\n",
         cfg.num_threads, NUM_INCREMENTS);
  auto avgs = std::vector<double>{};
  for (auto i = 0; i < TEST_REPS; i++) {
    auto cycles = std::atomic<std::size_t>{0};
    auto threads = std::vector<std::thread>{};

    // start threads
    for (std::size_t i = 0; i < cfg.num_threads; i++) {
      threads.emplace_back(cas_increment, i, std::ref(cycles));
    }

    // wait for them to finish executing
    for (auto& thread : threads) {
      thread.join();
    }

    // each thread increments cycles by the number of cycles it took
    // for all increment operations; compute average
    auto avg = static_cast<double>(cycles) / (NUM_INCREMENTS * cfg.num_threads);

    printf("[INFO] Quick stats: cycles per increment: %f\n", avg);
    avgs.push_back(avg);
  }
  double total = std::accumulate(avgs.begin(), avgs.end(), 0.0);
  printf("[INFO] Final stats: average cycles per increment: %f\n", total / TEST_REPS);
}

void LockTest::uncontended_lock_test_run(Configuration const& cfg) {
  printf("[INFO] Uncontended lock test run: threads %u, insertions:%lu\n",
         cfg.num_threads, NUM_INCREMENTS);
  auto avgs = std::vector<double>{};
  for (auto i = 0; i < TEST_REPS; i++) {
    auto cycles = std::atomic<std::size_t>{0};
    auto threads = std::vector<std::thread>{};

    // start threads
    for (std::size_t i = 0; i < cfg.num_threads; i++) {
      threads.emplace_back(uncontended_lock_increment, i, std::ref(cycles));
    }

    // wait for them to finish executing
    for (auto& thread : threads) {
      thread.join();
    }

    // each thread increments cycles by the number of cycles it took
    // for all increment operations; compute average
    auto avg = static_cast<double>(cycles) / (NUM_INCREMENTS * cfg.num_threads);

    printf("[INFO] Quick stats: cycles per increment: %f\n", avg);
    avgs.push_back(avg);
  }
  double total = std::accumulate(avgs.begin(), avgs.end(), 0.0);
  printf("[INFO] Final stats: average cycles per increment: %f\n", total / TEST_REPS);
}

void LockTest::uncontended_increment_test_run(Configuration const& cfg) {
  printf("[INFO] Uncontended increment test run: threads %u, insertions:%lu\n",
         cfg.num_threads, NUM_INCREMENTS);
  auto avgs = std::vector<double>{};
  for (auto i = 0; i < TEST_REPS; i++) {
    auto cycles = std::atomic<std::size_t>{0};
    auto threads = std::vector<std::thread>{};

    // start threads
    for (std::size_t i = 0; i < cfg.num_threads; i++) {
      threads.emplace_back(uncontended_increment, i, std::ref(cycles));
    }

    // wait for them to finish executing
    for (auto& thread : threads) {
      thread.join();
    }

    // each thread increments cycles by the number of cycles it took
    // for all increment operations; compute average
    auto avg = static_cast<double>(cycles) / (NUM_INCREMENTS * cfg.num_threads);

    printf("[INFO] Quick stats: cycles per increment: %f\n", avg);
    avgs.push_back(avg);
  }
  double total = std::accumulate(avgs.begin(), avgs.end(), 0.0);
  printf("[INFO] Final stats: average cycles per increment: %f\n", total / TEST_REPS);
}

}  // namespace kmercounter
