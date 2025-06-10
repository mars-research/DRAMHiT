import os
import subprocess
import re
import sys

#CHANGE ME, dir where build/ folder is at
set_dir= "/opt/dramhit/dramhit/"

# Parses output from dramhit with perfcpp output
def get_data(in_file_name, events):
    data = {}
    with open(in_file_name, 'r') as f:
        for line in f:
            for e in events:
                if e in line:
                    tokens = line.strip().split(":")
                    if len(tokens) == 3:
                        data[tokens[0].strip()] = [tokens[1].strip(), tokens[2].strip()]
    
    for k in list(data.keys()): 
        if (k in events) == False:
            data.pop(k)                   
    return data

# Print our event counter data to std out
def write_data(data):
    for e in data:
        print(f"{e},{data[e][0]},{data[e][1]}")
        sys.stdout.flush()  # Flush output immediately
    
#Gets 4 lines from file 
def get_next_events(start_line, perf_list):
    events = []
    with open(perf_list, 'r') as f:
        lines = f.readlines()
        next_line = min(start_line + 4, len(lines))
        for i in range(start_line, next_line):
            event_name = lines[i].split(',')[0].strip()
            events.append(event_name)
    return events, next_line

# file with all counters
perf_list = set_dir+"./perf_counters_aggregate"
# temp file for current counters being run (4 at at time for no multiplexing)
event_tmp = set_dir+"./perf_cnt.txt"
# total counters = total lines in our counter file
total_lines = sum(1 for _ in open(perf_list))
# start from beggining of file
next_line = 0
# output file name
output_tmp = 'temp_dramhit_output.txt'

# Set the below
size = 'large'
thread_num = '56'
fill = '10'

# Ensure event_tmp is initialized to empty
with open(event_tmp, 'w') as f:
    pass
# Iterate through all our counters
while next_line < total_lines:
    # get next 4 counters
    events, next_line = get_next_events(next_line, perf_list)
    # write the 4 counters to our temp file
    with open(event_tmp, 'w') as f:
        f.write("\n".join(events))
        f.flush()
    # RUN dramhit with those 4 counters
    subprocess.run([
        "sudo", set_dir+"./u.sh", size, thread_num, fill
    ], stdout=open(output_tmp, 'w'))
    # parse results and write to stdo
    data = get_data(output_tmp, events)
    write_data(data)

# clean up temp files
os.remove(output_tmp)  

            