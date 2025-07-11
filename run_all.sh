
cmake -S . -B build -DOLD_DRAMHiT=ON -DBUCKETIZATION=OFF -DBRANCH=branched -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=OFF
cmake --build ./build
./u.sh large local 64 | grep mops > dramhit_base.txt
./u.sh large remote 128 | grep mops > remote_dramhit_base.txt

cmake -S . -B build -DOLD_DRAMHiT=OFF -DBUCKETIZATION=OFF -DBRANCH=branched -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=OFF
cmake --build ./build
./u.sh large local 64 | grep mops > dramhit_new.txt
./u.sh large remote 128 | grep mops > remote_dramhit_new.txt

cmake -S . -B build -DOLD_DRAMHiT=ON -DBUCKETIZATION=ON -DBRANCH=branched -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=OFF
cmake --build ./build
./u.sh large local 64 | grep mops > dramhit_base_bucket.txt
./u.sh large remote 128 | grep mops > remote_dramhit_base_bucket.txt

cmake -S . -B build -DOLD_DRAMHiT=ON -DBUCKETIZATION=ON -DBRANCH=simd -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=OFF
cmake --build ./build
./u.sh large local 64 | grep mops > dramhit_base_bucket_simd.txt
./u.sh large remote 128 | grep mops > remote_dramhit_base_bucket_simd.txt

cmake -S . -B build -DOLD_DRAMHiT=OFF -DBUCKETIZATION=ON -DBRANCH=simd -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=OFF
cmake --build ./build
./u.sh large local 64 | grep mops > dramhit_new_bucket_simd.txt
./u.sh large remote 128 | grep mops > remote_dramhit_new_bucket_simd.txt

cmake -S . -B build -DOLD_DRAMHiT=OFF -DBUCKETIZATION=ON -DBRANCH=simd -DDRAMHiT_MANUAL_INLINE=ON -DUNIFORM_PROBING=OFF
cmake --build ./build
./u.sh large local 64 | grep mops > dramhit_new_bucket_simd_inline.txt
./u.sh large remote 128 | grep mops > remote_dramhit_new_bucket_simd_inline.txt

cmake -S . -B build -DOLD_DRAMHiT=OFF -DBUCKETIZATION=ON -DBRANCH=simd -DDRAMHiT_MANUAL_INLINE=ON -DUNIFORM_PROBING=ON
cmake --build ./build
./u.sh large local 64 | grep mops > dramhit_new_bucket_simd_inline_uniform.txt
./u.sh large remote 128 | grep mops > remote_dramhit_new_bucket_simd_inline_uniform.txt

