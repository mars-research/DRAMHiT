0000000000469b40:
  469b40:	lea    r10,[rsp+0x8]
  469b45:	and    rsp,0xffffffffffffffc0
  469b49:	push   QWORD PTR [r10-0x8]
  469b4d:	push   rbp
  469b4e:	mov    rbp,rsp
  469b51:	push   r15
  469b53:	mov    r15,rdi
  469b56:	push   r14
  469b58:	push   r13
  469b5a:	push   r12
  469b5c:	push   r10
  469b5e:	push   rbx
  469b5f:	sub    rsp,0x140
  469b66:	mov    rax,QWORD PTR [rsi+0x8]
  469b6a:	mov    ecx,DWORD PTR [rdi+0xc8]
  469b70:	mov    r10,QWORD PTR [rsi]
  469b73:	mov    esi,DWORD PTR [rdi+0xcc]
  469b79:	mov    rdx,rax
  469b7c:	mov    edi,DWORD PTR [rdi+0x70]
  469b7f:	mov    r9d,ecx
  469b82:	shl    rdx,0x4
  469b86:	sub    r9d,esi
  469b89:	add    rdx,r10
  469b8c:	and    r9d,DWORD PTR [r15+0x74]
  469b90:	lea    r8d,[rdi-0x1]
  469b94:	mov    QWORD PTR [rbp-0x58],rdx
  469b98:	cmp    r9d,r8d
  469b9b:	jb     46a01e
  469ba1:	and    rax,0xfffffffffffffffc
  469ba5:	mov    rbx,QWORD PTR [r15+0xb0]
  469bac:	mov    r12d,DWORD PTR [r15+0x80]
  469bb3:	shl    rax,0x4
  469bb7:	lea    r14,[rdi*4+0x0]
  469bbf:	add    rax,r10
  469bc2:	mov    QWORD PTR [rbp-0xb0],rbx
  469bc9:	mov    QWORD PTR [rbp-0x60],rax
  469bcd:	mov    r8,QWORD PTR [r15+0xb8]
  469bd4:	mov    r13,QWORD PTR [rip+0x2b015]        # 494bf0
  469bdb:	lea    r9,[r14-0x1]
  469bdf:	lea    rbx,[rsi*4+0x0]
  469be7:	lea    rdx,[rcx*4+0x0]
  469bef:	not    r12d
  469bf2:	cmp    r10,rax
  469bf5:	je     469e70
  469bfb:	mov    QWORD PTR [rbp-0x48],r10
  469bff:	mov    QWORD PTR [rbp-0x148],r15
  469c06:	mov    esi,0x55
  469c0b:	mov    r15,r8
  469c0e:	mov    r8,r14
  469c11:	kmovb  k2,esi
  469c15:	nop    DWORD PTR [rax]
  469c18:	lea    r10,[rbp-0x40]
  469c1c:	mov    QWORD PTR [rbp-0x50],r10
  469c20:	mov    r14,r9
  469c23:	nop    DWORD PTR [rax+rax*1+0x0]
  469c28:	mov    r11,QWORD PTR [rbp-0xb0]
  469c2f:	lea    r10,[rbx+0x10]
  469c33:	lea    rax,[r11+rbx*4]
  469c37:	cmp    r8,r10
  469c3a:	jb     46a520
  469c40:	vmovdqu64 zmm5,ZMMWORD PTR [rax]
  469c46:	lea    r9,[r15+rbx*1]
  469c4a:	lea    rax,[rbx+0x60]
  469c4e:	and    rax,r14
  469c51:	lea    rdi,[rax+0x10]
  469c55:	mov    esi,DWORD PTR [r15+rax*1]
  469c59:	lea    rcx,[rax+0x4]
  469c5d:	lea    rbx,[rax+0x8]
  469c61:	lea    r11,[rax+0xc]
  469c65:	cmp    r8,rdi
  469c68:	jb     46a4d0
  469c6e:	andn   r11d,r12d,esi
  469c73:	shl    r11,0x4
  469c77:	andn   ecx,r12d,DWORD PTR [r15+rax*1+0x8]
  469c7e:	shl    rcx,0x4
  469c82:	andn   esi,r12d,DWORD PTR [r15+rax*1+0x4]
  469c89:	shl    rsi,0x4
  469c8d:	andn   edi,r12d,DWORD PTR [r15+rax*1+0xc]
  469c94:	shl    rdi,0x4
  469c98:	prefetchw BYTE PTR [r13+r11*1+0x0]
  469c9e:	prefetchw BYTE PTR [r13+rsi*1+0x0]
  469ca4:	prefetchw BYTE PTR [r13+rcx*1+0x0]
  469caa:	prefetchw BYTE PTR [r13+rdi*1+0x0]
  469cb0:	mov    rbx,r10
  469cb3:	mov    r10d,DWORD PTR [r9]
  469cb6:	andn   edi,r12d,r10d
  469cbb:	shl    rdi,0x4
  469cbf:	add    rdi,r13
  469cc2:	vmovdqa64 zmm10,ZMMWORD PTR [rdi]
  469cc8:	vshufi64x2 zmm0,zmm5,zmm5,0x0
  469ccf:	vpcmpequq k6{k2},zmm10,zmm0
  469cd6:	and    rbx,r14
  469cd9:	kortestb k6,k6
  469cdd:	je     46a400
  469ce3:	kaddb  k1,k6,k6
  469ce7:	vmovdqu64 ZMMWORD PTR [rdi]{k1},zmm0
  469ced:	mov    r10d,DWORD PTR [r9+0x4]
  469cf1:	andn   edi,r12d,r10d
  469cf6:	shl    rdi,0x4
  469cfa:	add    rdi,r13
  469cfd:	vmovdqa64 zmm12,ZMMWORD PTR [rdi]
  469d03:	vshufi64x2 zmm0,zmm5,zmm5,0x55
  469d0a:	vpcmpequq k0{k2},zmm12,zmm0
  469d11:	kortestb k0,k0
  469d15:	je     46a330
  469d1b:	kaddb  k4,k0,k0
  469d1f:	vmovdqu64 ZMMWORD PTR [rdi]{k4},zmm0
  469d25:	mov    ecx,DWORD PTR [r9+0x8]
  469d29:	andn   edi,r12d,ecx
  469d2e:	shl    rdi,0x4
  469d32:	add    rdi,r13
  469d35:	vmovdqa64 zmm14,ZMMWORD PTR [rdi]
  469d3b:	vshufi64x2 zmm0,zmm5,zmm5,0xaa
  469d42:	vpcmpequq k5{k2},zmm14,zmm0
  469d49:	kortestb k5,k5
  469d4d:	je     46a260
  469d53:	kaddb  k7,k5,k5
  469d57:	vmovdqu64 ZMMWORD PTR [rdi]{k7},zmm0
  469d5d:	mov    esi,DWORD PTR [r9+0xc]
  469d61:	andn   edi,r12d,esi
  469d66:	shl    rdi,0x4
  469d6a:	add    rdi,r13
  469d6d:	vmovdqa64 zmm0,ZMMWORD PTR [rdi]
  469d73:	vshufi64x2 zmm3,zmm5,zmm5,0xff
  469d7a:	vpcmpequq k1{k2},zmm0,zmm3
  469d81:	kortestb k1,k1
  469d85:	je     46a1b0
  469d8b:	kaddb  k3,k1,k1
  469d8f:	vmovdqu64 ZMMWORD PTR [rdi]{k3},zmm3
  469d95:	mov    rdi,rbx
  469d98:	sub    rdi,rdx
  469d9b:	and    rdi,r14
  469d9e:	cmp    rdi,0x13
  469da2:	jbe    469c28
  469da8:	mov    r11,QWORD PTR [rbp-0x48]
  469dac:	mov    ecx,0xffffffff
  469db1:	mov    esi,0xffffffff
  469db6:	mov    edi,0xffffffff
  469dbb:	mov    r9,r14
  469dbe:	crc32  rcx,QWORD PTR [r11]
  469dc4:	crc32  rsi,QWORD PTR [r11+0x10]
  469dcb:	andn   r14d,r12d,ecx
  469dd0:	shl    r14,0x4
  469dd4:	andn   eax,r12d,esi
  469dd9:	shl    rax,0x4
  469ddd:	crc32  rdi,QWORD PTR [r11+0x30]
  469de4:	prefetcht1 BYTE PTR [r13+r14*1+0x0]
  469dea:	prefetcht1 BYTE PTR [r13+rax*1+0x0]
  469df0:	andn   r14d,r12d,edi
  469df5:	shl    r14,0x4
  469df9:	mov    eax,0xffffffff
  469dfe:	prefetcht1 BYTE PTR [r13+r14*1+0x0]
  469e04:	lea    r14,[rdx+0x10]
  469e08:	crc32  rax,QWORD PTR [r11+0x20]
  469e0f:	vmovdqu64 zmm0,ZMMWORD PTR [r11]
  469e15:	andn   r10d,r12d,eax
  469e1a:	shl    r10,0x4
  469e1e:	prefetcht1 BYTE PTR [r13+r10*1+0x0]
  469e24:	cmp    r8,r14
  469e27:	jb     40e010
  469e2d:	mov    r10,QWORD PTR [rbp-0xb0]
  469e34:	add    r11,0x40
  469e38:	vmovdqu64 ZMMWORD PTR [r10+rdx*4],zmm0
  469e3f:	mov    DWORD PTR [r15+rdx*1],ecx
  469e43:	mov    DWORD PTR [r15+rdx*1+0x4],esi
  469e48:	mov    DWORD PTR [r15+rdx*1+0x8],eax
  469e4d:	mov    DWORD PTR [r15+rdx*1+0xc],edi
  469e52:	mov    rdx,r14
  469e55:	mov    QWORD PTR [rbp-0x48],r11
  469e59:	and    rdx,r9
  469e5c:	cmp    QWORD PTR [rbp-0x60],r11
  469e60:	jne    469c18
  469e66:	mov    r15,QWORD PTR [rbp-0x148]
  469e6d:	mov    r10,r11
  469e70:	vmovq  xmm8,rdx
  469e75:	vpinsrq xmm9,xmm8,rbx,0x1
  469e7b:	vpsrlq xmm10,xmm9,0x2
  469e81:	mov    r14,QWORD PTR [rbp-0x58]
  469e85:	vpmovqd xmm11,xmm10
  469e8b:	vpextrd eax,xmm11,0x1
  469e91:	vmovq  QWORD PTR [r15+0xc8],xmm11
  469e9a:	cmp    r10,r14
  469e9d:	je     46a004
  469ea3:	mov    rsi,QWORD PTR [rip+0x2ad46]        # 494bf0
  469eaa:	mov    rcx,QWORD PTR [r15+0xb8]
  469eb1:	mov    edi,DWORD PTR [r15+0x74]
  469eb5:	mov    rdx,QWORD PTR [r15+0xb0]
  469ebc:	mov    r13,QWORD PTR [rbp-0x150]
  469ec3:	mov    ebx,0xffffffff
  469ec8:	mov    r12,r10
  469ecb:	jmp    469f46
  469ecd:	nop    DWORD PTR [rax]
  469ed0:	cmp    r8,0x8
  469ed4:	jne    469ee0
  469ed6:	mov    r13,rbx
  469ed9:	crc32  r13,QWORD PTR [r12]
  469ee0:	mov    r11d,r13d
  469ee3:	mov    r10,QWORD PTR [r15+0x88]
  469eea:	mov    edi,DWORD PTR [r15+0xc8]
  469ef1:	dec    r10
  469ef4:	and    r10,r13
  469ef7:	vmovdqu xmm5,XMMWORD PTR [r12]
  469efd:	mov    rax,rdi
  469f00:	and    r10,0xfffffffffffffffc
  469f04:	shl    r10,0x4
  469f08:	shl    rax,0x4
  469f0c:	prefetcht1 BYTE PTR [rsi+r10*1]
  469f11:	vmovdqu XMMWORD PTR [rdx+rax*1],xmm5
  469f16:	mov    DWORD PTR [rcx+rdi*4],r11d
  469f1a:	add    r12,0x10
  469f1e:	mov    r9d,DWORD PTR [r15+0xc8]
  469f25:	mov    edi,DWORD PTR [r15+0x74]
  469f29:	inc    r9d
  469f2c:	and    r9d,edi
  469f2f:	mov    DWORD PTR [r15+0xc8],r9d
  469f36:	cmp    r12,r14
  469f39:	je     46a004
  469f3f:	mov    eax,DWORD PTR [r15+0xcc]
  469f46:	mov    r8d,DWORD PTR [r15+0x80]
  469f4d:	lea    r9d,[rax+0x18]
  469f51:	and    r9d,edi
  469f54:	mov    r11d,r8d
  469f57:	and    r11d,DWORD PTR [rcx+r9*4]
  469f5b:	lea    r10d,[rax+0x1]
  469f5f:	and    edi,r10d
  469f62:	shl    r11,0x4
  469f66:	prefetchw BYTE PTR [rsi+r11*1]
  469f6b:	mov    DWORD PTR [r15+0xcc],edi
  469f72:	mov    r9d,DWORD PTR [rcx+rax*4]
  469f76:	shl    rax,0x4
  469f7a:	vbroadcasti32x4 zmm15,XMMWORD PTR [rdx+rax*1]
  469f81:	lea    rdi,[rdx+rax*1]
  469f85:	mov    rax,QWORD PTR [r15+0x90]
  469f8c:	cmp    QWORD PTR [rdi],rax
  469f8f:	je     46a5a6
  469f95:	mov    edi,r8d
  469f98:	and    edi,r9d
  469f9b:	shl    rdi,0x4
  469f9f:	add    rdi,rsi
  469fa2:	vmovdqa64 zmm13,ZMMWORD PTR [rdi]
  469fa8:	mov    ecx,0x55
  469fad:	kmovb  k4,ecx
  469fb1:	vpcmpequq k5{k4},zmm13,zmm15
  469fb8:	kortestb k5,k5
  469fbc:	je     46a5bd
  469fc2:	kaddb  k7,k5,k5
  469fc6:	vmovdqu64 ZMMWORD PTR [rdi]{k7},zmm15
  469fcc:	mov    rsi,QWORD PTR [rip+0x2ac1d]        # 494bf0
  469fd3:	mov    rdx,QWORD PTR [r15+0xb0]
  469fda:	mov    rcx,QWORD PTR [r15+0xb8]
  469fe1:	mov    r8,QWORD PTR [r15+0x60]
  469fe5:	cmp    r8,0x4
  469fe9:	jne    469ed0
  469fef:	mov    r11d,0xffffffff
  469ff5:	crc32  r11d,DWORD PTR [r12]
  469ffc:	mov    r13d,r11d
  469fff:	jmp    469ee3
  46a004:	vzeroupper
  46a007:	add    rsp,0x140
  46a00e:	pop    rbx
  46a00f:	pop    rcx
  46a010:	pop    r12
  46a012:	pop    r13
  46a014:	pop    r14
  46a016:	pop    r15
  46a018:	pop    rbp
  46a019:	lea    rsp,[rcx-0x8]
  46a01d:	ret
  46a01e:	cmp    r10,QWORD PTR [rbp-0x58]
  46a022:	je     46a007
  46a024:	mov    r11,QWORD PTR [r15+0x88]
  46a02b:	mov    r8,QWORD PTR [r15+0x60]
  46a02f:	mov    rdi,QWORD PTR [rip+0x2abba]        # 494bf0
  46a036:	mov    rcx,QWORD PTR [r15+0xb0]
  46a03d:	mov    rsi,QWORD PTR [r15+0xb8]
  46a044:	lea    r9,[r11-0x1]
  46a048:	mov    r12d,0xffffffff
  46a04e:	xchg   ax,ax
  46a050:	cmp    r8,0x4
  46a054:	je     46a193
  46a05a:	cmp    r8,0x8
  46a05e:	jne    46a069
  46a060:	mov    rbx,r12
  46a063:	crc32  rbx,QWORD PTR [r10]
  46a069:	mov    r13d,ebx
  46a06c:	mov    eax,DWORD PTR [r15+0xc8]
  46a073:	mov    r14,r9
  46a076:	and    r14,rbx
  46a079:	vmovdqu xmm5,XMMWORD PTR [r10]
  46a07e:	mov    rdx,rax
  46a081:	and    r14,0xfffffffffffffffc
  46a085:	shl    rdx,0x4
  46a089:	shl    r14,0x4
  46a08d:	prefetcht1 BYTE PTR [rdi+r14*1]
  46a092:	vmovdqu XMMWORD PTR [rcx+rdx*1],xmm5
  46a097:	mov    DWORD PTR [rsi+rax*4],r13d
  46a09b:	add    r10,0x10
  46a09f:	mov    eax,DWORD PTR [r15+0xc8]
  46a0a6:	mov    edx,DWORD PTR [r15+0x74]
  46a0aa:	inc    eax
  46a0ac:	and    eax,edx
  46a0ae:	mov    DWORD PTR [r15+0xc8],eax
  46a0b5:	cmp    r10,QWORD PTR [rbp-0x58]
  46a0b9:	je     46a004
  46a0bf:	mov    r11d,DWORD PTR [r15+0xcc]
  46a0c6:	mov    r13d,DWORD PTR [r15+0x70]
  46a0ca:	sub    eax,r11d
  46a0cd:	and    eax,edx
  46a0cf:	lea    r14d,[r13-0x1]
  46a0d3:	cmp    eax,r14d
  46a0d6:	jb     46a050
  46a0dc:	mov    r13d,DWORD PTR [r15+0x80]
  46a0e3:	lea    r9d,[r11+0x18]
  46a0e7:	and    r9d,edx
  46a0ea:	mov    eax,r13d
  46a0ed:	and    eax,DWORD PTR [rsi+r9*4]
  46a0f1:	lea    r14d,[r11+0x1]
  46a0f5:	mov    r8,rax
  46a0f8:	and    r14d,edx
  46a0fb:	shl    r8,0x4
  46a0ff:	prefetchw BYTE PTR [rdi+r8*1]
  46a104:	mov    DWORD PTR [r15+0xcc],r14d
  46a10b:	mov    r14d,DWORD PTR [rsi+r11*4]
  46a10f:	shl    r11,0x4
  46a113:	vbroadcasti32x4 zmm1,XMMWORD PTR [rcx+r11*1]
  46a11a:	lea    r9,[rcx+r11*1]
  46a11e:	mov    r11,QWORD PTR [r15+0x90]
  46a125:	cmp    QWORD PTR [r9],r11
  46a128:	je     46a68d
  46a12e:	mov    edx,r13d
  46a131:	and    edx,r14d
  46a134:	shl    rdx,0x4
  46a138:	add    rdx,rdi
  46a13b:	vmovdqa64 zmm0,ZMMWORD PTR [rdx]
  46a141:	mov    esi,0x55
  46a146:	kmovb  k1,esi
  46a14a:	vpcmpequq k0{k1},zmm0,zmm1
  46a151:	kortestb k0,k0
  46a155:	je     46a6b3
  46a15b:	kaddb  k3,k0,k0
  46a15f:	vmovdqu64 ZMMWORD PTR [rdx]{k3},zmm1
  46a165:	mov    r13,QWORD PTR [r15+0x88]
  46a16c:	mov    r8,QWORD PTR [r15+0x60]
  46a170:	mov    rdi,QWORD PTR [rip+0x2aa79]        # 494bf0
  46a177:	mov    rcx,QWORD PTR [r15+0xb0]
  46a17e:	mov    rsi,QWORD PTR [r15+0xb8]
  46a185:	lea    r9,[r13-0x1]
  46a189:	cmp    r8,0x4
  46a18d:	jne    46a05a
  46a193:	mov    r13d,0xffffffff
  46a199:	crc32  r13d,DWORD PTR [r10]
  46a19f:	mov    ebx,r13d
  46a1a2:	jmp    46a06c
  46a1a7:	nop    WORD PTR [rax+rax*1+0x0]
  46a1b0:	vpxor  xmm2,xmm2,xmm2
  46a1b4:	vpcmpequq k0{k2},zmm0,zmm2
  46a1bb:	kortestb k0,k0
  46a1bf:	je     46a220
  46a1c1:	mov    DWORD PTR [rbp-0x130],esi
  46a1c7:	xor    esi,esi
  46a1c9:	kmovb  r11d,k0
  46a1cd:	tzcnt  esi,r11d
  46a1d2:	sar    esi,1
  46a1d4:	vmovdqa64 zmm0,zmm3
  46a1da:	mov    QWORD PTR [rbp-0x70],rdx
  46a1de:	mov    QWORD PTR [rbp-0x68],r8
  46a1e2:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm3
  46a1ec:	call   433450
  46a1f1:	test   al,al
  46a1f3:	mov    edx,0x55
  46a1f8:	kmovb  k2,edx
  46a1fc:	vmovdqa64 zmm3,ZMMWORD PTR [rbp-0xf0]
  46a206:	mov    esi,DWORD PTR [rbp-0x130]
  46a20c:	mov    r8,QWORD PTR [rbp-0x68]
  46a210:	mov    rdx,QWORD PTR [rbp-0x70]
  46a214:	jne    469d95
  46a21a:	nop    WORD PTR [rax+rax*1+0x0]
  46a220:	mov    r10,QWORD PTR [rbp-0xb0]
  46a227:	mov    r9d,0xffffffff
  46a22d:	crc32  r9,rsi
  46a233:	andn   ecx,r12d,r9d
  46a238:	shl    rcx,0x4
  46a23c:	prefetcht1 BYTE PTR [r13+rcx*1+0x0]
  46a242:	vmovdqu XMMWORD PTR [r10+rdx*4],xmm3
  46a248:	mov    DWORD PTR [r15+rdx*1],r9d
  46a24c:	add    rdx,0x4
  46a250:	and    rdx,r14
  46a253:	jmp    469d95
  46a258:	nop    DWORD PTR [rax+rax*1+0x0]
  46a260:	vpxor  xmm15,xmm15,xmm15
  46a265:	vpcmpequq k6{k2},zmm14,zmm15
  46a26c:	kortestb k6,k6
  46a270:	je     46a2f0
  46a272:	xor    esi,esi
  46a274:	mov    QWORD PTR [rbp-0x140],rdx
  46a27b:	kmovb  edx,k6
  46a27f:	tzcnt  esi,edx
  46a283:	sar    esi,1
  46a285:	mov    QWORD PTR [rbp-0x138],r8
  46a28c:	mov    DWORD PTR [rbp-0x70],ecx
  46a28f:	mov    QWORD PTR [rbp-0x68],r9
  46a293:	vmovdqa64 ZMMWORD PTR [rbp-0x130],zmm5
  46a29d:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm0
  46a2a7:	call   433450
  46a2ac:	test   al,al
  46a2ae:	mov    r8d,0x55
  46a2b4:	kmovb  k2,r8d
  46a2b9:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0xf0]
  46a2c3:	vmovdqa64 zmm5,ZMMWORD PTR [rbp-0x130]
  46a2cd:	mov    r9,QWORD PTR [rbp-0x68]
  46a2d1:	mov    ecx,DWORD PTR [rbp-0x70]
  46a2d4:	mov    r8,QWORD PTR [rbp-0x138]
  46a2db:	mov    rdx,QWORD PTR [rbp-0x140]
  46a2e2:	jne    469d5d
  46a2e8:	nop    DWORD PTR [rax+rax*1+0x0]
  46a2f0:	mov    rax,QWORD PTR [rbp-0xb0]
  46a2f7:	mov    r10d,0xffffffff
  46a2fd:	crc32  r10,rcx
  46a303:	andn   edi,r12d,r10d
  46a308:	shl    rdi,0x4
  46a30c:	prefetcht1 BYTE PTR [r13+rdi*1+0x0]
  46a312:	vmovdqu XMMWORD PTR [rax+rdx*4],xmm0
  46a317:	mov    DWORD PTR [r15+rdx*1],r10d
  46a31b:	add    rdx,0x4
  46a31f:	and    rdx,r14
  46a322:	jmp    469d5d
  46a327:	nop    WORD PTR [rax+rax*1+0x0]
  46a330:	vpxor  xmm13,xmm13,xmm13
  46a335:	vpcmpequq k3{k2},zmm12,zmm13
  46a33c:	kortestb k3,k3
  46a340:	je     46a3c0
  46a342:	xor    esi,esi
  46a344:	mov    QWORD PTR [rbp-0x68],r9
  46a348:	kmovb  r9d,k3
  46a34c:	tzcnt  esi,r9d
  46a351:	sar    esi,1
  46a353:	mov    QWORD PTR [rbp-0x140],rdx
  46a35a:	mov    QWORD PTR [rbp-0x138],r8
  46a361:	mov    DWORD PTR [rbp-0x70],r10d
  46a365:	vmovdqa64 ZMMWORD PTR [rbp-0x130],zmm5
  46a36f:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm0
  46a379:	call   433450
  46a37e:	test   al,al
  46a380:	mov    edi,0x55
  46a385:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0xf0]
  46a38f:	vmovdqa64 zmm5,ZMMWORD PTR [rbp-0x130]
  46a399:	mov    r9,QWORD PTR [rbp-0x68]
  46a39d:	mov    r10d,DWORD PTR [rbp-0x70]
  46a3a1:	mov    r8,QWORD PTR [rbp-0x138]
  46a3a8:	mov    rdx,QWORD PTR [rbp-0x140]
  46a3af:	kmovb  k2,edi
  46a3b3:	jne    469d25
  46a3b9:	nop    DWORD PTR [rax+0x0]
  46a3c0:	mov    rsi,QWORD PTR [rbp-0xb0]
  46a3c7:	mov    eax,0xffffffff
  46a3cc:	crc32  rax,r10
  46a3d2:	andn   r11d,r12d,eax
  46a3d7:	shl    r11,0x4
  46a3db:	prefetcht1 BYTE PTR [r13+r11*1+0x0]
  46a3e1:	vmovdqu XMMWORD PTR [rsi+rdx*4],xmm0
  46a3e6:	mov    DWORD PTR [r15+rdx*1],eax
  46a3ea:	add    rdx,0x4
  46a3ee:	and    rdx,r14
  46a3f1:	jmp    469d25
  46a3f6:	cs nop WORD PTR [rax+rax*1+0x0]
  46a400:	vpxor  xmm11,xmm11,xmm11
  46a405:	vpcmpequq k7{k2},zmm10,zmm11
  46a40c:	kortestb k7,k7
  46a410:	je     46a490
  46a412:	xor    esi,esi
  46a414:	mov    QWORD PTR [rbp-0x140],rdx
  46a41b:	kmovb  edx,k7
  46a41f:	tzcnt  esi,edx
  46a423:	sar    esi,1
  46a425:	mov    QWORD PTR [rbp-0x138],r8
  46a42c:	mov    DWORD PTR [rbp-0x70],r10d
  46a430:	mov    QWORD PTR [rbp-0x68],r9
  46a434:	vmovdqa64 ZMMWORD PTR [rbp-0x130],zmm5
  46a43e:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm0
  46a448:	call   433450
  46a44d:	test   al,al
  46a44f:	mov    r8d,0x55
  46a455:	kmovb  k2,r8d
  46a45a:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0xf0]
  46a464:	vmovdqa64 zmm5,ZMMWORD PTR [rbp-0x130]
  46a46e:	mov    r9,QWORD PTR [rbp-0x68]
  46a472:	mov    r10d,DWORD PTR [rbp-0x70]
  46a476:	mov    r8,QWORD PTR [rbp-0x138]
  46a47d:	mov    rdx,QWORD PTR [rbp-0x140]
  46a484:	jne    469ced
  46a48a:	nop    WORD PTR [rax+rax*1+0x0]
  46a490:	mov    rcx,QWORD PTR [rbp-0xb0]
  46a497:	mov    r11d,0xffffffff
  46a49d:	crc32  r11,r10
  46a4a3:	andn   esi,r12d,r11d
  46a4a8:	shl    rsi,0x4
  46a4ac:	prefetcht1 BYTE PTR [r13+rsi*1+0x0]
  46a4b2:	vmovdqu XMMWORD PTR [rcx+rdx*4],xmm0
  46a4b7:	mov    DWORD PTR [r15+rdx*1],r11d
  46a4bb:	add    rdx,0x4
  46a4bf:	and    rdx,r14
  46a4c2:	jmp    469ced
  46a4c7:	nop    WORD PTR [rax+rax*1+0x0]
  46a4d0:	andn   eax,r12d,esi
  46a4d5:	shl    rax,0x4
  46a4d9:	mov    rsi,rcx
  46a4dc:	and    rbx,r14
  46a4df:	prefetchw BYTE PTR [r13+rax*1+0x0]
  46a4e5:	andn   edi,r12d,DWORD PTR [r15+rbx*1]
  46a4eb:	shl    rdi,0x4
  46a4ef:	and    rsi,r14
  46a4f2:	and    r11,r14
  46a4f5:	andn   eax,r12d,DWORD PTR [r15+rsi*1]
  46a4fb:	shl    rax,0x4
  46a4ff:	andn   ebx,r12d,DWORD PTR [r15+r11*1]
  46a505:	shl    rbx,0x4
  46a509:	prefetchw BYTE PTR [r13+rax*1+0x0]
  46a50f:	prefetchw BYTE PTR [r13+rdi*1+0x0]
  46a515:	prefetchw BYTE PTR [r13+rbx*1+0x0]
  46a51b:	jmp    469cb0
  46a520:	mov    rdi,r8
  46a523:	sub    rdi,rbx
  46a526:	mov    r9,rdi
  46a529:	shr    r9,1
  46a52c:	mov    ecx,0x1
  46a531:	shlx   esi,ecx,r9d
  46a536:	lea    r11d,[rsi-0x1]
  46a53a:	kmovb  k4,r11d
  46a53f:	vmovdqu64 zmm5{k4}{z},ZMMWORD PTR [rax]
  46a545:	mov    rax,QWORD PTR [rbp-0xb0]
  46a54c:	shl    rdi,0x2
  46a550:	sub    rax,rdi
  46a553:	lea    r9,[rbx+0x8]
  46a557:	mov    rdi,r14
  46a55a:	neg    esi
  46a55c:	and    r9,r14
  46a55f:	and    rdi,rbx
  46a562:	vmovd  xmm4,DWORD PTR [r15+r9*1]
  46a568:	kmovb  k5,esi
  46a56c:	vmovd  xmm7,DWORD PTR [r15+rdi*1]
  46a572:	lea    rcx,[rbx+0x4]
  46a576:	lea    rsi,[rbx+0xc]
  46a57a:	and    rcx,r14
  46a57d:	and    rsi,r14
  46a580:	vpinsrd xmm6,xmm4,DWORD PTR [r15+rsi*1],0x1
  46a587:	vpinsrd xmm8,xmm7,DWORD PTR [r15+rcx*1],0x1
  46a58e:	vmovdqu64 zmm5{k5},ZMMWORD PTR [rax]
  46a594:	vpunpcklqdq xmm9,xmm8,xmm6
  46a598:	mov    r9,QWORD PTR [rbp-0x50]
  46a59c:	vmovdqa XMMWORD PTR [rbp-0x40],xmm9
  46a5a1:	jmp    469c4a
  46a5a6:	mov    r9,QWORD PTR [rdi+0x8]
  46a5aa:	mov    BYTE PTR [rip+0x2a54f],0x1        # 494b00
  46a5b1:	mov    QWORD PTR [rip+0x2a550],r9        # 494b08
  46a5b8:	jmp    469fe1
  46a5bd:	vpxor  xmm14,xmm14,xmm14
  46a5c2:	vpcmpequq k6{k4},zmm13,zmm14
  46a5c9:	kortestb k6,k6
  46a5cd:	jne    46a639
  46a5cf:	mov    r11,rbx
  46a5d2:	mov    edi,DWORD PTR [r15+0xc8]
  46a5d9:	crc32  r11,r9
  46a5df:	mov    r10d,r8d
  46a5e2:	and    r10d,r11d
  46a5e5:	shl    rdi,0x4
  46a5e9:	shl    r10,0x4
  46a5ed:	prefetcht1 BYTE PTR [rsi+r10*1]
  46a5f2:	vmovdqa XMMWORD PTR [rdx+rdi*1],xmm15
  46a5f7:	mov    edx,DWORD PTR [r15+0xc8]
  46a5fe:	mov    rcx,QWORD PTR [r15+0xb8]
  46a605:	mov    rsi,QWORD PTR [rip+0x2a5e4]        # 494bf0
  46a60c:	mov    DWORD PTR [rcx+rdx*4],r11d
  46a610:	mov    rdx,QWORD PTR [r15+0xb0]
  46a617:	mov    eax,DWORD PTR [r15+0xc8]
  46a61e:	mov    edi,DWORD PTR [r15+0x74]
  46a622:	inc    eax
  46a624:	and    eax,edi
  46a626:	mov    DWORD PTR [r15+0xc8],eax
  46a62d:	mov    eax,DWORD PTR [r15+0xcc]
  46a634:	jmp    469f4d
  46a639:	kmovb  esi,k6
  46a63d:	tzcnt  esi,esi
  46a641:	sar    esi,1
  46a643:	vmovdqa64 zmm0,zmm15
  46a649:	mov    DWORD PTR [rbp-0x50],r9d
  46a64d:	mov    DWORD PTR [rbp-0x48],r8d
  46a651:	vmovdqa32 ZMMWORD PTR [rbp-0xb0],zmm15
  46a65b:	call   433450
  46a660:	mov    rsi,QWORD PTR [rip+0x2a589]        # 494bf0
  46a667:	mov    rdx,QWORD PTR [r15+0xb0]
  46a66e:	test   al,al
  46a670:	jne    46a77c
  46a676:	mov    r9d,DWORD PTR [rbp-0x50]
  46a67a:	mov    r8d,DWORD PTR [rbp-0x48]
  46a67e:	vmovdqa32 zmm15,ZMMWORD PTR [rbp-0xb0]
  46a688:	jmp    46a5cf
  46a68d:	mov    rdx,QWORD PTR [r9+0x8]
  46a691:	mov    rax,QWORD PTR [r15+0x88]
  46a698:	mov    QWORD PTR [rip+0x2a469],rdx        # 494b08
  46a69f:	mov    BYTE PTR [rip+0x2a45a],0x1        # 494b00
  46a6a6:	mov    r8,QWORD PTR [r15+0x60]
  46a6aa:	lea    r9,[rax-0x1]
  46a6ae:	jmp    46a050
  46a6b3:	vpxor  xmm3,xmm3,xmm3
  46a6b7:	vpcmpequq k2{k1},zmm0,zmm3
  46a6be:	kortestb k2,k2
  46a6c2:	je     46a711
  46a6c4:	xor    esi,esi
  46a6c6:	mov    QWORD PTR [rbp-0x48],r10
  46a6ca:	kmovb  r10d,k2
  46a6ce:	tzcnt  esi,r10d
  46a6d3:	sar    esi,1
  46a6d5:	vmovdqa64 zmm0,zmm1
  46a6db:	mov    rdi,rdx
  46a6de:	vmovdqa32 ZMMWORD PTR [rbp-0xb0],zmm1
  46a6e8:	call   433450
  46a6ed:	test   al,al
  46a6ef:	vmovdqa32 zmm1,ZMMWORD PTR [rbp-0xb0]
  46a6f9:	mov    r10,QWORD PTR [rbp-0x48]
  46a6fd:	jne    46a165
  46a703:	mov    rdi,QWORD PTR [rip+0x2a4e6]        # 494bf0
  46a70a:	mov    rcx,QWORD PTR [r15+0xb0]
  46a711:	mov    r8,r12
  46a714:	crc32  r8,r14
  46a71a:	mov    eax,r13d
  46a71d:	and    eax,r8d
  46a720:	shl    rax,0x4
  46a724:	prefetcht1 BYTE PTR [rdi+rax*1]
  46a728:	mov    edi,DWORD PTR [r15+0xc8]
  46a72f:	shl    rdi,0x4
  46a733:	vmovdqa XMMWORD PTR [rcx+rdi*1],xmm1
  46a738:	mov    ecx,DWORD PTR [r15+0xc8]
  46a73f:	mov    rsi,QWORD PTR [r15+0xb8]
  46a746:	mov    rdi,QWORD PTR [rip+0x2a4a3]        # 494bf0
  46a74d:	mov    DWORD PTR [rsi+rcx*4],r8d
  46a751:	mov    rcx,QWORD PTR [r15+0xb0]
  46a758:	mov    r14d,DWORD PTR [r15+0xc8]
  46a75f:	mov    edx,DWORD PTR [r15+0x74]
  46a763:	inc    r14d
  46a766:	and    r14d,edx
  46a769:	mov    DWORD PTR [r15+0xc8],r14d
  46a770:	mov    r11d,DWORD PTR [r15+0xcc]
  46a777:	jmp    46a0e3
  46a77c:	mov    rcx,QWORD PTR [r15+0xb8]
  46a783:	jmp    469fe1
