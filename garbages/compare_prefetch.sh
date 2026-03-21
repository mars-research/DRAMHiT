cmake -S . -B build -DOLD_DRAMHiT=ON -DBUCKETIZATION=OFF -DBRANCH=branched -DREAD_BEFORE_CAS=ON
cmake --build ./build
./u.sh large local 64 | grep mops > cp_dramhit_old.txt
./u.sh large remote 128 | grep mops > cp_remote_dramhit_old.txt

cmake -S . -B build -DOLD_DRAMHiT=OFF -DBUCKETIZATION=OFF -DBRANCH=branched -DREAD_BEFORE_CAS=ON
cmake --build ./build
./u.sh large local 64 | grep mops > cp_dramhit_new.txt
./u.sh large remote 128 | grep mops > cp_remote_dramhit_new.txt

cmake -S . -B build -DOLD_DRAMHiT=ON -DBUCKETIZATION=ON -DBRANCH=simd -DREAD_BEFORE_CAS=ON
cmake --build ./build
./u.sh large local 64 | grep mops > cp_dramhit_old_simd.txt
./u.sh large remote 128 | grep mops > cp_remote_dramhit_old_simd.txt

cmake -S . -B build -DOLD_DRAMHiT=OFF -DBUCKETIZATION=ON -DBRANCH=simd -DREAD_BEFORE_CAS=ON
cmake --build ./build
./u.sh large local 64 | grep mops > cp_dramhit_new_simd.txt
./u.sh large remote 128 | grep mops > cp_remote_dramhit_new_simd.txt