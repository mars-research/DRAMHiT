.intel_syntax noprefix
vmovd  xmm13,DWORD PTR [r12+0xc]
kshiftlb k6,k6,0x1
vpcompressq zmm12{k6}{z},zmm8
vpunpcklqdq xmm14,xmm13,xmm12
vshufi32x4 zmm15{k5}{z},zmm14,zmm14,0x0
vmovdqa64 zmm12,zmm15
mov    r11d,0x1
lea    r15,[rax+0x180]
and    r15,r10
andn   r14d,esi,DWORD PTR [r9+r15*1+0x8]
mov    r12d,r14d
shl    r12,0x4
lea    r14,[r9+rax*1]
mov    r15d,DWORD PTR [r14+0x8]
prefetcht0 BYTE PTR [rdi+r12*1]
andn   r12d,esi,r15d
mov    r12d,r12d
shl    r12,0x4
vmovdqa64 zmm0,ZMMWORD PTR [rdi+r12*1]
vpbroadcastq zmm2,QWORD PTR [r14]
vpcmpequq k0{k1},zmm0,zmm2
add    rax,0x10
and    rax,r10
kortestb k0,k0
vmovd  xmm1,DWORD PTR [r14+0xc]
kshiftlb k6,k0,0x1
vpcompressq zmm5{k6}{z},zmm0
vpunpcklqdq xmm6,xmm1,xmm5
vshufi32x4 zmm15{k4},zmm6,zmm6,0x0
vmovdqa64 zmm12,zmm15
or     r11d,0x2
lea    r14,[rax+0x180]
and    r14,r10
andn   r12d,esi,DWORD PTR [r9+r14*1+0x8]
mov    r15d,r12d
shl    r15,0x4
lea    r14,[r9+rax*1]
prefetcht0 BYTE PTR [rdi+r15*1]
mov    r15d,DWORD PTR [r14+0x8]
andn   r12d,esi,r15d
mov    r12d,r12d
shl    r12,0x4
vmovdqa64 zmm8,ZMMWORD PTR [rdi+r12*1]
vpbroadcastq zmm9,QWORD PTR [r14]
vpcmpequq k0{k1},zmm8,zmm9
add    rax,0x10
and    rax,r10
kortestb k0,k0
vmovd  xmm13,DWORD PTR [r14+0xc]
kshiftlb k6,k0,0x1
vpcompressq zmm12{k6}{z},zmm8
vpunpcklqdq xmm14,xmm13,xmm12
mov    QWORD PTR [rsp-0x10],rdx
vshufi32x4 zmm15{k3},zmm14,zmm14,0x0
vmovdqa64 zmm12,zmm15
or     r11d,0x4
lea    rdx,[rax+0x180]
and    rdx,r10
andn   r14d,esi,DWORD PTR [r9+rdx*1+0x8]
mov    r12d,r14d
shl    r12,0x4
lea    r14,[r9+rax*1]
mov    r15d,DWORD PTR [r14+0x8]
prefetcht0 BYTE PTR [rdi+r12*1]
andn   edx,esi,r15d
mov    r12d,edx
shl    r12,0x4
vmovdqa64 zmm0,ZMMWORD PTR [rdi+r12*1]
vpbroadcastq zmm2,QWORD PTR [r14]
vpcmpequq k0{k1},zmm0,zmm2
add    rax,0x10
and    rax,r10
lea    r12,[r9+rbx*1]
kortestb k0,k0
vmovd  xmm1,DWORD PTR [r14+0xc]
kshiftlb k6,k0,0x1
vpcompressq zmm5{k6}{z},zmm0
vpunpcklqdq xmm6,xmm1,xmm5
vshufi32x4 zmm15{k2},zmm6,zmm6,0x0
or     r11d,0x8
mov    rdx,QWORD PTR [rsp-0x10]
vmovdqa64 zmm12,zmm15
cmp    r11d,0xf
mov    r14,QWORD PTR [rsp]
vmovdqu64 ZMMWORD PTR [r14],zmm15
add    r14,0x40
mov    QWORD PTR [rsp],r14
mov    r15,r13
mov    r14,r13
crc32  r15,QWORD PTR [rdx]
crc32  r14,QWORD PTR [rdx+0x20]
andn   r11d,esi,r15d
shl    r11,0x4
prefetcht2 BYTE PTR [rdi+r11*1]
mov    r11,r13
crc32  r11,QWORD PTR [rdx+0x10]
vmovq  xmm15,r15
vmovq  xmm8,r14
andn   r15d,esi,r11d
shl    r15,0x4
prefetcht2 BYTE PTR [rdi+r15*1]
mov    r15d,r14d
andn   r14d,esi,r15d
shl    r14,0x4
prefetcht2 BYTE PTR [rdi+r14*1]
mov    r14,r13
crc32  r14,QWORD PTR [rdx+0x30]
vpinsrd xmm10,xmm15,r11d,0x1
vmovdqu32 zmm13,ZMMWORD PTR [rdx]
mov    r11d,0x4444
vpinsrd xmm9,xmm8,r14d,0x1
kmovw  k6,r11d
vpunpcklqdq xmm11,xmm10,xmm9
lea    r11,[rbx+0x40]
andn   r15d,esi,r14d
shl    r15,0x4
vpexpandd zmm13{k6},zmm11
prefetcht2 BYTE PTR [rdi+r15*1]
cmp    QWORD PTR [rsp-0x28],r11
vmovdqu64 ZMMWORD PTR [r12],zmm13
mov    rbx,r11
add    rdx,0x40
and    rbx,r10
cmp    QWORD PTR [rsp-0x30],rdx
lea    r11,[rax+0x180]
and    r11,r10
andn   r12d,esi,DWORD PTR [r9+r11*1+0x8]
mov    r15d,r12d
shl    r15,0x4
lea    r12,[r9+rax*1]
mov    r14d,DWORD PTR [r12+0x8]
prefetcht0 BYTE PTR [rdi+r15*1]
andn   r11d,esi,r14d
mov    r15d,r11d
shl    r15,0x4
vmovdqa64 zmm8,ZMMWORD PTR [rdi+r15*1]
vpbroadcastq zmm9,QWORD PTR [r12]
vpcmpequq k6{k1},zmm8,zmm9
add    rax,0x10
and    rax,r10
kortestb k6,k6
