0000000000468f90 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468f90:	push   rbp
  468f91:	mov    rcx,rdi
  468f94:	mov    rbp,rsp
  468f97:	push   r15
  468f99:	mov    r15,rdx
  468f9c:	push   r14
  468f9e:	push   r13
  468fa0:	push   r12
  468fa2:	push   rbx
  468fa3:	and    rsp,0xffffffffffffffc0
  468fa7:	sub    rsp,0x8
  468fab:	mov    r11,QWORD PTR [rsi+0x8]
  468faf:	mov    edi,DWORD PTR [rdi+0xc0]
  468fb5:	mov    eax,DWORD PTR [rcx+0xc4]
  468fbb:	mov    rdx,QWORD PTR [rsi]
  468fbe:	mov    r8d,DWORD PTR [rcx+0x78]
  468fc2:	mov    r9d,DWORD PTR [rcx+0x6c]
  468fc6:	mov    r10,r11
  468fc9:	mov    esi,edi
  468fcb:	shl    r10,0x4
  468fcf:	sub    esi,eax
  468fd1:	lea    rbx,[rdx+r10*1]
  468fd5:	and    esi,r8d
  468fd8:	lea    r12d,[r9-0x1]
  468fdc:	mov    QWORD PTR [rsp-0x20],rbx
  468fe1:	cmp    esi,r12d
  468fe4:	jb     46984c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8bc>
  468fea:	and    r11,0xfffffffffffffffc
  468fee:	shl    r9,0x4
  468ff2:	shl    r11,0x4
  468ff6:	mov    r14,QWORD PTR [r15+0x8]
  468ffa:	mov    esi,DWORD PTR [rcx+0x80]
  469000:	mov    QWORD PTR [rsp-0x18],r9
  469005:	mov    QWORD PTR [rsp-0x38],r11
  46900a:	lea    r10,[r9-0x1]
  46900e:	lea    r11,[rdx+r11*1]
  469012:	mov    r9d,edi
  469015:	mov    QWORD PTR [rsp],r14
  469019:	mov    QWORD PTR [rsp-0x28],r11
  46901e:	mov    DWORD PTR [rsp-0x2c],0x0
  469026:	mov    r8,QWORD PTR [rcx+0xa0]
  46902d:	mov    rdi,QWORD PTR [rip+0x2bbbc]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469034:	shl    rax,0x4
  469038:	shl    r9,0x4
  46903c:	not    esi
  46903e:	cmp    rdx,r11
  469041:	je     469aea <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb5a>
  469047:	mov    r13d,0x55
  46904d:	mov    ebx,0xf
  469052:	mov    r12d,0xf0
  469058:	mov    r11d,0xf00
  46905e:	kmovb  k2,r13d
  469063:	mov    r13d,0xfffff000
  469069:	mov    QWORD PTR [rsp-0x40],rcx
  46906e:	mov    QWORD PTR [rsp-0x48],r15
  469073:	vpxor  xmm4,xmm4,xmm4
  469077:	mov    r14d,0xffffffff
  46907d:	kmovw  k6,ebx
  469081:	kmovw  k5,r12d
  469086:	kmovw  k4,r11d
  46908b:	kmovw  k3,r13d
  469090:	jmp    4692e9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  469095:	nop    DWORD PTR [rax]
  469098:	vmovd  xmm13,DWORD PTR [r12+0xc]
  46909f:	kshiftlb k7,k7,0x1
  4690a5:	vpcompressq zmm12{k7}{z},zmm8
  4690ab:	vpunpcklqdq xmm14,xmm13,xmm12
  4690b0:	vshufi32x4 zmm15{k6}{z},zmm14,zmm14,0x0
  4690b7:	vmovdqa64 zmm12,zmm15
  4690bd:	mov    r11d,0x1
  4690c3:	lea    r13,[r8+rax*1]
  4690c7:	lea    r12,[rax+0x180]
  4690ce:	and    r12,r10
  4690d1:	mov    r15d,DWORD PTR [r13+0x8]
  4690d5:	andn   ecx,esi,DWORD PTR [r8+r12*1+0x8]
  4690dc:	shl    rcx,0x4
  4690e0:	andn   r12d,esi,r15d
  4690e5:	shl    r12,0x4
  4690e9:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r12*1]
  4690f0:	vpbroadcastq zmm2,QWORD PTR [r13+0x0]
  4690f7:	vpcmpequq k0{k2},zmm0,zmm2
  4690fe:	add    rax,0x10
  469102:	and    rax,r10
  469105:	prefetcht0 BYTE PTR [rdi+rcx*1]
  469109:	kortestb k0,k0
  46910d:	je     469760 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
  469113:	vmovd  xmm1,DWORD PTR [r13+0xc]
  469119:	kshiftlb k7,k0,0x1
  46911f:	vpcompressq zmm6{k7}{z},zmm0
  469125:	vpunpcklqdq xmm7,xmm1,xmm6
  469129:	vshufi32x4 zmm15{k5},zmm7,zmm7,0x0
  469130:	vmovdqa64 zmm12,zmm15
  469136:	or     r11d,0x2
  46913a:	lea    r13,[rax+0x180]
  469141:	and    r13,r10
  469144:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  46914b:	shl    rcx,0x4
  46914f:	lea    r13,[r8+rax*1]
  469153:	mov    ebx,DWORD PTR [r13+0x8]
  469157:	andn   r12d,esi,ebx
  46915c:	shl    r12,0x4
  469160:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r12*1]
  469167:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  46916e:	vpcmpequq k0{k2},zmm8,zmm9
  469175:	add    rax,0x10
  469179:	and    rax,r10
  46917c:	prefetcht0 BYTE PTR [rdi+rcx*1]
  469180:	kortestb k0,k0
  469184:	je     469710 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x780>
  46918a:	vmovd  xmm13,DWORD PTR [r13+0xc]
  469190:	kshiftlb k7,k0,0x1
  469196:	vpcompressq zmm12{k7}{z},zmm8
  46919c:	vpunpcklqdq xmm14,xmm13,xmm12
  4691a1:	vshufi32x4 zmm15{k4},zmm14,zmm14,0x0
  4691a8:	vmovdqa64 zmm12,zmm15
  4691ae:	or     r11d,0x4
  4691b2:	lea    r15,[r8+rax*1]
  4691b6:	lea    r13,[rax+0x180]
  4691bd:	and    r13,r10
  4691c0:	mov    r12d,DWORD PTR [r15+0x8]
  4691c4:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  4691cb:	shl    rcx,0x4
  4691cf:	andn   r13d,esi,r12d
  4691d4:	shl    r13,0x4
  4691d8:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r13*1]
  4691df:	vpbroadcastq zmm2,QWORD PTR [r15]
  4691e5:	vpcmpequq k0{k2},zmm0,zmm2
  4691ec:	add    rax,0x10
  4691f0:	and    rax,r10
  4691f3:	prefetcht0 BYTE PTR [rdi+rcx*1]
  4691f7:	kortestb k0,k0
  4691fb:	lea    rcx,[r8+r9*1]
  4691ff:	je     4696c8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
  469205:	vmovd  xmm1,DWORD PTR [r15+0xc]
  46920b:	kshiftlb k7,k0,0x1
  469211:	vpcompressq zmm6{k7}{z},zmm0
  469217:	vpunpcklqdq xmm7,xmm1,xmm6
  46921b:	vshufi32x4 zmm15{k3},zmm7,zmm7,0x0
  469222:	or     r11d,0x8
  469226:	vmovdqa64 zmm12,zmm15
  46922c:	cmp    r11d,0xf
  469230:	jne    469818 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x888>
  469236:	mov    r15,QWORD PTR [rsp]
  46923a:	vmovdqu64 ZMMWORD PTR [r15],zmm15
  469240:	add    r15,0x40
  469244:	mov    QWORD PTR [rsp],r15
  469248:	mov    rbx,r14
  46924b:	mov    r11,r14
  46924e:	crc32  rbx,QWORD PTR [rdx]
  469254:	crc32  r11,QWORD PTR [rdx+0x20]
  46925b:	andn   r13d,esi,ebx
  469260:	shl    r13,0x4
  469264:	andn   r15d,esi,r11d
  469269:	shl    r15,0x4
  46926d:	prefetcht2 BYTE PTR [rdi+r13*1]
  469272:	prefetcht2 BYTE PTR [rdi+r15*1]
  469277:	mov    r13,r14
  46927a:	mov    r15,r14
  46927d:	crc32  r13,QWORD PTR [rdx+0x10]
  469284:	crc32  r15,QWORD PTR [rdx+0x30]
  46928b:	andn   r12d,esi,r13d
  469290:	shl    r12,0x4
  469294:	prefetcht2 BYTE PTR [rdi+r12*1]
  469299:	andn   r12d,esi,r15d
  46929e:	shl    r12,0x4
  4692a2:	prefetcht2 BYTE PTR [rdi+r12*1]
  4692a7:	lea    r12,[r9+0x40]
  4692ab:	vmovdqu64 zmm15,ZMMWORD PTR [rdx]
  4692b1:	cmp    QWORD PTR [rsp-0x18],r12
  4692b6:	jb     4697a8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x818>
  4692bc:	vmovdqu64 ZMMWORD PTR [rcx],zmm15
  4692c2:	mov    DWORD PTR [rcx+0x8],ebx
  4692c5:	mov    DWORD PTR [r8+r9*1+0x18],r13d
  4692ca:	mov    DWORD PTR [r8+r9*1+0x28],r11d
  4692cf:	mov    DWORD PTR [r8+r9*1+0x38],r15d
  4692d4:	mov    r9,r12
  4692d7:	add    rdx,0x40
  4692db:	and    r9,r10
  4692de:	cmp    QWORD PTR [rsp-0x28],rdx
  4692e3:	je     469388 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3f8>
  4692e9:	lea    r12,[r8+rax*1]
  4692ed:	mov    r11d,DWORD PTR [r12+0x8]
  4692f2:	andn   r13d,esi,r11d
  4692f7:	shl    r13,0x4
  4692fb:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r13*1]
  469302:	vpbroadcastq zmm9,QWORD PTR [r12]
  469309:	vpcmpequq k7{k2},zmm8,zmm9
  469310:	lea    rcx,[rax+0x180]
  469317:	add    rax,0x10
  46931b:	and    rcx,r10
  46931e:	and    rax,r10
  469321:	andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
  469328:	shl    r15,0x4
  46932c:	kortestb k7,k7
  469330:	prefetcht0 BYTE PTR [rdi+r15*1]
  469335:	jne    469098 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
  46933b:	vpcmpequq k1{k2},zmm8,zmm4
  469342:	kortestb k1,k1
  469346:	jne    469b13 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb83>
  46934c:	vmovdqu xmm10,XMMWORD PTR [r12]
  469352:	mov    rcx,r14
  469355:	crc32  rcx,r11
  46935b:	vpinsrd xmm11,xmm10,ecx,0x2
  469361:	andn   r15d,esi,ecx
  469366:	shl    r15,0x4
  46936a:	prefetcht2 BYTE PTR [rdi+r15*1]
  46936f:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  469375:	add    r9,0x10
  469379:	and    r9,r10
  46937c:	jmp    4692e9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  469381:	nop    DWORD PTR [rax+0x0]
  469388:	mov    rcx,QWORD PTR [rsp-0x40]
  46938d:	mov    r15,QWORD PTR [rsp-0x48]
  469392:	mov    edi,DWORD PTR [rsp-0x2c]
  469396:	vmovq  xmm14,r9
  46939b:	vpinsrq xmm0,xmm14,rax,0x1
  4693a1:	mov    rsi,QWORD PTR [rsp-0x38]
  4693a6:	vpsrlq xmm2,xmm0,0x4
  4693ab:	vpmovqd xmm3,xmm2
  4693b1:	sar    rsi,0x4
  4693b5:	vmovq  QWORD PTR [rcx+0xc0],xmm3
  4693bd:	sub    rsi,rdi
  4693c0:	add    DWORD PTR [r15],esi
  4693c3:	vpextrd eax,xmm3,0x1
  4693c9:	cmp    rdx,QWORD PTR [rsp-0x20]
  4693ce:	je     4696b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  4693d4:	mov    rdi,QWORD PTR [rcx+0x88]
  4693db:	mov    rbx,QWORD PTR [rcx+0x80]
  4693e2:	mov    r8,QWORD PTR [rcx+0x60]
  4693e6:	dec    rdi
  4693e9:	mov    QWORD PTR [rsp-0x18],rbx
  4693ee:	mov    QWORD PTR [rsp],r8
  4693f2:	mov    QWORD PTR [rsp-0x28],rdi
  4693f7:	mov    r10d,DWORD PTR [rcx+0x78]
  4693fb:	mov    r11,QWORD PTR [rip+0x2b7ee]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469402:	mov    r9,QWORD PTR [rcx+0xa0]
  469409:	movzx  r13d,BYTE PTR [rip+0x2b6ef]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469411:	mov    r12,QWORD PTR [rip+0x2b6f0]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469418:	mov    r14d,0x55
  46941e:	vpxor  xmm7,xmm7,xmm7
  469422:	kmovb  k2,r14d
  469427:	nop    WORD PTR [rax+rax*1+0x0]
  469430:	lea    esi,[rax+0x18]
  469433:	and    esi,r10d
  469436:	shl    rsi,0x4
  46943a:	mov    r8d,ebx
  46943d:	and    r8d,DWORD PTR [r9+rsi*1+0x8]
  469442:	mov    esi,eax
  469444:	shl    rsi,0x4
  469448:	add    rsi,r9
  46944b:	mov    r14,r8
  46944e:	mov    r8,QWORD PTR [rsi]
  469451:	shl    r14,0x4
  469455:	prefetcht0 BYTE PTR [r11+r14*1]
  46945a:	cmp    r8,QWORD PTR [rcx+0x90]
  469461:	jne    469520 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x590>
  469467:	test   r13b,r13b
  46946a:	je     46948a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fa>
  46946c:	mov    r14d,DWORD PTR [r15]
  46946f:	mov    esi,DWORD PTR [rsi+0xc]
  469472:	mov    r8,r14
  469475:	shl    r14,0x4
  469479:	add    r14,QWORD PTR [r15+0x8]
  46947d:	inc    r8d
  469480:	mov    DWORD PTR [r14],esi
  469483:	mov    QWORD PTR [r14+0x8],r12
  469487:	mov    DWORD PTR [r15],r8d
  46948a:	inc    eax
  46948c:	and    eax,r10d
  46948f:	mov    DWORD PTR [rcx+0xc4],eax
  469495:	test   r12,r12
  469498:	jne    469430 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  46949a:	cmp    QWORD PTR [rsp],0x4
  46949f:	je     469615 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x685>
  4694a5:	nop    DWORD PTR [rax]
  4694a8:	cmp    QWORD PTR [rsp],0x8
  4694ad:	je     469690 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
  4694b3:	vmovd  xmm15,DWORD PTR [rsp-0x10]
  4694b9:	mov    rdi,QWORD PTR [rdx]
  4694bc:	mov    esi,DWORD PTR [rcx+0xc0]
  4694c2:	mov    r8,QWORD PTR [rsp-0x28]
  4694c7:	mov    rax,rsi
  4694ca:	and    r8,QWORD PTR [rsp-0x10]
  4694cf:	vpinsrd xmm9,xmm15,DWORD PTR [rdx+0xc],0x1
  4694d6:	and    r8,0xfffffffffffffffc
  4694da:	shl    rsi,0x4
  4694de:	inc    eax
  4694e0:	add    rsi,r9
  4694e3:	shl    r8,0x4
  4694e7:	and    eax,r10d
  4694ea:	add    rdx,0x10
  4694ee:	prefetcht2 BYTE PTR [r11+r8*1]
  4694f3:	mov    QWORD PTR [rsi],rdi
  4694f6:	vmovq  QWORD PTR [rsi+0x8],xmm9
  4694fb:	mov    DWORD PTR [rcx+0xc0],eax
  469501:	cmp    rdx,QWORD PTR [rsp-0x20]
  469506:	je     4696b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  46950c:	mov    eax,DWORD PTR [rcx+0xc4]
  469512:	jmp    469430 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  469517:	nop    WORD PTR [rax+rax*1+0x0]
  469520:	mov    r14d,DWORD PTR [rsi+0x8]
  469524:	mov    edi,ebx
  469526:	and    edi,r14d
  469529:	shl    rdi,0x4
  46952d:	add    rdi,r11
  469530:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  469536:	vpbroadcastq zmm6,r8
  46953c:	vpcmpequq k0{k2},zmm5,zmm6
  469543:	kortestb k0,k0
  469547:	jne    4695d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x640>
  46954d:	vpcmpequq k3{k2},zmm5,zmm7
  469554:	kortestb k3,k3
  469558:	jne    469640 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  46955e:	cmp    QWORD PTR [rsp],0x4
  469563:	mov    edi,r14d
  469566:	je     469650 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  46956c:	cmp    QWORD PTR [rsp],0x8
  469571:	je     469670 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
  469577:	vmovd  xmm1,DWORD PTR [rsp-0x8]
  46957d:	mov    edi,DWORD PTR [rcx+0xc0]
  469583:	mov    r14,QWORD PTR [rsp-0x18]
  469588:	vpinsrd xmm4,xmm1,DWORD PTR [rsi+0xc],0x1
  46958f:	mov    rsi,rdi
  469592:	and    r14,QWORD PTR [rsp-0x8]
  469597:	shl    rdi,0x4
  46959b:	inc    esi
  46959d:	inc    eax
  46959f:	add    rdi,r9
  4695a2:	shl    r14,0x4
  4695a6:	and    esi,r10d
  4695a9:	and    eax,r10d
  4695ac:	prefetcht2 BYTE PTR [r11+r14*1]
  4695b1:	mov    QWORD PTR [rdi],r8
  4695b4:	vmovq  QWORD PTR [rdi+0x8],xmm4
  4695b9:	mov    DWORD PTR [rcx+0xc0],esi
  4695bf:	mov    DWORD PTR [rcx+0xc4],eax
  4695c5:	jmp    469430 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  4695ca:	nop    WORD PTR [rax+rax*1+0x0]
  4695d0:	mov    r8d,DWORD PTR [r15]
  4695d3:	mov    esi,DWORD PTR [rsi+0xc]
  4695d6:	mov    r14,r8
  4695d9:	shl    r8,0x4
  4695dd:	add    r8,QWORD PTR [r15+0x8]
  4695e1:	mov    DWORD PTR [r8],esi
  4695e4:	kmovb  esi,k0
  4695e8:	tzcnt  esi,esi
  4695ec:	inc    esi
  4695ee:	movsxd rsi,esi
  4695f1:	mov    rdi,QWORD PTR [rdi+rsi*8]
  4695f5:	inc    eax
  4695f7:	inc    r14d
  4695fa:	and    eax,r10d
  4695fd:	cmp    QWORD PTR [rsp],0x4
  469602:	mov    QWORD PTR [r8+0x8],rdi
  469606:	mov    DWORD PTR [r15],r14d
  469609:	mov    DWORD PTR [rcx+0xc4],eax
  46960f:	jne    4694a8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x518>
  469615:	mov    r14d,0xffffffff
  46961b:	crc32  r14d,DWORD PTR [rdx]
  469621:	vmovd  xmm8,r14d
  469626:	mov    rdi,QWORD PTR [rdx]
  469629:	vmovdqa xmm15,xmm8
  46962e:	vmovq  QWORD PTR [rsp-0x10],xmm8
  469634:	jmp    4694bc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  469639:	nop    DWORD PTR [rax+0x0]
  469640:	inc    eax
  469642:	and    eax,r10d
  469645:	mov    DWORD PTR [rcx+0xc4],eax
  46964b:	jmp    46949a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
  469650:	mov    edi,0xffffffff
  469655:	crc32  edi,r14d
  46965b:	vmovd  xmm12,edi
  46965f:	vmovdqa xmm1,xmm12
  469663:	vmovq  QWORD PTR [rsp-0x8],xmm12
  469669:	jmp    46957d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  46966e:	xchg   ax,ax
  469670:	mov    r14d,0xffffffff
  469676:	crc32  r14,rdi
  46967c:	mov    QWORD PTR [rsp-0x8],r14
  469681:	vmovd  xmm1,r14d
  469686:	jmp    46957d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  46968b:	nop    DWORD PTR [rax+rax*1+0x0]
  469690:	mov    rdi,QWORD PTR [rdx]
  469693:	mov    eax,0xffffffff
  469698:	crc32  rax,rdi
  46969e:	mov    QWORD PTR [rsp-0x10],rax
  4696a3:	vmovd  xmm15,eax
  4696a7:	jmp    4694bc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  4696ac:	nop    DWORD PTR [rax+0x0]
  4696b0:	vzeroupper 
  4696b3:	lea    rsp,[rbp-0x28]
  4696b7:	pop    rbx
  4696b8:	pop    r12
  4696ba:	pop    r13
  4696bc:	pop    r14
  4696be:	pop    r15
  4696c0:	pop    rbp
  4696c1:	ret    
  4696c2:	nop    WORD PTR [rax+rax*1+0x0]
  4696c8:	vpcmpequq k1{k2},zmm0,zmm4
  4696cf:	kortestb k1,k1
  4696d3:	jne    469810 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x880>
  4696d9:	vmovdqu xmm3,XMMWORD PTR [r15]
  4696de:	mov    rbx,r14
  4696e1:	crc32  rbx,r12
  4696e7:	vpinsrd xmm5,xmm3,ebx,0x2
  4696ed:	add    r9,0x10
  4696f1:	andn   r12d,esi,ebx
  4696f6:	shl    r12,0x4
  4696fa:	and    r9,r10
  4696fd:	prefetcht2 BYTE PTR [rdi+r12*1]
  469702:	vmovdqu XMMWORD PTR [rcx],xmm5
  469706:	jmp    4691b2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
  46970b:	nop    DWORD PTR [rax+rax*1+0x0]
  469710:	vpcmpequq k1{k2},zmm8,zmm4
  469717:	kortestb k1,k1
  46971b:	jne    469b29 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb99>
  469721:	vmovdqu xmm10,XMMWORD PTR [r13+0x0]
  469727:	mov    rcx,r14
  46972a:	crc32  rcx,rbx
  469730:	vpinsrd xmm11,xmm10,ecx,0x2
  469736:	andn   r15d,esi,ecx
  46973b:	shl    r15,0x4
  46973f:	prefetcht2 BYTE PTR [rdi+r15*1]
  469744:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  46974a:	add    r9,0x10
  46974e:	and    r9,r10
  469751:	jmp    46913a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469756:	cs nop WORD PTR [rax+rax*1+0x0]
  469760:	vpcmpequq k1{k2},zmm0,zmm4
  469767:	kortestb k1,k1
  46976b:	jne    469b0a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb7a>
  469771:	vmovdqu xmm3,XMMWORD PTR [r13+0x0]
  469777:	mov    rcx,r14
  46977a:	crc32  rcx,r15
  469780:	vpinsrd xmm5,xmm3,ecx,0x2
  469786:	andn   ebx,esi,ecx
  46978b:	shl    rbx,0x4
  46978f:	prefetcht2 BYTE PTR [rdi+rbx*1]
  469793:	vmovdqu XMMWORD PTR [r8+r9*1],xmm5
  469799:	add    r9,0x10
  46979d:	and    r9,r10
  4697a0:	jmp    4690c3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  4697a5:	nop    DWORD PTR [rax]
  4697a8:	vmovd  xmm10,ebx
  4697ac:	vpinsrd xmm11,xmm10,r13d,0x1
  4697b2:	mov    r13,QWORD PTR [rsp-0x18]
  4697b7:	vmovd  xmm8,r11d
  4697bc:	mov    r11,r13
  4697bf:	vpinsrd xmm9,xmm8,r15d,0x1
  4697c5:	sub    r11,r9
  4697c8:	mov    ebx,0x4444
  4697cd:	vpunpcklqdq xmm13,xmm11,xmm9
  4697d2:	shr    r11,0x2
  4697d6:	mov    r15d,0x1
  4697dc:	kmovw  k7,ebx
  4697e0:	shlx   r11d,r15d,r11d
  4697e5:	vpexpandd zmm15{k7},zmm13
  4697eb:	lea    ebx,[r11-0x1]
  4697ef:	sub    r9,r13
  4697f2:	neg    r11d
  4697f5:	kmovw  k1,ebx
  4697f9:	vmovdqu32 ZMMWORD PTR [rcx]{k1},zmm15
  4697ff:	kmovw  k7,r11d
  469804:	vmovdqu32 ZMMWORD PTR [r8+r9*1]{k7},zmm15
  46980b:	jmp    4692d4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x344>
  469810:	inc    DWORD PTR [rsp-0x2c]
  469814:	nop    DWORD PTR [rax+0x0]
  469818:	mov    r12,QWORD PTR [rsp]
  46981c:	mov    r15d,0x55
  469822:	pdep   r13d,r11d,r15d
  469827:	popcnt r11d,r11d
  46982c:	lea    ebx,[r13+r13*2+0x0]
  469831:	shl    r11,0x4
  469835:	kmovb  k1,ebx
  469839:	vpcompressq ZMMWORD PTR [r12]{k1},zmm12
  469840:	add    r12,r11
  469843:	mov    QWORD PTR [rsp],r12
  469847:	jmp    469248 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b8>
  46984c:	cmp    rdx,QWORD PTR [rsp-0x20]
  469851:	je     4696b3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x723>
  469857:	mov    r12,QWORD PTR [rcx+0x88]
  46985e:	movzx  r13d,BYTE PTR [rip+0x2b29a]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469866:	mov    r9,QWORD PTR [rip+0x2b29b]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46986d:	mov    r10,QWORD PTR [rcx+0x60]
  469871:	mov    ebx,0x55
  469876:	dec    r12
  469879:	kmovb  k2,r13d
  46987e:	mov    QWORD PTR [rsp],r10
  469882:	mov    QWORD PTR [rsp-0x8],r12
  469887:	mov    r14,QWORD PTR [rip+0x2b362]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46988e:	mov    r11,QWORD PTR [rcx+0xa0]
  469895:	mov    esi,edi
  469897:	vpxor  xmm2,xmm2,xmm2
  46989b:	mov    r13,r9
  46989e:	kmovb  k1,ebx
  4698a2:	jmp    46990a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x97a>
  4698a4:	cmp    QWORD PTR [rsp],0x8
  4698a9:	je     469ab8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb28>
  4698af:	vmovd  xmm5,DWORD PTR [rsp-0x18]
  4698b5:	mov    r12,QWORD PTR [rsp-0x8]
  4698ba:	mov    esi,edi
  4698bc:	and    r12,QWORD PTR [rsp-0x18]
  4698c1:	vpinsrd xmm7,xmm5,DWORD PTR [rdx+0xc],0x1
  4698c8:	mov    r10,QWORD PTR [rdx]
  4698cb:	and    r12,0xfffffffffffffffc
  4698cf:	shl    rsi,0x4
  4698d3:	add    rsi,r11
  4698d6:	shl    r12,0x4
  4698da:	prefetcht2 BYTE PTR [r14+r12*1]
  4698df:	mov    QWORD PTR [rsi],r10
  4698e2:	vmovq  QWORD PTR [rsi+0x8],xmm7
  4698e7:	lea    esi,[rdi+0x1]
  4698ea:	and    esi,r8d
  4698ed:	add    rdx,0x10
  4698f1:	mov    DWORD PTR [rcx+0xc0],esi
  4698f7:	cmp    QWORD PTR [rsp-0x20],rdx
  4698fc:	je     4696b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  469902:	mov    eax,DWORD PTR [rcx+0xc4]
  469908:	mov    edi,esi
  46990a:	sub    esi,eax
  46990c:	and    esi,r8d
  46990f:	cmp    r8d,esi
  469912:	jbe    469935 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a5>
  469914:	cmp    QWORD PTR [rsp],0x4
  469919:	jne    4698a4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x914>
  46991b:	mov    ebx,0xffffffff
  469920:	crc32  ebx,DWORD PTR [rdx]
  469925:	vmovd  xmm6,ebx
  469929:	vmovdqa xmm5,xmm6
  46992d:	vmovq  QWORD PTR [rsp-0x18],xmm6
  469933:	jmp    4698b5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  469935:	mov    rbx,QWORD PTR [rcx+0x80]
  46993c:	mov    QWORD PTR [rsp-0x10],rbx
  469941:	nop    DWORD PTR [rax+0x0]
  469948:	lea    esi,[rax+0x18]
  46994b:	and    esi,r8d
  46994e:	shl    rsi,0x4
  469952:	mov    r9d,ebx
  469955:	and    r9d,DWORD PTR [r11+rsi*1+0x8]
  46995a:	mov    esi,eax
  46995c:	mov    r10,r9
  46995f:	shl    rsi,0x4
  469963:	shl    r10,0x4
  469967:	add    rsi,r11
  46996a:	prefetcht0 BYTE PTR [r14+r10*1]
  46996f:	mov    r10,QWORD PTR [rsi]
  469972:	cmp    r10,QWORD PTR [rcx+0x90]
  469979:	jne    4699c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa30>
  46997b:	kortestb k2,k2
  46997f:	je     4699a2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa12>
  469981:	mov    r12d,DWORD PTR [r15]
  469984:	mov    esi,DWORD PTR [rsi+0xc]
  469987:	mov    r10,r12
  46998a:	shl    r12,0x4
  46998e:	add    r12,QWORD PTR [r15+0x8]
  469992:	lea    r9d,[r10+0x1]
  469996:	mov    DWORD PTR [r12],esi
  46999a:	mov    QWORD PTR [r12+0x8],r13
  46999f:	mov    DWORD PTR [r15],r9d
  4699a2:	inc    eax
  4699a4:	and    eax,r8d
  4699a7:	mov    DWORD PTR [rcx+0xc4],eax
  4699ad:	test   r13,r13
  4699b0:	jne    469948 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  4699b2:	jmp    469914 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  4699b7:	nop    WORD PTR [rax+rax*1+0x0]
  4699c0:	mov    r12d,DWORD PTR [rsi+0x8]
  4699c4:	mov    r9d,ebx
  4699c7:	and    r9d,r12d
  4699ca:	shl    r9,0x4
  4699ce:	add    r9,r14
  4699d1:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  4699d7:	vpbroadcastq zmm1,r10
  4699dd:	vpcmpequq k0{k1},zmm0,zmm1
  4699e4:	kortestb k0,k0
  4699e8:	jne    469a64 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad4>
  4699ea:	vpcmpequq k3{k1},zmm0,zmm2
  4699f1:	kortestb k3,k3
  4699f5:	jne    469aa8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb18>
  4699fb:	cmp    QWORD PTR [rsp],0x4
  469a00:	mov    r9d,r12d
  469a03:	je     469ad1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb41>
  469a09:	cmp    QWORD PTR [rsp],0x8
  469a0e:	je     469af1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb61>
  469a14:	mov    r9d,DWORD PTR [rsp-0x28]
  469a19:	mov    r12,QWORD PTR [rsp-0x10]
  469a1e:	vmovd  xmm4,r9d
  469a23:	vpinsrd xmm3,xmm4,DWORD PTR [rsi+0xc],0x1
  469a2a:	mov    esi,edi
  469a2c:	and    r12,QWORD PTR [rsp-0x28]
  469a31:	shl    rsi,0x4
  469a35:	inc    edi
  469a37:	inc    eax
  469a39:	add    rsi,r11
  469a3c:	shl    r12,0x4
  469a40:	and    edi,r8d
  469a43:	and    eax,r8d
  469a46:	prefetcht2 BYTE PTR [r14+r12*1]
  469a4b:	mov    QWORD PTR [rsi],r10
  469a4e:	vmovq  QWORD PTR [rsi+0x8],xmm3
  469a53:	mov    DWORD PTR [rcx+0xc0],edi
  469a59:	mov    DWORD PTR [rcx+0xc4],eax
  469a5f:	jmp    469948 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  469a64:	mov    r10d,DWORD PTR [r15]
  469a67:	mov    r12d,DWORD PTR [rsi+0xc]
  469a6b:	mov    rbx,r10
  469a6e:	shl    r10,0x4
  469a72:	add    r10,QWORD PTR [r15+0x8]
  469a76:	mov    DWORD PTR [r10],r12d
  469a79:	xor    r12d,r12d
  469a7c:	kmovb  esi,k0
  469a80:	tzcnt  r12d,esi
  469a85:	inc    r12d
  469a88:	movsxd rsi,r12d
  469a8b:	mov    r9,QWORD PTR [r9+rsi*8]
  469a8f:	inc    eax
  469a91:	inc    ebx
  469a93:	and    eax,r8d
  469a96:	mov    QWORD PTR [r10+0x8],r9
  469a9a:	mov    DWORD PTR [r15],ebx
  469a9d:	mov    DWORD PTR [rcx+0xc4],eax
  469aa3:	jmp    469914 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  469aa8:	inc    eax
  469aaa:	and    eax,r8d
  469aad:	mov    DWORD PTR [rcx+0xc4],eax
  469ab3:	jmp    469914 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  469ab8:	mov    eax,0xffffffff
  469abd:	crc32  rax,QWORD PTR [rdx]
  469ac3:	mov    QWORD PTR [rsp-0x18],rax
  469ac8:	vmovd  xmm5,eax
  469acc:	jmp    4698b5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  469ad1:	mov    r9d,0xffffffff
  469ad7:	crc32  r9d,r12d
  469add:	mov    r12d,r9d
  469ae0:	mov    QWORD PTR [rsp-0x28],r12
  469ae5:	jmp    469a19 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  469aea:	xor    edi,edi
  469aec:	jmp    469396 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x406>
  469af1:	mov    r12d,0xffffffff
  469af7:	crc32  r12,r9
  469afd:	mov    QWORD PTR [rsp-0x28],r12
  469b02:	mov    r9d,r12d
  469b05:	jmp    469a19 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  469b0a:	inc    DWORD PTR [rsp-0x2c]
  469b0e:	jmp    46913a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469b13:	inc    DWORD PTR [rsp-0x2c]
  469b17:	vpxor  xmm15,xmm15,xmm15
  469b1c:	xor    r11d,r11d
  469b1f:	vpxor  xmm12,xmm12,xmm12
  469b24:	jmp    4690c3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  469b29:	inc    DWORD PTR [rsp-0x2c]
  469b2d:	jmp    4691b2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
