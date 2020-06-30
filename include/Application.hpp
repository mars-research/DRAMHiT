#ifndef __APPLICATION_HPP__
#define __APPLICATION_HPP__

#include "numa.hpp"

namespace kmercounter {

class Application {
  Numa *n;

 public:
  std::vector<numa_node> nodes;
  int process(int argc, char **argv);
  int spawn_shard_threads_bqueues();
  int spawn_shard_threads();

  Application() {
    this->n = new Numa();
    this->nodes = n->get_node_config();
  }
};

}  // namespace kmercounter

#endif  // __APPLICATION_HPP__
