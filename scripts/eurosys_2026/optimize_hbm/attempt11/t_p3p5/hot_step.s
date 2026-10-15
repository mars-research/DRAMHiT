.intel_syntax noprefix
xor    ebx,ebx
mov    r12d,DWORD PTR [r13+0xc]
kmovb  r13d,k4
tzcnt  ebx,r13d
inc    ebx
movsxd rcx,ebx
mov    r11,QWORD PTR [r11+rcx*8]
mov    DWORD PTR [rdx],r12d
mov    QWORD PTR [rdx+0x8],r11
add    rdx,0x10
lea    r13,[r9+rax*1]
mov    ebx,DWORD PTR [r13+0x8]
andn   r11d,esi,ebx
shl    r11,0x4
add    r11,r8
vmovdqa64 zmm12,ZMMWORD PTR [r11]
vpbroadcastq zmm13,QWORD PTR [r13+0x0]
vpcmpequq k6{k1},zmm12,zmm13
lea    r15,[rax+0x180]
add    rax,0x10
and    r15,r10
and    rax,r10
andn   ecx,esi,DWORD PTR [r9+r15*1+0x8]
shl    rcx,0x4
kortestb k6,k6
prefetcht0 BYTE PTR [r8+rcx*1]
xor    ebx,ebx
mov    r12d,DWORD PTR [r13+0xc]
kmovb  r13d,k6
tzcnt  ebx,r13d
inc    ebx
movsxd r15,ebx
mov    r11,QWORD PTR [r11+r15*8]
mov    DWORD PTR [rdx],r12d
mov    QWORD PTR [rdx+0x8],r11
add    rdx,0x10
lea    r15,[r9+rax*1]
mov    ebx,DWORD PTR [r15+0x8]
andn   r11d,esi,ebx
shl    r11,0x4
add    r11,r8
vmovdqa64 zmm0,ZMMWORD PTR [r11]
vpbroadcastq zmm1,QWORD PTR [r15]
vpcmpequq k0{k1},zmm0,zmm1
lea    rcx,[rax+0x180]
add    rax,0x10
and    rcx,r10
and    rax,r10
andn   r12d,esi,DWORD PTR [r9+rcx*1+0x8]
shl    r12,0x4
kortestb k0,k0
prefetcht0 BYTE PTR [r8+r12*1]
xor    ebx,ebx
mov    r13d,DWORD PTR [r15+0xc]
kmovb  r15d,k0
tzcnt  ebx,r15d
inc    ebx
movsxd rcx,ebx
mov    r11,QWORD PTR [r11+rcx*8]
mov    DWORD PTR [rdx],r13d
mov    QWORD PTR [rdx+0x8],r11
add    rdx,0x10
lea    r15,[r9+rax*1]
mov    ebx,DWORD PTR [r15+0x8]
andn   r11d,esi,ebx
shl    r11,0x4
add    r11,r8
vmovdqa64 zmm4,ZMMWORD PTR [r11]
vpbroadcastq zmm6,QWORD PTR [r15]
vpcmpequq k4{k1},zmm4,zmm6
lea    r12,[rax+0x180]
add    rax,0x10
and    r12,r10
and    rax,r10
andn   ecx,esi,DWORD PTR [r9+r12*1+0x8]
shl    rcx,0x4
kortestb k4,k4
prefetcht0 BYTE PTR [r8+rcx*1]
lea    rcx,[r9+r14*1]
xor    r13d,r13d
kmovb  ebx,k4
tzcnt  r13d,ebx
inc    r13d
movsxd r12,r13d
mov    r15d,DWORD PTR [r15+0xc]
mov    r11,QWORD PTR [r11+r12*8]
mov    DWORD PTR [rdx],r15d
mov    QWORD PTR [rdx+0x8],r11
add    rdx,0x10
mov    r13d,0xffffffff
mov    r11d,0xffffffff
crc32  r13,QWORD PTR [rdi]
crc32  r11,QWORD PTR [rdi+0x10]
andn   r15d,esi,r13d
shl    r15,0x4
andn   ebx,esi,r11d
shl    rbx,0x4
prefetcht2 BYTE PTR [r8+r15*1]
prefetcht2 BYTE PTR [r8+rbx*1]
mov    r15d,0xffffffff
mov    ebx,0xffffffff
crc32  r15,QWORD PTR [rdi+0x20]
crc32  rbx,QWORD PTR [rdi+0x30]
andn   r12d,esi,r15d
shl    r12,0x4
prefetcht2 BYTE PTR [r8+r12*1]
andn   r12d,esi,ebx
shl    r12,0x4
prefetcht2 BYTE PTR [r8+r12*1]
lea    r12,[r14+0x40]
vmovdqu64 zmm9,ZMMWORD PTR [rdi]
cmp    QWORD PTR [rsp],r12
vmovdqu64 ZMMWORD PTR [rcx],zmm9
mov    DWORD PTR [rcx+0x8],r13d
mov    DWORD PTR [r9+r14*1+0x18],r11d
mov    DWORD PTR [r9+r14*1+0x28],r15d
mov    DWORD PTR [r9+r14*1+0x38],ebx
mov    r14,r12
add    rdi,0x40
and    r14,r10
cmp    QWORD PTR [rsp-0x18],rdi
lea    r13,[r9+rax*1]
mov    ebx,DWORD PTR [r13+0x8]
andn   r11d,esi,ebx
shl    r11,0x4
add    r11,r8
vmovdqa64 zmm8,ZMMWORD PTR [r11]
vpbroadcastq zmm9,QWORD PTR [r13+0x0]
vpcmpequq k4{k1},zmm8,zmm9
lea    rcx,[rax+0x180]
add    rax,0x10
and    rcx,r10
and    rax,r10
andn   r15d,esi,DWORD PTR [r9+rcx*1+0x8]
shl    r15,0x4
kortestb k4,k4
prefetcht0 BYTE PTR [r8+r15*1]
