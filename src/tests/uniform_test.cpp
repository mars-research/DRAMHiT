#include <cstdint>
#include <cstdlib>
#include "tests/UniformTest.hpp"

namespace kmercounter {

extern bool clear_table;
extern ExecPhase cur_phase;
extern uint64_t *g_insert_durations;
extern uint64_t *g_find_durations;
extern uint64_t zipfian_iter;
extern bool stop_sync;
extern bool zipfian_finds;
extern bool zipfian_inserts;

static inline uint64_t hash_knuth(uint64_t x) {
    return x * 11400714819323198485ULL;
}

void do_uniform_batch_insertion(BaseHashTable *ht, uint64_t requests_num, unsigned int id) {
#if defined(CAS_NO_ABSTRACT)
  CASHashTable<KVType, ItemQueue> *cas_ht =
      static_cast<CASHashTable<KVType, ItemQueue> *>(ht);
#endif
  collector_type *const collector{};

  uint32_t batch_len = config.batch_len;
  InsertFindArgument* items = (InsertFindArgument*)aligned_alloc(
      64, sizeof(InsertFindArgument) * batch_len);
  size_t batch_num = requests_num / batch_len;
  size_t residue_num = requests_num - batch_len * batch_num;
  size_t idx = 0;
  size_t offset = id * requests_num;

  uint64_t payload;
  for (unsigned int n = 0; n < batch_num; n++) {
    // on each batch, populate find args
    for (int i = 0; i < batch_len; i++) {
      payload = hash_knuth(idx + offset);
      items[i].key = payload;
      items[i].value = payload;
      items[i].id = idx;
      idx++;
    }

    ht->insert_batch(InsertFindArguments(items, batch_len), collector);
  }

  // in case batch size is not divisible
  if (residue_num > 0) {
    for (int i = 0; i < residue_num; i++) {
      payload = hash_knuth(idx + offset);
      items[i].key = payload;
      items[i].value = payload;
      items[i].id = idx;
      idx++;
    }

    ht->insert_batch(InsertFindArguments(items, residue_num), collector);
  }

  ht->flush_insert_queue(collector);
  free(items);
}

uint64_t do_uniform_batch_find(BaseHashTable *ht, uint64_t requests_num, unsigned int id) {
#if defined(CAS_NO_ABSTRACT)
  CASHashTable<KVType, ItemQueue> *cas_ht =
      static_cast<CASHashTable<KVType, ItemQueue> *>(ht);
#endif
  uint64_t found = 0;
  collector_type *const collector{};
  InsertFindArgument *items = (InsertFindArgument *)aligned_alloc(
      64, sizeof(InsertFindArgument) * config.batch_len);
  uint32_t batch_len = config.batch_len;
  size_t batch_num = requests_num / batch_len;
  FindResult *results = new FindResult[batch_len];
  ValuePairs vp = std::make_pair(0, results);
  size_t residue_num = requests_num - batch_len * batch_num;
  uint64_t payload;
  uint64_t idx = 0;
  uint64_t offset = id * requests_num; // 1 + 1 * 1000
  for (unsigned int n = 0; n < batch_num; ++n) {
    for (int i = 0; i < batch_len; i++) {
      payload = hash_knuth(idx + offset);
      items[i].key = payload;
      items[i].id = idx;
      idx++;
    }

    vp.first = 0;

#if defined(CAS_NO_ABSTRACT)
    cas_ht->find_batch_inline(InsertFindArguments(items, config.batch_len), vp,
                              collector);
#else
    ht->find_batch(InsertFindArguments(items, config.batch_len), vp, collector);
#endif

    found += vp.first;
  }

  if (residue_num > 0) {
    for (int i = 0; i < residue_num; i++) {
        payload = hash_knuth(idx + offset);
        items[i].key = payload;
        items[i].id = idx;
        idx++;
    }
    vp.first = 0;
    ht->find_batch(InsertFindArguments(items, residue_num), vp, collector);
    found += vp.first;
  }

  while (true) {
    vp.first = 0;
    size_t cur_queue_sz = ht->flush_find_queue(vp, collector);
    if (vp.first == 0 && cur_queue_sz == 0) {
      break;
    }
    found += vp.first;
  }

  free(items);

  return found;
}

OpTimings do_uniform_inserts(
    BaseHashTable *hashtable, unsigned int id,
    uint64_t requests_num,
    std::barrier<std::function<void()>> *sync_barrier) {
  if (config.insert_factor == 0) return {1, 1};

  if (id == 0) {
    cur_phase = ExecPhase::insertions;
    zipfian_inserts = false;
  }

  for (auto j = 0u; j < config.insert_factor; j++) {

    if (id == 0) {
      cur_phase = ExecPhase::insertions;
      zipfian_inserts = false;
    }
    sync_barrier->arrive_and_wait();

    do_uniform_batch_insertion(hashtable, requests_num, id);

    if (id == 0) {
      zipfian_inserts = true;
      zipfian_iter = j;
    }
    sync_barrier->arrive_and_wait();
  }

  uint64_t duration = 0;
  uint64_t ops = 0;
  for (int i = 0; i < config.insert_factor; i++)
    duration += g_insert_durations[i];

  ops = requests_num * config.insert_factor;
  return {duration, ops};
}

OpTimings do_uniform_gets(BaseHashTable *hashtable, unsigned int id,
                          uint64_t requests_num,
                          auto sync_barrier) {
  uint64_t found = 0;

  for (auto j = 0u; j < config.read_factor; j++) {
    if (id == 0) {
      cur_phase = ExecPhase::finds;
      zipfian_finds = false;
    }
    sync_barrier->arrive_and_wait();
    found = do_uniform_batch_find(hashtable, requests_num, id);
    if (id == 0) {
      zipfian_finds = true;
      zipfian_iter = j;
    }
    sync_barrier->arrive_and_wait();
  }

  uint64_t duration = 0;
  uint64_t ops = 0;

  for (int i = 0; i < config.read_factor; i++) duration += g_find_durations[i];
  ops = requests_num * config.read_factor;

  return {duration, ops};
}

void UniformTest::run(Shard *shard, BaseHashTable *hashtable,
                      std::barrier<std::function<void()>> *sync_barrier) {
  OpTimings insert_timings{};
  OpTimings find_timings{};

  uint64_t total = config.ht_size * config.ht_fill / 100;
  uint64_t requests_num = total / config.num_threads;
    if (shard->shard_idx == config.num_threads - 1) {
        requests_num += total % config.num_threads;
    }


    if (shard->shard_idx == 0) {
        PLOGI.printf("requests_num per shard %lu", requests_num);
        PLOGI.printf("test insert start");
    }
  insert_timings = do_uniform_inserts(hashtable, shard->shard_idx, requests_num, sync_barrier);

  if (shard->shard_idx == 0) {
    PLOGI.printf("test insert end");
    PLOGI.printf("test find start");
  }
  find_timings = do_uniform_gets(hashtable, shard->shard_idx, requests_num, sync_barrier);

  if (shard->shard_idx == 0) {
    PLOGI.printf("test find end");
  }

  shard->stats->insertions = insert_timings;
  shard->stats->finds = find_timings;
  shard->stats->ht_fill = config.ht_fill;

  if (shard->shard_idx == 0) {
      cur_phase = ExecPhase::none;
  }

  sync_barrier->arrive_and_wait();

  if (shard->shard_idx == 0) {
    PLOGI.printf("get fill %.3f",
                 (double)hashtable->get_fill() / hashtable->get_capacity());
  }
#ifdef CALC_STATS
  shard->stats->num_reprobes = hashtable->num_reprobes;
#endif
}

}  // namespace kmercounter
