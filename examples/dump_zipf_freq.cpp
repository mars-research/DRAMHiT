// Dump the frequencies of zipfians generated from multiple threads
// in binary array format.

#include <absl/flags/flag.h>
#include <absl/container/flat_hash_map.h>
#include <absl/flags/parse.h>

#include <future>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <random>
#include <string>
#include <string_view>
#include <thread>
#include <vector>

#include "fastrange.h"
#include "hasher.hpp"
#include "input_reader/zipfian.hpp"

ABSL_FLAG(std::string, output_file, "", "Output file path");
ABSL_FLAG(uint, num_threads, 1, "Number of threads for generation.");
ABSL_FLAG(double, skew, 0.5,
          "skew of zipf dist.");
ABSL_FLAG(uint64_t, num_output, 64E7,
          "Number of zipfians being generated and dumped. This will be divided "
          "equally among all threads.");

using Counter = absl::flat_hash_map<uint64_t, uint64_t>;

// Worker thread for generating and dumping zipfian numbers.
Counter dump_zipf_worker(const double skew, const uint tid, const uint64_t num_output) {
  std::cerr << "Starting worker " << tid << std::endl;

  // Initialize input reader
  kmercounter::input_reader::ZipfianGenerator reader{
      skew, num_output, tid + 1};

  // Count freq.
  Counter counter;
  uint64_t key{};
  for (uint64_t i = 0; i < num_output && reader.next(&key); i++) {
    counter[key]++;
  }

  std::cerr << "Worker " << tid << " finished." << std::endl;
  return counter;
}

void dump_zipf(const uint num_threads, const std::string_view output_file,
               const double skew, const uint64_t num_output) {
  std::cerr << "Writing zipfian with skew " << std::setprecision(2) << skew
            << " to <" << output_file << ">" << std::endl;

  // Initialized buffered output stream
  std::ostream *pofile;
  if (output_file.empty()) {
    pofile = &std::cout;
  } else {
    pofile =
        new std::ofstream(output_file.data(), std::ios::out | std::ios::binary);
  }
  std::ostream &ofile = *pofile;

  // Create async workers.
  const uint64_t num_output_pre_thread = num_output / num_threads;
  std::vector<std::future<Counter>> futures;
  futures.reserve(num_threads);
  for (uint tid = 0; tid < num_threads; tid++) {
    std::future<Counter> future = std::async(dump_zipf_worker, skew, tid, num_output_pre_thread);
    futures.push_back(std::move(future));
  }

  // Join worker threads.
  Counter main_counter;
  for (auto &future : futures) {
    for (auto&& [key, count] : future.get()) {
      main_counter[key] += count;
    }
  }

  // Dump frequencies
  for (auto&& [_, count] : main_counter) {
    ofile.write((char*)&count, sizeof(uint64_t));
  }

  // Cleanup
  if (!output_file.empty()) {
    delete pofile;
  }
  pofile = nullptr;
}

int main(int argc, char **argv) {
  absl::ParseCommandLine(argc, argv);
  dump_zipf(absl::GetFlag(FLAGS_num_threads), absl::GetFlag(FLAGS_output_file),
            absl::GetFlag(FLAGS_skew), absl::GetFlag(FLAGS_num_output));
  return 0;
}