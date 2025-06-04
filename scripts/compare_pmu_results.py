import sys

# Read data from file
def read_file(file_path):
    data = {}
    with open(file_path, 'r') as file:
        for line in file:
            name, value = line.strip().split(':')
            data[name] = float(value)
    return data

# Subtract corresponding values
def subtract_files(file1, file2):
    data1 = read_file(file1)
    data2 = read_file(file2)
    
    # Subtract the values and print differences
    for name in data1:
        if name in data2:
            diff = data1[name] - data2[name]
            # Can filter output here:
            if(data1[name] != 0 and data2[name] != 0):
                if(diff > 0.0001):
                    print(f"{name:60}= {diff:5.4f} ({data1[name]} - {data2[name]})")


# Ensure the script is called with two arguments
if len(sys.argv) != 3:
    print("Usage: python subtract_files.py <file1> <file2>")
else:
    file1 = sys.argv[1]
    file2 = sys.argv[2]
    subtract_files(file1, file2)
