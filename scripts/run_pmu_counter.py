import os
import subprocess
import re
import sys

def parse_thread_data(file_name):
    thread_data = {}
    line_count = 0
    capture_data = False

    with open(file_name, 'r') as f:
        for line in f:
            if "Thread ID: 0" in line:
                capture_data = True
                line_count = 0  # Reset count when finding thread 0
                continue  # Move to next line

            if capture_data and line_count < 4:
                tokens = line.strip().split(":")
                if len(tokens) == 2:
                    thread_data[tokens[0].strip()] = tokens[1].strip()
                    line_count += 1

    return thread_data

def process_events(event_tmp_file, data1, data2):
    with open(event_tmp_file, 'r') as f:
        for event in f:
            event = event.strip()
            if event in data1 and event in data2:
                result = float(data1[event]) - float(data2[event])
                print(f"{event}: {data1[event]} - {data2[event]} = {result}")
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

size = 134217728 #2048
insertFactor = 10 #100000
batch = 16

perf_list = "./perf-cpp/perf_list.csv"
event_tmp = "./event_tmp.txt"

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
    # print()
    # print("Running 1-thread execution...")
    subprocess.run([
        "sudo", "/opt/DRAMHiT/build/dramhit",
        "--perf_cnt_path", event_tmp,
        "--perf_def_path", perf_list,
        "--find_queue_sz", "32",
        "--ht-fill", "10",
        "--ht-type", "3",
        "--insert-factor", str(insertFactor),
        "--num-threads", "1",
        "--numa-split", "1",
        "--no-prefetch", "0",
        "--mode", "11",
        "--ht-size", str(size),
        "--skew", "0.01",
        "--hw-pref", "0",
        "--batch-len", str(batch)
    ], stdout=open('1.txt', 'w'))
    
    # print("Running 2-thread execution...")
    subprocess.run([
        "sudo", "/opt/DRAMHiT/build/dramhit",
        "--perf_cnt_path", event_tmp,
        "--perf_def_path", perf_list,
        "--find_queue_sz", "32",
        "--ht-fill", "10",
        "--ht-type", "3",
        "--insert-factor", str(insertFactor),
        "--num-threads", "2",
        "--numa-split", "1",
        "--no-prefetch", "0",
        "--mode", "11",
        "--ht-size", str(size),
        "--skew", "0.01",
        "--hw-pref", "0",
        "--batch-len", str(batch)
    ], stdout=open('2.txt', 'w'))
    
    data1 = parse_thread_data('1.txt')
    data2 = parse_thread_data('2.txt')
    process_events(event_tmp, data1, data2)
    
    

print("Reached end of file in perf_list.csv")
