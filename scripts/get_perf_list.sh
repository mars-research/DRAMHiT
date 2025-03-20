
#!/bin/bash

set -e

# Get the script's directory
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Go to the newly cloned repository
cd "$script_dir/../perf-cpp" || exit

# Run cmake and build perf-list
cmake .
cmake --build . --target perf-list

cd ..