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

#include "./include/ac_kseq.h"

int FunctorRead::operator()(int fd, void *buf, size_t count)
{
  return read(fd, buf, count);
}

kseq::kseq()
{
  this->seq.reserve(BUFFER_SIZE);
  this->last_char = 0;
};
kseq::~kseq() = default;

/* class __kseq
{
  public:
    __kseq(): last_char(0){};
    ~__kseq() = default;
    char outbuf [BUFFER_SIZE];
    int last_char;
};
 */
template <class FileIdentifier, class ReadFunction>
kstream<FileIdentifier, ReadFunction>::kstream(FileIdentifier fi,
                                               ReadFunction rf,
                                               uint32_t shard_idx,
                                               off_t f_start, off_t f_end)
    : bufferSize(BUFFER_SIZE),
      idx(shard_idx),
      off_start(f_start),
      off_end(f_end)
{
  is_eof = 0;
  begin = 0;
  end = 0;
  is_first_read = 0;
  readfunc = rf;
  fileid = fi;
  done = 0;

  buf = (char *)malloc(bufferSize);
}

template <class FileIdentifier, class ReadFunction>
kstream<FileIdentifier, ReadFunction>::~kstream()
{
  free(buf);
}

/* Each time read is called, it tries to read the next record starting with '@'.
 * If read is called t a position in the middle of a sequence, it  will skip to
 * the next record */
template <class FileIdentifier, class ReadFunction>
int kstream<FileIdentifier, ReadFunction>::read(kseq &seq)
{
  int c;
  if (this->done) return -1;
  if (seq.last_char == 0) {
    /* Keep reading into buffer until we see a '\n' followed by '@'  (except for
     * the is_first_read thread - just look for '@') */
    while (true) {
      c = this->getc();
      if (c == -1) break;
      if (this->idx == 0) {  // this is thread idx 0
        if (c == '@') break;
      } else if (!this->is_first_read) {
        if (c == '@') break;
      } else {
        if (c == '\n') {
          this->is_first_read = 1;
          c = this->getc();
          if (c == -1) break;
          if (c == '@') break;
        }
      }
    }
    if (c == -1) {
      return -1;
    }
    seq.last_char = c;
  }

  /* At this point, "buffer" is filled with data, "begin" points to start of new
   * sequence in buffer */
  seq.seq.clear();
  seq.qual_length = 0;
  // seq.qual.clear();
  // seq.comment.clear();

  /* consume buffer into seq.name until we see space characters*/
  if (this->getuntil(0, seq.name, &c) < 0) return -1;
  /* consume buffer into seq.comment until we see a newline */
  if (c != '\n') this->getuntil('\n', seq.comment, 0);
  /* consume buffer into seq.seq (the actual sequence) until there are
   * characters to read */
  while ((c = this->getc()) != -1 /* && c != '>' */ && c != '+' && c != '@') {
    if (isgraph(c)) {
      seq.seq += (char)c;
    }
  }
  if (c == '@') seq.last_char = c;

  /*TODO: remove this? there will always be a + in FastQ */
  if (c != '+') return (int)seq.seq.length();

  while ((c = this->getc()) != -1 && c != '\n')
    ;

  if (c == -1) return -2;
  /* Read quality scores into seq.qual */
  // while ((c = this->getc()) != -1 && seq.qual.length() < seq.seq.length()) {
  //   if (c >= 33 && c <= 127) seq.qual += (char)c;
  // }

  /* skip quality scores */
  while ((c = this->getc()) != -1 && seq.qual_length < seq.seq.length()) {
    if (c >= 33 && c <= 127) {
      seq.qual_length++;
    };
  }

  seq.last_char = 0;
  if (seq.seq.length() != seq.qual_length) return -2;
  return (int)seq.seq.length();
}

template <class FileIdentifier, class ReadFunction>
int kstream<FileIdentifier, ReadFunction>::getc()
{
  if (this->is_eof && this->begin >= this->end) return -1;
  if (this->begin >= this->end) {
    this->begin = 0;
    this->end = this->readfunc(this->fileid, this->buf, bufferSize);
    /* checking if reached end of assigned segment */
    if (lseek64(this->fileid, 0, SEEK_CUR) > this->off_end) this->done = 1;
    if (this->end < bufferSize) this->is_eof = 1;
    if (this->end == 0) return -1;
  }
  return (int)this->buf[this->begin++];
}

template <class FileIdentifier, class ReadFunction>
int kstream<FileIdentifier, ReadFunction>::getuntil(int delimiter,
                                                    std::string &str, int *dret)
{
  if (dret) *dret = 0;
  if (!str.empty()) {
    str.clear();
  }

  if (this->begin >= this->end && this->is_eof) return -1;
  for (;;) {
    int i;
    if (this->begin >= this->end) {
      if (!this->is_eof) {
        this->begin = 0;
        this->end = this->readfunc(this->fileid, this->buf, bufferSize);
        /* checking if reached end of assigned segment */
        if (lseek64(this->fileid, 0, SEEK_CUR) > this->off_end) this->done = 1;
        if (this->end < bufferSize) this->is_eof = 1;
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

    /* Append to seq.name/seq.comment  */
    // str.append(this->buf + this->begin,
    //            static_cast<unsigned long>(i - this->begin));
    this->begin = i + 1;
    if (i < this->end) {
      if (dret) *dret = this->buf[i];
      break;
    }
  }
  return (int)str.length();
}
