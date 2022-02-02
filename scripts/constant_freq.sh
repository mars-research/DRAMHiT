#!/usr/bin/env bash

CPU_FREQ_KHZ=0
RDMSR=$(which rdmsr)
WRMSR=$(which wrmsr)

get_rated_cpufreq() {
	# lscpu reports the rated processor freq in %1.2f format
	CPU_FREQ_GHZ=$(lscpu | grep -o "[0-9\.]\+GHz" | grep -o "[0-9\.]\+")
	CPU_FREQ_KHZ=$(printf "%.0f" $(echo "${CPU_FREQ_GHZ} * 10^9" | bc))
	echo $CPU_FREQ_KHZ
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
	if ! [ -x "$(command -v ${RDMSR})" ]; then
		echo "Installing msr-tools ..."
		sudo apt install msr-tools
	fi

	# make sure we have this module loaded
	if [ -z "$(lsmod | grep '^msr')" ]; then
		echo "Loading msr module"
		sudo modprobe msr
	fi

	# disable turbo boost (bit 38 on 0x1a0 msr)
	TURBO_BOOST_BIT=38
	echo "Disabling turboboost"
	sudo ${WRMSR} -a 0x1a0 $(printf "0x%x" $(($(sudo ${RDMSR} -d 0x1a0)|(1<<${TURBO_BOOST_BIT}))))
}

set_const_freq() {
	set_freq;

	disable_cstate;

	disable_turbo;
}

dump_sys_state() {
	if [ -d /sys/devices/system/cpu/cpu0/cpufreq/ ]; then
		for i in $(ls /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq); do echo "$i: $(cat $i)";done
		for i in $(ls /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq); do echo "$i: $(cat $i)";done
	fi

	for i in $(ls /sys/devices/system/cpu/cpu*/cpuidle/state*/disable); do echo "$i: $(cat $i)";done
	sudo ${RDMSR} -a 0x1a0 -f 38:38
}

get_rated_cpufreq;
set_const_freq;
dump_sys_state;
