#pragma once

#include <perfcpp/event_counter.h>
#include <iostream>
#include <fstream>
#include <mutex>
#include <vector>
#include <stdexcept>
#include <string>

namespace kmercounter {

class PerfCounterResult {
 private: 
  std::vector<std::pair<std::string, double>> _results;
 public:
  PerfCounterResult(const std::vector<std::string>& events) {
    for (const auto& event : events) {
      _results.emplace_back(event, 0);
    }
  }

  void add(const perf::CounterResult& result) {
    for (auto& [counter_name, counter_value] : _results) {
      counter_value += result.get(counter_name).value_or(0);
    }
  }

  void print(uint64_t sample_count) {
    for (auto& [counter_name, counter_value] : _results) {
      std::cout << counter_name << "\n"
                << "    per op: "<< counter_value/sample_count << "\n" 
                << "    total: " << counter_value << std::endl;
    }
  }
};

class MultithreadCounter {
 public:
  // Default constructor
  MultithreadCounter() {}

  // Delegating constructor: reads events from a file then delegates
  MultithreadCounter(size_t num_threads, const std::string& cnt_path, const std::string& def_path)
      : MultithreadCounter(num_threads, readEventsFromFile(cnt_path), def_path)
  {
    // Nothing to do here, delegation took care of initialization.
  }

  // Main constructor: uses events vector
  MultithreadCounter(size_t num_threads, const std::vector<std::string>& events, const std::string& def_path)
      : num_threads(num_threads), events(events) {    

    sample_counts.reserve(num_threads);
    results.reserve(num_threads);
    defs.reserve(num_threads);
    counters.reserve(num_threads);
    for (size_t i = 0; i < num_threads; ++i) {
      sample_counts.emplace_back(1);
      results.emplace_back(this->events);
      if (def_path.empty()) 
        defs.emplace_back();
      else
        defs.emplace_back(def_path);  
      counters.emplace_back(defs[i]);
      counters[i].add(this->events);
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
      results[thread_idx].add(counters[thread_idx].result());
    }
  }

  void set_sample_count(size_t thread_idx, uint64_t sample_count) 
  {
    if (thread_idx < num_threads) {
      sample_counts[thread_idx] = sample_count;
    }
  }

  void print() {
    std::cout << "\n------- PERFCPP ------- " << std::endl;
    for (size_t i = 0; i < num_threads; i++) {
      std::cout << "\nThread ID: " << i << " Sample counts: " << sample_counts[i] << std::endl;
      results[i].print(sample_counts[i]);
    }
    std::cout << "\n----------------------- " << std::endl;
  }

 private:
  // Helper function to read events from file
  static std::vector<std::string> readEventsFromFile(const std::string& path) {
    std::vector<std::string> events;
    if(path.empty())
      return events;

    std::ifstream file(path);
    if (!file.is_open()) {
      throw std::runtime_error("Error: Unable to open file " + path);
    }
    std::string line;
    while (std::getline(file, line)) {
      if (!line.empty()) {
        events.push_back(line);
      }
    }
    return events;
  }

  std::vector<perf::EventCounter> counters;  // Each counter needs its own definitions
  std::vector<perf::CounterDefinition> defs;
  std::vector<PerfCounterResult> results;
  std::vector<uint64_t> sample_counts;
  size_t num_threads;
  std::vector<std::string> events;
};
}  // namespace kmercounter
