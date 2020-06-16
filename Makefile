CC=g++
CFLAGS=-g -std=c++17 -Wall -mprefetchwt1 
# This crashes citihash
CFLAGS +=-march=skylake
LDFLAGS= -lboost_program_options -lz -lnuma -lpthread -flto
TARGET=kmercounter
OPT_YES=-O3
OPT_NO=-O0
#sources =  misc_lib.cpp ac_kseq.cpp include/city/city.cc include/xx/xxhash.c main.cpp
sources =  bqueue.c misc_lib.cpp ac_kseq.cpp include/xx/xxhash.c main.cpp 
#CFLAGS += -DCALC_STATS
# CFLAGS += -D__MMAP_FILE
CFLAGS += -DTOUCH_DEPENDENCY
#CFLAGS += -DSERIAL_SCAN
CFLAGS += -DXORWOW_SCAN
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

CFLAGS += -I./include

CFLAGS_PAPI = -I$(PWD)/papi/src/install/include/ -DWITH_PAPI_LIB
LDFLAGS_PAPI = -L$(PWD)/papi/src/install/lib/ -lpapi

.PHONY: all noopt clean ugdb

all: kc

papi: kc_papi

kc_papi: $(sources)
	$(CC) $(sources) -o $(TARGET) $(CFLAGS) $(CFLAGS_PAPI) $(OPT_YES) $(LDFLAGS) $(LDFLAGS_PAPI)

kc: $(sources)
	$(CC) $(sources) -o $(TARGET) $(CFLAGS) $(OPT_YES) $(LDFLAGS)

kc_noopt: $(sources)
	$(CC) $(sources) -o $(TARGET) $(CFLAGS) $(OPT_NO) $(LDFLAGS)

clean:
	rm -f $(TARGET) *.o

ugdb:
	ugdb $(TARGET)
