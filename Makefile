CC=g++
CFLAGS=-g -std=c++17 #-Wall 
TARGET=./bin/lpht

all:
	$(CC)  main.cpp -o $(TARGET) $(CFLAGS) kmer_class.cpp city.cc

clean:
	rm -f $(TARGET) *.o
