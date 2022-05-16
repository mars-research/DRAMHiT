#pragma once

#include "queue.hpp"
#include <tuple>
#include <map>
#include <assert.h>

namespace kmercounter {

class SectionQueue;

extern const uint64_t CACHELINE_SIZE;
extern const uint64_t CACHELINE_MASK;
extern const uint64_t PAGESIZE;

static const uint64_t SECTION_SIZE = 4096 * 1;

struct SectionQueueInner {
    struct prod_queue {
      data_t *enqPtr;
      data_t * volatile deqLocalPtr;
      data_t *data;
      data_t *queue_end;
    };

    struct cons_queue {
      data_t *deqPtr;
      data_t * volatile enqLocalPtr;
      data_t *data;
      data_t *queue_end;
    };

    struct prod_cons_shared {
      CACHE_ALIGNED data_t * volatile enqSharedPtr;
      data_t * volatile deqSharedPtr;
#ifdef CALC_STATS
      CACHE_ALIGNED size_t numEnqueueSpins;
      CACHE_ALIGNED size_t numDequeueSpins;
#endif
    };

    data_t *QUEUE;
    data_t *QUEUE_END;
    size_t num_sections;
    size_t queue_size;
    size_t section_size;
    struct prod_queue *pq;
    struct cons_queue *cq;
    struct prod_cons_shared *pcq;

    void dump(void) {
      PLOGI.printf("{ prod state }");
      PLOGI.printf("enqPtr:          %p", pq->enqPtr);
      PLOGI.printf("deqLocalPtr:       %p", pq->deqLocalPtr);

      PLOGI.printf("{ cons state }");
      PLOGI.printf("deqPtr:          %p", cq->deqPtr);
      PLOGI.printf("enqLocalPtr:       %p", cq->enqLocalPtr);
      PLOGI.printf("enqSharedPtr:       %p", pcq->enqSharedPtr);
      PLOGI.printf("deqSharedPtr:    %p", pcq->deqSharedPtr);

      PLOGI.printf("QUEUE:      %p", QUEUE);
      PLOGI.printf("QUEUE_END:      %p", QUEUE_END);
      PLOGI.printf("queue_size:     0x%lx", queue_size);
      PLOGI.printf("queue_mask:     0x%lx", ~queue_size);
      PLOGI.printf("QUEUE_SECTION_SIZE:  0x%lx", section_size);
    }

    explicit SectionQueueInner(size_t queue_size, struct prod_queue *pq, struct
        cons_queue *cq, struct prod_cons_shared *pcq) {
      this->queue_size = queue_size;
      this->QUEUE = pq->data;
      this->QUEUE_END = pq->data + queue_size / sizeof(data_t);
      cq->queue_end = pq->queue_end = this->QUEUE_END;
      this->section_size = kmercounter::SECTION_SIZE;
      this->num_sections = this->queue_size / this->section_size;
      this->pq = pq;
      this->cq = cq;
      this->pcq = pcq;
    }
};

class SectionQueue {
  public:
    typedef struct SectionQueueInner queue_t;
    typedef struct SectionQueueInner::prod_queue prod_queue_t;
    typedef struct SectionQueueInner::cons_queue cons_queue_t;
    typedef struct SectionQueueInner::prod_cons_shared pc_queue_t;

    prod_queue_t **all_pqueues;
    cons_queue_t **all_cqueues;
    pc_queue_t **all_pc_queues;
    static const uint64_t BQ_MAGIC_64BIT = 0xD221A6BE96E04673UL;
    static const uint64_t SECTION_MASK = SECTION_SIZE - 1;

    size_t queue_size;

  private:
    size_t num_sections;
    size_t section_size;
    uint32_t nprod;
    uint32_t ncons;

    std::map<std::tuple<int, int>, prod_queue_t*> pqueue_map;
    std::map<std::tuple<int, int>, cons_queue_t*> cqueue_map;
    std::map<std::tuple<int, int>, pc_queue_t*> pc_queue_map;

    queue_t ***queues;

    void init_prod_queues() {
      // map queues and producer_metadata
      for (auto p = 0u; p < nprod; p++) {
        // Queue Allocation
        auto pqueues = (prod_queue_t *)utils::zero_aligned_alloc(
            PAGESIZE, ncons * sizeof(prod_queue_t));
        all_pqueues[p] = pqueues;
        for (auto c = 0u; c < ncons; c++) {
          prod_queue_t *pq = &pqueues[c];
          pqueue_map.insert({std::make_tuple(p, c), pq});
        }
      }
    }

    void init_cons_queues() {
      // map queues and consumer_metadata
      for (auto c = 0u; c < ncons; c++) {
        auto cqueues = (cons_queue_t *)utils::zero_aligned_alloc(
            PAGESIZE, nprod * sizeof(cons_queue_t));
        all_cqueues[c] = cqueues;
        for (auto p = 0u; p < nprod; p++) {
          cons_queue_t *cq = &cqueues[p];
          cqueue_map.insert({std::make_tuple(p, c), cq});
        }
      }
    }

    void init_pc_shared_queues(void) {
      // map queues and consumer_shared_metadata
      for (auto p = 0u; p < nprod; p++) {
        auto pc_queues = (pc_queue_t *)utils::zero_aligned_alloc(
            FIPC_CACHE_LINE_SIZE, ncons * sizeof(pc_queue_t));
        all_pc_queues[p] = pc_queues;
        for (auto c = 0u; c < ncons; c++) {
          pc_queue_t *pc = &pc_queues[c];
          pc_queue_map.insert({std::make_tuple(p, c), pc});
        }
      }
    }

    void init_data(NumaPolicyQueues *npq) {
      auto qdata_sz = nprod * ncons * this->queue_size;
      std::map<uint32_t, std::vector<uint32_t>> node_map;

      auto get_current_node = [](uint32_t cpu) { return numa_node_of_cpu(cpu); };

      for (auto cpu: npq->get_assigned_cpu_list_producers()) {
        auto cpu_node = get_current_node(cpu);
        if (node_map.find(cpu_node) != node_map.end()) {
          node_map[cpu_node].push_back(cpu);
        } else {
          node_map[cpu_node] = std::vector<uint32_t>();
          node_map[cpu_node].push_back(cpu);
        }
      }
      std::ostringstream os;
      for (auto nodes: node_map) {
        os << "node " << nodes.first << "\n\t{ ";
        for (auto cpu: nodes.second) {
          os << cpu << ", ";
        }
        os << " }\n";
      }
      PLOGI << os.str();
      std::map<uint32_t, char*> node_memmap;

      auto mbind_buffer_local = [](void *buf, ssize_t sz, uint32_t node) {
        unsigned long nodemask[4096] = { 0 };
        ssize_t page_size = PAGESIZE;
        nodemask[0] = 1 << node;
        PLOGV.printf("nodemask %x", nodemask[0]);
        long ret =
            mbind(buf, std::max(sz, page_size), MPOL_BIND, nodemask, 4096, MPOL_MF_MOVE | MPOL_MF_STRICT);
        if (ret < 0) {
          PLOGE.printf("mbind failed! ret %d (errno %d)", ret, errno);
        }
        return ret;
      };

      for (auto nodes: node_map) {
        auto num_queues_in_node = nodes.second.size() * ncons;
        char *data =
            (char *)utils::zero_aligned_alloc(1 << 21, this->queue_size * num_queues_in_node);
        node_memmap[nodes.first] = data;
        mbind_buffer_local(data, this->queue_size * num_queues_in_node, nodes.first);
      }

      for (auto p = 0u; p < nprod; p++) {
        uint32_t node_for_prod = get_current_node(npq->get_assigned_cpu_list_producers()[p]);
        char *qdata = node_memmap[node_for_prod];
        node_memmap[node_for_prod] = qdata + ncons * this->queue_size;

        for (auto c = 0u; c < ncons; c++) {
          data_t *data = (data_t*) (qdata + c * this->queue_size);
          auto it = pqueue_map.find(std::make_tuple(p, c));
          if (it != pqueue_map.end()) {
            prod_queue_t *pq = pqueue_map.at(std::make_tuple(p, c));
            cons_queue_t *cq = cqueue_map.at(std::make_tuple(p, c));
            pc_queue_t *pcq = pc_queue_map.at(std::make_tuple(p, c));
            pq->data = cq->data = data;
            pq->enqPtr = pq->data;
            pq->deqLocalPtr = data;

            cq->deqPtr = data;
            cq->enqLocalPtr = data;

            pcq->enqSharedPtr = data;
            pcq->deqSharedPtr = data;

            PLOG_INFO.printf("enqPtr %p | deqPtr %p | data %p | section_mask %lx",
                pq->enqPtr, cq->deqPtr, cq->data, SECTION_MASK);
          } else {
            for (auto &e : pqueue_map) {
              auto &[p, c] = e.first;
              PLOGI.printf("p %u c %u pq %p", p, c, e.second);
            }
            exit(-1);
          }
        }
      }
    }

    void teardown_prod_queues() {
      for (auto p = 0u; p < nprod; p++) {
        free(this->all_pqueues[p]);
      }
    }
    void teardown_cons_queues() {
      for (auto c = 0u; c < ncons; c++) {
        auto cq = this->all_cqueues[c];
        free(cq->data);
      }
    }

  public:
    void dump_queue_map() {
      PLOGI.printf("pqueue_map");
      for (auto &e : pqueue_map) {
        auto &[p, c] = e.first;
        PLOGI.printf("p %u c %u pq %p", p, c, e.second);
      }

      PLOGI.printf("cqueue_map");
      for (auto &e : cqueue_map) {
        auto &[p, c] = e.first;
        PLOGI.printf("p %u c %u pq %p", p, c, e.second);
      }
    }

    explicit SectionQueue(uint32_t nprod, uint32_t ncons, size_t num_sections, NumaPolicyQueues *npq) {
      printf("%s, numsections %zu\n", __func__, num_sections);
      assert((num_sections & (num_sections - 1)) == 0);
      this->num_sections = num_sections;

      this->queue_size = SECTION_SIZE * this->num_sections;
      this->section_size = this->queue_size / this->num_sections;
      this->nprod = nprod;
      this->ncons = ncons;

      this->all_pqueues = (prod_queue_t **)utils::zero_aligned_alloc(
        FIPC_CACHE_LINE_SIZE, nprod * sizeof(prod_queue_t));

      this->all_cqueues = (cons_queue_t **)utils::zero_aligned_alloc(
        FIPC_CACHE_LINE_SIZE, ncons * sizeof(cons_queue_t));

      this->all_pc_queues = (pc_queue_t **)utils::zero_aligned_alloc(
        FIPC_CACHE_LINE_SIZE, nprod * sizeof(pc_queue_t));

      this->init_prod_queues();
      this->init_cons_queues();
      this->init_pc_shared_queues();
      this->init_data(npq);

      this->queues = (queue_t ***)calloc(1, nprod * sizeof(queue_t*));
      for (auto p = 0u; p < nprod; p++) {
        this->queues[p] = (queue_t **)calloc(1, ncons * sizeof(queue_t*));
        PLOGD.printf("allocating %zu bytes %p", ncons * sizeof(queue_t*), this->queues[p]);
        for (auto c = 0u; c < ncons; c++) {
          PLOGD.printf("queues[%d][%d] %p", p, c, &queues[p][c]);
          prod_queue_t *pq = pqueue_map.at(std::make_tuple(p, c));
          cons_queue_t *cq = cqueue_map.at(std::make_tuple(p, c));
          pc_queue_t *pcq = pc_queue_map.at(std::make_tuple(p, c));
          queues[p][c] = new queue_t(queue_size, pq, cq, pcq);
        }
      }
      queues[0][0]->dump();
    }

     inline int
       enqueue(prod_queue_t *pq, uint32_t p, uint32_t c, data_t value) {
      *pq->enqPtr = value;
      pq->enqPtr += 1;

      if (((data_t)pq->enqPtr & SECTION_MASK) == 0) {

        if (pq->enqPtr == pq->queue_end) {
          pq->enqPtr = pq->data;
        }

        {
          pc_queue_t *pcq = &all_pc_queues[p][c];
          while (pq->enqPtr == pq->deqLocalPtr) {
            pq->deqLocalPtr = pcq->deqSharedPtr;
#ifdef CALC_STATS
            pcq->numEnqueueSpins++;
#endif
            asm volatile("pause");
          }
          pcq->enqSharedPtr = pq->enqPtr;
        }
      }
      return SUCCESS;
    }

    inline int
      dequeue(cons_queue_t *cq, uint32_t p, uint32_t c, data_t *value) {
      if (((data_t)cq->deqPtr & SECTION_MASK) == 0) {
        if (cq->deqPtr == cq->queue_end) {
          cq->deqPtr = cq->data;
        }

        {
          pc_queue_t *pcq = &all_pc_queues[p][c];
          pcq->deqSharedPtr = cq->deqPtr;
          while (cq->deqPtr == cq->enqLocalPtr) {
            cq->enqLocalPtr = pcq->enqSharedPtr;
#ifdef CALC_STATS
            pcq->numDequeueSpins++;
#endif
            //asm volatile("pause");
            return RETRY;
          }
        }
      }
      *value = *((data_t *) cq->deqPtr);
      cq->deqPtr += 1;

      return SUCCESS;
    }

    void dump_stats(uint32_t p, uint32_t c) {
      auto cq = &all_cqueues[c][p];
      auto pcq = &all_pc_queues[p][c];
#ifdef CALC_STATS
      printf("[%u][%u] enq spins %lu | numdequeue spins %lu | enqLocalPtr %p\n",
            p, c, pcq->numEnqueueSpins, pcq->numDequeueSpins, cq->enqLocalPtr);
#endif
    }

    inline void prefetch_new(prod_queue_t *pq, bool is_prod)  {
      if (((uint64_t)pq->enqPtr & CACHELINE_MASK) == 0) {
        __builtin_prefetch(pq->enqPtr + 8, 1, 3);
      }
    }

    inline void prefetch(uint32_t p, uint32_t c, bool is_prod)  {
      if (is_prod) {
        auto nc = ((c + 1) >= ncons) ? 0 : (c + 1);
        //auto nc1 = ((nc + 1) >= ncons) ? 0 : (nc + 1);
        auto pq = &all_pqueues[p][nc];
        if (((uint64_t)pq->enqPtr & CACHELINE_MASK) == 0) {
          __builtin_prefetch(pq->enqPtr + 8, 1, 3);
        }
        //auto pq1 = &all_pqueues[p][nc1];
        //__builtin_prefetch(pq1, 1, 3);
      } else {
        auto np = ((p + 1) >= nprod) ? 0 : (p + 1);
        auto np1 = ((np + 1) >= nprod) ? 0 : (np + 1);
        auto cq1 = &all_cqueues[c][np1];
        __builtin_prefetch(cq1, 1, 3);

        auto cq = &all_cqueues[c][np];
        auto addr = cq->deqPtr;
        __builtin_prefetch(addr +  0, 1, 3);
        __builtin_prefetch(addr +  8, 1, 3);
      }
    }

    inline void push_done(uint32_t p, uint32_t c) {
      //PLOGD.printf("PUSH DONE");
      auto pcq = &this->all_pc_queues[p][c];
      auto pq = &this->all_pqueues[p][c];
      enqueue(pq, p, c, BQ_MAGIC_64BIT);
      pcq->enqSharedPtr = (data_t*)0xdeadbeef;
    }

    void pop_done(uint32_t p, uint32_t c) {
      auto cq = &this->all_cqueues[c][p];
      //cq->pop_done = true;
    }

    ~SectionQueue() {
      teardown_prod_queues();
      teardown_cons_queues();
    }
};
}
