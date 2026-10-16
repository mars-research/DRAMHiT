0000000000468a90 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468a90:	push   rbp
  468a91:	mov    rcx,rdi
  468a94:	mov    rbp,rsp
  468a97:	push   r15
  468a99:	mov    r15,rdx
  468a9c:	push   r14
  468a9e:	push   r13
  468aa0:	push   r12
  468aa2:	push   rbx
  468aa3:	and    rsp,0xffffffffffffffc0
  468aa7:	sub    rsp,0x8
  468aab:	mov    r11,QWORD PTR [rsi+0x8]
  468aaf:	mov    edi,DWORD PTR [rdi+0xc0]
  468ab5:	mov    eax,DWORD PTR [rcx+0xc4]
  468abb:	mov    rdx,QWORD PTR [rsi]
  468abe:	mov    r8d,DWORD PTR [rcx+0x78]
  468ac2:	mov    r9d,DWORD PTR [rcx+0x6c]
  468ac6:	mov    r10,r11
  468ac9:	mov    esi,edi
  468acb:	shl    r10,0x4
  468acf:	sub    esi,eax
  468ad1:	lea    rbx,[rdx+r10*1]
  468ad5:	and    esi,r8d
  468ad8:	lea    r12d,[r9-0x1]
  468adc:	mov    QWORD PTR [rsp-0x20],rbx
  468ae1:	cmp    esi,r12d
  468ae4:	jb     46934c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8bc>
  468aea:	and    r11,0xfffffffffffffffc
  468aee:	shl    r9,0x4
  468af2:	shl    r11,0x4
  468af6:	mov    r14,QWORD PTR [r15+0x8]
  468afa:	mov    esi,DWORD PTR [rcx+0x80]
  468b00:	mov    QWORD PTR [rsp-0x18],r9
  468b05:	mov    QWORD PTR [rsp-0x38],r11
  468b0a:	lea    r10,[r9-0x1]
  468b0e:	lea    r11,[rdx+r11*1]
  468b12:	mov    r9d,edi
  468b15:	mov    QWORD PTR [rsp],r14
  468b19:	mov    QWORD PTR [rsp-0x28],r11
  468b1e:	mov    DWORD PTR [rsp-0x2c],0x0
  468b26:	mov    r8,QWORD PTR [rcx+0xa0]
  468b2d:	mov    rdi,QWORD PTR [rip+0x2b0bc]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468b34:	shl    rax,0x4
  468b38:	shl    r9,0x4
  468b3c:	not    esi
  468b3e:	cmp    rdx,r11
  468b41:	je     4695ea <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb5a>
  468b47:	mov    r13d,0x55
  468b4d:	mov    ebx,0xf
  468b52:	mov    r12d,0xf0
  468b58:	mov    r11d,0xf00
  468b5e:	kmovb  k2,r13d
  468b63:	mov    r13d,0xfffff000
  468b69:	mov    QWORD PTR [rsp-0x40],rcx
  468b6e:	mov    QWORD PTR [rsp-0x48],r15
  468b73:	vpxor  xmm4,xmm4,xmm4
  468b77:	mov    r14d,0xffffffff
  468b7d:	kmovw  k6,ebx
  468b81:	kmovw  k5,r12d
  468b86:	kmovw  k4,r11d
  468b8b:	kmovw  k3,r13d
  468b90:	jmp    468de9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  468b95:	nop    DWORD PTR [rax]
  468b98:	vmovd  xmm13,DWORD PTR [r12+0xc]
  468b9f:	kshiftlb k7,k7,0x1
  468ba5:	vpcompressq zmm12{k7}{z},zmm8
  468bab:	vpunpcklqdq xmm14,xmm13,xmm12
  468bb0:	vshufi32x4 zmm15{k6}{z},zmm14,zmm14,0x0
  468bb7:	vmovdqa64 zmm12,zmm15
  468bbd:	mov    r11d,0x1
  468bc3:	lea    r13,[r8+rax*1]
  468bc7:	lea    r12,[rax+0x180]
  468bce:	and    r12,r10
  468bd1:	mov    r15d,DWORD PTR [r13+0x8]
  468bd5:	andn   ecx,esi,DWORD PTR [r8+r12*1+0x8]
  468bdc:	shl    rcx,0x4
  468be0:	andn   r12d,esi,r15d
  468be5:	shl    r12,0x4
  468be9:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r12*1]
  468bf0:	vpbroadcastq zmm2,QWORD PTR [r13+0x0]
  468bf7:	vpcmpequq k0{k2},zmm0,zmm2
  468bfe:	add    rax,0x10
  468c02:	and    rax,r10
  468c05:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468c09:	kortestb k0,k0
  468c0d:	je     469260 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
  468c13:	vmovd  xmm1,DWORD PTR [r13+0xc]
  468c19:	kshiftlb k7,k0,0x1
  468c1f:	vpcompressq zmm6{k7}{z},zmm0
  468c25:	vpunpcklqdq xmm7,xmm1,xmm6
  468c29:	vshufi32x4 zmm15{k5},zmm7,zmm7,0x0
  468c30:	vmovdqa64 zmm12,zmm15
  468c36:	or     r11d,0x2
  468c3a:	lea    r13,[rax+0x180]
  468c41:	and    r13,r10
  468c44:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  468c4b:	shl    rcx,0x4
  468c4f:	lea    r13,[r8+rax*1]
  468c53:	mov    ebx,DWORD PTR [r13+0x8]
  468c57:	andn   r12d,esi,ebx
  468c5c:	shl    r12,0x4
  468c60:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r12*1]
  468c67:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  468c6e:	vpcmpequq k0{k2},zmm8,zmm9
  468c75:	add    rax,0x10
  468c79:	and    rax,r10
  468c7c:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468c80:	kortestb k0,k0
  468c84:	je     469210 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x780>
  468c8a:	vmovd  xmm13,DWORD PTR [r13+0xc]
  468c90:	kshiftlb k7,k0,0x1
  468c96:	vpcompressq zmm12{k7}{z},zmm8
  468c9c:	vpunpcklqdq xmm14,xmm13,xmm12
  468ca1:	vshufi32x4 zmm15{k4},zmm14,zmm14,0x0
  468ca8:	vmovdqa64 zmm12,zmm15
  468cae:	or     r11d,0x4
  468cb2:	lea    r15,[r8+rax*1]
  468cb6:	lea    r13,[rax+0x180]
  468cbd:	and    r13,r10
  468cc0:	mov    r12d,DWORD PTR [r15+0x8]
  468cc4:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  468ccb:	shl    rcx,0x4
  468ccf:	andn   r13d,esi,r12d
  468cd4:	shl    r13,0x4
  468cd8:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r13*1]
  468cdf:	vpbroadcastq zmm2,QWORD PTR [r15]
  468ce5:	vpcmpequq k0{k2},zmm0,zmm2
  468cec:	add    rax,0x10
  468cf0:	and    rax,r10
  468cf3:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468cf7:	kortestb k0,k0
  468cfb:	lea    rcx,[r8+r9*1]
  468cff:	je     4691c8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
  468d05:	vmovd  xmm1,DWORD PTR [r15+0xc]
  468d0b:	kshiftlb k7,k0,0x1
  468d11:	vpcompressq zmm6{k7}{z},zmm0
  468d17:	vpunpcklqdq xmm7,xmm1,xmm6
  468d1b:	vshufi32x4 zmm15{k3},zmm7,zmm7,0x0
  468d22:	or     r11d,0x8
  468d26:	vmovdqa64 zmm12,zmm15
  468d2c:	cmp    r11d,0xf
  468d30:	jne    469318 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x888>
  468d36:	mov    r15,QWORD PTR [rsp]
  468d3a:	vmovdqu64 ZMMWORD PTR [r15],zmm15
  468d40:	add    r15,0x40
  468d44:	mov    QWORD PTR [rsp],r15
  468d48:	mov    rbx,r14
  468d4b:	mov    r11,r14
  468d4e:	crc32  rbx,QWORD PTR [rdx]
  468d54:	crc32  r11,QWORD PTR [rdx+0x20]
  468d5b:	andn   r13d,esi,ebx
  468d60:	shl    r13,0x4
  468d64:	andn   r15d,esi,r11d
  468d69:	shl    r15,0x4
  468d6d:	prefetcht2 BYTE PTR [rdi+r13*1]
  468d72:	prefetcht2 BYTE PTR [rdi+r15*1]
  468d77:	mov    r13,r14
  468d7a:	mov    r15,r14
  468d7d:	crc32  r13,QWORD PTR [rdx+0x10]
  468d84:	crc32  r15,QWORD PTR [rdx+0x30]
  468d8b:	andn   r12d,esi,r13d
  468d90:	shl    r12,0x4
  468d94:	prefetcht2 BYTE PTR [rdi+r12*1]
  468d99:	andn   r12d,esi,r15d
  468d9e:	shl    r12,0x4
  468da2:	prefetcht2 BYTE PTR [rdi+r12*1]
  468da7:	lea    r12,[r9+0x40]
  468dab:	vmovdqu64 zmm15,ZMMWORD PTR [rdx]
  468db1:	cmp    QWORD PTR [rsp-0x18],r12
  468db6:	jb     4692a8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x818>
  468dbc:	vmovdqu64 ZMMWORD PTR [rcx],zmm15
  468dc2:	mov    DWORD PTR [rcx+0x8],ebx
  468dc5:	mov    DWORD PTR [r8+r9*1+0x18],r13d
  468dca:	mov    DWORD PTR [r8+r9*1+0x28],r11d
  468dcf:	mov    DWORD PTR [r8+r9*1+0x38],r15d
  468dd4:	mov    r9,r12
  468dd7:	add    rdx,0x40
  468ddb:	and    r9,r10
  468dde:	cmp    QWORD PTR [rsp-0x28],rdx
  468de3:	je     468e88 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3f8>
  468de9:	lea    r12,[r8+rax*1]
  468ded:	mov    r11d,DWORD PTR [r12+0x8]
  468df2:	andn   r13d,esi,r11d
  468df7:	shl    r13,0x4
  468dfb:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r13*1]
  468e02:	vpbroadcastq zmm9,QWORD PTR [r12]
  468e09:	vpcmpequq k7{k2},zmm8,zmm9
  468e10:	lea    rcx,[rax+0x180]
  468e17:	add    rax,0x10
  468e1b:	and    rcx,r10
  468e1e:	and    rax,r10
  468e21:	andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
  468e28:	shl    r15,0x4
  468e2c:	kortestb k7,k7
  468e30:	prefetcht0 BYTE PTR [rdi+r15*1]
  468e35:	jne    468b98 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
  468e3b:	vpcmpequq k1{k2},zmm8,zmm4
  468e42:	kortestb k1,k1
  468e46:	jne    469613 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb83>
  468e4c:	vmovdqu xmm10,XMMWORD PTR [r12]
  468e52:	mov    rcx,r14
  468e55:	crc32  rcx,r11
  468e5b:	vpinsrd xmm11,xmm10,ecx,0x2
  468e61:	andn   r15d,esi,ecx
  468e66:	shl    r15,0x4
  468e6a:	prefetcht2 BYTE PTR [rdi+r15*1]
  468e6f:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  468e75:	add    r9,0x10
  468e79:	and    r9,r10
  468e7c:	jmp    468de9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  468e81:	nop    DWORD PTR [rax+0x0]
  468e88:	mov    rcx,QWORD PTR [rsp-0x40]
  468e8d:	mov    r15,QWORD PTR [rsp-0x48]
  468e92:	mov    edi,DWORD PTR [rsp-0x2c]
  468e96:	vmovq  xmm14,r9
  468e9b:	vpinsrq xmm0,xmm14,rax,0x1
  468ea1:	mov    rsi,QWORD PTR [rsp-0x38]
  468ea6:	vpsrlq xmm2,xmm0,0x4
  468eab:	vpmovqd xmm3,xmm2
  468eb1:	sar    rsi,0x4
  468eb5:	vmovq  QWORD PTR [rcx+0xc0],xmm3
  468ebd:	sub    rsi,rdi
  468ec0:	add    DWORD PTR [r15],esi
  468ec3:	vpextrd eax,xmm3,0x1
  468ec9:	cmp    rdx,QWORD PTR [rsp-0x20]
  468ece:	je     4691b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  468ed4:	mov    rdi,QWORD PTR [rcx+0x88]
  468edb:	mov    rbx,QWORD PTR [rcx+0x80]
  468ee2:	mov    r8,QWORD PTR [rcx+0x60]
  468ee6:	dec    rdi
  468ee9:	mov    QWORD PTR [rsp-0x18],rbx
  468eee:	mov    QWORD PTR [rsp],r8
  468ef2:	mov    QWORD PTR [rsp-0x28],rdi
  468ef7:	mov    r10d,DWORD PTR [rcx+0x78]
  468efb:	mov    r11,QWORD PTR [rip+0x2acee]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468f02:	mov    r9,QWORD PTR [rcx+0xa0]
  468f09:	movzx  r13d,BYTE PTR [rip+0x2abef]        # 493b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  468f11:	mov    r12,QWORD PTR [rip+0x2abf0]        # 493b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  468f18:	mov    r14d,0x55
  468f1e:	vpxor  xmm7,xmm7,xmm7
  468f22:	kmovb  k2,r14d
  468f27:	nop    WORD PTR [rax+rax*1+0x0]
  468f30:	lea    esi,[rax+0x18]
  468f33:	and    esi,r10d
  468f36:	shl    rsi,0x4
  468f3a:	mov    r8d,ebx
  468f3d:	and    r8d,DWORD PTR [r9+rsi*1+0x8]
  468f42:	mov    esi,eax
  468f44:	shl    rsi,0x4
  468f48:	add    rsi,r9
  468f4b:	mov    r14,r8
  468f4e:	mov    r8,QWORD PTR [rsi]
  468f51:	shl    r14,0x4
  468f55:	prefetcht0 BYTE PTR [r11+r14*1]
  468f5a:	cmp    r8,QWORD PTR [rcx+0x90]
  468f61:	jne    469020 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x590>
  468f67:	test   r13b,r13b
  468f6a:	je     468f8a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fa>
  468f6c:	mov    r14d,DWORD PTR [r15]
  468f6f:	mov    esi,DWORD PTR [rsi+0xc]
  468f72:	mov    r8,r14
  468f75:	shl    r14,0x4
  468f79:	add    r14,QWORD PTR [r15+0x8]
  468f7d:	inc    r8d
  468f80:	mov    DWORD PTR [r14],esi
  468f83:	mov    QWORD PTR [r14+0x8],r12
  468f87:	mov    DWORD PTR [r15],r8d
  468f8a:	inc    eax
  468f8c:	and    eax,r10d
  468f8f:	mov    DWORD PTR [rcx+0xc4],eax
  468f95:	test   r12,r12
  468f98:	jne    468f30 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  468f9a:	cmp    QWORD PTR [rsp],0x4
  468f9f:	je     469115 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x685>
  468fa5:	nop    DWORD PTR [rax]
  468fa8:	cmp    QWORD PTR [rsp],0x8
  468fad:	je     469190 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
  468fb3:	vmovd  xmm15,DWORD PTR [rsp-0x10]
  468fb9:	mov    rdi,QWORD PTR [rdx]
  468fbc:	mov    esi,DWORD PTR [rcx+0xc0]
  468fc2:	mov    r8,QWORD PTR [rsp-0x28]
  468fc7:	mov    rax,rsi
  468fca:	and    r8,QWORD PTR [rsp-0x10]
  468fcf:	vpinsrd xmm9,xmm15,DWORD PTR [rdx+0xc],0x1
  468fd6:	and    r8,0xfffffffffffffffc
  468fda:	shl    rsi,0x4
  468fde:	inc    eax
  468fe0:	add    rsi,r9
  468fe3:	shl    r8,0x4
  468fe7:	and    eax,r10d
  468fea:	add    rdx,0x10
  468fee:	prefetcht2 BYTE PTR [r11+r8*1]
  468ff3:	mov    QWORD PTR [rsi],rdi
  468ff6:	vmovq  QWORD PTR [rsi+0x8],xmm9
  468ffb:	mov    DWORD PTR [rcx+0xc0],eax
  469001:	cmp    rdx,QWORD PTR [rsp-0x20]
  469006:	je     4691b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  46900c:	mov    eax,DWORD PTR [rcx+0xc4]
  469012:	jmp    468f30 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  469017:	nop    WORD PTR [rax+rax*1+0x0]
  469020:	mov    r14d,DWORD PTR [rsi+0x8]
  469024:	mov    edi,ebx
  469026:	and    edi,r14d
  469029:	shl    rdi,0x4
  46902d:	add    rdi,r11
  469030:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  469036:	vpbroadcastq zmm6,r8
  46903c:	vpcmpequq k0{k2},zmm5,zmm6
  469043:	kortestb k0,k0
  469047:	jne    4690d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x640>
  46904d:	vpcmpequq k3{k2},zmm5,zmm7
  469054:	kortestb k3,k3
  469058:	jne    469140 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  46905e:	cmp    QWORD PTR [rsp],0x4
  469063:	mov    edi,r14d
  469066:	je     469150 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  46906c:	cmp    QWORD PTR [rsp],0x8
  469071:	je     469170 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
  469077:	vmovd  xmm1,DWORD PTR [rsp-0x8]
  46907d:	mov    edi,DWORD PTR [rcx+0xc0]
  469083:	mov    r14,QWORD PTR [rsp-0x18]
  469088:	vpinsrd xmm4,xmm1,DWORD PTR [rsi+0xc],0x1
  46908f:	mov    rsi,rdi
  469092:	and    r14,QWORD PTR [rsp-0x8]
  469097:	shl    rdi,0x4
  46909b:	inc    esi
  46909d:	inc    eax
  46909f:	add    rdi,r9
  4690a2:	shl    r14,0x4
  4690a6:	and    esi,r10d
  4690a9:	and    eax,r10d
  4690ac:	prefetcht2 BYTE PTR [r11+r14*1]
  4690b1:	mov    QWORD PTR [rdi],r8
  4690b4:	vmovq  QWORD PTR [rdi+0x8],xmm4
  4690b9:	mov    DWORD PTR [rcx+0xc0],esi
  4690bf:	mov    DWORD PTR [rcx+0xc4],eax
  4690c5:	jmp    468f30 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  4690ca:	nop    WORD PTR [rax+rax*1+0x0]
  4690d0:	mov    r8d,DWORD PTR [r15]
  4690d3:	mov    esi,DWORD PTR [rsi+0xc]
  4690d6:	mov    r14,r8
  4690d9:	shl    r8,0x4
  4690dd:	add    r8,QWORD PTR [r15+0x8]
  4690e1:	mov    DWORD PTR [r8],esi
  4690e4:	kmovb  esi,k0
  4690e8:	tzcnt  esi,esi
  4690ec:	inc    esi
  4690ee:	movsxd rsi,esi
  4690f1:	mov    rdi,QWORD PTR [rdi+rsi*8]
  4690f5:	inc    eax
  4690f7:	inc    r14d
  4690fa:	and    eax,r10d
  4690fd:	cmp    QWORD PTR [rsp],0x4
  469102:	mov    QWORD PTR [r8+0x8],rdi
  469106:	mov    DWORD PTR [r15],r14d
  469109:	mov    DWORD PTR [rcx+0xc4],eax
  46910f:	jne    468fa8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x518>
  469115:	mov    r14d,0xffffffff
  46911b:	crc32  r14d,DWORD PTR [rdx]
  469121:	vmovd  xmm8,r14d
  469126:	mov    rdi,QWORD PTR [rdx]
  469129:	vmovdqa xmm15,xmm8
  46912e:	vmovq  QWORD PTR [rsp-0x10],xmm8
  469134:	jmp    468fbc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  469139:	nop    DWORD PTR [rax+0x0]
  469140:	inc    eax
  469142:	and    eax,r10d
  469145:	mov    DWORD PTR [rcx+0xc4],eax
  46914b:	jmp    468f9a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
  469150:	mov    edi,0xffffffff
  469155:	crc32  edi,r14d
  46915b:	vmovd  xmm12,edi
  46915f:	vmovdqa xmm1,xmm12
  469163:	vmovq  QWORD PTR [rsp-0x8],xmm12
  469169:	jmp    46907d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  46916e:	xchg   ax,ax
  469170:	mov    r14d,0xffffffff
  469176:	crc32  r14,rdi
  46917c:	mov    QWORD PTR [rsp-0x8],r14
  469181:	vmovd  xmm1,r14d
  469186:	jmp    46907d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  46918b:	nop    DWORD PTR [rax+rax*1+0x0]
  469190:	mov    rdi,QWORD PTR [rdx]
  469193:	mov    eax,0xffffffff
  469198:	crc32  rax,rdi
  46919e:	mov    QWORD PTR [rsp-0x10],rax
  4691a3:	vmovd  xmm15,eax
  4691a7:	jmp    468fbc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  4691ac:	nop    DWORD PTR [rax+0x0]
  4691b0:	vzeroupper 
  4691b3:	lea    rsp,[rbp-0x28]
  4691b7:	pop    rbx
  4691b8:	pop    r12
  4691ba:	pop    r13
  4691bc:	pop    r14
  4691be:	pop    r15
  4691c0:	pop    rbp
  4691c1:	ret    
  4691c2:	nop    WORD PTR [rax+rax*1+0x0]
  4691c8:	vpcmpequq k1{k2},zmm0,zmm4
  4691cf:	kortestb k1,k1
  4691d3:	jne    469310 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x880>
  4691d9:	vmovdqu xmm3,XMMWORD PTR [r15]
  4691de:	mov    rbx,r14
  4691e1:	crc32  rbx,r12
  4691e7:	vpinsrd xmm5,xmm3,ebx,0x2
  4691ed:	add    r9,0x10
  4691f1:	andn   r12d,esi,ebx
  4691f6:	shl    r12,0x4
  4691fa:	and    r9,r10
  4691fd:	prefetcht2 BYTE PTR [rdi+r12*1]
  469202:	vmovdqu XMMWORD PTR [rcx],xmm5
  469206:	jmp    468cb2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
  46920b:	nop    DWORD PTR [rax+rax*1+0x0]
  469210:	vpcmpequq k1{k2},zmm8,zmm4
  469217:	kortestb k1,k1
  46921b:	jne    469629 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb99>
  469221:	vmovdqu xmm10,XMMWORD PTR [r13+0x0]
  469227:	mov    rcx,r14
  46922a:	crc32  rcx,rbx
  469230:	vpinsrd xmm11,xmm10,ecx,0x2
  469236:	andn   r15d,esi,ecx
  46923b:	shl    r15,0x4
  46923f:	prefetcht2 BYTE PTR [rdi+r15*1]
  469244:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  46924a:	add    r9,0x10
  46924e:	and    r9,r10
  469251:	jmp    468c3a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469256:	cs nop WORD PTR [rax+rax*1+0x0]
  469260:	vpcmpequq k1{k2},zmm0,zmm4
  469267:	kortestb k1,k1
  46926b:	jne    46960a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb7a>
  469271:	vmovdqu xmm3,XMMWORD PTR [r13+0x0]
  469277:	mov    rcx,r14
  46927a:	crc32  rcx,r15
  469280:	vpinsrd xmm5,xmm3,ecx,0x2
  469286:	andn   ebx,esi,ecx
  46928b:	shl    rbx,0x4
  46928f:	prefetcht2 BYTE PTR [rdi+rbx*1]
  469293:	vmovdqu XMMWORD PTR [r8+r9*1],xmm5
  469299:	add    r9,0x10
  46929d:	and    r9,r10
  4692a0:	jmp    468bc3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  4692a5:	nop    DWORD PTR [rax]
  4692a8:	vmovd  xmm10,ebx
  4692ac:	vpinsrd xmm11,xmm10,r13d,0x1
  4692b2:	mov    r13,QWORD PTR [rsp-0x18]
  4692b7:	vmovd  xmm8,r11d
  4692bc:	mov    r11,r13
  4692bf:	vpinsrd xmm9,xmm8,r15d,0x1
  4692c5:	sub    r11,r9
  4692c8:	mov    ebx,0x4444
  4692cd:	vpunpcklqdq xmm13,xmm11,xmm9
  4692d2:	shr    r11,0x2
  4692d6:	mov    r15d,0x1
  4692dc:	kmovw  k7,ebx
  4692e0:	shlx   r11d,r15d,r11d
  4692e5:	vpexpandd zmm15{k7},zmm13
  4692eb:	lea    ebx,[r11-0x1]
  4692ef:	sub    r9,r13
  4692f2:	neg    r11d
  4692f5:	kmovw  k1,ebx
  4692f9:	vmovdqu32 ZMMWORD PTR [rcx]{k1},zmm15
  4692ff:	kmovw  k7,r11d
  469304:	vmovdqu32 ZMMWORD PTR [r8+r9*1]{k7},zmm15
  46930b:	jmp    468dd4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x344>
  469310:	inc    DWORD PTR [rsp-0x2c]
  469314:	nop    DWORD PTR [rax+0x0]
  469318:	mov    r12,QWORD PTR [rsp]
  46931c:	mov    r15d,0x55
  469322:	pdep   r13d,r11d,r15d
  469327:	popcnt r11d,r11d
  46932c:	lea    ebx,[r13+r13*2+0x0]
  469331:	shl    r11,0x4
  469335:	kmovb  k1,ebx
  469339:	vpcompressq ZMMWORD PTR [r12]{k1},zmm12
  469340:	add    r12,r11
  469343:	mov    QWORD PTR [rsp],r12
  469347:	jmp    468d48 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b8>
  46934c:	cmp    rdx,QWORD PTR [rsp-0x20]
  469351:	je     4691b3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x723>
  469357:	mov    r12,QWORD PTR [rcx+0x88]
  46935e:	movzx  r13d,BYTE PTR [rip+0x2a79a]        # 493b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469366:	mov    r9,QWORD PTR [rip+0x2a79b]        # 493b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46936d:	mov    r10,QWORD PTR [rcx+0x60]
  469371:	mov    ebx,0x55
  469376:	dec    r12
  469379:	kmovb  k2,r13d
  46937e:	mov    QWORD PTR [rsp],r10
  469382:	mov    QWORD PTR [rsp-0x8],r12
  469387:	mov    r14,QWORD PTR [rip+0x2a862]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46938e:	mov    r11,QWORD PTR [rcx+0xa0]
  469395:	mov    esi,edi
  469397:	vpxor  xmm2,xmm2,xmm2
  46939b:	mov    r13,r9
  46939e:	kmovb  k1,ebx
  4693a2:	jmp    46940a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x97a>
  4693a4:	cmp    QWORD PTR [rsp],0x8
  4693a9:	je     4695b8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb28>
  4693af:	vmovd  xmm5,DWORD PTR [rsp-0x18]
  4693b5:	mov    r12,QWORD PTR [rsp-0x8]
  4693ba:	mov    esi,edi
  4693bc:	and    r12,QWORD PTR [rsp-0x18]
  4693c1:	vpinsrd xmm7,xmm5,DWORD PTR [rdx+0xc],0x1
  4693c8:	mov    r10,QWORD PTR [rdx]
  4693cb:	and    r12,0xfffffffffffffffc
  4693cf:	shl    rsi,0x4
  4693d3:	add    rsi,r11
  4693d6:	shl    r12,0x4
  4693da:	prefetcht2 BYTE PTR [r14+r12*1]
  4693df:	mov    QWORD PTR [rsi],r10
  4693e2:	vmovq  QWORD PTR [rsi+0x8],xmm7
  4693e7:	lea    esi,[rdi+0x1]
  4693ea:	and    esi,r8d
  4693ed:	add    rdx,0x10
  4693f1:	mov    DWORD PTR [rcx+0xc0],esi
  4693f7:	cmp    QWORD PTR [rsp-0x20],rdx
  4693fc:	je     4691b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  469402:	mov    eax,DWORD PTR [rcx+0xc4]
  469408:	mov    edi,esi
  46940a:	sub    esi,eax
  46940c:	and    esi,r8d
  46940f:	cmp    r8d,esi
  469412:	jbe    469435 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a5>
  469414:	cmp    QWORD PTR [rsp],0x4
  469419:	jne    4693a4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x914>
  46941b:	mov    ebx,0xffffffff
  469420:	crc32  ebx,DWORD PTR [rdx]
  469425:	vmovd  xmm6,ebx
  469429:	vmovdqa xmm5,xmm6
  46942d:	vmovq  QWORD PTR [rsp-0x18],xmm6
  469433:	jmp    4693b5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  469435:	mov    rbx,QWORD PTR [rcx+0x80]
  46943c:	mov    QWORD PTR [rsp-0x10],rbx
  469441:	nop    DWORD PTR [rax+0x0]
  469448:	lea    esi,[rax+0x18]
  46944b:	and    esi,r8d
  46944e:	shl    rsi,0x4
  469452:	mov    r9d,ebx
  469455:	and    r9d,DWORD PTR [r11+rsi*1+0x8]
  46945a:	mov    esi,eax
  46945c:	mov    r10,r9
  46945f:	shl    rsi,0x4
  469463:	shl    r10,0x4
  469467:	add    rsi,r11
  46946a:	prefetcht0 BYTE PTR [r14+r10*1]
  46946f:	mov    r10,QWORD PTR [rsi]
  469472:	cmp    r10,QWORD PTR [rcx+0x90]
  469479:	jne    4694c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa30>
  46947b:	kortestb k2,k2
  46947f:	je     4694a2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa12>
  469481:	mov    r12d,DWORD PTR [r15]
  469484:	mov    esi,DWORD PTR [rsi+0xc]
  469487:	mov    r10,r12
  46948a:	shl    r12,0x4
  46948e:	add    r12,QWORD PTR [r15+0x8]
  469492:	lea    r9d,[r10+0x1]
  469496:	mov    DWORD PTR [r12],esi
  46949a:	mov    QWORD PTR [r12+0x8],r13
  46949f:	mov    DWORD PTR [r15],r9d
  4694a2:	inc    eax
  4694a4:	and    eax,r8d
  4694a7:	mov    DWORD PTR [rcx+0xc4],eax
  4694ad:	test   r13,r13
  4694b0:	jne    469448 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  4694b2:	jmp    469414 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  4694b7:	nop    WORD PTR [rax+rax*1+0x0]
  4694c0:	mov    r12d,DWORD PTR [rsi+0x8]
  4694c4:	mov    r9d,ebx
  4694c7:	and    r9d,r12d
  4694ca:	shl    r9,0x4
  4694ce:	add    r9,r14
  4694d1:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  4694d7:	vpbroadcastq zmm1,r10
  4694dd:	vpcmpequq k0{k1},zmm0,zmm1
  4694e4:	kortestb k0,k0
  4694e8:	jne    469564 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad4>
  4694ea:	vpcmpequq k3{k1},zmm0,zmm2
  4694f1:	kortestb k3,k3
  4694f5:	jne    4695a8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb18>
  4694fb:	cmp    QWORD PTR [rsp],0x4
  469500:	mov    r9d,r12d
  469503:	je     4695d1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb41>
  469509:	cmp    QWORD PTR [rsp],0x8
  46950e:	je     4695f1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb61>
  469514:	mov    r9d,DWORD PTR [rsp-0x28]
  469519:	mov    r12,QWORD PTR [rsp-0x10]
  46951e:	vmovd  xmm4,r9d
  469523:	vpinsrd xmm3,xmm4,DWORD PTR [rsi+0xc],0x1
  46952a:	mov    esi,edi
  46952c:	and    r12,QWORD PTR [rsp-0x28]
  469531:	shl    rsi,0x4
  469535:	inc    edi
  469537:	inc    eax
  469539:	add    rsi,r11
  46953c:	shl    r12,0x4
  469540:	and    edi,r8d
  469543:	and    eax,r8d
  469546:	prefetcht2 BYTE PTR [r14+r12*1]
  46954b:	mov    QWORD PTR [rsi],r10
  46954e:	vmovq  QWORD PTR [rsi+0x8],xmm3
  469553:	mov    DWORD PTR [rcx+0xc0],edi
  469559:	mov    DWORD PTR [rcx+0xc4],eax
  46955f:	jmp    469448 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  469564:	mov    r10d,DWORD PTR [r15]
  469567:	mov    r12d,DWORD PTR [rsi+0xc]
  46956b:	mov    rbx,r10
  46956e:	shl    r10,0x4
  469572:	add    r10,QWORD PTR [r15+0x8]
  469576:	mov    DWORD PTR [r10],r12d
  469579:	xor    r12d,r12d
  46957c:	kmovb  esi,k0
  469580:	tzcnt  r12d,esi
  469585:	inc    r12d
  469588:	movsxd rsi,r12d
  46958b:	mov    r9,QWORD PTR [r9+rsi*8]
  46958f:	inc    eax
  469591:	inc    ebx
  469593:	and    eax,r8d
  469596:	mov    QWORD PTR [r10+0x8],r9
  46959a:	mov    DWORD PTR [r15],ebx
  46959d:	mov    DWORD PTR [rcx+0xc4],eax
  4695a3:	jmp    469414 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  4695a8:	inc    eax
  4695aa:	and    eax,r8d
  4695ad:	mov    DWORD PTR [rcx+0xc4],eax
  4695b3:	jmp    469414 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  4695b8:	mov    eax,0xffffffff
  4695bd:	crc32  rax,QWORD PTR [rdx]
  4695c3:	mov    QWORD PTR [rsp-0x18],rax
  4695c8:	vmovd  xmm5,eax
  4695cc:	jmp    4693b5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  4695d1:	mov    r9d,0xffffffff
  4695d7:	crc32  r9d,r12d
  4695dd:	mov    r12d,r9d
  4695e0:	mov    QWORD PTR [rsp-0x28],r12
  4695e5:	jmp    469519 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  4695ea:	xor    edi,edi
  4695ec:	jmp    468e96 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x406>
  4695f1:	mov    r12d,0xffffffff
  4695f7:	crc32  r12,r9
  4695fd:	mov    QWORD PTR [rsp-0x28],r12
  469602:	mov    r9d,r12d
  469605:	jmp    469519 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  46960a:	inc    DWORD PTR [rsp-0x2c]
  46960e:	jmp    468c3a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469613:	inc    DWORD PTR [rsp-0x2c]
  469617:	vpxor  xmm15,xmm15,xmm15
  46961c:	xor    r11d,r11d
  46961f:	vpxor  xmm12,xmm12,xmm12
  469624:	jmp    468bc3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  469629:	inc    DWORD PTR [rsp-0x2c]
  46962d:	jmp    468cb2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
