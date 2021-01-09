#!/bin/bash

echo 0 > /proc/sys/kernel/perf_event_paranoid
echo 0 > /proc/sys/kernel/kptr_restrict
echo 0 > /proc/sys/kernel/yama/ptrace_scope
