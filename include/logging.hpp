#ifndef LOGGER_HPP
#define LOGGER_HPP

#include <plog/Log.h>

#include <atomic>

void initializeLogger();

// Log only once.
#define PLOG_ONCE_IF(severity, condition)         \
  static std::atomic_int __plog_once_counter__{}; \
  PLOG_IF(severity, (__plog_once_counter__.fetch_add(0) == 0) && condition)
#define PLOG_WARNING_ONCE_IF(condition) PLOG_ONCE_IF(plog::warning, condition)
#define PLOG_WARNING_ONCE PLOG_WARNING_ONCE_IF(true)

#endif  // LOGGER_HPP
