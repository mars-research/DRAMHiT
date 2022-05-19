#include "Latency.hpp"

namespace kmercounter {
std::vector<LatencyCollector<pool_size>> collectors;
std::mutex collector_lock;
}  // namespace kmercounter
