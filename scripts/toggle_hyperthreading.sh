#!/usr/bin/env bash
typeset -i core_id
typeset -i sibling_id
typeset -i state

NPROC=$(lscpu | grep "^CPU(s):" | awk '{print $2}')


toggle() {
	for cpu in $(seq 0 $(( ${NPROC} - 1 ))); do
		i="/sys/devices/system/cpu/cpu${cpu}"
		core_id="${i##*cpu}"
		sibling_id="-1"

		if [ -f ${i}/topology/thread_siblings_list ]; then
			sibling_id="$(cut -d',' -f1 ${i}/topology/thread_siblings_list)"
		fi

		if [ $core_id -ne $sibling_id ]; then
			state="$(<${i}/online)"
			echo -n "$((1-state))" > "${i}/online"
			echo "switched ${i}/online to $((1-state))"
		fi
	done
}

ht_control() {
	for cpu in $(seq 0 $(( ${NPROC} - 1 ))); do
		i="/sys/devices/system/cpu/cpu${cpu}"
		core_id="${i##*cpu}"
		sibling_id="-1"

		if [ -f ${i}/topology/thread_siblings_list ]; then
			sibling_id="$(cut -d',' -f1 ${i}/topology/thread_siblings_list)"
		fi

		if [ $core_id -ne $sibling_id ]; then
			state=$1
			echo -n "${state}" > "${i}/online"
			echo "switched ${i}/online to ${state}"
		fi
	done
}


if [ "$1" == "off" ]; then
	ht_control 0
elif [ "$1" == "on" ]; then
	ht_control 1
else
	toggle
fi
