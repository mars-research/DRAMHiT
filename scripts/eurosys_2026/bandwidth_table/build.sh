

if [ "$#" -ne 1 ]; then
     echo "Usage: $0 <cpu_freq_mhz>"
     exit 1
fi
CPU_FREQ=$1
HOME_DIR=/opt/DRAMHiT
cmake -S $HOME_DIR -B $HOME_DIR/build -DCPUFREQ_MHZ=$CPU_FREQ -DPREFETCH=L2
cmake --build $HOME_DIR/build
