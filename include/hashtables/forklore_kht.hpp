#pragma once

#include <cstddef>
#include <cstdint>
#include <iostream>
#include <mutex>
#include <string>
#include <type_traits>

#include "allocator/poolallocator.hpp"
#include "data-structures/hash_table_mods.hpp"
#include "data-structures/table_config.hpp"
#include "hashtables/base_kht.hpp"
#include "utils/hash/crc_hash.hpp"

namespace kmercounter {

template <typename KV>
class ForkloreHashTable : public BaseHashTable {

 private:
  size_t size;
  size_t capacity;
  uint64_t id;
  KV* store;

 public:
  ForkloreHashTable(size_t capacity, uint64_t id) {

  }

  ~ForkloreHashTable() {
  }

  // Batch insert
  void insert_batch(const InsertFindArguments& kp,
                    collector_type* collector = nullptr) override {
    for (auto& data : kp) {
    }
  }

  // Batch find
  void find_batch(const InsertFindArguments& kp, ValuePairs& vp,
                  collector_type* collector = nullptr) override {
    for (auto& data : kp) {
    }
  }


  // Insert single (expects std::pair<size_t,size_t>)
  bool insert(const void* data) override { return false; }

  void insert_noprefetch(const void* data,
                         collector_type* collector = nullptr) override {
    return;
  }

  void flush_insert_queue(collector_type* collector = nullptr) override {
    return;
  }

  void* find_noprefetch(const void* data,
                        collector_type* collector = nullptr) override {
    return nullptr;
  }

  size_t flush_find_queue(ValuePairs& vp,
                        collector_type* collector = nullptr) override {
    // no-op
    return 0;
  }

  void display() const override {}

  void print_to_file(std::string& outfile) const override {}

  uint64_t read_hashtable_element(const void* data) override {}

  void prefetch_queue(QueueType qtype) override {}

  size_t get_fill() const override {
      return size;
 }

  size_t get_capacity() const override { return capacity; }

  size_t get_max_count() const override {
    return 0;  // Growt doesn’t expose max load
  }
};

}  // namespace kmercounter
