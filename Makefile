CC=g++
CFLAGS=-g -std=c++17 -Wall -DNDEBUG
LDFLAGS= -lboost_program_options -lz -lnuma -lpthread -laio
TARGET=./kmercounter
STATS_YES=-DCALC_STATS
OPT_YES=-O3
OPT_NO=-O0


.PHONY: all noopt clean ugdb


all:
	$(CC)  main.cpp -o $(TARGET) $(CFLAGS) $(OPT_YES) $(LDFLAGS) city/city.cc

parser-yu:
	$(CC)  parser_yu.cpp -o $(TARGET) $(CFLAGS) $(OPT_YES) $(LDFLAGS) city/city.cc	

stats:
	$(CC)  main.cpp -o $(TARGET) $(CFLAGS) $(STATS_YES) $(OPT_YES) $(LDFLAGS) city/city.cc

noopt:
	$(CC)  main.cpp -o $(TARGET) $(CFLAGS) $(OPT_NO) $(LDFLAGS)  city/city.cc


clean:
	rm -f $(TARGET) *.o

ugdb:
	ugdb $(TARGET)