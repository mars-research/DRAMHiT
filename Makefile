CC=g++
CFLAGS=-g -std=c++17 -Wall -DNDEBUG
LDFLAGS= -lboost_program_options -lz -lnuma -lpthread
TARGET=./kmercounter
STATS_YES=-DCALC_STATS
OPT_YES=-O3
OPT_NO=-O0

.PHONY: all noopt clean ugdb

all:
	$(CC)  main.cpp ac_kseq.cpp  city/city.cc -o $(TARGET) $(CFLAGS) $(OPT_YES) $(LDFLAGS)

stats:
	$(CC)  main.cpp -o $(TARGET) $(CFLAGS) $(STATS_YES) $(OPT_YES) $(LDFLAGS) city/city.cc

noopt:
	$(CC)  main.cpp -o $(TARGET) $(CFLAGS) $(OPT_NO) $(LDFLAGS)  city/city.cc


clean:
	rm -f $(TARGET) *.o

ugdb:
	ugdb $(TARGET)