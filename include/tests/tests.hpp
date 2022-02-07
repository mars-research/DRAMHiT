#ifndef TESTS_TESTS_HPP
#define TESTS_TESTS_HPP

#include "BQueueTest.hpp"
#include "CacheMissTest.hpp"
#include "PrefetchTest.hpp"
#include "SynthTest.hpp"
#include "ZipfianTest.hpp"

namespace kmercounter {

class Tests {
 public:
  SynthTest st;
  PrefetchTest pt;
  BQueueTest bqt;
  CacheMissTest cmt;
  ZipfianTest zipf;

  Tests() {}
};

}  // namespace kmercounter

#endif // TESTS_TESTS_HPP
