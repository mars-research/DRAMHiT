#include <string>
#include <iostream>
#include <fstream>
#include <random>

#include <absl/flags/flag.h>
#include <absl/flags/parse.h>

#include "hasher.hpp"
#include "fastrange.h"
#include "input_reader/fastq.hpp"

ABSL_FLAG(std::string, input_file, "../SRR072006.fastq",
          "A fastq file that we read the input from.");
ABSL_FLAG(std::string, output_file, "hashes.data",
          "Output file path");
ABSL_FLAG(double, sample_rate, 1.0, "Fraction of output sampled. 1.0 being sampling all output.");

void dump_hashes(const std::string_view input_file, const std::string_view output_file, double sample_rate) {
  std::cerr << "Reading from " << input_file << " writing to " << output_file << " with sampling rate " << sample_rate << " with K=" << KMER_LEN << std::endl;

  if (sample_rate > 1.0 || sample_rate < 0.0) {
    std::cerr << "Invalid sample rate " << sample_rate << std::endl;
    throw "Invalid sample rate";
  }
  std::random_device rd;
  std::mt19937 rand_gen(rd());
  std::bernoulli_distribution sampler(sample_rate);

  kmercounter::Hasher hasher;
  kmercounter::input_reader::FastqKMerReader<KMER_LEN> reader(input_file);
  std::ostream *ofile;
  if (output_file.empty()) {
    ofile = &std::cout;
  } else {
    ofile = new std::ofstream(output_file.data(), std::ios::out | std::ios::binary);
  }
  uint64_t kmer{};
  uint64_t i = 0;
  while(reader.next(&kmer)) {
    if (!sampler(rand_gen)) {
      continue;
    }
    // const uint64_t hash = hasher(&kmer, sizeof(uint64_t));
    const uint64_t hash = kmer;
    ofile->write((char*)&hash, sizeof(uint64_t));
  }
  if (!output_file.empty()) {
    delete ofile;
  }
  ofile = nullptr;
}

int main(int argc, char **argv) {
  absl::ParseCommandLine(argc, argv);
  dump_hashes(absl::GetFlag(FLAGS_input_file), absl::GetFlag(FLAGS_output_file), absl::GetFlag(FLAGS_sample_rate));
  return 0;
}