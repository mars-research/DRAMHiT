#include <absl/flags/flag.h>
#include <absl/flags/parse.h>

#include <fstream>
#include <iomanip>
#include <iostream>
#include <random>
#include <string>
#include <string_view>
#include <syncstream>

#include "fastrange.h"
#include "hasher.hpp"
#include "input_reader/zipfian.hpp"

ABSL_FLAG(std::string, output_file, "", "Output file path");
ABSL_FLAG(double, sample_rate, 1.0,
          "Fraction of output sampled. 1.0 being sampling all output.");

void dump_zipf(const std::string_view output_file, double skew, const uint tid) {
  std::cerr << "TID " << tid << ": writing zipfian with skew "
            << std::setprecision(2) << skew << " to " << output_file
            << std::endl;

  // Initialize input reader
  constexpr auto keyrange_width = 64ull * (1ull << 26);
  kmercounter::input_reader::ZipfianGenerator<uint64_t> reader{
      skew, keyrange_width, tid + 1};

  // Initialized buffered output stream
  std::ostream *pofile;
  if (output_file.empty()) {
    pofile = &std::cout;
  } else {
    pofile =
        new std::ofstream(output_file.data(), std::ios::out | std::ios::binary);
  }
  std::ostream &ofile = *pofile;
  std::

  uint64_t kmer{};
  uint64_t i = 0;
  while (reader.next(&kmer)) {
    const uint64_t hash = kmer;
    ofile.write((char *)&hash, sizeof(uint64_t));
  }
  if (!output_file.empty()) {
    delete pofile;
  }
  pofile = nullptr;
}

int main(int argc, char **argv) {
  absl::ParseCommandLine(argc, argv);
  dump_zipf(absl::GetFlag(FLAGS_output_file), absl::GetFlag(FLAGS_sample_rate),
            0);
  return 0;
}