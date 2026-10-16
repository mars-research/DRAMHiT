0000000000469980:
  469980:	lea    r10,[rsp+0x8]
  469985:	and    rsp,0xffffffffffffffc0
  469989:	push   QWORD PTR [r10-0x8]
  46998d:	push   rbp
  46998e:	mov    rbp,rsp
  469991:	push   r15
  469993:	mov    r15,rdi
  469996:	push   r14
  469998:	push   r13
  46999a:	push   r12
  46999c:	push   r10
  46999e:	push   rbx
  46999f:	sub    rsp,0x140
  4699a6:	mov    rax,QWORD PTR [rsi+0x8]
  4699aa:	mov    ecx,DWORD PTR [rdi+0xc8]
  4699b0:	mov    r10,QWORD PTR [rsi]
  4699b3:	mov    esi,DWORD PTR [rdi+0xcc]
  4699b9:	mov    rdx,rax
  4699bc:	mov    edi,DWORD PTR [rdi+0x70]
  4699bf:	mov    r9d,ecx
  4699c2:	shl    rdx,0x4
  4699c6:	sub    r9d,esi
  4699c9:	add    rdx,r10
  4699cc:	and    r9d,DWORD PTR [r15+0x74]
  4699d0:	lea    r8d,[rdi-0x1]
  4699d4:	mov    QWORD PTR [rbp-0x50],rdx
  4699d8:	cmp    r9d,r8d
  4699db:	jb     46a1cd
  4699e1:	and    rax,0xfffffffffffffffc
  4699e5:	mov    r12d,DWORD PTR [r15+0x80]
  4699ec:	shl    rax,0x4
  4699f0:	shl    rdi,0x2
  4699f4:	add    rax,r10
  4699f7:	mov    QWORD PTR [rbp-0x58],rax
  4699fb:	mov    r14,QWORD PTR [r15+0xb0]
  469a02:	mov    r8,QWORD PTR [r15+0xb8]
  469a09:	mov    r13,QWORD PTR [rip+0x2b1e0]        # 494bf0
  469a10:	lea    r9,[rdi-0x1]
  469a14:	lea    rbx,[rsi*4+0x0]
  469a1c:	lea    rdx,[rcx*4+0x0]
  469a24:	not    r12d
  469a27:	cmp    r10,rax
  469a2a:	je     469c84
  469a30:	mov    QWORD PTR [rbp-0x148],r15
  469a37:	mov    esi,0x55
  469a3c:	mov    r11,r10
  469a3f:	mov    r15,r8
  469a42:	mov    r10,rdi
  469a45:	mov    r8,r14
  469a48:	kmovb  k2,esi
  469a4c:	nop    DWORD PTR [rax+0x0]
  469a50:	lea    rdi,[rbp-0x40]
  469a54:	mov    QWORD PTR [rbp-0x48],rdi
  469a58:	mov    QWORD PTR [rbp-0xb0],r11
  469a5f:	mov    r14,r10
  469a62:	nop    WORD PTR [rax+rax*1+0x0]
  469a68:	lea    rax,[rbx+0x10]
  469a6c:	lea    rcx,[r8+rbx*4]
  469a70:	cmp    r14,rax
  469a73:	jb     46a130
  469a79:	vmovdqu64 zmm5,ZMMWORD PTR [rcx]
  469a7f:	lea    rcx,[r15+rbx*1]
  469a83:	add    rbx,0x60
  469a87:	and    rbx,r9
  469a8a:	andn   r10d,r12d,DWORD PTR [r15+rbx*1]
  469a90:	shl    r10,0x4
  469a94:	andn   edi,r12d,DWORD PTR [r15+rbx*1+0xc]
  469a9b:	shl    rdi,0x4
  469a9f:	prefetchw BYTE PTR [r13+r10*1+0x0]
  469aa5:	prefetchw BYTE PTR [r13+rdi*1+0x0]
  469aab:	mov    r10d,DWORD PTR [rcx]
  469aae:	andn   edi,r12d,r10d
  469ab3:	shl    rdi,0x4
  469ab7:	add    rdi,r13
  469aba:	vmovdqa64 zmm10,ZMMWORD PTR [rdi]
  469ac0:	vshufi64x2 zmm0,zmm5,zmm5,0x0
  469ac7:	vpcmpequq k6{k2},zmm10,zmm0
  469ace:	and    rax,r9
  469ad1:	andn   esi,r12d,DWORD PTR [r15+rbx*1+0x4]
  469ad8:	shl    rsi,0x4
  469adc:	andn   r11d,r12d,DWORD PTR [r15+rbx*1+0x8]
  469ae3:	shl    r11,0x4
  469ae7:	prefetchw BYTE PTR [r13+rsi*1+0x0]
  469aed:	prefetchw BYTE PTR [r13+r11*1+0x0]
  469af3:	mov    rbx,rax
  469af6:	kortestb k6,k6
  469afa:	je     46a060
  469b00:	kaddb  k1,k6,k6
  469b04:	vmovdqu64 ZMMWORD PTR [rdi]{k1},zmm0
  469b0a:	mov    r11d,DWORD PTR [rcx+0x4]
  469b0e:	andn   edi,r12d,r11d
  469b13:	shl    rdi,0x4
  469b17:	add    rdi,r13
  469b1a:	vmovdqa64 zmm12,ZMMWORD PTR [rdi]
  469b20:	vshufi64x2 zmm0,zmm5,zmm5,0x55
  469b27:	vpcmpequq k0{k2},zmm12,zmm0
  469b2e:	kortestb k0,k0
  469b32:	je     469ee8
  469b38:	kaddb  k4,k0,k0
  469b3c:	vmovdqu64 ZMMWORD PTR [rdi]{k4},zmm0
  469b42:	mov    esi,DWORD PTR [rcx+0x8]
  469b45:	andn   edi,r12d,esi
  469b4a:	shl    rdi,0x4
  469b4e:	add    rdi,r13
  469b51:	vmovdqa64 zmm14,ZMMWORD PTR [rdi]
  469b57:	vshufi64x2 zmm0,zmm5,zmm5,0xaa
  469b5e:	vpcmpequq k5{k2},zmm14,zmm0
  469b65:	kortestb k5,k5
  469b69:	je     469e20
  469b6f:	kaddb  k7,k5,k5
  469b73:	vmovdqu64 ZMMWORD PTR [rdi]{k7},zmm0
  469b79:	mov    r10d,DWORD PTR [rcx+0xc]
  469b7d:	andn   edi,r12d,r10d
  469b82:	shl    rdi,0x4
  469b86:	add    rdi,r13
  469b89:	vmovdqa64 zmm0,ZMMWORD PTR [rdi]
  469b8f:	vshufi64x2 zmm3,zmm5,zmm5,0xff
  469b96:	vpcmpequq k1{k2},zmm0,zmm3
  469b9d:	kortestb k1,k1
  469ba1:	je     469fb8
  469ba7:	kaddb  k3,k1,k1
  469bab:	vmovdqu64 ZMMWORD PTR [rdi]{k3},zmm3
  469bb1:	mov    rsi,rbx
  469bb4:	sub    rsi,rdx
  469bb7:	and    rsi,r9
  469bba:	cmp    rsi,0x13
  469bbe:	jbe    469a68
  469bc4:	mov    r11,QWORD PTR [rbp-0xb0]
  469bcb:	mov    esi,0xffffffff
  469bd0:	mov    ecx,0xffffffff
  469bd5:	crc32  rsi,QWORD PTR [r11+0x10]
  469bdc:	mov    eax,0xffffffff
  469be1:	andn   edi,r12d,esi
  469be6:	shl    rdi,0x4
  469bea:	prefetcht1 BYTE PTR [r13+rdi*1+0x0]
  469bf0:	mov    edi,0xffffffff
  469bf5:	mov    r10,r14
  469bf8:	crc32  rcx,QWORD PTR [r11]
  469bfe:	crc32  rax,QWORD PTR [r11+0x20]
  469c05:	andn   r14d,r12d,ecx
  469c0a:	shl    r14,0x4
  469c0e:	crc32  rdi,QWORD PTR [r11+0x30]
  469c15:	prefetcht1 BYTE PTR [r13+r14*1+0x0]
  469c1b:	andn   r14d,r12d,eax
  469c20:	shl    r14,0x4
  469c24:	prefetcht1 BYTE PTR [r13+r14*1+0x0]
  469c2a:	andn   r14d,r12d,edi
  469c2f:	shl    r14,0x4
  469c33:	prefetcht1 BYTE PTR [r13+r14*1+0x0]
  469c39:	lea    r14,[rdx+0x10]
  469c3d:	vmovdqu64 zmm0,ZMMWORD PTR [r11]
  469c43:	cmp    r10,r14
  469c46:	jb     40dfde
  469c4c:	vmovdqu64 ZMMWORD PTR [r8+rdx*4],zmm0
  469c53:	add    r11,0x40
  469c57:	mov    DWORD PTR [r15+rdx*1],ecx
  469c5b:	mov    DWORD PTR [r15+rdx*1+0x4],esi
  469c60:	mov    DWORD PTR [r15+rdx*1+0x8],eax
  469c65:	mov    DWORD PTR [r15+rdx*1+0xc],edi
  469c6a:	mov    rdx,r14
  469c6d:	and    rdx,r9
  469c70:	cmp    QWORD PTR [rbp-0x58],r11
  469c74:	jne    469a50
  469c7a:	mov    r15,QWORD PTR [rbp-0x148]
  469c81:	mov    r10,r11
  469c84:	vmovq  xmm8,rdx
  469c89:	vpinsrq xmm9,xmm8,rbx,0x1
  469c8f:	vpsrlq xmm10,xmm9,0x2
  469c95:	mov    r14,QWORD PTR [rbp-0x50]
  469c99:	vpmovqd xmm11,xmm10
  469c9f:	vpextrd eax,xmm11,0x1
  469ca5:	vmovq  QWORD PTR [r15+0xc8],xmm11
  469cae:	cmp    r10,r14
  469cb1:	je     46a1b3
  469cb7:	mov    rsi,QWORD PTR [rip+0x2af32]        # 494bf0
  469cbe:	mov    rcx,QWORD PTR [r15+0xb8]
  469cc5:	mov    r9d,DWORD PTR [r15+0x74]
  469cc9:	mov    rdx,QWORD PTR [r15+0xb0]
  469cd0:	mov    r13,QWORD PTR [rbp-0x150]
  469cd7:	mov    ebx,0xffffffff
  469cdc:	mov    r12,r10
  469cdf:	jmp    469d5d
  469ce1:	nop    DWORD PTR [rax+0x0]
  469ce8:	cmp    r8,0x8
  469cec:	jne    469cf8
  469cee:	mov    r13,rbx
  469cf1:	crc32  r13,QWORD PTR [r12]
  469cf8:	mov    r10d,r13d
  469cfb:	mov    rdi,QWORD PTR [r15+0x88]
  469d02:	mov    r11d,DWORD PTR [r15+0xc8]
  469d09:	dec    rdi
  469d0c:	and    rdi,r13
  469d0f:	vmovdqu xmm5,XMMWORD PTR [r12]
  469d15:	and    rdi,0xfffffffffffffffc
  469d19:	mov    rax,r11
  469d1c:	shl    rdi,0x4
  469d20:	shl    rax,0x4
  469d24:	prefetcht1 BYTE PTR [rsi+rdi*1]
  469d28:	vmovdqu XMMWORD PTR [rdx+rax*1],xmm5
  469d2d:	mov    DWORD PTR [rcx+r11*4],r10d
  469d31:	add    r12,0x10
  469d35:	mov    r8d,DWORD PTR [r15+0xc8]
  469d3c:	mov    r9d,DWORD PTR [r15+0x74]
  469d40:	inc    r8d
  469d43:	and    r8d,r9d
  469d46:	mov    DWORD PTR [r15+0xc8],r8d
  469d4d:	cmp    r12,r14
  469d50:	je     46a1b3
  469d56:	mov    eax,DWORD PTR [r15+0xcc]
  469d5d:	mov    r8d,DWORD PTR [r15+0x80]
  469d64:	lea    edi,[rax+0x18]
  469d67:	and    edi,r9d
  469d6a:	mov    r11d,r8d
  469d6d:	and    r11d,DWORD PTR [rcx+rdi*4]
  469d71:	mov    r10,r11
  469d74:	lea    edi,[rax+0x1]
  469d77:	and    edi,r9d
  469d7a:	shl    r10,0x4
  469d7e:	prefetchw BYTE PTR [rsi+r10*1]
  469d83:	mov    DWORD PTR [r15+0xcc],edi
  469d8a:	mov    r9d,DWORD PTR [rcx+rax*4]
  469d8e:	shl    rax,0x4
  469d92:	vbroadcasti32x4 zmm15,XMMWORD PTR [rdx+rax*1]
  469d99:	lea    r11,[rdx+rax*1]
  469d9d:	mov    rax,QWORD PTR [r15+0x90]
  469da4:	cmp    QWORD PTR [r11],rax
  469da7:	je     46a357
  469dad:	mov    edi,r8d
  469db0:	and    edi,r9d
  469db3:	shl    rdi,0x4
  469db7:	add    rdi,rsi
  469dba:	vmovdqa64 zmm13,ZMMWORD PTR [rdi]
  469dc0:	mov    ecx,0x55
  469dc5:	kmovb  k4,ecx
  469dc9:	vpcmpequq k5{k4},zmm13,zmm15
  469dd0:	kortestb k5,k5
  469dd4:	je     46a36e
  469dda:	kaddb  k7,k5,k5
  469dde:	vmovdqu64 ZMMWORD PTR [rdi]{k7},zmm15
  469de4:	mov    rsi,QWORD PTR [rip+0x2ae05]        # 494bf0
  469deb:	mov    rdx,QWORD PTR [r15+0xb0]
  469df2:	mov    rcx,QWORD PTR [r15+0xb8]
  469df9:	mov    r8,QWORD PTR [r15+0x60]
  469dfd:	cmp    r8,0x4
  469e01:	jne    469ce8
  469e07:	mov    r10d,0xffffffff
  469e0d:	crc32  r10d,DWORD PTR [r12]
  469e14:	mov    r13d,r10d
  469e17:	jmp    469cfb
  469e1c:	nop    DWORD PTR [rax+0x0]
  469e20:	vpxor  xmm15,xmm15,xmm15
  469e25:	vpcmpequq k6{k2},zmm14,zmm15
  469e2c:	kortestb k6,k6
  469e30:	je     469eb0
  469e32:	mov    DWORD PTR [rbp-0x68],esi
  469e35:	xor    esi,esi
  469e37:	mov    QWORD PTR [rbp-0x60],rcx
  469e3b:	kmovb  ecx,k6
  469e3f:	tzcnt  esi,ecx
  469e43:	sar    esi,1
  469e45:	mov    QWORD PTR [rbp-0x140],r8
  469e4c:	mov    QWORD PTR [rbp-0x138],rdx
  469e53:	mov    QWORD PTR [rbp-0x70],r9
  469e57:	vmovdqa64 ZMMWORD PTR [rbp-0x130],zmm5
  469e61:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm0
  469e6b:	call   433430
  469e70:	test   al,al
  469e72:	mov    r9d,0x55
  469e78:	kmovb  k2,r9d
  469e7d:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0xf0]
  469e87:	vmovdqa64 zmm5,ZMMWORD PTR [rbp-0x130]
  469e91:	mov    rcx,QWORD PTR [rbp-0x60]
  469e95:	mov    esi,DWORD PTR [rbp-0x68]
  469e98:	mov    r9,QWORD PTR [rbp-0x70]
  469e9c:	mov    rdx,QWORD PTR [rbp-0x138]
  469ea3:	mov    r8,QWORD PTR [rbp-0x140]
  469eaa:	jne    469b79
  469eb0:	mov    r11d,0xffffffff
  469eb6:	crc32  r11,rsi
  469ebc:	andn   edi,r12d,r11d
  469ec1:	shl    rdi,0x4
  469ec5:	prefetcht1 BYTE PTR [r13+rdi*1+0x0]
  469ecb:	vmovdqu XMMWORD PTR [r8+rdx*4],xmm0
  469ed1:	mov    DWORD PTR [r15+rdx*1],r11d
  469ed5:	add    rdx,0x4
  469ed9:	and    rdx,r9
  469edc:	jmp    469b79
  469ee1:	nop    DWORD PTR [rax+0x0]
  469ee8:	vpxor  xmm13,xmm13,xmm13
  469eed:	vpcmpequq k3{k2},zmm12,zmm13
  469ef4:	kortestb k3,k3
  469ef8:	je     469f80
  469efe:	xor    esi,esi
  469f00:	mov    QWORD PTR [rbp-0x140],r8
  469f07:	kmovb  r8d,k3
  469f0b:	tzcnt  esi,r8d
  469f10:	sar    esi,1
  469f12:	mov    QWORD PTR [rbp-0x138],rdx
  469f19:	mov    QWORD PTR [rbp-0x70],r9
  469f1d:	mov    DWORD PTR [rbp-0x68],r11d
  469f21:	mov    QWORD PTR [rbp-0x60],rcx
  469f25:	vmovdqa64 ZMMWORD PTR [rbp-0x130],zmm5
  469f2f:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm0
  469f39:	call   433430
  469f3e:	test   al,al
  469f40:	mov    edi,0x55
  469f45:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0xf0]
  469f4f:	vmovdqa64 zmm5,ZMMWORD PTR [rbp-0x130]
  469f59:	mov    rcx,QWORD PTR [rbp-0x60]
  469f5d:	mov    r11d,DWORD PTR [rbp-0x68]
  469f61:	mov    r9,QWORD PTR [rbp-0x70]
  469f65:	mov    rdx,QWORD PTR [rbp-0x138]
  469f6c:	mov    r8,QWORD PTR [rbp-0x140]
  469f73:	kmovb  k2,edi
  469f77:	jne    469b42
  469f7d:	nop    DWORD PTR [rax]
  469f80:	mov    r10d,0xffffffff
  469f86:	crc32  r10,r11
  469f8c:	andn   eax,r12d,r10d
  469f91:	shl    rax,0x4
  469f95:	prefetcht1 BYTE PTR [r13+rax*1+0x0]
  469f9b:	vmovdqu XMMWORD PTR [r8+rdx*4],xmm0
  469fa1:	mov    DWORD PTR [r15+rdx*1],r10d
  469fa5:	add    rdx,0x4
  469fa9:	and    rdx,r9
  469fac:	jmp    469b42
  469fb1:	nop    DWORD PTR [rax+0x0]
  469fb8:	vpxor  xmm2,xmm2,xmm2
  469fbc:	vpcmpequq k0{k2},zmm0,zmm2
  469fc3:	kortestb k0,k0
  469fc7:	je     46a030
  469fc9:	xor    esi,esi
  469fcb:	mov    QWORD PTR [rbp-0x68],rdx
  469fcf:	kmovb  edx,k0
  469fd3:	tzcnt  esi,edx
  469fd7:	sar    esi,1
  469fd9:	vmovdqa64 zmm0,zmm3
  469fdf:	mov    QWORD PTR [rbp-0x70],r8
  469fe3:	mov    QWORD PTR [rbp-0x60],r9
  469fe7:	mov    DWORD PTR [rbp-0x130],r10d
  469fee:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm3
  469ff8:	call   433430
  469ffd:	test   al,al
  469fff:	mov    r8d,0x55
  46a005:	kmovb  k2,r8d
  46a00a:	vmovdqa64 zmm3,ZMMWORD PTR [rbp-0xf0]
  46a014:	mov    r10d,DWORD PTR [rbp-0x130]
  46a01b:	mov    r9,QWORD PTR [rbp-0x60]
  46a01f:	mov    rdx,QWORD PTR [rbp-0x68]
  46a023:	mov    r8,QWORD PTR [rbp-0x70]
  46a027:	jne    469bb1
  46a02d:	nop    DWORD PTR [rax]
  46a030:	mov    eax,0xffffffff
  46a035:	crc32  rax,r10
  46a03b:	andn   ecx,r12d,eax
  46a040:	shl    rcx,0x4
  46a044:	prefetcht1 BYTE PTR [r13+rcx*1+0x0]
  46a04a:	vmovdqu XMMWORD PTR [r8+rdx*4],xmm3
  46a050:	mov    DWORD PTR [r15+rdx*1],eax
  46a054:	add    rdx,0x4
  46a058:	and    rdx,r9
  46a05b:	jmp    469bb1
  46a060:	vpxor  xmm11,xmm11,xmm11
  46a065:	vpcmpequq k7{k2},zmm10,zmm11
  46a06c:	kortestb k7,k7
  46a070:	je     46a0f8
  46a076:	xor    esi,esi
  46a078:	mov    QWORD PTR [rbp-0x70],r9
  46a07c:	kmovb  r9d,k7
  46a080:	tzcnt  esi,r9d
  46a085:	sar    esi,1
  46a087:	mov    QWORD PTR [rbp-0x140],r8
  46a08e:	mov    QWORD PTR [rbp-0x138],rdx
  46a095:	mov    DWORD PTR [rbp-0x68],r10d
  46a099:	mov    QWORD PTR [rbp-0x60],rcx
  46a09d:	vmovdqa64 ZMMWORD PTR [rbp-0x130],zmm5
  46a0a7:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm0
  46a0b1:	call   433430
  46a0b6:	test   al,al
  46a0b8:	mov    edx,0x55
  46a0bd:	kmovb  k2,edx
  46a0c1:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0xf0]
  46a0cb:	vmovdqa64 zmm5,ZMMWORD PTR [rbp-0x130]
  46a0d5:	mov    rcx,QWORD PTR [rbp-0x60]
  46a0d9:	mov    r10d,DWORD PTR [rbp-0x68]
  46a0dd:	mov    r9,QWORD PTR [rbp-0x70]
  46a0e1:	mov    rdx,QWORD PTR [rbp-0x138]
  46a0e8:	mov    r8,QWORD PTR [rbp-0x140]
  46a0ef:	jne    469b0a
  46a0f5:	nop    DWORD PTR [rax]
  46a0f8:	mov    eax,0xffffffff
  46a0fd:	crc32  rax,r10
  46a103:	andn   esi,r12d,eax
  46a108:	shl    rsi,0x4
  46a10c:	prefetcht1 BYTE PTR [r13+rsi*1+0x0]
  46a112:	vmovdqu XMMWORD PTR [r8+rdx*4],xmm0
  46a118:	mov    DWORD PTR [r15+rdx*1],eax
  46a11c:	add    rdx,0x4
  46a120:	and    rdx,r9
  46a123:	jmp    469b0a
  46a128:	nop    DWORD PTR [rax+rax*1+0x0]
  46a130:	mov    rdi,r14
  46a133:	sub    rdi,rbx
  46a136:	mov    r11,rdi
  46a139:	shr    r11,1
  46a13c:	mov    r10d,0x1
  46a142:	shlx   esi,r10d,r11d
  46a147:	lea    r11d,[rsi-0x1]
  46a14b:	kmovb  k4,r11d
  46a150:	mov    r10,r9
  46a153:	lea    r11,[rbx+0x8]
  46a157:	vmovdqu64 zmm5{k4}{z},ZMMWORD PTR [rcx]
  46a15d:	shl    rdi,0x2
  46a161:	neg    esi
  46a163:	mov    rcx,r8
  46a166:	and    r10,rbx
  46a169:	and    r11,r9
  46a16c:	sub    rcx,rdi
  46a16f:	kmovb  k5,esi
  46a173:	vmovd  xmm4,DWORD PTR [r15+r11*1]
  46a179:	vmovd  xmm7,DWORD PTR [r15+r10*1]
  46a17f:	lea    rsi,[rbx+0x4]
  46a183:	lea    rdi,[rbx+0xc]
  46a187:	and    rsi,r9
  46a18a:	and    rdi,r9
  46a18d:	vpinsrd xmm6,xmm4,DWORD PTR [r15+rdi*1],0x1
  46a194:	vpinsrd xmm8,xmm7,DWORD PTR [r15+rsi*1],0x1
  46a19b:	vmovdqu64 zmm5{k5},ZMMWORD PTR [rcx]
  46a1a1:	vpunpcklqdq xmm9,xmm8,xmm6
  46a1a5:	mov    rcx,QWORD PTR [rbp-0x48]
  46a1a9:	vmovdqa XMMWORD PTR [rbp-0x40],xmm9
  46a1ae:	jmp    469a83
  46a1b3:	vzeroupper
  46a1b6:	add    rsp,0x140
  46a1bd:	pop    rbx
  46a1be:	pop    rcx
  46a1bf:	pop    r12
  46a1c1:	pop    r13
  46a1c3:	pop    r14
  46a1c5:	pop    r15
  46a1c7:	pop    rbp
  46a1c8:	lea    rsp,[rcx-0x8]
  46a1cc:	ret
  46a1cd:	cmp    r10,QWORD PTR [rbp-0x50]
  46a1d1:	je     46a1b6
  46a1d3:	mov    r11,QWORD PTR [r15+0x88]
  46a1da:	mov    r8,QWORD PTR [r15+0x60]
  46a1de:	mov    rdi,QWORD PTR [rip+0x2aa0b]        # 494bf0
  46a1e5:	mov    rcx,QWORD PTR [r15+0xb0]
  46a1ec:	mov    rsi,QWORD PTR [r15+0xb8]
  46a1f3:	lea    r9,[r11-0x1]
  46a1f7:	mov    r12d,0xffffffff
  46a1fd:	nop    DWORD PTR [rax]
  46a200:	cmp    r8,0x4
  46a204:	je     46a343
  46a20a:	cmp    r8,0x8
  46a20e:	jne    46a219
  46a210:	mov    rbx,r12
  46a213:	crc32  rbx,QWORD PTR [r10]
  46a219:	mov    r13d,ebx
  46a21c:	mov    eax,DWORD PTR [r15+0xc8]
  46a223:	mov    r14,r9
  46a226:	and    r14,rbx
  46a229:	vmovdqu xmm5,XMMWORD PTR [r10]
  46a22e:	mov    rdx,rax
  46a231:	and    r14,0xfffffffffffffffc
  46a235:	shl    rdx,0x4
  46a239:	shl    r14,0x4
  46a23d:	prefetcht1 BYTE PTR [rdi+r14*1]
  46a242:	vmovdqu XMMWORD PTR [rcx+rdx*1],xmm5
  46a247:	mov    DWORD PTR [rsi+rax*4],r13d
  46a24b:	add    r10,0x10
  46a24f:	mov    eax,DWORD PTR [r15+0xc8]
  46a256:	mov    edx,DWORD PTR [r15+0x74]
  46a25a:	inc    eax
  46a25c:	and    eax,edx
  46a25e:	mov    DWORD PTR [r15+0xc8],eax
  46a265:	cmp    r10,QWORD PTR [rbp-0x50]
  46a269:	je     46a1b3
  46a26f:	mov    r11d,DWORD PTR [r15+0xcc]
  46a276:	mov    r13d,DWORD PTR [r15+0x70]
  46a27a:	sub    eax,r11d
  46a27d:	and    eax,edx
  46a27f:	lea    r14d,[r13-0x1]
  46a283:	cmp    eax,r14d
  46a286:	jb     46a200
  46a28c:	mov    r13d,DWORD PTR [r15+0x80]
  46a293:	lea    r9d,[r11+0x18]
  46a297:	and    r9d,edx
  46a29a:	mov    eax,r13d
  46a29d:	and    eax,DWORD PTR [rsi+r9*4]
  46a2a1:	lea    r14d,[r11+0x1]
  46a2a5:	mov    r8,rax
  46a2a8:	and    r14d,edx
  46a2ab:	shl    r8,0x4
  46a2af:	prefetchw BYTE PTR [rdi+r8*1]
  46a2b4:	mov    DWORD PTR [r15+0xcc],r14d
  46a2bb:	mov    r14d,DWORD PTR [rsi+r11*4]
  46a2bf:	shl    r11,0x4
  46a2c3:	vbroadcasti32x4 zmm1,XMMWORD PTR [rcx+r11*1]
  46a2ca:	lea    r9,[rcx+r11*1]
  46a2ce:	mov    r11,QWORD PTR [r15+0x90]
  46a2d5:	cmp    QWORD PTR [r9],r11
  46a2d8:	je     46a43f
  46a2de:	mov    edx,r13d
  46a2e1:	and    edx,r14d
  46a2e4:	shl    rdx,0x4
  46a2e8:	add    rdx,rdi
  46a2eb:	vmovdqa64 zmm0,ZMMWORD PTR [rdx]
  46a2f1:	mov    esi,0x55
  46a2f6:	kmovb  k1,esi
  46a2fa:	vpcmpequq k0{k1},zmm0,zmm1
  46a301:	kortestb k0,k0
  46a305:	je     46a465
  46a30b:	kaddb  k3,k0,k0
  46a30f:	vmovdqu64 ZMMWORD PTR [rdx]{k3},zmm1
  46a315:	mov    r13,QWORD PTR [r15+0x88]
  46a31c:	mov    r8,QWORD PTR [r15+0x60]
  46a320:	mov    rdi,QWORD PTR [rip+0x2a8c9]        # 494bf0
  46a327:	mov    rcx,QWORD PTR [r15+0xb0]
  46a32e:	mov    rsi,QWORD PTR [r15+0xb8]
  46a335:	lea    r9,[r13-0x1]
  46a339:	cmp    r8,0x4
  46a33d:	jne    46a20a
  46a343:	mov    r13d,0xffffffff
  46a349:	crc32  r13d,DWORD PTR [r10]
  46a34f:	mov    ebx,r13d
  46a352:	jmp    46a21c
  46a357:	mov    r9,QWORD PTR [r11+0x8]
  46a35b:	mov    BYTE PTR [rip+0x2a79e],0x1        # 494b00
  46a362:	mov    QWORD PTR [rip+0x2a79f],r9        # 494b08
  46a369:	jmp    469df9
  46a36e:	vpxor  xmm14,xmm14,xmm14
  46a373:	vpcmpequq k6{k4},zmm13,zmm14
  46a37a:	kortestb k6,k6
  46a37e:	jne    46a3eb
  46a380:	mov    r10,rbx
  46a383:	mov    r11d,DWORD PTR [r15+0xc8]
  46a38a:	crc32  r10,r9
  46a390:	mov    edi,r8d
  46a393:	and    edi,r10d
  46a396:	shl    rdi,0x4
  46a39a:	shl    r11,0x4
  46a39e:	prefetcht1 BYTE PTR [rsi+rdi*1]
  46a3a2:	vmovdqa XMMWORD PTR [rdx+r11*1],xmm15
  46a3a8:	mov    edx,DWORD PTR [r15+0xc8]
  46a3af:	mov    rcx,QWORD PTR [r15+0xb8]
  46a3b6:	mov    rsi,QWORD PTR [rip+0x2a833]        # 494bf0
  46a3bd:	mov    DWORD PTR [rcx+rdx*4],r10d
  46a3c1:	mov    rdx,QWORD PTR [r15+0xb0]
  46a3c8:	mov    eax,DWORD PTR [r15+0xc8]
  46a3cf:	mov    r9d,DWORD PTR [r15+0x74]
  46a3d3:	inc    eax
  46a3d5:	and    eax,r9d
  46a3d8:	mov    DWORD PTR [r15+0xc8],eax
  46a3df:	mov    eax,DWORD PTR [r15+0xcc]
  46a3e6:	jmp    469d64
  46a3eb:	kmovb  esi,k6
  46a3ef:	tzcnt  esi,esi
  46a3f3:	sar    esi,1
  46a3f5:	vmovdqa64 zmm0,zmm15
  46a3fb:	mov    DWORD PTR [rbp-0x50],r9d
  46a3ff:	mov    DWORD PTR [rbp-0x48],r8d
  46a403:	vmovdqa32 ZMMWORD PTR [rbp-0xb0],zmm15
  46a40d:	call   433430
  46a412:	mov    rsi,QWORD PTR [rip+0x2a7d7]        # 494bf0
  46a419:	mov    rdx,QWORD PTR [r15+0xb0]
  46a420:	test   al,al
  46a422:	jne    46a52e
  46a428:	mov    r9d,DWORD PTR [rbp-0x50]
  46a42c:	mov    r8d,DWORD PTR [rbp-0x48]
  46a430:	vmovdqa32 zmm15,ZMMWORD PTR [rbp-0xb0]
  46a43a:	jmp    46a380
  46a43f:	mov    rdx,QWORD PTR [r9+0x8]
  46a443:	mov    rax,QWORD PTR [r15+0x88]
  46a44a:	mov    QWORD PTR [rip+0x2a6b7],rdx        # 494b08
  46a451:	mov    BYTE PTR [rip+0x2a6a8],0x1        # 494b00
  46a458:	mov    r8,QWORD PTR [r15+0x60]
  46a45c:	lea    r9,[rax-0x1]
  46a460:	jmp    46a200
  46a465:	vpxor  xmm3,xmm3,xmm3
  46a469:	vpcmpequq k2{k1},zmm0,zmm3
  46a470:	kortestb k2,k2
  46a474:	je     46a4c3
  46a476:	xor    esi,esi
  46a478:	mov    QWORD PTR [rbp-0x48],r10
  46a47c:	kmovb  r10d,k2
  46a480:	tzcnt  esi,r10d
  46a485:	sar    esi,1
  46a487:	vmovdqa64 zmm0,zmm1
  46a48d:	mov    rdi,rdx
  46a490:	vmovdqa32 ZMMWORD PTR [rbp-0xb0],zmm1
  46a49a:	call   433430
  46a49f:	test   al,al
  46a4a1:	vmovdqa32 zmm1,ZMMWORD PTR [rbp-0xb0]
  46a4ab:	mov    r10,QWORD PTR [rbp-0x48]
  46a4af:	jne    46a315
  46a4b5:	mov    rdi,QWORD PTR [rip+0x2a734]        # 494bf0
  46a4bc:	mov    rcx,QWORD PTR [r15+0xb0]
  46a4c3:	mov    r8,r12
  46a4c6:	crc32  r8,r14
  46a4cc:	mov    eax,r13d
  46a4cf:	and    eax,r8d
  46a4d2:	shl    rax,0x4
  46a4d6:	prefetcht1 BYTE PTR [rdi+rax*1]
  46a4da:	mov    edi,DWORD PTR [r15+0xc8]
  46a4e1:	shl    rdi,0x4
  46a4e5:	vmovdqa XMMWORD PTR [rcx+rdi*1],xmm1
  46a4ea:	mov    ecx,DWORD PTR [r15+0xc8]
  46a4f1:	mov    rsi,QWORD PTR [r15+0xb8]
  46a4f8:	mov    rdi,QWORD PTR [rip+0x2a6f1]        # 494bf0
  46a4ff:	mov    DWORD PTR [rsi+rcx*4],r8d
  46a503:	mov    rcx,QWORD PTR [r15+0xb0]
  46a50a:	mov    r14d,DWORD PTR [r15+0xc8]
  46a511:	mov    edx,DWORD PTR [r15+0x74]
  46a515:	inc    r14d
  46a518:	and    r14d,edx
  46a51b:	mov    DWORD PTR [r15+0xc8],r14d
  46a522:	mov    r11d,DWORD PTR [r15+0xcc]
  46a529:	jmp    46a293
  46a52e:	mov    rcx,QWORD PTR [r15+0xb8]
  46a535:	jmp    469df9
