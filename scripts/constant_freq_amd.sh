#!/usr/bin/env bash
CPU_FREQ_KHZ=3250000
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

disable_turbo() {
	echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost
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
