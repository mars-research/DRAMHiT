CC=g++
CFLAGS=-g -O #-Wall 
TARGET=./bin/lpht

all:
	$(CC)  main.cpp -o $(TARGET) $(CFLAGS) kmer_class.cpp city.cc

clean:
	rm -f $(TARGET) *.o
