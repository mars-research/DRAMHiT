import os
import subprocess
import re
import sys

def get_data(in_file_name):
    data = {}
    line_count = 0
    capture_data = False

    with open(in_file_name, 'r') as f:
        for line in f:
            if "Thread ID: 0" in line:
                capture_data = True
                line_count = 0  # Reset count when finding thread 0
                continue  # Move to next line

            if capture_data and line_count < 4:
                tokens = line.strip().split(":")
                if len(tokens) >= 2:
                    data[tokens[0].strip()] = tokens[1].strip()
                    line_count += 1
        
    return data

def write_data(data):
    for e in data:
        print(f"{e}: {data[e]}")
        sys.stdout.flush()  # Flush output immediately
    

def get_next_events(start_line, perf_list):
    events = []
    with open(perf_list, 'r') as f:
        lines = f.readlines()
        next_line = min(start_line + 4, len(lines))
        for i in range(start_line, next_line):
            event_name = lines[i].split(',')[0].strip()
            events.append(event_name)
    return events, next_line

perf_list = "/opt/DRAMHiT/perf_counters.txt"
event_tmp = "/opt/DRAMHiT/perf_cnt.txt"
total_lines = sum(1 for _ in open(perf_list))
next_line = 0

# Ensure event_tmp is initialized to empty
with open(event_tmp, 'w') as f:
    pass

while next_line < total_lines:
    events, next_line = get_next_events(next_line, perf_list)
    with open(event_tmp, 'w') as f:
        f.write("\n".join(events))
        f.flush()

    subprocess.run([
        "sudo", "/opt/DRAMHiT/u.sh", "large", "56"
    ], stdout=open('1.txt', 'w'))
    
    data = get_data('1.txt')
    write_data(data)