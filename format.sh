# Format selected folders

# Format folders recursively
for folder in examples unittests include/input_reader src/input_reader; do
  find $folder -regex '.*\.\(cpp\|hpp\|cc\|cxx\|c\|h\)' -exec clang-format -style=file -i {} \;
done 

# Format files
for file in include/tests/HashjoinTest.hpp src/tests/hashjoin_test.cpp; do
  clang-format -style=file -i $file
done 