CC=g++
CFLAGS=-g -std=c++17 -Wall -O3  -lnuma -lpthread -DNDEBUG
LDFLAGS= -lboost_program_options
TARGET=./bin/lpht

all: clean
	$(CC)  main.cpp -o $(TARGET) $(CFLAGS) $(LDFLAGS) city/city.cc

clean:
	rm -f $(TARGET) *.o
