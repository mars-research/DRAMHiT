#!/usr/bin/env bash
set -e
CPU_FREQ_KHZ=2500000
#RDMSR=$(which rdmsr)
#WRMSR=$(which wrmsr)
#echo $RDMSR
#echo $WRMSR
# Get the input (e.g., 3.25GHz) and convert to uppercase for easier matching
INPUT=$(echo "$1" | tr '[:lower:]' '[:upper:]')

# Extract the numeric part (including decimals)
NUM=$(echo "$INPUT" | grep -oE '^[0-9.]+')

# Extract the unit part
UNIT=$(echo "$INPUT" | grep -oE '[A-Z]+$')

case "$UNIT" in
    GHZ)
        # GHz to kHz: Multiply by 1,000,000
        # Use 'bc' to handle decimals
        CPU_FREQ_KHZ=$(echo "$NUM * 1000000 / 1" | bc)
        ;;
    MHZ)
        # MHz to kHz: Multiply by 1,000
        CPU_FREQ_KHZ=$(echo "$NUM * 1000 / 1" | bc)
        ;;
    KHZ)
        CPU_FREQ_KHZ=$(echo "$NUM / 1" | bc)
        ;;
    *)
        echo "Usage: $0 3.25GHz"
        exit 1
        ;;
esac

get_rated_cpufreq() {
	echo "Target Frequency: ${CPU_FREQ_KHZ} kHz"
}

set_freq() {
	# make both min and max to the advertised freq
	if [ -d /sys/devices/system/cpu/cpu0/cpufreq/ ]; then
		for i in $(ls /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq); do echo "${CPU_FREQ_KHZ}" | sudo tee $i > /dev/null 2>&1 ;done
		for i in $(ls /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq); do echo "${CPU_FREQ_KHZ}" | sudo tee $i > /dev/null 2>&1 ;done
	fi
}

disable_cstate() {
	echo "Disabling C-states"
	for i in $(ls /sys/devices/system/cpu/cpu*/cpuidle/state*/disable); do echo "1" | sudo tee $i > /dev/null 2>&1 ;done
}

# Let us be normal ....
disable_turbo() {

	echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo

#	if ! [ -x "$(command -v ${RDMSR})" ]; then
#		echo "Installing msr-tools ..."
#		sudo apt update && sudo apt install msr-tools
#		RDMSR=$(which rdmsr)
#		WRMSR=$(which wrmsr)
#	fi
#
#	echo "Loading msr module"
#	sudo modprobe msr
#
#	# make sure we have this module loaded
#	if [ -z "$(lsmod | grep '^msr')" ]; then
#		echo "ERROR: Fail to load msr module into kernel!"
#		exit
#	fi
#
#	# disable turbo boost (bit 38 on 0x1a0 msr)
#	TURBO_BOOST_BIT=38
#	echo "Disabling turboboost"
#	sudo $WRMSR -a 0x1a0 "$(printf '0x%x' "$(( $(sudo $RDMSR -d 0x1a0) | (1 << TURBO_BOOST_BIT) ))")"
}

set_const_freq() {
	set_freq;
	disable_cstate;
	disable_turbo;
}

dump_sys_state() {
	if [ -d /sys/devices/system/cpu/cpu0/cpufreq/ ]; then
		cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
		cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	fi
}

get_rated_cpufreq;
set_const_freq;
dump_sys_state;
