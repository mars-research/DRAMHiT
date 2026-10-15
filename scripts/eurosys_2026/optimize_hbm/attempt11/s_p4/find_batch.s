0000000000468e00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468e00:	push   rbp
  468e01:	mov    rcx,rdi
  468e04:	mov    rbp,rsp
  468e07:	push   r15
  468e09:	mov    r15,rdx
  468e0c:	push   r14
  468e0e:	push   r13
  468e10:	push   r12
  468e12:	push   rbx
  468e13:	and    rsp,0xffffffffffffffc0
  468e17:	sub    rsp,0x8
  468e1b:	mov    r11,QWORD PTR [rsi+0x8]
  468e1f:	mov    edi,DWORD PTR [rdi+0xb0]
  468e25:	mov    eax,DWORD PTR [rcx+0xb4]
  468e2b:	mov    rdx,QWORD PTR [rsi]
  468e2e:	mov    r8d,DWORD PTR [rcx+0x78]
  468e32:	mov    r9d,DWORD PTR [rcx+0x6c]
  468e36:	mov    r10,r11
  468e39:	mov    esi,edi
  468e3b:	shl    r10,0x4
  468e3f:	sub    esi,eax
  468e41:	lea    rbx,[rdx+r10*1]
  468e45:	and    esi,r8d
  468e48:	lea    r12d,[r9-0x1]
  468e4c:	mov    QWORD PTR [rsp-0x20],rbx
  468e51:	cmp    esi,r12d
  468e54:	jb     4696d3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8d3>
  468e5a:	and    r11,0xfffffffffffffffc
  468e5e:	shl    r9,0x4
  468e62:	shl    r11,0x4
  468e66:	mov    r14,QWORD PTR [r15+0x8]
  468e6a:	mov    esi,DWORD PTR [rcx+0x80]
  468e70:	mov    QWORD PTR [rsp-0x18],r9
  468e75:	mov    QWORD PTR [rsp-0x38],r11
  468e7a:	lea    r10,[r9-0x1]
  468e7e:	lea    r11,[rdx+r11*1]
  468e82:	mov    r9d,edi
  468e85:	mov    QWORD PTR [rsp],r14
  468e89:	mov    QWORD PTR [rsp-0x28],r11
  468e8e:	mov    DWORD PTR [rsp-0x2c],0x0
  468e96:	mov    r8,QWORD PTR [rcx+0xa0]
  468e9d:	mov    rdi,QWORD PTR [rip+0x29d44]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468ea4:	shl    rax,0x4
  468ea8:	shl    r9,0x4
  468eac:	not    esi
  468eae:	cmp    rdx,r11
  468eb1:	je     46996a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb6a>
  468eb7:	mov    r13d,0x55
  468ebd:	mov    ebx,0xf
  468ec2:	mov    r12d,0xf0
  468ec8:	mov    r11d,0xf00
  468ece:	kmovb  k2,r13d
  468ed3:	mov    r13d,0xfffff000
  468ed9:	mov    QWORD PTR [rsp-0x40],rcx
  468ede:	mov    QWORD PTR [rsp-0x48],r15
  468ee3:	vpxor  xmm4,xmm4,xmm4
  468ee7:	mov    r14d,0xffffffff
  468eed:	kmovw  k6,ebx
  468ef1:	kmovw  k5,r12d
  468ef6:	kmovw  k4,r11d
  468efb:	kmovw  k3,r13d
  468f00:	jmp    469153 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x353>
  468f05:	nop    DWORD PTR [rax]
  468f08:	vmovd  xmm13,DWORD PTR [r13+0xc]
  468f0e:	kshiftlb k7,k7,0x1
  468f14:	vpcompressq zmm12{k7}{z},zmm8
  468f1a:	vpunpcklqdq xmm14,xmm13,xmm12
  468f1f:	vshufi32x4 zmm15{k6}{z},zmm14,zmm14,0x0
  468f26:	vmovdqa64 zmm12,zmm15
  468f2c:	mov    r11d,0x1
  468f32:	lea    r12,[rax+0x180]
  468f39:	and    r12,r10
  468f3c:	andn   ecx,esi,DWORD PTR [r8+r12*1+0x8]
  468f43:	shl    rcx,0x4
  468f47:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468f4b:	lea    rcx,[r8+rax*1]
  468f4f:	mov    ebx,DWORD PTR [rcx+0x8]
  468f52:	andn   r13d,esi,ebx
  468f57:	shl    r13,0x4
  468f5b:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r13*1]
  468f62:	vpbroadcastq zmm2,QWORD PTR [rcx]
  468f68:	vpcmpequq k0{k2},zmm0,zmm2
  468f6f:	add    rax,0x10
  468f73:	and    rax,r10
  468f76:	kortestb k0,k0
  468f7a:	je     4695e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7e0>
  468f80:	vmovd  xmm1,DWORD PTR [rcx+0xc]
  468f85:	kshiftlb k7,k0,0x1
  468f8b:	vpcompressq zmm6{k7}{z},zmm0
  468f91:	vpunpcklqdq xmm7,xmm1,xmm6
  468f95:	vshufi32x4 zmm15{k5},zmm7,zmm7,0x0
  468f9c:	vmovdqa64 zmm12,zmm15
  468fa2:	or     r11d,0x2
  468fa6:	lea    r13,[rax+0x180]
  468fad:	and    r13,r10
  468fb0:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  468fb7:	shl    rcx,0x4
  468fbb:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468fbf:	lea    rcx,[r8+rax*1]
  468fc3:	mov    ebx,DWORD PTR [rcx+0x8]
  468fc6:	andn   r12d,esi,ebx
  468fcb:	shl    r12,0x4
  468fcf:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r12*1]
  468fd6:	vpbroadcastq zmm9,QWORD PTR [rcx]
  468fdc:	vpcmpequq k0{k2},zmm8,zmm9
  468fe3:	add    rax,0x10
  468fe7:	and    rax,r10
  468fea:	kortestb k0,k0
  468fee:	je     469588 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x788>
  468ff4:	vmovd  xmm13,DWORD PTR [rcx+0xc]
  468ff9:	kshiftlb k7,k0,0x1
  468fff:	vpcompressq zmm12{k7}{z},zmm8
  469005:	vpunpcklqdq xmm14,xmm13,xmm12
  46900a:	vshufi32x4 zmm15{k4},zmm14,zmm14,0x0
  469011:	vmovdqa64 zmm12,zmm15
  469017:	or     r11d,0x4
  46901b:	lea    r15,[r8+rax*1]
  46901f:	lea    r12,[rax+0x180]
  469026:	and    r12,r10
  469029:	mov    ebx,DWORD PTR [r15+0x8]
  46902d:	andn   ecx,esi,DWORD PTR [r8+r12*1+0x8]
  469034:	shl    rcx,0x4
  469038:	andn   r12d,esi,ebx
  46903d:	shl    r12,0x4
  469041:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r12*1]
  469048:	vpbroadcastq zmm2,QWORD PTR [r15]
  46904e:	vpcmpequq k0{k2},zmm0,zmm2
  469055:	add    rax,0x10
  469059:	and    rax,r10
  46905c:	prefetcht0 BYTE PTR [rdi+rcx*1]
  469060:	kortestb k0,k0
  469064:	lea    rcx,[r8+r9*1]
  469068:	je     469538 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
  46906e:	vmovd  xmm1,DWORD PTR [r15+0xc]
  469074:	kshiftlb k7,k0,0x1
  46907a:	vpcompressq zmm6{k7}{z},zmm0
  469080:	vpunpcklqdq xmm7,xmm1,xmm6
  469084:	vshufi32x4 zmm15{k3},zmm7,zmm7,0x0
  46908b:	or     r11d,0x8
  46908f:	vmovdqa64 zmm12,zmm15
  469095:	cmp    r11d,0xf
  469099:	jne    4696a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8a0>
  46909f:	mov    r12,QWORD PTR [rsp]
  4690a3:	vmovdqu64 ZMMWORD PTR [r12],zmm15
  4690aa:	add    r12,0x40
  4690ae:	mov    QWORD PTR [rsp],r12
  4690b2:	mov    rbx,r14
  4690b5:	crc32  rbx,QWORD PTR [rdx]
  4690bb:	andn   r13d,esi,ebx
  4690c0:	shl    r13,0x4
  4690c4:	prefetcht2 BYTE PTR [rdi+r13*1]
  4690c9:	mov    r13,r14
  4690cc:	crc32  r13,QWORD PTR [rdx+0x10]
  4690d3:	mov    r11,r14
  4690d6:	andn   r15d,esi,r13d
  4690db:	shl    r15,0x4
  4690df:	prefetcht2 BYTE PTR [rdi+r15*1]
  4690e4:	mov    r15,r14
  4690e7:	crc32  r11,QWORD PTR [rdx+0x20]
  4690ee:	crc32  r15,QWORD PTR [rdx+0x30]
  4690f5:	andn   r12d,esi,r11d
  4690fa:	shl    r12,0x4
  4690fe:	prefetcht2 BYTE PTR [rdi+r12*1]
  469103:	andn   r12d,esi,r15d
  469108:	shl    r12,0x4
  46910c:	prefetcht2 BYTE PTR [rdi+r12*1]
  469111:	lea    r12,[r9+0x40]
  469115:	vmovdqu64 zmm15,ZMMWORD PTR [rdx]
  46911b:	cmp    QWORD PTR [rsp-0x18],r12
  469120:	jb     469630 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x830>
  469126:	vmovdqu64 ZMMWORD PTR [rcx],zmm15
  46912c:	mov    DWORD PTR [rcx+0x8],ebx
  46912f:	mov    DWORD PTR [r8+r9*1+0x18],r13d
  469134:	mov    DWORD PTR [r8+r9*1+0x28],r11d
  469139:	mov    DWORD PTR [r8+r9*1+0x38],r15d
  46913e:	mov    r9,r12
  469141:	add    rdx,0x40
  469145:	and    r9,r10
  469148:	cmp    QWORD PTR [rsp-0x28],rdx
  46914d:	je     4691f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3f8>
  469153:	lea    r13,[r8+rax*1]
  469157:	mov    r11d,DWORD PTR [r13+0x8]
  46915b:	andn   r12d,esi,r11d
  469160:	shl    r12,0x4
  469164:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r12*1]
  46916b:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  469172:	vpcmpequq k7{k2},zmm8,zmm9
  469179:	lea    rcx,[rax+0x180]
  469180:	add    rax,0x10
  469184:	and    rcx,r10
  469187:	and    rax,r10
  46918a:	andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
  469191:	shl    r15,0x4
  469195:	kortestb k7,k7
  469199:	prefetcht0 BYTE PTR [rdi+r15*1]
  46919e:	jne    468f08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
  4691a4:	vpcmpequq k1{k2},zmm8,zmm4
  4691ab:	kortestb k1,k1
  4691af:	jne    469993 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb93>
  4691b5:	mov    rcx,r14
  4691b8:	crc32  rcx,r11
  4691be:	vmovd  xmm10,ecx
  4691c2:	vpinsrd xmm11,xmm10,DWORD PTR [r13+0xc],0x1
  4691c9:	mov    r13,QWORD PTR [r13+0x0]
  4691cd:	lea    r15,[r8+r9*1]
  4691d1:	add    r9,0x10
  4691d5:	andn   ebx,esi,ecx
  4691da:	shl    rbx,0x4
  4691de:	and    r9,r10
  4691e1:	prefetcht2 BYTE PTR [rdi+rbx*1]
  4691e5:	mov    QWORD PTR [r15],r13
  4691e8:	vmovq  QWORD PTR [r15+0x8],xmm11
  4691ee:	jmp    469153 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x353>
  4691f3:	nop    DWORD PTR [rax+rax*1+0x0]
  4691f8:	mov    rcx,QWORD PTR [rsp-0x40]
  4691fd:	mov    r15,QWORD PTR [rsp-0x48]
  469202:	mov    edi,DWORD PTR [rsp-0x2c]
  469206:	vmovq  xmm14,r9
  46920b:	vpinsrq xmm0,xmm14,rax,0x1
  469211:	mov    rsi,QWORD PTR [rsp-0x38]
  469216:	vpsrlq xmm2,xmm0,0x4
  46921b:	vpmovqd xmm3,xmm2
  469221:	sar    rsi,0x4
  469225:	vmovq  QWORD PTR [rcx+0xb0],xmm3
  46922d:	sub    rsi,rdi
  469230:	add    DWORD PTR [r15],esi
  469233:	vpextrd eax,xmm3,0x1
  469239:	cmp    rdx,QWORD PTR [rsp-0x20]
  46923e:	je     469520 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  469244:	mov    rdi,QWORD PTR [rcx+0x88]
  46924b:	mov    rbx,QWORD PTR [rcx+0x80]
  469252:	mov    r8,QWORD PTR [rcx+0x60]
  469256:	dec    rdi
  469259:	mov    QWORD PTR [rsp-0x18],rbx
  46925e:	mov    QWORD PTR [rsp],r8
  469262:	mov    QWORD PTR [rsp-0x28],rdi
  469267:	mov    r10d,DWORD PTR [rcx+0x78]
  46926b:	mov    r11,QWORD PTR [rip+0x29976]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469272:	mov    r9,QWORD PTR [rcx+0xa0]
  469279:	movzx  r13d,BYTE PTR [rip+0x2987f]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469281:	mov    r12,QWORD PTR [rip+0x29880]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469288:	mov    r14d,0x55
  46928e:	vpxor  xmm7,xmm7,xmm7
  469292:	kmovb  k2,r14d
  469297:	nop    WORD PTR [rax+rax*1+0x0]
  4692a0:	lea    esi,[rax+0x18]
  4692a3:	and    esi,r10d
  4692a6:	shl    rsi,0x4
  4692aa:	mov    r8d,ebx
  4692ad:	and    r8d,DWORD PTR [r9+rsi*1+0x8]
  4692b2:	mov    esi,eax
  4692b4:	shl    rsi,0x4
  4692b8:	add    rsi,r9
  4692bb:	mov    r14,r8
  4692be:	mov    r8,QWORD PTR [rsi]
  4692c1:	shl    r14,0x4
  4692c5:	prefetcht0 BYTE PTR [r11+r14*1]
  4692ca:	cmp    r8,QWORD PTR [rcx+0x90]
  4692d1:	jne    469390 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x590>
  4692d7:	test   r13b,r13b
  4692da:	je     4692fa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fa>
  4692dc:	mov    r14d,DWORD PTR [r15]
  4692df:	mov    esi,DWORD PTR [rsi+0xc]
  4692e2:	mov    r8,r14
  4692e5:	shl    r14,0x4
  4692e9:	add    r14,QWORD PTR [r15+0x8]
  4692ed:	inc    r8d
  4692f0:	mov    DWORD PTR [r14],esi
  4692f3:	mov    QWORD PTR [r14+0x8],r12
  4692f7:	mov    DWORD PTR [r15],r8d
  4692fa:	inc    eax
  4692fc:	and    eax,r10d
  4692ff:	mov    DWORD PTR [rcx+0xb4],eax
  469305:	test   r12,r12
  469308:	jne    4692a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  46930a:	cmp    QWORD PTR [rsp],0x4
  46930f:	je     469485 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x685>
  469315:	nop    DWORD PTR [rax]
  469318:	cmp    QWORD PTR [rsp],0x8
  46931d:	je     469500 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
  469323:	vmovd  xmm15,DWORD PTR [rsp-0x10]
  469329:	mov    rdi,QWORD PTR [rdx]
  46932c:	mov    esi,DWORD PTR [rcx+0xb0]
  469332:	mov    r8,QWORD PTR [rsp-0x28]
  469337:	mov    rax,rsi
  46933a:	and    r8,QWORD PTR [rsp-0x10]
  46933f:	vpinsrd xmm9,xmm15,DWORD PTR [rdx+0xc],0x1
  469346:	and    r8,0xfffffffffffffffc
  46934a:	shl    rsi,0x4
  46934e:	inc    eax
  469350:	add    rsi,r9
  469353:	shl    r8,0x4
  469357:	and    eax,r10d
  46935a:	add    rdx,0x10
  46935e:	prefetcht2 BYTE PTR [r11+r8*1]
  469363:	mov    QWORD PTR [rsi],rdi
  469366:	vmovq  QWORD PTR [rsi+0x8],xmm9
  46936b:	mov    DWORD PTR [rcx+0xb0],eax
  469371:	cmp    rdx,QWORD PTR [rsp-0x20]
  469376:	je     469520 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  46937c:	mov    eax,DWORD PTR [rcx+0xb4]
  469382:	jmp    4692a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  469387:	nop    WORD PTR [rax+rax*1+0x0]
  469390:	mov    r14d,DWORD PTR [rsi+0x8]
  469394:	mov    edi,ebx
  469396:	and    edi,r14d
  469399:	shl    rdi,0x4
  46939d:	add    rdi,r11
  4693a0:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  4693a6:	vpbroadcastq zmm6,r8
  4693ac:	vpcmpequq k0{k2},zmm5,zmm6
  4693b3:	kortestb k0,k0
  4693b7:	jne    469440 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x640>
  4693bd:	vpcmpequq k3{k2},zmm5,zmm7
  4693c4:	kortestb k3,k3
  4693c8:	jne    4694b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  4693ce:	cmp    QWORD PTR [rsp],0x4
  4693d3:	mov    edi,r14d
  4693d6:	je     4694c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  4693dc:	cmp    QWORD PTR [rsp],0x8
  4693e1:	je     4694e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
  4693e7:	vmovd  xmm1,DWORD PTR [rsp-0x8]
  4693ed:	mov    edi,DWORD PTR [rcx+0xb0]
  4693f3:	mov    r14,QWORD PTR [rsp-0x18]
  4693f8:	vpinsrd xmm4,xmm1,DWORD PTR [rsi+0xc],0x1
  4693ff:	mov    rsi,rdi
  469402:	and    r14,QWORD PTR [rsp-0x8]
  469407:	shl    rdi,0x4
  46940b:	inc    esi
  46940d:	inc    eax
  46940f:	add    rdi,r9
  469412:	shl    r14,0x4
  469416:	and    esi,r10d
  469419:	and    eax,r10d
  46941c:	prefetcht2 BYTE PTR [r11+r14*1]
  469421:	mov    QWORD PTR [rdi],r8
  469424:	vmovq  QWORD PTR [rdi+0x8],xmm4
  469429:	mov    DWORD PTR [rcx+0xb0],esi
  46942f:	mov    DWORD PTR [rcx+0xb4],eax
  469435:	jmp    4692a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  46943a:	nop    WORD PTR [rax+rax*1+0x0]
  469440:	mov    r8d,DWORD PTR [r15]
  469443:	mov    esi,DWORD PTR [rsi+0xc]
  469446:	mov    r14,r8
  469449:	shl    r8,0x4
  46944d:	add    r8,QWORD PTR [r15+0x8]
  469451:	mov    DWORD PTR [r8],esi
  469454:	kmovb  esi,k0
  469458:	tzcnt  esi,esi
  46945c:	inc    esi
  46945e:	movsxd rsi,esi
  469461:	mov    rdi,QWORD PTR [rdi+rsi*8]
  469465:	inc    eax
  469467:	inc    r14d
  46946a:	and    eax,r10d
  46946d:	cmp    QWORD PTR [rsp],0x4
  469472:	mov    QWORD PTR [r8+0x8],rdi
  469476:	mov    DWORD PTR [r15],r14d
  469479:	mov    DWORD PTR [rcx+0xb4],eax
  46947f:	jne    469318 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x518>
  469485:	mov    r14d,0xffffffff
  46948b:	crc32  r14d,DWORD PTR [rdx]
  469491:	vmovd  xmm8,r14d
  469496:	mov    rdi,QWORD PTR [rdx]
  469499:	vmovdqa xmm15,xmm8
  46949e:	vmovq  QWORD PTR [rsp-0x10],xmm8
  4694a4:	jmp    46932c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  4694a9:	nop    DWORD PTR [rax+0x0]
  4694b0:	inc    eax
  4694b2:	and    eax,r10d
  4694b5:	mov    DWORD PTR [rcx+0xb4],eax
  4694bb:	jmp    46930a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
  4694c0:	mov    edi,0xffffffff
  4694c5:	crc32  edi,r14d
  4694cb:	vmovd  xmm12,edi
  4694cf:	vmovdqa xmm1,xmm12
  4694d3:	vmovq  QWORD PTR [rsp-0x8],xmm12
  4694d9:	jmp    4693ed <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  4694de:	xchg   ax,ax
  4694e0:	mov    r14d,0xffffffff
  4694e6:	crc32  r14,rdi
  4694ec:	mov    QWORD PTR [rsp-0x8],r14
  4694f1:	vmovd  xmm1,r14d
  4694f6:	jmp    4693ed <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  4694fb:	nop    DWORD PTR [rax+rax*1+0x0]
  469500:	mov    rdi,QWORD PTR [rdx]
  469503:	mov    eax,0xffffffff
  469508:	crc32  rax,rdi
  46950e:	mov    QWORD PTR [rsp-0x10],rax
  469513:	vmovd  xmm15,eax
  469517:	jmp    46932c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  46951c:	nop    DWORD PTR [rax+0x0]
  469520:	vzeroupper 
  469523:	lea    rsp,[rbp-0x28]
  469527:	pop    rbx
  469528:	pop    r12
  46952a:	pop    r13
  46952c:	pop    r14
  46952e:	pop    r15
  469530:	pop    rbp
  469531:	ret    
  469532:	nop    WORD PTR [rax+rax*1+0x0]
  469538:	vpcmpequq k1{k2},zmm0,zmm4
  46953f:	kortestb k1,k1
  469543:	jne    469698 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x898>
  469549:	mov    r13,r14
  46954c:	crc32  r13,rbx
  469552:	vmovd  xmm3,r13d
  469557:	vpinsrd xmm5,xmm3,DWORD PTR [r15+0xc],0x1
  46955e:	mov    r15,QWORD PTR [r15]
  469561:	add    r9,0x10
  469565:	andn   ebx,esi,r13d
  46956a:	shl    rbx,0x4
  46956e:	and    r9,r10
  469571:	prefetcht2 BYTE PTR [rdi+rbx*1]
  469575:	mov    QWORD PTR [rcx],r15
  469578:	vmovq  QWORD PTR [rcx+0x8],xmm5
  46957d:	jmp    46901b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x21b>
  469582:	nop    WORD PTR [rax+rax*1+0x0]
  469588:	vpcmpequq k1{k2},zmm8,zmm4
  46958f:	kortestb k1,k1
  469593:	jne    4699a9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xba9>
  469599:	mov    r15,r14
  46959c:	crc32  r15,rbx
  4695a2:	vmovd  xmm10,r15d
  4695a7:	vpinsrd xmm11,xmm10,DWORD PTR [rcx+0xc],0x1
  4695ae:	mov    rcx,QWORD PTR [rcx]
  4695b1:	lea    r13,[r8+r9*1]
  4695b5:	add    r9,0x10
  4695b9:	andn   ebx,esi,r15d
  4695be:	shl    rbx,0x4
  4695c2:	and    r9,r10
  4695c5:	prefetcht2 BYTE PTR [rdi+rbx*1]
  4695c9:	mov    QWORD PTR [r13+0x0],rcx
  4695cd:	vmovq  QWORD PTR [r13+0x8],xmm11
  4695d3:	jmp    468fa6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a6>
  4695d8:	nop    DWORD PTR [rax+rax*1+0x0]
  4695e0:	vpcmpequq k1{k2},zmm0,zmm4
  4695e7:	kortestb k1,k1
  4695eb:	jne    46998a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb8a>
  4695f1:	mov    r12,r14
  4695f4:	crc32  r12,rbx
  4695fa:	vmovd  xmm3,r12d
  4695ff:	vpinsrd xmm5,xmm3,DWORD PTR [rcx+0xc],0x1
  469606:	mov    rcx,QWORD PTR [rcx]
  469609:	lea    r15,[r8+r9*1]
  46960d:	add    r9,0x10
  469611:	andn   ebx,esi,r12d
  469616:	shl    rbx,0x4
  46961a:	and    r9,r10
  46961d:	prefetcht2 BYTE PTR [rdi+rbx*1]
  469621:	mov    QWORD PTR [r15],rcx
  469624:	vmovq  QWORD PTR [r15+0x8],xmm5
  46962a:	jmp    468f32 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x132>
  46962f:	nop
  469630:	vmovd  xmm10,ebx
  469634:	vpinsrd xmm11,xmm10,r13d,0x1
  46963a:	mov    r13,QWORD PTR [rsp-0x18]
  46963f:	vmovd  xmm8,r11d
  469644:	mov    r11,r13
  469647:	vpinsrd xmm9,xmm8,r15d,0x1
  46964d:	sub    r11,r9
  469650:	mov    ebx,0x4444
  469655:	vpunpcklqdq xmm13,xmm11,xmm9
  46965a:	shr    r11,0x2
  46965e:	mov    r15d,0x1
  469664:	kmovw  k7,ebx
  469668:	shlx   r11d,r15d,r11d
  46966d:	vpexpandd zmm15{k7},zmm13
  469673:	lea    ebx,[r11-0x1]
  469677:	sub    r9,r13
  46967a:	neg    r11d
  46967d:	kmovw  k1,ebx
  469681:	vmovdqu32 ZMMWORD PTR [rcx]{k1},zmm15
  469687:	kmovw  k7,r11d
  46968c:	vmovdqu32 ZMMWORD PTR [r8+r9*1]{k7},zmm15
  469693:	jmp    46913e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x33e>
  469698:	inc    DWORD PTR [rsp-0x2c]
  46969c:	nop    DWORD PTR [rax+0x0]
  4696a0:	mov    r15,QWORD PTR [rsp]
  4696a4:	mov    r12d,0x55
  4696aa:	pdep   r13d,r11d,r12d
  4696af:	popcnt r11d,r11d
  4696b4:	lea    ebx,[r13+r13*2+0x0]
  4696b9:	shl    r11,0x4
  4696bd:	kmovb  k1,ebx
  4696c1:	vpcompressq ZMMWORD PTR [r15]{k1},zmm12
  4696c7:	add    r15,r11
  4696ca:	mov    QWORD PTR [rsp],r15
  4696ce:	jmp    4690b2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b2>
  4696d3:	cmp    rdx,QWORD PTR [rsp-0x20]
  4696d8:	je     469523 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x723>
  4696de:	mov    r12,QWORD PTR [rcx+0x88]
  4696e5:	movzx  r13d,BYTE PTR [rip+0x29413]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4696ed:	mov    r9,QWORD PTR [rip+0x29414]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4696f4:	mov    r10,QWORD PTR [rcx+0x60]
  4696f8:	mov    ebx,0x55
  4696fd:	dec    r12
  469700:	kmovb  k2,r13d
  469705:	mov    QWORD PTR [rsp],r10
  469709:	mov    QWORD PTR [rsp-0x8],r12
  46970e:	mov    r14,QWORD PTR [rip+0x294d3]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469715:	mov    r11,QWORD PTR [rcx+0xa0]
  46971c:	mov    esi,edi
  46971e:	vpxor  xmm2,xmm2,xmm2
  469722:	mov    r13,r9
  469725:	kmovb  k1,ebx
  469729:	jmp    469791 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x991>
  46972b:	cmp    QWORD PTR [rsp],0x8
  469730:	je     469938 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb38>
  469736:	vmovd  xmm5,DWORD PTR [rsp-0x18]
  46973c:	mov    r12,QWORD PTR [rsp-0x8]
  469741:	mov    esi,edi
  469743:	and    r12,QWORD PTR [rsp-0x18]
  469748:	vpinsrd xmm7,xmm5,DWORD PTR [rdx+0xc],0x1
  46974f:	mov    r10,QWORD PTR [rdx]
  469752:	and    r12,0xfffffffffffffffc
  469756:	shl    rsi,0x4
  46975a:	add    rsi,r11
  46975d:	shl    r12,0x4
  469761:	prefetcht2 BYTE PTR [r14+r12*1]
  469766:	mov    QWORD PTR [rsi],r10
  469769:	vmovq  QWORD PTR [rsi+0x8],xmm7
  46976e:	lea    esi,[rdi+0x1]
  469771:	and    esi,r8d
  469774:	add    rdx,0x10
  469778:	mov    DWORD PTR [rcx+0xb0],esi
  46977e:	cmp    QWORD PTR [rsp-0x20],rdx
  469783:	je     469520 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  469789:	mov    eax,DWORD PTR [rcx+0xb4]
  46978f:	mov    edi,esi
  469791:	sub    esi,eax
  469793:	and    esi,r8d
  469796:	cmp    r8d,esi
  469799:	jbe    4697bc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9bc>
  46979b:	cmp    QWORD PTR [rsp],0x4
  4697a0:	jne    46972b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x92b>
  4697a2:	mov    ebx,0xffffffff
  4697a7:	crc32  ebx,DWORD PTR [rdx]
  4697ac:	vmovd  xmm6,ebx
  4697b0:	vmovdqa xmm5,xmm6
  4697b4:	vmovq  QWORD PTR [rsp-0x18],xmm6
  4697ba:	jmp    46973c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x93c>
  4697bc:	mov    rbx,QWORD PTR [rcx+0x80]
  4697c3:	mov    QWORD PTR [rsp-0x10],rbx
  4697c8:	nop    DWORD PTR [rax+rax*1+0x0]
  4697d0:	lea    esi,[rax+0x18]
  4697d3:	and    esi,r8d
  4697d6:	shl    rsi,0x4
  4697da:	mov    r9d,ebx
  4697dd:	and    r9d,DWORD PTR [r11+rsi*1+0x8]
  4697e2:	mov    esi,eax
  4697e4:	mov    r10,r9
  4697e7:	shl    rsi,0x4
  4697eb:	shl    r10,0x4
  4697ef:	add    rsi,r11
  4697f2:	prefetcht0 BYTE PTR [r14+r10*1]
  4697f7:	mov    r10,QWORD PTR [rsi]
  4697fa:	cmp    r10,QWORD PTR [rcx+0x90]
  469801:	jne    469840 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa40>
  469803:	kortestb k2,k2
  469807:	je     46982a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa2a>
  469809:	mov    r12d,DWORD PTR [r15]
  46980c:	mov    esi,DWORD PTR [rsi+0xc]
  46980f:	mov    r10,r12
  469812:	shl    r12,0x4
  469816:	add    r12,QWORD PTR [r15+0x8]
  46981a:	lea    r9d,[r10+0x1]
  46981e:	mov    DWORD PTR [r12],esi
  469822:	mov    QWORD PTR [r12+0x8],r13
  469827:	mov    DWORD PTR [r15],r9d
  46982a:	inc    eax
  46982c:	and    eax,r8d
  46982f:	mov    DWORD PTR [rcx+0xb4],eax
  469835:	test   r13,r13
  469838:	jne    4697d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9d0>
  46983a:	jmp    46979b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x99b>
  46983f:	nop
  469840:	mov    r12d,DWORD PTR [rsi+0x8]
  469844:	mov    r9d,ebx
  469847:	and    r9d,r12d
  46984a:	shl    r9,0x4
  46984e:	add    r9,r14
  469851:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  469857:	vpbroadcastq zmm1,r10
  46985d:	vpcmpequq k0{k1},zmm0,zmm1
  469864:	kortestb k0,k0
  469868:	jne    4698e4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xae4>
  46986a:	vpcmpequq k3{k1},zmm0,zmm2
  469871:	kortestb k3,k3
  469875:	jne    469928 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb28>
  46987b:	cmp    QWORD PTR [rsp],0x4
  469880:	mov    r9d,r12d
  469883:	je     469951 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb51>
  469889:	cmp    QWORD PTR [rsp],0x8
  46988e:	je     469971 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb71>
  469894:	mov    r9d,DWORD PTR [rsp-0x28]
  469899:	mov    r12,QWORD PTR [rsp-0x10]
  46989e:	vmovd  xmm4,r9d
  4698a3:	vpinsrd xmm3,xmm4,DWORD PTR [rsi+0xc],0x1
  4698aa:	mov    esi,edi
  4698ac:	and    r12,QWORD PTR [rsp-0x28]
  4698b1:	shl    rsi,0x4
  4698b5:	inc    edi
  4698b7:	inc    eax
  4698b9:	add    rsi,r11
  4698bc:	shl    r12,0x4
  4698c0:	and    edi,r8d
  4698c3:	and    eax,r8d
  4698c6:	prefetcht2 BYTE PTR [r14+r12*1]
  4698cb:	mov    QWORD PTR [rsi],r10
  4698ce:	vmovq  QWORD PTR [rsi+0x8],xmm3
  4698d3:	mov    DWORD PTR [rcx+0xb0],edi
  4698d9:	mov    DWORD PTR [rcx+0xb4],eax
  4698df:	jmp    4697d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9d0>
  4698e4:	mov    r10d,DWORD PTR [r15]
  4698e7:	mov    r12d,DWORD PTR [rsi+0xc]
  4698eb:	mov    rbx,r10
  4698ee:	shl    r10,0x4
  4698f2:	add    r10,QWORD PTR [r15+0x8]
  4698f6:	mov    DWORD PTR [r10],r12d
  4698f9:	xor    r12d,r12d
  4698fc:	kmovb  esi,k0
  469900:	tzcnt  r12d,esi
  469905:	inc    r12d
  469908:	movsxd rsi,r12d
  46990b:	mov    r9,QWORD PTR [r9+rsi*8]
  46990f:	inc    eax
  469911:	inc    ebx
  469913:	and    eax,r8d
  469916:	mov    QWORD PTR [r10+0x8],r9
  46991a:	mov    DWORD PTR [r15],ebx
  46991d:	mov    DWORD PTR [rcx+0xb4],eax
  469923:	jmp    46979b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x99b>
  469928:	inc    eax
  46992a:	and    eax,r8d
  46992d:	mov    DWORD PTR [rcx+0xb4],eax
  469933:	jmp    46979b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x99b>
  469938:	mov    eax,0xffffffff
  46993d:	crc32  rax,QWORD PTR [rdx]
  469943:	mov    QWORD PTR [rsp-0x18],rax
  469948:	vmovd  xmm5,eax
  46994c:	jmp    46973c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x93c>
  469951:	mov    r9d,0xffffffff
  469957:	crc32  r9d,r12d
  46995d:	mov    r12d,r9d
  469960:	mov    QWORD PTR [rsp-0x28],r12
  469965:	jmp    469899 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa99>
  46996a:	xor    edi,edi
  46996c:	jmp    469206 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x406>
  469971:	mov    r12d,0xffffffff
  469977:	crc32  r12,r9
  46997d:	mov    QWORD PTR [rsp-0x28],r12
  469982:	mov    r9d,r12d
  469985:	jmp    469899 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa99>
  46998a:	inc    DWORD PTR [rsp-0x2c]
  46998e:	jmp    468fa6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a6>
  469993:	inc    DWORD PTR [rsp-0x2c]
  469997:	vpxor  xmm15,xmm15,xmm15
  46999c:	xor    r11d,r11d
  46999f:	vpxor  xmm12,xmm12,xmm12
  4699a4:	jmp    468f32 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x132>
  4699a9:	inc    DWORD PTR [rsp-0x2c]
  4699ad:	jmp    46901b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x21b>
