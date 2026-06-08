

FILE_NAME=output.txt
./collect_amd.sh 3250  single-local 64 r &> $FILE_NAME
./collect_amd.sh 3250  single-local 64 rw &>> $FILE_NAME
./collect_amd.sh 3250  single-local 64 stream_rw &>> $FILE_NAME
./collect_amd.sh 3250  single-local 64 ratio &>> $FILE_NAME

r
mem: 3435973836800 bytes, took 10.038 sec, bandwidth: 342.3 GB/s
rw
mem: 6871947673600 bytes, took 25.319 sec, bandwidth: 271.4 GB/s
stream+rw
mem: 7730941132800 bytes, took 26.031 sec, bandwidth: 297.0 GB/s
1.5R_1W
mem: 6871947673600 bytes, took 20.976 sec, bandwidth: 280.0 GB/s

> python plot_bw.py amd/dramblast.txt amd/dramhit.txt amd/growt.txt 