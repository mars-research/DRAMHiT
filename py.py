import sys


THRESHOLD = 1.0 #CHANGE ME

def filter_large_values(filename):
    global THRESHOLD
    try:
        with open(filename, 'r') as file:
            for line in file:
                parts = line.rsplit("=", 1)  # Split from the right, keeping the last part
                if len(parts) == 2:
                    try:
                        value = float(parts[1].strip())
                        if abs(value) > THRESHOLD:
                            print(line.strip())
                    except ValueError:
                         print("\n\nEXCEPTION OCCURED!! ValueError\n\n")
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filename>")
    else:
        filter_large_values(sys.argv[1])