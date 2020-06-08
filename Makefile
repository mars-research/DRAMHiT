CC=g++
CFLAGS=-g -std=c++17 -Wall -DNO_INSERTS -mprefetchwt1 
# This crashes citihash
#-march=sandybridge
LDFLAGS= -lboost_program_options -lz -lnuma -lpthread
TARGET=kmercounter
OPT_YES=-O3
OPT_NO=-O0
sources =  misc_lib.cpp ac_kseq.cpp city/city.cc main.cpp
CFLAGS += -DCALC_STATS
CFLAGS += -DTOUCH_DEPENDENCY
#CFLAGS += -DSERIAL_SCAN
CFLAGS += -DXORWOW_SCAN
#CFLAGS += -DPREFETCH_TOUCH
CFLAGS += -DPREFETCH_TOUCH_WRITE

.PHONY: all noopt clean ugdb

all: kc

kc: $(sources)
	$(CC) $(sources) -o $(TARGET) $(CFLAGS) $(OPT_YES) $(LDFLAGS)

kc_noopt: $(sources)
	$(CC) $(sources) -o $(TARGET) $(CFLAGS) $(OPT_NO) $(LDFLAGS)

mmap_file_noopt: $(sources)
	$(CC) $(sources) -o $(TARGET) $(CFLAGS) -D__MMAP_FILE $(OPT_NO) $(LDFLAGS)

mmap_file: $(sources)
	$(CC) $(sources) -o $(TARGET) $(CFLAGS) -D__MMAP_FILE $(OPT_YES) $(LDFLAGS)

stats: $(sources)
	$(CC) $(sources) -o $(TARGET) $(CFLAGS) -DCALC_STATS $(OPT_YES) $(LDFLAGS)

clean:
	rm -f $(TARGET) *.o

ugdb:
	ugdb $(TARGET)
