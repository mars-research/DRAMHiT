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

#ifndef AC_KSEQ_H
#define AC_KSEQ_H

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#define KS_SEP_SPACE 0  // isspace(): \t, \n, \v, \f, \r
#define KS_SEP_TAB 1    // isspace() && !' '
#define KS_SEP_MAX 1

#define __KS_TYPE(type_t)						\
	typedef struct __kstream_t {				\
		char *buf;								\
		void *buf1;								\
		void *buf2;								\
		int begin, end, is_eof;					\
		long offset; \
		type_t f;								\
		long fileend; \
		struct iocb cb;	\
	  struct iocb* iocbs;	\
	  struct io_event events[1];	\
	  io_context_t ctx;	\
		int curBuf;	\
	} kstream_t;

#define ks_eof(ks) ((ks)->is_eof && (ks)->begin >= (ks)->end)
#define ks_rewind(ks) ((ks)->is_eof = (ks)->begin = (ks)->end = 0)

#define __KS_BASIC(type_t, __bufsize)								\
	static inline kstream_t *ks_init(type_t f, long begin, long fileend)						\
	{																\
		kstream_t *ks = (kstream_t*)calloc(1, sizeof(kstream_t));	\
		ks->f = f;													\
		posix_memalign((void**)&ks->buf1, getpagesize(), __bufsize); \
		posix_memalign((void**)&ks->buf2, getpagesize(), __bufsize); \
		ks -> offset = begin;	\
		ks -> fileend = fileend; \
		ks -> is_eof = 0;	\
		memset(&ks->ctx, 0, sizeof(ks->ctx));	\
	  memset(&ks->cb, 0, sizeof(ks->cb));	\
		ks->iocbs = &ks->cb;	\
		ks->curBuf = 1; 	\
		ks-> end = read(f, ks->buf1, __bufsize);	\
		ks ->buf = (char*)ks->buf1;	\
		ks-> begin = 0;	\
		ks -> offset += ks-> end;		\
		if(io_setup(1, &ks->ctx) < 0) {	\
	    printf("io_setup error\n");	\
	  }	\
		io_prep_pread(&ks->cb, ks->f, ks->buf2, __bufsize, ks->offset);	\
		if(io_submit(ks->ctx, 1, &ks->iocbs) < 0){	\
			printf("io_submit error\n");	\
		}	\
		return ks;													\
	}																\
	static inline void ks_destroy(kstream_t *ks)					\
	{																\
		if (ks) {													\
			free(ks->buf1);											\
			free(ks->buf2);							\
			io_destroy(ks->ctx);	\
			free(ks);												\
		}															\
	}

#define __KS_GETC(__read, __bufsize)						\
	static inline int ks_getc(kstream_t *ks)				\
	{														\
		if (ks->is_eof && ks->begin >= ks->end){	\
			return -1;	\
		} \
		if (ks->begin >= ks->end) {							\
			ks->begin = 0;									\
			if(io_getevents(ks->ctx, 1, 1, ks->events, NULL) != 1) printf("io_getevents error\n"); \
			ks -> offset += ks->events[0].res;	\
			ks->end = ks->events[0].res;	\
			if (ks->end < __bufsize || ks->offset >= ks->fileend) ks->is_eof = 1;		\
			else{	\
				memset(&ks->ctx, 0, sizeof(ks->ctx));	\
				memset(&ks->cb, 0, sizeof(ks->cb));	\
				io_setup(1, &ks->ctx);	\
				if(ks->curBuf == 1){	\
					io_prep_pread(&ks->cb, ks->f, ks->buf1, __bufsize, ks->offset);	\
					ks-> curBuf = 2;	\
					ks -> buf = (char*)ks -> buf2;	\
				}	\
				else{	\
					io_prep_pread(&ks->cb, ks->f, ks->buf2, __bufsize, ks->offset);	\
					ks -> curBuf = 1;	\
					ks -> buf = (char*)ks -> buf1;	\
				}	\
				if(io_submit(ks->ctx, 1, &ks->iocbs) < 0){	\
			   	printf("io_setup error\n");	\
			 	}	\
				if (ks->end == 0) return -1;					\
			}	\
		}													\
		return (int)ks->buf[ks->begin++];					\
	}

#ifndef KSTRING_T
#define KSTRING_T kkstring_t
typedef struct __kkstring_t {
  size_t l, m;
  char *s;
} kkstring_t;
#endif

#ifndef kroundup32
#define kroundup32(x)                                                         \
  (--(x), (x) |= (x) >> 1, (x) |= (x) >> 2, (x) |= (x) >> 4, (x) |= (x) >> 8, \
   (x) |= (x) >> 16, ++(x))
#endif

#define __KS_GETUNTIL(__read, __bufsize)								\
	static int ks_getuntil(kstream_t *ks, int delimiter, kkstring_t *str, int *dret) \
	{																	\
		if (dret) *dret = 0;											\
		str->l = 0;														\
		if (ks->begin >= ks->end && ks->is_eof) return -1;				\
		for (;;) {														\
			int i;														\
			if (ks->begin >= ks->end) {									\
				if (!ks->is_eof) {										\
					ks->begin = 0;									\
					if(io_getevents(ks->ctx, 1, 1, ks->events, NULL) != 1) printf("io_getevents error\n"); \
					ks -> offset += ks->events[0].res;	\
					ks->end = ks->events[0].res;	\
					if (ks->end < __bufsize  || ks->offset >= ks->fileend) ks->is_eof = 1;		\
					else{	\
						memset(&ks->ctx, 0, sizeof(ks->ctx));	\
						memset(&ks->cb, 0, sizeof(ks->cb));	\
						io_setup(1, &ks->ctx);	\
						if(ks->curBuf == 1){	\
							io_prep_pread(&ks->cb, ks->f, ks->buf1, __bufsize, ks->offset);	\
							ks-> curBuf = 2;	\
							ks -> buf = (char*)ks -> buf2;	\
						}	\
						else{	\
							io_prep_pread(&ks->cb, ks->f, ks->buf2, __bufsize, ks->offset);	\
							ks -> curBuf = 1;	\
							ks -> buf = (char*)ks -> buf1;	\
						}	\
						if(io_submit(ks->ctx, 1, &ks->iocbs) < 0){	\
					   	printf("io_setup error\n");	\
					 	}	\
						if (ks->end == 0) return -1;					\
					}	\
					if (ks->end == 0) break;							\
				} else break;											\
			}															\
			if (delimiter > KS_SEP_MAX) {								\
				for (i = ks->begin; i < ks->end; ++i)					\
					if (ks->buf[i] == delimiter) break;					\
			} else if (delimiter == KS_SEP_SPACE) {						\
				for (i = ks->begin; i < ks->end; ++i)					\
					if (isspace(ks->buf[i])) break;						\
			} else if (delimiter == KS_SEP_TAB) {						\
				for (i = ks->begin; i < ks->end; ++i)					\
					if (isspace(ks->buf[i]) && ks->buf[i] != ' ') break; \
			} else i = 0; /* never come to here! */						\
			if (str->m - str->l < i - ks->begin + 1) {					\
				str->m = str->l + (i - ks->begin) + 1;					\
				kroundup32(str->m);										\
				str->s = (char*)realloc(str->s, str->m);				\
			}															\
			memcpy(str->s + str->l, ks->buf + ks->begin, i - ks->begin); \
			str->l = str->l + (i - ks->begin);							\
			ks->begin = i + 1;											\
			if (i < ks->end) {											\
				if (dret) *dret = ks->buf[i];							\
				break;													\
			}															\
		}																\
		if (str->l == 0) {												\
			str->m = 1;													\
			str->s = (char*)calloc(1, 1);								\
		}																\
		str->s[str->l] = '\0';											\
		return str->l;													\
	}

#define KSTREAM_INIT(type_t, __read, __bufsize) \
	__KS_TYPE(type_t)							\
	__KS_BASIC(type_t, __bufsize)				\
	__KS_GETC(__read, __bufsize)				\
	__KS_GETUNTIL(__read, __bufsize)

#define __KSEQ_BASIC(type_t)											\
	static inline kseq_t *kseq_init(type_t fd, long begin, long fileend)							\
	{																	\
		kseq_t *s = (kseq_t*)calloc(1, sizeof(kseq_t));					\
		s->f = ks_init(fd, begin, fileend);												\
		return s;														\
	}																	\
	static inline void kseq_rewind(kseq_t *ks)							\
	{																	\
		ks->last_char = 0;												\
		ks->f->is_eof = ks->f->begin = ks->f->end = 0;					\
	}																	\
	static inline void kseq_destroy(kseq_t *ks)							\
	{																	\
		if (!ks) return;												\
		free(ks->name.s); free(ks->comment.s); free(ks->seq.s);	free(ks->qual.s); \
		ks_destroy(ks->f);												\
		free(ks);														\
	}

/* Return value:
   >=0  length of the sequence (normal)
   -1   end-of-file
   -2   truncated quality string
 */
#define __KSEQ_READ														\
	static int kseq_read(kseq_t *seq)									\
	{																	\
		int c;															\
		kstream_t *ks = seq->f;											\
		if (seq->last_char == 0) { /* then jump to the next header line */ \
			while ((c = ks_getc(ks)) != -1 && c != '>' && c != '@');	\
			if (c == -1) return -1; /* end of file */					\
			seq->last_char = c;											\
		} /* the first header char has been read */						\
		seq->comment.l = seq->seq.l = seq->qual.l = 0;					\
		if (ks_getuntil(ks, 0, &seq->name, &c) < 0) return -1;			\
		if (c != '\n') ks_getuntil(ks, '\n', &seq->comment, 0);			\
		while ((c = ks_getc(ks)) != -1 && c != '>' && c != '+' && c != '@') { \
			if (isgraph(c)) { /* printable non-space character */		\
				if (seq->seq.l + 1 >= seq->seq.m) { /* double the memory */ \
					seq->seq.m = seq->seq.l + 2;						\
					kroundup32(seq->seq.m); /* rounded to next closest 2^k */ \
					seq->seq.s = (char*)realloc(seq->seq.s, seq->seq.m); \
				}														\
				seq->seq.s[seq->seq.l++] = (char)c;						\
			}															\
		}																\
		if (c == '>' || c == '@') seq->last_char = c; /* the first header char has been read */	\
		seq->seq.s[seq->seq.l] = 0;	/* null terminated string */		\
		if (c != '+') return seq->seq.l; /* FASTA */					\
		if (seq->qual.m < seq->seq.m) {	/* allocate enough memory */	\
			seq->qual.m = seq->seq.m;									\
			seq->qual.s = (char*)realloc(seq->qual.s, seq->qual.m);		\
		}																\
		while ((c = ks_getc(ks)) != -1 && c != '\n'); /* skip the rest of '+' line */ \
		if (c == -1) return -2; /* we should not stop here */			\
		while ((c = ks_getc(ks)) != -1 && seq->qual.l < seq->seq.l)		\
			if (c >= 33 && c <= 127) seq->qual.s[seq->qual.l++] = (unsigned char)c;	\
		seq->qual.s[seq->qual.l] = 0; /* null terminated string */		\
		seq->last_char = 0;	/* we have not come to the next header line */ \
		if (seq->seq.l != seq->qual.l) return -2; /* qual string is shorter than seq string */ \
		return seq->seq.l;												\
	}

#define __KSEQ_TYPE(type_t)						\
	typedef struct {							\
		kkstring_t name, comment, seq, qual;		\
		int last_char;							\
		kstream_t *f;							\
	} kseq_t;

#define KSEQ_INIT(type_t, __read)				\
	KSTREAM_INIT(type_t, __read, 40968*1024)			\
	__KSEQ_TYPE(type_t)							\
	__KSEQ_BASIC(type_t)						\
	__KSEQ_READ

#endif
