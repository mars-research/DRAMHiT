
> cd /opt/DRAMHiT

# clone CLHT
> git clone https://github.com/LPD-EPFL/CLHT.git
> cd CLHT

# build ssmem
> git clone https://github.com/LPD-EPFL/ssmem.git
> cd ssmem && make libssmem.a
> mkdir -p ../external/lib ../external/include
> cp libssmem.a ../external/lib/
> cp include/ssmem.h ../external/include/
> cd ..

# build sspfd
> git clone https://github.com/trigonak/sspfd.git
> cd sspfd && make
> cp libsspfd.a ../external/lib/
> cp sspfd.h ../external/include/
> cd ..

# We are now at ./CLHT/
# PICK WHICH CLHT 
# Lock-based, resizable
make libclht_lb_res.a
# Lock-based, no resize
make libclht_lb.a
# Lock-free, resizable
make libclht_lf_res.a
# Lock-free, no resize (can hang if full)
make libclht_lf.a

# building example.cpp

> g++ -std=c++11 -pthread -Iinclude -Iexternal/include example.cpp \
    -L. -lclht -Lexternal/lib -lssmem -lsspfd \
    -DCORES_PER_SOCKET=64 -DNUMBER_OF_SOCKETS=2 -DCACHE_LINE_SIZE=64 \
    -o example_cpp
> ./example_cpp





