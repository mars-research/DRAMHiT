0000000000468f50 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468f50:	push   rbp
  468f51:	mov    rcx,rdi
  468f54:	mov    rbp,rsp
  468f57:	push   r15
  468f59:	mov    r15,rdx
  468f5c:	push   r14
  468f5e:	push   r13
  468f60:	push   r12
  468f62:	push   rbx
  468f63:	and    rsp,0xffffffffffffffc0
  468f67:	sub    rsp,0x8
  468f6b:	mov    r11,QWORD PTR [rsi+0x8]
  468f6f:	mov    edi,DWORD PTR [rdi+0xc0]
  468f75:	mov    eax,DWORD PTR [rcx+0xc4]
  468f7b:	mov    rdx,QWORD PTR [rsi]
  468f7e:	mov    r8d,DWORD PTR [rcx+0x78]
  468f82:	mov    r9d,DWORD PTR [rcx+0x6c]
  468f86:	mov    r10,r11
  468f89:	mov    esi,edi
  468f8b:	shl    r10,0x4
  468f8f:	sub    esi,eax
  468f91:	lea    rbx,[rdx+r10*1]
  468f95:	and    esi,r8d
  468f98:	lea    r12d,[r9-0x1]
  468f9c:	mov    QWORD PTR [rsp-0x20],rbx
  468fa1:	cmp    esi,r12d
  468fa4:	jb     46980c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8bc>
  468faa:	and    r11,0xfffffffffffffffc
  468fae:	shl    r9,0x4
  468fb2:	shl    r11,0x4
  468fb6:	mov    r14,QWORD PTR [r15+0x8]
  468fba:	mov    esi,DWORD PTR [rcx+0x80]
  468fc0:	mov    QWORD PTR [rsp-0x18],r9
  468fc5:	mov    QWORD PTR [rsp-0x38],r11
  468fca:	lea    r10,[r9-0x1]
  468fce:	lea    r11,[rdx+r11*1]
  468fd2:	mov    r9d,edi
  468fd5:	mov    QWORD PTR [rsp],r14
  468fd9:	mov    QWORD PTR [rsp-0x28],r11
  468fde:	mov    DWORD PTR [rsp-0x2c],0x0
  468fe6:	mov    r8,QWORD PTR [rcx+0xa0]
  468fed:	mov    rdi,QWORD PTR [rip+0x2bbfc]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468ff4:	shl    rax,0x4
  468ff8:	shl    r9,0x4
  468ffc:	not    esi
  468ffe:	cmp    rdx,r11
  469001:	je     469aaa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb5a>
  469007:	mov    r13d,0x55
  46900d:	mov    ebx,0xf
  469012:	mov    r12d,0xf0
  469018:	mov    r11d,0xf00
  46901e:	kmovb  k2,r13d
  469023:	mov    r13d,0xfffff000
  469029:	mov    QWORD PTR [rsp-0x40],rcx
  46902e:	mov    QWORD PTR [rsp-0x48],r15
  469033:	vpxor  xmm4,xmm4,xmm4
  469037:	mov    r14d,0xffffffff
  46903d:	kmovw  k6,ebx
  469041:	kmovw  k5,r12d
  469046:	kmovw  k4,r11d
  46904b:	kmovw  k3,r13d
  469050:	jmp    4692a9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  469055:	nop    DWORD PTR [rax]
  469058:	vmovd  xmm13,DWORD PTR [r12+0xc]
  46905f:	kshiftlb k7,k7,0x1
  469065:	vpcompressq zmm12{k7}{z},zmm8
  46906b:	vpunpcklqdq xmm14,xmm13,xmm12
  469070:	vshufi32x4 zmm15{k6}{z},zmm14,zmm14,0x0
  469077:	vmovdqa64 zmm12,zmm15
  46907d:	mov    r11d,0x1
  469083:	lea    r13,[r8+rax*1]
  469087:	lea    r12,[rax+0x180]
  46908e:	and    r12,r10
  469091:	mov    r15d,DWORD PTR [r13+0x8]
  469095:	andn   ecx,esi,DWORD PTR [r8+r12*1+0x8]
  46909c:	shl    rcx,0x4
  4690a0:	andn   r12d,esi,r15d
  4690a5:	shl    r12,0x4
  4690a9:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r12*1]
  4690b0:	vpbroadcastq zmm2,QWORD PTR [r13+0x0]
  4690b7:	vpcmpequq k0{k2},zmm0,zmm2
  4690be:	add    rax,0x10
  4690c2:	and    rax,r10
  4690c5:	prefetcht0 BYTE PTR [rdi+rcx*1]
  4690c9:	kortestb k0,k0
  4690cd:	je     469720 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
  4690d3:	vmovd  xmm1,DWORD PTR [r13+0xc]
  4690d9:	kshiftlb k7,k0,0x1
  4690df:	vpcompressq zmm6{k7}{z},zmm0
  4690e5:	vpunpcklqdq xmm7,xmm1,xmm6
  4690e9:	vshufi32x4 zmm15{k5},zmm7,zmm7,0x0
  4690f0:	vmovdqa64 zmm12,zmm15
  4690f6:	or     r11d,0x2
  4690fa:	lea    r13,[rax+0x180]
  469101:	and    r13,r10
  469104:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  46910b:	shl    rcx,0x4
  46910f:	lea    r13,[r8+rax*1]
  469113:	mov    ebx,DWORD PTR [r13+0x8]
  469117:	andn   r12d,esi,ebx
  46911c:	shl    r12,0x4
  469120:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r12*1]
  469127:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  46912e:	vpcmpequq k0{k2},zmm8,zmm9
  469135:	add    rax,0x10
  469139:	and    rax,r10
  46913c:	prefetcht0 BYTE PTR [rdi+rcx*1]
  469140:	kortestb k0,k0
  469144:	je     4696d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x780>
  46914a:	vmovd  xmm13,DWORD PTR [r13+0xc]
  469150:	kshiftlb k7,k0,0x1
  469156:	vpcompressq zmm12{k7}{z},zmm8
  46915c:	vpunpcklqdq xmm14,xmm13,xmm12
  469161:	vshufi32x4 zmm15{k4},zmm14,zmm14,0x0
  469168:	vmovdqa64 zmm12,zmm15
  46916e:	or     r11d,0x4
  469172:	lea    r15,[r8+rax*1]
  469176:	lea    r13,[rax+0x180]
  46917d:	and    r13,r10
  469180:	mov    r12d,DWORD PTR [r15+0x8]
  469184:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  46918b:	shl    rcx,0x4
  46918f:	andn   r13d,esi,r12d
  469194:	shl    r13,0x4
  469198:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r13*1]
  46919f:	vpbroadcastq zmm2,QWORD PTR [r15]
  4691a5:	vpcmpequq k0{k2},zmm0,zmm2
  4691ac:	add    rax,0x10
  4691b0:	and    rax,r10
  4691b3:	prefetcht0 BYTE PTR [rdi+rcx*1]
  4691b7:	kortestb k0,k0
  4691bb:	lea    rcx,[r8+r9*1]
  4691bf:	je     469688 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
  4691c5:	vmovd  xmm1,DWORD PTR [r15+0xc]
  4691cb:	kshiftlb k7,k0,0x1
  4691d1:	vpcompressq zmm6{k7}{z},zmm0
  4691d7:	vpunpcklqdq xmm7,xmm1,xmm6
  4691db:	vshufi32x4 zmm15{k3},zmm7,zmm7,0x0
  4691e2:	or     r11d,0x8
  4691e6:	vmovdqa64 zmm12,zmm15
  4691ec:	cmp    r11d,0xf
  4691f0:	jne    4697d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x888>
  4691f6:	mov    r15,QWORD PTR [rsp]
  4691fa:	vmovdqu64 ZMMWORD PTR [r15],zmm15
  469200:	add    r15,0x40
  469204:	mov    QWORD PTR [rsp],r15
  469208:	mov    rbx,r14
  46920b:	mov    r11,r14
  46920e:	crc32  rbx,QWORD PTR [rdx]
  469214:	crc32  r11,QWORD PTR [rdx+0x20]
  46921b:	andn   r13d,esi,ebx
  469220:	shl    r13,0x4
  469224:	andn   r15d,esi,r11d
  469229:	shl    r15,0x4
  46922d:	prefetcht2 BYTE PTR [rdi+r13*1]
  469232:	prefetcht2 BYTE PTR [rdi+r15*1]
  469237:	mov    r13,r14
  46923a:	mov    r15,r14
  46923d:	crc32  r13,QWORD PTR [rdx+0x10]
  469244:	crc32  r15,QWORD PTR [rdx+0x30]
  46924b:	andn   r12d,esi,r13d
  469250:	shl    r12,0x4
  469254:	prefetcht2 BYTE PTR [rdi+r12*1]
  469259:	andn   r12d,esi,r15d
  46925e:	shl    r12,0x4
  469262:	prefetcht2 BYTE PTR [rdi+r12*1]
  469267:	lea    r12,[r9+0x40]
  46926b:	vmovdqu64 zmm15,ZMMWORD PTR [rdx]
  469271:	cmp    QWORD PTR [rsp-0x18],r12
  469276:	jb     469768 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x818>
  46927c:	vmovdqu64 ZMMWORD PTR [rcx],zmm15
  469282:	mov    DWORD PTR [rcx+0x8],ebx
  469285:	mov    DWORD PTR [r8+r9*1+0x18],r13d
  46928a:	mov    DWORD PTR [r8+r9*1+0x28],r11d
  46928f:	mov    DWORD PTR [r8+r9*1+0x38],r15d
  469294:	mov    r9,r12
  469297:	add    rdx,0x40
  46929b:	and    r9,r10
  46929e:	cmp    QWORD PTR [rsp-0x28],rdx
  4692a3:	je     469348 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3f8>
  4692a9:	lea    r12,[r8+rax*1]
  4692ad:	mov    r11d,DWORD PTR [r12+0x8]
  4692b2:	andn   r13d,esi,r11d
  4692b7:	shl    r13,0x4
  4692bb:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r13*1]
  4692c2:	vpbroadcastq zmm9,QWORD PTR [r12]
  4692c9:	vpcmpequq k7{k2},zmm8,zmm9
  4692d0:	lea    rcx,[rax+0x180]
  4692d7:	add    rax,0x10
  4692db:	and    rcx,r10
  4692de:	and    rax,r10
  4692e1:	andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
  4692e8:	shl    r15,0x4
  4692ec:	kortestb k7,k7
  4692f0:	prefetcht0 BYTE PTR [rdi+r15*1]
  4692f5:	jne    469058 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
  4692fb:	vpcmpequq k1{k2},zmm8,zmm4
  469302:	kortestb k1,k1
  469306:	jne    469ad3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb83>
  46930c:	vmovdqu xmm10,XMMWORD PTR [r12]
  469312:	mov    rcx,r14
  469315:	crc32  rcx,r11
  46931b:	vpinsrd xmm11,xmm10,ecx,0x2
  469321:	andn   r15d,esi,ecx
  469326:	shl    r15,0x4
  46932a:	prefetcht2 BYTE PTR [rdi+r15*1]
  46932f:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  469335:	add    r9,0x10
  469339:	and    r9,r10
  46933c:	jmp    4692a9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  469341:	nop    DWORD PTR [rax+0x0]
  469348:	mov    rcx,QWORD PTR [rsp-0x40]
  46934d:	mov    r15,QWORD PTR [rsp-0x48]
  469352:	mov    edi,DWORD PTR [rsp-0x2c]
  469356:	vmovq  xmm14,r9
  46935b:	vpinsrq xmm0,xmm14,rax,0x1
  469361:	mov    rsi,QWORD PTR [rsp-0x38]
  469366:	vpsrlq xmm2,xmm0,0x4
  46936b:	vpmovqd xmm3,xmm2
  469371:	sar    rsi,0x4
  469375:	vmovq  QWORD PTR [rcx+0xc0],xmm3
  46937d:	sub    rsi,rdi
  469380:	add    DWORD PTR [r15],esi
  469383:	vpextrd eax,xmm3,0x1
  469389:	cmp    rdx,QWORD PTR [rsp-0x20]
  46938e:	je     469670 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  469394:	mov    rdi,QWORD PTR [rcx+0x88]
  46939b:	mov    rbx,QWORD PTR [rcx+0x80]
  4693a2:	mov    r8,QWORD PTR [rcx+0x60]
  4693a6:	dec    rdi
  4693a9:	mov    QWORD PTR [rsp-0x18],rbx
  4693ae:	mov    QWORD PTR [rsp],r8
  4693b2:	mov    QWORD PTR [rsp-0x28],rdi
  4693b7:	mov    r10d,DWORD PTR [rcx+0x78]
  4693bb:	mov    r11,QWORD PTR [rip+0x2b82e]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4693c2:	mov    r9,QWORD PTR [rcx+0xa0]
  4693c9:	movzx  r13d,BYTE PTR [rip+0x2b72f]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4693d1:	mov    r12,QWORD PTR [rip+0x2b730]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4693d8:	mov    r14d,0x55
  4693de:	vpxor  xmm7,xmm7,xmm7
  4693e2:	kmovb  k2,r14d
  4693e7:	nop    WORD PTR [rax+rax*1+0x0]
  4693f0:	lea    esi,[rax+0x18]
  4693f3:	and    esi,r10d
  4693f6:	shl    rsi,0x4
  4693fa:	mov    r8d,ebx
  4693fd:	and    r8d,DWORD PTR [r9+rsi*1+0x8]
  469402:	mov    esi,eax
  469404:	shl    rsi,0x4
  469408:	add    rsi,r9
  46940b:	mov    r14,r8
  46940e:	mov    r8,QWORD PTR [rsi]
  469411:	shl    r14,0x4
  469415:	prefetcht0 BYTE PTR [r11+r14*1]
  46941a:	cmp    r8,QWORD PTR [rcx+0x90]
  469421:	jne    4694e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x590>
  469427:	test   r13b,r13b
  46942a:	je     46944a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fa>
  46942c:	mov    r14d,DWORD PTR [r15]
  46942f:	mov    esi,DWORD PTR [rsi+0xc]
  469432:	mov    r8,r14
  469435:	shl    r14,0x4
  469439:	add    r14,QWORD PTR [r15+0x8]
  46943d:	inc    r8d
  469440:	mov    DWORD PTR [r14],esi
  469443:	mov    QWORD PTR [r14+0x8],r12
  469447:	mov    DWORD PTR [r15],r8d
  46944a:	inc    eax
  46944c:	and    eax,r10d
  46944f:	mov    DWORD PTR [rcx+0xc4],eax
  469455:	test   r12,r12
  469458:	jne    4693f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  46945a:	cmp    QWORD PTR [rsp],0x4
  46945f:	je     4695d5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x685>
  469465:	nop    DWORD PTR [rax]
  469468:	cmp    QWORD PTR [rsp],0x8
  46946d:	je     469650 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
  469473:	vmovd  xmm15,DWORD PTR [rsp-0x10]
  469479:	mov    rdi,QWORD PTR [rdx]
  46947c:	mov    esi,DWORD PTR [rcx+0xc0]
  469482:	mov    r8,QWORD PTR [rsp-0x28]
  469487:	mov    rax,rsi
  46948a:	and    r8,QWORD PTR [rsp-0x10]
  46948f:	vpinsrd xmm9,xmm15,DWORD PTR [rdx+0xc],0x1
  469496:	and    r8,0xfffffffffffffffc
  46949a:	shl    rsi,0x4
  46949e:	inc    eax
  4694a0:	add    rsi,r9
  4694a3:	shl    r8,0x4
  4694a7:	and    eax,r10d
  4694aa:	add    rdx,0x10
  4694ae:	prefetcht2 BYTE PTR [r11+r8*1]
  4694b3:	mov    QWORD PTR [rsi],rdi
  4694b6:	vmovq  QWORD PTR [rsi+0x8],xmm9
  4694bb:	mov    DWORD PTR [rcx+0xc0],eax
  4694c1:	cmp    rdx,QWORD PTR [rsp-0x20]
  4694c6:	je     469670 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  4694cc:	mov    eax,DWORD PTR [rcx+0xc4]
  4694d2:	jmp    4693f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  4694d7:	nop    WORD PTR [rax+rax*1+0x0]
  4694e0:	mov    r14d,DWORD PTR [rsi+0x8]
  4694e4:	mov    edi,ebx
  4694e6:	and    edi,r14d
  4694e9:	shl    rdi,0x4
  4694ed:	add    rdi,r11
  4694f0:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  4694f6:	vpbroadcastq zmm6,r8
  4694fc:	vpcmpequq k0{k2},zmm5,zmm6
  469503:	kortestb k0,k0
  469507:	jne    469590 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x640>
  46950d:	vpcmpequq k3{k2},zmm5,zmm7
  469514:	kortestb k3,k3
  469518:	jne    469600 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  46951e:	cmp    QWORD PTR [rsp],0x4
  469523:	mov    edi,r14d
  469526:	je     469610 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  46952c:	cmp    QWORD PTR [rsp],0x8
  469531:	je     469630 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
  469537:	vmovd  xmm1,DWORD PTR [rsp-0x8]
  46953d:	mov    edi,DWORD PTR [rcx+0xc0]
  469543:	mov    r14,QWORD PTR [rsp-0x18]
  469548:	vpinsrd xmm4,xmm1,DWORD PTR [rsi+0xc],0x1
  46954f:	mov    rsi,rdi
  469552:	and    r14,QWORD PTR [rsp-0x8]
  469557:	shl    rdi,0x4
  46955b:	inc    esi
  46955d:	inc    eax
  46955f:	add    rdi,r9
  469562:	shl    r14,0x4
  469566:	and    esi,r10d
  469569:	and    eax,r10d
  46956c:	prefetcht2 BYTE PTR [r11+r14*1]
  469571:	mov    QWORD PTR [rdi],r8
  469574:	vmovq  QWORD PTR [rdi+0x8],xmm4
  469579:	mov    DWORD PTR [rcx+0xc0],esi
  46957f:	mov    DWORD PTR [rcx+0xc4],eax
  469585:	jmp    4693f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  46958a:	nop    WORD PTR [rax+rax*1+0x0]
  469590:	mov    r8d,DWORD PTR [r15]
  469593:	mov    esi,DWORD PTR [rsi+0xc]
  469596:	mov    r14,r8
  469599:	shl    r8,0x4
  46959d:	add    r8,QWORD PTR [r15+0x8]
  4695a1:	mov    DWORD PTR [r8],esi
  4695a4:	kmovb  esi,k0
  4695a8:	tzcnt  esi,esi
  4695ac:	inc    esi
  4695ae:	movsxd rsi,esi
  4695b1:	mov    rdi,QWORD PTR [rdi+rsi*8]
  4695b5:	inc    eax
  4695b7:	inc    r14d
  4695ba:	and    eax,r10d
  4695bd:	cmp    QWORD PTR [rsp],0x4
  4695c2:	mov    QWORD PTR [r8+0x8],rdi
  4695c6:	mov    DWORD PTR [r15],r14d
  4695c9:	mov    DWORD PTR [rcx+0xc4],eax
  4695cf:	jne    469468 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x518>
  4695d5:	mov    r14d,0xffffffff
  4695db:	crc32  r14d,DWORD PTR [rdx]
  4695e1:	vmovd  xmm8,r14d
  4695e6:	mov    rdi,QWORD PTR [rdx]
  4695e9:	vmovdqa xmm15,xmm8
  4695ee:	vmovq  QWORD PTR [rsp-0x10],xmm8
  4695f4:	jmp    46947c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  4695f9:	nop    DWORD PTR [rax+0x0]
  469600:	inc    eax
  469602:	and    eax,r10d
  469605:	mov    DWORD PTR [rcx+0xc4],eax
  46960b:	jmp    46945a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
  469610:	mov    edi,0xffffffff
  469615:	crc32  edi,r14d
  46961b:	vmovd  xmm12,edi
  46961f:	vmovdqa xmm1,xmm12
  469623:	vmovq  QWORD PTR [rsp-0x8],xmm12
  469629:	jmp    46953d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  46962e:	xchg   ax,ax
  469630:	mov    r14d,0xffffffff
  469636:	crc32  r14,rdi
  46963c:	mov    QWORD PTR [rsp-0x8],r14
  469641:	vmovd  xmm1,r14d
  469646:	jmp    46953d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  46964b:	nop    DWORD PTR [rax+rax*1+0x0]
  469650:	mov    rdi,QWORD PTR [rdx]
  469653:	mov    eax,0xffffffff
  469658:	crc32  rax,rdi
  46965e:	mov    QWORD PTR [rsp-0x10],rax
  469663:	vmovd  xmm15,eax
  469667:	jmp    46947c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  46966c:	nop    DWORD PTR [rax+0x0]
  469670:	vzeroupper 
  469673:	lea    rsp,[rbp-0x28]
  469677:	pop    rbx
  469678:	pop    r12
  46967a:	pop    r13
  46967c:	pop    r14
  46967e:	pop    r15
  469680:	pop    rbp
  469681:	ret    
  469682:	nop    WORD PTR [rax+rax*1+0x0]
  469688:	vpcmpequq k1{k2},zmm0,zmm4
  46968f:	kortestb k1,k1
  469693:	jne    4697d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x880>
  469699:	vmovdqu xmm3,XMMWORD PTR [r15]
  46969e:	mov    rbx,r14
  4696a1:	crc32  rbx,r12
  4696a7:	vpinsrd xmm5,xmm3,ebx,0x2
  4696ad:	add    r9,0x10
  4696b1:	andn   r12d,esi,ebx
  4696b6:	shl    r12,0x4
  4696ba:	and    r9,r10
  4696bd:	prefetcht2 BYTE PTR [rdi+r12*1]
  4696c2:	vmovdqu XMMWORD PTR [rcx],xmm5
  4696c6:	jmp    469172 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
  4696cb:	nop    DWORD PTR [rax+rax*1+0x0]
  4696d0:	vpcmpequq k1{k2},zmm8,zmm4
  4696d7:	kortestb k1,k1
  4696db:	jne    469ae9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb99>
  4696e1:	vmovdqu xmm10,XMMWORD PTR [r13+0x0]
  4696e7:	mov    rcx,r14
  4696ea:	crc32  rcx,rbx
  4696f0:	vpinsrd xmm11,xmm10,ecx,0x2
  4696f6:	andn   r15d,esi,ecx
  4696fb:	shl    r15,0x4
  4696ff:	prefetcht2 BYTE PTR [rdi+r15*1]
  469704:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  46970a:	add    r9,0x10
  46970e:	and    r9,r10
  469711:	jmp    4690fa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469716:	cs nop WORD PTR [rax+rax*1+0x0]
  469720:	vpcmpequq k1{k2},zmm0,zmm4
  469727:	kortestb k1,k1
  46972b:	jne    469aca <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb7a>
  469731:	vmovdqu xmm3,XMMWORD PTR [r13+0x0]
  469737:	mov    rcx,r14
  46973a:	crc32  rcx,r15
  469740:	vpinsrd xmm5,xmm3,ecx,0x2
  469746:	andn   ebx,esi,ecx
  46974b:	shl    rbx,0x4
  46974f:	prefetcht2 BYTE PTR [rdi+rbx*1]
  469753:	vmovdqu XMMWORD PTR [r8+r9*1],xmm5
  469759:	add    r9,0x10
  46975d:	and    r9,r10
  469760:	jmp    469083 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  469765:	nop    DWORD PTR [rax]
  469768:	vmovd  xmm10,ebx
  46976c:	vpinsrd xmm11,xmm10,r13d,0x1
  469772:	mov    r13,QWORD PTR [rsp-0x18]
  469777:	vmovd  xmm8,r11d
  46977c:	mov    r11,r13
  46977f:	vpinsrd xmm9,xmm8,r15d,0x1
  469785:	sub    r11,r9
  469788:	mov    ebx,0x4444
  46978d:	vpunpcklqdq xmm13,xmm11,xmm9
  469792:	shr    r11,0x2
  469796:	mov    r15d,0x1
  46979c:	kmovw  k7,ebx
  4697a0:	shlx   r11d,r15d,r11d
  4697a5:	vpexpandd zmm15{k7},zmm13
  4697ab:	lea    ebx,[r11-0x1]
  4697af:	sub    r9,r13
  4697b2:	neg    r11d
  4697b5:	kmovw  k1,ebx
  4697b9:	vmovdqu32 ZMMWORD PTR [rcx]{k1},zmm15
  4697bf:	kmovw  k7,r11d
  4697c4:	vmovdqu32 ZMMWORD PTR [r8+r9*1]{k7},zmm15
  4697cb:	jmp    469294 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x344>
  4697d0:	inc    DWORD PTR [rsp-0x2c]
  4697d4:	nop    DWORD PTR [rax+0x0]
  4697d8:	mov    r12,QWORD PTR [rsp]
  4697dc:	mov    r15d,0x55
  4697e2:	pdep   r13d,r11d,r15d
  4697e7:	popcnt r11d,r11d
  4697ec:	lea    ebx,[r13+r13*2+0x0]
  4697f1:	shl    r11,0x4
  4697f5:	kmovb  k1,ebx
  4697f9:	vpcompressq ZMMWORD PTR [r12]{k1},zmm12
  469800:	add    r12,r11
  469803:	mov    QWORD PTR [rsp],r12
  469807:	jmp    469208 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b8>
  46980c:	cmp    rdx,QWORD PTR [rsp-0x20]
  469811:	je     469673 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x723>
  469817:	mov    r12,QWORD PTR [rcx+0x88]
  46981e:	movzx  r13d,BYTE PTR [rip+0x2b2da]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469826:	mov    r9,QWORD PTR [rip+0x2b2db]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46982d:	mov    r10,QWORD PTR [rcx+0x60]
  469831:	mov    ebx,0x55
  469836:	dec    r12
  469839:	kmovb  k2,r13d
  46983e:	mov    QWORD PTR [rsp],r10
  469842:	mov    QWORD PTR [rsp-0x8],r12
  469847:	mov    r14,QWORD PTR [rip+0x2b3a2]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46984e:	mov    r11,QWORD PTR [rcx+0xa0]
  469855:	mov    esi,edi
  469857:	vpxor  xmm2,xmm2,xmm2
  46985b:	mov    r13,r9
  46985e:	kmovb  k1,ebx
  469862:	jmp    4698ca <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x97a>
  469864:	cmp    QWORD PTR [rsp],0x8
  469869:	je     469a78 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb28>
  46986f:	vmovd  xmm5,DWORD PTR [rsp-0x18]
  469875:	mov    r12,QWORD PTR [rsp-0x8]
  46987a:	mov    esi,edi
  46987c:	and    r12,QWORD PTR [rsp-0x18]
  469881:	vpinsrd xmm7,xmm5,DWORD PTR [rdx+0xc],0x1
  469888:	mov    r10,QWORD PTR [rdx]
  46988b:	and    r12,0xfffffffffffffffc
  46988f:	shl    rsi,0x4
  469893:	add    rsi,r11
  469896:	shl    r12,0x4
  46989a:	prefetcht2 BYTE PTR [r14+r12*1]
  46989f:	mov    QWORD PTR [rsi],r10
  4698a2:	vmovq  QWORD PTR [rsi+0x8],xmm7
  4698a7:	lea    esi,[rdi+0x1]
  4698aa:	and    esi,r8d
  4698ad:	add    rdx,0x10
  4698b1:	mov    DWORD PTR [rcx+0xc0],esi
  4698b7:	cmp    QWORD PTR [rsp-0x20],rdx
  4698bc:	je     469670 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  4698c2:	mov    eax,DWORD PTR [rcx+0xc4]
  4698c8:	mov    edi,esi
  4698ca:	sub    esi,eax
  4698cc:	and    esi,r8d
  4698cf:	cmp    r8d,esi
  4698d2:	jbe    4698f5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a5>
  4698d4:	cmp    QWORD PTR [rsp],0x4
  4698d9:	jne    469864 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x914>
  4698db:	mov    ebx,0xffffffff
  4698e0:	crc32  ebx,DWORD PTR [rdx]
  4698e5:	vmovd  xmm6,ebx
  4698e9:	vmovdqa xmm5,xmm6
  4698ed:	vmovq  QWORD PTR [rsp-0x18],xmm6
  4698f3:	jmp    469875 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  4698f5:	mov    rbx,QWORD PTR [rcx+0x80]
  4698fc:	mov    QWORD PTR [rsp-0x10],rbx
  469901:	nop    DWORD PTR [rax+0x0]
  469908:	lea    esi,[rax+0x18]
  46990b:	and    esi,r8d
  46990e:	shl    rsi,0x4
  469912:	mov    r9d,ebx
  469915:	and    r9d,DWORD PTR [r11+rsi*1+0x8]
  46991a:	mov    esi,eax
  46991c:	mov    r10,r9
  46991f:	shl    rsi,0x4
  469923:	shl    r10,0x4
  469927:	add    rsi,r11
  46992a:	prefetcht0 BYTE PTR [r14+r10*1]
  46992f:	mov    r10,QWORD PTR [rsi]
  469932:	cmp    r10,QWORD PTR [rcx+0x90]
  469939:	jne    469980 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa30>
  46993b:	kortestb k2,k2
  46993f:	je     469962 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa12>
  469941:	mov    r12d,DWORD PTR [r15]
  469944:	mov    esi,DWORD PTR [rsi+0xc]
  469947:	mov    r10,r12
  46994a:	shl    r12,0x4
  46994e:	add    r12,QWORD PTR [r15+0x8]
  469952:	lea    r9d,[r10+0x1]
  469956:	mov    DWORD PTR [r12],esi
  46995a:	mov    QWORD PTR [r12+0x8],r13
  46995f:	mov    DWORD PTR [r15],r9d
  469962:	inc    eax
  469964:	and    eax,r8d
  469967:	mov    DWORD PTR [rcx+0xc4],eax
  46996d:	test   r13,r13
  469970:	jne    469908 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  469972:	jmp    4698d4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  469977:	nop    WORD PTR [rax+rax*1+0x0]
  469980:	mov    r12d,DWORD PTR [rsi+0x8]
  469984:	mov    r9d,ebx
  469987:	and    r9d,r12d
  46998a:	shl    r9,0x4
  46998e:	add    r9,r14
  469991:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  469997:	vpbroadcastq zmm1,r10
  46999d:	vpcmpequq k0{k1},zmm0,zmm1
  4699a4:	kortestb k0,k0
  4699a8:	jne    469a24 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad4>
  4699aa:	vpcmpequq k3{k1},zmm0,zmm2
  4699b1:	kortestb k3,k3
  4699b5:	jne    469a68 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb18>
  4699bb:	cmp    QWORD PTR [rsp],0x4
  4699c0:	mov    r9d,r12d
  4699c3:	je     469a91 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb41>
  4699c9:	cmp    QWORD PTR [rsp],0x8
  4699ce:	je     469ab1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb61>
  4699d4:	mov    r9d,DWORD PTR [rsp-0x28]
  4699d9:	mov    r12,QWORD PTR [rsp-0x10]
  4699de:	vmovd  xmm4,r9d
  4699e3:	vpinsrd xmm3,xmm4,DWORD PTR [rsi+0xc],0x1
  4699ea:	mov    esi,edi
  4699ec:	and    r12,QWORD PTR [rsp-0x28]
  4699f1:	shl    rsi,0x4
  4699f5:	inc    edi
  4699f7:	inc    eax
  4699f9:	add    rsi,r11
  4699fc:	shl    r12,0x4
  469a00:	and    edi,r8d
  469a03:	and    eax,r8d
  469a06:	prefetcht2 BYTE PTR [r14+r12*1]
  469a0b:	mov    QWORD PTR [rsi],r10
  469a0e:	vmovq  QWORD PTR [rsi+0x8],xmm3
  469a13:	mov    DWORD PTR [rcx+0xc0],edi
  469a19:	mov    DWORD PTR [rcx+0xc4],eax
  469a1f:	jmp    469908 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  469a24:	mov    r10d,DWORD PTR [r15]
  469a27:	mov    r12d,DWORD PTR [rsi+0xc]
  469a2b:	mov    rbx,r10
  469a2e:	shl    r10,0x4
  469a32:	add    r10,QWORD PTR [r15+0x8]
  469a36:	mov    DWORD PTR [r10],r12d
  469a39:	xor    r12d,r12d
  469a3c:	kmovb  esi,k0
  469a40:	tzcnt  r12d,esi
  469a45:	inc    r12d
  469a48:	movsxd rsi,r12d
  469a4b:	mov    r9,QWORD PTR [r9+rsi*8]
  469a4f:	inc    eax
  469a51:	inc    ebx
  469a53:	and    eax,r8d
  469a56:	mov    QWORD PTR [r10+0x8],r9
  469a5a:	mov    DWORD PTR [r15],ebx
  469a5d:	mov    DWORD PTR [rcx+0xc4],eax
  469a63:	jmp    4698d4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  469a68:	inc    eax
  469a6a:	and    eax,r8d
  469a6d:	mov    DWORD PTR [rcx+0xc4],eax
  469a73:	jmp    4698d4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  469a78:	mov    eax,0xffffffff
  469a7d:	crc32  rax,QWORD PTR [rdx]
  469a83:	mov    QWORD PTR [rsp-0x18],rax
  469a88:	vmovd  xmm5,eax
  469a8c:	jmp    469875 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  469a91:	mov    r9d,0xffffffff
  469a97:	crc32  r9d,r12d
  469a9d:	mov    r12d,r9d
  469aa0:	mov    QWORD PTR [rsp-0x28],r12
  469aa5:	jmp    4699d9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  469aaa:	xor    edi,edi
  469aac:	jmp    469356 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x406>
  469ab1:	mov    r12d,0xffffffff
  469ab7:	crc32  r12,r9
  469abd:	mov    QWORD PTR [rsp-0x28],r12
  469ac2:	mov    r9d,r12d
  469ac5:	jmp    4699d9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  469aca:	inc    DWORD PTR [rsp-0x2c]
  469ace:	jmp    4690fa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469ad3:	inc    DWORD PTR [rsp-0x2c]
  469ad7:	vpxor  xmm15,xmm15,xmm15
  469adc:	xor    r11d,r11d
  469adf:	vpxor  xmm12,xmm12,xmm12
  469ae4:	jmp    469083 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  469ae9:	inc    DWORD PTR [rsp-0x2c]
  469aed:	jmp    469172 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
