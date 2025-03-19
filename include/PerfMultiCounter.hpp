#pragma once

#include <perfcpp/event_counter.h>

#include <iostream>
#include <mutex>
#include <vector>

namespace kmercounter {
class MultithreadCounter {
 public:
  MultithreadCounter() {
    MultithreadCounter(1);
  }

  MultithreadCounter(size_t num_threads)
      : num_threads(num_threads),
        def()
  {
    counters.reserve(num_threads);
    for (size_t i = 0; i < num_threads; ++i) {
      counters.emplace_back(def);
    }
  }

  void start(size_t thread_idx) {
    if (thread_idx < num_threads) {
      counters[thread_idx].start();
    }
  }

  void stop(size_t thread_idx) {
    if (thread_idx < num_threads) {
      counters[thread_idx].stop();
    }
  }

  void add(const std::vector<std::string>& events) {
    for (size_t i = 0; i < num_threads; i++) {
      counters[i].add(events);
    }
  }

  void show() {
    for (int i = 0; i < num_threads; i++) {
      auto result = counters[i].result();
      std::cout << "\n TID: " << i << " PERFCPP Results:" << std::endl;
      for (const auto& [counter_name, counter_value] : result) {
        std::cout << counter_value << " " << counter_name << std::endl;
      }
    }
  }

 private:
  std::vector<perf::EventCounter> counters;
  perf::CounterDefinition def;
  size_t num_threads;
};
}  // namespace kmercounter