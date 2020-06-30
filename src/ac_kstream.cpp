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

#include "ac_kstream.h"

extern Configuration config;

#ifdef __MMAP_FILE
char *kstream::fmap = NULL;
char *kstream::fmap_end = NULL;
uint64_t kstream::mmaped_file = 0;

ssize_t kstream::__mmap_read()
{
  int bytes_read;

  // return zero bytes read if offset greater than end of file
  if (this->fmap + this->off_curr >= this->fmap_end) return 0;

  this->buf = this->fmap + this->off_curr;
  this->off_curr += this->bufferSize;
  if (this->fmap + this->off_curr > this->fmap_end) {
    // end of file
    bytes_read = (int)((uint64_t)this->fmap_end - (uint64_t)buf);
  } else {
    bytes_read = this->bufferSize;
  }
  return bytes_read;
}

off64_t kstream::__mmap_lseek64() { return this->off_curr; }
#endif  //__MMAP_FILE

kstream::kstream(uint32_t shard_idx, off_t f_start, off_t f_end)
    : bufferSize(BUFFER_SIZE)
{
  this->off_start = f_start;
  this->off_end = f_end;
  this->is_eof = 0;
  this->begin = 0;
  this->end = 0;
  this->is_first_read = 0;
  this->done = 0;
  this->thread_id = shard_idx;

  this->fileid = open(config.in_file.c_str(), O_RDONLY);
#ifdef __MMAP_FILE
  // if this is the first thread, map the whole file
  if (this->thread_id == 0) {
    printf("[INFO] Shard %u: mmaping file ...\n", this->thread_id);
    this->fmap = (char *)mmap(NULL, config.in_file_sz, PROT_READ, MAP_PRIVATE,
                              this->fileid, 0);
    if (this->fmap == MAP_FAILED) {
      perror("[ERROR] mmap() failed");
      exit(-1);
    }
    mlock(fmap, config.in_file_sz);
    touchpages(fmap, config.in_file_sz);
    mmaped_file = 1;
    printf("[INFO] Shard %u: mmaping file ... done \n", this->thread_id);
  }
  while (mmaped_file == 0) fipc_test_pause();

  this->off_curr = this->off_start;
  this->fmap_end = this->fmap + config.in_file_sz;
#else
  this->buf = static_cast<char *>(
      std::aligned_alloc(__CACHE_LINE_SIZE, sizeof(char) * this->bufferSize));
  if (lseek64(this->fileid, this->off_start, SEEK_SET) == -1) {
    printf("[ERROR] Shard %u: Unable to seek", this->thread_id);
    exit(-1);
  }
#endif
  printf("[INFO] Shard %u: kstream init done \n", this->thread_id);
}

kstream::~kstream()
{
  close(this->fileid);
  // #ifdef __MMAP_FILE
  //   free(this->fmap);
  // #else
  //   free(this->buf);
  // #endif
  printf("kstream descturtor\n");
}

/* Each time read is called, it tries to read the next record starting with '@'.
 * If read is called t a position in the middle of a sequence, it  will skip to
 * the next record */
int kstream::readseq(kseq &seq)
{
  int c;
  if (this->done) return -1;

  if (seq.last_char == 0) {
    /* Keep reading into buffer until we see a '\n' followed by '@'  (except for
     * the is_first_read thread - just look for '@')
     * TODO verify if this is enough:
     * https://en.wikipedia.org/wiki/FASTQ_format*/

    while (true) {
      c = this->getc();
      if (c == -1) break;
      if (this->is_first_read == 0) {
        this->is_first_read = 1;
        if (this->thread_id == 0) {
          if (c == '@') break;
        } else {
          if (c != '\n') continue;
          c = this->getc();
          if (c == '@') break;
          if (c == -1) break;
        }
      } else {
        if (c == '@') break;
      }
    }
    if (c == -1) {
      return -1;
    }
    seq.last_char = c;
  }

  /* At this point, "buffer" is filled with data, "begin" points to start of
   * new sequence in buffer */
#ifndef CHAR_ARRAY_PARSE_BUFFER
  seq.seq.clear();
#else
  seq.clearSeq();
#endif
  seq.qual_length = 0;

  /* TODO remove statement this altogether? Just consume until newline (see next
   * statement) */
  /* consume buffer until we see space characters*/
  if (this->getuntil(0, &c) < 0) return -1;

  /* consume buffer until we see a newline */
  if (c != '\n') this->getuntil('\n', 0);

  /* consume buffer into seq.seq until there are characters to read */
  while ((c = this->getc()) != -1 && c != '+' && c != '@') {
    // TODO convert to isalpha?
    if (isgraph(c)) {
#ifndef CHAR_ARRAY_PARSE_BUFFER
      seq.seq += (char)c;
#else
      seq.addToSeq((char)c);
#endif
    }
  }
  if (c == '@') seq.last_char = c;

  /* TODO: remove this? there will always be a + in FastQ */
  if (c != '+') {
#ifndef CHAR_ARRAY_PARSE_BUFFER
    return (int)seq.seq.length();
#else
    return seq._s;
#endif
  }

  while ((c = this->getc()) != -1 && c != '\n')
    ;

  if (c == -1) return -2;

    /* skip quality scores */
#ifndef CHAR_ARRAY_PARSE_BUFFER
  while ((c = this->getc()) != -1 && seq.qual_length < seq.seq.length()) {
    if (c >= 33 && c <= 127) {
      seq.qual_length++;
    };
  }
#else
  while ((c = this->getc()) != -1 && seq.qual_length < (uint64_t)seq._s) {
    if (c >= 33 && c <= 127) {
      seq.qual_length++;
    };
  }
#endif

  seq.last_char = 0;
#ifndef CHAR_ARRAY_PARSE_BUFFER
  if (seq.seq.length() != seq.qual_length) return -2;
  return (int)seq.seq.length();
#else
  if ((uint64_t)seq._s != seq.qual_length) return -2;
  return seq._s;
#endif
}

int kstream::readfunc(int fd, void *buffer, size_t count)
{
#ifdef __MMAP_FILE
  int bytes_read = __mmap_read();
  if (__mmap_lseek64() > this->off_end) {
    printf("[INFO] Shard %u: reached done\n", this->thread_id);
    this->done = 1;
  }
  if (bytes_read < (int)this->bufferSize) this->is_eof = 1;
  return bytes_read;
#else
  unsigned int bytes_read = read(fd, buffer, count);
  if (lseek64(this->fileid, 0, SEEK_CUR) > this->off_end) {
    // printf("[INFO] Shard %u: done\n", this->thread_id);
    this->done = 1;
  }
  if (bytes_read < this->bufferSize) this->is_eof = 1;
  return bytes_read;
#endif
}

int kstream::getc()
{
  if (this->is_eof && this->begin >= this->end) return -1;
  if (this->begin >= this->end) {
    this->begin = 0;
    this->end = this->readfunc(this->fileid, this->buf, bufferSize);
    if (this->end == 0) return -1;
  }
  return (int)this->buf[this->begin++];
}

int kstream::getuntil(int delimiter, int *dret)
{
  if (dret) *dret = 0;

  if (this->begin >= this->end && this->is_eof) return -1;
  for (;;) {
    int i;
    if (this->begin >= this->end) {
      if (!this->is_eof) {
        this->begin = 0;
        this->end = this->readfunc(this->fileid, this->buf, bufferSize);
        if (this->end == 0) break;
      } else
        break;
    }
    if (delimiter > 1) {
      for (i = this->begin; i < this->end; ++i) {
        if (this->buf[i] == delimiter) break;
      }
    } else if (delimiter == 0) {
      for (i = this->begin; i < this->end; ++i) {
        if (isspace(this->buf[i])) break;
      }
    } else if (delimiter == 1) {
      for (i = this->begin; i < this->end; ++i) {
        if (isspace(this->buf[i]) && this->buf[i] != ' ') break;
      }
    } else
      i = 0;

    this->begin = i + 1;
    if (i < this->end) {
      if (dret) *dret = this->buf[i];
      break;
    }
  }
  return 0;
}
