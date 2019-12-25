CC=g++
CFLAGS=-g -std=c++17 -Wall -lnuma -lpthread -DNDEBUG
TARGET=./bin/lpht

all: clean
	$(CC) -O3 main.cpp -o $(TARGET) $(CFLAGS) city/city.cc

noopt: clean
	$(CC) -O0 main.cpp -o $(TARGET) $(CFLAGS) city/city.cc	

clean:
	rm -f $(TARGET) *.o
