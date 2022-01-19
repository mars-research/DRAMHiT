#include <gtest/gtest.h>
#include <misc_lib.h>

#include <array>
#include <hashtables/cas_kht.hpp>
#include <hashtables/simple_kht.hpp>

using namespace kmercounter;

void read_back(BaseHashTable& map) {
  std::array<Keys, HT_TESTS_BATCH_LENGTH> keys{};
  KeyPairs kp{keys.size(), keys.data()};
  xorwow_urbg prng;
  for (auto& key : keys) key.key = prng() | 1;
  map.insert_batch(kp);
  map.flush_insert_queue();

  std::array<Values, HT_TESTS_FIND_BATCH_LENGTH> values{};
  ValuePairs vp{0, values.data()};
  map.find_batch(kp, vp);
  map.flush_find_queue(vp);
  ASSERT_EQ(vp.first, keys.size())
      << "Did not find all keys (" << vp.first << " found, but " << keys.size()
      << " inserted)\n";
}

TEST(partitioned, read_back) {
  PartitionedHashStore<Aggr_KV, ItemQueue> map{256, 0};
  read_back(map);
}

TEST(cashtpp, read_back) {
  CASHashTable<Aggr_KV, ItemQueue> map{256};
  read_back(map);
}

void aggr_count(BaseHashTable& map) {
  std::array<Keys, HT_TESTS_BATCH_LENGTH> keys{};
  KeyPairs kp{keys.size(), keys.data()};
  xorwow_urbg prng;
  for (auto& key : keys) key.key = prng() | 1;
  map.insert_batch(kp);
  map.flush_insert_queue();

  std::array<Values, HT_TESTS_FIND_BATCH_LENGTH> values{};
  ValuePairs vp{0, values.data()};
  map.find_batch(kp, vp);
  map.flush_find_queue(vp);
  for (auto i = 0u; i < vp.first; ++i)
    ASSERT_EQ(vp.second[i].value, 1)
        << "Each key was inserted once, but count != 0";
}

TEST(partitioned, aggr_count) {
  PartitionedHashStore<Aggr_KV, ItemQueue> map{256, 0};
  aggr_count(map);
}

TEST(cashtpp, aggr_count) {
  CASHashTable<Aggr_KV, ItemQueue> map{256};
  aggr_count(map);
}

void aggr_count_many(BaseHashTable& map) {
  std::array<Keys, HT_TESTS_BATCH_LENGTH> keys{};
  KeyPairs kp{keys.size(), keys.data()};
  for (auto& key : keys) key.key = 0xdeadbeef;
  map.insert_batch(kp);
  map.flush_insert_queue();

  std::array<Values, HT_TESTS_FIND_BATCH_LENGTH> values{};
  ValuePairs vp{0, values.data()};
  map.find_batch(kp, vp);
  map.flush_find_queue(vp);
  for (auto i = 0u; i < vp.first; ++i)
    ASSERT_EQ(vp.second[i].value, keys.size())
        << "Aggregate count did not equal insert count";
}

TEST(partitioned, aggr_count_many) {
  PartitionedHashStore<Aggr_KV, ItemQueue> map{256, 0};
  aggr_count_many(map);
}

TEST(cashtpp, aggr_count_many) {
  CASHashTable<Aggr_KV, ItemQueue> map{256};
  aggr_count_many(map);
}
