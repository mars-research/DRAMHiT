CC=g++
CFLAGS=-g -std=c++17 -Wall -O2 -DALPHANUM_KMERS
TARGET=./bin/lpht

all:
	$(CC)  main.cpp -o $(TARGET) $(CFLAGS) city/city.cc

clean:
	rm -f $(TARGET) *.o
