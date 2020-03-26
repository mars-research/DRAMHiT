CC=g++
CFLAGS=-g -std=c++17 -Wall -O3 -DNDEBUG
LDFLAGS= -lboost_program_options -lz -lnuma -lpthread
TARGET=./bin/lpht

all:
	$(CC)  main.cpp -o $(TARGET) $(CFLAGS) $(LDFLAGS) city/city.cc

clean:
	rm -f $(TARGET) *.o
