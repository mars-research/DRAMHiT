#ifndef __NUMA_HPP__
#define __NUMA_HPP__

#include <numa.h>

#include <algorithm>
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <iostream>
#include <map>
#include <set>
#include <vector>

using namespace std;

namespace kmercounter {
constexpr long long RESET_MASK(int x) { return ~(1LL << (x)); }

typedef struct numa_node {
  unsigned int id;
  unsigned long cpu_bitmask;
  unsigned int num_cpus;
  std::vector<uint32_t> cpu_list;
} numa_node_t;

class Numa {
 public:
  Numa() : numa_present(!numa_available()) {
    if (numa_present) {
      max_node = numa_max_node();
      max_possible_node = numa_max_possible_node();
      num_possible_nodes = numa_num_possible_nodes();
      num_configured_nodes = numa_num_configured_nodes();

      num_configured_cpus = numa_num_configured_cpus();
      num_possible_cpus = numa_num_possible_cpus();
      extract_numa_config();
      print_numa_nodes();
    }
  }

  inline bool is_numa_present(void) const { return numa_present; }

  friend std::ostream &operator<<(std::ostream &os, const Numa &n) {
    printf("NUMA available: %s\n", n.numa_present ? "true" : "false");
    printf("Node config:\n");
    printf("\tnuma_num_possible_nodes: %d\n", n.num_possible_nodes);
    printf("\tnuma_num_configured_nodes: %d\n", n.num_configured_nodes);
    printf("CPU config:\n");
    printf("\tnuma_num_possible_cpus: %d\n", n.num_possible_cpus);
    printf("\tnuma_num_configured_cpus: %d\n", n.num_configured_cpus);
    return os;
  }

  const int get_num_nodes() const { return num_configured_nodes; }

  const int get_num_total_cpus() {
    int num_total_cpus = 0;
    for (auto i : nodes) num_total_cpus += i.cpu_list.size();
    return num_total_cpus;
  }

  void print_numa_nodes(void) {
    std::for_each(nodes.begin(), nodes.end(), [](auto &node) {
      printf("Node: %d cpu_bitmask: 0x%08lx | num_cpus: %d\n\t", node.id,
             node.cpu_bitmask, node.num_cpus);
      std::for_each(node.cpu_list.begin(), node.cpu_list.end(),
                    [](uint32_t &cpu) { printf("%d ", cpu); });
      printf("\n");
    });
  }

  const std::vector<numa_node_t> &get_node_config(void) const { return nodes; }

 private:
  int numa_present;
  int max_node;
  int max_possible_node;
  int num_possible_nodes;
  int num_configured_nodes;
  int num_configured_cpus;
  int num_possible_cpus;
  int num_nodes;
  std::vector<numa_node_t> nodes;

  int extract_numa_config(void) {
    struct bitmask *cm = numa_allocate_cpumask();
    auto ret = 0;

    for (auto n = 0; n < num_configured_nodes; n++) {
      numa_node_t _node;
      if ((ret = numa_node_to_cpus(n, cm))) {
        fprintf(stderr, "bitmask is not long enough\n");
        return ret;
      }

      _node.cpu_bitmask = *(cm->maskp);
      _node.num_cpus = __builtin_popcountl(_node.cpu_bitmask);
      _node.id = n;

      // extract all the cpus from the bitmask
      while (_node.cpu_bitmask) {
        // cpu number starts from 0, ffs starts from 1.
        unsigned long c = __builtin_ffsll(_node.cpu_bitmask) - 1;
        _node.cpu_bitmask &= RESET_MASK(c);
        _node.cpu_list.push_back(c);
      }
      append_node(_node);
    }

    numa_free_cpumask(cm);
    return ret;
  }

  void append_node(numa_node_t &node) { nodes.push_back(node); }
};

/* Numa policy for when using producer/consumer queues.
- PROD_CONS_SEPARATE_NODES: This mode is to stress the framework as running
producers and consumers on different numa nodes
- PROD_CONS_SAME_NODES: Run producers and consumers  on the same numa node. Of
course, this is bounded by the number of cpus available on a numa node. prod +
cons <= node_x_cpus
- PROD_CONS_MIXED_MODE: the affinity does not matter. Just run it as long as you
can tie this thread to a cpu.
 */
enum numa_policy_queues {
  PROD_CONS_SEQUENTIAL = 1,
  PROD_CONS_SEPARATE_NODES = 2
};

class NumaPolicyQueues : public Numa {
 public:
  NumaPolicyQueues(int num_prod, int num_cons, numa_policy_queues npq) {
    this->config_num_prod = num_prod;
    this->config_num_cons = num_cons;
    this->nodes = Numa::get_node_config();
    this->npq = npq;
    this->init_unassigned_cpus_list();
    this->generate_cpu_lists();
    std::cout << *this << std::endl;
  }

  friend std::ostream &operator<<(std::ostream &os, const NumaPolicyQueues &n) {
    std::cout << "assigned_cpu_list_producers: ";
    for (auto i : n.assigned_cpu_list_producers) {
      std::cout << i << ' ';
    }
    std::cout << "\n";
    std::cout << "assigned_cpu_list_consumers: ";
    for (auto i : n.assigned_cpu_list_consumers) {
      std::cout << i << ' ';
    }
    std::cout << "\n";
    return os;
  }

  std::vector<uint32_t> get_assigned_cpu_list_producers() {
    // std::cout << *this << std::endl;
    return this->assigned_cpu_list_producers;
  }

  std::vector<uint32_t> get_assigned_cpu_list_consumers() {
    // std::cout << *this << std::endl;
    return this->assigned_cpu_list_consumers;
  }

  std::vector<uint32_t> get_unassigned_cpu_list() {
    std::vector<uint32_t> v(this->unassigned_cpu_list.begin(),
                            this->unassigned_cpu_list.end());
    return v;
  }

  // TODO There is definitely a less ugly way to do this
  std::tuple<uint32_t, uint32_t> get_num_nodes_and_cpus_reqd(
      uint32_t num_threads) {
    uint32_t num_nodes_reqd = 1;
    uint32_t num_cpus_reqd = 0;
    for (numa_node_t n : this->nodes) {
      for (uint32_t c : n.cpu_list) {
        (void)c;
        num_cpus_reqd += 1;
        num_threads--;
        if (num_threads == 0)
          return std::make_tuple(num_nodes_reqd, num_cpus_reqd);
      }
      num_nodes_reqd += 1;
    }
    // shouldn't get here
    return std::make_tuple(0, 0);
  }

 private:
  uint32_t config_num_prod;
  uint32_t config_num_cons;
  numa_policy_queues npq;
  std::vector<numa_node_t> nodes;
  std::vector<uint32_t> assigned_cpu_list_producers;
  std::vector<uint32_t> assigned_cpu_list_consumers;
  std::set<uint32_t> unassigned_cpu_list;

  void generate_cpu_lists() {
    uint32_t total_threads = this->config_num_cons + this->config_num_prod;

    assert(total_threads <= static_cast<uint32_t>(Numa::get_num_total_cpus()));

    if (this->npq == PROD_CONS_SEQUENTIAL) {
      uint32_t node_idx_ctr = 0, cpu_idx_ctr = 0;

      for (auto i = 0u; i < this->config_num_prod; i++) {
        uint32_t cpu_assigned = nodes[node_idx_ctr].cpu_list[cpu_idx_ctr];
        this->assigned_cpu_list_producers.push_back(cpu_assigned);
        this->unassigned_cpu_list.erase(cpu_assigned);
        cpu_idx_ctr += 1;
        if (cpu_idx_ctr == nodes[node_idx_ctr].cpu_list.size()) {
          node_idx_ctr += 1;
          cpu_idx_ctr = 0;
        }
      }

      for (auto i = 0u; i < this->config_num_cons; i++) {
        uint32_t cpu_assigned = nodes[node_idx_ctr].cpu_list[cpu_idx_ctr];
        this->assigned_cpu_list_consumers.push_back(cpu_assigned);
        this->unassigned_cpu_list.erase(cpu_assigned);
        cpu_idx_ctr += 1;
        if (cpu_idx_ctr == nodes[node_idx_ctr].cpu_list.size()) {
          node_idx_ctr += 1;
          cpu_idx_ctr = 0;
        }
      }
      return;
    }

    if (this->npq == PROD_CONS_SEPARATE_NODES) {
      uint32_t node_idx_ctr = 0, cpu_idx_ctr = 0;
      uint32_t num_nodes = static_cast<uint32_t>(Numa::get_num_nodes());

      auto prod_config = get_num_nodes_and_cpus_reqd(this->config_num_prod);
      auto cons_config = get_num_nodes_and_cpus_reqd(this->config_num_cons);

      /* check nodes required vs. available */
      std::cout << "prod_config: "
                << "num_nodes_reqd: " << std::get<0>(prod_config) << ", "
                << "num_cpus_reqd: " << std::get<1>(prod_config) << "\n";
      std::cout << "cons_config: "
                << "num_nodes_reqd: " << std::get<0>(cons_config) << ", "
                << "num_cpus_reqd: " << std::get<1>(cons_config) << "\n";
      assert(std::get<0>(prod_config) + std::get<0>(cons_config) <= num_nodes);

      for (auto i = 0u; i < this->config_num_prod; i++) {
        uint32_t cpu_assigned = nodes[node_idx_ctr].cpu_list[cpu_idx_ctr];
        this->assigned_cpu_list_producers.push_back(cpu_assigned);
        this->unassigned_cpu_list.erase(cpu_assigned);
        cpu_idx_ctr += 1;
        if (cpu_idx_ctr == nodes[node_idx_ctr].cpu_list.size()) {
          // break if we are done with producers
          if (cpu_idx_ctr == this->config_num_prod) break;
          node_idx_ctr += 1;
          cpu_idx_ctr = 0;
        }
      }

      node_idx_ctr += 1;  // go to next node
      cpu_idx_ctr = 0;    // first cpu idx of next node
      for (auto i = 0u; i < this->config_num_cons; i++) {
        uint32_t cpu_assigned = nodes[node_idx_ctr].cpu_list[cpu_idx_ctr];
        this->assigned_cpu_list_consumers.push_back(cpu_assigned);
        this->unassigned_cpu_list.erase(cpu_assigned);
        cpu_idx_ctr += 1;
        if (cpu_idx_ctr == nodes[node_idx_ctr].cpu_list.size()) {
          // break if we are done with consumers
          if (cpu_idx_ctr == this->config_num_cons) break;
          node_idx_ctr += 1;
          cpu_idx_ctr = 0;
        }
      }
      return;
    }
  }

  void init_unassigned_cpus_list() {
    for (numa_node_t n : this->nodes)
      for (uint32_t c : n.cpu_list) this->unassigned_cpu_list.insert(c);
  }
};

/* Numa policy when using just a "number of threads" assignment */
enum numa_policy_threads {
  THREADS_SPLIT_SEPARATE_NODES = 1,
  THREADS_ASSIGN_SEQUENTIAL = 2
};

class NumaPolicyThreads : public Numa {
 public:
  NumaPolicyThreads(int num_threads, numa_policy_threads np) {
    this->config_num_threads = num_threads;
    this->nodes = Numa::get_node_config();
    this->np = np;
    this->init_unassigned_cpus_list();
    this->generate_cpu_list();
  }

  friend std::ostream &operator<<(std::ostream &os,
                                  const NumaPolicyThreads &n) {
    std::cout << "assigned cpu list: \n";
    for (auto i : n.assigned_cpu_list) {
      std::cout << i << ' ';
    }
    std::cout << "\n";
    return os;
  }

  std::vector<uint32_t> get_assigned_cpu_list() {
    // std::cout << *this << std::endl;
    return this->assigned_cpu_list;
  }

  std::vector<uint32_t> get_unassigned_cpu_list() {
    std::vector<uint32_t> v(this->unassigned_cpu_list.begin(),
                            this->unassigned_cpu_list.end());
    return v;
  }

 private:
  uint32_t config_num_threads;
  numa_policy_threads np;
  std::vector<numa_node_t> nodes;
  std::vector<uint32_t> assigned_cpu_list;
  std::set<uint32_t> unassigned_cpu_list;

  void generate_cpu_list() {
    assert(this->config_num_threads <=
           static_cast<uint32_t>(Numa::get_num_total_cpus()));

    if (this->np == THREADS_SPLIT_SEPARATE_NODES) {
      int num_nodes = Numa::get_num_nodes();
      uint32_t node_idx_ctr = 0, cpu_idx_ctr = 0, last_cpu_idx = 0;
      uint32_t threads_per_node =
          static_cast<int>(this->config_num_threads / num_nodes);
      uint32_t threads_per_node_spill =
          static_cast<int>(this->config_num_threads % num_nodes);

      for (auto i = 0u; i < threads_per_node * num_nodes; i++) {
        uint32_t cpu_assigned = nodes[node_idx_ctr].cpu_list[cpu_idx_ctr];
        this->assigned_cpu_list.push_back(cpu_assigned);
        this->unassigned_cpu_list.erase(cpu_assigned);
        cpu_idx_ctr += 1;
        if (cpu_idx_ctr == threads_per_node) {
          node_idx_ctr++;
          last_cpu_idx = cpu_idx_ctr;
          cpu_idx_ctr = 0;
        }
      }

      node_idx_ctr = 0;
      for (auto i = 0u; i < threads_per_node_spill; i++) {
        uint32_t cpu_assigned = nodes[node_idx_ctr].cpu_list[last_cpu_idx];
        this->assigned_cpu_list.push_back(cpu_assigned);
        this->unassigned_cpu_list.erase(cpu_assigned);
        node_idx_ctr += 1;
        cpu_idx_ctr += 1;  // not necessary
      }

      return;
    }

    if (this->np == THREADS_ASSIGN_SEQUENTIAL) {
      uint32_t node_idx_ctr = 0, cpu_idx_ctr = 0;

      for (auto i = 0u; i < this->config_num_threads; i++) {
        uint32_t cpu_assigned = nodes[node_idx_ctr].cpu_list[cpu_idx_ctr];
        this->assigned_cpu_list.push_back(cpu_assigned);
        this->unassigned_cpu_list.erase(cpu_assigned);
        cpu_idx_ctr += 1;
        if (cpu_idx_ctr == nodes[node_idx_ctr].cpu_list.size()) {
          node_idx_ctr += 1;
          cpu_idx_ctr = 0;
        }
      }
      return;
    }
  }

  void init_unassigned_cpus_list() {
    for (numa_node_t n : this->nodes)
      for (uint32_t c : n.cpu_list) this->unassigned_cpu_list.insert(c);
  }
};

}  // namespace kmercounter

#endif  // __NUMA_HPP__
