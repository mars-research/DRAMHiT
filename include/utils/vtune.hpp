#pragma once

#include <string>

#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#else
typedef int __itt_event;
#endif

namespace kmercounter {

  namespace vtune {
#ifdef WITH_VTUNE_LIB
    inline void set_threadname(std::string name) {
      __itt_thread_set_name(name.c_str());
    }

    inline __itt_event event_start(std::string name) {
      auto event =
      __itt_event_create(name.c_str(), name.size());
      __itt_event_start(event);
      return event;
    }

    inline void event_end(__itt_event event) {
      __itt_event_end(event);
    }
#else
    inline void set_threadname(std::string name) { }
    inline __itt_event event_start(std::string name) { return -1; }
    inline void event_end(__itt_event event) { }
#endif
  }
}
