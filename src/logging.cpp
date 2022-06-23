#include "logging.hpp"

#include <plog/Appenders/ColorConsoleAppender.h>
#include <plog/Appenders/RollingFileAppender.h>
#include <plog/Formatters/TxtFormatter.h>
#include <plog/Init.h>
#include <plog/Log.h>

void initializeLogger() {
  static plog::RollingFileAppender<plog::TxtFormatter> fileAppender(
      "kvstore.log");
  static plog::ColorConsoleAppender<plog::TxtFormatter> consoleAppender;
  plog::init(plog::debug, &fileAppender).addAppender(&consoleAppender);

  PLOG_INFO << "------------------------";
  PLOG_INFO << "Plog library initialized";
  PLOG_INFO << "------------------------";
}