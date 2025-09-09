#include <cassert>
#include <cstdint>
#include <cstdio>
#include <mutex>
#include <unordered_map>

#include "hashtables/base_kht.hpp"

namespace kmercounter {

class UMAP_HashTable : public BaseHashTable {
 private:
  static std::mutex ht_init_mutex;
  static std::unordered_map<uint64_t, uint64_t>* table;
  static uint32_t ref_cnt;
  static uint64_t bucket_count_start;

 public:
  UMAP_HashTable(uint64_t sz) {
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      if (!table) {
        assert(ref_cnt == 0);
        table = new std::unordered_map<uint64_t, uint64_t>();
        // dramhit 'sz' is a kv which is 16bytes, umap 'reserves' for 'sz' items
        // without resize.
        table->reserve(sz);
        // only resize if at 100% capcity
        table->max_load_factor(1.0);
        printf("Created std::unordered_map at %p with reserved buckets %zu\n",
               (void*)table, sz);

        bucket_count_start = table->bucket_count();
        fflush(stdout);
      }
    }  // end lock...
    ref_cnt++;
  }

  ~UMAP_HashTable() override {
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      ref_cnt--;
      if (ref_cnt == 0) {
        printf("Final load factor: %f\n", table->load_factor());

        if (table->bucket_count() != bucket_count_start) {
          fprintf(stderr,
                  "ERROR: std::unordered_map resized START: %zu END: %zu!\n",
                  bucket_count_start, table->bucket_count());
          // abort();
        }

        delete table;
        table = nullptr;
      }
    }  // end lock...
  }

  void insert_batch(const InsertFindArguments& kp,
                    collector_type* collector) override {
    for (auto& data : kp) {
     if (!table->insert_or_assign(data.key, data.value).second) {
        //std::cout << "growt insertion failed" << std::endl;
      }
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
      //   else abort();
    }
  }

  // --- stubs for BaseHashTable interface ---
  bool insert(const void*) override { return false; }
  void insert_noprefetch(const void*, collector_type* = nullptr) override {}
  void flush_insert_queue(collector_type* = nullptr) override {}
  void* find_noprefetch(const void*, collector_type* = nullptr) override {
    return nullptr;
  }
  void flush_find_queue(ValuePairs&, collector_type* = nullptr) override {}
  void display() const override {}
  size_t get_fill() const override { return table->size(); }
  size_t get_capacity() const override { return table->bucket_count(); }
  size_t get_max_count() const override { return 0; }
  void print_to_file(std::string&) const override {}
  uint64_t read_hashtable_element(const void*) override { return 0; }
  void prefetch_queue(QueueType) override {}
};

std::mutex UMAP_HashTable::ht_init_mutex;
uint32_t UMAP_HashTable::ref_cnt=0;
std::unordered_map<uint64_t, uint64_t>* UMAP_HashTable::table = nullptr;
uint64_t UMAP_HashTable::bucket_count_start = 0;


}  // namespace kmercounter
