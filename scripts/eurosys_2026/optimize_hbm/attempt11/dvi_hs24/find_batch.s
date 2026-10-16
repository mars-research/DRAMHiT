0000000000468a30 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468a30:	push   rbp
  468a31:	mov    rcx,rdi
  468a34:	mov    rbp,rsp
  468a37:	push   r15
  468a39:	mov    r15,rdx
  468a3c:	push   r14
  468a3e:	push   r13
  468a40:	push   r12
  468a42:	push   rbx
  468a43:	and    rsp,0xffffffffffffffc0
  468a47:	sub    rsp,0x8
  468a4b:	mov    r11,QWORD PTR [rsi+0x8]
  468a4f:	mov    edi,DWORD PTR [rdi+0xc0]
  468a55:	mov    eax,DWORD PTR [rcx+0xc4]
  468a5b:	mov    rdx,QWORD PTR [rsi]
  468a5e:	mov    r8d,DWORD PTR [rcx+0x78]
  468a62:	mov    r9d,DWORD PTR [rcx+0x6c]
  468a66:	mov    r10,r11
  468a69:	mov    esi,edi
  468a6b:	shl    r10,0x4
  468a6f:	sub    esi,eax
  468a71:	lea    rbx,[rdx+r10*1]
  468a75:	and    esi,r8d
  468a78:	lea    r12d,[r9-0x1]
  468a7c:	mov    QWORD PTR [rsp-0x20],rbx
  468a81:	cmp    esi,r12d
  468a84:	jb     4692ec <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8bc>
  468a8a:	and    r11,0xfffffffffffffffc
  468a8e:	shl    r9,0x4
  468a92:	shl    r11,0x4
  468a96:	mov    r14,QWORD PTR [r15+0x8]
  468a9a:	mov    esi,DWORD PTR [rcx+0x80]
  468aa0:	mov    QWORD PTR [rsp-0x18],r9
  468aa5:	mov    QWORD PTR [rsp-0x38],r11
  468aaa:	lea    r10,[r9-0x1]
  468aae:	lea    r11,[rdx+r11*1]
  468ab2:	mov    r9d,edi
  468ab5:	mov    QWORD PTR [rsp],r14
  468ab9:	mov    QWORD PTR [rsp-0x28],r11
  468abe:	mov    DWORD PTR [rsp-0x2c],0x0
  468ac6:	mov    r8,QWORD PTR [rcx+0xa0]
  468acd:	mov    rdi,QWORD PTR [rip+0x2b11c]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468ad4:	shl    rax,0x4
  468ad8:	shl    r9,0x4
  468adc:	not    esi
  468ade:	cmp    rdx,r11
  468ae1:	je     46958a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb5a>
  468ae7:	mov    r13d,0x55
  468aed:	mov    ebx,0xf
  468af2:	mov    r12d,0xf0
  468af8:	mov    r11d,0xf00
  468afe:	kmovb  k2,r13d
  468b03:	mov    r13d,0xfffff000
  468b09:	mov    QWORD PTR [rsp-0x40],rcx
  468b0e:	mov    QWORD PTR [rsp-0x48],r15
  468b13:	vpxor  xmm4,xmm4,xmm4
  468b17:	mov    r14d,0xffffffff
  468b1d:	kmovw  k6,ebx
  468b21:	kmovw  k5,r12d
  468b26:	kmovw  k4,r11d
  468b2b:	kmovw  k3,r13d
  468b30:	jmp    468d89 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  468b35:	nop    DWORD PTR [rax]
  468b38:	vmovd  xmm13,DWORD PTR [r12+0xc]
  468b3f:	kshiftlb k7,k7,0x1
  468b45:	vpcompressq zmm12{k7}{z},zmm8
  468b4b:	vpunpcklqdq xmm14,xmm13,xmm12
  468b50:	vshufi32x4 zmm15{k6}{z},zmm14,zmm14,0x0
  468b57:	vmovdqa64 zmm12,zmm15
  468b5d:	mov    r11d,0x1
  468b63:	lea    r13,[r8+rax*1]
  468b67:	lea    r12,[rax+0x180]
  468b6e:	and    r12,r10
  468b71:	mov    r15d,DWORD PTR [r13+0x8]
  468b75:	andn   ecx,esi,DWORD PTR [r8+r12*1+0x8]
  468b7c:	shl    rcx,0x4
  468b80:	andn   r12d,esi,r15d
  468b85:	shl    r12,0x4
  468b89:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r12*1]
  468b90:	vpbroadcastq zmm2,QWORD PTR [r13+0x0]
  468b97:	vpcmpequq k0{k2},zmm0,zmm2
  468b9e:	add    rax,0x10
  468ba2:	and    rax,r10
  468ba5:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468ba9:	kortestb k0,k0
  468bad:	je     469200 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
  468bb3:	vmovd  xmm1,DWORD PTR [r13+0xc]
  468bb9:	kshiftlb k7,k0,0x1
  468bbf:	vpcompressq zmm6{k7}{z},zmm0
  468bc5:	vpunpcklqdq xmm7,xmm1,xmm6
  468bc9:	vshufi32x4 zmm15{k5},zmm7,zmm7,0x0
  468bd0:	vmovdqa64 zmm12,zmm15
  468bd6:	or     r11d,0x2
  468bda:	lea    r13,[rax+0x180]
  468be1:	and    r13,r10
  468be4:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  468beb:	shl    rcx,0x4
  468bef:	lea    r13,[r8+rax*1]
  468bf3:	mov    ebx,DWORD PTR [r13+0x8]
  468bf7:	andn   r12d,esi,ebx
  468bfc:	shl    r12,0x4
  468c00:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r12*1]
  468c07:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  468c0e:	vpcmpequq k0{k2},zmm8,zmm9
  468c15:	add    rax,0x10
  468c19:	and    rax,r10
  468c1c:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468c20:	kortestb k0,k0
  468c24:	je     4691b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x780>
  468c2a:	vmovd  xmm13,DWORD PTR [r13+0xc]
  468c30:	kshiftlb k7,k0,0x1
  468c36:	vpcompressq zmm12{k7}{z},zmm8
  468c3c:	vpunpcklqdq xmm14,xmm13,xmm12
  468c41:	vshufi32x4 zmm15{k4},zmm14,zmm14,0x0
  468c48:	vmovdqa64 zmm12,zmm15
  468c4e:	or     r11d,0x4
  468c52:	lea    r15,[r8+rax*1]
  468c56:	lea    r13,[rax+0x180]
  468c5d:	and    r13,r10
  468c60:	mov    r12d,DWORD PTR [r15+0x8]
  468c64:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  468c6b:	shl    rcx,0x4
  468c6f:	andn   r13d,esi,r12d
  468c74:	shl    r13,0x4
  468c78:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r13*1]
  468c7f:	vpbroadcastq zmm2,QWORD PTR [r15]
  468c85:	vpcmpequq k0{k2},zmm0,zmm2
  468c8c:	add    rax,0x10
  468c90:	and    rax,r10
  468c93:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468c97:	kortestb k0,k0
  468c9b:	lea    rcx,[r8+r9*1]
  468c9f:	je     469168 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
  468ca5:	vmovd  xmm1,DWORD PTR [r15+0xc]
  468cab:	kshiftlb k7,k0,0x1
  468cb1:	vpcompressq zmm6{k7}{z},zmm0
  468cb7:	vpunpcklqdq xmm7,xmm1,xmm6
  468cbb:	vshufi32x4 zmm15{k3},zmm7,zmm7,0x0
  468cc2:	or     r11d,0x8
  468cc6:	vmovdqa64 zmm12,zmm15
  468ccc:	cmp    r11d,0xf
  468cd0:	jne    4692b8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x888>
  468cd6:	mov    r15,QWORD PTR [rsp]
  468cda:	vmovdqu64 ZMMWORD PTR [r15],zmm15
  468ce0:	add    r15,0x40
  468ce4:	mov    QWORD PTR [rsp],r15
  468ce8:	mov    rbx,r14
  468ceb:	mov    r11,r14
  468cee:	crc32  rbx,QWORD PTR [rdx]
  468cf4:	crc32  r11,QWORD PTR [rdx+0x20]
  468cfb:	andn   r13d,esi,ebx
  468d00:	shl    r13,0x4
  468d04:	andn   r15d,esi,r11d
  468d09:	shl    r15,0x4
  468d0d:	prefetcht2 BYTE PTR [rdi+r13*1]
  468d12:	prefetcht2 BYTE PTR [rdi+r15*1]
  468d17:	mov    r13,r14
  468d1a:	mov    r15,r14
  468d1d:	crc32  r13,QWORD PTR [rdx+0x10]
  468d24:	crc32  r15,QWORD PTR [rdx+0x30]
  468d2b:	andn   r12d,esi,r13d
  468d30:	shl    r12,0x4
  468d34:	prefetcht2 BYTE PTR [rdi+r12*1]
  468d39:	andn   r12d,esi,r15d
  468d3e:	shl    r12,0x4
  468d42:	prefetcht2 BYTE PTR [rdi+r12*1]
  468d47:	lea    r12,[r9+0x40]
  468d4b:	vmovdqu64 zmm15,ZMMWORD PTR [rdx]
  468d51:	cmp    QWORD PTR [rsp-0x18],r12
  468d56:	jb     469248 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x818>
  468d5c:	vmovdqu64 ZMMWORD PTR [rcx],zmm15
  468d62:	mov    DWORD PTR [rcx+0x8],ebx
  468d65:	mov    DWORD PTR [r8+r9*1+0x18],r13d
  468d6a:	mov    DWORD PTR [r8+r9*1+0x28],r11d
  468d6f:	mov    DWORD PTR [r8+r9*1+0x38],r15d
  468d74:	mov    r9,r12
  468d77:	add    rdx,0x40
  468d7b:	and    r9,r10
  468d7e:	cmp    QWORD PTR [rsp-0x28],rdx
  468d83:	je     468e28 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3f8>
  468d89:	lea    r12,[r8+rax*1]
  468d8d:	mov    r11d,DWORD PTR [r12+0x8]
  468d92:	andn   r13d,esi,r11d
  468d97:	shl    r13,0x4
  468d9b:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r13*1]
  468da2:	vpbroadcastq zmm9,QWORD PTR [r12]
  468da9:	vpcmpequq k7{k2},zmm8,zmm9
  468db0:	lea    rcx,[rax+0x180]
  468db7:	add    rax,0x10
  468dbb:	and    rcx,r10
  468dbe:	and    rax,r10
  468dc1:	andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
  468dc8:	shl    r15,0x4
  468dcc:	kortestb k7,k7
  468dd0:	prefetcht0 BYTE PTR [rdi+r15*1]
  468dd5:	jne    468b38 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
  468ddb:	vpcmpequq k1{k2},zmm8,zmm4
  468de2:	kortestb k1,k1
  468de6:	jne    4695b3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb83>
  468dec:	vmovdqu xmm10,XMMWORD PTR [r12]
  468df2:	mov    rcx,r14
  468df5:	crc32  rcx,r11
  468dfb:	vpinsrd xmm11,xmm10,ecx,0x2
  468e01:	andn   r15d,esi,ecx
  468e06:	shl    r15,0x4
  468e0a:	prefetcht2 BYTE PTR [rdi+r15*1]
  468e0f:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  468e15:	add    r9,0x10
  468e19:	and    r9,r10
  468e1c:	jmp    468d89 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  468e21:	nop    DWORD PTR [rax+0x0]
  468e28:	mov    rcx,QWORD PTR [rsp-0x40]
  468e2d:	mov    r15,QWORD PTR [rsp-0x48]
  468e32:	mov    edi,DWORD PTR [rsp-0x2c]
  468e36:	vmovq  xmm14,r9
  468e3b:	vpinsrq xmm0,xmm14,rax,0x1
  468e41:	mov    rsi,QWORD PTR [rsp-0x38]
  468e46:	vpsrlq xmm2,xmm0,0x4
  468e4b:	vpmovqd xmm3,xmm2
  468e51:	sar    rsi,0x4
  468e55:	vmovq  QWORD PTR [rcx+0xc0],xmm3
  468e5d:	sub    rsi,rdi
  468e60:	add    DWORD PTR [r15],esi
  468e63:	vpextrd eax,xmm3,0x1
  468e69:	cmp    rdx,QWORD PTR [rsp-0x20]
  468e6e:	je     469150 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  468e74:	mov    rdi,QWORD PTR [rcx+0x88]
  468e7b:	mov    rbx,QWORD PTR [rcx+0x80]
  468e82:	mov    r8,QWORD PTR [rcx+0x60]
  468e86:	dec    rdi
  468e89:	mov    QWORD PTR [rsp-0x18],rbx
  468e8e:	mov    QWORD PTR [rsp],r8
  468e92:	mov    QWORD PTR [rsp-0x28],rdi
  468e97:	mov    r10d,DWORD PTR [rcx+0x78]
  468e9b:	mov    r11,QWORD PTR [rip+0x2ad4e]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468ea2:	mov    r9,QWORD PTR [rcx+0xa0]
  468ea9:	movzx  r13d,BYTE PTR [rip+0x2ac4f]        # 493b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  468eb1:	mov    r12,QWORD PTR [rip+0x2ac50]        # 493b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  468eb8:	mov    r14d,0x55
  468ebe:	vpxor  xmm7,xmm7,xmm7
  468ec2:	kmovb  k2,r14d
  468ec7:	nop    WORD PTR [rax+rax*1+0x0]
  468ed0:	lea    esi,[rax+0x18]
  468ed3:	and    esi,r10d
  468ed6:	shl    rsi,0x4
  468eda:	mov    r8d,ebx
  468edd:	and    r8d,DWORD PTR [r9+rsi*1+0x8]
  468ee2:	mov    esi,eax
  468ee4:	shl    rsi,0x4
  468ee8:	add    rsi,r9
  468eeb:	mov    r14,r8
  468eee:	mov    r8,QWORD PTR [rsi]
  468ef1:	shl    r14,0x4
  468ef5:	prefetcht0 BYTE PTR [r11+r14*1]
  468efa:	cmp    r8,QWORD PTR [rcx+0x90]
  468f01:	jne    468fc0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x590>
  468f07:	test   r13b,r13b
  468f0a:	je     468f2a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fa>
  468f0c:	mov    r14d,DWORD PTR [r15]
  468f0f:	mov    esi,DWORD PTR [rsi+0xc]
  468f12:	mov    r8,r14
  468f15:	shl    r14,0x4
  468f19:	add    r14,QWORD PTR [r15+0x8]
  468f1d:	inc    r8d
  468f20:	mov    DWORD PTR [r14],esi
  468f23:	mov    QWORD PTR [r14+0x8],r12
  468f27:	mov    DWORD PTR [r15],r8d
  468f2a:	inc    eax
  468f2c:	and    eax,r10d
  468f2f:	mov    DWORD PTR [rcx+0xc4],eax
  468f35:	test   r12,r12
  468f38:	jne    468ed0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  468f3a:	cmp    QWORD PTR [rsp],0x4
  468f3f:	je     4690b5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x685>
  468f45:	nop    DWORD PTR [rax]
  468f48:	cmp    QWORD PTR [rsp],0x8
  468f4d:	je     469130 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
  468f53:	vmovd  xmm15,DWORD PTR [rsp-0x10]
  468f59:	mov    rdi,QWORD PTR [rdx]
  468f5c:	mov    esi,DWORD PTR [rcx+0xc0]
  468f62:	mov    r8,QWORD PTR [rsp-0x28]
  468f67:	mov    rax,rsi
  468f6a:	and    r8,QWORD PTR [rsp-0x10]
  468f6f:	vpinsrd xmm9,xmm15,DWORD PTR [rdx+0xc],0x1
  468f76:	and    r8,0xfffffffffffffffc
  468f7a:	shl    rsi,0x4
  468f7e:	inc    eax
  468f80:	add    rsi,r9
  468f83:	shl    r8,0x4
  468f87:	and    eax,r10d
  468f8a:	add    rdx,0x10
  468f8e:	prefetcht2 BYTE PTR [r11+r8*1]
  468f93:	mov    QWORD PTR [rsi],rdi
  468f96:	vmovq  QWORD PTR [rsi+0x8],xmm9
  468f9b:	mov    DWORD PTR [rcx+0xc0],eax
  468fa1:	cmp    rdx,QWORD PTR [rsp-0x20]
  468fa6:	je     469150 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  468fac:	mov    eax,DWORD PTR [rcx+0xc4]
  468fb2:	jmp    468ed0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  468fb7:	nop    WORD PTR [rax+rax*1+0x0]
  468fc0:	mov    r14d,DWORD PTR [rsi+0x8]
  468fc4:	mov    edi,ebx
  468fc6:	and    edi,r14d
  468fc9:	shl    rdi,0x4
  468fcd:	add    rdi,r11
  468fd0:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  468fd6:	vpbroadcastq zmm6,r8
  468fdc:	vpcmpequq k0{k2},zmm5,zmm6
  468fe3:	kortestb k0,k0
  468fe7:	jne    469070 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x640>
  468fed:	vpcmpequq k3{k2},zmm5,zmm7
  468ff4:	kortestb k3,k3
  468ff8:	jne    4690e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  468ffe:	cmp    QWORD PTR [rsp],0x4
  469003:	mov    edi,r14d
  469006:	je     4690f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  46900c:	cmp    QWORD PTR [rsp],0x8
  469011:	je     469110 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
  469017:	vmovd  xmm1,DWORD PTR [rsp-0x8]
  46901d:	mov    edi,DWORD PTR [rcx+0xc0]
  469023:	mov    r14,QWORD PTR [rsp-0x18]
  469028:	vpinsrd xmm4,xmm1,DWORD PTR [rsi+0xc],0x1
  46902f:	mov    rsi,rdi
  469032:	and    r14,QWORD PTR [rsp-0x8]
  469037:	shl    rdi,0x4
  46903b:	inc    esi
  46903d:	inc    eax
  46903f:	add    rdi,r9
  469042:	shl    r14,0x4
  469046:	and    esi,r10d
  469049:	and    eax,r10d
  46904c:	prefetcht2 BYTE PTR [r11+r14*1]
  469051:	mov    QWORD PTR [rdi],r8
  469054:	vmovq  QWORD PTR [rdi+0x8],xmm4
  469059:	mov    DWORD PTR [rcx+0xc0],esi
  46905f:	mov    DWORD PTR [rcx+0xc4],eax
  469065:	jmp    468ed0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  46906a:	nop    WORD PTR [rax+rax*1+0x0]
  469070:	mov    r8d,DWORD PTR [r15]
  469073:	mov    esi,DWORD PTR [rsi+0xc]
  469076:	mov    r14,r8
  469079:	shl    r8,0x4
  46907d:	add    r8,QWORD PTR [r15+0x8]
  469081:	mov    DWORD PTR [r8],esi
  469084:	kmovb  esi,k0
  469088:	tzcnt  esi,esi
  46908c:	inc    esi
  46908e:	movsxd rsi,esi
  469091:	mov    rdi,QWORD PTR [rdi+rsi*8]
  469095:	inc    eax
  469097:	inc    r14d
  46909a:	and    eax,r10d
  46909d:	cmp    QWORD PTR [rsp],0x4
  4690a2:	mov    QWORD PTR [r8+0x8],rdi
  4690a6:	mov    DWORD PTR [r15],r14d
  4690a9:	mov    DWORD PTR [rcx+0xc4],eax
  4690af:	jne    468f48 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x518>
  4690b5:	mov    r14d,0xffffffff
  4690bb:	crc32  r14d,DWORD PTR [rdx]
  4690c1:	vmovd  xmm8,r14d
  4690c6:	mov    rdi,QWORD PTR [rdx]
  4690c9:	vmovdqa xmm15,xmm8
  4690ce:	vmovq  QWORD PTR [rsp-0x10],xmm8
  4690d4:	jmp    468f5c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  4690d9:	nop    DWORD PTR [rax+0x0]
  4690e0:	inc    eax
  4690e2:	and    eax,r10d
  4690e5:	mov    DWORD PTR [rcx+0xc4],eax
  4690eb:	jmp    468f3a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
  4690f0:	mov    edi,0xffffffff
  4690f5:	crc32  edi,r14d
  4690fb:	vmovd  xmm12,edi
  4690ff:	vmovdqa xmm1,xmm12
  469103:	vmovq  QWORD PTR [rsp-0x8],xmm12
  469109:	jmp    46901d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  46910e:	xchg   ax,ax
  469110:	mov    r14d,0xffffffff
  469116:	crc32  r14,rdi
  46911c:	mov    QWORD PTR [rsp-0x8],r14
  469121:	vmovd  xmm1,r14d
  469126:	jmp    46901d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  46912b:	nop    DWORD PTR [rax+rax*1+0x0]
  469130:	mov    rdi,QWORD PTR [rdx]
  469133:	mov    eax,0xffffffff
  469138:	crc32  rax,rdi
  46913e:	mov    QWORD PTR [rsp-0x10],rax
  469143:	vmovd  xmm15,eax
  469147:	jmp    468f5c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  46914c:	nop    DWORD PTR [rax+0x0]
  469150:	vzeroupper 
  469153:	lea    rsp,[rbp-0x28]
  469157:	pop    rbx
  469158:	pop    r12
  46915a:	pop    r13
  46915c:	pop    r14
  46915e:	pop    r15
  469160:	pop    rbp
  469161:	ret    
  469162:	nop    WORD PTR [rax+rax*1+0x0]
  469168:	vpcmpequq k1{k2},zmm0,zmm4
  46916f:	kortestb k1,k1
  469173:	jne    4692b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x880>
  469179:	vmovdqu xmm3,XMMWORD PTR [r15]
  46917e:	mov    rbx,r14
  469181:	crc32  rbx,r12
  469187:	vpinsrd xmm5,xmm3,ebx,0x2
  46918d:	add    r9,0x10
  469191:	andn   r12d,esi,ebx
  469196:	shl    r12,0x4
  46919a:	and    r9,r10
  46919d:	prefetcht2 BYTE PTR [rdi+r12*1]
  4691a2:	vmovdqu XMMWORD PTR [rcx],xmm5
  4691a6:	jmp    468c52 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
  4691ab:	nop    DWORD PTR [rax+rax*1+0x0]
  4691b0:	vpcmpequq k1{k2},zmm8,zmm4
  4691b7:	kortestb k1,k1
  4691bb:	jne    4695c9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb99>
  4691c1:	vmovdqu xmm10,XMMWORD PTR [r13+0x0]
  4691c7:	mov    rcx,r14
  4691ca:	crc32  rcx,rbx
  4691d0:	vpinsrd xmm11,xmm10,ecx,0x2
  4691d6:	andn   r15d,esi,ecx
  4691db:	shl    r15,0x4
  4691df:	prefetcht2 BYTE PTR [rdi+r15*1]
  4691e4:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  4691ea:	add    r9,0x10
  4691ee:	and    r9,r10
  4691f1:	jmp    468bda <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  4691f6:	cs nop WORD PTR [rax+rax*1+0x0]
  469200:	vpcmpequq k1{k2},zmm0,zmm4
  469207:	kortestb k1,k1
  46920b:	jne    4695aa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb7a>
  469211:	vmovdqu xmm3,XMMWORD PTR [r13+0x0]
  469217:	mov    rcx,r14
  46921a:	crc32  rcx,r15
  469220:	vpinsrd xmm5,xmm3,ecx,0x2
  469226:	andn   ebx,esi,ecx
  46922b:	shl    rbx,0x4
  46922f:	prefetcht2 BYTE PTR [rdi+rbx*1]
  469233:	vmovdqu XMMWORD PTR [r8+r9*1],xmm5
  469239:	add    r9,0x10
  46923d:	and    r9,r10
  469240:	jmp    468b63 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  469245:	nop    DWORD PTR [rax]
  469248:	vmovd  xmm10,ebx
  46924c:	vpinsrd xmm11,xmm10,r13d,0x1
  469252:	mov    r13,QWORD PTR [rsp-0x18]
  469257:	vmovd  xmm8,r11d
  46925c:	mov    r11,r13
  46925f:	vpinsrd xmm9,xmm8,r15d,0x1
  469265:	sub    r11,r9
  469268:	mov    ebx,0x4444
  46926d:	vpunpcklqdq xmm13,xmm11,xmm9
  469272:	shr    r11,0x2
  469276:	mov    r15d,0x1
  46927c:	kmovw  k7,ebx
  469280:	shlx   r11d,r15d,r11d
  469285:	vpexpandd zmm15{k7},zmm13
  46928b:	lea    ebx,[r11-0x1]
  46928f:	sub    r9,r13
  469292:	neg    r11d
  469295:	kmovw  k1,ebx
  469299:	vmovdqu32 ZMMWORD PTR [rcx]{k1},zmm15
  46929f:	kmovw  k7,r11d
  4692a4:	vmovdqu32 ZMMWORD PTR [r8+r9*1]{k7},zmm15
  4692ab:	jmp    468d74 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x344>
  4692b0:	inc    DWORD PTR [rsp-0x2c]
  4692b4:	nop    DWORD PTR [rax+0x0]
  4692b8:	mov    r12,QWORD PTR [rsp]
  4692bc:	mov    r15d,0x55
  4692c2:	pdep   r13d,r11d,r15d
  4692c7:	popcnt r11d,r11d
  4692cc:	lea    ebx,[r13+r13*2+0x0]
  4692d1:	shl    r11,0x4
  4692d5:	kmovb  k1,ebx
  4692d9:	vpcompressq ZMMWORD PTR [r12]{k1},zmm12
  4692e0:	add    r12,r11
  4692e3:	mov    QWORD PTR [rsp],r12
  4692e7:	jmp    468ce8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b8>
  4692ec:	cmp    rdx,QWORD PTR [rsp-0x20]
  4692f1:	je     469153 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x723>
  4692f7:	mov    r12,QWORD PTR [rcx+0x88]
  4692fe:	movzx  r13d,BYTE PTR [rip+0x2a7fa]        # 493b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469306:	mov    r9,QWORD PTR [rip+0x2a7fb]        # 493b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46930d:	mov    r10,QWORD PTR [rcx+0x60]
  469311:	mov    ebx,0x55
  469316:	dec    r12
  469319:	kmovb  k2,r13d
  46931e:	mov    QWORD PTR [rsp],r10
  469322:	mov    QWORD PTR [rsp-0x8],r12
  469327:	mov    r14,QWORD PTR [rip+0x2a8c2]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46932e:	mov    r11,QWORD PTR [rcx+0xa0]
  469335:	mov    esi,edi
  469337:	vpxor  xmm2,xmm2,xmm2
  46933b:	mov    r13,r9
  46933e:	kmovb  k1,ebx
  469342:	jmp    4693aa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x97a>
  469344:	cmp    QWORD PTR [rsp],0x8
  469349:	je     469558 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb28>
  46934f:	vmovd  xmm5,DWORD PTR [rsp-0x18]
  469355:	mov    r12,QWORD PTR [rsp-0x8]
  46935a:	mov    esi,edi
  46935c:	and    r12,QWORD PTR [rsp-0x18]
  469361:	vpinsrd xmm7,xmm5,DWORD PTR [rdx+0xc],0x1
  469368:	mov    r10,QWORD PTR [rdx]
  46936b:	and    r12,0xfffffffffffffffc
  46936f:	shl    rsi,0x4
  469373:	add    rsi,r11
  469376:	shl    r12,0x4
  46937a:	prefetcht2 BYTE PTR [r14+r12*1]
  46937f:	mov    QWORD PTR [rsi],r10
  469382:	vmovq  QWORD PTR [rsi+0x8],xmm7
  469387:	lea    esi,[rdi+0x1]
  46938a:	and    esi,r8d
  46938d:	add    rdx,0x10
  469391:	mov    DWORD PTR [rcx+0xc0],esi
  469397:	cmp    QWORD PTR [rsp-0x20],rdx
  46939c:	je     469150 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  4693a2:	mov    eax,DWORD PTR [rcx+0xc4]
  4693a8:	mov    edi,esi
  4693aa:	sub    esi,eax
  4693ac:	and    esi,r8d
  4693af:	cmp    r8d,esi
  4693b2:	jbe    4693d5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a5>
  4693b4:	cmp    QWORD PTR [rsp],0x4
  4693b9:	jne    469344 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x914>
  4693bb:	mov    ebx,0xffffffff
  4693c0:	crc32  ebx,DWORD PTR [rdx]
  4693c5:	vmovd  xmm6,ebx
  4693c9:	vmovdqa xmm5,xmm6
  4693cd:	vmovq  QWORD PTR [rsp-0x18],xmm6
  4693d3:	jmp    469355 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  4693d5:	mov    rbx,QWORD PTR [rcx+0x80]
  4693dc:	mov    QWORD PTR [rsp-0x10],rbx
  4693e1:	nop    DWORD PTR [rax+0x0]
  4693e8:	lea    esi,[rax+0x18]
  4693eb:	and    esi,r8d
  4693ee:	shl    rsi,0x4
  4693f2:	mov    r9d,ebx
  4693f5:	and    r9d,DWORD PTR [r11+rsi*1+0x8]
  4693fa:	mov    esi,eax
  4693fc:	mov    r10,r9
  4693ff:	shl    rsi,0x4
  469403:	shl    r10,0x4
  469407:	add    rsi,r11
  46940a:	prefetcht0 BYTE PTR [r14+r10*1]
  46940f:	mov    r10,QWORD PTR [rsi]
  469412:	cmp    r10,QWORD PTR [rcx+0x90]
  469419:	jne    469460 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa30>
  46941b:	kortestb k2,k2
  46941f:	je     469442 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa12>
  469421:	mov    r12d,DWORD PTR [r15]
  469424:	mov    esi,DWORD PTR [rsi+0xc]
  469427:	mov    r10,r12
  46942a:	shl    r12,0x4
  46942e:	add    r12,QWORD PTR [r15+0x8]
  469432:	lea    r9d,[r10+0x1]
  469436:	mov    DWORD PTR [r12],esi
  46943a:	mov    QWORD PTR [r12+0x8],r13
  46943f:	mov    DWORD PTR [r15],r9d
  469442:	inc    eax
  469444:	and    eax,r8d
  469447:	mov    DWORD PTR [rcx+0xc4],eax
  46944d:	test   r13,r13
  469450:	jne    4693e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  469452:	jmp    4693b4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  469457:	nop    WORD PTR [rax+rax*1+0x0]
  469460:	mov    r12d,DWORD PTR [rsi+0x8]
  469464:	mov    r9d,ebx
  469467:	and    r9d,r12d
  46946a:	shl    r9,0x4
  46946e:	add    r9,r14
  469471:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  469477:	vpbroadcastq zmm1,r10
  46947d:	vpcmpequq k0{k1},zmm0,zmm1
  469484:	kortestb k0,k0
  469488:	jne    469504 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad4>
  46948a:	vpcmpequq k3{k1},zmm0,zmm2
  469491:	kortestb k3,k3
  469495:	jne    469548 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb18>
  46949b:	cmp    QWORD PTR [rsp],0x4
  4694a0:	mov    r9d,r12d
  4694a3:	je     469571 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb41>
  4694a9:	cmp    QWORD PTR [rsp],0x8
  4694ae:	je     469591 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb61>
  4694b4:	mov    r9d,DWORD PTR [rsp-0x28]
  4694b9:	mov    r12,QWORD PTR [rsp-0x10]
  4694be:	vmovd  xmm4,r9d
  4694c3:	vpinsrd xmm3,xmm4,DWORD PTR [rsi+0xc],0x1
  4694ca:	mov    esi,edi
  4694cc:	and    r12,QWORD PTR [rsp-0x28]
  4694d1:	shl    rsi,0x4
  4694d5:	inc    edi
  4694d7:	inc    eax
  4694d9:	add    rsi,r11
  4694dc:	shl    r12,0x4
  4694e0:	and    edi,r8d
  4694e3:	and    eax,r8d
  4694e6:	prefetcht2 BYTE PTR [r14+r12*1]
  4694eb:	mov    QWORD PTR [rsi],r10
  4694ee:	vmovq  QWORD PTR [rsi+0x8],xmm3
  4694f3:	mov    DWORD PTR [rcx+0xc0],edi
  4694f9:	mov    DWORD PTR [rcx+0xc4],eax
  4694ff:	jmp    4693e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  469504:	mov    r10d,DWORD PTR [r15]
  469507:	mov    r12d,DWORD PTR [rsi+0xc]
  46950b:	mov    rbx,r10
  46950e:	shl    r10,0x4
  469512:	add    r10,QWORD PTR [r15+0x8]
  469516:	mov    DWORD PTR [r10],r12d
  469519:	xor    r12d,r12d
  46951c:	kmovb  esi,k0
  469520:	tzcnt  r12d,esi
  469525:	inc    r12d
  469528:	movsxd rsi,r12d
  46952b:	mov    r9,QWORD PTR [r9+rsi*8]
  46952f:	inc    eax
  469531:	inc    ebx
  469533:	and    eax,r8d
  469536:	mov    QWORD PTR [r10+0x8],r9
  46953a:	mov    DWORD PTR [r15],ebx
  46953d:	mov    DWORD PTR [rcx+0xc4],eax
  469543:	jmp    4693b4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  469548:	inc    eax
  46954a:	and    eax,r8d
  46954d:	mov    DWORD PTR [rcx+0xc4],eax
  469553:	jmp    4693b4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  469558:	mov    eax,0xffffffff
  46955d:	crc32  rax,QWORD PTR [rdx]
  469563:	mov    QWORD PTR [rsp-0x18],rax
  469568:	vmovd  xmm5,eax
  46956c:	jmp    469355 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  469571:	mov    r9d,0xffffffff
  469577:	crc32  r9d,r12d
  46957d:	mov    r12d,r9d
  469580:	mov    QWORD PTR [rsp-0x28],r12
  469585:	jmp    4694b9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  46958a:	xor    edi,edi
  46958c:	jmp    468e36 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x406>
  469591:	mov    r12d,0xffffffff
  469597:	crc32  r12,r9
  46959d:	mov    QWORD PTR [rsp-0x28],r12
  4695a2:	mov    r9d,r12d
  4695a5:	jmp    4694b9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  4695aa:	inc    DWORD PTR [rsp-0x2c]
  4695ae:	jmp    468bda <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  4695b3:	inc    DWORD PTR [rsp-0x2c]
  4695b7:	vpxor  xmm15,xmm15,xmm15
  4695bc:	xor    r11d,r11d
  4695bf:	vpxor  xmm12,xmm12,xmm12
  4695c4:	jmp    468b63 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  4695c9:	inc    DWORD PTR [rsp-0x2c]
  4695cd:	jmp    468c52 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
