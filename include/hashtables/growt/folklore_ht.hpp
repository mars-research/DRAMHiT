#ifndef KVSTORE_FOLKLORE_HT_HEADER
#define KVSTORE_FOLKLORE_HT_HEADER

#include <memory>
#include <stdexcept>

#include "allocator/alignedallocator.hpp"
#include "constants.hpp"
#include "data-structures/table_config.hpp"
#include "hasher.hpp"
#include "hashtables/ht_helper.hpp"
#include "helper.hpp"
#include "plog/Log.h"
#include "sync.h"
#include "utils/default_hash.hpp"
#include "wrapper/tbb_um_wrapper.hpp"

namespace kmercounter {

using growt_config =
    growt::table_config<kmercounter::key_type, kmercounter::value_type,
                        utils_tm::hash_tm::default_hash,
                        growt::AlignedAllocator<> >;

using tbb_config =
    tbb_um_config<kmercounter::key_type, kmercounter::value_type,
                  utils_tm::hash_tm::default_hash, growt::AlignedAllocator<> >;

template <typename table_config>
class GrowTHashTable : public BaseHashTable {
  using table_type = table_config::table_type;
  using handle_type = table_type::handle_type;

 public:
  GrowTHashTable(uint64_t capacity) {
    std::lock_guard literally_just_needs_a_name{mutex};
    if (!initialized) {
      initialized = true;
      table = table_type(capacity);// std::make_unique<table_type>(capacity);
    }
  }

  bool insert(const void *data) {
    return false;  // TODO
  }

  // NEVER NEVER NEVER USE KEY OR ID 0
  // Your inserts will be ignored if you do (we use these as empty markers)
  void insert_batch(const InsertFindArguments &kp,
                    collector_type *collector = nullptr) {
    // TODO
    // NEED FOR TEST
    handle_type& ht = table.get_handle();
    for (auto &mapping : kp) {
      ht.insert(mapping.key, mapping.value);
    }
  }

  void insert_noprefetch(const void *data,
                         collector_type *collector = nullptr) {
    PLOG_DEBUG.printf("folklore insert");
    const InsertFindArgument *kp =
        reinterpret_cast<const InsertFindArgument *>(data);
    handle_type& ht = table.get_handle();
    ht.insert(kp->key, kp->value);
  }

  void flush_insert_queue(collector_type *collector = nullptr) {
    // TODO
    // NEED FOR TEST
  }

  // NEVER NEVER NEVER USE KEY OR ID 0
  // Your inserts will be ignored if you do (we use these as empty markers)
  void find_batch(const InsertFindArguments &kp, ValuePairs &vp,
                  collector_type *collector = nullptr) {
    // TODO
    // NEED FOR TEST
  }

  void *find_noprefetch(const void *data, collector_type *collector = nullptr) {
    const kmercounter::key_type *key =
        reinterpret_cast<const kmercounter::key_type *>(data);
    handle_type& ht = table.get_handle();
    auto val = ht.find(*key);
    // return some kind of pointer purely for the purposes of the test (it
    // doesn't actually use the pointer)
    return val != ht.end() ? &val : nullptr;
  }

  void flush_find_queue(ValuePairs &vp, collector_type *collector = nullptr) {
    // TODO
    // NEED FOR TEST
  }

  void display() const {
    // TODO
  }

  size_t get_fill() const {
    return 0;  // TODO
  }

  size_t get_capacity() const {
    return 0;  // TODO
  }

  size_t get_max_count() const {
    return 0;  // TODO
  }

  void print_to_file(std::string &outfile) const {
    // TODO
  }

  uint64_t read_hashtable_element(const void *data) {
    return 0;  // TODO
  }

  void prefetch_queue(QueueType qtype) {
    // TODO
  }

  // uhh?
  // uint64_t num_reprobes = 0;
  // uint64_t num_soft_reprobes = 0;
  // uint64_t num_memcmps = 0;
  // uint64_t num_memcpys = 0;
  // uint64_t num_hashcmps = 0;
  // uint64_t num_queue_flushes = 0;
  // uint64_t sum_distance_from_bucket = 0;
  // uint64_t max_distance_from_bucket = 0;
  // uint64_t num_swaps = 0;

 private:
  // static std::unique_ptr<table_type> table;
  alignas(64) static table_type table;
  static std::mutex mutex;
  static bool initialized;
};

using FolkloreHashTable = GrowTHashTable<growt_config>;
using TbbHashTable = GrowTHashTable<tbb_config>;

template <typename config>
GrowTHashTable<config>::table_type GrowTHashTable<config>::table{};

template <typename config>
bool GrowTHashTable<config>::initialized{};

template <typename config>
std::mutex GrowTHashTable<config>::mutex{};

}  // namespace kmercounter

#endif
