0000000000469960:
  469960:	lea    r10,[rsp+0x8]
  469965:	and    rsp,0xffffffffffffffc0
  469969:	push   QWORD PTR [r10-0x8]
  46996d:	push   rbp
  46996e:	mov    rbp,rsp
  469971:	push   r15
  469973:	mov    r15,rdi
  469976:	push   r14
  469978:	push   r13
  46997a:	push   r12
  46997c:	push   r10
  46997e:	push   rbx
  46997f:	sub    rsp,0x140
  469986:	mov    rax,QWORD PTR [rsi+0x8]
  46998a:	mov    ecx,DWORD PTR [rdi+0xc8]
  469990:	mov    r10,QWORD PTR [rsi]
  469993:	mov    esi,DWORD PTR [rdi+0xcc]
  469999:	mov    rdx,rax
  46999c:	mov    edi,DWORD PTR [rdi+0x70]
  46999f:	mov    r9d,ecx
  4699a2:	shl    rdx,0x4
  4699a6:	sub    r9d,esi
  4699a9:	add    rdx,r10
  4699ac:	and    r9d,DWORD PTR [r15+0x74]
  4699b0:	lea    r8d,[rdi-0x1]
  4699b4:	mov    QWORD PTR [rbp-0x50],rdx
  4699b8:	cmp    r9d,r8d
  4699bb:	jb     46a1bd
  4699c1:	and    rax,0xfffffffffffffffc
  4699c5:	mov    r12d,DWORD PTR [r15+0x80]
  4699cc:	shl    rax,0x4
  4699d0:	shl    rdi,0x2
  4699d4:	add    rax,r10
  4699d7:	mov    QWORD PTR [rbp-0x58],rax
  4699db:	mov    r14,QWORD PTR [r15+0xb0]
  4699e2:	mov    r8,QWORD PTR [r15+0xb8]
  4699e9:	mov    r13,QWORD PTR [rip+0x2b200]        # 494bf0
  4699f0:	lea    r9,[rdi-0x1]
  4699f4:	lea    rbx,[rsi*4+0x0]
  4699fc:	lea    rdx,[rcx*4+0x0]
  469a04:	not    r12d
  469a07:	cmp    r10,rax
  469a0a:	je     469c6f
  469a10:	mov    QWORD PTR [rbp-0x148],r15
  469a17:	mov    esi,0x55
  469a1c:	mov    r11,r10
  469a1f:	mov    r15,r8
  469a22:	mov    r10,rdi
  469a25:	mov    r8,r14
  469a28:	kmovb  k2,esi
  469a2c:	nop    DWORD PTR [rax+0x0]
  469a30:	lea    rdi,[rbp-0x40]
  469a34:	mov    QWORD PTR [rbp-0x48],rdi
  469a38:	mov    QWORD PTR [rbp-0xb0],r11
  469a3f:	mov    r14,r10
  469a42:	nop    WORD PTR [rax+rax*1+0x0]
  469a48:	lea    rax,[rbx+0x10]
  469a4c:	lea    rcx,[r8+rbx*4]
  469a50:	cmp    r14,rax
  469a53:	jb     46a120
  469a59:	vmovdqu64 zmm6,ZMMWORD PTR [rcx]
  469a5f:	lea    rcx,[r15+rbx*1]
  469a63:	add    rbx,0x60
  469a67:	and    rbx,r9
  469a6a:	andn   r10d,r12d,DWORD PTR [r15+rbx*1]
  469a70:	shl    r10,0x4
  469a74:	andn   edi,r12d,DWORD PTR [r15+rbx*1+0xc]
  469a7b:	shl    rdi,0x4
  469a7f:	prefetchw BYTE PTR [r13+r10*1+0x0]
  469a85:	prefetchw BYTE PTR [r13+rdi*1+0x0]
  469a8b:	mov    r10d,DWORD PTR [rcx]
  469a8e:	andn   edi,r12d,r10d
  469a93:	shl    rdi,0x4
  469a97:	add    rdi,r13
  469a9a:	vmovdqa64 zmm10,ZMMWORD PTR [rdi]
  469aa0:	vshufi64x2 zmm0,zmm6,zmm6,0x0
  469aa7:	vpcmpequq k6{k2},zmm10,zmm0
  469aae:	and    rax,r9
  469ab1:	andn   esi,r12d,DWORD PTR [r15+rbx*1+0x4]
  469ab8:	shl    rsi,0x4
  469abc:	andn   r11d,r12d,DWORD PTR [r15+rbx*1+0x8]
  469ac3:	shl    r11,0x4
  469ac7:	prefetchw BYTE PTR [r13+rsi*1+0x0]
  469acd:	prefetchw BYTE PTR [r13+r11*1+0x0]
  469ad3:	mov    rbx,rax
  469ad6:	kortestb k6,k6
  469ada:	je     46a050
  469ae0:	kaddb  k1,k6,k6
  469ae4:	vmovdqu64 ZMMWORD PTR [rdi]{k1},zmm0
  469aea:	mov    r11d,DWORD PTR [rcx+0x4]
  469aee:	andn   edi,r12d,r11d
  469af3:	shl    rdi,0x4
  469af7:	add    rdi,r13
  469afa:	vmovdqa64 zmm12,ZMMWORD PTR [rdi]
  469b00:	vshufi64x2 zmm0,zmm6,zmm6,0x55
  469b07:	vpcmpequq k0{k2},zmm12,zmm0
  469b0e:	kortestb k0,k0
  469b12:	je     469ed8
  469b18:	kaddb  k4,k0,k0
  469b1c:	vmovdqu64 ZMMWORD PTR [rdi]{k4},zmm0
  469b22:	mov    esi,DWORD PTR [rcx+0x8]
  469b25:	andn   edi,r12d,esi
  469b2a:	shl    rdi,0x4
  469b2e:	add    rdi,r13
  469b31:	vmovdqa64 zmm14,ZMMWORD PTR [rdi]
  469b37:	vshufi64x2 zmm0,zmm6,zmm6,0xaa
  469b3e:	vpcmpequq k5{k2},zmm14,zmm0
  469b45:	kortestb k5,k5
  469b49:	je     469e08
  469b4f:	kaddb  k7,k5,k5
  469b53:	vmovdqu64 ZMMWORD PTR [rdi]{k7},zmm0
  469b59:	mov    r10d,DWORD PTR [rcx+0xc]
  469b5d:	andn   edi,r12d,r10d
  469b62:	shl    rdi,0x4
  469b66:	add    rdi,r13
  469b69:	vmovdqa64 zmm0,ZMMWORD PTR [rdi]
  469b6f:	vshufi64x2 zmm3,zmm6,zmm6,0xff
  469b76:	vpcmpequq k1{k2},zmm0,zmm3
  469b7d:	kortestb k1,k1
  469b81:	je     469fa8
  469b87:	kaddb  k3,k1,k1
  469b8b:	vmovdqu64 ZMMWORD PTR [rdi]{k3},zmm3
  469b91:	mov    rsi,rbx
  469b94:	sub    rsi,rdx
  469b97:	and    rsi,r9
  469b9a:	cmp    rsi,0x13
  469b9e:	jbe    469a48
  469ba4:	mov    r11,QWORD PTR [rbp-0xb0]
  469bab:	mov    ecx,0xffffffff
  469bb0:	mov    esi,0xffffffff
  469bb5:	mov    eax,0xffffffff
  469bba:	crc32  rcx,QWORD PTR [r11]
  469bc0:	crc32  rsi,QWORD PTR [r11+0x10]
  469bc7:	crc32  rax,QWORD PTR [r11+0x20]
  469bce:	andn   edi,r12d,esi
  469bd3:	shl    rdi,0x4
  469bd7:	prefetcht1 BYTE PTR [r13+rdi*1+0x0]
  469bdd:	mov    edi,0xffffffff
  469be2:	crc32  rdi,QWORD PTR [r11+0x30]
  469be9:	vmovd  xmm1,eax
  469bed:	vmovd  xmm5,ecx
  469bf1:	mov    r10,r14
  469bf4:	vpinsrd xmm4,xmm1,edi,0x1
  469bfa:	andn   r14d,r12d,ecx
  469bff:	shl    r14,0x4
  469c03:	vpinsrd xmm8,xmm5,esi,0x1
  469c09:	prefetcht1 BYTE PTR [r13+r14*1+0x0]
  469c0f:	andn   r14d,r12d,eax
  469c14:	shl    r14,0x4
  469c18:	prefetcht1 BYTE PTR [r13+r14*1+0x0]
  469c1e:	andn   r14d,r12d,edi
  469c23:	shl    r14,0x4
  469c27:	prefetcht1 BYTE PTR [r13+r14*1+0x0]
  469c2d:	lea    r14,[rdx+0x10]
  469c31:	vmovdqu64 zmm7,ZMMWORD PTR [r11]
  469c37:	vpunpcklqdq xmm1,xmm8,xmm4
  469c3b:	cmp    r10,r14
  469c3e:	jb     40dfc6
  469c44:	vmovdqu64 ZMMWORD PTR [r8+rdx*4],zmm7
  469c4b:	add    r11,0x40
  469c4f:	vmovdqu XMMWORD PTR [r15+rdx*1],xmm1
  469c55:	mov    rdx,r14
  469c58:	and    rdx,r9
  469c5b:	cmp    QWORD PTR [rbp-0x58],r11
  469c5f:	jne    469a30
  469c65:	mov    r15,QWORD PTR [rbp-0x148]
  469c6c:	mov    r10,r11
  469c6f:	vmovq  xmm9,rdx
  469c74:	vpinsrq xmm10,xmm9,rbx,0x1
  469c7a:	vpsrlq xmm11,xmm10,0x2
  469c80:	mov    r14,QWORD PTR [rbp-0x50]
  469c84:	vpmovqd xmm12,xmm11
  469c8a:	vpextrd eax,xmm12,0x1
  469c90:	vmovq  QWORD PTR [r15+0xc8],xmm12
  469c99:	cmp    r10,r14
  469c9c:	je     46a1a3
  469ca2:	mov    rsi,QWORD PTR [rip+0x2af47]        # 494bf0
  469ca9:	mov    rcx,QWORD PTR [r15+0xb8]
  469cb0:	mov    r9d,DWORD PTR [r15+0x74]
  469cb4:	mov    rdx,QWORD PTR [r15+0xb0]
  469cbb:	mov    r13,QWORD PTR [rbp-0x150]
  469cc2:	mov    ebx,0xffffffff
  469cc7:	mov    r12,r10
  469cca:	jmp    469d45
  469ccc:	nop    DWORD PTR [rax+0x0]
  469cd0:	cmp    r8,0x8
  469cd4:	jne    469ce0
  469cd6:	mov    r13,rbx
  469cd9:	crc32  r13,QWORD PTR [r12]
  469ce0:	mov    r10d,r13d
  469ce3:	mov    rdi,QWORD PTR [r15+0x88]
  469cea:	mov    r11d,DWORD PTR [r15+0xc8]
  469cf1:	dec    rdi
  469cf4:	and    rdi,r13
  469cf7:	vmovdqu xmm0,XMMWORD PTR [r12]
  469cfd:	and    rdi,0xfffffffffffffffc
  469d01:	mov    rax,r11
  469d04:	shl    rdi,0x4
  469d08:	shl    rax,0x4
  469d0c:	prefetcht1 BYTE PTR [rsi+rdi*1]
  469d10:	vmovdqu XMMWORD PTR [rdx+rax*1],xmm0
  469d15:	mov    DWORD PTR [rcx+r11*4],r10d
  469d19:	add    r12,0x10
  469d1d:	mov    r8d,DWORD PTR [r15+0xc8]
  469d24:	mov    r9d,DWORD PTR [r15+0x74]
  469d28:	inc    r8d
  469d2b:	and    r8d,r9d
  469d2e:	mov    DWORD PTR [r15+0xc8],r8d
  469d35:	cmp    r12,r14
  469d38:	je     46a1a3
  469d3e:	mov    eax,DWORD PTR [r15+0xcc]
  469d45:	mov    r8d,DWORD PTR [r15+0x80]
  469d4c:	lea    edi,[rax+0x18]
  469d4f:	and    edi,r9d
  469d52:	mov    r11d,r8d
  469d55:	and    r11d,DWORD PTR [rcx+rdi*4]
  469d59:	mov    r10,r11
  469d5c:	lea    edi,[rax+0x1]
  469d5f:	and    edi,r9d
  469d62:	shl    r10,0x4
  469d66:	prefetchw BYTE PTR [rsi+r10*1]
  469d6b:	mov    DWORD PTR [r15+0xcc],edi
  469d72:	mov    r9d,DWORD PTR [rcx+rax*4]
  469d76:	shl    rax,0x4
  469d7a:	vbroadcasti32x4 zmm6,XMMWORD PTR [rdx+rax*1]
  469d81:	lea    r11,[rdx+rax*1]
  469d85:	mov    rax,QWORD PTR [r15+0x90]
  469d8c:	cmp    QWORD PTR [r11],rax
  469d8f:	je     46a347
  469d95:	mov    edi,r8d
  469d98:	and    edi,r9d
  469d9b:	shl    rdi,0x4
  469d9f:	add    rdi,rsi
  469da2:	vmovdqa64 zmm14,ZMMWORD PTR [rdi]
  469da8:	mov    ecx,0x55
  469dad:	kmovb  k4,ecx
  469db1:	vpcmpequq k5{k4},zmm14,zmm6
  469db8:	kortestb k5,k5
  469dbc:	je     46a35e
  469dc2:	kaddb  k7,k5,k5
  469dc6:	vmovdqu64 ZMMWORD PTR [rdi]{k7},zmm6
  469dcc:	mov    rsi,QWORD PTR [rip+0x2ae1d]        # 494bf0
  469dd3:	mov    rdx,QWORD PTR [r15+0xb0]
  469dda:	mov    rcx,QWORD PTR [r15+0xb8]
  469de1:	mov    r8,QWORD PTR [r15+0x60]
  469de5:	cmp    r8,0x4
  469de9:	jne    469cd0
  469def:	mov    r10d,0xffffffff
  469df5:	crc32  r10d,DWORD PTR [r12]
  469dfc:	mov    r13d,r10d
  469dff:	jmp    469ce3
  469e04:	nop    DWORD PTR [rax+0x0]
  469e08:	vpxor  xmm15,xmm15,xmm15
  469e0d:	vpcmpequq k6{k2},zmm14,zmm15
  469e14:	kortestb k6,k6
  469e18:	je     469ea0
  469e1e:	mov    DWORD PTR [rbp-0x68],esi
  469e21:	xor    esi,esi
  469e23:	mov    QWORD PTR [rbp-0x60],rcx
  469e27:	kmovb  ecx,k6
  469e2b:	tzcnt  esi,ecx
  469e2f:	sar    esi,1
  469e31:	mov    QWORD PTR [rbp-0x140],r8
  469e38:	mov    QWORD PTR [rbp-0x138],rdx
  469e3f:	mov    QWORD PTR [rbp-0x70],r9
  469e43:	vmovdqa64 ZMMWORD PTR [rbp-0x130],zmm6
  469e4d:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm0
  469e57:	call   433410
  469e5c:	test   al,al
  469e5e:	mov    r9d,0x55
  469e64:	kmovb  k2,r9d
  469e69:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0xf0]
  469e73:	vmovdqa64 zmm6,ZMMWORD PTR [rbp-0x130]
  469e7d:	mov    rcx,QWORD PTR [rbp-0x60]
  469e81:	mov    esi,DWORD PTR [rbp-0x68]
  469e84:	mov    r9,QWORD PTR [rbp-0x70]
  469e88:	mov    rdx,QWORD PTR [rbp-0x138]
  469e8f:	mov    r8,QWORD PTR [rbp-0x140]
  469e96:	jne    469b59
  469e9c:	nop    DWORD PTR [rax+0x0]
  469ea0:	mov    r11d,0xffffffff
  469ea6:	crc32  r11,rsi
  469eac:	andn   edi,r12d,r11d
  469eb1:	shl    rdi,0x4
  469eb5:	prefetcht1 BYTE PTR [r13+rdi*1+0x0]
  469ebb:	vmovdqu XMMWORD PTR [r8+rdx*4],xmm0
  469ec1:	mov    DWORD PTR [r15+rdx*1],r11d
  469ec5:	add    rdx,0x4
  469ec9:	and    rdx,r9
  469ecc:	jmp    469b59
  469ed1:	nop    DWORD PTR [rax+0x0]
  469ed8:	vpxor  xmm13,xmm13,xmm13
  469edd:	vpcmpequq k3{k2},zmm12,zmm13
  469ee4:	kortestb k3,k3
  469ee8:	je     469f70
  469eee:	xor    esi,esi
  469ef0:	mov    QWORD PTR [rbp-0x140],r8
  469ef7:	kmovb  r8d,k3
  469efb:	tzcnt  esi,r8d
  469f00:	sar    esi,1
  469f02:	mov    QWORD PTR [rbp-0x138],rdx
  469f09:	mov    QWORD PTR [rbp-0x70],r9
  469f0d:	mov    DWORD PTR [rbp-0x68],r11d
  469f11:	mov    QWORD PTR [rbp-0x60],rcx
  469f15:	vmovdqa64 ZMMWORD PTR [rbp-0x130],zmm6
  469f1f:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm0
  469f29:	call   433410
  469f2e:	test   al,al
  469f30:	mov    edi,0x55
  469f35:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0xf0]
  469f3f:	vmovdqa64 zmm6,ZMMWORD PTR [rbp-0x130]
  469f49:	mov    rcx,QWORD PTR [rbp-0x60]
  469f4d:	mov    r11d,DWORD PTR [rbp-0x68]
  469f51:	mov    r9,QWORD PTR [rbp-0x70]
  469f55:	mov    rdx,QWORD PTR [rbp-0x138]
  469f5c:	mov    r8,QWORD PTR [rbp-0x140]
  469f63:	kmovb  k2,edi
  469f67:	jne    469b22
  469f6d:	nop    DWORD PTR [rax]
  469f70:	mov    r10d,0xffffffff
  469f76:	crc32  r10,r11
  469f7c:	andn   eax,r12d,r10d
  469f81:	shl    rax,0x4
  469f85:	prefetcht1 BYTE PTR [r13+rax*1+0x0]
  469f8b:	vmovdqu XMMWORD PTR [r8+rdx*4],xmm0
  469f91:	mov    DWORD PTR [r15+rdx*1],r10d
  469f95:	add    rdx,0x4
  469f99:	and    rdx,r9
  469f9c:	jmp    469b22
  469fa1:	nop    DWORD PTR [rax+0x0]
  469fa8:	vpxor  xmm2,xmm2,xmm2
  469fac:	vpcmpequq k0{k2},zmm0,zmm2
  469fb3:	kortestb k0,k0
  469fb7:	je     46a020
  469fb9:	xor    esi,esi
  469fbb:	mov    QWORD PTR [rbp-0x68],rdx
  469fbf:	kmovb  edx,k0
  469fc3:	tzcnt  esi,edx
  469fc7:	sar    esi,1
  469fc9:	vmovdqa64 zmm0,zmm3
  469fcf:	mov    QWORD PTR [rbp-0x70],r8
  469fd3:	mov    QWORD PTR [rbp-0x60],r9
  469fd7:	mov    DWORD PTR [rbp-0x130],r10d
  469fde:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm3
  469fe8:	call   433410
  469fed:	test   al,al
  469fef:	mov    r8d,0x55
  469ff5:	kmovb  k2,r8d
  469ffa:	vmovdqa64 zmm3,ZMMWORD PTR [rbp-0xf0]
  46a004:	mov    r10d,DWORD PTR [rbp-0x130]
  46a00b:	mov    r9,QWORD PTR [rbp-0x60]
  46a00f:	mov    rdx,QWORD PTR [rbp-0x68]
  46a013:	mov    r8,QWORD PTR [rbp-0x70]
  46a017:	jne    469b91
  46a01d:	nop    DWORD PTR [rax]
  46a020:	mov    eax,0xffffffff
  46a025:	crc32  rax,r10
  46a02b:	andn   ecx,r12d,eax
  46a030:	shl    rcx,0x4
  46a034:	prefetcht1 BYTE PTR [r13+rcx*1+0x0]
  46a03a:	vmovdqu XMMWORD PTR [r8+rdx*4],xmm3
  46a040:	mov    DWORD PTR [r15+rdx*1],eax
  46a044:	add    rdx,0x4
  46a048:	and    rdx,r9
  46a04b:	jmp    469b91
  46a050:	vpxor  xmm11,xmm11,xmm11
  46a055:	vpcmpequq k7{k2},zmm10,zmm11
  46a05c:	kortestb k7,k7
  46a060:	je     46a0e8
  46a066:	xor    esi,esi
  46a068:	mov    QWORD PTR [rbp-0x70],r9
  46a06c:	kmovb  r9d,k7
  46a070:	tzcnt  esi,r9d
  46a075:	sar    esi,1
  46a077:	mov    QWORD PTR [rbp-0x140],r8
  46a07e:	mov    QWORD PTR [rbp-0x138],rdx
  46a085:	mov    DWORD PTR [rbp-0x68],r10d
  46a089:	mov    QWORD PTR [rbp-0x60],rcx
  46a08d:	vmovdqa64 ZMMWORD PTR [rbp-0x130],zmm6
  46a097:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm0
  46a0a1:	call   433410
  46a0a6:	test   al,al
  46a0a8:	mov    edx,0x55
  46a0ad:	kmovb  k2,edx
  46a0b1:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0xf0]
  46a0bb:	vmovdqa64 zmm6,ZMMWORD PTR [rbp-0x130]
  46a0c5:	mov    rcx,QWORD PTR [rbp-0x60]
  46a0c9:	mov    r10d,DWORD PTR [rbp-0x68]
  46a0cd:	mov    r9,QWORD PTR [rbp-0x70]
  46a0d1:	mov    rdx,QWORD PTR [rbp-0x138]
  46a0d8:	mov    r8,QWORD PTR [rbp-0x140]
  46a0df:	jne    469aea
  46a0e5:	nop    DWORD PTR [rax]
  46a0e8:	mov    eax,0xffffffff
  46a0ed:	crc32  rax,r10
  46a0f3:	andn   esi,r12d,eax
  46a0f8:	shl    rsi,0x4
  46a0fc:	prefetcht1 BYTE PTR [r13+rsi*1+0x0]
  46a102:	vmovdqu XMMWORD PTR [r8+rdx*4],xmm0
  46a108:	mov    DWORD PTR [r15+rdx*1],eax
  46a10c:	add    rdx,0x4
  46a110:	and    rdx,r9
  46a113:	jmp    469aea
  46a118:	nop    DWORD PTR [rax+rax*1+0x0]
  46a120:	mov    rdi,r14
  46a123:	sub    rdi,rbx
  46a126:	mov    r11,rdi
  46a129:	shr    r11,1
  46a12c:	mov    r10d,0x1
  46a132:	shlx   esi,r10d,r11d
  46a137:	lea    r11d,[rsi-0x1]
  46a13b:	kmovb  k4,r11d
  46a140:	mov    r10,r9
  46a143:	lea    r11,[rbx+0x8]
  46a147:	vmovdqu64 zmm6{k4}{z},ZMMWORD PTR [rcx]
  46a14d:	shl    rdi,0x2
  46a151:	neg    esi
  46a153:	mov    rcx,r8
  46a156:	and    r10,rbx
  46a159:	and    r11,r9
  46a15c:	sub    rcx,rdi
  46a15f:	kmovb  k5,esi
  46a163:	vmovd  xmm4,DWORD PTR [r15+r11*1]
  46a169:	vmovd  xmm7,DWORD PTR [r15+r10*1]
  46a16f:	lea    rsi,[rbx+0x4]
  46a173:	lea    rdi,[rbx+0xc]
  46a177:	and    rsi,r9
  46a17a:	and    rdi,r9
  46a17d:	vpinsrd xmm5,xmm4,DWORD PTR [r15+rdi*1],0x1
  46a184:	vpinsrd xmm8,xmm7,DWORD PTR [r15+rsi*1],0x1
  46a18b:	vmovdqu64 zmm6{k5},ZMMWORD PTR [rcx]
  46a191:	vpunpcklqdq xmm9,xmm8,xmm5
  46a195:	mov    rcx,QWORD PTR [rbp-0x48]
  46a199:	vmovdqa XMMWORD PTR [rbp-0x40],xmm9
  46a19e:	jmp    469a63
  46a1a3:	vzeroupper
  46a1a6:	add    rsp,0x140
  46a1ad:	pop    rbx
  46a1ae:	pop    rcx
  46a1af:	pop    r12
  46a1b1:	pop    r13
  46a1b3:	pop    r14
  46a1b5:	pop    r15
  46a1b7:	pop    rbp
  46a1b8:	lea    rsp,[rcx-0x8]
  46a1bc:	ret
  46a1bd:	cmp    r10,QWORD PTR [rbp-0x50]
  46a1c1:	je     46a1a6
  46a1c3:	mov    r11,QWORD PTR [r15+0x88]
  46a1ca:	mov    r8,QWORD PTR [r15+0x60]
  46a1ce:	mov    rdi,QWORD PTR [rip+0x2aa1b]        # 494bf0
  46a1d5:	mov    rcx,QWORD PTR [r15+0xb0]
  46a1dc:	mov    rsi,QWORD PTR [r15+0xb8]
  46a1e3:	lea    r9,[r11-0x1]
  46a1e7:	mov    r12d,0xffffffff
  46a1ed:	nop    DWORD PTR [rax]
  46a1f0:	cmp    r8,0x4
  46a1f4:	je     46a333
  46a1fa:	cmp    r8,0x8
  46a1fe:	jne    46a209
  46a200:	mov    rbx,r12
  46a203:	crc32  rbx,QWORD PTR [r10]
  46a209:	mov    r13d,ebx
  46a20c:	mov    eax,DWORD PTR [r15+0xc8]
  46a213:	mov    r14,r9
  46a216:	and    r14,rbx
  46a219:	vmovdqu xmm6,XMMWORD PTR [r10]
  46a21e:	mov    rdx,rax
  46a221:	and    r14,0xfffffffffffffffc
  46a225:	shl    rdx,0x4
  46a229:	shl    r14,0x4
  46a22d:	prefetcht1 BYTE PTR [rdi+r14*1]
  46a232:	vmovdqu XMMWORD PTR [rcx+rdx*1],xmm6
  46a237:	mov    DWORD PTR [rsi+rax*4],r13d
  46a23b:	add    r10,0x10
  46a23f:	mov    eax,DWORD PTR [r15+0xc8]
  46a246:	mov    edx,DWORD PTR [r15+0x74]
  46a24a:	inc    eax
  46a24c:	and    eax,edx
  46a24e:	mov    DWORD PTR [r15+0xc8],eax
  46a255:	cmp    r10,QWORD PTR [rbp-0x50]
  46a259:	je     46a1a3
  46a25f:	mov    r11d,DWORD PTR [r15+0xcc]
  46a266:	mov    r13d,DWORD PTR [r15+0x70]
  46a26a:	sub    eax,r11d
  46a26d:	and    eax,edx
  46a26f:	lea    r14d,[r13-0x1]
  46a273:	cmp    eax,r14d
  46a276:	jb     46a1f0
  46a27c:	mov    r13d,DWORD PTR [r15+0x80]
  46a283:	lea    r9d,[r11+0x18]
  46a287:	and    r9d,edx
  46a28a:	mov    eax,r13d
  46a28d:	and    eax,DWORD PTR [rsi+r9*4]
  46a291:	lea    r14d,[r11+0x1]
  46a295:	mov    r8,rax
  46a298:	and    r14d,edx
  46a29b:	shl    r8,0x4
  46a29f:	prefetchw BYTE PTR [rdi+r8*1]
  46a2a4:	mov    DWORD PTR [r15+0xcc],r14d
  46a2ab:	mov    r14d,DWORD PTR [rsi+r11*4]
  46a2af:	shl    r11,0x4
  46a2b3:	vbroadcasti32x4 zmm1,XMMWORD PTR [rcx+r11*1]
  46a2ba:	lea    r9,[rcx+r11*1]
  46a2be:	mov    r11,QWORD PTR [r15+0x90]
  46a2c5:	cmp    QWORD PTR [r9],r11
  46a2c8:	je     46a42f
  46a2ce:	mov    edx,r13d
  46a2d1:	and    edx,r14d
  46a2d4:	shl    rdx,0x4
  46a2d8:	add    rdx,rdi
  46a2db:	vmovdqa64 zmm0,ZMMWORD PTR [rdx]
  46a2e1:	mov    esi,0x55
  46a2e6:	kmovb  k1,esi
  46a2ea:	vpcmpequq k0{k1},zmm0,zmm1
  46a2f1:	kortestb k0,k0
  46a2f5:	je     46a455
  46a2fb:	kaddb  k3,k0,k0
  46a2ff:	vmovdqu64 ZMMWORD PTR [rdx]{k3},zmm1
  46a305:	mov    r13,QWORD PTR [r15+0x88]
  46a30c:	mov    r8,QWORD PTR [r15+0x60]
  46a310:	mov    rdi,QWORD PTR [rip+0x2a8d9]        # 494bf0
  46a317:	mov    rcx,QWORD PTR [r15+0xb0]
  46a31e:	mov    rsi,QWORD PTR [r15+0xb8]
  46a325:	lea    r9,[r13-0x1]
  46a329:	cmp    r8,0x4
  46a32d:	jne    46a1fa
  46a333:	mov    r13d,0xffffffff
  46a339:	crc32  r13d,DWORD PTR [r10]
  46a33f:	mov    ebx,r13d
  46a342:	jmp    46a20c
  46a347:	mov    r9,QWORD PTR [r11+0x8]
  46a34b:	mov    BYTE PTR [rip+0x2a7ae],0x1        # 494b00
  46a352:	mov    QWORD PTR [rip+0x2a7af],r9        # 494b08
  46a359:	jmp    469de1
  46a35e:	vpxor  xmm15,xmm15,xmm15
  46a363:	vpcmpequq k6{k4},zmm14,zmm15
  46a36a:	kortestb k6,k6
  46a36e:	jne    46a3db
  46a370:	mov    r10,rbx
  46a373:	mov    r11d,DWORD PTR [r15+0xc8]
  46a37a:	crc32  r10,r9
  46a380:	mov    edi,r8d
  46a383:	and    edi,r10d
  46a386:	shl    rdi,0x4
  46a38a:	shl    r11,0x4
  46a38e:	prefetcht1 BYTE PTR [rsi+rdi*1]
  46a392:	vmovdqa XMMWORD PTR [rdx+r11*1],xmm6
  46a398:	mov    edx,DWORD PTR [r15+0xc8]
  46a39f:	mov    rcx,QWORD PTR [r15+0xb8]
  46a3a6:	mov    rsi,QWORD PTR [rip+0x2a843]        # 494bf0
  46a3ad:	mov    DWORD PTR [rcx+rdx*4],r10d
  46a3b1:	mov    rdx,QWORD PTR [r15+0xb0]
  46a3b8:	mov    eax,DWORD PTR [r15+0xc8]
  46a3bf:	mov    r9d,DWORD PTR [r15+0x74]
  46a3c3:	inc    eax
  46a3c5:	and    eax,r9d
  46a3c8:	mov    DWORD PTR [r15+0xc8],eax
  46a3cf:	mov    eax,DWORD PTR [r15+0xcc]
  46a3d6:	jmp    469d4c
  46a3db:	kmovb  esi,k6
  46a3df:	tzcnt  esi,esi
  46a3e3:	sar    esi,1
  46a3e5:	vmovdqa64 zmm0,zmm6
  46a3eb:	mov    DWORD PTR [rbp-0x50],r9d
  46a3ef:	mov    DWORD PTR [rbp-0x48],r8d
  46a3f3:	vmovdqa32 ZMMWORD PTR [rbp-0xb0],zmm6
  46a3fd:	call   433410
  46a402:	mov    rsi,QWORD PTR [rip+0x2a7e7]        # 494bf0
  46a409:	mov    rdx,QWORD PTR [r15+0xb0]
  46a410:	test   al,al
  46a412:	jne    46a51e
  46a418:	mov    r9d,DWORD PTR [rbp-0x50]
  46a41c:	mov    r8d,DWORD PTR [rbp-0x48]
  46a420:	vmovdqa32 zmm6,ZMMWORD PTR [rbp-0xb0]
  46a42a:	jmp    46a370
  46a42f:	mov    rdx,QWORD PTR [r9+0x8]
  46a433:	mov    rax,QWORD PTR [r15+0x88]
  46a43a:	mov    QWORD PTR [rip+0x2a6c7],rdx        # 494b08
  46a441:	mov    BYTE PTR [rip+0x2a6b8],0x1        # 494b00
  46a448:	mov    r8,QWORD PTR [r15+0x60]
  46a44c:	lea    r9,[rax-0x1]
  46a450:	jmp    46a1f0
  46a455:	vpxor  xmm3,xmm3,xmm3
  46a459:	vpcmpequq k2{k1},zmm0,zmm3
  46a460:	kortestb k2,k2
  46a464:	je     46a4b3
  46a466:	xor    esi,esi
  46a468:	mov    QWORD PTR [rbp-0x48],r10
  46a46c:	kmovb  r10d,k2
  46a470:	tzcnt  esi,r10d
  46a475:	sar    esi,1
  46a477:	vmovdqa64 zmm0,zmm1
  46a47d:	mov    rdi,rdx
  46a480:	vmovdqa32 ZMMWORD PTR [rbp-0xb0],zmm1
  46a48a:	call   433410
  46a48f:	test   al,al
  46a491:	vmovdqa32 zmm1,ZMMWORD PTR [rbp-0xb0]
  46a49b:	mov    r10,QWORD PTR [rbp-0x48]
  46a49f:	jne    46a305
  46a4a5:	mov    rdi,QWORD PTR [rip+0x2a744]        # 494bf0
  46a4ac:	mov    rcx,QWORD PTR [r15+0xb0]
  46a4b3:	mov    r8,r12
  46a4b6:	crc32  r8,r14
  46a4bc:	mov    eax,r13d
  46a4bf:	and    eax,r8d
  46a4c2:	shl    rax,0x4
  46a4c6:	prefetcht1 BYTE PTR [rdi+rax*1]
  46a4ca:	mov    edi,DWORD PTR [r15+0xc8]
  46a4d1:	shl    rdi,0x4
  46a4d5:	vmovdqa XMMWORD PTR [rcx+rdi*1],xmm1
  46a4da:	mov    ecx,DWORD PTR [r15+0xc8]
  46a4e1:	mov    rsi,QWORD PTR [r15+0xb8]
  46a4e8:	mov    rdi,QWORD PTR [rip+0x2a701]        # 494bf0
  46a4ef:	mov    DWORD PTR [rsi+rcx*4],r8d
  46a4f3:	mov    rcx,QWORD PTR [r15+0xb0]
  46a4fa:	mov    r14d,DWORD PTR [r15+0xc8]
  46a501:	mov    edx,DWORD PTR [r15+0x74]
  46a505:	inc    r14d
  46a508:	and    r14d,edx
  46a50b:	mov    DWORD PTR [r15+0xc8],r14d
  46a512:	mov    r11d,DWORD PTR [r15+0xcc]
  46a519:	jmp    46a283
  46a51e:	mov    rcx,QWORD PTR [r15+0xb8]
  46a525:	jmp    469de1
