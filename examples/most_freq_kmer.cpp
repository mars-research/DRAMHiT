#include <absl/container/flat_hash_map.h>
#include <absl/flags/flag.h>
#include <absl/flags/parse.h>

#include <fstream>
#include <iostream>
#include <queue>
#include <random>
#include <string>
#include <vector>

#include "fastrange.h"
#include "hasher.hpp"
#include "input_reader/fastq.hpp"
#include "utils/circular_buffer.hpp"

ABSL_FLAG(std::string, input_file, "../SRR072006.fastq",
          "A fastq file that we read the input from.");
ABSL_FLAG(size_t, limit, 20, "Max number of output.");
ABSL_FLAG(std::vector<std::string>, K,
          std::vector<std::string>({"4", "5", "6", "7", "8", "9", "10", "11",
                                    "12", "13", "14", "15", "16", "17", "18"}),
          "A vector `K`s to run.");

// Pass the max value that K could be to use it.
// This function will recursively decrease the `MAX_K` until it finds the right
// K.
template <size_t MAX_K>
void most_freq_kmer(const std::string_view input_file, const size_t limit,
                    const size_t K) {
  // Sanity check
  if (K > MAX_K || MAX_K <= 0) {
    std::cerr << "Invalid K: " << K << ";, MAX_K: " << MAX_K << std::endl;
  }
  // Check if we are at the right K. Go down if now.
  if (K != MAX_K) {
    return most_freq_kmer<MAX_K - 1>(input_file, limit, K);
  }

  // Count the KMers
  std::cout << "Reading from " << input_file << " with K=" << K << std::endl;
  kmercounter::input_reader::FastqKMerReader<MAX_K> reader(input_file);
  std::unordered_map<uint64_t, uint64_t> counter;
  uint64_t kmer{};
  while (reader.next(&kmer)) {
    counter[kmer]++;
  }

  // Initialize a pq over counts
  std::priority_queue<std::tuple<uint64_t, uint64_t>> pq;
  for (const auto& [kmer, count] : counter) {
    pq.push({count, kmer});
  }

  // Output the top `limit` KMers.
  for (size_t i = 0; i < limit && !pq.empty(); i++) {
    const auto [count, kmer] = pq.top();
    pq.pop();
    std::cout << kmercounter::DNAKMer<MAX_K>::decode(kmer) << ": " << count
              << std::endl;
  }
}

template <>
void most_freq_kmer<0>(const std::string_view input_file, const size_t limit,
                       const size_t K) {
  std::cerr << "Invalid K: " << K << ";, MAX_K: " << 0 << std::endl;
  throw -1;
}

int main(int argc, char** argv) {
  absl::ParseCommandLine(argc, argv);
  const auto input_file = absl::GetFlag(FLAGS_input_file);
  const auto limit = absl::GetFlag(FLAGS_limit);
  for (const auto& K : absl::GetFlag(FLAGS_K)) {
    most_freq_kmer<32>(input_file, limit, std::stoul(K));
  }
  return 0;
}