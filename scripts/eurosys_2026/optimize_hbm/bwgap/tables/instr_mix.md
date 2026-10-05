## rck dramblast, find phase (fill 10), from logs/E3_sampling/dramhit_f10
find_ops = 5368709100; samples: find_batch 120712, harness find-fill loop 28957; loop-body entry executed ~2784 times (1.037x per find)

| region | instr/find | share of region | note |
|---|---|---|---|
| find_batch loop body 0x43dbae-0x43dc5f: LOAD of the bucket | 0.98 | | vmovdqa64 (%r10,%rdi,1),%zmm7 |
| find_batch loop: memory-DEPENDENT | 5.95 | | je, kortestb, kshiftlb, vmovq, vpcmpequq, vpcompressq |
| find_batch loop: independent | 34.02 | | |
| find_batch outside loop (call entry/exit, per 16 finds) | 4.03 | | |
| harness find fill loop 0x46ae80-0x46b090 | 10.79 | | all independent of the table line (loads the key stream instead) |
| **total accounted** | **55.76** | | measured (E2) 55.3-55.8 |

Split: load 0.98, memory-dependent 5.95 (10.7%), independent 48.83 (87.6%)

Loop body classification (static, taint):

```
43dbae   2784 I  lea    (%r9,%rax,1),%rcx                 
43dbb2   2584 I  mov    0x10(%rcx),%edi                   
43dbb5   2765 I  mov    (%rcx),%r11                       
43dbb8   2625 I  shl    $0x4,%rdi                         
43dbbc   2624 I  lea    0x100(%rax),%rbx                  
43dbc3   2621 L  vmovdqa64 (%r10,%rdi,1),%zmm7            LOADS the line
43dbca   2690 I  and    %r8,%rbx                          
43dbcd   2621 I  vpbroadcastq %r11,%zmm8                  
43dbd3   2646 D  vpcmpequq %zmm8,%zmm7,%k1{%k2}           reads tainted v7
43dbda   2778 I  mov    0x10(%r9,%rbx,1),%esi             
43dbdf   2684 I  add    $0x20,%rax                        
43dbe3   2642 I  shl    $0x4,%rsi                         
43dbe7   2619 I  and    %r8,%rax                          
43dbea   2676 I  prefetcht0 (%r10,%rsi,1)                 
43dbef   2308 D  kortestb %k1,%k1                         reads tainted k1
43dbf3   2988 D  je     43db60                            branches on tainted flags
43dbf9   2764 I  mov    0x14(%rcx),%ecx                   
43dbfc   2671 D  kshiftlb $0x1,%k1,%k6                    reads tainted k1
43dc02   2716 D  vpcompressq %zmm7,%zmm0{%k6}{z}          reads tainted k6; reads tainted v7
43dc08   2743 I  mov    %ecx,(%r15)                       
43dc0b   2646 D  vmovq  %xmm0,0x8(%r15)                   reads tainted v0
43dc11   2607 I  add    $0x10,%r15                        
43dc15   2782 I  mov    (%r14),%rbx                       
43dc18   2702 I  mov    %r12,%rsi                         
43dc1b   2682 I  crc32  %rbx,%rsi                         
43dc21   2826 I  mov    %r13d,%r11d                       
43dc24   2672 I  and    %esi,%r11d                        
43dc27   2697 I  vmovd  %r11d,%xmm13                      
43dc2c   2691 I  vpinsrd $0x1,0x10(%r14),%xmm13,%xmm14    
43dc33   2655 I  mov    %r11d,%edi                        
43dc36   2659 I  lea    (%r9,%rdx,1),%rcx                 
43dc3a   2824 I  shl    $0x4,%rdi                         
43dc3e   2646 I  add    $0x20,%rdx                        
43dc42   2768 I  add    $0x18,%r14                        
43dc46   2617 I  prefetcht2 (%r10,%rdi,1)                 
43dc4b   2630 I  and    %r8,%rdx                          
43dc4e   2660 I  mov    %rbx,(%rcx)                       
43dc51   2674 I  mov    %rsi,0x18(%rcx)                   
43dc55   2672 I  vmovq  %xmm14,0x10(%rcx)                 
43dc5a    316 I  cmp    %r14,-0x8(%rsp)                   
43dc5f   4930 I  jne    43dbae                            
```

## bandwidth_rand bw_t1: loop 0x4047d0-0x404802

static loop length 14 instructions (cmp+jne are counted as two instructions by the counter; sampling attributes both to the jne); load 1, dependent 0, independent 13; loop samples 187935 of 187935 in mem_worker (100.0%)

```
4047d0  14879 I  lea    (%r15,%rcx,1),%r9                 
4047d4  10814 I  mov    %r8,%rax                          
4047d7  15836 I  mov    %r8,%rdx                          
4047da  13038 I  crc32  %rcx,%rax                         
4047e0  13292 I  crc32  %r9,%rdx                          
4047e6  13681 I  and    %rsi,%rdx                         
4047e9  13525 I  and    %rsi,%rax                         
4047ec  12789 I  shl    $0x6,%rdx                         
4047f0  14559 I  shl    $0x6,%rax                         
4047f4  11743 I  inc    %rcx                              
4047f7  13692 L  add    (%rdi,%rax,1),%r14                LOADS the line
4047fb  12944 I  prefetcht1 (%rdi,%rdx,1)                 
4047ff      0 I  cmp    %rcx,%r10                         
404802  27143 I  jne    4047d0                            
```

## bandwidth_rand bw_double24: loop 0x405ed8-0x405faa

static loop length 51 instructions (cmp+jne are counted as two instructions by the counter; sampling attributes both to the jne); load 1, dependent 0, independent 50; loop samples 684547 of 684547 in mem_worker (100.0%)

```
405ed8  13400 I  mov    0x28(%rsp),%r14                   
405edd  13633 I  mov    %r13,%r9                          
405ee0  12261 I  lea    (%r14,%r11,1),%r10                
405ee4  15120 I  mov    %r13,%r14                         
405ee7  12934 I  crc32  %r10,%r14                         
405eed  13596 I  mov    0x8(%rsp),%r10                    
405ef2  13435 I  crc32  %r11,%r9                          
405ef8  13087 I  add    %r11,%r10                         
405efb  13651 I  mov    %r10,0x30(%rsp)                   
405f00  13145 I  mov    %r13,%r10                         
405f03  14202 I  and    %r12,%r14                         
405f06  10894 I  crc32q 0x30(%rsp),%r10                   
405f0e  15556 I  and    %r12,%r10                         
405f11  13107 I  and    %r12,%r9                          
405f14  12780 I  shl    $0x6,%r10                         
405f18  13360 I  shl    $0x6,%r9                          
405f1c  14636 I  shl    $0x6,%r14                         
405f20  13269 L  add    (%rbx,%r9,1),%r15                 LOADS the line
405f24  13287 I  prefetcht0 (%rbx,%r10,1)                 
405f29  13456 I  mov    0x38(%rsp),%r9                    
405f2e  12891 I  mov    0x40(%rsp),%r10                   
405f33  13925 I  prefetcht2 (%rbx,%r14,1)                 
405f38  12900 I  add    $0x1,%rax                         
405f3c  12648 I  add    $0x1,%rdx                         
405f40  11773 I  add    $0x1,%rcx                         
405f44  16410 I  add    $0x1,%rsi                         
405f48  13308 I  add    $0x1,%rdi                         
405f4c  11783 I  add    $0x1,%r10                         
405f50  14947 I  add    $0x1,%r9                          
405f54  13648 I  add    $0x1,%r8                          
405f58  13827 I  add    $0x1,%rax                         
405f5c  12946 I  add    $0x1,%rdx                         
405f60  13442 I  add    $0x1,%rcx                         
405f64  13145 I  add    $0x1,%rsi                         
405f68  13866 I  add    $0x1,%rdi                         
405f6c  13026 I  add    $0x1,%r10                         
405f70   6348 I  add    $0x1,%r9                          
405f74  18918 I  add    $0x1,%r8                          
405f78  15038 I  add    $0x1,%rax                         
405f7c  13747 I  add    $0x1,%rdx                         
405f80  11554 I  add    $0x1,%rcx                         
405f84  15383 I  add    $0x1,%rsi                         
405f88  13093 I  add    $0x1,%rdi                         
405f8c  13783 I  add    $0x1,%r10                         
405f90  13186 I  add    $0x1,%r9                          
405f94  13281 I  add    $0x1,%r8                          
405f98  13318 I  inc    %r11                              
405f9b  13574 I  mov    %r10,0x40(%rsp)                   
405fa0  13585 I  mov    %r9,0x38(%rsp)                    
405fa5      0 I  cmp    %r11,0x50(%rsp)                   
405faa  26445 I  jne    405ed8                            
```
