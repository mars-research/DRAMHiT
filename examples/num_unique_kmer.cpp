#include <absl/container/flat_hash_set.h>
#include <absl/flags/flag.h>
#include <absl/flags/parse.h>

#include <boost/asio/post.hpp>
#include <boost/asio/thread_pool.hpp>
#include <boost/bind.hpp>
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

ABSL_FLAG(std::string, input_file, "../memfs/SRR072006.fastq",
          "A fastq file that we read the input from.");
ABSL_FLAG(std::vector<std::string>, K, {},
          "A vector `K`s to run. K=[4, 32] if not set.");

std::vector<std::string> default_Ks() {
  std::vector<std::string> rtn;
  for (int i = 4; i <= 32; i++) {
    rtn.push_back(std::to_string(i));
  }
  return rtn;
}

// Pass the max value that K could be to use it.
// This function will recursively decrease the `MAX_K` until it finds the right
// K.
template <size_t MAX_K>
void num_uniq_kmer(const std::string_view input_file, const size_t K) {
  // Sanity check
  if (K > MAX_K || MAX_K <= 0) {
    std::cerr << "Invalid K: " << K << ";, MAX_K: " << MAX_K << std::endl;
  }
  // Check if we are at the right K. Go down if now.
  if (K != MAX_K) {
    return num_uniq_kmer<MAX_K - 1>(input_file, K);
  }

  // Count the KMers
  std::cout << "Reading from " << input_file << " with K=" << K << std::endl;
  kmercounter::input_reader::FastqKMerReader<MAX_K> reader(input_file);
  absl::flat_hash_set<uint64_t> counter(1 << 30);  // 1GB initial size.
  uint64_t kmer{};
  while (reader.next(&kmer)) {
    counter.insert(kmer);
  }

  // Output size.
  std::cout << MAX_K << ": " << counter.size() << std::endl;
}

template <>
void num_uniq_kmer<0>(const std::string_view input_file, const size_t K) {
  std::cerr << "Invalid K: " << K << ";, MAX_K: " << 0 << std::endl;
  throw -1;
}

int main(int argc, char** argv) {
  absl::ParseCommandLine(argc, argv);
  const auto input_file = absl::GetFlag(FLAGS_input_file);
  auto Ks = absl::GetFlag(FLAGS_K);
  if (Ks.empty()) {
    Ks = default_Ks();
  }
  // boost::asio::thread_pool pool(4); // 4 threads
  // for (const auto& K : Ks) {
  //   boost::asio::post(pool, [] {});
  //   num_uniq_kmer<32>(input_file, std::stoul(K));
  // }
  // pool.join();
  for (const auto& K : Ks) {
    num_uniq_kmer<32>(input_file, std::stoul(K));
  }
  return 0;
}