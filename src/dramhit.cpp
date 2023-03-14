#include <plog/Appenders/ColorConsoleAppender.h>
#include <plog/Appenders/RollingFileAppender.h>
#include <plog/Formatters/TxtFormatter.h>
#include <plog/Init.h>
#include <plog/Log.h>

#include "Application.hpp"

using namespace kmercounter;

void initializeLogger() {
  static plog::RollingFileAppender<plog::TxtFormatter> fileAppender(
      "dramhit.log");
  static plog::ColorConsoleAppender<plog::TxtFormatter> consoleAppender;
  plog::init(plog::debug, &fileAppender).addAppender(&consoleAppender);

  PLOG_INFO << "------------------------";
  PLOG_INFO << "Plog library initialized";
  PLOG_INFO << "------------------------";
}

int main(int argc, char **argv) {
  initializeLogger();

  Application application;

  PLOGI << "Starting dramhit";

  application.process(argc, argv);

  return 0;
}
