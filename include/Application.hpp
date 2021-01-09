#ifndef __APPLICATION_HPP__
#define __APPLICATION_HPP__

#include <thread>

#include "numa.hpp"
#include "tests.hpp"

using namespace std;
namespace kmercounter {

class Application {
  Numa *n;
  NumaPolicyThreads *np;
  NumaPolicyQueues *npq;
  Tests test;
  std::thread *threads;
  Shard *shards;

  int fd;

 public:
  std::vector<numa_node> nodes;
  int process(int argc, char **argv);
  int spawn_shard_threads_bqueues();
  uint64_t* alloc_distribution();//NEW
  void free_distribution(uint64_t* mem);//NEW
  int spawn_shard_threads();
  void shard_thread(int tid);

  Application() {
    this->n = new Numa();
    this->nodes = n->get_node_config();
  }
};

}  // namespace kmercounter

#endif  // __APPLICATION_HPP__
