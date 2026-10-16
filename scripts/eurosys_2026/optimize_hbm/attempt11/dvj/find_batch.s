0000000000468dd0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468dd0:	push   rbp
  468dd1:	mov    rcx,rdi
  468dd4:	mov    rbp,rsp
  468dd7:	push   r15
  468dd9:	mov    r15,rdx
  468ddc:	push   r14
  468dde:	push   r13
  468de0:	push   r12
  468de2:	push   rbx
  468de3:	and    rsp,0xffffffffffffffc0
  468de7:	sub    rsp,0x8
  468deb:	mov    r11,QWORD PTR [rsi+0x8]
  468def:	mov    edi,DWORD PTR [rdi+0xc0]
  468df5:	mov    eax,DWORD PTR [rcx+0xc4]
  468dfb:	mov    rdx,QWORD PTR [rsi]
  468dfe:	mov    r8d,DWORD PTR [rcx+0x78]
  468e02:	mov    r9d,DWORD PTR [rcx+0x6c]
  468e06:	mov    r10,r11
  468e09:	mov    esi,edi
  468e0b:	shl    r10,0x4
  468e0f:	sub    esi,eax
  468e11:	lea    rbx,[rdx+r10*1]
  468e15:	and    esi,r8d
  468e18:	lea    r12d,[r9-0x1]
  468e1c:	mov    QWORD PTR [rsp-0x20],rbx
  468e21:	cmp    esi,r12d
  468e24:	jb     46968c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8bc>
  468e2a:	and    r11,0xfffffffffffffffc
  468e2e:	shl    r9,0x4
  468e32:	shl    r11,0x4
  468e36:	mov    r14,QWORD PTR [r15+0x8]
  468e3a:	mov    esi,DWORD PTR [rcx+0x80]
  468e40:	mov    QWORD PTR [rsp-0x18],r9
  468e45:	mov    QWORD PTR [rsp-0x38],r11
  468e4a:	lea    r10,[r9-0x1]
  468e4e:	lea    r11,[rdx+r11*1]
  468e52:	mov    r9d,edi
  468e55:	mov    QWORD PTR [rsp],r14
  468e59:	mov    QWORD PTR [rsp-0x28],r11
  468e5e:	mov    DWORD PTR [rsp-0x2c],0x0
  468e66:	mov    r8,QWORD PTR [rcx+0xa0]
  468e6d:	mov    rdi,QWORD PTR [rip+0x2bd7c]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468e74:	shl    rax,0x4
  468e78:	shl    r9,0x4
  468e7c:	not    esi
  468e7e:	cmp    rdx,r11
  468e81:	je     46992a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb5a>
  468e87:	mov    r13d,0x55
  468e8d:	mov    ebx,0xf
  468e92:	mov    r12d,0xf0
  468e98:	mov    r11d,0xf00
  468e9e:	kmovb  k2,r13d
  468ea3:	mov    r13d,0xfffff000
  468ea9:	mov    QWORD PTR [rsp-0x40],rcx
  468eae:	mov    QWORD PTR [rsp-0x48],r15
  468eb3:	vpxor  xmm4,xmm4,xmm4
  468eb7:	mov    r14d,0xffffffff
  468ebd:	kmovw  k6,ebx
  468ec1:	kmovw  k5,r12d
  468ec6:	kmovw  k4,r11d
  468ecb:	kmovw  k3,r13d
  468ed0:	jmp    469129 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  468ed5:	nop    DWORD PTR [rax]
  468ed8:	vmovd  xmm13,DWORD PTR [r12+0xc]
  468edf:	kshiftlb k7,k7,0x1
  468ee5:	vpcompressq zmm12{k7}{z},zmm8
  468eeb:	vpunpcklqdq xmm14,xmm13,xmm12
  468ef0:	vshufi32x4 zmm15{k6}{z},zmm14,zmm14,0x0
  468ef7:	vmovdqa64 zmm12,zmm15
  468efd:	mov    r11d,0x1
  468f03:	lea    r13,[r8+rax*1]
  468f07:	lea    r12,[rax+0x180]
  468f0e:	and    r12,r10
  468f11:	mov    r15d,DWORD PTR [r13+0x8]
  468f15:	andn   ecx,esi,DWORD PTR [r8+r12*1+0x8]
  468f1c:	shl    rcx,0x4
  468f20:	andn   r12d,esi,r15d
  468f25:	shl    r12,0x4
  468f29:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r12*1]
  468f30:	vpbroadcastq zmm2,QWORD PTR [r13+0x0]
  468f37:	vpcmpequq k0{k2},zmm0,zmm2
  468f3e:	add    rax,0x10
  468f42:	and    rax,r10
  468f45:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468f49:	kortestb k0,k0
  468f4d:	je     4695a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
  468f53:	vmovd  xmm1,DWORD PTR [r13+0xc]
  468f59:	kshiftlb k7,k0,0x1
  468f5f:	vpcompressq zmm6{k7}{z},zmm0
  468f65:	vpunpcklqdq xmm7,xmm1,xmm6
  468f69:	vshufi32x4 zmm15{k5},zmm7,zmm7,0x0
  468f70:	vmovdqa64 zmm12,zmm15
  468f76:	or     r11d,0x2
  468f7a:	lea    r13,[rax+0x180]
  468f81:	and    r13,r10
  468f84:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  468f8b:	shl    rcx,0x4
  468f8f:	lea    r13,[r8+rax*1]
  468f93:	mov    ebx,DWORD PTR [r13+0x8]
  468f97:	andn   r12d,esi,ebx
  468f9c:	shl    r12,0x4
  468fa0:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r12*1]
  468fa7:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  468fae:	vpcmpequq k0{k2},zmm8,zmm9
  468fb5:	add    rax,0x10
  468fb9:	and    rax,r10
  468fbc:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468fc0:	kortestb k0,k0
  468fc4:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x780>
  468fca:	vmovd  xmm13,DWORD PTR [r13+0xc]
  468fd0:	kshiftlb k7,k0,0x1
  468fd6:	vpcompressq zmm12{k7}{z},zmm8
  468fdc:	vpunpcklqdq xmm14,xmm13,xmm12
  468fe1:	vshufi32x4 zmm15{k4},zmm14,zmm14,0x0
  468fe8:	vmovdqa64 zmm12,zmm15
  468fee:	or     r11d,0x4
  468ff2:	lea    r15,[r8+rax*1]
  468ff6:	lea    r13,[rax+0x180]
  468ffd:	and    r13,r10
  469000:	mov    r12d,DWORD PTR [r15+0x8]
  469004:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  46900b:	shl    rcx,0x4
  46900f:	andn   r13d,esi,r12d
  469014:	shl    r13,0x4
  469018:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r13*1]
  46901f:	vpbroadcastq zmm2,QWORD PTR [r15]
  469025:	vpcmpequq k0{k2},zmm0,zmm2
  46902c:	add    rax,0x10
  469030:	and    rax,r10
  469033:	prefetcht0 BYTE PTR [rdi+rcx*1]
  469037:	kortestb k0,k0
  46903b:	lea    rcx,[r8+r9*1]
  46903f:	je     469508 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
  469045:	vmovd  xmm1,DWORD PTR [r15+0xc]
  46904b:	kshiftlb k7,k0,0x1
  469051:	vpcompressq zmm6{k7}{z},zmm0
  469057:	vpunpcklqdq xmm7,xmm1,xmm6
  46905b:	vshufi32x4 zmm15{k3},zmm7,zmm7,0x0
  469062:	or     r11d,0x8
  469066:	vmovdqa64 zmm12,zmm15
  46906c:	cmp    r11d,0xf
  469070:	jne    469658 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x888>
  469076:	mov    r15,QWORD PTR [rsp]
  46907a:	vmovdqu64 ZMMWORD PTR [r15],zmm15
  469080:	add    r15,0x40
  469084:	mov    QWORD PTR [rsp],r15
  469088:	mov    rbx,r14
  46908b:	mov    r11,r14
  46908e:	crc32  rbx,QWORD PTR [rdx]
  469094:	crc32  r11,QWORD PTR [rdx+0x20]
  46909b:	andn   r13d,esi,ebx
  4690a0:	shl    r13,0x4
  4690a4:	andn   r15d,esi,r11d
  4690a9:	shl    r15,0x4
  4690ad:	prefetcht2 BYTE PTR [rdi+r13*1]
  4690b2:	prefetcht2 BYTE PTR [rdi+r15*1]
  4690b7:	mov    r13,r14
  4690ba:	mov    r15,r14
  4690bd:	crc32  r13,QWORD PTR [rdx+0x10]
  4690c4:	crc32  r15,QWORD PTR [rdx+0x30]
  4690cb:	andn   r12d,esi,r13d
  4690d0:	shl    r12,0x4
  4690d4:	prefetcht2 BYTE PTR [rdi+r12*1]
  4690d9:	andn   r12d,esi,r15d
  4690de:	shl    r12,0x4
  4690e2:	prefetcht2 BYTE PTR [rdi+r12*1]
  4690e7:	lea    r12,[r9+0x40]
  4690eb:	vmovdqu64 zmm15,ZMMWORD PTR [rdx]
  4690f1:	cmp    QWORD PTR [rsp-0x18],r12
  4690f6:	jb     4695e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x818>
  4690fc:	vmovdqu64 ZMMWORD PTR [rcx],zmm15
  469102:	mov    DWORD PTR [rcx+0x8],ebx
  469105:	mov    DWORD PTR [r8+r9*1+0x18],r13d
  46910a:	mov    DWORD PTR [r8+r9*1+0x28],r11d
  46910f:	mov    DWORD PTR [r8+r9*1+0x38],r15d
  469114:	mov    r9,r12
  469117:	add    rdx,0x40
  46911b:	and    r9,r10
  46911e:	cmp    QWORD PTR [rsp-0x28],rdx
  469123:	je     4691c8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3f8>
  469129:	lea    r12,[r8+rax*1]
  46912d:	mov    r11d,DWORD PTR [r12+0x8]
  469132:	andn   r13d,esi,r11d
  469137:	shl    r13,0x4
  46913b:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r13*1]
  469142:	vpbroadcastq zmm9,QWORD PTR [r12]
  469149:	vpcmpequq k7{k2},zmm8,zmm9
  469150:	lea    rcx,[rax+0x180]
  469157:	add    rax,0x10
  46915b:	and    rcx,r10
  46915e:	and    rax,r10
  469161:	andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
  469168:	shl    r15,0x4
  46916c:	kortestb k7,k7
  469170:	prefetcht0 BYTE PTR [rdi+r15*1]
  469175:	jne    468ed8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
  46917b:	vpcmpequq k1{k2},zmm8,zmm4
  469182:	kortestb k1,k1
  469186:	jne    469953 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb83>
  46918c:	vmovdqu xmm10,XMMWORD PTR [r12]
  469192:	mov    rcx,r14
  469195:	crc32  rcx,r11
  46919b:	vpinsrd xmm11,xmm10,ecx,0x2
  4691a1:	andn   r15d,esi,ecx
  4691a6:	shl    r15,0x4
  4691aa:	prefetcht2 BYTE PTR [rdi+r15*1]
  4691af:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  4691b5:	add    r9,0x10
  4691b9:	and    r9,r10
  4691bc:	jmp    469129 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  4691c1:	nop    DWORD PTR [rax+0x0]
  4691c8:	mov    rcx,QWORD PTR [rsp-0x40]
  4691cd:	mov    r15,QWORD PTR [rsp-0x48]
  4691d2:	mov    edi,DWORD PTR [rsp-0x2c]
  4691d6:	vmovq  xmm14,r9
  4691db:	vpinsrq xmm0,xmm14,rax,0x1
  4691e1:	mov    rsi,QWORD PTR [rsp-0x38]
  4691e6:	vpsrlq xmm2,xmm0,0x4
  4691eb:	vpmovqd xmm3,xmm2
  4691f1:	sar    rsi,0x4
  4691f5:	vmovq  QWORD PTR [rcx+0xc0],xmm3
  4691fd:	sub    rsi,rdi
  469200:	add    DWORD PTR [r15],esi
  469203:	vpextrd eax,xmm3,0x1
  469209:	cmp    rdx,QWORD PTR [rsp-0x20]
  46920e:	je     4694f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  469214:	mov    rdi,QWORD PTR [rcx+0x88]
  46921b:	mov    rbx,QWORD PTR [rcx+0x80]
  469222:	mov    r8,QWORD PTR [rcx+0x60]
  469226:	dec    rdi
  469229:	mov    QWORD PTR [rsp-0x18],rbx
  46922e:	mov    QWORD PTR [rsp],r8
  469232:	mov    QWORD PTR [rsp-0x28],rdi
  469237:	mov    r10d,DWORD PTR [rcx+0x78]
  46923b:	mov    r11,QWORD PTR [rip+0x2b9ae]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469242:	mov    r9,QWORD PTR [rcx+0xa0]
  469249:	movzx  r13d,BYTE PTR [rip+0x2b8af]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469251:	mov    r12,QWORD PTR [rip+0x2b8b0]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469258:	mov    r14d,0x55
  46925e:	vpxor  xmm7,xmm7,xmm7
  469262:	kmovb  k2,r14d
  469267:	nop    WORD PTR [rax+rax*1+0x0]
  469270:	lea    esi,[rax+0x18]
  469273:	and    esi,r10d
  469276:	shl    rsi,0x4
  46927a:	mov    r8d,ebx
  46927d:	and    r8d,DWORD PTR [r9+rsi*1+0x8]
  469282:	mov    esi,eax
  469284:	shl    rsi,0x4
  469288:	add    rsi,r9
  46928b:	mov    r14,r8
  46928e:	mov    r8,QWORD PTR [rsi]
  469291:	shl    r14,0x4
  469295:	prefetcht0 BYTE PTR [r11+r14*1]
  46929a:	cmp    r8,QWORD PTR [rcx+0x90]
  4692a1:	jne    469360 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x590>
  4692a7:	test   r13b,r13b
  4692aa:	je     4692ca <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fa>
  4692ac:	mov    r14d,DWORD PTR [r15]
  4692af:	mov    esi,DWORD PTR [rsi+0xc]
  4692b2:	mov    r8,r14
  4692b5:	shl    r14,0x4
  4692b9:	add    r14,QWORD PTR [r15+0x8]
  4692bd:	inc    r8d
  4692c0:	mov    DWORD PTR [r14],esi
  4692c3:	mov    QWORD PTR [r14+0x8],r12
  4692c7:	mov    DWORD PTR [r15],r8d
  4692ca:	inc    eax
  4692cc:	and    eax,r10d
  4692cf:	mov    DWORD PTR [rcx+0xc4],eax
  4692d5:	test   r12,r12
  4692d8:	jne    469270 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  4692da:	cmp    QWORD PTR [rsp],0x4
  4692df:	je     469455 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x685>
  4692e5:	nop    DWORD PTR [rax]
  4692e8:	cmp    QWORD PTR [rsp],0x8
  4692ed:	je     4694d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
  4692f3:	vmovd  xmm15,DWORD PTR [rsp-0x10]
  4692f9:	mov    rdi,QWORD PTR [rdx]
  4692fc:	mov    esi,DWORD PTR [rcx+0xc0]
  469302:	mov    r8,QWORD PTR [rsp-0x28]
  469307:	mov    rax,rsi
  46930a:	and    r8,QWORD PTR [rsp-0x10]
  46930f:	vpinsrd xmm9,xmm15,DWORD PTR [rdx+0xc],0x1
  469316:	and    r8,0xfffffffffffffffc
  46931a:	shl    rsi,0x4
  46931e:	inc    eax
  469320:	add    rsi,r9
  469323:	shl    r8,0x4
  469327:	and    eax,r10d
  46932a:	add    rdx,0x10
  46932e:	prefetcht2 BYTE PTR [r11+r8*1]
  469333:	mov    QWORD PTR [rsi],rdi
  469336:	vmovq  QWORD PTR [rsi+0x8],xmm9
  46933b:	mov    DWORD PTR [rcx+0xc0],eax
  469341:	cmp    rdx,QWORD PTR [rsp-0x20]
  469346:	je     4694f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  46934c:	mov    eax,DWORD PTR [rcx+0xc4]
  469352:	jmp    469270 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  469357:	nop    WORD PTR [rax+rax*1+0x0]
  469360:	mov    r14d,DWORD PTR [rsi+0x8]
  469364:	mov    edi,ebx
  469366:	and    edi,r14d
  469369:	shl    rdi,0x4
  46936d:	add    rdi,r11
  469370:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  469376:	vpbroadcastq zmm6,r8
  46937c:	vpcmpequq k0{k2},zmm5,zmm6
  469383:	kortestb k0,k0
  469387:	jne    469410 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x640>
  46938d:	vpcmpequq k3{k2},zmm5,zmm7
  469394:	kortestb k3,k3
  469398:	jne    469480 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  46939e:	cmp    QWORD PTR [rsp],0x4
  4693a3:	mov    edi,r14d
  4693a6:	je     469490 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  4693ac:	cmp    QWORD PTR [rsp],0x8
  4693b1:	je     4694b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
  4693b7:	vmovd  xmm1,DWORD PTR [rsp-0x8]
  4693bd:	mov    edi,DWORD PTR [rcx+0xc0]
  4693c3:	mov    r14,QWORD PTR [rsp-0x18]
  4693c8:	vpinsrd xmm4,xmm1,DWORD PTR [rsi+0xc],0x1
  4693cf:	mov    rsi,rdi
  4693d2:	and    r14,QWORD PTR [rsp-0x8]
  4693d7:	shl    rdi,0x4
  4693db:	inc    esi
  4693dd:	inc    eax
  4693df:	add    rdi,r9
  4693e2:	shl    r14,0x4
  4693e6:	and    esi,r10d
  4693e9:	and    eax,r10d
  4693ec:	prefetcht2 BYTE PTR [r11+r14*1]
  4693f1:	mov    QWORD PTR [rdi],r8
  4693f4:	vmovq  QWORD PTR [rdi+0x8],xmm4
  4693f9:	mov    DWORD PTR [rcx+0xc0],esi
  4693ff:	mov    DWORD PTR [rcx+0xc4],eax
  469405:	jmp    469270 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  46940a:	nop    WORD PTR [rax+rax*1+0x0]
  469410:	mov    r8d,DWORD PTR [r15]
  469413:	mov    esi,DWORD PTR [rsi+0xc]
  469416:	mov    r14,r8
  469419:	shl    r8,0x4
  46941d:	add    r8,QWORD PTR [r15+0x8]
  469421:	mov    DWORD PTR [r8],esi
  469424:	kmovb  esi,k0
  469428:	tzcnt  esi,esi
  46942c:	inc    esi
  46942e:	movsxd rsi,esi
  469431:	mov    rdi,QWORD PTR [rdi+rsi*8]
  469435:	inc    eax
  469437:	inc    r14d
  46943a:	and    eax,r10d
  46943d:	cmp    QWORD PTR [rsp],0x4
  469442:	mov    QWORD PTR [r8+0x8],rdi
  469446:	mov    DWORD PTR [r15],r14d
  469449:	mov    DWORD PTR [rcx+0xc4],eax
  46944f:	jne    4692e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x518>
  469455:	mov    r14d,0xffffffff
  46945b:	crc32  r14d,DWORD PTR [rdx]
  469461:	vmovd  xmm8,r14d
  469466:	mov    rdi,QWORD PTR [rdx]
  469469:	vmovdqa xmm15,xmm8
  46946e:	vmovq  QWORD PTR [rsp-0x10],xmm8
  469474:	jmp    4692fc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  469479:	nop    DWORD PTR [rax+0x0]
  469480:	inc    eax
  469482:	and    eax,r10d
  469485:	mov    DWORD PTR [rcx+0xc4],eax
  46948b:	jmp    4692da <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
  469490:	mov    edi,0xffffffff
  469495:	crc32  edi,r14d
  46949b:	vmovd  xmm12,edi
  46949f:	vmovdqa xmm1,xmm12
  4694a3:	vmovq  QWORD PTR [rsp-0x8],xmm12
  4694a9:	jmp    4693bd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  4694ae:	xchg   ax,ax
  4694b0:	mov    r14d,0xffffffff
  4694b6:	crc32  r14,rdi
  4694bc:	mov    QWORD PTR [rsp-0x8],r14
  4694c1:	vmovd  xmm1,r14d
  4694c6:	jmp    4693bd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  4694cb:	nop    DWORD PTR [rax+rax*1+0x0]
  4694d0:	mov    rdi,QWORD PTR [rdx]
  4694d3:	mov    eax,0xffffffff
  4694d8:	crc32  rax,rdi
  4694de:	mov    QWORD PTR [rsp-0x10],rax
  4694e3:	vmovd  xmm15,eax
  4694e7:	jmp    4692fc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  4694ec:	nop    DWORD PTR [rax+0x0]
  4694f0:	vzeroupper 
  4694f3:	lea    rsp,[rbp-0x28]
  4694f7:	pop    rbx
  4694f8:	pop    r12
  4694fa:	pop    r13
  4694fc:	pop    r14
  4694fe:	pop    r15
  469500:	pop    rbp
  469501:	ret    
  469502:	nop    WORD PTR [rax+rax*1+0x0]
  469508:	vpcmpequq k1{k2},zmm0,zmm4
  46950f:	kortestb k1,k1
  469513:	jne    469650 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x880>
  469519:	vmovdqu xmm3,XMMWORD PTR [r15]
  46951e:	mov    rbx,r14
  469521:	crc32  rbx,r12
  469527:	vpinsrd xmm5,xmm3,ebx,0x2
  46952d:	add    r9,0x10
  469531:	andn   r12d,esi,ebx
  469536:	shl    r12,0x4
  46953a:	and    r9,r10
  46953d:	prefetcht2 BYTE PTR [rdi+r12*1]
  469542:	vmovdqu XMMWORD PTR [rcx],xmm5
  469546:	jmp    468ff2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
  46954b:	nop    DWORD PTR [rax+rax*1+0x0]
  469550:	vpcmpequq k1{k2},zmm8,zmm4
  469557:	kortestb k1,k1
  46955b:	jne    469969 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb99>
  469561:	vmovdqu xmm10,XMMWORD PTR [r13+0x0]
  469567:	mov    rcx,r14
  46956a:	crc32  rcx,rbx
  469570:	vpinsrd xmm11,xmm10,ecx,0x2
  469576:	andn   r15d,esi,ecx
  46957b:	shl    r15,0x4
  46957f:	prefetcht2 BYTE PTR [rdi+r15*1]
  469584:	vmovdqu XMMWORD PTR [r8+r9*1],xmm11
  46958a:	add    r9,0x10
  46958e:	and    r9,r10
  469591:	jmp    468f7a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469596:	cs nop WORD PTR [rax+rax*1+0x0]
  4695a0:	vpcmpequq k1{k2},zmm0,zmm4
  4695a7:	kortestb k1,k1
  4695ab:	jne    46994a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb7a>
  4695b1:	vmovdqu xmm3,XMMWORD PTR [r13+0x0]
  4695b7:	mov    rcx,r14
  4695ba:	crc32  rcx,r15
  4695c0:	vpinsrd xmm5,xmm3,ecx,0x2
  4695c6:	andn   ebx,esi,ecx
  4695cb:	shl    rbx,0x4
  4695cf:	prefetcht2 BYTE PTR [rdi+rbx*1]
  4695d3:	vmovdqu XMMWORD PTR [r8+r9*1],xmm5
  4695d9:	add    r9,0x10
  4695dd:	and    r9,r10
  4695e0:	jmp    468f03 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  4695e5:	nop    DWORD PTR [rax]
  4695e8:	vmovd  xmm10,ebx
  4695ec:	vpinsrd xmm11,xmm10,r13d,0x1
  4695f2:	mov    r13,QWORD PTR [rsp-0x18]
  4695f7:	vmovd  xmm8,r11d
  4695fc:	mov    r11,r13
  4695ff:	vpinsrd xmm9,xmm8,r15d,0x1
  469605:	sub    r11,r9
  469608:	mov    ebx,0x4444
  46960d:	vpunpcklqdq xmm13,xmm11,xmm9
  469612:	shr    r11,0x2
  469616:	mov    r15d,0x1
  46961c:	kmovw  k7,ebx
  469620:	shlx   r11d,r15d,r11d
  469625:	vpexpandd zmm15{k7},zmm13
  46962b:	lea    ebx,[r11-0x1]
  46962f:	sub    r9,r13
  469632:	neg    r11d
  469635:	kmovw  k1,ebx
  469639:	vmovdqu32 ZMMWORD PTR [rcx]{k1},zmm15
  46963f:	kmovw  k7,r11d
  469644:	vmovdqu32 ZMMWORD PTR [r8+r9*1]{k7},zmm15
  46964b:	jmp    469114 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x344>
  469650:	inc    DWORD PTR [rsp-0x2c]
  469654:	nop    DWORD PTR [rax+0x0]
  469658:	mov    r12,QWORD PTR [rsp]
  46965c:	mov    r15d,0x55
  469662:	pdep   r13d,r11d,r15d
  469667:	popcnt r11d,r11d
  46966c:	lea    ebx,[r13+r13*2+0x0]
  469671:	shl    r11,0x4
  469675:	kmovb  k1,ebx
  469679:	vpcompressq ZMMWORD PTR [r12]{k1},zmm12
  469680:	add    r12,r11
  469683:	mov    QWORD PTR [rsp],r12
  469687:	jmp    469088 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b8>
  46968c:	cmp    rdx,QWORD PTR [rsp-0x20]
  469691:	je     4694f3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x723>
  469697:	mov    r12,QWORD PTR [rcx+0x88]
  46969e:	movzx  r13d,BYTE PTR [rip+0x2b45a]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4696a6:	mov    r9,QWORD PTR [rip+0x2b45b]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4696ad:	mov    r10,QWORD PTR [rcx+0x60]
  4696b1:	mov    ebx,0x55
  4696b6:	dec    r12
  4696b9:	kmovb  k2,r13d
  4696be:	mov    QWORD PTR [rsp],r10
  4696c2:	mov    QWORD PTR [rsp-0x8],r12
  4696c7:	mov    r14,QWORD PTR [rip+0x2b522]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4696ce:	mov    r11,QWORD PTR [rcx+0xa0]
  4696d5:	mov    esi,edi
  4696d7:	vpxor  xmm2,xmm2,xmm2
  4696db:	mov    r13,r9
  4696de:	kmovb  k1,ebx
  4696e2:	jmp    46974a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x97a>
  4696e4:	cmp    QWORD PTR [rsp],0x8
  4696e9:	je     4698f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb28>
  4696ef:	vmovd  xmm5,DWORD PTR [rsp-0x18]
  4696f5:	mov    r12,QWORD PTR [rsp-0x8]
  4696fa:	mov    esi,edi
  4696fc:	and    r12,QWORD PTR [rsp-0x18]
  469701:	vpinsrd xmm7,xmm5,DWORD PTR [rdx+0xc],0x1
  469708:	mov    r10,QWORD PTR [rdx]
  46970b:	and    r12,0xfffffffffffffffc
  46970f:	shl    rsi,0x4
  469713:	add    rsi,r11
  469716:	shl    r12,0x4
  46971a:	prefetcht2 BYTE PTR [r14+r12*1]
  46971f:	mov    QWORD PTR [rsi],r10
  469722:	vmovq  QWORD PTR [rsi+0x8],xmm7
  469727:	lea    esi,[rdi+0x1]
  46972a:	and    esi,r8d
  46972d:	add    rdx,0x10
  469731:	mov    DWORD PTR [rcx+0xc0],esi
  469737:	cmp    QWORD PTR [rsp-0x20],rdx
  46973c:	je     4694f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  469742:	mov    eax,DWORD PTR [rcx+0xc4]
  469748:	mov    edi,esi
  46974a:	sub    esi,eax
  46974c:	and    esi,r8d
  46974f:	cmp    r8d,esi
  469752:	jbe    469775 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a5>
  469754:	cmp    QWORD PTR [rsp],0x4
  469759:	jne    4696e4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x914>
  46975b:	mov    ebx,0xffffffff
  469760:	crc32  ebx,DWORD PTR [rdx]
  469765:	vmovd  xmm6,ebx
  469769:	vmovdqa xmm5,xmm6
  46976d:	vmovq  QWORD PTR [rsp-0x18],xmm6
  469773:	jmp    4696f5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  469775:	mov    rbx,QWORD PTR [rcx+0x80]
  46977c:	mov    QWORD PTR [rsp-0x10],rbx
  469781:	nop    DWORD PTR [rax+0x0]
  469788:	lea    esi,[rax+0x18]
  46978b:	and    esi,r8d
  46978e:	shl    rsi,0x4
  469792:	mov    r9d,ebx
  469795:	and    r9d,DWORD PTR [r11+rsi*1+0x8]
  46979a:	mov    esi,eax
  46979c:	mov    r10,r9
  46979f:	shl    rsi,0x4
  4697a3:	shl    r10,0x4
  4697a7:	add    rsi,r11
  4697aa:	prefetcht0 BYTE PTR [r14+r10*1]
  4697af:	mov    r10,QWORD PTR [rsi]
  4697b2:	cmp    r10,QWORD PTR [rcx+0x90]
  4697b9:	jne    469800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa30>
  4697bb:	kortestb k2,k2
  4697bf:	je     4697e2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa12>
  4697c1:	mov    r12d,DWORD PTR [r15]
  4697c4:	mov    esi,DWORD PTR [rsi+0xc]
  4697c7:	mov    r10,r12
  4697ca:	shl    r12,0x4
  4697ce:	add    r12,QWORD PTR [r15+0x8]
  4697d2:	lea    r9d,[r10+0x1]
  4697d6:	mov    DWORD PTR [r12],esi
  4697da:	mov    QWORD PTR [r12+0x8],r13
  4697df:	mov    DWORD PTR [r15],r9d
  4697e2:	inc    eax
  4697e4:	and    eax,r8d
  4697e7:	mov    DWORD PTR [rcx+0xc4],eax
  4697ed:	test   r13,r13
  4697f0:	jne    469788 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  4697f2:	jmp    469754 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  4697f7:	nop    WORD PTR [rax+rax*1+0x0]
  469800:	mov    r12d,DWORD PTR [rsi+0x8]
  469804:	mov    r9d,ebx
  469807:	and    r9d,r12d
  46980a:	shl    r9,0x4
  46980e:	add    r9,r14
  469811:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  469817:	vpbroadcastq zmm1,r10
  46981d:	vpcmpequq k0{k1},zmm0,zmm1
  469824:	kortestb k0,k0
  469828:	jne    4698a4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad4>
  46982a:	vpcmpequq k3{k1},zmm0,zmm2
  469831:	kortestb k3,k3
  469835:	jne    4698e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb18>
  46983b:	cmp    QWORD PTR [rsp],0x4
  469840:	mov    r9d,r12d
  469843:	je     469911 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb41>
  469849:	cmp    QWORD PTR [rsp],0x8
  46984e:	je     469931 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb61>
  469854:	mov    r9d,DWORD PTR [rsp-0x28]
  469859:	mov    r12,QWORD PTR [rsp-0x10]
  46985e:	vmovd  xmm4,r9d
  469863:	vpinsrd xmm3,xmm4,DWORD PTR [rsi+0xc],0x1
  46986a:	mov    esi,edi
  46986c:	and    r12,QWORD PTR [rsp-0x28]
  469871:	shl    rsi,0x4
  469875:	inc    edi
  469877:	inc    eax
  469879:	add    rsi,r11
  46987c:	shl    r12,0x4
  469880:	and    edi,r8d
  469883:	and    eax,r8d
  469886:	prefetcht2 BYTE PTR [r14+r12*1]
  46988b:	mov    QWORD PTR [rsi],r10
  46988e:	vmovq  QWORD PTR [rsi+0x8],xmm3
  469893:	mov    DWORD PTR [rcx+0xc0],edi
  469899:	mov    DWORD PTR [rcx+0xc4],eax
  46989f:	jmp    469788 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  4698a4:	mov    r10d,DWORD PTR [r15]
  4698a7:	mov    r12d,DWORD PTR [rsi+0xc]
  4698ab:	mov    rbx,r10
  4698ae:	shl    r10,0x4
  4698b2:	add    r10,QWORD PTR [r15+0x8]
  4698b6:	mov    DWORD PTR [r10],r12d
  4698b9:	xor    r12d,r12d
  4698bc:	kmovb  esi,k0
  4698c0:	tzcnt  r12d,esi
  4698c5:	inc    r12d
  4698c8:	movsxd rsi,r12d
  4698cb:	mov    r9,QWORD PTR [r9+rsi*8]
  4698cf:	inc    eax
  4698d1:	inc    ebx
  4698d3:	and    eax,r8d
  4698d6:	mov    QWORD PTR [r10+0x8],r9
  4698da:	mov    DWORD PTR [r15],ebx
  4698dd:	mov    DWORD PTR [rcx+0xc4],eax
  4698e3:	jmp    469754 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  4698e8:	inc    eax
  4698ea:	and    eax,r8d
  4698ed:	mov    DWORD PTR [rcx+0xc4],eax
  4698f3:	jmp    469754 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  4698f8:	mov    eax,0xffffffff
  4698fd:	crc32  rax,QWORD PTR [rdx]
  469903:	mov    QWORD PTR [rsp-0x18],rax
  469908:	vmovd  xmm5,eax
  46990c:	jmp    4696f5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
  469911:	mov    r9d,0xffffffff
  469917:	crc32  r9d,r12d
  46991d:	mov    r12d,r9d
  469920:	mov    QWORD PTR [rsp-0x28],r12
  469925:	jmp    469859 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  46992a:	xor    edi,edi
  46992c:	jmp    4691d6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x406>
  469931:	mov    r12d,0xffffffff
  469937:	crc32  r12,r9
  46993d:	mov    QWORD PTR [rsp-0x28],r12
  469942:	mov    r9d,r12d
  469945:	jmp    469859 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
  46994a:	inc    DWORD PTR [rsp-0x2c]
  46994e:	jmp    468f7a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469953:	inc    DWORD PTR [rsp-0x2c]
  469957:	vpxor  xmm15,xmm15,xmm15
  46995c:	xor    r11d,r11d
  46995f:	vpxor  xmm12,xmm12,xmm12
  469964:	jmp    468f03 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  469969:	inc    DWORD PTR [rsp-0x2c]
  46996d:	jmp    468ff2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
