0000000000468db0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468db0:	push   rbp
  468db1:	mov    rcx,rdi
  468db4:	mov    rbp,rsp
  468db7:	push   r15
  468db9:	mov    r15,rdx
  468dbc:	push   r14
  468dbe:	push   r13
  468dc0:	push   r12
  468dc2:	push   rbx
  468dc3:	and    rsp,0xffffffffffffffc0
  468dc7:	sub    rsp,0x8
  468dcb:	mov    r11,QWORD PTR [rsi+0x8]
  468dcf:	mov    edi,DWORD PTR [rdi+0xc0]
  468dd5:	mov    eax,DWORD PTR [rcx+0xc4]
  468ddb:	mov    rdx,QWORD PTR [rsi]
  468dde:	mov    r8d,DWORD PTR [rcx+0x78]
  468de2:	mov    r9d,DWORD PTR [rcx+0x6c]
  468de6:	mov    r10,r11
  468de9:	mov    esi,edi
  468deb:	shl    r10,0x4
  468def:	sub    esi,eax
  468df1:	lea    rbx,[rdx+r10*1]
  468df5:	and    esi,r8d
  468df8:	lea    r12d,[r9-0x1]
  468dfc:	mov    QWORD PTR [rsp-0x20],rbx
  468e01:	cmp    esi,r12d
  468e04:	jb     46966c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8bc>
  468e0a:	and    r11,0xfffffffffffffffc
  468e0e:	shl    r9,0x4
  468e12:	shl    r11,0x4
  468e16:	mov    r14,QWORD PTR [r15+0x8]
  468e1a:	mov    esi,DWORD PTR [rcx+0x80]
  468e20:	mov    QWORD PTR [rsp-0x18],r9
  468e25:	mov    QWORD PTR [rsp-0x38],r11
  468e2a:	lea    r10,[r9-0x1]
  468e2e:	lea    r11,[rdx+r11*1]
  468e32:	mov    r9d,edi
  468e35:	mov    QWORD PTR [rsp],r14
  468e39:	mov    QWORD PTR [rsp-0x28],r11
  468e3e:	mov    DWORD PTR [rsp-0x2c],0x0
  468e46:	mov    r8,QWORD PTR [rcx+0xa0]
  468e4d:	mov    rdi,QWORD PTR [rip+0x2bd9c]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468e54:	shl    rax,0x4
  468e58:	shl    r9,0x4
  468e5c:	not    esi
  468e5e:	cmp    rdx,r11
  468e61:	je     46990a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb5a>
  468e67:	mov    r13d,0x55
  468e6d:	mov    ebx,0xf
  468e72:	mov    r12d,0xf0
  468e78:	mov    r11d,0xf00
  468e7e:	kmovb  k2,r13d
  468e83:	mov    r13d,0xfffff000
  468e89:	mov    QWORD PTR [rsp-0x40],rcx
  468e8e:	mov    QWORD PTR [rsp-0x48],r15
  468e93:	vpxor  xmm4,xmm4,xmm4
  468e97:	mov    r14d,0xffffffff
  468e9d:	kmovw  k6,ebx
  468ea1:	kmovw  k5,r12d
  468ea6:	kmovw  k4,r11d
  468eab:	kmovw  k3,r13d
  468eb0:	jmp    469109 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  468eb5:	nop    DWORD PTR [rax]
  468eb8:	vmovd  xmm13,DWORD PTR [r12+0xc]
  468ebf:	kshiftlb k7,k7,0x1
  468ec5:	vpcompressq zmm12{k7}{z},zmm8
  468ecb:	vpunpcklqdq xmm14,xmm13,xmm12
  468ed0:	vshufi32x4 zmm15{k6}{z},zmm14,zmm14,0x0
  468ed7:	vmovdqa64 zmm12,zmm15
  468edd:	mov    r11d,0x1
  468ee3:	lea    r13,[r8+rax*1]
  468ee7:	lea    r12,[rax+0x180]
  468eee:	and    r12,r10
  468ef1:	mov    r15d,DWORD PTR [r13+0x8]
  468ef5:	andn   ecx,esi,DWORD PTR [r8+r12*1+0x8]
  468efc:	shl    rcx,0x4
  468f00:	andn   r12d,esi,r15d
  468f05:	shl    r12,0x4
  468f09:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r12*1]
  468f10:	vpbroadcastq zmm2,QWORD PTR [r13+0x0]
  468f17:	vpcmpequq k0{k2},zmm0,zmm2
  468f1e:	add    rax,0x10
  468f22:	and    rax,r10
  468f25:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468f29:	kortestb k0,k0
  468f2d:	je     469580 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
  468f33:	vmovd  xmm1,DWORD PTR [r13+0xc]
  468f39:	kshiftlb k7,k0,0x1
  468f3f:	vpcompressq zmm6{k7}{z},zmm0
  468f45:	vpunpcklqdq xmm7,xmm1,xmm6
  468f49:	vshufi32x4 zmm15{k5},zmm7,zmm7,0x0
  468f50:	vmovdqa64 zmm12,zmm15
  468f56:	or     r11d,0x2
  468f5a:	lea    r13,[rax+0x180]
  468f61:	and    r13,r10
  468f64:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  468f6b:	shl    rcx,0x4
  468f6f:	lea    r13,[r8+rax*1]
  468f73:	mov    ebx,DWORD PTR [r13+0x8]
  468f77:	andn   r12d,esi,ebx
  468f7c:	shl    r12,0x4
  468f80:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r12*1]
  468f87:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  468f8e:	vpcmpequq k0{k2},zmm8,zmm9
  468f95:	add    rax,0x10
  468f99:	and    rax,r10
  468f9c:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468fa0:	kortestb k0,k0
  468fa4:	je     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x780>
  468faa:	vmovd  xmm13,DWORD PTR [r13+0xc]
  468fb0:	kshiftlb k7,k0,0x1
  468fb6:	vpcompressq zmm12{k7}{z},zmm8
  468fbc:	vpunpcklqdq xmm14,xmm13,xmm12
  468fc1:	vshufi32x4 zmm15{k4},zmm14,zmm14,0x0
  468fc8:	vmovdqa64 zmm12,zmm15
  468fce:	or     r11d,0x4
  468fd2:	lea    r15,[r8+rax*1]
  468fd6:	lea    r13,[rax+0x180]
  468fdd:	and    r13,r10
  468fe0:	mov    r12d,DWORD PTR [r15+0x8]
  468fe4:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  468feb:	shl    rcx,0x4
  468fef:	andn   r13d,esi,r12d
  468ff4:	shl    r13,0x4
  468ff8:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r13*1]
  468fff:	vpbroadcastq zmm2,QWORD PTR [r15]
  469005:	vpcmpequq k0{k2},zmm0,zmm2
  46900c:	add    rax,0x10
  469010:	and    rax,r10
  469013:	prefetcht0 BYTE PTR [rdi+rcx*1]
  469017:	kortestb k0,k0
  46901b:	lea    rcx,[r8+r9*1]
  46901f:	je     4694e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
  469025:	vmovd  xmm1,DWORD PTR [r15+0xc]
  46902b:	kshiftlb k7,k0,0x1
  469031:	vpcompressq zmm6{k7}{z},zmm0
  469037:	vpunpcklqdq xmm7,xmm1,xmm6
  46903b:	vshufi32x4 zmm15{k3},zmm7,zmm7,0x0
  469042:	or     r11d,0x8
  469046:	vmovdqa64 zmm12,zmm15
  46904c:	cmp    r11d,0xf
  469050:	jne    469638 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x888>
  469056:	mov    r15,QWORD PTR [rsp]
  46905a:	vmovdqu64 ZMMWORD PTR [r15],zmm15
  469060:	add    r15,0x40
  469064:	mov    QWORD PTR [rsp],r15
  469068:	mov    rbx,r14
  46906b:	mov    r11,r14
  46906e:	crc32  rbx,QWORD PTR [rdx]
  469074:	crc32  r11,QWORD PTR [rdx+0x20]
  46907b:	andn   r13d,esi,ebx
  469080:	shl    r13,0x4
  469084:	andn   r15d,esi,r11d
  469089:	shl    r15,0x4
  46908d:	prefetcht2 BYTE PTR [rdi+r13*1]
  469092:	prefetcht2 BYTE PTR [rdi+r15*1]
  469097:	mov    r13,r14
  46909a:	mov    r15,r14
  46909d:	crc32  r13,QWORD PTR [rdx+0x10]
  4690a4:	crc32  r15,QWORD PTR [rdx+0x30]
  4690ab:	andn   r12d,esi,r13d
  4690b0:	shl    r12,0x4
  4690b4:	prefetcht2 BYTE PTR [rdi+r12*1]
  4690b9:	andn   r12d,esi,r15d
  4690be:	shl    r12,0x4
  4690c2:	prefetcht2 BYTE PTR [rdi+r12*1]
  4690c7:	lea    r12,[r9+0x40]
  4690cb:	vmovdqu64 zmm15,ZMMWORD PTR [rdx]
  4690d1:	cmp    QWORD PTR [rsp-0x18],r12
  4690d6:	jb     4695c8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x818>
  4690dc:	vmovdqu64 ZMMWORD PTR [rcx],zmm15
  4690e2:	mov    DWORD PTR [rcx+0x8],ebx
  4690e5:	mov    DWORD PTR [r8+r9*1+0x18],r13d
  4690ea:	mov    DWORD PTR [r8+r9*1+0x28],r11d
  4690ef:	mov    DWORD PTR [r8+r9*1+0x38],r15d
  4690f4:	mov    r9,r12
  4690f7:	add    rdx,0x40
  4690fb:	and    r9,r10
  4690fe:	cmp    QWORD PTR [rsp-0x28],rdx
  469103:	je     4691a8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3f8>
  469109:	lea    r12,[r8+rax*1]
  46910d:	mov    r11d,DWORD PTR [r12+0x8]
  469112:	andn   r13d,esi,r11d
  469117:	shl    r13,0x4
  46911b:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r13*1]
  469122:	vpbroadcastq zmm9,QWORD PTR [r12]
  469129:	vpcmpequq k7{k2},zmm8,zmm9
  469130:	lea    rcx,[rax+0x180]
  469137:	add    rax,0x10
  46913b:	and    rcx,r10
  46913e:	and    rax,r10
  469141:	andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
  469148:	shl    r15,0x4
  46914c:	kortestb k7,k7
  469150:	prefetcht0 BYTE PTR [rdi+r15*1]
  469155:	jne    468eb8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
  46915b:	vpcmpequq k1{k2},zmm8,zmm4
  469162:	kortestb k1,k1
  469166:	jne    469933 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb83>
  46916c:	vmovdqu xmm10,XMMWORD PTR [r12]
  469172:	mov    rcx,r14
  469175:	crc32  rcx,r11
  46917b:	vpinsrd xmm11,xmm10,ecx,0x2
  469181:	andn   r15d,esi,ecx
  469186:	shl    r15,0x4
  46918a:	prefetcht2 BYTE PTR [rdi+r15*1]
  46918f:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  469195:	add    r9,0x10
  469199:	and    r9,r10
  46919c:	jmp    469109 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  4691a1:	nop    DWORD PTR [rax+0x0]
  4691a8:	mov    rcx,QWORD PTR [rsp-0x40]
  4691ad:	mov    r15,QWORD PTR [rsp-0x48]
  4691b2:	mov    edi,DWORD PTR [rsp-0x2c]
  4691b6:	vmovq  xmm14,r9
  4691bb:	vpinsrq xmm0,xmm14,rax,0x1
  4691c1:	mov    rsi,QWORD PTR [rsp-0x38]
  4691c6:	vpsrlq xmm2,xmm0,0x4
  4691cb:	vpmovqd xmm3,xmm2
  4691d1:	sar    rsi,0x4
  4691d5:	vmovq  QWORD PTR [rcx+0xc0],xmm3
  4691dd:	sub    rsi,rdi
  4691e0:	add    DWORD PTR [r15],esi
  4691e3:	vpextrd eax,xmm3,0x1
  4691e9:	cmp    rdx,QWORD PTR [rsp-0x20]
  4691ee:	je     4694d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  4691f4:	mov    rdi,QWORD PTR [rcx+0x88]
  4691fb:	mov    rbx,QWORD PTR [rcx+0x80]
  469202:	mov    r8,QWORD PTR [rcx+0x60]
  469206:	dec    rdi
  469209:	mov    QWORD PTR [rsp-0x18],rbx
  46920e:	mov    QWORD PTR [rsp],r8
  469212:	mov    QWORD PTR [rsp-0x28],rdi
  469217:	mov    r10d,DWORD PTR [rcx+0x78]
  46921b:	mov    r11,QWORD PTR [rip+0x2b9ce]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469222:	mov    r9,QWORD PTR [rcx+0xa0]
  469229:	movzx  r13d,BYTE PTR [rip+0x2b8cf]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469231:	mov    r12,QWORD PTR [rip+0x2b8d0]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469238:	mov    r14d,0x55
  46923e:	vpxor  xmm7,xmm7,xmm7
  469242:	kmovb  k2,r14d
  469247:	nop    WORD PTR [rax+rax*1+0x0]
  469250:	lea    esi,[rax+0x18]
  469253:	and    esi,r10d
  469256:	shl    rsi,0x4
  46925a:	mov    r8d,ebx
  46925d:	and    r8d,DWORD PTR [r9+rsi*1+0x8]
  469262:	mov    esi,eax
  469264:	shl    rsi,0x4
  469268:	add    rsi,r9
  46926b:	mov    r14,r8
  46926e:	mov    r8,QWORD PTR [rsi]
  469271:	shl    r14,0x4
  469275:	prefetcht0 BYTE PTR [r11+r14*1]
  46927a:	cmp    r8,QWORD PTR [rcx+0x90]
  469281:	jne    469340 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x590>
  469287:	test   r13b,r13b
  46928a:	je     4692aa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fa>
  46928c:	mov    r14d,DWORD PTR [r15]
  46928f:	mov    esi,DWORD PTR [rsi+0xc]
  469292:	mov    r8,r14
  469295:	shl    r14,0x4
  469299:	add    r14,QWORD PTR [r15+0x8]
  46929d:	inc    r8d
  4692a0:	mov    DWORD PTR [r14],esi
  4692a3:	mov    QWORD PTR [r14+0x8],r12
  4692a7:	mov    DWORD PTR [r15],r8d
  4692aa:	inc    eax
  4692ac:	and    eax,r10d
  4692af:	mov    DWORD PTR [rcx+0xc4],eax
  4692b5:	test   r12,r12
  4692b8:	jne    469250 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  4692ba:	cmp    QWORD PTR [rsp],0x4
  4692bf:	je     469435 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x685>
  4692c5:	nop    DWORD PTR [rax]
  4692c8:	cmp    QWORD PTR [rsp],0x8
  4692cd:	je     4694b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
  4692d3:	vmovd  xmm15,DWORD PTR [rsp-0x10]
  4692d9:	mov    rdi,QWORD PTR [rdx]
  4692dc:	mov    esi,DWORD PTR [rcx+0xc0]
  4692e2:	mov    r8,QWORD PTR [rsp-0x28]
  4692e7:	mov    rax,rsi
  4692ea:	and    r8,QWORD PTR [rsp-0x10]
  4692ef:	vpinsrd xmm9,xmm15,DWORD PTR [rdx+0xc],0x1
  4692f6:	and    r8,0xfffffffffffffffc
  4692fa:	shl    rsi,0x4
  4692fe:	inc    eax
  469300:	add    rsi,r9
  469303:	shl    r8,0x4
  469307:	and    eax,r10d
  46930a:	add    rdx,0x10
  46930e:	prefetcht2 BYTE PTR [r11+r8*1]
  469313:	mov    QWORD PTR [rsi],rdi
  469316:	vmovq  QWORD PTR [rsi+0x8],xmm9
  46931b:	mov    DWORD PTR [rcx+0xc0],eax
  469321:	cmp    rdx,QWORD PTR [rsp-0x20]
  469326:	je     4694d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  46932c:	mov    eax,DWORD PTR [rcx+0xc4]
  469332:	jmp    469250 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  469337:	nop    WORD PTR [rax+rax*1+0x0]
  469340:	mov    r14d,DWORD PTR [rsi+0x8]
  469344:	mov    edi,ebx
  469346:	and    edi,r14d
  469349:	shl    rdi,0x4
  46934d:	add    rdi,r11
  469350:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  469356:	vpbroadcastq zmm6,r8
  46935c:	vpcmpequq k0{k2},zmm5,zmm6
  469363:	kortestb k0,k0
  469367:	jne    4693f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x640>
  46936d:	vpcmpequq k3{k2},zmm5,zmm7
  469374:	kortestb k3,k3
  469378:	jne    469460 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  46937e:	cmp    QWORD PTR [rsp],0x4
  469383:	mov    edi,r14d
  469386:	je     469470 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  46938c:	cmp    QWORD PTR [rsp],0x8
  469391:	je     469490 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
  469397:	vmovd  xmm1,DWORD PTR [rsp-0x8]
  46939d:	mov    edi,DWORD PTR [rcx+0xc0]
  4693a3:	mov    r14,QWORD PTR [rsp-0x18]
  4693a8:	vpinsrd xmm4,xmm1,DWORD PTR [rsi+0xc],0x1
  4693af:	mov    rsi,rdi
  4693b2:	and    r14,QWORD PTR [rsp-0x8]
  4693b7:	shl    rdi,0x4
  4693bb:	inc    esi
  4693bd:	inc    eax
  4693bf:	add    rdi,r9
  4693c2:	shl    r14,0x4
  4693c6:	and    esi,r10d
  4693c9:	and    eax,r10d
  4693cc:	prefetcht2 BYTE PTR [r11+r14*1]
  4693d1:	mov    QWORD PTR [rdi],r8
  4693d4:	vmovq  QWORD PTR [rdi+0x8],xmm4
  4693d9:	mov    DWORD PTR [rcx+0xc0],esi
  4693df:	mov    DWORD PTR [rcx+0xc4],eax
  4693e5:	jmp    469250 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  4693ea:	nop    WORD PTR [rax+rax*1+0x0]
  4693f0:	mov    r8d,DWORD PTR [r15]
  4693f3:	mov    esi,DWORD PTR [rsi+0xc]
  4693f6:	mov    r14,r8
  4693f9:	shl    r8,0x4
  4693fd:	add    r8,QWORD PTR [r15+0x8]
  469401:	mov    DWORD PTR [r8],esi
  469404:	kmovb  esi,k0
  469408:	tzcnt  esi,esi
  46940c:	inc    esi
  46940e:	movsxd rsi,esi
  469411:	mov    rdi,QWORD PTR [rdi+rsi*8]
  469415:	inc    eax
  469417:	inc    r14d
  46941a:	and    eax,r10d
  46941d:	cmp    QWORD PTR [rsp],0x4
  469422:	mov    QWORD PTR [r8+0x8],rdi
  469426:	mov    DWORD PTR [r15],r14d
  469429:	mov    DWORD PTR [rcx+0xc4],eax
  46942f:	jne    4692c8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x518>
  469435:	mov    r14d,0xffffffff
  46943b:	crc32  r14d,DWORD PTR [rdx]
  469441:	vmovd  xmm8,r14d
  469446:	mov    rdi,QWORD PTR [rdx]
  469449:	vmovdqa xmm15,xmm8
  46944e:	vmovq  QWORD PTR [rsp-0x10],xmm8
  469454:	jmp    4692dc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  469459:	nop    DWORD PTR [rax+0x0]
  469460:	inc    eax
  469462:	and    eax,r10d
  469465:	mov    DWORD PTR [rcx+0xc4],eax
  46946b:	jmp    4692ba <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
  469470:	mov    edi,0xffffffff
  469475:	crc32  edi,r14d
  46947b:	vmovd  xmm12,edi
  46947f:	vmovdqa xmm1,xmm12
  469483:	vmovq  QWORD PTR [rsp-0x8],xmm12
  469489:	jmp    46939d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  46948e:	xchg   ax,ax
  469490:	mov    r14d,0xffffffff
  469496:	crc32  r14,rdi
  46949c:	mov    QWORD PTR [rsp-0x8],r14
  4694a1:	vmovd  xmm1,r14d
  4694a6:	jmp    46939d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  4694ab:	nop    DWORD PTR [rax+rax*1+0x0]
  4694b0:	mov    rdi,QWORD PTR [rdx]
  4694b3:	mov    eax,0xffffffff
  4694b8:	crc32  rax,rdi
  4694be:	mov    QWORD PTR [rsp-0x10],rax
  4694c3:	vmovd  xmm15,eax
  4694c7:	jmp    4692dc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  4694cc:	nop    DWORD PTR [rax+0x0]
  4694d0:	vzeroupper 
  4694d3:	lea    rsp,[rbp-0x28]
  4694d7:	pop    rbx
  4694d8:	pop    r12
  4694da:	pop    r13
  4694dc:	pop    r14
  4694de:	pop    r15
  4694e0:	pop    rbp
  4694e1:	ret    
  4694e2:	nop    WORD PTR [rax+rax*1+0x0]
  4694e8:	vpcmpequq k1{k2},zmm0,zmm4
  4694ef:	kortestb k1,k1
  4694f3:	jne    469630 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x880>
  4694f9:	vmovdqu xmm3,XMMWORD PTR [r15]
  4694fe:	mov    rbx,r14
  469501:	crc32  rbx,r12
  469507:	vpinsrd xmm5,xmm3,ebx,0x2
  46950d:	add    r9,0x10
  469511:	andn   r12d,esi,ebx
  469516:	shl    r12,0x4
  46951a:	and    r9,r10
  46951d:	prefetcht2 BYTE PTR [rdi+r12*1]
  469522:	vmovdqu XMMWORD PTR [rcx],xmm5
  469526:	jmp    468fd2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
  46952b:	nop    DWORD PTR [rax+rax*1+0x0]
  469530:	vpcmpequq k1{k2},zmm8,zmm4
  469537:	kortestb k1,k1
  46953b:	jne    469949 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb99>
  469541:	vmovdqu xmm10,XMMWORD PTR [r13+0x0]
  469547:	mov    rcx,r14
  46954a:	crc32  rcx,rbx
  469550:	vpinsrd xmm11,xmm10,ecx,0x2
  469556:	andn   r15d,esi,ecx
  46955b:	shl    r15,0x4
  46955f:	prefetcht2 BYTE PTR [rdi+r15*1]
  469564:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  46956a:	add    r9,0x10
  46956e:	and    r9,r10
  469571:	jmp    468f5a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469576:	cs nop WORD PTR [rax+rax*1+0x0]
  469580:	vpcmpequq k1{k2},zmm0,zmm4
  469587:	kortestb k1,k1
  46958b:	jne    46992a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb7a>
  469591:	vmovdqu xmm3,XMMWORD PTR [r13+0x0]
  469597:	mov    rcx,r14
  46959a:	crc32  rcx,r15
  4695a0:	vpinsrd xmm5,xmm3,ecx,0x2
  4695a6:	andn   ebx,esi,ecx
  4695ab:	shl    rbx,0x4
  4695af:	prefetcht2 BYTE PTR [rdi+rbx*1]
  4695b3:	vmovdqu XMMWORD PTR [r8+r9*1],xmm5
  4695b9:	add    r9,0x10
  4695bd:	and    r9,r10
  4695c0:	jmp    468ee3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  4695c5:	nop    DWORD PTR [rax]
  4695c8:	vmovd  xmm10,ebx
  4695cc:	vpinsrd xmm11,xmm10,r13d,0x1
  4695d2:	mov    r13,QWORD PTR [rsp-0x18]
  4695d7:	vmovd  xmm8,r11d
  4695dc:	mov    r11,r13
  4695df:	vpinsrd xmm9,xmm8,r15d,0x1
  4695e5:	sub    r11,r9
  4695e8:	mov    ebx,0x4444
  4695ed:	vpunpcklqdq xmm13,xmm11,xmm9
  4695f2:	shr    r11,0x2
  4695f6:	mov    r15d,0x1
  4695fc:	kmovw  k7,ebx
  469600:	shlx   r11d,r15d,r11d
  469605:	vpexpandd zmm15{k7},zmm13
  46960b:	lea    ebx,[r11-0x1]
  46960f:	sub    r9,r13
  469612:	neg    r11d
  469615:	kmovw  k1,ebx
  469619:	vmovdqu32 ZMMWORD PTR [rcx]{k1},zmm15
  46961f:	kmovw  k7,r11d
  469624:	vmovdqu32 ZMMWORD PTR [r8+r9*1]{k7},zmm15
  46962b:	jmp    4690f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x344>
  469630:	inc    DWORD PTR [rsp-0x2c]
  469634:	nop    DWORD PTR [rax+0x0]
  469638:	mov    r12,QWORD PTR [rsp]
  46963c:	mov    r15d,0x55
  469642:	pdep   r13d,r11d,r15d
  469647:	popcnt r11d,r11d
  46964c:	lea    ebx,[r13+r13*2+0x0]
  469651:	shl    r11,0x4
  469655:	kmovb  k1,ebx
  469659:	vpcompressq ZMMWORD PTR [r12]{k1},zmm12
  469660:	add    r12,r11
  469663:	mov    QWORD PTR [rsp],r12
  469667:	jmp    469068 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b8>
  46966c:	cmp    rdx,QWORD PTR [rsp-0x20]
  469671:	je     4694d3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x723>
  469677:	mov    r12,QWORD PTR [rcx+0x88]
  46967e:	movzx  r13d,BYTE PTR [rip+0x2b47a]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469686:	mov    r9,QWORD PTR [rip+0x2b47b]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46968d:	mov    r10,QWORD PTR [rcx+0x60]
  469691:	mov    ebx,0x55
  469696:	dec    r12
  469699:	kmovb  k2,r13d
  46969e:	mov    QWORD PTR [rsp],r10
  4696a2:	mov    QWORD PTR [rsp-0x8],r12
  4696a7:	mov    r14,QWORD PTR [rip+0x2b542]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4696ae:	mov    r11,QWORD PTR [rcx+0xa0]
  4696b5:	mov    esi,edi
  4696b7:	vpxor  xmm2,xmm2,xmm2
  4696bb:	mov    r13,r9
  4696be:	kmovb  k1,ebx
  4696c2:	jmp    46972a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x97a>
  4696c4:	cmp    QWORD PTR [rsp],0x8
  4696c9:	je     4698d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb28>
  4696cf:	vmovd  xmm5,DWORD PTR [rsp-0x18]
  4696d5:	mov    r12,QWORD PTR [rsp-0x8]
  4696da:	mov    esi,edi
  4696dc:	and    r12,QWORD PTR [rsp-0x18]
  4696e1:	vpinsrd xmm7,xmm5,DWORD PTR [rdx+0xc],0x1
  4696e8:	mov    r10,QWORD PTR [rdx]
  4696eb:	and    r12,0xfffffffffffffffc
  4696ef:	shl    rsi,0x4
  4696f3:	add    rsi,r11
  4696f6:	shl    r12,0x4
  4696fa:	prefetcht2 BYTE PTR [r14+r12*1]
  4696ff:	mov    QWORD PTR [rsi],r10
  469702:	vmovq  QWORD PTR [rsi+0x8],xmm7
  469707:	lea    esi,[rdi+0x1]
  46970a:	and    esi,r8d
  46970d:	add    rdx,0x10
  469711:	mov    DWORD PTR [rcx+0xc0],esi
  469717:	cmp    QWORD PTR [rsp-0x20],rdx
  46971c:	je     4694d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  469722:	mov    eax,DWORD PTR [rcx+0xc4]
  469728:	mov    edi,esi
  46972a:	sub    esi,eax
  46972c:	and    esi,r8d
  46972f:	cmp    r8d,esi
  469732:	jbe    469755 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a5>
  469734:	cmp    QWORD PTR [rsp],0x4
  469739:	jne    4696c4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x914>
  46973b:	mov    ebx,0xffffffff
  469740:	crc32  ebx,DWORD PTR [rdx]
  469745:	vmovd  xmm6,ebx
  469749:	vmovdqa xmm5,xmm6
  46974d:	vmovq  QWORD PTR [rsp-0x18],xmm6
  469753:	jmp    4696d5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  469755:	mov    rbx,QWORD PTR [rcx+0x80]
  46975c:	mov    QWORD PTR [rsp-0x10],rbx
  469761:	nop    DWORD PTR [rax+0x0]
  469768:	lea    esi,[rax+0x18]
  46976b:	and    esi,r8d
  46976e:	shl    rsi,0x4
  469772:	mov    r9d,ebx
  469775:	and    r9d,DWORD PTR [r11+rsi*1+0x8]
  46977a:	mov    esi,eax
  46977c:	mov    r10,r9
  46977f:	shl    rsi,0x4
  469783:	shl    r10,0x4
  469787:	add    rsi,r11
  46978a:	prefetcht0 BYTE PTR [r14+r10*1]
  46978f:	mov    r10,QWORD PTR [rsi]
  469792:	cmp    r10,QWORD PTR [rcx+0x90]
  469799:	jne    4697e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa30>
  46979b:	kortestb k2,k2
  46979f:	je     4697c2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa12>
  4697a1:	mov    r12d,DWORD PTR [r15]
  4697a4:	mov    esi,DWORD PTR [rsi+0xc]
  4697a7:	mov    r10,r12
  4697aa:	shl    r12,0x4
  4697ae:	add    r12,QWORD PTR [r15+0x8]
  4697b2:	lea    r9d,[r10+0x1]
  4697b6:	mov    DWORD PTR [r12],esi
  4697ba:	mov    QWORD PTR [r12+0x8],r13
  4697bf:	mov    DWORD PTR [r15],r9d
  4697c2:	inc    eax
  4697c4:	and    eax,r8d
  4697c7:	mov    DWORD PTR [rcx+0xc4],eax
  4697cd:	test   r13,r13
  4697d0:	jne    469768 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  4697d2:	jmp    469734 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  4697d7:	nop    WORD PTR [rax+rax*1+0x0]
  4697e0:	mov    r12d,DWORD PTR [rsi+0x8]
  4697e4:	mov    r9d,ebx
  4697e7:	and    r9d,r12d
  4697ea:	shl    r9,0x4
  4697ee:	add    r9,r14
  4697f1:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  4697f7:	vpbroadcastq zmm1,r10
  4697fd:	vpcmpequq k0{k1},zmm0,zmm1
  469804:	kortestb k0,k0
  469808:	jne    469884 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad4>
  46980a:	vpcmpequq k3{k1},zmm0,zmm2
  469811:	kortestb k3,k3
  469815:	jne    4698c8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb18>
  46981b:	cmp    QWORD PTR [rsp],0x4
  469820:	mov    r9d,r12d
  469823:	je     4698f1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb41>
  469829:	cmp    QWORD PTR [rsp],0x8
  46982e:	je     469911 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb61>
  469834:	mov    r9d,DWORD PTR [rsp-0x28]
  469839:	mov    r12,QWORD PTR [rsp-0x10]
  46983e:	vmovd  xmm4,r9d
  469843:	vpinsrd xmm3,xmm4,DWORD PTR [rsi+0xc],0x1
  46984a:	mov    esi,edi
  46984c:	and    r12,QWORD PTR [rsp-0x28]
  469851:	shl    rsi,0x4
  469855:	inc    edi
  469857:	inc    eax
  469859:	add    rsi,r11
  46985c:	shl    r12,0x4
  469860:	and    edi,r8d
  469863:	and    eax,r8d
  469866:	prefetcht2 BYTE PTR [r14+r12*1]
  46986b:	mov    QWORD PTR [rsi],r10
  46986e:	vmovq  QWORD PTR [rsi+0x8],xmm3
  469873:	mov    DWORD PTR [rcx+0xc0],edi
  469879:	mov    DWORD PTR [rcx+0xc4],eax
  46987f:	jmp    469768 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  469884:	mov    r10d,DWORD PTR [r15]
  469887:	mov    r12d,DWORD PTR [rsi+0xc]
  46988b:	mov    rbx,r10
  46988e:	shl    r10,0x4
  469892:	add    r10,QWORD PTR [r15+0x8]
  469896:	mov    DWORD PTR [r10],r12d
  469899:	xor    r12d,r12d
  46989c:	kmovb  esi,k0
  4698a0:	tzcnt  r12d,esi
  4698a5:	inc    r12d
  4698a8:	movsxd rsi,r12d
  4698ab:	mov    r9,QWORD PTR [r9+rsi*8]
  4698af:	inc    eax
  4698b1:	inc    ebx
  4698b3:	and    eax,r8d
  4698b6:	mov    QWORD PTR [r10+0x8],r9
  4698ba:	mov    DWORD PTR [r15],ebx
  4698bd:	mov    DWORD PTR [rcx+0xc4],eax
  4698c3:	jmp    469734 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  4698c8:	inc    eax
  4698ca:	and    eax,r8d
  4698cd:	mov    DWORD PTR [rcx+0xc4],eax
  4698d3:	jmp    469734 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  4698d8:	mov    eax,0xffffffff
  4698dd:	crc32  rax,QWORD PTR [rdx]
  4698e3:	mov    QWORD PTR [rsp-0x18],rax
  4698e8:	vmovd  xmm5,eax
  4698ec:	jmp    4696d5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  4698f1:	mov    r9d,0xffffffff
  4698f7:	crc32  r9d,r12d
  4698fd:	mov    r12d,r9d
  469900:	mov    QWORD PTR [rsp-0x28],r12
  469905:	jmp    469839 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  46990a:	xor    edi,edi
  46990c:	jmp    4691b6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x406>
  469911:	mov    r12d,0xffffffff
  469917:	crc32  r12,r9
  46991d:	mov    QWORD PTR [rsp-0x28],r12
  469922:	mov    r9d,r12d
  469925:	jmp    469839 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  46992a:	inc    DWORD PTR [rsp-0x2c]
  46992e:	jmp    468f5a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469933:	inc    DWORD PTR [rsp-0x2c]
  469937:	vpxor  xmm15,xmm15,xmm15
  46993c:	xor    r11d,r11d
  46993f:	vpxor  xmm12,xmm12,xmm12
  469944:	jmp    468ee3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  469949:	inc    DWORD PTR [rsp-0x2c]
  46994d:	jmp    468fd2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
