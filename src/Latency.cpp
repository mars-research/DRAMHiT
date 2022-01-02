#include "Latency.hpp"

namespace kvstore {
#ifdef LATENCY_COLLECTION
thread_local LatencyCollector<512> collector{};
#endif
}  // namespace kvstore
