.intel_syntax noprefix
vmovd  xmm14,DWORD PTR [r9+0xc]
kshiftlb k6,k4,0x1
vpcompressq zmm13{k6}{z},zmm9
vpunpcklqdq xmm15,xmm14,xmm13
mov    r8d,0xf
kmovw  k7,r8d
vshufi32x4 zmm0{k7}{z},zmm15,zmm15,0x0
vmovdqa64 zmm13,zmm0
mov    ecx,0x1
lea    r11,[r15+rbx*1]
lea    r9,[rbx+0x180]
and    r9,rsi
mov    r8d,DWORD PTR [r11+0x8]
andn   edi,r14d,DWORD PTR [r15+r9*1+0x8]
shl    rdi,0x4
andn   r9d,r14d,r8d
shl    r9,0x4
vmovdqa64 zmm7,ZMMWORD PTR [rax+r9*1]
vpbroadcastq zmm2,QWORD PTR [r11]
vpcmpequq k1{k2},zmm7,zmm2
add    rbx,0x10
and    rbx,rsi
prefetcht0 BYTE PTR [rax+rdi*1]
kortestb k1,k1
vmovd  xmm1,DWORD PTR [r11+0xc]
kshiftlb k3,k1,0x1
vpcompressq zmm5{k3}{z},zmm7
vpunpcklqdq xmm6,xmm1,xmm5
mov    r11d,0xf0
kmovw  k4,r11d
vshufi32x4 zmm0{k4},zmm6,zmm6,0x0
vmovdqa64 zmm13,zmm0
or     ecx,0x2
lea    r10,[r15+rbx*1]
lea    r8,[rbx+0x180]
and    r8,rsi
mov    r11d,DWORD PTR [r10+0x8]
andn   edi,r14d,DWORD PTR [r15+r8*1+0x8]
shl    rdi,0x4
andn   r8d,r14d,r11d
shl    r8,0x4
vmovdqa64 zmm9,ZMMWORD PTR [rax+r8*1]
vpbroadcastq zmm10,QWORD PTR [r10]
vpcmpequq k5{k2},zmm9,zmm10
add    rbx,0x10
and    rbx,rsi
prefetcht0 BYTE PTR [rax+rdi*1]
kortestb k5,k5
vmovd  xmm14,DWORD PTR [r10+0xc]
kshiftlb k7,k5,0x1
vpcompressq zmm13{k7}{z},zmm9
vpunpcklqdq xmm15,xmm14,xmm13
mov    r10d,0xf00
kmovw  k1,r10d
vshufi32x4 zmm0{k1},zmm15,zmm15,0x0
vmovdqa64 zmm13,zmm0
or     ecx,0x4
lea    r10,[r15+rbx*1]
lea    r11,[rbx+0x180]
and    r11,rsi
andn   edi,r14d,DWORD PTR [r15+r11*1+0x8]
shl    rdi,0x4
mov    r11d,DWORD PTR [r10+0x8]
andn   r9d,r14d,r11d
shl    r9,0x4
vmovdqa64 zmm7,ZMMWORD PTR [rax+r9*1]
vpbroadcastq zmm2,QWORD PTR [r10]
vpcmpequq k0{k2},zmm7,zmm2
add    rbx,0x10
and    rbx,rsi
prefetcht0 BYTE PTR [rax+rdi*1]
kortestb k0,k0
vmovd  xmm1,DWORD PTR [r10+0xc]
kshiftlb k4,k0,0x1
vpcompressq zmm5{k4}{z},zmm7
vpunpcklqdq xmm6,xmm1,xmm5
mov    r10d,0xfffff000
kmovw  k5,r10d
or     ecx,0x8
vshufi32x4 zmm0{k5},zmm6,zmm6,0x0
vmovdqa64 zmm13,zmm0
cmp    ecx,0xf
vmovdqu64 ZMMWORD PTR [r12],zmm0
add    r12,0x40
mov    ecx,0xffffffff
mov    r8d,0xffffffff
crc32  rcx,QWORD PTR [r13+0x20]
andn   edi,r14d,ecx
shl    rdi,0x4
prefetcht2 BYTE PTR [rax+rdi*1]
mov    edi,0xffffffff
crc32  r8,QWORD PTR [r13+0x0]
mov    r9d,0xffffffff
andn   r10d,r14d,r8d
shl    r10,0x4
crc32  rdi,QWORD PTR [r13+0x30]
prefetcht2 BYTE PTR [rax+r10*1]
andn   r10d,r14d,edi
shl    r10,0x4
prefetcht2 BYTE PTR [rax+r10*1]
lea    r10,[rdx+0x40]
crc32  r9,QWORD PTR [r13+0x10]
andn   r11d,r14d,r9d
shl    r11,0x4
prefetcht2 BYTE PTR [rax+r11*1]
cmp    QWORD PTR [rbp-0x50],r10
vmovdqu64 zmm0,ZMMWORD PTR [r13+0x0]
lea    r11,[r15+rdx*1]
vmovdqu64 ZMMWORD PTR [r11],zmm0
add    r13,0x40
mov    DWORD PTR [r11+0x8],r8d
mov    DWORD PTR [r15+rdx*1+0x18],r9d
mov    DWORD PTR [r15+rdx*1+0x28],ecx
mov    DWORD PTR [r15+rdx*1+0x38],edi
mov    rdx,r10
and    rdx,rsi
cmp    QWORD PTR [rbp-0x38],r13
lea    r9,[r15+rbx*1]
mov    edi,DWORD PTR [r9+0x8]
andn   r10d,r14d,edi
shl    r10,0x4
vmovdqa64 zmm9,ZMMWORD PTR [rax+r10*1]
vpbroadcastq zmm10,QWORD PTR [r9]
vpcmpequq k4{k2},zmm9,zmm10
lea    r11,[rbx+0x180]
add    rbx,0x10
and    r11,rsi
and    rbx,rsi
andn   ecx,r14d,DWORD PTR [r15+r11*1+0x8]
shl    rcx,0x4
kortestb k4,k4
prefetcht0 BYTE PTR [rax+rcx*1]
