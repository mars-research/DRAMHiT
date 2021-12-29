#!/usr/bin/env bash

for filename in ./*.txt; do
  echo "downloading files from $filename, 8 files in parallel"
  basename=${filename##*/}
  basename="${basename%.txt}"
  echo "$basename"
  if [ ! -d ./$basename ]; then
	  mkdir -p ./$basename
  fi
  cat $f | xargs -n 1 -P 8 wget -q
done
