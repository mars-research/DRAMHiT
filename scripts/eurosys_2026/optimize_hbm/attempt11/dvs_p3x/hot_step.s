.intel_syntax noprefix
vmovd  xmm13,DWORD PTR [r13+0xc]
kshiftlb k7,k7,0x1
vpcompressq zmm12{k7}{z},zmm8
vpunpcklqdq xmm14,xmm13,xmm12
vshufi32x4 zmm15{k6}{z},zmm14,zmm14,0x0
vmovdqa64 zmm12,zmm15
mov    r11d,0x1
lea    r15,[r8+rax*1]
lea    r13,[rax+0x180]
and    r13,rsi
mov    ebx,DWORD PTR [r15+0x8]
andn   ecx,edi,DWORD PTR [r8+r13*1+0x8]
shl    rcx,0x4
andn   r13d,edi,ebx
shl    r13,0x4
vmovdqa64 zmm0,ZMMWORD PTR [r9+r13*1]
vpbroadcastq zmm2,QWORD PTR [r15]
vpcmpequq k0{k2},zmm0,zmm2
add    rax,0x10
and    rax,rsi
prefetcht0 BYTE PTR [r9+rcx*1]
kortestb k0,k0
vmovd  xmm1,DWORD PTR [r15+0xc]
kshiftlb k7,k0,0x1
vpcompressq zmm5{k7}{z},zmm0
vpunpcklqdq xmm6,xmm1,xmm5
vshufi32x4 zmm15{k5},zmm6,zmm6,0x0
vmovdqa64 zmm12,zmm15
or     r11d,0x2
lea    r15,[rax+0x180]
and    r15,rsi
andn   ecx,edi,DWORD PTR [r8+r15*1+0x8]
shl    rcx,0x4
lea    r15,[r8+rax*1]
mov    ebx,DWORD PTR [r15+0x8]
andn   r12d,edi,ebx
shl    r12,0x4
vmovdqa64 zmm8,ZMMWORD PTR [r9+r12*1]
vpbroadcastq zmm9,QWORD PTR [r15]
vpcmpequq k0{k2},zmm8,zmm9
add    rax,0x10
and    rax,rsi
prefetcht0 BYTE PTR [r9+rcx*1]
kortestb k0,k0
vmovd  xmm13,DWORD PTR [r15+0xc]
kshiftlb k7,k0,0x1
vpcompressq zmm12{k7}{z},zmm8
vpunpcklqdq xmm14,xmm13,xmm12
vshufi32x4 zmm15{k4},zmm14,zmm14,0x0
vmovdqa64 zmm12,zmm15
or     r11d,0x4
lea    rbx,[r8+rax*1]
lea    r15,[rax+0x180]
and    r15,rsi
andn   ecx,edi,DWORD PTR [r8+r15*1+0x8]
shl    rcx,0x4
mov    r15d,DWORD PTR [rbx+0x8]
andn   r13d,edi,r15d
shl    r13,0x4
vmovdqa64 zmm0,ZMMWORD PTR [r9+r13*1]
vpbroadcastq zmm2,QWORD PTR [rbx]
vpcmpequq k0{k2},zmm0,zmm2
add    rax,0x10
prefetcht0 BYTE PTR [r9+rcx*1]
lea    rcx,[r10+0x10]
and    rax,rsi
and    rcx,rsi
kortestb k0,k0
vmovd  xmm1,DWORD PTR [rbx+0xc]
kshiftlb k7,k0,0x1
vpcompressq zmm5{k7}{z},zmm0
vpunpcklqdq xmm6,xmm1,xmm5
vshufi32x4 zmm15{k3},zmm6,zmm6,0x0
or     r11d,0x8
vmovdqa64 zmm12,zmm15
cmp    r11d,0xf
mov    rbx,QWORD PTR [rsp]
vmovdqu64 ZMMWORD PTR [rbx],zmm15
add    rbx,0x40
mov    QWORD PTR [rsp],rbx
mov    r15,r14
crc32  r15,QWORD PTR [rdx]
andn   r13d,edi,r15d
shl    r13,0x4
prefetcht2 BYTE PTR [r9+r13*1]
mov    r13,r14
crc32  r13,QWORD PTR [rdx+0x10]
mov    rbx,r14
andn   r12d,edi,r13d
shl    r12,0x4
prefetcht2 BYTE PTR [r9+r12*1]
mov    r12,r14
crc32  r12,QWORD PTR [rdx+0x20]
crc32  rbx,QWORD PTR [rdx+0x30]
andn   r11d,edi,r12d
shl    r11,0x4
prefetcht2 BYTE PTR [r9+r11*1]
andn   r11d,edi,ebx
shl    r11,0x4
prefetcht2 BYTE PTR [r9+r11*1]
mov    r11,rsi
vmovdqu xmm15,XMMWORD PTR [rdx]
and    r11,r10
add    r11,r8
vmovdqu XMMWORD PTR [r11],xmm15
mov    DWORD PTR [r11+0x8],r15d
add    rcx,r8
lea    r15,[r10+0x30]
vmovdqu xmm8,XMMWORD PTR [rdx+0x10]
and    r15,rsi
vmovdqu XMMWORD PTR [rcx],xmm8
mov    DWORD PTR [rcx+0x8],r13d
lea    rcx,[r10+0x20]
and    rcx,rsi
vmovdqu xmm9,XMMWORD PTR [rdx+0x20]
add    rcx,r8
vmovdqu XMMWORD PTR [rcx],xmm9
mov    DWORD PTR [rcx+0x8],r12d
add    r15,r8
add    r10,0x40
vmovdqu xmm10,XMMWORD PTR [rdx+0x30]
add    rdx,0x40
vmovdqu XMMWORD PTR [r15],xmm10
and    r10,rsi
mov    DWORD PTR [r15+0x8],ebx
cmp    QWORD PTR [rsp-0x18],rdx
lea    r13,[r8+rax*1]
mov    r11d,DWORD PTR [r13+0x8]
andn   r12d,edi,r11d
shl    r12,0x4
vmovdqa64 zmm8,ZMMWORD PTR [r9+r12*1]
vpbroadcastq zmm9,QWORD PTR [r13+0x0]
vpcmpequq k7{k2},zmm8,zmm9
lea    rcx,[rax+0x180]
add    rax,0x10
and    rcx,rsi
and    rax,rsi
andn   r15d,edi,DWORD PTR [r8+rcx*1+0x8]
shl    r15,0x4
kortestb k7,k7
prefetcht0 BYTE PTR [r9+r15*1]
