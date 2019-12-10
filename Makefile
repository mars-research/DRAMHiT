CC=g++
CFLAGS=-g -std=c++17 -Wall -O2  -lnuma -lpthread
TARGET=./bin/lpht

all:
	$(CC)  main.cpp -o $(TARGET) $(CFLAGS) city/city.cc

clean:
	rm -f $(TARGET) *.o
