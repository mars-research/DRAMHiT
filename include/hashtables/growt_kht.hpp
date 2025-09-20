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

using growht_type =
    growt::table_config<uint64_t, uint64_t, utils_tm::hash_tm::crc_hash,
                        growt::HTLBPoolAllocator<>, 
                        hmod::sync>::table_type;

class GrowtHashTable : public BaseHashTable {
  // Growt configuration from your example

 private:
  static growht_type* table;
  static uint32_t ref_cnt;
  static std::mutex ht_init_mutex;
  uint64_t sz;

 public:
  GrowtHashTable(uint64_t capacity) {
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);

      sz = capacity/2; 
      if (!table) {
        assert(this->ref_cnt == 0);
        this->table = new growht_type(sz);

        std::cout << "table name " << table->name() << " size " << table->capacity() << std::endl;
      }
      this->ref_cnt++;
    }
  }

  ~GrowtHashTable() {
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      this->ref_cnt--;
      if (this->ref_cnt == 0) {
        delete table;
      }
    }
  }

  // Batch insert
  void insert_batch(const InsertFindArguments& kp,
                    collector_type* collector = nullptr) override {
    //
    for (auto& data : kp) {
      // std::cout << "growt inserting key " << data.key << std::endl;
      if (!table->insert_or_assign(data.key, data.value).second) {
        //std::cout << "growt insertion failed" << std::endl;
      }
    }
  }

  // Batch find
  void find_batch(const InsertFindArguments& kp, ValuePairs& vp,
                  collector_type* collector = nullptr) override {
    for (auto& data : kp) {
      // std::cout << "growt find key " << data.key << std::endl;

      auto it = table->find(data.key);
      if (it != table->end()) {
        vp.second[vp.first].value = (*it).second;
        vp.second[vp.first].id = data.id;
        vp.first++;
      } else {
        //std::cout << "growt find failed " << data.key << std::endl;
      }
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
    size_t count=0;
    for (auto it = table->cbegin(); it != table->cend(); ++it) {
    ++count;
    }
    return count;
 }

  size_t get_capacity() const override { return table->capacity(); }

  size_t get_max_count() const override {
    return 0;  // Growt doesn’t expose max load
  }
};

std::mutex GrowtHashTable::ht_init_mutex;
uint32_t GrowtHashTable::ref_cnt;
growht_type* GrowtHashTable::table;

}  // namespace kmercounter
