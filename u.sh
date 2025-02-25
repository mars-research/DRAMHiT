# /opt/mnt/DRAMHiT/build/dramhit --ht-fill 75 --insert-factor 10 --num-threads 56 --ht-type 3 --numa-split 1 --no-prefetch 0 --mode 11 --ht-size 134217728 --skew 0.01 --hw-pref 0 

# objdump -d ./build/dramhit

#  rm build/CMakeCache.txt
#     cmake -S . -B build
#     cmake --build build/ --clean-first


# /opt/mnt/DRAMHiT/build/dramhit --ht-fill 70 --insert-factor 10 --num-threads 56 --ht-type 3 --numa-split 1 --no-prefetch 0 --mode 11 --ht-size 134217728 --skew 0.01 --hw-pref 0 --batch-len 112


#2gb 
#size=1024 
size=268435456
insertFactor=10
numThreads=56
batch=16

# 128,144 fastest 
# for batch in 80 96 112 128 144 160 176 192 208 224 240 256 272
# do
#     ./build/dramhit --ht-fill 70 --insert-factor $insertFactor --num-threads $numThreads --ht-type 3 --numa-split 1 --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01 --hw-pref 0 --batch-len $batch
# done

# /opt/mnt/DRAMHiT/build/dramhit --ht-fill 70 --insert-factor 10 --num-threads 56 --ht-type 3 --numa-split 1 --no-prefetch 0 --mode 11 --ht-size 134217728 --skew 0.01 --hw-pref 0 --batch-len  1024

for fill in 10 20 30 40 50 60 70 80 90
do  
    sudo ./build/dramhit --ht-fill $fill --insert-factor $insertFactor --num-threads $numThreads --ht-type 3 --numa-split 1 --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01 --hw-pref 0 --batch-len $batch
done


#sudo ./build/dramhit --ht-fill 80 --insert-factor $insertFactor --num-threads $numThreads --ht-type 3 --numa-split 1 --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01 --hw-pref 0 --batch-len $batch

