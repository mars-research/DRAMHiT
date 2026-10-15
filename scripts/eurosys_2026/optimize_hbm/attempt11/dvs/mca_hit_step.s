.intel_syntax noprefix
vmovd  xmm13,DWORD PTR [rbx+0xc]
kshiftlb k6,k6,0x1
vpcompressq zmm12{k6}{z},zmm8
vpunpcklqdq xmm14,xmm13,xmm12
vshufi32x4 zmm15{k5}{z},zmm14,zmm14,0x0
vmovdqa64 zmm12,zmm15
mov    ecx,0x1
lea    rbx,[r8+rax*1]
lea    r11,[rax+0x180]
and    r11,rdi
mov    r10d,DWORD PTR [rbx+0x8]
andn   r15d,r14d,DWORD PTR [r8+r11*1+0x8]
andn   r11d,r14d,r10d
mov    r9d,r15d
mov    r15d,r11d
shl    r15,0x4
vmovdqa64 zmm0,ZMMWORD PTR [rsi+r15*1]
vpbroadcastq zmm2,QWORD PTR [rbx]
vpcmpequq k0{k1},zmm0,zmm2
shl    r9,0x4
add    rax,0x10
and    rax,rdi
prefetcht0 BYTE PTR [rsi+r9*1]
kortestb k0,k0
vmovd  xmm1,DWORD PTR [rbx+0xc]
kshiftlb k6,k0,0x1
vpcompressq zmm6{k6}{z},zmm0
vpunpcklqdq xmm7,xmm1,xmm6
vshufi32x4 zmm15{k4},zmm7,zmm7,0x0
vmovdqa64 zmm12,zmm15
or     ecx,0x2
lea    rbx,[r8+rax*1]
lea    r15,[rax+0x180]
and    r15,rdi
mov    r11d,DWORD PTR [rbx+0x8]
andn   r9d,r14d,DWORD PTR [r8+r15*1+0x8]
andn   r15d,r14d,r11d
mov    r10d,r9d
mov    r9d,r15d
shl    r9,0x4
vmovdqa64 zmm8,ZMMWORD PTR [rsi+r9*1]
vpbroadcastq zmm9,QWORD PTR [rbx]
vpcmpequq k0{k1},zmm8,zmm9
shl    r10,0x4
add    rax,0x10
and    rax,rdi
prefetcht0 BYTE PTR [rsi+r10*1]
kortestb k0,k0
vmovd  xmm13,DWORD PTR [rbx+0xc]
kshiftlb k6,k0,0x1
vpcompressq zmm12{k6}{z},zmm8
vpunpcklqdq xmm14,xmm13,xmm12
vshufi32x4 zmm15{k3},zmm14,zmm14,0x0
vmovdqa64 zmm12,zmm15
or     ecx,0x4
lea    rbx,[r8+rax*1]
lea    r9,[rax+0x180]
and    r9,rdi
mov    r15d,DWORD PTR [rbx+0x8]
andn   r10d,r14d,DWORD PTR [r8+r9*1+0x8]
andn   r9d,r14d,r15d
mov    r11d,r10d
mov    r10d,r9d
shl    r10,0x4
vmovdqa64 zmm0,ZMMWORD PTR [rsi+r10*1]
vpbroadcastq zmm2,QWORD PTR [rbx]
vpcmpequq k0{k1},zmm0,zmm2
shl    r11,0x4
add    rax,0x10
and    rax,rdi
prefetcht0 BYTE PTR [rsi+r11*1]
kortestb k0,k0
vmovd  xmm1,DWORD PTR [rbx+0xc]
kshiftlb k6,k0,0x1
vpcompressq zmm6{k6}{z},zmm0
vpunpcklqdq xmm7,xmm1,xmm6
vshufi32x4 zmm15{k2},zmm7,zmm7,0x0
or     ecx,0x8
vmovdqa64 zmm12,zmm15
cmp    ecx,0xf
mov    r15,QWORD PTR [rsp]
vmovdqu64 ZMMWORD PTR [r15],zmm15
add    r15,0x40
mov    QWORD PTR [rsp],r15
mov    r10,QWORD PTR [rdx]
mov    r15,r12
mov    r11,QWORD PTR [rdx+0x10]
crc32  r15,r10
mov    QWORD PTR [rsp-0x38],r10
mov    r10d,DWORD PTR [rsp-0x18]
mov    rcx,r12
crc32  rcx,r11
mov    ebx,r10d
mov    r9d,r10d
and    ebx,ecx
shl    rbx,0x4
and    r9d,r15d
shl    r9,0x4
prefetcht2 BYTE PTR [rsi+rbx*1]
mov    rbx,QWORD PTR [rdx+0x20]
prefetcht2 BYTE PTR [rsi+r9*1]
mov    r9,r12
crc32  r9,rbx
mov    QWORD PTR [rsp-0x40],r11
mov    r11d,r9d
and    r11d,r10d
shl    r11,0x4
prefetcht2 BYTE PTR [rsi+r11*1]
mov    r11,QWORD PTR [rdx+0x30]
vmovq  xmm15,r9
mov    r9,r12
crc32  r9,r11
and    r10d,r9d
mov    QWORD PTR [rsp-0x48],r11
mov    r11,r10
shl    r11,0x4
lea    r10,[r13+0x40]
prefetcht2 BYTE PTR [rsi+r11*1]
cmp    QWORD PTR [rsp-0x28],r10
vmovd  xmm3,r15d
vmovdqu32 zmm1,ZMMWORD PTR [rdx]
vpinsrd xmm2,xmm15,r9d,0x1
vpinsrd xmm5,xmm3,ecx,0x1
vpunpcklqdq xmm6,xmm5,xmm2
mov    r9d,0x4444
kmovw  k6,r9d
vpexpandd zmm1{k6},zmm6
vmovdqu64 ZMMWORD PTR [r8+r13*1],zmm1
and    r10,rdi
add    rdx,0x40
mov    r13,r10
cmp    QWORD PTR [rsp-0x30],rdx
lea    rbx,[r8+rax*1]
lea    rcx,[rax+0x180]
and    rcx,rdi
mov    r10d,DWORD PTR [rbx+0x8]
andn   r15d,r14d,DWORD PTR [r8+rcx*1+0x8]
andn   r11d,r14d,r10d
mov    ecx,r11d
shl    rcx,0x4
vmovdqa64 zmm8,ZMMWORD PTR [rsi+rcx*1]
vpbroadcastq zmm9,QWORD PTR [rbx]
vpcmpequq k6{k1},zmm8,zmm9
mov    r9d,r15d
shl    r9,0x4
add    rax,0x10
and    rax,rdi
prefetcht0 BYTE PTR [rsi+r9*1]
kortestb k6,k6
