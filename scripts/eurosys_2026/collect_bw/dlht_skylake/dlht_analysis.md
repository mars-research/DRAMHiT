
# 1mb
> (16,000*16)/ (1*1024*1024)=0.244140625
set_cycles : 1141, get_cycles : 491, set_mops : 140, get_mops : 325
# 8mb
> (128,000*16)/ (8*1024*1024) = 0.244140625
set_cycles : 419, get_cycles : 68, set_mops : 381, get_mops : 2351
# 67 mb
> 1,000,000*16 / (67*1024*1024)=0.22774312033
set_cycles : 309, get_cycles : 64, set_mops : 516, get_mops : 2466

# 512mb
> 8,000,000*16/1024^3 / .5 = 0.2384185791
set_cycles : 319, get_cycles : 111, set_mops : 500, get_mops : 1440
# 4gb
> (64,000,000*16/1024^3 )/ 4 = 0.2384185791
set_cycles : 306, get_cycles : 113, set_mops : 521, get_mops : 1414
# 64gb
> (1,000,000,000*16/1024^3) /64 = 0.23283064365
set_cycles : 317, get_cycles : 129, set_mops : 503, get_mops : 1233


Normalizd across channels (skylake has 12): (X/12)
then scale to what performance would be with only 8 channels: (X/12)*8 

Scaled 8 channels performance:
| HT Size     | set_mops | get_mops |
| ----------- | -------: | -------: |
| 1 MB        |    93.33 |   216.67 |
| 8 MB        |   221.33 |  1536.00 |
| 67 MB       |   344.00 |  1644.00 |
| 512 MB      |   333.33 |   960.00 |
| 4 GB        |   347.33 |   942.67 |
| 64 GB       |   335.33 |   822.00 |


elif [ "$test" = "large" ]; then
    # size=4294967296
    size=65536 #1mb
    # size=524288 #8mb
    # size=4194304 64mb
    # size=33554432 512mb
    # size=268435456 4gb
    # size=536870912
    # size=4294967296 64gb
    insertFactor=1
    readFactor=1000000
fi