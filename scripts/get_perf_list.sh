
#!/bin/bash

# Get the script's directory
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
echo "Script is located at: $script_dir"

# Clone the perf-cpp repository inside the script's directory
git clone https://github.com/jmuehlig/perf-cpp "$script_dir/../perf-cpp"

# Go to the newly cloned repository
cd "$script_dir/../perf-cpp" || exit

# Run cmake and build perf-list
cmake .
cmake --build . --target perf-list

cd ..