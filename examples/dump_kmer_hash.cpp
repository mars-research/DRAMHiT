#include <string>
#include <fstream>

#include <absl/flags/flag.h>
#include <absl/flags/parse.h>

#include "hasher.hpp"
#include "fastrange.h"
#include "logger.h"
#include "input_reader/fastq.hpp"

ABSL_FLAG(std::string, input_file, "../SRR072006.fastq",
          "A fastq file that we read the input from.");
ABSL_FLAG(std::string, output_file, "hashes.data",
          "Output file path");

constexpr size_t K = 4;

void dump_hashes(const std::string_view input_file, const std::string_view output_file) {
  kmercounter::Hasher hasher;
  kmercounter::input_reader::FastqKMerPreloadReader<K> reader(input_file);
  auto ofile = std::ofstream(output_file.data(), std::ios::out | std::ios::binary);
  std::array<uint8_t, K> kmer;
  while(reader.next(&kmer)) {
    const uint64_t hash = hasher(&kmer, sizeof(uint64_t));
    ofile.write((char*)&hash, sizeof(uint64_t));
  }
}


int main(int argc, char **argv) {
  initializeLogger();
  absl::ParseCommandLine(argc, argv);
  dump_hashes(absl::GetFlag(FLAGS_input_file), absl::GetFlag(FLAGS_output_file));
  return 0;
}