#pragma once

#include <stdlib.h>
#include <cstdint>
#include <unistd.h>

typedef uint64_t data_t;

#define FIPC_CACHE_LINE_SIZE  64
#define SUCCESS   0

#define CACHE_ALIGNED __attribute__((aligned(FIPC_CACHE_LINE_SIZE)))

template <typename T>
class Queue {
  public:
  virtual inline int enqueue(int, int, T data) = 0;
  virtual int dequeue(int, int, T *data) = 0;
  virtual void push_done(int, int) = 0;
  virtual void pop_done(int, int) = 0;
  virtual ~Queue() { }
};
