.intel_syntax noprefix
vmovd  xmm13,DWORD PTR [r15+0xc]
kshiftlb k6,k6,0x1
vpcompressq zmm12{k6}{z},zmm8
vpunpcklqdq xmm14,xmm13,xmm12
vshufi32x4 zmm15{k5}{z},zmm14,zmm14,0x0
vmovdqa64 zmm12,zmm15
mov    r11d,0x1
lea    r13,[rax+0x180]
and    r13,r10
andn   ecx,esi,DWORD PTR [r9+r13*1+0x8]
shl    rcx,0x4
lea    r13,[r9+rax*1]
prefetcht0 BYTE PTR [rdi+rcx*1]
mov    ecx,DWORD PTR [r13+0x8]
andn   r14d,esi,ecx
shl    r14,0x4
vmovdqa64 zmm0,ZMMWORD PTR [rdi+r14*1]
vpbroadcastq zmm2,QWORD PTR [r13+0x0]
vpcmpequq k0{k1},zmm0,zmm2
add    rax,0x10
and    rax,r10
kortestb k0,k0
vmovd  xmm1,DWORD PTR [r13+0xc]
kshiftlb k6,k0,0x1
vpcompressq zmm5{k6}{z},zmm0
vpunpcklqdq xmm6,xmm1,xmm5
vshufi32x4 zmm15{k4},zmm6,zmm6,0x0
vmovdqa64 zmm12,zmm15
or     r11d,0x2
lea    r15,[r9+rax*1]
lea    r13,[rax+0x180]
and    r13,r10
andn   ecx,esi,DWORD PTR [r9+r13*1+0x8]
shl    rcx,0x4
mov    r13d,DWORD PTR [r15+0x8]
prefetcht0 BYTE PTR [rdi+rcx*1]
andn   ecx,esi,r13d
shl    rcx,0x4
vmovdqa64 zmm8,ZMMWORD PTR [rdi+rcx*1]
vpbroadcastq zmm9,QWORD PTR [r15]
vpcmpequq k0{k1},zmm8,zmm9
add    rax,0x10
and    rax,r10
kortestb k0,k0
vmovd  xmm13,DWORD PTR [r15+0xc]
kshiftlb k6,k0,0x1
vpcompressq zmm12{k6}{z},zmm8
vpunpcklqdq xmm14,xmm13,xmm12
vshufi32x4 zmm15{k3},zmm14,zmm14,0x0
vmovdqa64 zmm12,zmm15
or     r11d,0x4
lea    r13,[r9+rax*1]
lea    r15,[rax+0x180]
and    r15,r10
mov    r14d,DWORD PTR [r13+0x8]
andn   ecx,esi,DWORD PTR [r9+r15*1+0x8]
shl    rcx,0x4
andn   r15d,esi,r14d
shl    r15,0x4
vmovdqa64 zmm0,ZMMWORD PTR [rdi+r15*1]
vpbroadcastq zmm2,QWORD PTR [r13+0x0]
vpcmpequq k0{k1},zmm0,zmm2
add    rax,0x10
and    rax,r10
prefetcht0 BYTE PTR [rdi+rcx*1]
kortestb k0,k0
lea    rcx,[r9+rbx*1]
vmovd  xmm1,DWORD PTR [r13+0xc]
kshiftlb k6,k0,0x1
vpcompressq zmm5{k6}{z},zmm0
vpunpcklqdq xmm6,xmm1,xmm5
vshufi32x4 zmm15{k2},zmm6,zmm6,0x0
or     r11d,0x8
vmovdqa64 zmm12,zmm15
cmp    r11d,0xf
mov    r15,QWORD PTR [rsp]
vmovdqu64 ZMMWORD PTR [r15],zmm15
add    r15,0x40
mov    QWORD PTR [rsp],r15
mov    r15,r12
crc32  r15,QWORD PTR [rdx]
andn   r13d,esi,r15d
shl    r13,0x4
prefetcht2 BYTE PTR [rdi+r13*1]
mov    r13,r12
crc32  r13,QWORD PTR [rdx+0x20]
mov    r11,r12
crc32  r11,QWORD PTR [rdx+0x10]
vmovq  xmm15,r13
andn   r14d,esi,r11d
shl    r14,0x4
prefetcht2 BYTE PTR [rdi+r14*1]
mov    r14d,r13d
andn   r13d,esi,r14d
shl    r13,0x4
prefetcht2 BYTE PTR [rdi+r13*1]
mov    r13,r12
crc32  r13,QWORD PTR [rdx+0x30]
vmovd  xmm9,r15d
vpinsrd xmm10,xmm9,r11d,0x1
vmovdqu32 zmm13,ZMMWORD PTR [rdx]
vpinsrd xmm8,xmm15,r13d,0x1
vpunpcklqdq xmm11,xmm10,xmm8
mov    r15d,0x4444
lea    r11,[rbx+0x40]
andn   r14d,esi,r13d
shl    r14,0x4
kmovw  k6,r15d
prefetcht2 BYTE PTR [rdi+r14*1]
vpexpandd zmm13{k6},zmm11
cmp    QWORD PTR [rsp-0x18],r11
vmovdqu64 ZMMWORD PTR [rcx],zmm13
mov    rbx,r11
add    rdx,0x40
and    rbx,r10
cmp    QWORD PTR [rsp-0x28],rdx
lea    r15,[r9+rax*1]
mov    r13d,DWORD PTR [r15+0x8]
andn   r14d,esi,r13d
shl    r14,0x4
vmovdqa64 zmm8,ZMMWORD PTR [rdi+r14*1]
vpbroadcastq zmm9,QWORD PTR [r15]
vpcmpequq k6{k1},zmm8,zmm9
lea    r11,[rax+0x180]
add    rax,0x10
and    r11,r10
and    rax,r10
andn   ecx,esi,DWORD PTR [r9+r11*1+0x8]
shl    rcx,0x4
kortestb k6,k6
prefetcht0 BYTE PTR [rdi+rcx*1]
