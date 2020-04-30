CC=g++
CFLAGS=-g -std=c++17 -Wall -DNDEBUG
OPT_YES=-O3
OPT_NO=-O0
LDFLAGS= -lboost_program_options -lz -lnuma -lpthread -laio
TARGET=./bin/lpht

all:
	$(CC)  main.cpp -o $(TARGET) $(CFLAGS) $(OPT_YES) $(LDFLAGS) city/city.cc

noopt:
	$(CC)  main.cpp -o $(TARGET) $(CFLAGS) $(OPT_NO) $(LDFLAGS)  city/city.cc


clean:
	rm -f $(TARGET) *.o
