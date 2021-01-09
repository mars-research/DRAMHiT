#ifndef __TESTS_HPP__
#define __TESTS_HPP__

#include "BQueueTest.hpp"
#include "CacheMissTest.hpp"
#include "ParserTest.hpp"
#include "PrefetchTest.hpp"
#include "SynthTest.hpp"

namespace kmercounter {

class Tests {
 public:
  SynthTest st;
  PrefetchTest pt;
  ParserTest pat;
  BQueueTest bqt;
  CacheMissTest cmt;

  Tests() {}
};

}  // namespace kmercounter

#endif  // __TESTS_HPP__
