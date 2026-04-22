
import argparse
import subprocess
import re
import statistics
import sys
import shlex

def main():
    # Set up command line argument parsing
    parser = argparse.ArgumentParser(description="Run a command N times and compute stats on get_mops and set_mops.")
    parser.add_argument("num_runs", type=int, help="Number of times to run the command")
    parser.add_argument("command", type=str, help="The command to execute (enclose in quotes)")

    args = parser.parse_args()

    get_mops_list = []
    set_mops_list = []

    # Regular expressions to find the exact numbers in your output string
    # Matches "set_mops : 1800" or "set_mops:1800"
    set_mops_pattern = re.compile(r"set_mops\s*:\s*(\d+)")
    get_mops_pattern = re.compile(r"get_mops\s*:\s*(\d+)")

    # Safely split the command string into a list of arguments
    cmd_args = shlex.split(args.command)

    print(f"Running command {args.num_runs} times...\n")

    for i in range(args.num_runs):
        try:
            # Execute the command and capture standard output
            result = subprocess.run(cmd_args, capture_output=True, text=True, check=True)
            output = result.stdout

            # Search the output for our target metrics
            set_match = set_mops_pattern.search(output)
            get_match = get_mops_pattern.search(output)

            if set_match and get_match:
                set_val = int(set_match.group(1))
                get_val = int(get_match.group(1))

                set_mops_list.append(set_val)
                get_mops_list.append(get_val)
                print(f"Run {i+1}: set_mops = {set_val}, get_mops = {get_val}")
            else:
                print(f"Warning: Could not find set_mops or get_mops in run {i+1}. Output was:\n{output.strip()}")

        except subprocess.CalledProcessError as e:
            print(f"Error running command on iteration {i+1}.")
            print(f"Command output: {e.output}")
            sys.exit(1)
        except FileNotFoundError:
            print(f"Error: The command '{cmd_args[0]}' was not found. Check your path.")
            sys.exit(1)

    # Ensure we collected data before trying to do math
    if not get_mops_list or not set_mops_list:
        print("\nNo valid data extracted. Exiting.")
        return

    # Calculate and print statistics
    print("\n" + "=" * 40)
    print(f"RESULTS OVER {len(get_mops_list)} SUCCESSFUL RUNS")
    print("=" * 40)

    for name, data in [("SET_MOPS", set_mops_list), ("GET_MOPS", get_mops_list)]:
        mean_val = statistics.mean(data)
        median_val = statistics.median(data)
        # Variance requires at least 2 data points
        variance_val = statistics.variance(data) if len(data) > 1 else 0.0

        print(f"{name}:")
        print(f"  Average (Mean): {mean_val:.2f}")
        print(f"  Median:         {median_val:.2f}")
        print(f"  Variance:       {variance_val:.2f}")
        print("-" * 40)

if __name__ == "__main__":
    main()
