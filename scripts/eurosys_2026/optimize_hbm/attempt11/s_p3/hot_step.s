.intel_syntax noprefix
vmovd  xmm13,DWORD PTR [r11+0xc]
kshiftlb k7,k7,0x1
vpcompressq zmm12{k7}{z},zmm8
vpunpcklqdq xmm14,xmm13,xmm12
vshufi32x4 zmm15{k6}{z},zmm14,zmm14,0x0
vmovdqa64 zmm12,zmm15
mov    r11d,0x1
lea    rbx,[r8+rax*1]
lea    r13,[rax+0x180]
and    r13,r10
mov    r12d,DWORD PTR [rbx+0x8]
andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
andn   r13d,esi,r12d
mov    r15d,ecx
mov    ecx,r13d
shl    rcx,0x4
vmovdqa64 zmm0,ZMMWORD PTR [rdi+rcx*1]
vpbroadcastq zmm2,QWORD PTR [rbx]
vpcmpequq k0{k2},zmm0,zmm2
shl    r15,0x4
add    rax,0x10
and    rax,r10
prefetcht0 BYTE PTR [rdi+r15*1]
kortestb k0,k0
vmovd  xmm1,DWORD PTR [rbx+0xc]
kshiftlb k7,k0,0x1
vpcompressq zmm6{k7}{z},zmm0
vpunpcklqdq xmm7,xmm1,xmm6
vshufi32x4 zmm15{k5},zmm7,zmm7,0x0
vmovdqa64 zmm12,zmm15
or     r11d,0x2
lea    rbx,[r8+rax*1]
lea    rcx,[rax+0x180]
and    rcx,r10
mov    r12d,DWORD PTR [rbx+0x8]
andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
andn   ecx,esi,r12d
mov    r13d,r15d
mov    r15d,ecx
shl    r15,0x4
vmovdqa64 zmm8,ZMMWORD PTR [rdi+r15*1]
vpbroadcastq zmm9,QWORD PTR [rbx]
vpcmpequq k0{k2},zmm8,zmm9
shl    r13,0x4
add    rax,0x10
and    rax,r10
prefetcht0 BYTE PTR [rdi+r13*1]
kortestb k0,k0
vmovd  xmm13,DWORD PTR [rbx+0xc]
kshiftlb k7,k0,0x1
vpcompressq zmm12{k7}{z},zmm8
vpunpcklqdq xmm14,xmm13,xmm12
vshufi32x4 zmm15{k4},zmm14,zmm14,0x0
vmovdqa64 zmm12,zmm15
or     r11d,0x4
lea    rbx,[r8+rax*1]
lea    r15,[rax+0x180]
and    r15,r10
mov    r12d,DWORD PTR [rbx+0x8]
andn   r13d,esi,DWORD PTR [r8+r15*1+0x8]
andn   r15d,esi,r12d
mov    ecx,r13d
mov    r13d,r15d
shl    r13,0x4
vmovdqa64 zmm0,ZMMWORD PTR [rdi+r13*1]
vpbroadcastq zmm2,QWORD PTR [rbx]
vpcmpequq k0{k2},zmm0,zmm2
shl    rcx,0x4
add    rax,0x10
and    rax,r10
prefetcht0 BYTE PTR [rdi+rcx*1]
kortestb k0,k0
lea    rcx,[r8+r9*1]
vmovd  xmm1,DWORD PTR [rbx+0xc]
kshiftlb k7,k0,0x1
vpcompressq zmm6{k7}{z},zmm0
vpunpcklqdq xmm7,xmm1,xmm6
vshufi32x4 zmm15{k3},zmm7,zmm7,0x0
or     r11d,0x8
vmovdqa64 zmm12,zmm15
cmp    r11d,0xf
mov    r13,QWORD PTR [rsp]
vmovdqu64 ZMMWORD PTR [r13+0x0],zmm15
add    r13,0x40
mov    QWORD PTR [rsp],r13
mov    rbx,r14
mov    r11,r14
crc32  rbx,QWORD PTR [rdx]
mov    r13,r14
andn   r15d,esi,ebx
shl    r15,0x4
crc32  r11,QWORD PTR [rdx+0x20]
prefetcht2 BYTE PTR [rdi+r15*1]
andn   r15d,esi,r11d
shl    r15,0x4
prefetcht2 BYTE PTR [rdi+r15*1]
mov    r15,r14
crc32  r13,QWORD PTR [rdx+0x10]
crc32  r15,QWORD PTR [rdx+0x30]
andn   r12d,esi,r13d
shl    r12,0x4
prefetcht2 BYTE PTR [rdi+r12*1]
andn   r12d,esi,r15d
shl    r12,0x4
prefetcht2 BYTE PTR [rdi+r12*1]
lea    r12,[r9+0x40]
vmovdqu64 zmm15,ZMMWORD PTR [rdx]
cmp    QWORD PTR [rsp-0x18],r12
vmovdqu64 ZMMWORD PTR [rcx],zmm15
mov    DWORD PTR [rcx+0x8],ebx
mov    DWORD PTR [r8+r9*1+0x18],r13d
mov    DWORD PTR [r8+r9*1+0x28],r11d
mov    DWORD PTR [r8+r9*1+0x38],r15d
mov    r9,r12
add    rdx,0x40
and    r9,r10
cmp    QWORD PTR [rsp-0x28],rdx
lea    r11,[r8+rax*1]
lea    rcx,[rax+0x180]
and    rcx,r10
mov    r13d,DWORD PTR [r11+0x8]
andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
andn   r12d,esi,r13d
mov    ecx,r12d
shl    rcx,0x4
vmovdqa64 zmm8,ZMMWORD PTR [rdi+rcx*1]
vpbroadcastq zmm9,QWORD PTR [r11]
vpcmpequq k7{k2},zmm8,zmm9
mov    ebx,r15d
shl    rbx,0x4
add    rax,0x10
and    rax,r10
prefetcht0 BYTE PTR [rdi+rbx*1]
kortestb k7,k7
