find_package(absl REQUIRED)

add_executable(dump_kmer_hash dump_kmer_hash.cpp)
target_link_libraries(dump_kmer_hash 
  ht_lib 
  absl::flags
  absl::flags_parse
)

add_executable(most_freq_kmer most_freq_kmer.cpp)
target_link_libraries(most_freq_kmer 
  ht_lib 
  absl::flat_hash_map
  absl::flags
  absl::flags_parse
)

add_executable(num_unique_kmer num_unique_kmer.cpp)
target_link_libraries(num_unique_kmer 
  ht_lib 
  absl::flat_hash_map
  absl::flags
  absl::flags_parse
  Boost::boost
)