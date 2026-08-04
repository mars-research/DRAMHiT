all: bandwidth.c
	gcc -O3 bandwidth.c -lpthread -lnuma -o bandwidth_rand -DRANDOM
	gcc -O3 bandwidth.c -lpthread -lnuma -o bandwidth_seq -DSEQUENTIAL
