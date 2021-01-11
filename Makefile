CXX=g++

ifeq ($(OPT), no)
	OPT_FLAGS = -O0
else
	OPT_FLAGS =-O3
endif

IDIRS = include \
	include/xx \
	include/city

CFLAGS = -g -Wall -mprefetchwt1 $(OPT_FLAGS)
# This crashes cityhash
CFLAGS += -march=native
CFLAGS += $(patsubst %,-I%/,$(IDIRS))

VTUNE_ROOT := /opt/vtune/vtune_profiler_2020.1.0.607630

ifeq ($(PAPI), yes)
	CFLAGS += -I$(PWD)/papi/src/install/include/ -DWITH_PAPI_LIB
endif

ifeq ($(VTUNE), yes)
	CFLAGS += -I$(VTUNE_ROOT)/include/ -DWITH_VTUNE_LIB
endif

# YES. We love spaghetti!!!
# CFLAGS += -DCALC_STATS
CFLAGS += -D__MMAP_FILE
#CFLAGS += -DTOUCH_DEPENDENCY
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
# CFLAGS += -DCHAR_ARRAY_PARSE_BUFFER
# CFLAGS += -DNO_CORNER_CASES
CFLAGS += -DBQ_TESTS_DO_HT_INSERTS
# CFLAGS += -DBQ_TESTS_USE_HALT
#CFLAGS += -DUSE_ATOMICS

# https://wiki.ubuntu.com/ToolChain/CompilerFlags#A-fstack-clash-protection
CFLAGS += -fcf-protection=none
# CFLAGS += -fsanitize=address

CXXFLAGS = -std=c++17 $(CFLAGS) -MP -MD -fcf-protection=none

ifeq ($(BRANCH), cmov)
	CXXFLAGS += -DBRANCHLESS_CMOVE
endif

ifeq ($(BRANCH), simd)
	CXXFLAGS += -DBRANCHLESS_SIMD
endif

# LIBS = -lasan

# boostpo to parse args
LIBS += -lboost_program_options
# for compressed fasta?
LIBS += -lz
# Used for numa partitioning
LIBS += -lnuma
# Multithreading
LIBS += -lpthread -flto
 
# for PAPI
LIBPAPI = libpapi.a
LIBDIR = $(PWD)/papi/src/install/lib/
PAPILIB = $(LIBDIR)/$(LIBPAPI) 

ifeq ($(PAPI), yes)
	LIBS += $(PAPILIB)
endif

ifeq ($(VTUNE), yes)
	LIBS += -Wl,--no-as-needed -ldl -L$(VTUNE_ROOT)/lib64/ -littnotify
endif

TARGET=kmercounter

C_SRCS = $(patsubst %,src/%, bqueue.c \
	 hashers/xx/xxhash.c)

TESTS = $(patsubst %,src/tests/%, bq_tests.cpp  \
	hashtable_tests.cpp  \
	parser_tests.cpp \
	prefetch_tests.cpp \
	cachemiss_test.cpp \
	)

CPP_SRCS = $(patsubst %,src/%, misc_lib.cpp \
	   ac_kseq.cpp \
	   ac_kstream.cpp \
	   Application.cpp \
	   kmercounter.cpp \
	   ) $(TESTS)

CC_SRCS = src/hashers/city/city.cc

OBJS = $(C_SRCS:.c=.o) $(CPP_SRCS:.cpp=.o) $(CC_SRCS:.cc=.o)

%.o : %.cc
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(OPT_YES)

%.o : %.cpp
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(OPT_YES)

%.o : %.c
	$(CXX) -c -o $@ $< $(CFLAGS) $(OPT_YES)


.PHONY: all papi clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) -o $@ $^ $(LDFLAGS) $(LIBS)


# Use automatic dependency generation
-include $(CPP_SRCS:.cpp=.d)
-include $(C_SRCS:.c=.d)

clean:
	rm -f $(TARGET) $(OBJS)
	rm -f src/*.d

