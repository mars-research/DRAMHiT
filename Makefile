CXX=g++

ifeq ($(OPT), no)
	OPT_FLAGS = -O0
else
	OPT_FLAGS =-O3
endif

IDIR=./include

CFLAGS = -g -Wall -mprefetchwt1 $(OPT_FLAGS)
# This crashes cityhash
CFLAGS += -march=skylake
CFLAGS += -I$(IDIR)
# CFLAGS += -I$(PWD)/papi/src/install/include/ -DWITH_PAPI_LIB

# YES. We love spaghetti!!!
# CFLAGS += -DCALC_STATS
CFLAGS += -D__MMAP_FILE
CFLAGS += -DTOUCH_DEPENDENCY
CFLAGS += -DSERIAL_SCAN
#CFLAGS += -DXORWOW_SCAN
CFLAGS += -DPREFETCH_WITH_PREFETCH_INSTR
#CFLAGS += -DSAME_KMER
#CFLAGS += -DPREFETCH_TWOLINE
#CFLAGS += -DPREFETCH_WITH_WRITE
#CFLAGS += -DPREFETCH_RUN
CFLAGS += -DHUGE_1GB_PAGES
# CFLAGS += -DCITY_HASH
#CFLAGS += -DFNV_HASH
CFLAGS += -DXX_HASH
# CFLAGS += -DXX_HASH_3
# CFLAGS += -DBQ_TESTS_INSERT_XORWOW
CFLAGS += -DCHAR_ARRAY_PARSE_BUFFER

CXXFLAGS = -std=c++17 $(CFLAGS)

# boostpo to parse args
LIBS = -lboost_program_options
# for compressed fasta?
LIBS += -lz
# Used for numa partitioning
LIBS += -lnuma
# Multithreading
LIBS += -lpthread -flto

# for PAPI
LIBS += -lpapi
LDFLAGS = -L$(PWD)/papi/src/install/lib/

TARGET=kmercounter

C_SRCS = bqueue.c \
	 include/xx/xxhash.c

CPP_SRCS = misc_lib.cpp \
	   ac_kseq.cpp \
	   ac_kstream.cpp \
	   main.cpp \


DEPS = $(wildcard hashtables/*.hpp) \
       $(wildcard include/*.h) \
       $(wildcard include/*.hpp) \
       $(wildcard *_tests.cpp)

OBJS = $(C_SRCS:.c=.o) $(CPP_SRCS:.cpp=.o)

%.o : %.cpp $(DEPS)
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(OPT_YES)

%.o : %.c $(DEPS)
	$(CXX) -c -o $@ $< $(CFLAGS) $(OPT_YES)


.PHONY: all papi clean ugdb

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) -o $@ $^ $(LDFLAGS) $(LIBS)

clean:
	rm -f $(TARGET) $(OBJS)

ugdb:
	ugdb $(TARGET)
