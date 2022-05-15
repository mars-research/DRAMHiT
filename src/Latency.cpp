#include "Latency.hpp"

namespace kmercounter {
#ifdef LATENCY_COLLECTION
std::vector<LatencyCollector<pool_size>> collectors;
#endif
}  // namespace kvstore
