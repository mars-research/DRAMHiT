#!/bin/bash
# enable counters and load uncore counters
echo -1 | sudo tee /proc/sys/kernel/perf_event_paranoid
sudo modprobe amd-uncore
