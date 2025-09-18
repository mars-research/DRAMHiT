#include "tests/UniformTest.hpp"

namespace kmercounter {

extern bool clear_table;
extern ExecPhase cur_phase;
extern uint64_t HT_TESTS_NUM_INSERTS;
extern uint64_t *g_insert_durations;
extern uint64_t *g_find_durations;
extern uint64_t zipfian_iter;
extern bool stop_sync;
extern bool zipfian_finds;
extern bool zipfian_inserts;

static inline uint32_t hash_knuth(uint32_t x) { return x * 2654435761u; }

void do_uniform_batch_insertion(BaseHashTable *ht, uint64_t batch_num,
                                uint32_t batch_len, uint64_t idx) {
#if defined(CAS_NO_ABSTRACT)
  CASHashTable<KVType, ItemQueue> *cas_ht =
      static_cast<CASHashTable<KVType, ItemQueue> *>(ht);
#endif
  collector_type *const collector{};

  InsertFindArgument *items = (InsertFindArgument *)aligned_alloc(
      64, sizeof(InsertFindArgument) * config.batch_len);
  uint64_t value;
  for (unsigned int n = 0; n < batch_num; ++n) {
    for (int i = 0; i < batch_len; i++) {
      value = hash_knuth(idx);
      items[i].key = items[i].value = value;
      items[i].id = idx;
      idx++;
    }

    InsertFindArguments keypairs(items, config.batch_len);
#if defined(CAS_NO_ABSTRACT)
    cas_ht->insert_batch_inline(keypairs, collector);
#else
    ht->insert_batch(keypairs, collector);
#endif
  }

  ht->flush_insert_queue(collector);

  free(items);
}

uint64_t do_uniform_batch_find(BaseHashTable *ht, uint64_t batch_num,
                               uint32_t batch_len, uint32_t idx) {
#if defined(CAS_NO_ABSTRACT)
  CASHashTable<KVType, ItemQueue> *cas_ht =
      static_cast<CASHashTable<KVType, ItemQueue> *>(ht);
#endif
  uint64_t found = 0;
  collector_type *const collector{};
  InsertFindArgument *items = (InsertFindArgument *)aligned_alloc(
      64, sizeof(InsertFindArgument) * config.batch_len);

  FindResult *results = new FindResult[config.batch_len];

  ValuePairs vp = std::make_pair(0, results);
  uint32_t value;
  for (unsigned int n = 0; n < batch_num; ++n) {
    for (int i = 0; i < batch_len; i++) {
      value = hash_knuth(idx);
      items[i].key = value;
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

  vp.first = 0;
  while (ht->flush_find_queue(vp, collector) > 0) {
    found += vp.first;
    vp.first = 0;
  }

  free(items);

  return found;
}

OpTimings do_uniform_inserts(
    BaseHashTable *hashtable, unsigned int id,
    std::barrier<std::function<void()>> *sync_barrier) {
  if (config.insert_factor == 0) return {1, 1};

  if (id == 0) {
    cur_phase = ExecPhase::insertions;
    zipfian_inserts = false;
  }

  const uint64_t ops_per_iter = HT_TESTS_NUM_INSERTS;
  const uint64_t batches = HT_TESTS_NUM_INSERTS / config.batch_len;

  collector_type *const collector{};

  uint64_t start, end;

  for (auto j = 0u; j < config.insert_factor; j++) {
    uint64_t idx;
    idx = ops_per_iter * id;

    if (id == 0) {
      cur_phase = ExecPhase::insertions;
      zipfian_inserts = false;
    }
    sync_barrier->arrive_and_wait();

    do_uniform_batch_insertion(hashtable, batches, config.batch_len, idx);

    if (id == 0) {
      cur_phase = ExecPhase::insertions;
      zipfian_inserts = true;
      zipfian_iter = j;
    }
    sync_barrier->arrive_and_wait();

    // if (id == 0) {
    //   cur_phase = ExecPhase::none;
    // }
    // sync_barrier->arrive_and_wait();
    // // don't clear last insert iteration, or ht will be empty for finds
    // if (id == 0 && j + 1 < config.insert_factor) {
    //   hashtable->clear();
    // }
    // sync_barrier->arrive_and_wait();
  }

  uint64_t duration = 0;
  uint64_t ops = 0;
  for (int i = 0; i < config.insert_factor; i++)
    duration += g_insert_durations[i];
  ops = ops_per_iter * config.insert_factor;

  return {duration, ops};
}

OpTimings do_uniform_gets(BaseHashTable *hashtable, unsigned int id,
                          auto sync_barrier) {
  if (config.read_factor == 0) {
    return {1, 1};
  }

  if (id == 0) {
    cur_phase = ExecPhase::finds;
    zipfian_finds = false;
  }

  std::uint64_t found = 0;
  const uint64_t ops_per_iter = HT_TESTS_NUM_INSERTS;
  const uint64_t batches = ops_per_iter / config.batch_len;

  uint64_t start;
  uint64_t end;

  for (auto j = 0u; j < config.read_factor; j++) {
    uint64_t value, idx;

    idx = id * ops_per_iter;

    // All thread wait here, and record start

    if (id == 0) {
      zipfian_finds = false;
    }
    sync_barrier->arrive_and_wait();
    found = do_uniform_batch_find(hashtable, batches, config.batch_len, idx);
    if (id == 0) {
      zipfian_finds = true;
      zipfian_iter = j;
    }
    sync_barrier->arrive_and_wait();
  }

  uint64_t duration = 0;
  uint64_t ops = 0;

  for (int i = 0; i < config.read_factor; i++) duration += g_find_durations[i];
  ops = ops_per_iter * config.read_factor;

  return {duration, ops};
}

void UniformTest::run(Shard *shard, BaseHashTable *hashtable,
                      std::barrier<std::function<void()>> *sync_barrier) {
  OpTimings insert_timings{};
  OpTimings find_timings{};

  insert_timings =
      do_uniform_inserts(hashtable, shard->shard_idx, sync_barrier);
  find_timings = do_uniform_gets(hashtable, shard->shard_idx, sync_barrier);

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
