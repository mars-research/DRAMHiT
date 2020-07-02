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

#ifndef AC_KSEQ_H
#define AC_KSEQ_H

#include <cstdint>
#include <cstdlib>
#include "types.hpp"

namespace kmercounter {

#define BUFFER_SIZE 4096

// #if HAVE_ZLIB
// #include <zlib.h>
// class FunctorZlib
// {
//  public:
//   int operator()(gzFile file, void *buffer, unsigned int len)
//   {
//     return gzread(file, buffer, len);
//   }
// };
// #endif

// #if HAVE_BZIP2
// #include <bzlib.h>
// class FunctorBZlib2
// {
//  public:
//   int operator()(BZFILE *file, void *buffer, int len)
//   {
//     return BZ2_bzread(file, buffer, len);
//   }
// };
// #endif

// TODO clean up kseq
class kseq
{
 public:
  kseq();
  ~kseq();
#ifndef CHAR_ARRAY_PARSE_BUFFER
  std::string seq;
#else
  char *seq;
  const unsigned int bufferSize;
  int _s;
  int _len;
  void clearSeq();
  void addToSeq(char c);
#endif
  uint64_t qual_length;
  int last_char;
};

} // namespace kmercounter
#endif
