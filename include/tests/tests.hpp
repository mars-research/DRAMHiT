#ifndef TESTS_TESTS_HPP
#define TESTS_TESTS_HPP

#include "BQueueTest.hpp"
#include "CacheMissTest.hpp"
#include "PrefetchTest.hpp"
#include "SynthTest.hpp"
#include "ZipfianTest.hpp"
#include "QueueTest.hpp"

namespace kmercounter {

class LynxQueue;

class Tests {
 public:
  SynthTest st;
  PrefetchTest pt;
  BQueueTest bqt;
  QueueTest<kmercounter::LynxQueue> qt;
  CacheMissTest cmt;
  ZipfianTest zipf;

  Tests() {
  }
};

}  // namespace kmercounter

#endif // TESTS_TESTS_HPP
