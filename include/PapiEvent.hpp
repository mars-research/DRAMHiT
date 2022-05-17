#ifndef __PAPIEVENT_HPP__
#define __PAPIEVENT_HPP__

#include <sstream>
#include <string>
#include <vector>

#include "plog/Log.h"
#include "papi.h"

namespace kmercounter {
class PapiEvent {
 public:
  int* event_set;
  int uncore_cidx;
  long long* values;
  int num_events;
  int cpu;
  std::vector<std::string> uncore_events;

  PapiEvent(int num_events) : uncore_cidx(-1), num_events(num_events) {
    event_set = new int[num_events];
    values = new long long[num_events];
    for (auto i = 0; i < num_events; i++) {
      this->event_set[i] = PAPI_NULL;
    }
  }

  int init_event(int cpu) {
    this->uncore_cidx = PAPI_get_component_index("perf_event_uncore");
    this->cpu = cpu;
    if (this->uncore_cidx < 0) {
      PLOG_ERROR.printf("perf_event_uncore component not found");
      return -EINVAL;
    }

    for (auto i = 0; i < this->num_events; i++) {
      auto retval = PAPI_create_eventset(&event_set[i]);

      if (retval != PAPI_OK) {
        PLOG_ERROR.printf("PAPI_create_eventset %d", retval);
        return -ENOENT;
      }

      // Set a component for the EventSet
      retval =
          PAPI_assign_eventset_component(this->event_set[i], this->uncore_cidx);
      if (retval != PAPI_OK) {
        PLOG_ERROR.printf("PAPI_assign_eventset_component %d", retval);
        return -ENOENT;
      }

      // we need to set to a certain cpu for uncore to work
      PAPI_cpu_option_t cpu_opt;

      cpu_opt.eventset = this->event_set[i];
      cpu_opt.cpu_num = cpu;

      retval = PAPI_set_opt(PAPI_CPU_ATTACH, (PAPI_option_t*)&cpu_opt);
      if (retval != PAPI_OK) {
        PLOG_ERROR.printf("this test; trying to PAPI_CPU_ATTACH; need to run as root %d",
            retval);
      }
    }
    return 0;
  }

  int add_event(const std::string& event_name, const std::string& uncore_base) {
    auto retval = 0;
    for (auto i = 0; i < this->num_events; i++) {
      std::ostringstream out;
      out << uncore_base << i << "::" << event_name;

      std::string uncore_event = out.str();

      PLOG_INFO.printf("uncore event %s ", uncore_event.c_str());
      this->uncore_events.push_back(uncore_event);
      retval |= PAPI_add_named_event(event_set[i], uncore_event.c_str());
      if (retval != PAPI_OK) {
        PLOG_INFO.printf("failed to add evnt %s", uncore_event.c_str());
        break;
      }
    }
    return retval;
  }

  int start() {
    auto retval = 0;
    // Start PAPI
    for (auto i = 0; i < this->num_events; i++) {
      retval |= PAPI_start(this->event_set[i]);
      if (retval != PAPI_OK) {
        PLOG_ERROR.printf("Error starting cbox %d | retval %d", i, retval);
      }
    }
    return retval;
  }

  std::uint64_t stop() {
    auto retval = 0;
    std::uint64_t sum{};
    // Stop PAPI
    for (auto i = 0; i < uncore_events.size(); i++) {
      retval |= PAPI_stop(this->event_set[i], &values[i]);
      if (retval != PAPI_OK) {
        PLOG_ERROR.printf("PAPI_stop %d", retval);
      }
      PLOG_INFO.printf("=>%s:cpu %d %lld", this->uncore_events[i].c_str(), this->cpu,
             values[i]);
      sum += values[i];
    }
    PLOG_INFO.printf("--------------------------------------------");
    PLOG_INFO.printf("TOTAL(cpu %d)  %s: %llu (%f)", this->cpu,
           this->uncore_events[0].c_str(), sum,
           static_cast<float>(sum) / 1000000.0);
    PLOG_INFO.printf("--------------------------------------------");
    return sum;
  }
};
}  // namespace kmercounter
#endif  // __PAPIEVENT_HPP__
