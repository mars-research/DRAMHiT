find_package(absl REQUIRED)

add_executable(dump_kmer_hash dump_kmer_hash.cpp)
target_link_libraries(dump_kmer_hash 
  ht_lib 
  absl::flags
  absl::flags_parse
)