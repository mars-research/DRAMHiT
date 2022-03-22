#ifndef TESTS_TESTS_HPP
#define TESTS_TESTS_HPP

#include "CacheMissTest.hpp"
#include "PrefetchTest.hpp"
#include "SynthTest.hpp"
#include "ZipfianTest.hpp"
#include "QueueTest.hpp"

namespace kmercounter {

class LynxQueue;
class BQueueAligned;

class Tests {
 public:
  SynthTest st;
  PrefetchTest pt;
  QueueTest<kmercounter::BQueueAligned> qt;
  //QueueTest<kmercounter::LynxQueue> qt;
  CacheMissTest cmt;
  ZipfianTest zipf;

  Tests() {
  }
};

}  // namespace kmercounter

#endif // TESTS_TESTS_HPP
