#ifndef __PAPIEVENT_HPP__
#define __PAPIEVENT_HPP__

#include <vector>
#include <sstream>
#include <string>
#include "papi.h"
#include "dbg.hpp"

namespace kmercounter {
  class PapiEvent {
    public:
      int *event_set;
      int uncore_cidx;
	    long long *values;
      int num_events;
      std::vector<std::string> uncore_events;

      PapiEvent(int num_events) : uncore_cidx(-1), num_events(num_events) {
        event_set = new int [num_events];
        values = new long long [num_events];
        for (auto i = 0; i < num_events; i++) {
          this->event_set[i] = PAPI_NULL;
        }
      }

      int init_event(int cpu) {
        this->uncore_cidx = PAPI_get_component_index("perf_event_uncore");
        if (this->uncore_cidx < 0) {
          dbg("perf_event_uncore component not found\n");
          return -EINVAL;
        }

        for (auto i = 0; i < this->num_events; i++) {
          auto retval = PAPI_create_eventset(&event_set[i]);

          if (retval != PAPI_OK) {
            dbg("PAPI_create_eventset %d", retval);
            return -ENOENT;
          }

          // Set a component for the EventSet
          retval = PAPI_assign_eventset_component(this->event_set[i], this->uncore_cidx);
          if (retval != PAPI_OK) {
            dbg("PAPI_assign_eventset_component %d", retval);
            return -ENOENT;
          }

          // we need to set to a certain cpu for uncore to work
          PAPI_cpu_option_t cpu_opt;

          cpu_opt.eventset = this->event_set[i];
          cpu_opt.cpu_num = cpu;

          retval = PAPI_set_opt(PAPI_CPU_ATTACH,(PAPI_option_t*)&cpu_opt);
          if (retval != PAPI_OK) {
                dbg("this test; trying to PAPI_CPU_ATTACH; need to run as root %d",
                retval);
          }
        }
        return 0;
      }
      
      int add_event(std::string&& event_name, std::string&& uncore_base) {
        auto retval = 0;
        for (auto i = 0; i < this->num_events; i++) {
          std::ostringstream out;
          out << uncore_base << i << "::" << event_name;

          std::string uncore_event = out.str();
          //std::string uncore_event = uncore_base + i + std::string("::") + event_name;

          printf("uncore event %s \n", uncore_event.c_str());
          this->uncore_events.push_back(uncore_event);
          retval |= PAPI_add_named_event(event_set[i], uncore_event.c_str());
          if (retval != PAPI_OK) {
            printf("failed to add evnt %s\n", uncore_event.c_str());
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
          if ( retval != PAPI_OK ) {
            printf("Error starting cbox %d\n",i);
            dbg("PAPI_start %d", retval );
          }
        }
        return retval;
      }

      void stop() {
        auto retval = 0;
        // Stop PAPI
        for(auto i=0;i < this->num_events; i++) {
          retval |= PAPI_stop( this->event_set[i], &values[i] );
          if ( retval != PAPI_OK ) {
            dbg("PAPI_stop %d", retval );
          }
			    printf("=>%s %lld\n", this->uncore_events[i].c_str() ,values[i]);
        }
      }
  };
}
#endif  // __PAPIEVENT_HPP__
