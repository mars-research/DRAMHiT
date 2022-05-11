#include <absl/flags/flag.h>
#include <absl/flags/parse.h>

#include <fstream>
#include <iomanip>
#include <iostream>
#include <random>
#include <string>
#include <string_view>
#include <syncstream>
#include <thread>
#include <vector>

#include "fastrange.h"
#include "hasher.hpp"
#include "input_reader/zipfian.hpp"

ABSL_FLAG(std::string, output_file, "", "Output file path");
ABSL_FLAG(uint, num_threads, 1, "Number of threads for generation.");
ABSL_FLAG(double, sample_rate, 0.5,
          "Fraction of output sampled. 1.0 being sampling all output.");
ABSL_FLAG(uint64_t, output_size, (1ull << 26) * 64,
          "Number of zipfians being generated and dumped. This will be divided "
          "equally among all threads.");

// Worker thread for generating and dumping zipfian numbers.
void dump_zipf_worker(std::osyncstream os, const double skew, const uint tid) {
  // Initialize input reader
  constexpr auto keyrange_width = 64ull * (1ull << 26);
  kmercounter::input_reader::ZipfianGenerator<uint64_t> reader{
      skew, keyrange_width, tid + 1};

  // Batch 4K write per flush.
  uint64_t key{};
  uint64_t i = 0;
  while (reader.next(&key)) {
    os.write((char *)&key, sizeof(uint64_t));
    if (((++i) % 4096) == 0) {
      os.emit();
    }
  }
}

void dump_zipf(const uint num_threads, const std::string_view output_file,
               const double skew) {
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

  // Create worker threads.
  std::vector<std::thread> threads;
  threads.reserve(num_threads);
  for (uint tid = 0; tid < num_threads; tid++) {
    threads.emplace_back(dump_zipf_worker, std::osyncstream{ofile}, skew, tid);
  }

  // Join worker threads.
  for (auto &thread : threads) {
    thread.join();
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
            absl::GetFlag(FLAGS_sample_rate));
  return 0;
}