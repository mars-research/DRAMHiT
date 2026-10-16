0000000000468f80 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468f80:	push   rbp
  468f81:	mov    rcx,rdi
  468f84:	mov    rbp,rsp
  468f87:	push   r15
  468f89:	mov    r15,rdx
  468f8c:	push   r14
  468f8e:	push   r13
  468f90:	push   r12
  468f92:	push   rbx
  468f93:	and    rsp,0xffffffffffffffc0
  468f97:	sub    rsp,0x8
  468f9b:	mov    r11,QWORD PTR [rsi+0x8]
  468f9f:	mov    edi,DWORD PTR [rdi+0xc0]
  468fa5:	mov    eax,DWORD PTR [rcx+0xc4]
  468fab:	mov    rdx,QWORD PTR [rsi]
  468fae:	mov    r8d,DWORD PTR [rcx+0x78]
  468fb2:	mov    r9d,DWORD PTR [rcx+0x6c]
  468fb6:	mov    r10,r11
  468fb9:	mov    esi,edi
  468fbb:	shl    r10,0x4
  468fbf:	sub    esi,eax
  468fc1:	lea    rbx,[rdx+r10*1]
  468fc5:	and    esi,r8d
  468fc8:	lea    r12d,[r9-0x1]
  468fcc:	mov    QWORD PTR [rsp-0x20],rbx
  468fd1:	cmp    esi,r12d
  468fd4:	jb     46982c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8ac>
  468fda:	and    r11,0xfffffffffffffffc
  468fde:	shl    r9,0x4
  468fe2:	shl    r11,0x4
  468fe6:	mov    r14,QWORD PTR [r15+0x8]
  468fea:	mov    esi,DWORD PTR [rcx+0x80]
  468ff0:	mov    QWORD PTR [rsp-0x18],r9
  468ff5:	mov    QWORD PTR [rsp-0x38],r11
  468ffa:	lea    r10,[r9-0x1]
  468ffe:	lea    r11,[rdx+r11*1]
  469002:	mov    r9d,edi
  469005:	mov    QWORD PTR [rsp],r14
  469009:	mov    QWORD PTR [rsp-0x28],r11
  46900e:	mov    DWORD PTR [rsp-0x2c],0x0
  469016:	mov    r8,QWORD PTR [rcx+0xa0]
  46901d:	mov    rdi,QWORD PTR [rip+0x2bbcc]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469024:	shl    rax,0x4
  469028:	shl    r9,0x4
  46902c:	not    esi
  46902e:	cmp    rdx,r11
  469031:	je     469aca <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb4a>
  469037:	mov    r13d,0x55
  46903d:	mov    ebx,0xf
  469042:	mov    r12d,0xf0
  469048:	mov    r11d,0xf00
  46904e:	kmovb  k2,r13d
  469053:	mov    r13d,0xfffff000
  469059:	mov    QWORD PTR [rsp-0x40],rcx
  46905e:	mov    QWORD PTR [rsp-0x48],r15
  469063:	vpxor  xmm4,xmm4,xmm4
  469067:	mov    r14d,0xffffffff
  46906d:	kmovw  k6,ebx
  469071:	kmovw  k5,r12d
  469076:	kmovw  k4,r11d
  46907b:	kmovw  k3,r13d
  469080:	jmp    4692d1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x351>
  469085:	nop    DWORD PTR [rax]
  469088:	vmovd  xmm13,DWORD PTR [r12+0xc]
  46908f:	kaddb  k7,k7,k7
  469093:	vpcompressq zmm12{k7}{z},zmm8
  469099:	vpunpcklqdq xmm14,xmm13,xmm12
  46909e:	vshufi32x4 zmm15{k6}{z},zmm14,zmm14,0x0
  4690a5:	vmovdqa64 zmm12,zmm15
  4690ab:	mov    r11d,0x1
  4690b1:	lea    r13,[r8+rax*1]
  4690b5:	lea    r12,[rax+0x180]
  4690bc:	and    r12,r10
  4690bf:	mov    r15d,DWORD PTR [r13+0x8]
  4690c3:	andn   ecx,esi,DWORD PTR [r8+r12*1+0x8]
  4690ca:	shl    rcx,0x4
  4690ce:	andn   r12d,esi,r15d
  4690d3:	shl    r12,0x4
  4690d7:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r12*1]
  4690de:	vpbroadcastq zmm2,QWORD PTR [r13+0x0]
  4690e5:	vpcmpequq k0{k2},zmm0,zmm2
  4690ec:	add    rax,0x10
  4690f0:	and    rax,r10
  4690f3:	prefetcht0 BYTE PTR [rdi+rcx*1]
  4690f7:	kortestb k0,k0
  4690fb:	je     469740 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7c0>
  469101:	vmovd  xmm1,DWORD PTR [r13+0xc]
  469107:	kaddb  k7,k0,k0
  46910b:	vpcompressq zmm6{k7}{z},zmm0
  469111:	vpunpcklqdq xmm7,xmm1,xmm6
  469115:	vshufi32x4 zmm15{k5},zmm7,zmm7,0x0
  46911c:	vmovdqa64 zmm12,zmm15
  469122:	or     r11d,0x2
  469126:	lea    r13,[rax+0x180]
  46912d:	and    r13,r10
  469130:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  469137:	shl    rcx,0x4
  46913b:	lea    r13,[r8+rax*1]
  46913f:	mov    ebx,DWORD PTR [r13+0x8]
  469143:	andn   r12d,esi,ebx
  469148:	shl    r12,0x4
  46914c:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r12*1]
  469153:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  46915a:	vpcmpequq k0{k2},zmm8,zmm9
  469161:	add    rax,0x10
  469165:	and    rax,r10
  469168:	prefetcht0 BYTE PTR [rdi+rcx*1]
  46916c:	kortestb k0,k0
  469170:	je     4696f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x770>
  469176:	vmovd  xmm13,DWORD PTR [r13+0xc]
  46917c:	kaddb  k7,k0,k0
  469180:	vpcompressq zmm12{k7}{z},zmm8
  469186:	vpunpcklqdq xmm14,xmm13,xmm12
  46918b:	vshufi32x4 zmm15{k4},zmm14,zmm14,0x0
  469192:	vmovdqa64 zmm12,zmm15
  469198:	or     r11d,0x4
  46919c:	lea    r15,[r8+rax*1]
  4691a0:	lea    r13,[rax+0x180]
  4691a7:	and    r13,r10
  4691aa:	mov    r12d,DWORD PTR [r15+0x8]
  4691ae:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  4691b5:	shl    rcx,0x4
  4691b9:	andn   r13d,esi,r12d
  4691be:	shl    r13,0x4
  4691c2:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r13*1]
  4691c9:	vpbroadcastq zmm2,QWORD PTR [r15]
  4691cf:	vpcmpequq k0{k2},zmm0,zmm2
  4691d6:	add    rax,0x10
  4691da:	and    rax,r10
  4691dd:	prefetcht0 BYTE PTR [rdi+rcx*1]
  4691e1:	kortestb k0,k0
  4691e5:	lea    rcx,[r8+r9*1]
  4691e9:	je     4696a8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x728>
  4691ef:	vmovd  xmm1,DWORD PTR [r15+0xc]
  4691f5:	kaddb  k7,k0,k0
  4691f9:	vpcompressq zmm6{k7}{z},zmm0
  4691ff:	vpunpcklqdq xmm7,xmm1,xmm6
  469203:	vshufi32x4 zmm15{k3},zmm7,zmm7,0x0
  46920a:	or     r11d,0x8
  46920e:	vmovdqa64 zmm12,zmm15
  469214:	cmp    r11d,0xf
  469218:	jne    4697f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x878>
  46921e:	mov    r15,QWORD PTR [rsp]
  469222:	vmovdqu64 ZMMWORD PTR [r15],zmm15
  469228:	add    r15,0x40
  46922c:	mov    QWORD PTR [rsp],r15
  469230:	mov    rbx,r14
  469233:	mov    r11,r14
  469236:	crc32  rbx,QWORD PTR [rdx]
  46923c:	crc32  r11,QWORD PTR [rdx+0x20]
  469243:	andn   r13d,esi,ebx
  469248:	shl    r13,0x4
  46924c:	andn   r15d,esi,r11d
  469251:	shl    r15,0x4
  469255:	prefetcht2 BYTE PTR [rdi+r13*1]
  46925a:	prefetcht2 BYTE PTR [rdi+r15*1]
  46925f:	mov    r13,r14
  469262:	mov    r15,r14
  469265:	crc32  r13,QWORD PTR [rdx+0x10]
  46926c:	crc32  r15,QWORD PTR [rdx+0x30]
  469273:	andn   r12d,esi,r13d
  469278:	shl    r12,0x4
  46927c:	prefetcht2 BYTE PTR [rdi+r12*1]
  469281:	andn   r12d,esi,r15d
  469286:	shl    r12,0x4
  46928a:	prefetcht2 BYTE PTR [rdi+r12*1]
  46928f:	lea    r12,[r9+0x40]
  469293:	vmovdqu64 zmm15,ZMMWORD PTR [rdx]
  469299:	cmp    QWORD PTR [rsp-0x18],r12
  46929e:	jb     469788 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x808>
  4692a4:	vmovdqu64 ZMMWORD PTR [rcx],zmm15
  4692aa:	mov    DWORD PTR [rcx+0x8],ebx
  4692ad:	mov    DWORD PTR [r8+r9*1+0x18],r13d
  4692b2:	mov    DWORD PTR [r8+r9*1+0x28],r11d
  4692b7:	mov    DWORD PTR [r8+r9*1+0x38],r15d
  4692bc:	mov    r9,r12
  4692bf:	add    rdx,0x40
  4692c3:	and    r9,r10
  4692c6:	cmp    QWORD PTR [rsp-0x28],rdx
  4692cb:	je     469370 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3f0>
  4692d1:	lea    r12,[r8+rax*1]
  4692d5:	mov    r11d,DWORD PTR [r12+0x8]
  4692da:	andn   r13d,esi,r11d
  4692df:	shl    r13,0x4
  4692e3:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r13*1]
  4692ea:	vpbroadcastq zmm9,QWORD PTR [r12]
  4692f1:	vpcmpequq k7{k2},zmm8,zmm9
  4692f8:	lea    rcx,[rax+0x180]
  4692ff:	add    rax,0x10
  469303:	and    rcx,r10
  469306:	and    rax,r10
  469309:	andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
  469310:	shl    r15,0x4
  469314:	kortestb k7,k7
  469318:	prefetcht0 BYTE PTR [rdi+r15*1]
  46931d:	jne    469088 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
  469323:	vpcmpequq k1{k2},zmm8,zmm4
  46932a:	kortestb k1,k1
  46932e:	jne    469af3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb73>
  469334:	vmovdqu xmm10,XMMWORD PTR [r12]
  46933a:	mov    rcx,r14
  46933d:	crc32  rcx,r11
  469343:	vpinsrd xmm11,xmm10,ecx,0x2
  469349:	andn   r15d,esi,ecx
  46934e:	shl    r15,0x4
  469352:	prefetcht2 BYTE PTR [rdi+r15*1]
  469357:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  46935d:	add    r9,0x10
  469361:	and    r9,r10
  469364:	jmp    4692d1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x351>
  469369:	nop    DWORD PTR [rax+0x0]
  469370:	mov    rcx,QWORD PTR [rsp-0x40]
  469375:	mov    r15,QWORD PTR [rsp-0x48]
  46937a:	mov    edi,DWORD PTR [rsp-0x2c]
  46937e:	vmovq  xmm14,r9
  469383:	vpinsrq xmm0,xmm14,rax,0x1
  469389:	mov    rsi,QWORD PTR [rsp-0x38]
  46938e:	vpsrlq xmm2,xmm0,0x4
  469393:	vpmovqd xmm3,xmm2
  469399:	sar    rsi,0x4
  46939d:	vmovq  QWORD PTR [rcx+0xc0],xmm3
  4693a5:	sub    rsi,rdi
  4693a8:	add    DWORD PTR [r15],esi
  4693ab:	vpextrd eax,xmm3,0x1
  4693b1:	cmp    rdx,QWORD PTR [rsp-0x20]
  4693b6:	je     469690 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x710>
  4693bc:	mov    rdi,QWORD PTR [rcx+0x88]
  4693c3:	mov    rbx,QWORD PTR [rcx+0x80]
  4693ca:	mov    r8,QWORD PTR [rcx+0x60]
  4693ce:	dec    rdi
  4693d1:	mov    QWORD PTR [rsp-0x18],rbx
  4693d6:	mov    QWORD PTR [rsp],r8
  4693da:	mov    QWORD PTR [rsp-0x28],rdi
  4693df:	mov    r10d,DWORD PTR [rcx+0x78]
  4693e3:	mov    r11,QWORD PTR [rip+0x2b806]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4693ea:	mov    r9,QWORD PTR [rcx+0xa0]
  4693f1:	movzx  r13d,BYTE PTR [rip+0x2b707]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4693f9:	mov    r12,QWORD PTR [rip+0x2b708]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469400:	mov    r14d,0x55
  469406:	vpxor  xmm7,xmm7,xmm7
  46940a:	kmovb  k2,r14d
  46940f:	nop
  469410:	lea    esi,[rax+0x18]
  469413:	and    esi,r10d
  469416:	shl    rsi,0x4
  46941a:	mov    r8d,ebx
  46941d:	and    r8d,DWORD PTR [r9+rsi*1+0x8]
  469422:	mov    esi,eax
  469424:	shl    rsi,0x4
  469428:	add    rsi,r9
  46942b:	mov    r14,r8
  46942e:	mov    r8,QWORD PTR [rsi]
  469431:	shl    r14,0x4
  469435:	prefetcht0 BYTE PTR [r11+r14*1]
  46943a:	cmp    r8,QWORD PTR [rcx+0x90]
  469441:	jne    469500 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x580>
  469447:	test   r13b,r13b
  46944a:	je     46946a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4ea>
  46944c:	mov    r14d,DWORD PTR [r15]
  46944f:	mov    esi,DWORD PTR [rsi+0xc]
  469452:	mov    r8,r14
  469455:	shl    r14,0x4
  469459:	add    r14,QWORD PTR [r15+0x8]
  46945d:	inc    r8d
  469460:	mov    DWORD PTR [r14],esi
  469463:	mov    QWORD PTR [r14+0x8],r12
  469467:	mov    DWORD PTR [r15],r8d
  46946a:	inc    eax
  46946c:	and    eax,r10d
  46946f:	mov    DWORD PTR [rcx+0xc4],eax
  469475:	test   r12,r12
  469478:	jne    469410 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x490>
  46947a:	cmp    QWORD PTR [rsp],0x4
  46947f:	je     4695f5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x675>
  469485:	nop    DWORD PTR [rax]
  469488:	cmp    QWORD PTR [rsp],0x8
  46948d:	je     469670 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6f0>
  469493:	vmovd  xmm15,DWORD PTR [rsp-0x10]
  469499:	mov    rdi,QWORD PTR [rdx]
  46949c:	mov    esi,DWORD PTR [rcx+0xc0]
  4694a2:	mov    r8,QWORD PTR [rsp-0x28]
  4694a7:	mov    rax,rsi
  4694aa:	and    r8,QWORD PTR [rsp-0x10]
  4694af:	vpinsrd xmm9,xmm15,DWORD PTR [rdx+0xc],0x1
  4694b6:	and    r8,0xfffffffffffffffc
  4694ba:	shl    rsi,0x4
  4694be:	inc    eax
  4694c0:	add    rsi,r9
  4694c3:	shl    r8,0x4
  4694c7:	and    eax,r10d
  4694ca:	add    rdx,0x10
  4694ce:	prefetcht2 BYTE PTR [r11+r8*1]
  4694d3:	mov    QWORD PTR [rsi],rdi
  4694d6:	vmovq  QWORD PTR [rsi+0x8],xmm9
  4694db:	mov    DWORD PTR [rcx+0xc0],eax
  4694e1:	cmp    rdx,QWORD PTR [rsp-0x20]
  4694e6:	je     469690 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x710>
  4694ec:	mov    eax,DWORD PTR [rcx+0xc4]
  4694f2:	jmp    469410 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x490>
  4694f7:	nop    WORD PTR [rax+rax*1+0x0]
  469500:	mov    r14d,DWORD PTR [rsi+0x8]
  469504:	mov    edi,ebx
  469506:	and    edi,r14d
  469509:	shl    rdi,0x4
  46950d:	add    rdi,r11
  469510:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  469516:	vpbroadcastq zmm6,r8
  46951c:	vpcmpequq k0{k2},zmm5,zmm6
  469523:	kortestb k0,k0
  469527:	jne    4695b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x630>
  46952d:	vpcmpequq k3{k2},zmm5,zmm7
  469534:	kortestb k3,k3
  469538:	jne    469620 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6a0>
  46953e:	cmp    QWORD PTR [rsp],0x4
  469543:	mov    edi,r14d
  469546:	je     469630 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  46954c:	cmp    QWORD PTR [rsp],0x8
  469551:	je     469650 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d0>
  469557:	vmovd  xmm1,DWORD PTR [rsp-0x8]
  46955d:	mov    edi,DWORD PTR [rcx+0xc0]
  469563:	mov    r14,QWORD PTR [rsp-0x18]
  469568:	vpinsrd xmm4,xmm1,DWORD PTR [rsi+0xc],0x1
  46956f:	mov    rsi,rdi
  469572:	and    r14,QWORD PTR [rsp-0x8]
  469577:	shl    rdi,0x4
  46957b:	inc    esi
  46957d:	inc    eax
  46957f:	add    rdi,r9
  469582:	shl    r14,0x4
  469586:	and    esi,r10d
  469589:	and    eax,r10d
  46958c:	prefetcht2 BYTE PTR [r11+r14*1]
  469591:	mov    QWORD PTR [rdi],r8
  469594:	vmovq  QWORD PTR [rdi+0x8],xmm4
  469599:	mov    DWORD PTR [rcx+0xc0],esi
  46959f:	mov    DWORD PTR [rcx+0xc4],eax
  4695a5:	jmp    469410 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x490>
  4695aa:	nop    WORD PTR [rax+rax*1+0x0]
  4695b0:	mov    r8d,DWORD PTR [r15]
  4695b3:	mov    esi,DWORD PTR [rsi+0xc]
  4695b6:	mov    r14,r8
  4695b9:	shl    r8,0x4
  4695bd:	add    r8,QWORD PTR [r15+0x8]
  4695c1:	mov    DWORD PTR [r8],esi
  4695c4:	kmovb  esi,k0
  4695c8:	tzcnt  esi,esi
  4695cc:	inc    esi
  4695ce:	movsxd rsi,esi
  4695d1:	mov    rdi,QWORD PTR [rdi+rsi*8]
  4695d5:	inc    eax
  4695d7:	inc    r14d
  4695da:	and    eax,r10d
  4695dd:	cmp    QWORD PTR [rsp],0x4
  4695e2:	mov    QWORD PTR [r8+0x8],rdi
  4695e6:	mov    DWORD PTR [r15],r14d
  4695e9:	mov    DWORD PTR [rcx+0xc4],eax
  4695ef:	jne    469488 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x508>
  4695f5:	mov    r14d,0xffffffff
  4695fb:	crc32  r14d,DWORD PTR [rdx]
  469601:	vmovd  xmm8,r14d
  469606:	mov    rdi,QWORD PTR [rdx]
  469609:	vmovdqa xmm15,xmm8
  46960e:	vmovq  QWORD PTR [rsp-0x10],xmm8
  469614:	jmp    46949c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x51c>
  469619:	nop    DWORD PTR [rax+0x0]
  469620:	inc    eax
  469622:	and    eax,r10d
  469625:	mov    DWORD PTR [rcx+0xc4],eax
  46962b:	jmp    46947a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fa>
  469630:	mov    edi,0xffffffff
  469635:	crc32  edi,r14d
  46963b:	vmovd  xmm12,edi
  46963f:	vmovdqa xmm1,xmm12
  469643:	vmovq  QWORD PTR [rsp-0x8],xmm12
  469649:	jmp    46955d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5dd>
  46964e:	xchg   ax,ax
  469650:	mov    r14d,0xffffffff
  469656:	crc32  r14,rdi
  46965c:	mov    QWORD PTR [rsp-0x8],r14
  469661:	vmovd  xmm1,r14d
  469666:	jmp    46955d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5dd>
  46966b:	nop    DWORD PTR [rax+rax*1+0x0]
  469670:	mov    rdi,QWORD PTR [rdx]
  469673:	mov    eax,0xffffffff
  469678:	crc32  rax,rdi
  46967e:	mov    QWORD PTR [rsp-0x10],rax
  469683:	vmovd  xmm15,eax
  469687:	jmp    46949c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x51c>
  46968c:	nop    DWORD PTR [rax+0x0]
  469690:	vzeroupper 
  469693:	lea    rsp,[rbp-0x28]
  469697:	pop    rbx
  469698:	pop    r12
  46969a:	pop    r13
  46969c:	pop    r14
  46969e:	pop    r15
  4696a0:	pop    rbp
  4696a1:	ret    
  4696a2:	nop    WORD PTR [rax+rax*1+0x0]
  4696a8:	vpcmpequq k1{k2},zmm0,zmm4
  4696af:	kortestb k1,k1
  4696b3:	jne    4697f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x870>
  4696b9:	vmovdqu xmm3,XMMWORD PTR [r15]
  4696be:	mov    rbx,r14
  4696c1:	crc32  rbx,r12
  4696c7:	vpinsrd xmm5,xmm3,ebx,0x2
  4696cd:	add    r9,0x10
  4696d1:	andn   r12d,esi,ebx
  4696d6:	shl    r12,0x4
  4696da:	and    r9,r10
  4696dd:	prefetcht2 BYTE PTR [rdi+r12*1]
  4696e2:	vmovdqu XMMWORD PTR [rcx],xmm5
  4696e6:	jmp    46919c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x21c>
  4696eb:	nop    DWORD PTR [rax+rax*1+0x0]
  4696f0:	vpcmpequq k1{k2},zmm8,zmm4
  4696f7:	kortestb k1,k1
  4696fb:	jne    469b09 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb89>
  469701:	vmovdqu xmm10,XMMWORD PTR [r13+0x0]
  469707:	mov    rcx,r14
  46970a:	crc32  rcx,rbx
  469710:	vpinsrd xmm11,xmm10,ecx,0x2
  469716:	andn   r15d,esi,ecx
  46971b:	shl    r15,0x4
  46971f:	prefetcht2 BYTE PTR [rdi+r15*1]
  469724:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  46972a:	add    r9,0x10
  46972e:	and    r9,r10
  469731:	jmp    469126 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a6>
  469736:	cs nop WORD PTR [rax+rax*1+0x0]
  469740:	vpcmpequq k1{k2},zmm0,zmm4
  469747:	kortestb k1,k1
  46974b:	jne    469aea <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb6a>
  469751:	vmovdqu xmm3,XMMWORD PTR [r13+0x0]
  469757:	mov    rcx,r14
  46975a:	crc32  rcx,r15
  469760:	vpinsrd xmm5,xmm3,ecx,0x2
  469766:	andn   ebx,esi,ecx
  46976b:	shl    rbx,0x4
  46976f:	prefetcht2 BYTE PTR [rdi+rbx*1]
  469773:	vmovdqu XMMWORD PTR [r8+r9*1],xmm5
  469779:	add    r9,0x10
  46977d:	and    r9,r10
  469780:	jmp    4690b1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x131>
  469785:	nop    DWORD PTR [rax]
  469788:	vmovd  xmm10,ebx
  46978c:	vpinsrd xmm11,xmm10,r13d,0x1
  469792:	mov    r13,QWORD PTR [rsp-0x18]
  469797:	vmovd  xmm8,r11d
  46979c:	mov    r11,r13
  46979f:	vpinsrd xmm9,xmm8,r15d,0x1
  4697a5:	sub    r11,r9
  4697a8:	mov    ebx,0x4444
  4697ad:	vpunpcklqdq xmm13,xmm11,xmm9
  4697b2:	shr    r11,0x2
  4697b6:	mov    r15d,0x1
  4697bc:	kmovw  k7,ebx
  4697c0:	shlx   r11d,r15d,r11d
  4697c5:	vpexpandd zmm15{k7},zmm13
  4697cb:	lea    ebx,[r11-0x1]
  4697cf:	sub    r9,r13
  4697d2:	neg    r11d
  4697d5:	kmovw  k1,ebx
  4697d9:	vmovdqu32 ZMMWORD PTR [rcx]{k1},zmm15
  4697df:	kmovw  k7,r11d
  4697e4:	vmovdqu32 ZMMWORD PTR [r8+r9*1]{k7},zmm15
  4697eb:	jmp    4692bc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x33c>
  4697f0:	inc    DWORD PTR [rsp-0x2c]
  4697f4:	nop    DWORD PTR [rax+0x0]
  4697f8:	mov    r12,QWORD PTR [rsp]
  4697fc:	mov    r15d,0x55
  469802:	pdep   r13d,r11d,r15d
  469807:	popcnt r11d,r11d
  46980c:	lea    ebx,[r13+r13*2+0x0]
  469811:	shl    r11,0x4
  469815:	kmovb  k1,ebx
  469819:	vpcompressq ZMMWORD PTR [r12]{k1},zmm12
  469820:	add    r12,r11
  469823:	mov    QWORD PTR [rsp],r12
  469827:	jmp    469230 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b0>
  46982c:	cmp    rdx,QWORD PTR [rsp-0x20]
  469831:	je     469693 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x713>
  469837:	mov    r12,QWORD PTR [rcx+0x88]
  46983e:	movzx  r13d,BYTE PTR [rip+0x2b2ba]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469846:	mov    r9,QWORD PTR [rip+0x2b2bb]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46984d:	mov    r10,QWORD PTR [rcx+0x60]
  469851:	mov    ebx,0x55
  469856:	dec    r12
  469859:	kmovb  k2,r13d
  46985e:	mov    QWORD PTR [rsp],r10
  469862:	mov    QWORD PTR [rsp-0x8],r12
  469867:	mov    r14,QWORD PTR [rip+0x2b382]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46986e:	mov    r11,QWORD PTR [rcx+0xa0]
  469875:	mov    esi,edi
  469877:	vpxor  xmm2,xmm2,xmm2
  46987b:	mov    r13,r9
  46987e:	kmovb  k1,ebx
  469882:	jmp    4698ea <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x96a>
  469884:	cmp    QWORD PTR [rsp],0x8
  469889:	je     469a98 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb18>
  46988f:	vmovd  xmm5,DWORD PTR [rsp-0x18]
  469895:	mov    r12,QWORD PTR [rsp-0x8]
  46989a:	mov    esi,edi
  46989c:	and    r12,QWORD PTR [rsp-0x18]
  4698a1:	vpinsrd xmm7,xmm5,DWORD PTR [rdx+0xc],0x1
  4698a8:	mov    r10,QWORD PTR [rdx]
  4698ab:	and    r12,0xfffffffffffffffc
  4698af:	shl    rsi,0x4
  4698b3:	add    rsi,r11
  4698b6:	shl    r12,0x4
  4698ba:	prefetcht2 BYTE PTR [r14+r12*1]
  4698bf:	mov    QWORD PTR [rsi],r10
  4698c2:	vmovq  QWORD PTR [rsi+0x8],xmm7
  4698c7:	lea    esi,[rdi+0x1]
  4698ca:	and    esi,r8d
  4698cd:	add    rdx,0x10
  4698d1:	mov    DWORD PTR [rcx+0xc0],esi
  4698d7:	cmp    QWORD PTR [rsp-0x20],rdx
  4698dc:	je     469690 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x710>
  4698e2:	mov    eax,DWORD PTR [rcx+0xc4]
  4698e8:	mov    edi,esi
  4698ea:	sub    esi,eax
  4698ec:	and    esi,r8d
  4698ef:	cmp    r8d,esi
  4698f2:	jbe    469915 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x995>
  4698f4:	cmp    QWORD PTR [rsp],0x4
  4698f9:	jne    469884 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x904>
  4698fb:	mov    ebx,0xffffffff
  469900:	crc32  ebx,DWORD PTR [rdx]
  469905:	vmovd  xmm6,ebx
  469909:	vmovdqa xmm5,xmm6
  46990d:	vmovq  QWORD PTR [rsp-0x18],xmm6
  469913:	jmp    469895 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x915>
  469915:	mov    rbx,QWORD PTR [rcx+0x80]
  46991c:	mov    QWORD PTR [rsp-0x10],rbx
  469921:	nop    DWORD PTR [rax+0x0]
  469928:	lea    esi,[rax+0x18]
  46992b:	and    esi,r8d
  46992e:	shl    rsi,0x4
  469932:	mov    r9d,ebx
  469935:	and    r9d,DWORD PTR [r11+rsi*1+0x8]
  46993a:	mov    esi,eax
  46993c:	mov    r10,r9
  46993f:	shl    rsi,0x4
  469943:	shl    r10,0x4
  469947:	add    rsi,r11
  46994a:	prefetcht0 BYTE PTR [r14+r10*1]
  46994f:	mov    r10,QWORD PTR [rsi]
  469952:	cmp    r10,QWORD PTR [rcx+0x90]
  469959:	jne    4699a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa20>
  46995b:	kortestb k2,k2
  46995f:	je     469982 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa02>
  469961:	mov    r12d,DWORD PTR [r15]
  469964:	mov    esi,DWORD PTR [rsi+0xc]
  469967:	mov    r10,r12
  46996a:	shl    r12,0x4
  46996e:	add    r12,QWORD PTR [r15+0x8]
  469972:	lea    r9d,[r10+0x1]
  469976:	mov    DWORD PTR [r12],esi
  46997a:	mov    QWORD PTR [r12+0x8],r13
  46997f:	mov    DWORD PTR [r15],r9d
  469982:	inc    eax
  469984:	and    eax,r8d
  469987:	mov    DWORD PTR [rcx+0xc4],eax
  46998d:	test   r13,r13
  469990:	jne    469928 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a8>
  469992:	jmp    4698f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x974>
  469997:	nop    WORD PTR [rax+rax*1+0x0]
  4699a0:	mov    r12d,DWORD PTR [rsi+0x8]
  4699a4:	mov    r9d,ebx
  4699a7:	and    r9d,r12d
  4699aa:	shl    r9,0x4
  4699ae:	add    r9,r14
  4699b1:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  4699b7:	vpbroadcastq zmm1,r10
  4699bd:	vpcmpequq k0{k1},zmm0,zmm1
  4699c4:	kortestb k0,k0
  4699c8:	jne    469a44 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xac4>
  4699ca:	vpcmpequq k3{k1},zmm0,zmm2
  4699d1:	kortestb k3,k3
  4699d5:	jne    469a88 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb08>
  4699db:	cmp    QWORD PTR [rsp],0x4
  4699e0:	mov    r9d,r12d
  4699e3:	je     469ab1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb31>
  4699e9:	cmp    QWORD PTR [rsp],0x8
  4699ee:	je     469ad1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb51>
  4699f4:	mov    r9d,DWORD PTR [rsp-0x28]
  4699f9:	mov    r12,QWORD PTR [rsp-0x10]
  4699fe:	vmovd  xmm4,r9d
  469a03:	vpinsrd xmm3,xmm4,DWORD PTR [rsi+0xc],0x1
  469a0a:	mov    esi,edi
  469a0c:	and    r12,QWORD PTR [rsp-0x28]
  469a11:	shl    rsi,0x4
  469a15:	inc    edi
  469a17:	inc    eax
  469a19:	add    rsi,r11
  469a1c:	shl    r12,0x4
  469a20:	and    edi,r8d
  469a23:	and    eax,r8d
  469a26:	prefetcht2 BYTE PTR [r14+r12*1]
  469a2b:	mov    QWORD PTR [rsi],r10
  469a2e:	vmovq  QWORD PTR [rsi+0x8],xmm3
  469a33:	mov    DWORD PTR [rcx+0xc0],edi
  469a39:	mov    DWORD PTR [rcx+0xc4],eax
  469a3f:	jmp    469928 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a8>
  469a44:	mov    r10d,DWORD PTR [r15]
  469a47:	mov    r12d,DWORD PTR [rsi+0xc]
  469a4b:	mov    rbx,r10
  469a4e:	shl    r10,0x4
  469a52:	add    r10,QWORD PTR [r15+0x8]
  469a56:	mov    DWORD PTR [r10],r12d
  469a59:	xor    r12d,r12d
  469a5c:	kmovb  esi,k0
  469a60:	tzcnt  r12d,esi
  469a65:	inc    r12d
  469a68:	movsxd rsi,r12d
  469a6b:	mov    r9,QWORD PTR [r9+rsi*8]
  469a6f:	inc    eax
  469a71:	inc    ebx
  469a73:	and    eax,r8d
  469a76:	mov    QWORD PTR [r10+0x8],r9
  469a7a:	mov    DWORD PTR [r15],ebx
  469a7d:	mov    DWORD PTR [rcx+0xc4],eax
  469a83:	jmp    4698f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x974>
  469a88:	inc    eax
  469a8a:	and    eax,r8d
  469a8d:	mov    DWORD PTR [rcx+0xc4],eax
  469a93:	jmp    4698f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x974>
  469a98:	mov    eax,0xffffffff
  469a9d:	crc32  rax,QWORD PTR [rdx]
  469aa3:	mov    QWORD PTR [rsp-0x18],rax
  469aa8:	vmovd  xmm5,eax
  469aac:	jmp    469895 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x915>
  469ab1:	mov    r9d,0xffffffff
  469ab7:	crc32  r9d,r12d
  469abd:	mov    r12d,r9d
  469ac0:	mov    QWORD PTR [rsp-0x28],r12
  469ac5:	jmp    4699f9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa79>
  469aca:	xor    edi,edi
  469acc:	jmp    46937e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3fe>
  469ad1:	mov    r12d,0xffffffff
  469ad7:	crc32  r12,r9
  469add:	mov    QWORD PTR [rsp-0x28],r12
  469ae2:	mov    r9d,r12d
  469ae5:	jmp    4699f9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa79>
  469aea:	inc    DWORD PTR [rsp-0x2c]
  469aee:	jmp    469126 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a6>
  469af3:	inc    DWORD PTR [rsp-0x2c]
  469af7:	vpxor  xmm15,xmm15,xmm15
  469afc:	xor    r11d,r11d
  469aff:	vpxor  xmm12,xmm12,xmm12
  469b04:	jmp    4690b1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x131>
  469b09:	inc    DWORD PTR [rsp-0x2c]
  469b0d:	jmp    46919c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x21c>
