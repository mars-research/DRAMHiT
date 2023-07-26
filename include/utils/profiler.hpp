#ifndef UTILS_PROFILER_HPP
#define UTILS_PROFILER_HPP

#include <string>
#include <string_view>

#include "plog/Log.h"
#include "sync.h"

#ifdef ENABLE_HIGH_LEVEL_PAPI
#include <papi.h>
#endif

#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

namespace kmercounter {

class Profiler {
 public:
  Profiler(std::string_view name) : name_(name) {
#ifdef WITH_VTUNE_LIB
    event_ = __itt_event_create(name_.c_str(), name_.length());
    __itt_event_start(event_);
#endif

#ifdef ENABLE_HIGH_LEVEL_PAPI
    papi_check(PAPI_hl_region_begin(name));
#endif

    rdtsc_start_ = RDTSC_START();
  }

  uint64_t end() {
    const auto duration = RDTSCP() - rdtsc_start_;

#ifdef WITH_VTUNE_LIB
    __itt_event_end(event_);
#endif

#ifdef ENABLE_HIGH_LEVEL_PAPI
    papi_check(PAPI_hl_region_end(name_.c_str()));
#endif

    return duration;
  }

 private:
  void papi_check(int code) {
    if (code != PAPI_OK) {
      PLOG_ERROR << "PAPI call failed with code " << code;
      std::terminate();
    }
  }

  // Name of the region.
  std::string name_;
  // RDTSC at the start of the duration.
  uint64_t rdtsc_start_;
#ifdef WITH_VTUNE_LIB
  __itt_event event_;
#endif
};

}  // namespace kmercounter

#endif  // UTILS_PROFILER_HPP
