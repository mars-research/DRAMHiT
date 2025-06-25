#pragma once

#include <perfcpp/event_counter.h>

#include <cstring>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>
#include <sstream>


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

  void clear() {
    for (auto& [counter_name, counter_value] : _results) {
      counter_value = 0;
    }
  }

  uint64_t get_value(std::string x) 
  {
    for (auto& [counter_name, counter_value] : _results) {
      if (counter_name == x) {
        return counter_value;
      } 
    } 

    return 0; 
  }

  bool contain(std::string x){
    for (auto& [counter_name, counter_value] : _results) {
      if (counter_name == x) {
        return true;
      } 
    } 
    return false;
  }



  void print(uint64_t sample_count) {
    std::cout << get_result_str(sample_count); 
  }

  std::string get_result_str(uint64_t sample_count)
  { 
    std::ostringstream s;
    for (auto& [counter_name, counter_value] : _results) {
      s << counter_name << ":" << counter_value / sample_count << ":" << counter_value << "\n";
    }
    return s.str();
  }
};

class MultithreadCounter {
 public:
  // Default constructor
  MultithreadCounter() {}

  // Delegating constructor: reads events from a file then delegates
  MultithreadCounter(size_t num_threads, const std::string& cnt_path,
                     const std::string& def_path)
      : MultithreadCounter(num_threads, readEventsFromFile(cnt_path),
                           def_path) {
    // Nothing to do here, delegation took care of initialization.
  }

  // Main constructor: uses events vector
  MultithreadCounter(size_t num_threads, const std::vector<std::string>& events,
                     const std::string& def_path)
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
      counters[i].add(
          this->events,
          perf::EventCounter::Schedule::Separate);  // Disable multiplexing
      // counters[i].add(this->events); //Enable multiplexing (it's default)
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

  void clear(size_t thread_idx) {
    if (thread_idx < num_threads) {
      results[thread_idx].clear();
    }
  }

  void clear_all() {
    for (int thread_idx = 0; thread_idx < num_threads; thread_idx++) {
      results[thread_idx].clear();
    }
  }

  void set_sample_count(size_t thread_idx, uint64_t sample_count) {
    if (thread_idx < num_threads) {
      sample_counts[thread_idx] = sample_count;
    }
  }


  // save all counter results into a file 
  void save(std::string path) 
  { 

    std::ostringstream s;
    for (size_t i = 0; i < num_threads; i++) {
      s << "\nThread ID: " << i << " Sample counts: " << sample_counts[i] << std::endl;
      s << results[i].get_result_str(sample_counts[i]);
    }

    std::ofstream out(path);  // open the file for writing
    if (!out) {
        throw std::runtime_error("Failed to open file: " + path);
    }
    out << s.str();
  }

  void print() {
    std::cout << "\n------- PERFCPP ------- " << std::endl;
    std::cout << "\n data format: <EVT_NAME> <PER OP> <TOTAL> " << std::endl;

    double totol_rbw = 0;  
    double totol_bw = 0;    
  

    for (size_t i = 0; i < num_threads; i++) {
      std::cout << "\nThread ID: " << i
                << " Sample counts: " << sample_counts[i] << std::endl;
      results[i].print(sample_counts[i]);
      double bw = 0;
      if(results[i].contain("cycles") && results[i].contain("OFFCORE_REQUESTS.DATA_RD"))
      {
        bw = (results[i].get_value("OFFCORE_REQUESTS.DATA_RD") * 64 / GB_IN_BYTES) / (results[i].get_value("cycles")  / CYCLES_PER_SEC);
        std::cout << "read bw: " << bw << "GB/s \n";
        totol_rbw += bw;
      } 

      if(results[i].contain("cycles") && results[i].contain("OFFCORE_REQUESTS.ALL_REQUESTS"))
      {
        bw = (results[i].get_value("OFFCORE_REQUESTS.ALL_REQUESTS") * 64 / GB_IN_BYTES) / (results[i].get_value("cycles")  / CYCLES_PER_SEC);
        std::cout << "total bw: " << bw << "GB/s \n";
        totol_bw += bw;
      }
    }

    // average system 
    std::cout << "\nSystem stats summary: <evt> <sum/thread> <sum>\n";  

    uint64_t sc_average = 0;
    for(auto& sc: sample_counts)
    {
      sc_average += sc;
    }

    std::cout << "samples:" << sc_average / num_threads << ":" << sc_average << std::endl;
    sc_average = sc_average / num_threads;

    for (auto& evt : events) {
      uint64_t sum = 0;
      for (size_t i = 0; i < num_threads; i++) {
        sum += results[i].get_value(evt);
      }
      std::cout << evt << ":" << sum/num_threads << ":" << sum << std::endl;
    }

    if(totol_rbw > 0.1)
      std::cout << "total rbw: " << totol_rbw << "GB/s \n";

    if(totol_bw > 0.1)
      std::cout << "total bw: " << totol_bw << "GB/s \n";
    std::cout << "----------------------- " << std::endl;
  }

 private:
  // Helper function to read events from file
  static std::vector<std::string> readEventsFromFile(const std::string& path) {
    std::vector<std::string> events;
    if (path.empty()) return events;

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

  static constexpr double CYCLES_PER_SEC = (2.5 * 1000 * 1000 * 1000);
  static constexpr double GB_IN_BYTES = (1 << 30);

  std::vector<perf::EventCounter>
      counters;  // Each counter needs its own definitions
  std::vector<perf::CounterDefinition> defs;
  std::vector<PerfCounterResult> results;
  std::vector<uint64_t> sample_counts;
  size_t num_threads;
  std::vector<std::string> events;
};
}  // namespace kmercounter
