#include "Application.hpp"
#include "logger.h"

using namespace kmercounter;

int main(int argc, char **argv) {
  initializeLogger();

  Application application;

  PLOGI << "Starting kvstore";
  for (auto i = 0; i < argc; ++i)
    PLOGI << argv[i];

  application.process(argc, argv);

  return 0;
}
