#include <stdio.h>
#include <sys/mman.h>

#include "hashtables/base_kht.hpp"

// CLHT includes (choose lock-based or lock-free)
extern "C" {
#include "clht_lf.h"  //lock-free (no resize)
//#include "/opt/DRAMHiT/CLHT/include/clht_lf_res.h" //lock-free resize
}

namespace kmercounter {
// Needed by clht
//  #define CORES_PER_SOCKET 64
//  #define NUMBER_OF_SOCKETS 2
//  #define CACHE_LINE_SIZE 64

class CLHT_HashTable : public BaseHashTable {
 private:
  static std::mutex ht_init_mutex;
  static clht_t* table;
  static uint32_t ref_cnt;

  uint64_t num_buckets;

 public:
  CLHT_HashTable(uint64_t sz) {

    {

      num_buckets = sz / 4; // CLHT bucket is 64 byte. Dramhit sz is count of kv which is 16 bytes. 
      const std::lock_guard<std::mutex> lock(ht_init_mutex);

      if (!table) {
        assert(this->ref_cnt == 0);
        table = clht_create(num_buckets);
        printf("Created %s at addr %p\n", clht_type_desc(), (void*)table);
        fflush(stdout);
      }
      
      this->ref_cnt++;

    }  // end scope of lock...
  }

  ~CLHT_HashTable() override {
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      this->ref_cnt--;
      if (this->ref_cnt == 0) {
      }
    }  // end scope of lock...
  }

  // --- insert a batch of keys ---
  void insert_batch(const InsertFindArguments& kp,
                    collector_type* collector) override {
    for (auto& data : kp) {
      clht_put(table, data.key, data.value);
    }
  }

  void find_batch(const InsertFindArguments& kp, ValuePairs& vp,
                  collector_type* collector) override {
    for (auto& data : kp) {
      auto val = clht_get(table->ht, data.key);
      if (val) {
        vp.second[vp.first].value = val;
        vp.second[vp.first].id = data.id;
        vp.first++;
      }  
    }
  }

  // --- stub the rest so we satisfy BaseHashTable ---
  bool insert(const void*) override { return false; }
  void insert_noprefetch(const void*, collector_type* = nullptr) override {}
  void flush_insert_queue(collector_type* = nullptr) override {}
  void* find_noprefetch(const void*, collector_type* = nullptr) override {
    return nullptr;
  }
  size_t flush_find_queue(ValuePairs&, collector_type* = nullptr) override {return 0; }
  void display() const override {}
  size_t get_fill() const override { return clht_size(table->ht); }
  size_t get_capacity() const override { return this->num_buckets * 3; }
  size_t get_max_count() const override { return 0; }
  void print_to_file(std::string&) const override {}
  uint64_t read_hashtable_element(const void*) override { return 0; }
  void prefetch_queue(QueueType) override {}
};

std::mutex CLHT_HashTable::ht_init_mutex;
uint32_t CLHT_HashTable::ref_cnt;
clht_t* CLHT_HashTable::table = nullptr;

}  // namespace kmercounter
