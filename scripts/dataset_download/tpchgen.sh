git clone https://github.com/electrum/tpch-dbgen.git
make -C tpch-dbgen -j
cd tpch-dbgen && ./dbgen -s $(1:-DEFAULT_DATA_SCALE) -f
cp tpch-dbgen/*.tbl . -f