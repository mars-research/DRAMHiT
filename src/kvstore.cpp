#include "Application.hpp"
#include "logger.h"

using namespace kmercounter;

int main(int argc, char **argv) {
  initializeLogger();

  Application application;

  PLOGI << "Starting kvstore";

  application.process(argc, argv);

  return 0;
}
