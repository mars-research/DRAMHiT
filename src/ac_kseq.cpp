/* The MIT License

 Copyright (c) 2008 Genome Research Ltd (GRL).

 Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "ac_kseq.h"
// #include "types.hpp"
// #include "libfipc/libfipc_test.h"
// #include "misc_lib.h"

namespace kmercounter {

#ifndef CHAR_ARRAY_PARSE_BUFFER
kseq::kseq()
{
  this->seq.reserve(BUFFER_SIZE);
  this->last_char = 0;
}
#else
kseq::kseq() : bufferSize(BUFFER_SIZE)
{
  this->seq = static_cast<char*>(
      std::aligned_alloc(CACHE_LINE_SIZE, sizeof(char) * this->bufferSize));
  this->_s = 0;
  this->last_char = 0;
}
#endif

#ifdef CHAR_ARRAY_PARSE_BUFFER
void kseq::clearSeq() { this->_s = 0; }

void kseq::addToSeq(char c)
{
  this->seq[_s++] = c;
  if (this->_s >= (int)this->bufferSize) {
    fprintf(stderr, "[ERROR] kseq::addToSeq overflow \n");
    exit(-1);
  }
}
#endif

kseq::~kseq() { printf("kseq destructor called\n"); }
} // namespace kmercounter
