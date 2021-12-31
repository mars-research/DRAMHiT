#ifndef __APPLICATION_HPP__
#define __APPLICATION_HPP__

#include <thread>

#include "MsrHandler.hpp"
#include "numa.hpp"
#include "tests.hpp"

using namespace std;
namespace kmercounter {

class Application {
  Numa *n;
  NumaPolicyThreads *np;
  NumaPolicyQueues *npq;
  Tests test;
  std::vector<std::thread> threads;
  Shard *shards;
  MsrHandler *msr_ctrl;

 public:
  std::vector<numa_node> nodes;
  int process(int argc, char **argv);
  int spawn_shard_threads_bqueues();
  int spawn_shard_threads();
  void shard_thread(int tid, bool mainthread);

  Application() {
    this->n = new Numa();
    this->nodes = n->get_node_config();
    this->msr_ctrl = new MsrHandler();
  }
};

}  // namespace kmercounter

#endif  // __APPLICATION_HPP__
