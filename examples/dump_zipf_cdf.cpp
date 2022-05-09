// Dump the cdf of zipfian distribution.

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
  kmercounter::input_reader::ZipfianGenerator<uint64_t> reader{
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
  uint64_t total_count = 0;
  for (auto &future : futures) {
    for (auto&& [key, count] : future.get()) {
      main_counter[key] += count;
      total_count += count;
    }
  }

  // Sort the frequencies
  std::vector<uint64_t> freqs;
  freqs.reserve(main_counter.size());
  for (const auto& [_, freq] : main_counter) {
    freqs.push_back(freq);
  }
  std::sort(freqs.begin(), freqs.end(), std::greater<uint64_t>());

  // Dump header
  ofile << "\% of keys,\% of values" << std::endl;

  // Dump frequencies in batches
  // If we get more than 1 percent of the values, it's a batch.
  double total_val_percentage = 0.0;
  double current_val_percentage = 0.0; // Current percentage of this batch
  for (size_t i = 0; i < freqs.size(); i++) {
    const auto freq = freqs[i];
    const double percentage = (double)freq / total_count * 100.0;
    current_val_percentage += percentage;
    // This is one batch
    if (current_val_percentage >= 1.0) {
      total_val_percentage += current_val_percentage;
      current_val_percentage = 0.0;
      const double total_key_percentage = (double)(i+1) / freqs.size() * 100.0;
      ofile << total_key_percentage << "," << total_val_percentage << std::endl;
    }
  }
  // This is the last batch
  if (current_val_percentage >= 1.0) {
    total_val_percentage += current_val_percentage;
    current_val_percentage = 0.0;
    const double total_key_percentage =  100.0;
    ofile << total_key_percentage << "," << total_val_percentage << std::endl;
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