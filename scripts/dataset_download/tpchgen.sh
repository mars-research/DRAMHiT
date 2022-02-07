git clone https://github.com/electrum/tpch-dbgen.git
make -C tpch-dbgen -j
DATA_SCALE=${DATA_SCALE:=0.001}
cd tpch-dbgen && ./dbgen -s ${DATA_SCALE} -f
cp *.tbl .. -f