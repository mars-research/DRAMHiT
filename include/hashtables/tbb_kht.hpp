#include <tbb/concurrent_unordered_map.h>

#include <cassert>
#include <cstdint>
#include <cstdio>

#include "hashtables/base_kht.hpp"

namespace kmercounter {

class TBB_HashTable : public BaseHashTable {
 private:
  // Single shared concurrent map across all instances
  static tbb::concurrent_unordered_map<uint64_t, uint64_t>* table;
  static uint32_t ref_cnt;
  static uint64_t bucket_count_start;
  static std::mutex ht_init_mutex;

 public:
  TBB_HashTable(uint64_t sz) {
    {  // lock scope

      const std::lock_guard<std::mutex> lock(ht_init_mutex);

      if (!table) {
        assert(ref_cnt == 0);

        table = new tbb::concurrent_unordered_map<uint64_t, uint64_t>(sz);
        table->max_load_factor(1.0);
        table->reserve(sz);

        //    bucket_count_start = table->bucket_count();
        bucket_count_start = sz;
        fflush(stdout);
      }
      ref_cnt++;

    }  // end lock scope
  }

  ~TBB_HashTable() override {
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);

      ref_cnt--;
      if (ref_cnt == 0) {
        delete table;
        table = nullptr;
      }
    }
  }

  void clear() {
    printf("Clearing table.\n");
    fflush(stdout);

    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      // delete table;
      // table = new tbb::concurrent_unordered_map<uint64_t, uint64_t>(
      //     bucket_count_start);
      // table->reserve(bucket_count_start);
      table->clear();
    }
  }

  void insert_batch(const InsertFindArguments& kp,
                    collector_type* collector) override {
    for (auto& data : kp) {
      // insert_or_assign equivalent in TBB:
      (*table)[data.key] = data.value;
    }
  }

  void find_batch(const InsertFindArguments& kp, ValuePairs& vp,
                  collector_type* collector) override {
    for (auto& data : kp) {
      auto it = table->find(data.key);
      if (it != table->end()) {
        vp.second[vp.first].value = it->second;
        vp.second[vp.first].id = data.id;
        vp.first++;
      }
    }
  }

  // --- stubs for BaseHashTable interface ---
  bool insert(const void*) override { return false; }
  void insert_noprefetch(const void*, collector_type* = nullptr) override {}
  void flush_insert_queue(collector_type* = nullptr) override {}
  void* find_noprefetch(const void*, collector_type* = nullptr) override {
    return nullptr;
  }
  size_t flush_find_queue(ValuePairs&, collector_type* = nullptr) override {
    return 0;
  }
  void display() const override {}
  size_t get_fill() const override { return table->size(); }
  size_t get_capacity() const override {
    // return table->bucket_count();
    return bucket_count_start;
  }
  size_t get_max_count() const override { return 0; }
  void print_to_file(std::string&) const override {}
  uint64_t read_hashtable_element(const void*) override { return 0; }
  void prefetch_queue(QueueType) override {}
};

// static member definitions
std::mutex TBB_HashTable::ht_init_mutex;
tbb::concurrent_unordered_map<uint64_t, uint64_t>* TBB_HashTable::table =
    nullptr;
uint32_t TBB_HashTable::ref_cnt = 0;
uint64_t TBB_HashTable::bucket_count_start = 0;

}  // namespace kmercounter
