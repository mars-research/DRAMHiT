.intel_syntax noprefix
xor    r15d,r15d
mov    r14d,DWORD PTR [r14+0xc]
kmovb  edi,k4
tzcnt  r15d,edi
inc    r15d
mov    DWORD PTR [rdx],r14d
movsxd r14,r15d
mov    rbx,QWORD PTR [rbx+r14*8]
add    rdx,0x10
mov    QWORD PTR [rdx-0x8],rbx
lea    rdi,[rax+0x180]
and    rdi,r9
andn   r15d,ecx,DWORD PTR [r8+rdi*1+0x8]
shl    r15,0x4
prefetcht0 BYTE PTR [rsi+r15*1]
lea    r15,[r8+rax*1]
mov    edi,DWORD PTR [r15+0x8]
andn   ebx,ecx,edi
shl    rbx,0x4
add    rbx,rsi
vmovdqa64 zmm12,ZMMWORD PTR [rbx]
vpbroadcastq zmm13,QWORD PTR [r15]
vpcmpequq k6{k1},zmm12,zmm13
add    rax,0x10
and    rax,r9
kortestb k6,k6
xor    edi,edi
mov    r15d,DWORD PTR [r15+0xc]
kmovb  r14d,k6
tzcnt  edi,r14d
inc    edi
mov    DWORD PTR [rdx],r15d
movsxd r15,edi
mov    rbx,QWORD PTR [rbx+r15*8]
add    rdx,0x10
mov    QWORD PTR [rdx-0x8],rbx
lea    r14,[rax+0x180]
and    r14,r9
andn   edi,ecx,DWORD PTR [r8+r14*1+0x8]
shl    rdi,0x4
lea    r14,[r8+rax*1]
prefetcht0 BYTE PTR [rsi+rdi*1]
mov    edi,DWORD PTR [r14+0x8]
andn   ebx,ecx,edi
shl    rbx,0x4
add    rbx,rsi
vmovdqa64 zmm0,ZMMWORD PTR [rbx]
vpbroadcastq zmm1,QWORD PTR [r14]
vpcmpequq k0{k1},zmm0,zmm1
add    rax,0x10
and    rax,r9
kortestb k0,k0
xor    edi,edi
mov    r14d,DWORD PTR [r14+0xc]
kmovb  r15d,k0
tzcnt  edi,r15d
inc    edi
mov    DWORD PTR [rdx],r14d
movsxd r14,edi
mov    rbx,QWORD PTR [rbx+r14*8]
add    rdx,0x10
mov    QWORD PTR [rdx-0x8],rbx
lea    r14,[r8+rax*1]
lea    r15,[rax+0x180]
and    r15,r9
andn   edi,ecx,DWORD PTR [r8+r15*1+0x8]
shl    rdi,0x4
mov    r15d,DWORD PTR [r14+0x8]
andn   ebx,ecx,r15d
shl    rbx,0x4
add    rbx,rsi
vmovdqa64 zmm4,ZMMWORD PTR [rbx]
vpbroadcastq zmm7,QWORD PTR [r14]
vpcmpequq k4{k1},zmm4,zmm7
add    rax,0x10
and    rax,r9
prefetcht0 BYTE PTR [rsi+rdi*1]
kortestb k4,k4
lea    rdi,[r8+r10*1]
mov    r14d,DWORD PTR [r14+0xc]
kmovb  r15d,k4
mov    DWORD PTR [rdx],r14d
xor    r14d,r14d
tzcnt  r14d,r15d
inc    r14d
movsxd r15,r14d
mov    rbx,QWORD PTR [rbx+r15*8]
add    rdx,0x10
mov    QWORD PTR [rdx-0x8],rbx
mov    r14,r13
crc32  r14,QWORD PTR [r11]
vmovq  xmm9,r14
andn   ebx,ecx,r14d
shl    rbx,0x4
mov    r14,r13
prefetcht2 BYTE PTR [rsi+rbx*1]
mov    rbx,r13
crc32  rbx,QWORD PTR [r11+0x20]
crc32  r14,QWORD PTR [r11+0x10]
andn   r15d,ecx,r14d
shl    r15,0x4
prefetcht2 BYTE PTR [rsi+r15*1]
andn   r15d,ecx,ebx
shl    r15,0x4
prefetcht2 BYTE PTR [rsi+r15*1]
mov    r15,r13
vmovq  xmm10,rbx
crc32  r15,QWORD PTR [r11+0x30]
vmovdqu32 zmm14,ZMMWORD PTR [r11]
vpinsrd xmm11,xmm10,r15d,0x1
vpinsrd xmm12,xmm9,r14d,0x1
andn   ebx,ecx,r15d
shl    rbx,0x4
vpunpcklqdq xmm13,xmm12,xmm11
prefetcht2 BYTE PTR [rsi+rbx*1]
lea    rbx,[r10+0x40]
vpexpandd zmm14{k2},zmm13
cmp    QWORD PTR [rsp-0x8],rbx
vmovdqu64 ZMMWORD PTR [rdi],zmm14
and    rbx,r9
add    r11,0x40
mov    r10,rbx
cmp    QWORD PTR [rsp-0x20],r11
lea    r14,[r8+rax*1]
lea    rbx,[rax+0x180]
and    rbx,r9
mov    r15d,DWORD PTR [r14+0x8]
andn   edi,ecx,DWORD PTR [r8+rbx*1+0x8]
shl    rdi,0x4
andn   ebx,ecx,r15d
shl    rbx,0x4
add    rbx,rsi
vmovdqa64 zmm8,ZMMWORD PTR [rbx]
vpbroadcastq zmm9,QWORD PTR [r14]
vpcmpequq k4{k1},zmm8,zmm9
add    rax,0x10
and    rax,r9
prefetcht0 BYTE PTR [rsi+rdi*1]
kortestb k4,k4
