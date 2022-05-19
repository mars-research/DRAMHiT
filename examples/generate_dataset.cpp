/// Generate two relations, R and S.
/// R is be the primary key table and S is the foreign key table.
/// Each table has two column: the key column and the value column.
/// The value is `key/2` in relation R and `key*2` in relation S.

#include <absl/container/flat_hash_set.h>
#include <absl/flags/flag.h>
#include <absl/flags/parse.h>

#include <algorithm>
#include <cstdio>
#include <fstream>
#include <functional>
#include <iostream>
#include <random>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

#include "zipf_distribution.hpp"

ABSL_FLAG(std::string, outfile_r, "r.tbl", "Output file path for relation R");
ABSL_FLAG(std::string, outfile_s, "s.tbl", "Output file path for relation S");
ABSL_FLAG(uint64_t, num_keys, 64E7, "Number of unique keys being generator");
ABSL_FLAG(uint, ratio, 1, "|S| to |R| ratio. For example, ");
ABSL_FLAG(std::string, delimitor, "|", "Column seperator.");

using Key = uint64_t;
using Keys = std::vector<Key>;

// Generated shuffled primary keys and foreign keys.
std::pair<Keys, Keys> gen_keys(const uint64_t num_keys, const uint ratio) {
  std::random_device rd;
  std::mt19937 gen{rd()};

  // Generate primary keys and shuffle them
  kmercounter::zipf_distribution_apache dist(1ull<<63, 0.01);
  absl::flat_hash_set<uint64_t> key_set;
  while (key_set.size() < num_keys) {
    key_set.insert(dist.sample());
  }
  Keys keys(key_set.begin(), key_set.end());
  std::ranges::shuffle(keys, gen);

  // Generate primary keys and shuffle them
  Keys foreign_keys;
  foreign_keys.reserve(num_keys * ratio);
  for (uint i = 0; i < ratio; i++) {
    foreign_keys.insert(foreign_keys.end(), keys.begin(), keys.end());
  }
  std::ranges::shuffle(foreign_keys, gen);

  return std::make_pair(keys, foreign_keys);
}

// Write dataset file. `value_fn` is used to generate the value for a key.
void write_dataset(const std::string path, const ::std::string delimitor,
                   Keys keys, const std::function<Key(Key)> value_fn) {
  // Open files for writing
  std::ofstream ofile(path);
  if (ofile.fail()) {
    perror("Failed to open file.");
  }

  // Write to file
  for (const auto key : keys) {
    ofile << key << delimitor << value_fn(key) << "\n";
  }
}

void gen_dataset(const std::string outfile_r, const std::string outfile_s,
                 const uint64_t num_keys, const uint ratio,
                 const ::std::string delimitor) {
  // Generate keys
  const auto [keys, foreign_keys] = gen_keys(num_keys, ratio);

  // Write keys to file
  const auto divide_by_two = [](const Key key) { return key / 2; };
  write_dataset(outfile_r, delimitor, keys, divide_by_two);
  const auto multiply_by_two = [](const Key key) { return key * 2; };
  write_dataset(outfile_s, delimitor, foreign_keys, multiply_by_two);
}

int main(int argc, char **argv) {
  absl::ParseCommandLine(argc, argv);
  gen_dataset(absl::GetFlag(FLAGS_outfile_r), absl::GetFlag(FLAGS_outfile_s),
              absl::GetFlag(FLAGS_num_keys), absl::GetFlag(FLAGS_ratio),
              absl::GetFlag(FLAGS_delimitor));
  return 0;
}