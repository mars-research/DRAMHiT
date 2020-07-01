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

#ifndef AC_KSTREAM_H
#define AC_KSTREAM_H

#include <fcntl.h>
#include <unistd.h>
#include "ac_kseq.h"
#include "misc_lib.h"
#include "sync.h"

namespace kmercounter {
class kstream
{
 public:
  kstream(uint32_t, off_t, off_t);
  ~kstream();
  int readseq(kseq &seq);
  int readfunc(int, void *, size_t);

 private:
  int getc();
  int getuntil(int delimiter, int *dret);
#ifdef __MMAP_FILE
  ssize_t __mmap_read();
  off64_t __mmap_lseek64();
#endif /* __MMAP_FILE */

  char *buf;
  const unsigned int bufferSize;
  int is_eof;
  int begin;
  int end;

  int fileid;
  uint32_t thread_id;  // thread id corresponding to this kstream
  off64_t off_start;   // start byte into file
  off64_t off_end;     // end byte into file
  int is_first_read;   // is this the first time readseq is being called?
  int done;

#ifdef __MMAP_FILE
  static char *fmap;
  static char *fmap_end;
  static uint64_t mmaped_file;
  off64_t off_curr;
#endif /* __MMAP_FILE */
};

} // namespace kmercounter
#endif /* AC_KSTREAM_H */
