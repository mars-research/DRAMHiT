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

/* Contact: Heng Li <lh3@sanger.ac.uk> */

/* Last Modified: 12APR2009 */

/* De-macro'd by the ACE-team 18MAY2012 wattup! */

/*Converted into template classes by CTS 11DEC2014*/

/*https://github.com/gtonkinhill/pairsnp-r/blob/master/src/kseq.h */

#ifndef AC_KSEQ_H
#define AC_KSEQ_H

#define BUFFER_SIZE 4096

#include <unistd.h>
#include <fcntl.h>

#include <cctype>
#include <cstdint>
#include <cstdlib>
#include <string>
#include <malloc.h>

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
  std::string seq;
  uint64_t qual_length;
  int last_char;
};

class kstream
{
 public:
  kstream(uint32_t, off_t, off_t);
  ~kstream();
  int readseq(kseq &seq);
  int readfunc(int, void*, size_t);

 private:
  int getc();
  int getuntil(int delimiter, int *dret);
#ifdef __MMAP_FILE
  ssize_t __mmap_read();
  off64_t __mmap_lseek64();
#endif 

  char *buf;
  const unsigned int bufferSize;
  int is_eof;
  int begin;
  int end;

  int fileid;
  uint32_t thread_id; // thread id corresponding to this kstream
  off64_t off_start;  // start byte into file
  off64_t off_end;    // end byte into file
  int is_first_read;  // is this the first time readseq is being called?
  int done;

#ifdef __MMAP_FILE
  static char* fmap;
  static char* fmap_end;
  static uint64_t mmaped_file;
  off64_t off_curr;
#endif 

};

#endif