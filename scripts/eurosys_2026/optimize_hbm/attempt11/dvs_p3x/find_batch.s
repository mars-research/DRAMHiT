0000000000468d80 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468d80:	push   rbp
  468d81:	mov    rcx,rdi
  468d84:	mov    rbp,rsp
  468d87:	push   r15
  468d89:	mov    r15,rdx
  468d8c:	push   r14
  468d8e:	push   r13
  468d90:	push   r12
  468d92:	push   rbx
  468d93:	and    rsp,0xffffffffffffffc0
  468d97:	sub    rsp,0x8
  468d9b:	mov    r11,QWORD PTR [rsi+0x8]
  468d9f:	mov    edi,DWORD PTR [rdi+0xb0]
  468da5:	mov    eax,DWORD PTR [rcx+0xb4]
  468dab:	mov    rdx,QWORD PTR [rsi]
  468dae:	mov    r8d,DWORD PTR [rcx+0x78]
  468db2:	mov    r9d,DWORD PTR [rcx+0x6c]
  468db6:	mov    r10,r11
  468db9:	mov    esi,edi
  468dbb:	shl    r10,0x4
  468dbf:	sub    esi,eax
  468dc1:	lea    rbx,[rdx+r10*1]
  468dc5:	and    esi,r8d
  468dc8:	lea    r12d,[r9-0x1]
  468dcc:	mov    QWORD PTR [rsp-0x20],rbx
  468dd1:	cmp    esi,r12d
  468dd4:	jb     4695f3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x873>
  468dda:	and    r11,0xfffffffffffffffc
  468dde:	mov    r10d,edi
  468de1:	shl    r11,0x4
  468de5:	mov    r14,QWORD PTR [r15+0x8]
  468de9:	mov    edi,DWORD PTR [rcx+0x80]
  468def:	shl    r9,0x4
  468df3:	mov    QWORD PTR [rsp-0x30],r11
  468df8:	lea    r11,[rdx+r11*1]
  468dfc:	lea    rsi,[r9-0x1]
  468e00:	mov    QWORD PTR [rsp],r14
  468e04:	mov    QWORD PTR [rsp-0x18],r11
  468e09:	mov    DWORD PTR [rsp-0x28],0x0
  468e11:	mov    r8,QWORD PTR [rcx+0xa0]
  468e18:	mov    r9,QWORD PTR [rip+0x29dc9]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468e1f:	shl    rax,0x4
  468e23:	shl    r10,0x4
  468e27:	not    edi
  468e29:	cmp    rdx,r11
  468e2c:	je     46988a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb0a>
  468e32:	mov    r13d,0x55
  468e38:	mov    ebx,0xf
  468e3d:	mov    r12d,0xf0
  468e43:	mov    r11d,0xf00
  468e49:	kmovb  k2,r13d
  468e4e:	mov    r13d,0xfffff000
  468e54:	mov    QWORD PTR [rsp-0x38],rcx
  468e59:	mov    QWORD PTR [rsp-0x40],r15
  468e5e:	vpxor  xmm4,xmm4,xmm4
  468e62:	mov    r14d,0xffffffff
  468e68:	kmovw  k6,ebx
  468e6c:	kmovw  k5,r12d
  468e71:	kmovw  k4,r11d
  468e76:	kmovw  k3,r13d
  468e7b:	jmp    4690fc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x37c>
  468e80:	vmovd  xmm13,DWORD PTR [r13+0xc]
  468e86:	kshiftlb k7,k7,0x1
  468e8c:	vpcompressq zmm12{k7}{z},zmm8
  468e92:	vpunpcklqdq xmm14,xmm13,xmm12
  468e97:	vshufi32x4 zmm15{k6}{z},zmm14,zmm14,0x0
  468e9e:	vmovdqa64 zmm12,zmm15
  468ea4:	mov    r11d,0x1
  468eaa:	lea    r15,[r8+rax*1]
  468eae:	lea    r13,[rax+0x180]
  468eb5:	and    r13,rsi
  468eb8:	mov    ebx,DWORD PTR [r15+0x8]
  468ebc:	andn   ecx,edi,DWORD PTR [r8+r13*1+0x8]
  468ec3:	shl    rcx,0x4
  468ec7:	andn   r13d,edi,ebx
  468ecc:	shl    r13,0x4
  468ed0:	vmovdqa64 zmm0,ZMMWORD PTR [r9+r13*1]
  468ed7:	vpbroadcastq zmm2,QWORD PTR [r15]
  468edd:	vpcmpequq k0{k2},zmm0,zmm2
  468ee4:	add    rax,0x10
  468ee8:	and    rax,rsi
  468eeb:	prefetcht0 BYTE PTR [r9+rcx*1]
  468ef0:	kortestb k0,k0
  468ef4:	je     469570 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7f0>
  468efa:	vmovd  xmm1,DWORD PTR [r15+0xc]
  468f00:	kshiftlb k7,k0,0x1
  468f06:	vpcompressq zmm5{k7}{z},zmm0
  468f0c:	vpunpcklqdq xmm6,xmm1,xmm5
  468f10:	vshufi32x4 zmm15{k5},zmm6,zmm6,0x0
  468f17:	vmovdqa64 zmm12,zmm15
  468f1d:	or     r11d,0x2
  468f21:	lea    r15,[rax+0x180]
  468f28:	and    r15,rsi
  468f2b:	andn   ecx,edi,DWORD PTR [r8+r15*1+0x8]
  468f32:	shl    rcx,0x4
  468f36:	lea    r15,[r8+rax*1]
  468f3a:	mov    ebx,DWORD PTR [r15+0x8]
  468f3e:	andn   r12d,edi,ebx
  468f43:	shl    r12,0x4
  468f47:	vmovdqa64 zmm8,ZMMWORD PTR [r9+r12*1]
  468f4e:	vpbroadcastq zmm9,QWORD PTR [r15]
  468f54:	vpcmpequq k0{k2},zmm8,zmm9
  468f5b:	add    rax,0x10
  468f5f:	and    rax,rsi
  468f62:	prefetcht0 BYTE PTR [r9+rcx*1]
  468f67:	kortestb k0,k0
  468f6b:	je     469520 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7a0>
  468f71:	vmovd  xmm13,DWORD PTR [r15+0xc]
  468f77:	kshiftlb k7,k0,0x1
  468f7d:	vpcompressq zmm12{k7}{z},zmm8
  468f83:	vpunpcklqdq xmm14,xmm13,xmm12
  468f88:	vshufi32x4 zmm15{k4},zmm14,zmm14,0x0
  468f8f:	vmovdqa64 zmm12,zmm15
  468f95:	or     r11d,0x4
  468f99:	lea    rbx,[r8+rax*1]
  468f9d:	lea    r15,[rax+0x180]
  468fa4:	and    r15,rsi
  468fa7:	andn   ecx,edi,DWORD PTR [r8+r15*1+0x8]
  468fae:	shl    rcx,0x4
  468fb2:	mov    r15d,DWORD PTR [rbx+0x8]
  468fb6:	andn   r13d,edi,r15d
  468fbb:	shl    r13,0x4
  468fbf:	vmovdqa64 zmm0,ZMMWORD PTR [r9+r13*1]
  468fc6:	vpbroadcastq zmm2,QWORD PTR [rbx]
  468fcc:	vpcmpequq k0{k2},zmm0,zmm2
  468fd3:	add    rax,0x10
  468fd7:	prefetcht0 BYTE PTR [r9+rcx*1]
  468fdc:	lea    rcx,[r10+0x10]
  468fe0:	and    rax,rsi
  468fe3:	and    rcx,rsi
  468fe6:	kortestb k0,k0
  468fea:	je     4694d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x758>
  468ff0:	vmovd  xmm1,DWORD PTR [rbx+0xc]
  468ff5:	kshiftlb k7,k0,0x1
  468ffb:	vpcompressq zmm5{k7}{z},zmm0
  469001:	vpunpcklqdq xmm6,xmm1,xmm5
  469005:	vshufi32x4 zmm15{k3},zmm6,zmm6,0x0
  46900c:	or     r11d,0x8
  469010:	vmovdqa64 zmm12,zmm15
  469016:	cmp    r11d,0xf
  46901a:	jne    4695c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x840>
  469020:	mov    rbx,QWORD PTR [rsp]
  469024:	vmovdqu64 ZMMWORD PTR [rbx],zmm15
  46902a:	add    rbx,0x40
  46902e:	mov    QWORD PTR [rsp],rbx
  469032:	mov    r15,r14
  469035:	crc32  r15,QWORD PTR [rdx]
  46903b:	andn   r13d,edi,r15d
  469040:	shl    r13,0x4
  469044:	prefetcht2 BYTE PTR [r9+r13*1]
  469049:	mov    r13,r14
  46904c:	crc32  r13,QWORD PTR [rdx+0x10]
  469053:	mov    rbx,r14
  469056:	andn   r12d,edi,r13d
  46905b:	shl    r12,0x4
  46905f:	prefetcht2 BYTE PTR [r9+r12*1]
  469064:	mov    r12,r14
  469067:	crc32  r12,QWORD PTR [rdx+0x20]
  46906e:	crc32  rbx,QWORD PTR [rdx+0x30]
  469075:	andn   r11d,edi,r12d
  46907a:	shl    r11,0x4
  46907e:	prefetcht2 BYTE PTR [r9+r11*1]
  469083:	andn   r11d,edi,ebx
  469088:	shl    r11,0x4
  46908c:	prefetcht2 BYTE PTR [r9+r11*1]
  469091:	mov    r11,rsi
  469094:	vmovdqu xmm15,XMMWORD PTR [rdx]
  469098:	and    r11,r10
  46909b:	add    r11,r8
  46909e:	vmovdqu XMMWORD PTR [r11],xmm15
  4690a3:	mov    DWORD PTR [r11+0x8],r15d
  4690a7:	add    rcx,r8
  4690aa:	lea    r15,[r10+0x30]
  4690ae:	vmovdqu xmm8,XMMWORD PTR [rdx+0x10]
  4690b3:	and    r15,rsi
  4690b6:	vmovdqu XMMWORD PTR [rcx],xmm8
  4690ba:	mov    DWORD PTR [rcx+0x8],r13d
  4690be:	lea    rcx,[r10+0x20]
  4690c2:	and    rcx,rsi
  4690c5:	vmovdqu xmm9,XMMWORD PTR [rdx+0x20]
  4690ca:	add    rcx,r8
  4690cd:	vmovdqu XMMWORD PTR [rcx],xmm9
  4690d1:	mov    DWORD PTR [rcx+0x8],r12d
  4690d5:	add    r15,r8
  4690d8:	add    r10,0x40
  4690dc:	vmovdqu xmm10,XMMWORD PTR [rdx+0x30]
  4690e1:	add    rdx,0x40
  4690e5:	vmovdqu XMMWORD PTR [r15],xmm10
  4690ea:	and    r10,rsi
  4690ed:	mov    DWORD PTR [r15+0x8],ebx
  4690f1:	cmp    QWORD PTR [rsp-0x18],rdx
  4690f6:	je     4691a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x420>
  4690fc:	lea    r13,[r8+rax*1]
  469100:	mov    r11d,DWORD PTR [r13+0x8]
  469104:	andn   r12d,edi,r11d
  469109:	shl    r12,0x4
  46910d:	vmovdqa64 zmm8,ZMMWORD PTR [r9+r12*1]
  469114:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  46911b:	vpcmpequq k7{k2},zmm8,zmm9
  469122:	lea    rcx,[rax+0x180]
  469129:	add    rax,0x10
  46912d:	and    rcx,rsi
  469130:	and    rax,rsi
  469133:	andn   r15d,edi,DWORD PTR [r8+rcx*1+0x8]
  46913a:	shl    r15,0x4
  46913e:	kortestb k7,k7
  469142:	prefetcht0 BYTE PTR [r9+r15*1]
  469147:	jne    468e80 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x100>
  46914d:	vpcmpequq k1{k2},zmm8,zmm4
  469154:	kortestb k1,k1
  469158:	jne    4698b3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb33>
  46915e:	vmovdqu xmm10,XMMWORD PTR [r13+0x0]
  469164:	mov    r15,r14
  469167:	crc32  r15,r11
  46916d:	lea    rcx,[r10+0x10]
  469171:	vpinsrd xmm11,xmm10,r15d,0x2
  469177:	andn   ebx,edi,r15d
  46917c:	shl    rbx,0x4
  469180:	prefetcht2 BYTE PTR [r9+rbx*1]
  469185:	vmovdqu XMMWORD PTR [r8+r10*1],xmm11
  46918b:	mov    r10,rcx
  46918e:	and    r10,rsi
  469191:	jmp    4690fc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x37c>
  469196:	cs nop WORD PTR [rax+rax*1+0x0]
  4691a0:	mov    rcx,QWORD PTR [rsp-0x38]
  4691a5:	mov    r15,QWORD PTR [rsp-0x40]
  4691aa:	mov    edi,DWORD PTR [rsp-0x28]
  4691ae:	vmovq  xmm11,r10
  4691b3:	vpinsrq xmm13,xmm11,rax,0x1
  4691b9:	mov    r10,QWORD PTR [rsp-0x30]
  4691be:	vpsrlq xmm14,xmm13,0x4
  4691c4:	vpmovqd xmm0,xmm14
  4691ca:	sar    r10,0x4
  4691ce:	vmovq  QWORD PTR [rcx+0xb0],xmm0
  4691d6:	sub    r10,rdi
  4691d9:	add    DWORD PTR [r15],r10d
  4691dc:	vpextrd eax,xmm0,0x1
  4691e2:	cmp    rdx,QWORD PTR [rsp-0x20]
  4691e7:	je     4694c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x740>
  4691ed:	mov    r14,QWORD PTR [rcx+0x88]
  4691f4:	mov    rbx,QWORD PTR [rcx+0x80]
  4691fb:	mov    rsi,QWORD PTR [rcx+0x60]
  4691ff:	dec    r14
  469202:	mov    QWORD PTR [rsp-0x18],rbx
  469207:	mov    QWORD PTR [rsp],rsi
  46920b:	mov    QWORD PTR [rsp-0x28],r14
  469210:	mov    r10d,DWORD PTR [rcx+0x78]
  469214:	mov    r11,QWORD PTR [rip+0x299cd]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46921b:	mov    r9,QWORD PTR [rcx+0xa0]
  469222:	movzx  r13d,BYTE PTR [rip+0x298d6]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  46922a:	mov    r12,QWORD PTR [rip+0x298d7]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469231:	mov    r8d,0x55
  469237:	vpxor  xmm2,xmm2,xmm2
  46923b:	kmovb  k7,r8d
  469240:	lea    esi,[rax+0x18]
  469243:	and    esi,r10d
  469246:	shl    rsi,0x4
  46924a:	mov    edi,ebx
  46924c:	and    edi,DWORD PTR [r9+rsi*1+0x8]
  469251:	mov    esi,eax
  469253:	shl    rsi,0x4
  469257:	add    rsi,r9
  46925a:	mov    r8,QWORD PTR [rsi]
  46925d:	shl    rdi,0x4
  469261:	prefetcht0 BYTE PTR [r11+rdi*1]
  469266:	cmp    r8,QWORD PTR [rcx+0x90]
  46926d:	jne    469330 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5b0>
  469273:	test   r13b,r13b
  469276:	je     469296 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x516>
  469278:	mov    r14d,DWORD PTR [r15]
  46927b:	mov    esi,DWORD PTR [rsi+0xc]
  46927e:	mov    r8,r14
  469281:	shl    r14,0x4
  469285:	add    r14,QWORD PTR [r15+0x8]
  469289:	inc    r8d
  46928c:	mov    DWORD PTR [r14],esi
  46928f:	mov    QWORD PTR [r14+0x8],r12
  469293:	mov    DWORD PTR [r15],r8d
  469296:	inc    eax
  469298:	and    eax,r10d
  46929b:	mov    DWORD PTR [rcx+0xb4],eax
  4692a1:	test   r12,r12
  4692a4:	jne    469240 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4c0>
  4692a6:	cmp    QWORD PTR [rsp],0x4
  4692ab:	je     469425 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6a5>
  4692b1:	nop    DWORD PTR [rax+0x0]
  4692b8:	cmp    QWORD PTR [rsp],0x8
  4692bd:	je     4694a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  4692c3:	vmovd  xmm12,DWORD PTR [rsp-0x10]
  4692c9:	mov    rdi,QWORD PTR [rdx]
  4692cc:	mov    esi,DWORD PTR [rcx+0xb0]
  4692d2:	mov    r8,QWORD PTR [rsp-0x28]
  4692d7:	mov    rax,rsi
  4692da:	and    r8,QWORD PTR [rsp-0x10]
  4692df:	vpinsrd xmm15,xmm12,DWORD PTR [rdx+0xc],0x1
  4692e6:	and    r8,0xfffffffffffffffc
  4692ea:	shl    rsi,0x4
  4692ee:	inc    eax
  4692f0:	add    rsi,r9
  4692f3:	shl    r8,0x4
  4692f7:	and    eax,r10d
  4692fa:	add    rdx,0x10
  4692fe:	prefetcht2 BYTE PTR [r11+r8*1]
  469303:	mov    QWORD PTR [rsi],rdi
  469306:	vmovq  QWORD PTR [rsi+0x8],xmm15
  46930b:	mov    DWORD PTR [rcx+0xb0],eax
  469311:	cmp    rdx,QWORD PTR [rsp-0x20]
  469316:	je     4694c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x740>
  46931c:	mov    eax,DWORD PTR [rcx+0xb4]
  469322:	jmp    469240 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4c0>
  469327:	nop    WORD PTR [rax+rax*1+0x0]
  469330:	mov    r14d,DWORD PTR [rsi+0x8]
  469334:	mov    edi,ebx
  469336:	and    edi,r14d
  469339:	shl    rdi,0x4
  46933d:	add    rdi,r11
  469340:	vmovdqa64 zmm7,ZMMWORD PTR [rdi]
  469346:	vpbroadcastq zmm3,r8
  46934c:	vpcmpequq k0{k7},zmm7,zmm3
  469353:	kortestb k0,k0
  469357:	jne    4693e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x660>
  46935d:	vpcmpequq k2{k7},zmm7,zmm2
  469364:	kortestb k2,k2
  469368:	jne    469450 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d0>
  46936e:	cmp    QWORD PTR [rsp],0x4
  469373:	mov    edi,r14d
  469376:	je     469460 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
  46937c:	cmp    QWORD PTR [rsp],0x8
  469381:	je     469480 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
  469387:	vmovd  xmm1,DWORD PTR [rsp-0x8]
  46938d:	mov    edi,DWORD PTR [rcx+0xb0]
  469393:	mov    r14,QWORD PTR [rsp-0x18]
  469398:	vpinsrd xmm6,xmm1,DWORD PTR [rsi+0xc],0x1
  46939f:	mov    rsi,rdi
  4693a2:	and    r14,QWORD PTR [rsp-0x8]
  4693a7:	shl    rdi,0x4
  4693ab:	inc    esi
  4693ad:	inc    eax
  4693af:	add    rdi,r9
  4693b2:	shl    r14,0x4
  4693b6:	and    esi,r10d
  4693b9:	and    eax,r10d
  4693bc:	prefetcht2 BYTE PTR [r11+r14*1]
  4693c1:	mov    QWORD PTR [rdi],r8
  4693c4:	vmovq  QWORD PTR [rdi+0x8],xmm6
  4693c9:	mov    DWORD PTR [rcx+0xb0],esi
  4693cf:	mov    DWORD PTR [rcx+0xb4],eax
  4693d5:	jmp    469240 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4c0>
  4693da:	nop    WORD PTR [rax+rax*1+0x0]
  4693e0:	mov    r8d,DWORD PTR [r15]
  4693e3:	mov    esi,DWORD PTR [rsi+0xc]
  4693e6:	mov    r14,r8
  4693e9:	shl    r8,0x4
  4693ed:	add    r8,QWORD PTR [r15+0x8]
  4693f1:	mov    DWORD PTR [r8],esi
  4693f4:	kmovb  esi,k0
  4693f8:	tzcnt  esi,esi
  4693fc:	inc    esi
  4693fe:	movsxd rsi,esi
  469401:	mov    rdi,QWORD PTR [rdi+rsi*8]
  469405:	inc    eax
  469407:	inc    r14d
  46940a:	and    eax,r10d
  46940d:	cmp    QWORD PTR [rsp],0x4
  469412:	mov    QWORD PTR [r8+0x8],rdi
  469416:	mov    DWORD PTR [r15],r14d
  469419:	mov    DWORD PTR [rcx+0xb4],eax
  46941f:	jne    4692b8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x538>
  469425:	mov    r14d,0xffffffff
  46942b:	crc32  r14d,DWORD PTR [rdx]
  469431:	vmovd  xmm4,r14d
  469436:	mov    rdi,QWORD PTR [rdx]
  469439:	vmovdqa xmm12,xmm4
  46943d:	vmovq  QWORD PTR [rsp-0x10],xmm4
  469443:	jmp    4692cc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x54c>
  469448:	nop    DWORD PTR [rax+rax*1+0x0]
  469450:	inc    eax
  469452:	and    eax,r10d
  469455:	mov    DWORD PTR [rcx+0xb4],eax
  46945b:	jmp    4692a6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x526>
  469460:	mov    edi,0xffffffff
  469465:	crc32  edi,r14d
  46946b:	vmovd  xmm5,edi
  46946f:	vmovdqa xmm1,xmm5
  469473:	vmovq  QWORD PTR [rsp-0x8],xmm5
  469479:	jmp    46938d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x60d>
  46947e:	xchg   ax,ax
  469480:	mov    r14d,0xffffffff
  469486:	crc32  r14,rdi
  46948c:	mov    QWORD PTR [rsp-0x8],r14
  469491:	vmovd  xmm1,r14d
  469496:	jmp    46938d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x60d>
  46949b:	nop    DWORD PTR [rax+rax*1+0x0]
  4694a0:	mov    rdi,QWORD PTR [rdx]
  4694a3:	mov    eax,0xffffffff
  4694a8:	crc32  rax,rdi
  4694ae:	mov    QWORD PTR [rsp-0x10],rax
  4694b3:	vmovd  xmm12,eax
  4694b7:	jmp    4692cc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x54c>
  4694bc:	nop    DWORD PTR [rax+0x0]
  4694c0:	vzeroupper 
  4694c3:	lea    rsp,[rbp-0x28]
  4694c7:	pop    rbx
  4694c8:	pop    r12
  4694ca:	pop    r13
  4694cc:	pop    r14
  4694ce:	pop    r15
  4694d0:	pop    rbp
  4694d1:	ret    
  4694d2:	nop    WORD PTR [rax+rax*1+0x0]
  4694d8:	vpcmpequq k1{k2},zmm0,zmm4
  4694df:	kortestb k1,k1
  4694e3:	jne    4695b8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x838>
  4694e9:	vmovdqu xmm7,XMMWORD PTR [rbx]
  4694ed:	mov    r13,r14
  4694f0:	crc32  r13,r15
  4694f6:	vpinsrd xmm3,xmm7,r13d,0x2
  4694fc:	andn   r12d,edi,r13d
  469501:	shl    r12,0x4
  469505:	prefetcht2 BYTE PTR [r9+r12*1]
  46950a:	vmovdqu XMMWORD PTR [r8+r10*1],xmm3
  469510:	mov    r10,rcx
  469513:	jmp    468f99 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x219>
  469518:	nop    DWORD PTR [rax+rax*1+0x0]
  469520:	vpcmpequq k1{k2},zmm8,zmm4
  469527:	kortestb k1,k1
  46952b:	jne    4698c9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb49>
  469531:	vmovdqu xmm10,XMMWORD PTR [r15]
  469536:	mov    r13,r14
  469539:	crc32  r13,rbx
  46953f:	lea    rcx,[r10+0x10]
  469543:	vpinsrd xmm11,xmm10,r13d,0x2
  469549:	andn   ebx,edi,r13d
  46954e:	shl    rbx,0x4
  469552:	prefetcht2 BYTE PTR [r9+rbx*1]
  469557:	vmovdqu XMMWORD PTR [r8+r10*1],xmm11
  46955d:	mov    r10,rcx
  469560:	and    r10,rsi
  469563:	jmp    468f21 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a1>
  469568:	nop    DWORD PTR [rax+rax*1+0x0]
  469570:	vpcmpequq k1{k2},zmm0,zmm4
  469577:	kortestb k1,k1
  46957b:	jne    4698aa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb2a>
  469581:	vmovdqu xmm7,XMMWORD PTR [r15]
  469586:	mov    r12,r14
  469589:	crc32  r12,rbx
  46958f:	lea    rcx,[r10+0x10]
  469593:	vpinsrd xmm3,xmm7,r12d,0x2
  469599:	andn   ebx,edi,r12d
  46959e:	shl    rbx,0x4
  4695a2:	prefetcht2 BYTE PTR [r9+rbx*1]
  4695a7:	vmovdqu XMMWORD PTR [r8+r10*1],xmm3
  4695ad:	mov    r10,rcx
  4695b0:	and    r10,rsi
  4695b3:	jmp    468eaa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x12a>
  4695b8:	inc    DWORD PTR [rsp-0x28]
  4695bc:	nop    DWORD PTR [rax+0x0]
  4695c0:	mov    r12,QWORD PTR [rsp]
  4695c4:	mov    ebx,0x55
  4695c9:	pdep   r15d,r11d,ebx
  4695ce:	popcnt r11d,r11d
  4695d3:	lea    r13d,[r15+r15*2]
  4695d7:	shl    r11,0x4
  4695db:	kmovb  k1,r13d
  4695e0:	vpcompressq ZMMWORD PTR [r12]{k1},zmm12
  4695e7:	add    r12,r11
  4695ea:	mov    QWORD PTR [rsp],r12
  4695ee:	jmp    469032 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b2>
  4695f3:	cmp    rdx,QWORD PTR [rsp-0x20]
  4695f8:	je     4694c3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x743>
  4695fe:	mov    r12,QWORD PTR [rcx+0x88]
  469605:	movzx  r13d,BYTE PTR [rip+0x294f3]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  46960d:	mov    r9,QWORD PTR [rip+0x294f4]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469614:	mov    r10,QWORD PTR [rcx+0x60]
  469618:	mov    ebx,0x55
  46961d:	dec    r12
  469620:	kmovb  k2,r13d
  469625:	mov    QWORD PTR [rsp],r10
  469629:	mov    QWORD PTR [rsp-0x8],r12
  46962e:	mov    r14,QWORD PTR [rip+0x295b3]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469635:	mov    r11,QWORD PTR [rcx+0xa0]
  46963c:	mov    esi,edi
  46963e:	vpxor  xmm2,xmm2,xmm2
  469642:	mov    r13,r9
  469645:	kmovb  k1,ebx
  469649:	jmp    4696b1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x931>
  46964b:	cmp    QWORD PTR [rsp],0x8
  469650:	je     469858 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad8>
  469656:	vmovd  xmm4,DWORD PTR [rsp-0x18]
  46965c:	mov    r12,QWORD PTR [rsp-0x8]
  469661:	mov    esi,edi
  469663:	and    r12,QWORD PTR [rsp-0x18]
  469668:	vpinsrd xmm6,xmm4,DWORD PTR [rdx+0xc],0x1
  46966f:	mov    r10,QWORD PTR [rdx]
  469672:	and    r12,0xfffffffffffffffc
  469676:	shl    rsi,0x4
  46967a:	add    rsi,r11
  46967d:	shl    r12,0x4
  469681:	prefetcht2 BYTE PTR [r14+r12*1]
  469686:	mov    QWORD PTR [rsi],r10
  469689:	vmovq  QWORD PTR [rsi+0x8],xmm6
  46968e:	lea    esi,[rdi+0x1]
  469691:	and    esi,r8d
  469694:	add    rdx,0x10
  469698:	mov    DWORD PTR [rcx+0xb0],esi
  46969e:	cmp    QWORD PTR [rsp-0x20],rdx
  4696a3:	je     4694c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x740>
  4696a9:	mov    eax,DWORD PTR [rcx+0xb4]
  4696af:	mov    edi,esi
  4696b1:	sub    esi,eax
  4696b3:	and    esi,r8d
  4696b6:	cmp    r8d,esi
  4696b9:	jbe    4696dc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x95c>
  4696bb:	cmp    QWORD PTR [rsp],0x4
  4696c0:	jne    46964b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8cb>
  4696c2:	mov    ebx,0xffffffff
  4696c7:	crc32  ebx,DWORD PTR [rdx]
  4696cc:	vmovd  xmm5,ebx
  4696d0:	vmovdqa xmm4,xmm5
  4696d4:	vmovq  QWORD PTR [rsp-0x18],xmm5
  4696da:	jmp    46965c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8dc>
  4696dc:	mov    rbx,QWORD PTR [rcx+0x80]
  4696e3:	mov    QWORD PTR [rsp-0x10],rbx
  4696e8:	nop    DWORD PTR [rax+rax*1+0x0]
  4696f0:	lea    esi,[rax+0x18]
  4696f3:	and    esi,r8d
  4696f6:	shl    rsi,0x4
  4696fa:	mov    r9d,ebx
  4696fd:	and    r9d,DWORD PTR [r11+rsi*1+0x8]
  469702:	mov    esi,eax
  469704:	mov    r10,r9
  469707:	shl    rsi,0x4
  46970b:	shl    r10,0x4
  46970f:	add    rsi,r11
  469712:	prefetcht0 BYTE PTR [r14+r10*1]
  469717:	mov    r10,QWORD PTR [rsi]
  46971a:	cmp    r10,QWORD PTR [rcx+0x90]
  469721:	jne    469760 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9e0>
  469723:	kortestb k2,k2
  469727:	je     46974a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9ca>
  469729:	mov    r12d,DWORD PTR [r15]
  46972c:	mov    esi,DWORD PTR [rsi+0xc]
  46972f:	mov    r10,r12
  469732:	shl    r12,0x4
  469736:	add    r12,QWORD PTR [r15+0x8]
  46973a:	lea    r9d,[r10+0x1]
  46973e:	mov    DWORD PTR [r12],esi
  469742:	mov    QWORD PTR [r12+0x8],r13
  469747:	mov    DWORD PTR [r15],r9d
  46974a:	inc    eax
  46974c:	and    eax,r8d
  46974f:	mov    DWORD PTR [rcx+0xb4],eax
  469755:	test   r13,r13
  469758:	jne    4696f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x970>
  46975a:	jmp    4696bb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x93b>
  46975f:	nop
  469760:	mov    r12d,DWORD PTR [rsi+0x8]
  469764:	mov    r9d,ebx
  469767:	and    r9d,r12d
  46976a:	shl    r9,0x4
  46976e:	add    r9,r14
  469771:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  469777:	vpbroadcastq zmm1,r10
  46977d:	vpcmpequq k0{k1},zmm0,zmm1
  469784:	kortestb k0,k0
  469788:	jne    469804 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa84>
  46978a:	vpcmpequq k3{k1},zmm0,zmm2
  469791:	kortestb k3,k3
  469795:	jne    469848 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xac8>
  46979b:	cmp    QWORD PTR [rsp],0x4
  4697a0:	mov    r9d,r12d
  4697a3:	je     469871 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaf1>
  4697a9:	cmp    QWORD PTR [rsp],0x8
  4697ae:	je     469891 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb11>
  4697b4:	mov    r9d,DWORD PTR [rsp-0x28]
  4697b9:	mov    r12,QWORD PTR [rsp-0x10]
  4697be:	vmovd  xmm7,r9d
  4697c3:	vpinsrd xmm3,xmm7,DWORD PTR [rsi+0xc],0x1
  4697ca:	mov    esi,edi
  4697cc:	and    r12,QWORD PTR [rsp-0x28]
  4697d1:	shl    rsi,0x4
  4697d5:	inc    edi
  4697d7:	inc    eax
  4697d9:	add    rsi,r11
  4697dc:	shl    r12,0x4
  4697e0:	and    edi,r8d
  4697e3:	and    eax,r8d
  4697e6:	prefetcht2 BYTE PTR [r14+r12*1]
  4697eb:	mov    QWORD PTR [rsi],r10
  4697ee:	vmovq  QWORD PTR [rsi+0x8],xmm3
  4697f3:	mov    DWORD PTR [rcx+0xb0],edi
  4697f9:	mov    DWORD PTR [rcx+0xb4],eax
  4697ff:	jmp    4696f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x970>
  469804:	mov    r10d,DWORD PTR [r15]
  469807:	mov    r12d,DWORD PTR [rsi+0xc]
  46980b:	mov    rbx,r10
  46980e:	shl    r10,0x4
  469812:	add    r10,QWORD PTR [r15+0x8]
  469816:	mov    DWORD PTR [r10],r12d
  469819:	xor    r12d,r12d
  46981c:	kmovb  esi,k0
  469820:	tzcnt  r12d,esi
  469825:	inc    r12d
  469828:	movsxd rsi,r12d
  46982b:	mov    r9,QWORD PTR [r9+rsi*8]
  46982f:	inc    eax
  469831:	inc    ebx
  469833:	and    eax,r8d
  469836:	mov    QWORD PTR [r10+0x8],r9
  46983a:	mov    DWORD PTR [r15],ebx
  46983d:	mov    DWORD PTR [rcx+0xb4],eax
  469843:	jmp    4696bb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x93b>
  469848:	inc    eax
  46984a:	and    eax,r8d
  46984d:	mov    DWORD PTR [rcx+0xb4],eax
  469853:	jmp    4696bb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x93b>
  469858:	mov    eax,0xffffffff
  46985d:	crc32  rax,QWORD PTR [rdx]
  469863:	mov    QWORD PTR [rsp-0x18],rax
  469868:	vmovd  xmm4,eax
  46986c:	jmp    46965c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8dc>
  469871:	mov    r9d,0xffffffff
  469877:	crc32  r9d,r12d
  46987d:	mov    r12d,r9d
  469880:	mov    QWORD PTR [rsp-0x28],r12
  469885:	jmp    4697b9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa39>
  46988a:	xor    edi,edi
  46988c:	jmp    4691ae <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x42e>
  469891:	mov    r12d,0xffffffff
  469897:	crc32  r12,r9
  46989d:	mov    QWORD PTR [rsp-0x28],r12
  4698a2:	mov    r9d,r12d
  4698a5:	jmp    4697b9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa39>
  4698aa:	inc    DWORD PTR [rsp-0x28]
  4698ae:	jmp    468f21 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a1>
  4698b3:	inc    DWORD PTR [rsp-0x28]
  4698b7:	vpxor  xmm15,xmm15,xmm15
  4698bc:	xor    r11d,r11d
  4698bf:	vpxor  xmm12,xmm12,xmm12
  4698c4:	jmp    468eaa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x12a>
  4698c9:	inc    DWORD PTR [rsp-0x28]
  4698cd:	jmp    468f99 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x219>
