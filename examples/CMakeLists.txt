find_package(absl REQUIRED)

# Check g++ version
if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 8.0)
    message(FATAL_ERROR "gcc11 or above is needed.")
endif()

add_executable(dump_kmer_hash dump_kmer_hash.cpp)
target_link_libraries(dump_kmer_hash 
  dramhit_lib 
  absl::flags
  absl::flags_parse
)

add_executable(dump_zipf dump_zipf.cpp)
target_link_libraries(dump_zipf 
  dramhit_lib 
  absl::flags
  absl::flags_parse
)

add_executable(dump_zipf_cdf dump_zipf_cdf.cpp)
target_link_libraries(dump_zipf_cdf 
  dramhit_lib 
  absl::flat_hash_map
  absl::flags
  absl::flags_parse
)

add_executable(dump_zipf_freq dump_zipf_freq.cpp)
target_link_libraries(dump_zipf_freq 
  dramhit_lib 
  absl::flat_hash_map
  absl::flags
  absl::flags_parse
)

add_executable(generate_dataset generate_dataset.cpp)
target_link_libraries(generate_dataset 
  dramhit_lib 
  absl::flat_hash_set
  absl::flags
  absl::flags_parse
)

add_executable(most_freq_kmer most_freq_kmer.cpp)
target_link_libraries(most_freq_kmer 
  dramhit_lib 
  absl::flat_hash_map
  absl::flags
  absl::flags_parse
)

add_executable(num_unique_kmer num_unique_kmer.cpp)
target_link_libraries(num_unique_kmer 
  dramhit_lib 
  absl::flat_hash_map
  absl::flags
  absl::flags_parse
  Boost::boost
)