#include "Latency.hpp"

namespace kvstore {
#ifdef LATENCY_COLLECTION
thread_local LatencyCollector<pool_size> collector{};
#endif
}  // namespace kvstore
