

FILE_NAME=output.txt
#!/bin/bash

if [ "$#" -ne 1 ]; then
     echo "Usage: ./collect.sh <amd|intel> ʕ•ᴥ•ʔ"
     exit 1
fi

if [ "$1" = "amd" ]; then
    ./collect.sh 3250 single-local 64 amd r &>  "$FILE_NAME"
    ./collect.sh 3250 single-local 64 amd rw &>> "$FILE_NAME"
    ./collect.sh 3250 single-local 64 amd stream_rw &>> "$FILE_NAME"
    ./collect.sh 3250 single-local 64 amd ratio &>> "$FILE_NAME"
else
    # ./collect.sh 2500 single-local 64 intel r &>  "$FILE_NAME"
    # ./collect.sh 2500 single-local 64 intel rw &>> "$FILE_NAME"
    # ./collect.sh 2500 single-local 64 intel stream_rw &>> "$FILE_NAME"
    # ./collect.sh 2500 single-local 64 intel ratio &>> "$FILE_NAME"

    # dual socket
    ./collect.sh 2500 even 64 intel r &>  "$FILE_NAME"
    ./collect.sh 2500 even 64 intel rw &>> "$FILE_NAME"
    ./collect.sh 2500 even 64 intel stream_rw &>> "$FILE_NAME"
    ./collect.sh 2500 even 64 intel ratio &>> "$FILE_NAME"

    # intel's pmu events report memory transactions, ie, 64 bytes each, normalize to GBs
  awk '
    /unc_m_cas_count\.(all|rd|wr)/ {
        count = $2
        gsub(/,/, "", count)
        gbs = count * 64 / 1000000000.0
        printf "%12s %10.3f GB/s %s\n", $1, gbs, $3
        next
    }
    { print }
    ' "$FILE_NAME" > "${FILE_NAME}.gbs"
fi