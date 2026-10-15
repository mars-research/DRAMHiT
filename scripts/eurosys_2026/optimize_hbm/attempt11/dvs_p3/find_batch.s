0000000000468de0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468de0:	push   rbp
  468de1:	mov    rcx,rdi
  468de4:	mov    rbp,rsp
  468de7:	push   r15
  468de9:	mov    r15,rdx
  468dec:	push   r14
  468dee:	push   r13
  468df0:	push   r12
  468df2:	push   rbx
  468df3:	and    rsp,0xffffffffffffffc0
  468df7:	sub    rsp,0x8
  468dfb:	mov    r11,QWORD PTR [rsi+0x8]
  468dff:	mov    edi,DWORD PTR [rdi+0xb0]
  468e05:	mov    eax,DWORD PTR [rcx+0xb4]
  468e0b:	mov    rdx,QWORD PTR [rsi]
  468e0e:	mov    r8d,DWORD PTR [rcx+0x78]
  468e12:	mov    r9d,DWORD PTR [rcx+0x6c]
  468e16:	mov    r10,r11
  468e19:	mov    esi,edi
  468e1b:	shl    r10,0x4
  468e1f:	sub    esi,eax
  468e21:	lea    rbx,[rdx+r10*1]
  468e25:	and    esi,r8d
  468e28:	lea    r12d,[r9-0x1]
  468e2c:	mov    QWORD PTR [rsp-0x20],rbx
  468e31:	cmp    esi,r12d
  468e34:	jb     46969c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8bc>
  468e3a:	and    r11,0xfffffffffffffffc
  468e3e:	shl    r9,0x4
  468e42:	shl    r11,0x4
  468e46:	mov    r14,QWORD PTR [r15+0x8]
  468e4a:	mov    esi,DWORD PTR [rcx+0x80]
  468e50:	mov    QWORD PTR [rsp-0x18],r9
  468e55:	mov    QWORD PTR [rsp-0x38],r11
  468e5a:	lea    r10,[r9-0x1]
  468e5e:	lea    r11,[rdx+r11*1]
  468e62:	mov    r9d,edi
  468e65:	mov    QWORD PTR [rsp],r14
  468e69:	mov    QWORD PTR [rsp-0x28],r11
  468e6e:	mov    DWORD PTR [rsp-0x2c],0x0
  468e76:	mov    r8,QWORD PTR [rcx+0xa0]
  468e7d:	mov    rdi,QWORD PTR [rip+0x29d64]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468e84:	shl    rax,0x4
  468e88:	shl    r9,0x4
  468e8c:	not    esi
  468e8e:	cmp    rdx,r11
  468e91:	je     46993a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb5a>
  468e97:	mov    r13d,0x55
  468e9d:	mov    ebx,0xf
  468ea2:	mov    r12d,0xf0
  468ea8:	mov    r11d,0xf00
  468eae:	kmovb  k2,r13d
  468eb3:	mov    r13d,0xfffff000
  468eb9:	mov    QWORD PTR [rsp-0x40],rcx
  468ebe:	mov    QWORD PTR [rsp-0x48],r15
  468ec3:	vpxor  xmm4,xmm4,xmm4
  468ec7:	mov    r14d,0xffffffff
  468ecd:	kmovw  k6,ebx
  468ed1:	kmovw  k5,r12d
  468ed6:	kmovw  k4,r11d
  468edb:	kmovw  k3,r13d
  468ee0:	jmp    469139 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  468ee5:	nop    DWORD PTR [rax]
  468ee8:	vmovd  xmm13,DWORD PTR [r12+0xc]
  468eef:	kshiftlb k7,k7,0x1
  468ef5:	vpcompressq zmm12{k7}{z},zmm8
  468efb:	vpunpcklqdq xmm14,xmm13,xmm12
  468f00:	vshufi32x4 zmm15{k6}{z},zmm14,zmm14,0x0
  468f07:	vmovdqa64 zmm12,zmm15
  468f0d:	mov    r11d,0x1
  468f13:	lea    r13,[r8+rax*1]
  468f17:	lea    r12,[rax+0x180]
  468f1e:	and    r12,r10
  468f21:	mov    r15d,DWORD PTR [r13+0x8]
  468f25:	andn   ecx,esi,DWORD PTR [r8+r12*1+0x8]
  468f2c:	shl    rcx,0x4
  468f30:	andn   r12d,esi,r15d
  468f35:	shl    r12,0x4
  468f39:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r12*1]
  468f40:	vpbroadcastq zmm2,QWORD PTR [r13+0x0]
  468f47:	vpcmpequq k0{k2},zmm0,zmm2
  468f4e:	add    rax,0x10
  468f52:	and    rax,r10
  468f55:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468f59:	kortestb k0,k0
  468f5d:	je     4695b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
  468f63:	vmovd  xmm1,DWORD PTR [r13+0xc]
  468f69:	kshiftlb k7,k0,0x1
  468f6f:	vpcompressq zmm6{k7}{z},zmm0
  468f75:	vpunpcklqdq xmm7,xmm1,xmm6
  468f79:	vshufi32x4 zmm15{k5},zmm7,zmm7,0x0
  468f80:	vmovdqa64 zmm12,zmm15
  468f86:	or     r11d,0x2
  468f8a:	lea    r13,[rax+0x180]
  468f91:	and    r13,r10
  468f94:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  468f9b:	shl    rcx,0x4
  468f9f:	lea    r13,[r8+rax*1]
  468fa3:	mov    ebx,DWORD PTR [r13+0x8]
  468fa7:	andn   r12d,esi,ebx
  468fac:	shl    r12,0x4
  468fb0:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r12*1]
  468fb7:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  468fbe:	vpcmpequq k0{k2},zmm8,zmm9
  468fc5:	add    rax,0x10
  468fc9:	and    rax,r10
  468fcc:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468fd0:	kortestb k0,k0
  468fd4:	je     469560 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x780>
  468fda:	vmovd  xmm13,DWORD PTR [r13+0xc]
  468fe0:	kshiftlb k7,k0,0x1
  468fe6:	vpcompressq zmm12{k7}{z},zmm8
  468fec:	vpunpcklqdq xmm14,xmm13,xmm12
  468ff1:	vshufi32x4 zmm15{k4},zmm14,zmm14,0x0
  468ff8:	vmovdqa64 zmm12,zmm15
  468ffe:	or     r11d,0x4
  469002:	lea    r15,[r8+rax*1]
  469006:	lea    r13,[rax+0x180]
  46900d:	and    r13,r10
  469010:	mov    r12d,DWORD PTR [r15+0x8]
  469014:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  46901b:	shl    rcx,0x4
  46901f:	andn   r13d,esi,r12d
  469024:	shl    r13,0x4
  469028:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r13*1]
  46902f:	vpbroadcastq zmm2,QWORD PTR [r15]
  469035:	vpcmpequq k0{k2},zmm0,zmm2
  46903c:	add    rax,0x10
  469040:	and    rax,r10
  469043:	prefetcht0 BYTE PTR [rdi+rcx*1]
  469047:	kortestb k0,k0
  46904b:	lea    rcx,[r8+r9*1]
  46904f:	je     469518 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
  469055:	vmovd  xmm1,DWORD PTR [r15+0xc]
  46905b:	kshiftlb k7,k0,0x1
  469061:	vpcompressq zmm6{k7}{z},zmm0
  469067:	vpunpcklqdq xmm7,xmm1,xmm6
  46906b:	vshufi32x4 zmm15{k3},zmm7,zmm7,0x0
  469072:	or     r11d,0x8
  469076:	vmovdqa64 zmm12,zmm15
  46907c:	cmp    r11d,0xf
  469080:	jne    469668 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x888>
  469086:	mov    r15,QWORD PTR [rsp]
  46908a:	vmovdqu64 ZMMWORD PTR [r15],zmm15
  469090:	add    r15,0x40
  469094:	mov    QWORD PTR [rsp],r15
  469098:	mov    rbx,r14
  46909b:	mov    r11,r14
  46909e:	crc32  rbx,QWORD PTR [rdx]
  4690a4:	crc32  r11,QWORD PTR [rdx+0x20]
  4690ab:	andn   r13d,esi,ebx
  4690b0:	shl    r13,0x4
  4690b4:	andn   r15d,esi,r11d
  4690b9:	shl    r15,0x4
  4690bd:	prefetcht2 BYTE PTR [rdi+r13*1]
  4690c2:	prefetcht2 BYTE PTR [rdi+r15*1]
  4690c7:	mov    r13,r14
  4690ca:	mov    r15,r14
  4690cd:	crc32  r13,QWORD PTR [rdx+0x10]
  4690d4:	crc32  r15,QWORD PTR [rdx+0x30]
  4690db:	andn   r12d,esi,r13d
  4690e0:	shl    r12,0x4
  4690e4:	prefetcht2 BYTE PTR [rdi+r12*1]
  4690e9:	andn   r12d,esi,r15d
  4690ee:	shl    r12,0x4
  4690f2:	prefetcht2 BYTE PTR [rdi+r12*1]
  4690f7:	lea    r12,[r9+0x40]
  4690fb:	vmovdqu64 zmm15,ZMMWORD PTR [rdx]
  469101:	cmp    QWORD PTR [rsp-0x18],r12
  469106:	jb     4695f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x818>
  46910c:	vmovdqu64 ZMMWORD PTR [rcx],zmm15
  469112:	mov    DWORD PTR [rcx+0x8],ebx
  469115:	mov    DWORD PTR [r8+r9*1+0x18],r13d
  46911a:	mov    DWORD PTR [r8+r9*1+0x28],r11d
  46911f:	mov    DWORD PTR [r8+r9*1+0x38],r15d
  469124:	mov    r9,r12
  469127:	add    rdx,0x40
  46912b:	and    r9,r10
  46912e:	cmp    QWORD PTR [rsp-0x28],rdx
  469133:	je     4691d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3f8>
  469139:	lea    r12,[r8+rax*1]
  46913d:	mov    r11d,DWORD PTR [r12+0x8]
  469142:	andn   r13d,esi,r11d
  469147:	shl    r13,0x4
  46914b:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r13*1]
  469152:	vpbroadcastq zmm9,QWORD PTR [r12]
  469159:	vpcmpequq k7{k2},zmm8,zmm9
  469160:	lea    rcx,[rax+0x180]
  469167:	add    rax,0x10
  46916b:	and    rcx,r10
  46916e:	and    rax,r10
  469171:	andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
  469178:	shl    r15,0x4
  46917c:	kortestb k7,k7
  469180:	prefetcht0 BYTE PTR [rdi+r15*1]
  469185:	jne    468ee8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
  46918b:	vpcmpequq k1{k2},zmm8,zmm4
  469192:	kortestb k1,k1
  469196:	jne    469963 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb83>
  46919c:	vmovdqu xmm10,XMMWORD PTR [r12]
  4691a2:	mov    rcx,r14
  4691a5:	crc32  rcx,r11
  4691ab:	vpinsrd xmm11,xmm10,ecx,0x2
  4691b1:	andn   r15d,esi,ecx
  4691b6:	shl    r15,0x4
  4691ba:	prefetcht2 BYTE PTR [rdi+r15*1]
  4691bf:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  4691c5:	add    r9,0x10
  4691c9:	and    r9,r10
  4691cc:	jmp    469139 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  4691d1:	nop    DWORD PTR [rax+0x0]
  4691d8:	mov    rcx,QWORD PTR [rsp-0x40]
  4691dd:	mov    r15,QWORD PTR [rsp-0x48]
  4691e2:	mov    edi,DWORD PTR [rsp-0x2c]
  4691e6:	vmovq  xmm14,r9
  4691eb:	vpinsrq xmm0,xmm14,rax,0x1
  4691f1:	mov    rsi,QWORD PTR [rsp-0x38]
  4691f6:	vpsrlq xmm2,xmm0,0x4
  4691fb:	vpmovqd xmm3,xmm2
  469201:	sar    rsi,0x4
  469205:	vmovq  QWORD PTR [rcx+0xb0],xmm3
  46920d:	sub    rsi,rdi
  469210:	add    DWORD PTR [r15],esi
  469213:	vpextrd eax,xmm3,0x1
  469219:	cmp    rdx,QWORD PTR [rsp-0x20]
  46921e:	je     469500 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  469224:	mov    rdi,QWORD PTR [rcx+0x88]
  46922b:	mov    rbx,QWORD PTR [rcx+0x80]
  469232:	mov    r8,QWORD PTR [rcx+0x60]
  469236:	dec    rdi
  469239:	mov    QWORD PTR [rsp-0x18],rbx
  46923e:	mov    QWORD PTR [rsp],r8
  469242:	mov    QWORD PTR [rsp-0x28],rdi
  469247:	mov    r10d,DWORD PTR [rcx+0x78]
  46924b:	mov    r11,QWORD PTR [rip+0x29996]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469252:	mov    r9,QWORD PTR [rcx+0xa0]
  469259:	movzx  r13d,BYTE PTR [rip+0x2989f]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469261:	mov    r12,QWORD PTR [rip+0x298a0]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469268:	mov    r14d,0x55
  46926e:	vpxor  xmm7,xmm7,xmm7
  469272:	kmovb  k2,r14d
  469277:	nop    WORD PTR [rax+rax*1+0x0]
  469280:	lea    esi,[rax+0x18]
  469283:	and    esi,r10d
  469286:	shl    rsi,0x4
  46928a:	mov    r8d,ebx
  46928d:	and    r8d,DWORD PTR [r9+rsi*1+0x8]
  469292:	mov    esi,eax
  469294:	shl    rsi,0x4
  469298:	add    rsi,r9
  46929b:	mov    r14,r8
  46929e:	mov    r8,QWORD PTR [rsi]
  4692a1:	shl    r14,0x4
  4692a5:	prefetcht0 BYTE PTR [r11+r14*1]
  4692aa:	cmp    r8,QWORD PTR [rcx+0x90]
  4692b1:	jne    469370 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x590>
  4692b7:	test   r13b,r13b
  4692ba:	je     4692da <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fa>
  4692bc:	mov    r14d,DWORD PTR [r15]
  4692bf:	mov    esi,DWORD PTR [rsi+0xc]
  4692c2:	mov    r8,r14
  4692c5:	shl    r14,0x4
  4692c9:	add    r14,QWORD PTR [r15+0x8]
  4692cd:	inc    r8d
  4692d0:	mov    DWORD PTR [r14],esi
  4692d3:	mov    QWORD PTR [r14+0x8],r12
  4692d7:	mov    DWORD PTR [r15],r8d
  4692da:	inc    eax
  4692dc:	and    eax,r10d
  4692df:	mov    DWORD PTR [rcx+0xb4],eax
  4692e5:	test   r12,r12
  4692e8:	jne    469280 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  4692ea:	cmp    QWORD PTR [rsp],0x4
  4692ef:	je     469465 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x685>
  4692f5:	nop    DWORD PTR [rax]
  4692f8:	cmp    QWORD PTR [rsp],0x8
  4692fd:	je     4694e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
  469303:	vmovd  xmm15,DWORD PTR [rsp-0x10]
  469309:	mov    rdi,QWORD PTR [rdx]
  46930c:	mov    esi,DWORD PTR [rcx+0xb0]
  469312:	mov    r8,QWORD PTR [rsp-0x28]
  469317:	mov    rax,rsi
  46931a:	and    r8,QWORD PTR [rsp-0x10]
  46931f:	vpinsrd xmm9,xmm15,DWORD PTR [rdx+0xc],0x1
  469326:	and    r8,0xfffffffffffffffc
  46932a:	shl    rsi,0x4
  46932e:	inc    eax
  469330:	add    rsi,r9
  469333:	shl    r8,0x4
  469337:	and    eax,r10d
  46933a:	add    rdx,0x10
  46933e:	prefetcht2 BYTE PTR [r11+r8*1]
  469343:	mov    QWORD PTR [rsi],rdi
  469346:	vmovq  QWORD PTR [rsi+0x8],xmm9
  46934b:	mov    DWORD PTR [rcx+0xb0],eax
  469351:	cmp    rdx,QWORD PTR [rsp-0x20]
  469356:	je     469500 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  46935c:	mov    eax,DWORD PTR [rcx+0xb4]
  469362:	jmp    469280 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  469367:	nop    WORD PTR [rax+rax*1+0x0]
  469370:	mov    r14d,DWORD PTR [rsi+0x8]
  469374:	mov    edi,ebx
  469376:	and    edi,r14d
  469379:	shl    rdi,0x4
  46937d:	add    rdi,r11
  469380:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  469386:	vpbroadcastq zmm6,r8
  46938c:	vpcmpequq k0{k2},zmm5,zmm6
  469393:	kortestb k0,k0
  469397:	jne    469420 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x640>
  46939d:	vpcmpequq k3{k2},zmm5,zmm7
  4693a4:	kortestb k3,k3
  4693a8:	jne    469490 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  4693ae:	cmp    QWORD PTR [rsp],0x4
  4693b3:	mov    edi,r14d
  4693b6:	je     4694a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  4693bc:	cmp    QWORD PTR [rsp],0x8
  4693c1:	je     4694c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
  4693c7:	vmovd  xmm1,DWORD PTR [rsp-0x8]
  4693cd:	mov    edi,DWORD PTR [rcx+0xb0]
  4693d3:	mov    r14,QWORD PTR [rsp-0x18]
  4693d8:	vpinsrd xmm4,xmm1,DWORD PTR [rsi+0xc],0x1
  4693df:	mov    rsi,rdi
  4693e2:	and    r14,QWORD PTR [rsp-0x8]
  4693e7:	shl    rdi,0x4
  4693eb:	inc    esi
  4693ed:	inc    eax
  4693ef:	add    rdi,r9
  4693f2:	shl    r14,0x4
  4693f6:	and    esi,r10d
  4693f9:	and    eax,r10d
  4693fc:	prefetcht2 BYTE PTR [r11+r14*1]
  469401:	mov    QWORD PTR [rdi],r8
  469404:	vmovq  QWORD PTR [rdi+0x8],xmm4
  469409:	mov    DWORD PTR [rcx+0xb0],esi
  46940f:	mov    DWORD PTR [rcx+0xb4],eax
  469415:	jmp    469280 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  46941a:	nop    WORD PTR [rax+rax*1+0x0]
  469420:	mov    r8d,DWORD PTR [r15]
  469423:	mov    esi,DWORD PTR [rsi+0xc]
  469426:	mov    r14,r8
  469429:	shl    r8,0x4
  46942d:	add    r8,QWORD PTR [r15+0x8]
  469431:	mov    DWORD PTR [r8],esi
  469434:	kmovb  esi,k0
  469438:	tzcnt  esi,esi
  46943c:	inc    esi
  46943e:	movsxd rsi,esi
  469441:	mov    rdi,QWORD PTR [rdi+rsi*8]
  469445:	inc    eax
  469447:	inc    r14d
  46944a:	and    eax,r10d
  46944d:	cmp    QWORD PTR [rsp],0x4
  469452:	mov    QWORD PTR [r8+0x8],rdi
  469456:	mov    DWORD PTR [r15],r14d
  469459:	mov    DWORD PTR [rcx+0xb4],eax
  46945f:	jne    4692f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x518>
  469465:	mov    r14d,0xffffffff
  46946b:	crc32  r14d,DWORD PTR [rdx]
  469471:	vmovd  xmm8,r14d
  469476:	mov    rdi,QWORD PTR [rdx]
  469479:	vmovdqa xmm15,xmm8
  46947e:	vmovq  QWORD PTR [rsp-0x10],xmm8
  469484:	jmp    46930c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  469489:	nop    DWORD PTR [rax+0x0]
  469490:	inc    eax
  469492:	and    eax,r10d
  469495:	mov    DWORD PTR [rcx+0xb4],eax
  46949b:	jmp    4692ea <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
  4694a0:	mov    edi,0xffffffff
  4694a5:	crc32  edi,r14d
  4694ab:	vmovd  xmm12,edi
  4694af:	vmovdqa xmm1,xmm12
  4694b3:	vmovq  QWORD PTR [rsp-0x8],xmm12
  4694b9:	jmp    4693cd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  4694be:	xchg   ax,ax
  4694c0:	mov    r14d,0xffffffff
  4694c6:	crc32  r14,rdi
  4694cc:	mov    QWORD PTR [rsp-0x8],r14
  4694d1:	vmovd  xmm1,r14d
  4694d6:	jmp    4693cd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  4694db:	nop    DWORD PTR [rax+rax*1+0x0]
  4694e0:	mov    rdi,QWORD PTR [rdx]
  4694e3:	mov    eax,0xffffffff
  4694e8:	crc32  rax,rdi
  4694ee:	mov    QWORD PTR [rsp-0x10],rax
  4694f3:	vmovd  xmm15,eax
  4694f7:	jmp    46930c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  4694fc:	nop    DWORD PTR [rax+0x0]
  469500:	vzeroupper 
  469503:	lea    rsp,[rbp-0x28]
  469507:	pop    rbx
  469508:	pop    r12
  46950a:	pop    r13
  46950c:	pop    r14
  46950e:	pop    r15
  469510:	pop    rbp
  469511:	ret    
  469512:	nop    WORD PTR [rax+rax*1+0x0]
  469518:	vpcmpequq k1{k2},zmm0,zmm4
  46951f:	kortestb k1,k1
  469523:	jne    469660 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x880>
  469529:	vmovdqu xmm3,XMMWORD PTR [r15]
  46952e:	mov    rbx,r14
  469531:	crc32  rbx,r12
  469537:	vpinsrd xmm5,xmm3,ebx,0x2
  46953d:	add    r9,0x10
  469541:	andn   r12d,esi,ebx
  469546:	shl    r12,0x4
  46954a:	and    r9,r10
  46954d:	prefetcht2 BYTE PTR [rdi+r12*1]
  469552:	vmovdqu XMMWORD PTR [rcx],xmm5
  469556:	jmp    469002 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
  46955b:	nop    DWORD PTR [rax+rax*1+0x0]
  469560:	vpcmpequq k1{k2},zmm8,zmm4
  469567:	kortestb k1,k1
  46956b:	jne    469979 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb99>
  469571:	vmovdqu xmm10,XMMWORD PTR [r13+0x0]
  469577:	mov    rcx,r14
  46957a:	crc32  rcx,rbx
  469580:	vpinsrd xmm11,xmm10,ecx,0x2
  469586:	andn   r15d,esi,ecx
  46958b:	shl    r15,0x4
  46958f:	prefetcht2 BYTE PTR [rdi+r15*1]
  469594:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  46959a:	add    r9,0x10
  46959e:	and    r9,r10
  4695a1:	jmp    468f8a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  4695a6:	cs nop WORD PTR [rax+rax*1+0x0]
  4695b0:	vpcmpequq k1{k2},zmm0,zmm4
  4695b7:	kortestb k1,k1
  4695bb:	jne    46995a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb7a>
  4695c1:	vmovdqu xmm3,XMMWORD PTR [r13+0x0]
  4695c7:	mov    rcx,r14
  4695ca:	crc32  rcx,r15
  4695d0:	vpinsrd xmm5,xmm3,ecx,0x2
  4695d6:	andn   ebx,esi,ecx
  4695db:	shl    rbx,0x4
  4695df:	prefetcht2 BYTE PTR [rdi+rbx*1]
  4695e3:	vmovdqu XMMWORD PTR [r8+r9*1],xmm5
  4695e9:	add    r9,0x10
  4695ed:	and    r9,r10
  4695f0:	jmp    468f13 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  4695f5:	nop    DWORD PTR [rax]
  4695f8:	vmovd  xmm10,ebx
  4695fc:	vpinsrd xmm11,xmm10,r13d,0x1
  469602:	mov    r13,QWORD PTR [rsp-0x18]
  469607:	vmovd  xmm8,r11d
  46960c:	mov    r11,r13
  46960f:	vpinsrd xmm9,xmm8,r15d,0x1
  469615:	sub    r11,r9
  469618:	mov    ebx,0x4444
  46961d:	vpunpcklqdq xmm13,xmm11,xmm9
  469622:	shr    r11,0x2
  469626:	mov    r15d,0x1
  46962c:	kmovw  k7,ebx
  469630:	shlx   r11d,r15d,r11d
  469635:	vpexpandd zmm15{k7},zmm13
  46963b:	lea    ebx,[r11-0x1]
  46963f:	sub    r9,r13
  469642:	neg    r11d
  469645:	kmovw  k1,ebx
  469649:	vmovdqu32 ZMMWORD PTR [rcx]{k1},zmm15
  46964f:	kmovw  k7,r11d
  469654:	vmovdqu32 ZMMWORD PTR [r8+r9*1]{k7},zmm15
  46965b:	jmp    469124 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x344>
  469660:	inc    DWORD PTR [rsp-0x2c]
  469664:	nop    DWORD PTR [rax+0x0]
  469668:	mov    r12,QWORD PTR [rsp]
  46966c:	mov    r15d,0x55
  469672:	pdep   r13d,r11d,r15d
  469677:	popcnt r11d,r11d
  46967c:	lea    ebx,[r13+r13*2+0x0]
  469681:	shl    r11,0x4
  469685:	kmovb  k1,ebx
  469689:	vpcompressq ZMMWORD PTR [r12]{k1},zmm12
  469690:	add    r12,r11
  469693:	mov    QWORD PTR [rsp],r12
  469697:	jmp    469098 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b8>
  46969c:	cmp    rdx,QWORD PTR [rsp-0x20]
  4696a1:	je     469503 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x723>
  4696a7:	mov    r12,QWORD PTR [rcx+0x88]
  4696ae:	movzx  r13d,BYTE PTR [rip+0x2944a]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4696b6:	mov    r9,QWORD PTR [rip+0x2944b]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4696bd:	mov    r10,QWORD PTR [rcx+0x60]
  4696c1:	mov    ebx,0x55
  4696c6:	dec    r12
  4696c9:	kmovb  k2,r13d
  4696ce:	mov    QWORD PTR [rsp],r10
  4696d2:	mov    QWORD PTR [rsp-0x8],r12
  4696d7:	mov    r14,QWORD PTR [rip+0x2950a]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4696de:	mov    r11,QWORD PTR [rcx+0xa0]
  4696e5:	mov    esi,edi
  4696e7:	vpxor  xmm2,xmm2,xmm2
  4696eb:	mov    r13,r9
  4696ee:	kmovb  k1,ebx
  4696f2:	jmp    46975a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x97a>
  4696f4:	cmp    QWORD PTR [rsp],0x8
  4696f9:	je     469908 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb28>
  4696ff:	vmovd  xmm5,DWORD PTR [rsp-0x18]
  469705:	mov    r12,QWORD PTR [rsp-0x8]
  46970a:	mov    esi,edi
  46970c:	and    r12,QWORD PTR [rsp-0x18]
  469711:	vpinsrd xmm7,xmm5,DWORD PTR [rdx+0xc],0x1
  469718:	mov    r10,QWORD PTR [rdx]
  46971b:	and    r12,0xfffffffffffffffc
  46971f:	shl    rsi,0x4
  469723:	add    rsi,r11
  469726:	shl    r12,0x4
  46972a:	prefetcht2 BYTE PTR [r14+r12*1]
  46972f:	mov    QWORD PTR [rsi],r10
  469732:	vmovq  QWORD PTR [rsi+0x8],xmm7
  469737:	lea    esi,[rdi+0x1]
  46973a:	and    esi,r8d
  46973d:	add    rdx,0x10
  469741:	mov    DWORD PTR [rcx+0xb0],esi
  469747:	cmp    QWORD PTR [rsp-0x20],rdx
  46974c:	je     469500 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  469752:	mov    eax,DWORD PTR [rcx+0xb4]
  469758:	mov    edi,esi
  46975a:	sub    esi,eax
  46975c:	and    esi,r8d
  46975f:	cmp    r8d,esi
  469762:	jbe    469785 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a5>
  469764:	cmp    QWORD PTR [rsp],0x4
  469769:	jne    4696f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x914>
  46976b:	mov    ebx,0xffffffff
  469770:	crc32  ebx,DWORD PTR [rdx]
  469775:	vmovd  xmm6,ebx
  469779:	vmovdqa xmm5,xmm6
  46977d:	vmovq  QWORD PTR [rsp-0x18],xmm6
  469783:	jmp    469705 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  469785:	mov    rbx,QWORD PTR [rcx+0x80]
  46978c:	mov    QWORD PTR [rsp-0x10],rbx
  469791:	nop    DWORD PTR [rax+0x0]
  469798:	lea    esi,[rax+0x18]
  46979b:	and    esi,r8d
  46979e:	shl    rsi,0x4
  4697a2:	mov    r9d,ebx
  4697a5:	and    r9d,DWORD PTR [r11+rsi*1+0x8]
  4697aa:	mov    esi,eax
  4697ac:	mov    r10,r9
  4697af:	shl    rsi,0x4
  4697b3:	shl    r10,0x4
  4697b7:	add    rsi,r11
  4697ba:	prefetcht0 BYTE PTR [r14+r10*1]
  4697bf:	mov    r10,QWORD PTR [rsi]
  4697c2:	cmp    r10,QWORD PTR [rcx+0x90]
  4697c9:	jne    469810 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa30>
  4697cb:	kortestb k2,k2
  4697cf:	je     4697f2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa12>
  4697d1:	mov    r12d,DWORD PTR [r15]
  4697d4:	mov    esi,DWORD PTR [rsi+0xc]
  4697d7:	mov    r10,r12
  4697da:	shl    r12,0x4
  4697de:	add    r12,QWORD PTR [r15+0x8]
  4697e2:	lea    r9d,[r10+0x1]
  4697e6:	mov    DWORD PTR [r12],esi
  4697ea:	mov    QWORD PTR [r12+0x8],r13
  4697ef:	mov    DWORD PTR [r15],r9d
  4697f2:	inc    eax
  4697f4:	and    eax,r8d
  4697f7:	mov    DWORD PTR [rcx+0xb4],eax
  4697fd:	test   r13,r13
  469800:	jne    469798 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  469802:	jmp    469764 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  469807:	nop    WORD PTR [rax+rax*1+0x0]
  469810:	mov    r12d,DWORD PTR [rsi+0x8]
  469814:	mov    r9d,ebx
  469817:	and    r9d,r12d
  46981a:	shl    r9,0x4
  46981e:	add    r9,r14
  469821:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  469827:	vpbroadcastq zmm1,r10
  46982d:	vpcmpequq k0{k1},zmm0,zmm1
  469834:	kortestb k0,k0
  469838:	jne    4698b4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad4>
  46983a:	vpcmpequq k3{k1},zmm0,zmm2
  469841:	kortestb k3,k3
  469845:	jne    4698f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb18>
  46984b:	cmp    QWORD PTR [rsp],0x4
  469850:	mov    r9d,r12d
  469853:	je     469921 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb41>
  469859:	cmp    QWORD PTR [rsp],0x8
  46985e:	je     469941 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb61>
  469864:	mov    r9d,DWORD PTR [rsp-0x28]
  469869:	mov    r12,QWORD PTR [rsp-0x10]
  46986e:	vmovd  xmm4,r9d
  469873:	vpinsrd xmm3,xmm4,DWORD PTR [rsi+0xc],0x1
  46987a:	mov    esi,edi
  46987c:	and    r12,QWORD PTR [rsp-0x28]
  469881:	shl    rsi,0x4
  469885:	inc    edi
  469887:	inc    eax
  469889:	add    rsi,r11
  46988c:	shl    r12,0x4
  469890:	and    edi,r8d
  469893:	and    eax,r8d
  469896:	prefetcht2 BYTE PTR [r14+r12*1]
  46989b:	mov    QWORD PTR [rsi],r10
  46989e:	vmovq  QWORD PTR [rsi+0x8],xmm3
  4698a3:	mov    DWORD PTR [rcx+0xb0],edi
  4698a9:	mov    DWORD PTR [rcx+0xb4],eax
  4698af:	jmp    469798 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  4698b4:	mov    r10d,DWORD PTR [r15]
  4698b7:	mov    r12d,DWORD PTR [rsi+0xc]
  4698bb:	mov    rbx,r10
  4698be:	shl    r10,0x4
  4698c2:	add    r10,QWORD PTR [r15+0x8]
  4698c6:	mov    DWORD PTR [r10],r12d
  4698c9:	xor    r12d,r12d
  4698cc:	kmovb  esi,k0
  4698d0:	tzcnt  r12d,esi
  4698d5:	inc    r12d
  4698d8:	movsxd rsi,r12d
  4698db:	mov    r9,QWORD PTR [r9+rsi*8]
  4698df:	inc    eax
  4698e1:	inc    ebx
  4698e3:	and    eax,r8d
  4698e6:	mov    QWORD PTR [r10+0x8],r9
  4698ea:	mov    DWORD PTR [r15],ebx
  4698ed:	mov    DWORD PTR [rcx+0xb4],eax
  4698f3:	jmp    469764 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  4698f8:	inc    eax
  4698fa:	and    eax,r8d
  4698fd:	mov    DWORD PTR [rcx+0xb4],eax
  469903:	jmp    469764 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  469908:	mov    eax,0xffffffff
  46990d:	crc32  rax,QWORD PTR [rdx]
  469913:	mov    QWORD PTR [rsp-0x18],rax
  469918:	vmovd  xmm5,eax
  46991c:	jmp    469705 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  469921:	mov    r9d,0xffffffff
  469927:	crc32  r9d,r12d
  46992d:	mov    r12d,r9d
  469930:	mov    QWORD PTR [rsp-0x28],r12
  469935:	jmp    469869 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  46993a:	xor    edi,edi
  46993c:	jmp    4691e6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x406>
  469941:	mov    r12d,0xffffffff
  469947:	crc32  r12,r9
  46994d:	mov    QWORD PTR [rsp-0x28],r12
  469952:	mov    r9d,r12d
  469955:	jmp    469869 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  46995a:	inc    DWORD PTR [rsp-0x2c]
  46995e:	jmp    468f8a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469963:	inc    DWORD PTR [rsp-0x2c]
  469967:	vpxor  xmm15,xmm15,xmm15
  46996c:	xor    r11d,r11d
  46996f:	vpxor  xmm12,xmm12,xmm12
  469974:	jmp    468f13 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  469979:	inc    DWORD PTR [rsp-0x2c]
  46997d:	jmp    469002 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
