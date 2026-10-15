0000000000468dd0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468dd0:	push   rbp
  468dd1:	mov    rcx,rdi
  468dd4:	mov    r8,rdx
  468dd7:	mov    rbp,rsp
  468dda:	push   r15
  468ddc:	push   r14
  468dde:	push   r13
  468de0:	push   r12
  468de2:	push   rbx
  468de3:	and    rsp,0xffffffffffffffc0
  468de7:	sub    rsp,0x8
  468deb:	mov    r11,QWORD PTR [rsi+0x8]
  468def:	mov    edi,DWORD PTR [rdi+0xb0]
  468df5:	mov    eax,DWORD PTR [rcx+0xb4]
  468dfb:	mov    rdx,QWORD PTR [rsi]
  468dfe:	mov    r9d,DWORD PTR [rcx+0x78]
  468e02:	mov    r10d,DWORD PTR [rcx+0x6c]
  468e06:	mov    rbx,r11
  468e09:	mov    esi,edi
  468e0b:	shl    rbx,0x4
  468e0f:	sub    esi,eax
  468e11:	add    rbx,rdx
  468e14:	and    esi,r9d
  468e17:	lea    r12d,[r10-0x1]
  468e1b:	mov    QWORD PTR [rsp-0x20],rbx
  468e20:	cmp    esi,r12d
  468e23:	jb     4696e3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x913>
  468e29:	and    r11,0xfffffffffffffffc
  468e2d:	shl    r11,0x4
  468e31:	mov    r15,QWORD PTR [r8+0x8]
  468e35:	mov    esi,DWORD PTR [rcx+0x80]
  468e3b:	shl    r10,0x4
  468e3f:	mov    ebx,edi
  468e41:	lea    r14,[rdx+r11*1]
  468e45:	mov    QWORD PTR [rsp-0x28],r10
  468e4a:	mov    QWORD PTR [rsp],r15
  468e4e:	mov    QWORD PTR [rsp-0x40],r11
  468e53:	mov    QWORD PTR [rsp-0x30],r14
  468e58:	mov    DWORD PTR [rsp-0x34],0x0
  468e60:	mov    r9,QWORD PTR [rcx+0xa0]
  468e67:	mov    rdi,QWORD PTR [rip+0x29d7a]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468e6e:	dec    r10
  468e71:	shl    rax,0x4
  468e75:	shl    rbx,0x4
  468e79:	not    esi
  468e7b:	cmp    rdx,r14
  468e7e:	je     46997b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbab>
  468e84:	mov    r13d,0x55
  468e8a:	mov    r11d,0xf
  468e90:	mov    r12d,0xf0
  468e96:	mov    r15d,0xf00
  468e9c:	mov    r14d,0xfffff000
  468ea2:	kmovb  k1,r13d
  468ea7:	vpxor  xmm4,xmm4,xmm4
  468eab:	mov    r13d,0xffffffff
  468eb1:	kmovw  k5,r11d
  468eb6:	kmovw  k4,r12d
  468ebb:	kmovw  k3,r15d
  468ec0:	kmovw  k2,r14d
  468ec5:	jmp    46915c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x38c>
  468eca:	nop    WORD PTR [rax+rax*1+0x0]
  468ed0:	vmovd  xmm13,DWORD PTR [r12+0xc]
  468ed7:	kshiftlb k6,k6,0x1
  468edd:	vpcompressq zmm12{k6}{z},zmm8
  468ee3:	vpunpcklqdq xmm14,xmm13,xmm12
  468ee8:	vshufi32x4 zmm15{k5}{z},zmm14,zmm14,0x0
  468eef:	vmovdqa64 zmm12,zmm15
  468ef5:	mov    r11d,0x1
  468efb:	lea    r15,[rax+0x180]
  468f02:	and    r15,r10
  468f05:	andn   r14d,esi,DWORD PTR [r9+r15*1+0x8]
  468f0c:	mov    r12d,r14d
  468f0f:	shl    r12,0x4
  468f13:	lea    r14,[r9+rax*1]
  468f17:	mov    r15d,DWORD PTR [r14+0x8]
  468f1b:	prefetcht0 BYTE PTR [rdi+r12*1]
  468f20:	andn   r12d,esi,r15d
  468f25:	mov    r12d,r12d
  468f28:	shl    r12,0x4
  468f2c:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r12*1]
  468f33:	vpbroadcastq zmm2,QWORD PTR [r14]
  468f39:	vpcmpequq k0{k1},zmm0,zmm2
  468f40:	add    rax,0x10
  468f44:	and    rax,r10
  468f47:	kortestb k0,k0
  468f4b:	je     469600 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x830>
  468f51:	vmovd  xmm1,DWORD PTR [r14+0xc]
  468f57:	kshiftlb k6,k0,0x1
  468f5d:	vpcompressq zmm5{k6}{z},zmm0
  468f63:	vpunpcklqdq xmm6,xmm1,xmm5
  468f67:	vshufi32x4 zmm15{k4},zmm6,zmm6,0x0
  468f6e:	vmovdqa64 zmm12,zmm15
  468f74:	or     r11d,0x2
  468f78:	lea    r14,[rax+0x180]
  468f7f:	and    r14,r10
  468f82:	andn   r12d,esi,DWORD PTR [r9+r14*1+0x8]
  468f89:	mov    r15d,r12d
  468f8c:	shl    r15,0x4
  468f90:	lea    r14,[r9+rax*1]
  468f94:	prefetcht0 BYTE PTR [rdi+r15*1]
  468f99:	mov    r15d,DWORD PTR [r14+0x8]
  468f9d:	andn   r12d,esi,r15d
  468fa2:	mov    r12d,r12d
  468fa5:	shl    r12,0x4
  468fa9:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r12*1]
  468fb0:	vpbroadcastq zmm9,QWORD PTR [r14]
  468fb6:	vpcmpequq k0{k1},zmm8,zmm9
  468fbd:	add    rax,0x10
  468fc1:	and    rax,r10
  468fc4:	kortestb k0,k0
  468fc8:	je     4695a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
  468fce:	vmovd  xmm13,DWORD PTR [r14+0xc]
  468fd4:	kshiftlb k6,k0,0x1
  468fda:	vpcompressq zmm12{k6}{z},zmm8
  468fe0:	vpunpcklqdq xmm14,xmm13,xmm12
  468fe5:	mov    QWORD PTR [rsp-0x10],rdx
  468fea:	vshufi32x4 zmm15{k3},zmm14,zmm14,0x0
  468ff1:	vmovdqa64 zmm12,zmm15
  468ff7:	or     r11d,0x4
  468ffb:	lea    rdx,[rax+0x180]
  469002:	and    rdx,r10
  469005:	andn   r14d,esi,DWORD PTR [r9+rdx*1+0x8]
  46900c:	mov    r12d,r14d
  46900f:	shl    r12,0x4
  469013:	lea    r14,[r9+rax*1]
  469017:	mov    r15d,DWORD PTR [r14+0x8]
  46901b:	prefetcht0 BYTE PTR [rdi+r12*1]
  469020:	andn   edx,esi,r15d
  469025:	mov    r12d,edx
  469028:	shl    r12,0x4
  46902c:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r12*1]
  469033:	vpbroadcastq zmm2,QWORD PTR [r14]
  469039:	vpcmpequq k0{k1},zmm0,zmm2
  469040:	add    rax,0x10
  469044:	and    rax,r10
  469047:	lea    r12,[r9+rbx*1]
  46904b:	kortestb k0,k0
  46904f:	je     469548 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x778>
  469055:	vmovd  xmm1,DWORD PTR [r14+0xc]
  46905b:	kshiftlb k6,k0,0x1
  469061:	vpcompressq zmm5{k6}{z},zmm0
  469067:	vpunpcklqdq xmm6,xmm1,xmm5
  46906b:	vshufi32x4 zmm15{k2},zmm6,zmm6,0x0
  469072:	or     r11d,0x8
  469076:	mov    rdx,QWORD PTR [rsp-0x10]
  46907b:	vmovdqa64 zmm12,zmm15
  469081:	cmp    r11d,0xf
  469085:	jne    4696b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8e0>
  46908b:	mov    r14,QWORD PTR [rsp]
  46908f:	vmovdqu64 ZMMWORD PTR [r14],zmm15
  469095:	add    r14,0x40
  469099:	mov    QWORD PTR [rsp],r14
  46909d:	mov    r15,r13
  4690a0:	mov    r14,r13
  4690a3:	crc32  r15,QWORD PTR [rdx]
  4690a9:	crc32  r14,QWORD PTR [rdx+0x20]
  4690b0:	andn   r11d,esi,r15d
  4690b5:	shl    r11,0x4
  4690b9:	prefetcht2 BYTE PTR [rdi+r11*1]
  4690be:	mov    r11,r13
  4690c1:	crc32  r11,QWORD PTR [rdx+0x10]
  4690c8:	vmovq  xmm15,r15
  4690cd:	vmovq  xmm8,r14
  4690d2:	andn   r15d,esi,r11d
  4690d7:	shl    r15,0x4
  4690db:	prefetcht2 BYTE PTR [rdi+r15*1]
  4690e0:	mov    r15d,r14d
  4690e3:	andn   r14d,esi,r15d
  4690e8:	shl    r14,0x4
  4690ec:	prefetcht2 BYTE PTR [rdi+r14*1]
  4690f1:	mov    r14,r13
  4690f4:	crc32  r14,QWORD PTR [rdx+0x30]
  4690fb:	vpinsrd xmm10,xmm15,r11d,0x1
  469101:	vmovdqu32 zmm13,ZMMWORD PTR [rdx]
  469107:	mov    r11d,0x4444
  46910d:	vpinsrd xmm9,xmm8,r14d,0x1
  469113:	kmovw  k6,r11d
  469118:	vpunpcklqdq xmm11,xmm10,xmm9
  46911d:	lea    r11,[rbx+0x40]
  469121:	andn   r15d,esi,r14d
  469126:	shl    r15,0x4
  46912a:	vpexpandd zmm13{k6},zmm11
  469130:	prefetcht2 BYTE PTR [rdi+r15*1]
  469135:	cmp    QWORD PTR [rsp-0x28],r11
  46913a:	jb     469660 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x890>
  469140:	vmovdqu64 ZMMWORD PTR [r12],zmm13
  469147:	mov    rbx,r11
  46914a:	add    rdx,0x40
  46914e:	and    rbx,r10
  469151:	cmp    QWORD PTR [rsp-0x30],rdx
  469156:	je     469210 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x440>
  46915c:	lea    r11,[rax+0x180]
  469163:	and    r11,r10
  469166:	andn   r12d,esi,DWORD PTR [r9+r11*1+0x8]
  46916d:	mov    r15d,r12d
  469170:	shl    r15,0x4
  469174:	lea    r12,[r9+rax*1]
  469178:	mov    r14d,DWORD PTR [r12+0x8]
  46917d:	prefetcht0 BYTE PTR [rdi+r15*1]
  469182:	andn   r11d,esi,r14d
  469187:	mov    r15d,r11d
  46918a:	shl    r15,0x4
  46918e:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r15*1]
  469195:	vpbroadcastq zmm9,QWORD PTR [r12]
  46919c:	vpcmpequq k6{k1},zmm8,zmm9
  4691a3:	add    rax,0x10
  4691a7:	and    rax,r10
  4691aa:	kortestb k6,k6
  4691ae:	jne    468ed0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x100>
  4691b4:	vpcmpequq k7{k1},zmm8,zmm4
  4691bb:	kortestb k7,k7
  4691bf:	jne    4699a5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbd5>
  4691c5:	mov    r15,r13
  4691c8:	crc32  r15,r14
  4691ce:	vmovd  xmm10,r15d
  4691d3:	vpinsrd xmm11,xmm10,DWORD PTR [r12+0xc],0x1
  4691db:	mov    r12,QWORD PTR [r12]
  4691df:	lea    r11,[r9+rbx*1]
  4691e3:	add    rbx,0x10
  4691e7:	andn   r14d,esi,r15d
  4691ec:	shl    r14,0x4
  4691f0:	and    rbx,r10
  4691f3:	prefetcht2 BYTE PTR [rdi+r14*1]
  4691f8:	mov    QWORD PTR [r11],r12
  4691fb:	vmovq  QWORD PTR [r11+0x8],xmm11
  469201:	jmp    46915c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x38c>
  469206:	cs nop WORD PTR [rax+rax*1+0x0]
  469210:	mov    r12d,DWORD PTR [rsp-0x34]
  469215:	vmovq  xmm14,rbx
  46921a:	vpinsrq xmm0,xmm14,rax,0x1
  469220:	mov    rsi,QWORD PTR [rsp-0x40]
  469225:	vpsrlq xmm2,xmm0,0x4
  46922a:	vpmovqd xmm7,xmm2
  469230:	sar    rsi,0x4
  469234:	vmovq  QWORD PTR [rcx+0xb0],xmm7
  46923c:	sub    rsi,r12
  46923f:	add    DWORD PTR [r8],esi
  469242:	vpextrd eax,xmm7,0x1
  469248:	cmp    rdx,QWORD PTR [rsp-0x20]
  46924d:	je     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x760>
  469253:	mov    r15,QWORD PTR [rcx+0x88]
  46925a:	mov    r12,QWORD PTR [rcx+0x80]
  469261:	mov    rdi,QWORD PTR [rcx+0x60]
  469265:	dec    r15
  469268:	mov    QWORD PTR [rsp-0x10],r12
  46926d:	mov    QWORD PTR [rsp],rdi
  469271:	mov    QWORD PTR [rsp-0x28],r15
  469276:	mov    r11d,DWORD PTR [rcx+0x78]
  46927a:	mov    rbx,QWORD PTR [rip+0x29967]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469281:	mov    r10,QWORD PTR [rcx+0xa0]
  469288:	movzx  r14d,BYTE PTR [rip+0x29870]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469290:	mov    r13,QWORD PTR [rip+0x29871]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469297:	mov    r9d,0x55
  46929d:	vpxor  xmm3,xmm3,xmm3
  4692a1:	kmovb  k1,r9d
  4692a6:	cs nop WORD PTR [rax+rax*1+0x0]
  4692b0:	lea    esi,[rax+0x18]
  4692b3:	and    esi,r11d
  4692b6:	shl    rsi,0x4
  4692ba:	mov    edi,r12d
  4692bd:	and    edi,DWORD PTR [r10+rsi*1+0x8]
  4692c2:	mov    esi,eax
  4692c4:	shl    rsi,0x4
  4692c8:	add    rsi,r10
  4692cb:	mov    r9,QWORD PTR [rsi]
  4692ce:	shl    rdi,0x4
  4692d2:	prefetcht0 BYTE PTR [rbx+rdi*1]
  4692d6:	cmp    r9,QWORD PTR [rcx+0x90]
  4692dd:	jne    4693a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5d0>
  4692e3:	test   r14b,r14b
  4692e6:	je     469306 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x536>
  4692e8:	mov    r15d,DWORD PTR [r8]
  4692eb:	mov    esi,DWORD PTR [rsi+0xc]
  4692ee:	mov    r9,r15
  4692f1:	shl    r15,0x4
  4692f5:	add    r15,QWORD PTR [r8+0x8]
  4692f9:	inc    r9d
  4692fc:	mov    DWORD PTR [r15],esi
  4692ff:	mov    QWORD PTR [r15+0x8],r13
  469303:	mov    DWORD PTR [r8],r9d
  469306:	inc    eax
  469308:	and    eax,r11d
  46930b:	mov    DWORD PTR [rcx+0xb4],eax
  469311:	test   r13,r13
  469314:	jne    4692b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4e0>
  469316:	cmp    QWORD PTR [rsp],0x4
  46931b:	je     469495 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c5>
  469321:	nop    DWORD PTR [rax+0x0]
  469328:	cmp    QWORD PTR [rsp],0x8
  46932d:	je     469510 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x740>
  469333:	vmovd  xmm15,DWORD PTR [rsp-0x18]
  469339:	mov    rdi,QWORD PTR [rdx]
  46933c:	mov    esi,DWORD PTR [rcx+0xb0]
  469342:	mov    r9,QWORD PTR [rsp-0x28]
  469347:	mov    rax,rsi
  46934a:	and    r9,QWORD PTR [rsp-0x18]
  46934f:	vpinsrd xmm9,xmm15,DWORD PTR [rdx+0xc],0x1
  469356:	and    r9,0xfffffffffffffffc
  46935a:	shl    rsi,0x4
  46935e:	inc    eax
  469360:	add    rsi,r10
  469363:	shl    r9,0x4
  469367:	and    eax,r11d
  46936a:	add    rdx,0x10
  46936e:	prefetcht2 BYTE PTR [rbx+r9*1]
  469373:	mov    QWORD PTR [rsi],rdi
  469376:	vmovq  QWORD PTR [rsi+0x8],xmm9
  46937b:	mov    DWORD PTR [rcx+0xb0],eax
  469381:	cmp    rdx,QWORD PTR [rsp-0x20]
  469386:	je     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x760>
  46938c:	mov    eax,DWORD PTR [rcx+0xb4]
  469392:	jmp    4692b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4e0>
  469397:	nop    WORD PTR [rax+rax*1+0x0]
  4693a0:	mov    r15d,DWORD PTR [rsi+0x8]
  4693a4:	mov    edi,r12d
  4693a7:	and    edi,r15d
  4693aa:	shl    rdi,0x4
  4693ae:	add    rdi,rbx
  4693b1:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  4693b7:	vpbroadcastq zmm1,r9
  4693bd:	vpcmpequq k0{k1},zmm5,zmm1
  4693c4:	kortestb k0,k0
  4693c8:	jne    469450 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x680>
  4693ce:	vpcmpequq k2{k1},zmm5,zmm3
  4693d5:	kortestb k2,k2
  4693d9:	jne    4694c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6f0>
  4693df:	cmp    QWORD PTR [rsp],0x4
  4693e4:	mov    edi,r15d
  4693e7:	je     4694d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
  4693ed:	cmp    QWORD PTR [rsp],0x8
  4693f2:	je     4694f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  4693f8:	vmovd  xmm6,DWORD PTR [rsp-0x8]
  4693fe:	mov    edi,DWORD PTR [rcx+0xb0]
  469404:	mov    r15,QWORD PTR [rsp-0x10]
  469409:	vpinsrd xmm4,xmm6,DWORD PTR [rsi+0xc],0x1
  469410:	mov    rsi,rdi
  469413:	and    r15,QWORD PTR [rsp-0x8]
  469418:	shl    rdi,0x4
  46941c:	inc    esi
  46941e:	inc    eax
  469420:	add    rdi,r10
  469423:	shl    r15,0x4
  469427:	and    esi,r11d
  46942a:	and    eax,r11d
  46942d:	prefetcht2 BYTE PTR [rbx+r15*1]
  469432:	mov    QWORD PTR [rdi],r9
  469435:	vmovq  QWORD PTR [rdi+0x8],xmm4
  46943a:	mov    DWORD PTR [rcx+0xb0],esi
  469440:	mov    DWORD PTR [rcx+0xb4],eax
  469446:	jmp    4692b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4e0>
  46944b:	nop    DWORD PTR [rax+rax*1+0x0]
  469450:	mov    r9d,DWORD PTR [r8]
  469453:	mov    esi,DWORD PTR [rsi+0xc]
  469456:	mov    r15,r9
  469459:	shl    r9,0x4
  46945d:	add    r9,QWORD PTR [r8+0x8]
  469461:	mov    DWORD PTR [r9],esi
  469464:	kmovb  esi,k0
  469468:	tzcnt  esi,esi
  46946c:	inc    esi
  46946e:	movsxd rsi,esi
  469471:	mov    rdi,QWORD PTR [rdi+rsi*8]
  469475:	inc    eax
  469477:	inc    r15d
  46947a:	and    eax,r11d
  46947d:	cmp    QWORD PTR [rsp],0x4
  469482:	mov    QWORD PTR [r9+0x8],rdi
  469486:	mov    DWORD PTR [r8],r15d
  469489:	mov    DWORD PTR [rcx+0xb4],eax
  46948f:	jne    469328 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x558>
  469495:	mov    r15d,0xffffffff
  46949b:	crc32  r15d,DWORD PTR [rdx]
  4694a1:	vmovd  xmm8,r15d
  4694a6:	mov    rdi,QWORD PTR [rdx]
  4694a9:	vmovdqa xmm15,xmm8
  4694ae:	vmovq  QWORD PTR [rsp-0x18],xmm8
  4694b4:	jmp    46933c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x56c>
  4694b9:	nop    DWORD PTR [rax+0x0]
  4694c0:	inc    eax
  4694c2:	and    eax,r11d
  4694c5:	mov    DWORD PTR [rcx+0xb4],eax
  4694cb:	jmp    469316 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x546>
  4694d0:	mov    edi,0xffffffff
  4694d5:	crc32  edi,r15d
  4694db:	vmovd  xmm12,edi
  4694df:	vmovdqa xmm6,xmm12
  4694e3:	vmovq  QWORD PTR [rsp-0x8],xmm12
  4694e9:	jmp    4693fe <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x62e>
  4694ee:	xchg   ax,ax
  4694f0:	mov    r15d,0xffffffff
  4694f6:	crc32  r15,rdi
  4694fc:	mov    QWORD PTR [rsp-0x8],r15
  469501:	vmovd  xmm6,r15d
  469506:	jmp    4693fe <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x62e>
  46950b:	nop    DWORD PTR [rax+rax*1+0x0]
  469510:	mov    rdi,QWORD PTR [rdx]
  469513:	mov    eax,0xffffffff
  469518:	crc32  rax,rdi
  46951e:	mov    QWORD PTR [rsp-0x18],rax
  469523:	vmovd  xmm15,eax
  469527:	jmp    46933c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x56c>
  46952c:	nop    DWORD PTR [rax+0x0]
  469530:	vzeroupper 
  469533:	lea    rsp,[rbp-0x28]
  469537:	pop    rbx
  469538:	pop    r12
  46953a:	pop    r13
  46953c:	pop    r14
  46953e:	pop    r15
  469540:	pop    rbp
  469541:	ret    
  469542:	nop    WORD PTR [rax+rax*1+0x0]
  469548:	vpcmpequq k7{k1},zmm0,zmm4
  46954f:	kortestb k7,k7
  469553:	jne    4696a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8d0>
  469559:	mov    rdx,r13
  46955c:	crc32  rdx,r15
  469562:	vmovq  xmm7,rdx
  469567:	vpinsrd xmm3,xmm7,DWORD PTR [r14+0xc],0x1
  46956e:	mov    r14,QWORD PTR [r14]
  469571:	add    rbx,0x10
  469575:	andn   r15d,esi,edx
  46957a:	shl    r15,0x4
  46957e:	and    rbx,r10
  469581:	prefetcht2 BYTE PTR [rdi+r15*1]
  469586:	mov    QWORD PTR [r12],r14
  46958a:	vmovq  QWORD PTR [r12+0x8],xmm3
  469591:	jmp    468ffb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x22b>
  469596:	cs nop WORD PTR [rax+rax*1+0x0]
  4695a0:	vpcmpequq k7{k1},zmm8,zmm4
  4695a7:	kortestb k7,k7
  4695ab:	jne    4699bb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbeb>
  4695b1:	lea    r12,[r9+rbx*1]
  4695b5:	mov    QWORD PTR [rsp-0x10],r12
  4695ba:	mov    r12,r13
  4695bd:	crc32  r12,r15
  4695c3:	vmovq  xmm10,r12
  4695c8:	vpinsrd xmm11,xmm10,DWORD PTR [r14+0xc],0x1
  4695cf:	andn   r15d,esi,r12d
  4695d4:	shl    r15,0x4
  4695d8:	mov    r14,QWORD PTR [r14]
  4695db:	mov    r12,QWORD PTR [rsp-0x10]
  4695e0:	add    rbx,0x10
  4695e4:	prefetcht2 BYTE PTR [rdi+r15*1]
  4695e9:	and    rbx,r10
  4695ec:	mov    QWORD PTR [r12],r14
  4695f0:	vmovq  QWORD PTR [r12+0x8],xmm11
  4695f7:	jmp    468f78 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a8>
  4695fc:	nop    DWORD PTR [rax+0x0]
  469600:	vpcmpequq k7{k1},zmm0,zmm4
  469607:	kortestb k7,k7
  46960b:	jne    46999c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbcc>
  469611:	lea    r12,[r9+rbx*1]
  469615:	mov    QWORD PTR [rsp-0x10],r12
  46961a:	mov    r12,r13
  46961d:	crc32  r12,r15
  469623:	vmovq  xmm7,r12
  469628:	vpinsrd xmm3,xmm7,DWORD PTR [r14+0xc],0x1
  46962f:	andn   r15d,esi,r12d
  469634:	shl    r15,0x4
  469638:	mov    r14,QWORD PTR [r14]
  46963b:	mov    r12,QWORD PTR [rsp-0x10]
  469640:	add    rbx,0x10
  469644:	prefetcht2 BYTE PTR [rdi+r15*1]
  469649:	and    rbx,r10
  46964c:	mov    QWORD PTR [r12],r14
  469650:	vmovq  QWORD PTR [r12+0x8],xmm3
  469657:	jmp    468efb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x12b>
  46965c:	nop    DWORD PTR [rax+0x0]
  469660:	mov    r14,QWORD PTR [rsp-0x28]
  469665:	mov    r15d,0x1
  46966b:	sub    r14,rbx
  46966e:	shr    r14,0x2
  469672:	shlx   r14d,r15d,r14d
  469677:	lea    r15d,[r14-0x1]
  46967b:	kmovw  k7,r15d
  469680:	vmovdqu32 ZMMWORD PTR [r12]{k7},zmm13
  469687:	sub    rbx,QWORD PTR [rsp-0x28]
  46968c:	neg    r14d
  46968f:	kmovw  k6,r14d
  469694:	vmovdqu32 ZMMWORD PTR [r9+rbx*1]{k6},zmm13
  46969b:	jmp    469147 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x377>
  4696a0:	inc    DWORD PTR [rsp-0x34]
  4696a4:	mov    rdx,QWORD PTR [rsp-0x10]
  4696a9:	nop    DWORD PTR [rax+0x0]
  4696b0:	mov    r15d,0x55
  4696b6:	pdep   r14d,r11d,r15d
  4696bb:	mov    r15,QWORD PTR [rsp]
  4696bf:	lea    r14d,[r14+r14*2]
  4696c3:	popcnt r11d,r11d
  4696c8:	shl    r11,0x4
  4696cc:	kmovb  k7,r14d
  4696d1:	vpcompressq ZMMWORD PTR [r15]{k7},zmm12
  4696d7:	add    r15,r11
  4696da:	mov    QWORD PTR [rsp],r15
  4696de:	jmp    46909d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2cd>
  4696e3:	cmp    rdx,QWORD PTR [rsp-0x20]
  4696e8:	je     469533 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x763>
  4696ee:	mov    r11,QWORD PTR [rcx+0x88]
  4696f5:	mov    r10,QWORD PTR [rcx+0x60]
  4696f9:	mov    r13d,0x55
  4696ff:	dec    r11
  469702:	mov    QWORD PTR [rsp],r10
  469706:	mov    QWORD PTR [rsp-0x8],r11
  46970b:	mov    r15,QWORD PTR [rip+0x294d6]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469712:	mov    r14,QWORD PTR [rip+0x293ef]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469719:	mov    rbx,QWORD PTR [rcx+0xa0]
  469720:	mov    r12d,edi
  469723:	vpxor  xmm2,xmm2,xmm2
  469727:	kmovb  k2,BYTE PTR [rip+0x293d1]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  46972f:	kmovb  k1,r13d
  469734:	jmp    46979f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9cf>
  469736:	cmp    QWORD PTR [rsp],0x8
  46973b:	je     469949 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb79>
  469741:	vmovd  xmm4,DWORD PTR [rsp-0x10]
  469747:	mov    r13,QWORD PTR [rsp-0x8]
  46974c:	mov    esi,edi
  46974e:	and    r13,QWORD PTR [rsp-0x10]
  469753:	vpinsrd xmm6,xmm4,DWORD PTR [rdx+0xc],0x1
  46975a:	mov    r11,QWORD PTR [rdx]
  46975d:	and    r13,0xfffffffffffffffc
  469761:	shl    rsi,0x4
  469765:	lea    r12d,[rdi+0x1]
  469769:	add    rsi,rbx
  46976c:	shl    r13,0x4
  469770:	and    r12d,r9d
  469773:	add    rdx,0x10
  469777:	prefetcht2 BYTE PTR [r15+r13*1]
  46977c:	mov    QWORD PTR [rsi],r11
  46977f:	vmovq  QWORD PTR [rsi+0x8],xmm6
  469784:	mov    DWORD PTR [rcx+0xb0],r12d
  46978b:	cmp    QWORD PTR [rsp-0x20],rdx
  469790:	je     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x760>
  469796:	mov    eax,DWORD PTR [rcx+0xb4]
  46979c:	mov    edi,r12d
  46979f:	sub    r12d,eax
  4697a2:	and    r12d,r9d
  4697a5:	cmp    r9d,r12d
  4697a8:	jbe    4697d1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa01>
  4697aa:	cmp    QWORD PTR [rsp],0x4
  4697af:	jne    469736 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x966>
  4697b1:	mov    r12d,0xffffffff
  4697b7:	crc32  r12d,DWORD PTR [rdx]
  4697bd:	vmovd  xmm5,r12d
  4697c2:	vmovdqa xmm4,xmm5
  4697c6:	vmovq  QWORD PTR [rsp-0x10],xmm5
  4697cc:	jmp    469747 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x977>
  4697d1:	mov    r12,QWORD PTR [rcx+0x80]
  4697d8:	mov    QWORD PTR [rsp-0x18],r12
  4697dd:	nop    DWORD PTR [rax]
  4697e0:	lea    esi,[rax+0x18]
  4697e3:	and    esi,r9d
  4697e6:	shl    rsi,0x4
  4697ea:	mov    r10d,r12d
  4697ed:	and    r10d,DWORD PTR [rbx+rsi*1+0x8]
  4697f2:	mov    esi,eax
  4697f4:	shl    rsi,0x4
  4697f8:	add    rsi,rbx
  4697fb:	mov    r11,QWORD PTR [rsi]
  4697fe:	shl    r10,0x4
  469802:	prefetcht0 BYTE PTR [r15+r10*1]
  469807:	cmp    r11,QWORD PTR [rcx+0x90]
  46980e:	jne    469850 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa80>
  469810:	kortestb k2,k2
  469814:	je     469836 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa66>
  469816:	mov    r13d,DWORD PTR [r8]
  469819:	mov    esi,DWORD PTR [rsi+0xc]
  46981c:	mov    r11,r13
  46981f:	shl    r13,0x4
  469823:	add    r13,QWORD PTR [r8+0x8]
  469827:	lea    r10d,[r11+0x1]
  46982b:	mov    DWORD PTR [r13+0x0],esi
  46982f:	mov    QWORD PTR [r13+0x8],r14
  469833:	mov    DWORD PTR [r8],r10d
  469836:	inc    eax
  469838:	and    eax,r9d
  46983b:	mov    DWORD PTR [rcx+0xb4],eax
  469841:	test   r14,r14
  469844:	jne    4697e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa10>
  469846:	jmp    4697aa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9da>
  46984b:	nop    DWORD PTR [rax+rax*1+0x0]
  469850:	mov    r13d,DWORD PTR [rsi+0x8]
  469854:	mov    r10d,r12d
  469857:	and    r10d,r13d
  46985a:	shl    r10,0x4
  46985e:	add    r10,r15
  469861:	vmovdqa64 zmm0,ZMMWORD PTR [r10]
  469867:	vpbroadcastq zmm1,r11
  46986d:	vpcmpequq k0{k1},zmm0,zmm1
  469874:	kortestb k0,k0
  469878:	jne    4698f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb24>
  46987a:	vpcmpequq k3{k1},zmm0,zmm2
  469881:	kortestb k3,k3
  469885:	jne    469939 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb69>
  46988b:	cmp    QWORD PTR [rsp],0x4
  469890:	mov    r10d,r13d
  469893:	je     469962 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb92>
  469899:	cmp    QWORD PTR [rsp],0x8
  46989e:	je     469983 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbb3>
  4698a4:	mov    r10d,DWORD PTR [rsp-0x28]
  4698a9:	mov    r13,QWORD PTR [rsp-0x18]
  4698ae:	vmovd  xmm7,r10d
  4698b3:	vpinsrd xmm3,xmm7,DWORD PTR [rsi+0xc],0x1
  4698ba:	mov    esi,edi
  4698bc:	and    r13,QWORD PTR [rsp-0x28]
  4698c1:	shl    rsi,0x4
  4698c5:	inc    edi
  4698c7:	inc    eax
  4698c9:	add    rsi,rbx
  4698cc:	shl    r13,0x4
  4698d0:	and    edi,r9d
  4698d3:	and    eax,r9d
  4698d6:	prefetcht2 BYTE PTR [r15+r13*1]
  4698db:	mov    QWORD PTR [rsi],r11
  4698de:	vmovq  QWORD PTR [rsi+0x8],xmm3
  4698e3:	mov    DWORD PTR [rcx+0xb0],edi
  4698e9:	mov    DWORD PTR [rcx+0xb4],eax
  4698ef:	jmp    4697e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa10>
  4698f4:	mov    r11d,DWORD PTR [r8]
  4698f7:	mov    r13d,DWORD PTR [rsi+0xc]
  4698fb:	mov    r12,r11
  4698fe:	shl    r11,0x4
  469902:	add    r11,QWORD PTR [r8+0x8]
  469906:	mov    DWORD PTR [r11],r13d
  469909:	xor    r13d,r13d
  46990c:	kmovb  esi,k0
  469910:	tzcnt  r13d,esi
  469915:	inc    r13d
  469918:	movsxd rsi,r13d
  46991b:	mov    r10,QWORD PTR [r10+rsi*8]
  46991f:	inc    eax
  469921:	inc    r12d
  469924:	and    eax,r9d
  469927:	mov    QWORD PTR [r11+0x8],r10
  46992b:	mov    DWORD PTR [r8],r12d
  46992e:	mov    DWORD PTR [rcx+0xb4],eax
  469934:	jmp    4697aa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9da>
  469939:	inc    eax
  46993b:	and    eax,r9d
  46993e:	mov    DWORD PTR [rcx+0xb4],eax
  469944:	jmp    4697aa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9da>
  469949:	mov    eax,0xffffffff
  46994e:	crc32  rax,QWORD PTR [rdx]
  469954:	mov    QWORD PTR [rsp-0x10],rax
  469959:	vmovd  xmm4,eax
  46995d:	jmp    469747 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x977>
  469962:	mov    r10d,0xffffffff
  469968:	crc32  r10d,r13d
  46996e:	mov    r13d,r10d
  469971:	mov    QWORD PTR [rsp-0x28],r13
  469976:	jmp    4698a9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad9>
  46997b:	xor    r12d,r12d
  46997e:	jmp    469215 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x445>
  469983:	mov    r13d,0xffffffff
  469989:	crc32  r13,r10
  46998f:	mov    QWORD PTR [rsp-0x28],r13
  469994:	mov    r10d,r13d
  469997:	jmp    4698a9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad9>
  46999c:	inc    DWORD PTR [rsp-0x34]
  4699a0:	jmp    468f78 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a8>
  4699a5:	inc    DWORD PTR [rsp-0x34]
  4699a9:	vpxor  xmm15,xmm15,xmm15
  4699ae:	xor    r11d,r11d
  4699b1:	vpxor  xmm12,xmm12,xmm12
  4699b6:	jmp    468efb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x12b>
  4699bb:	inc    DWORD PTR [rsp-0x34]
  4699bf:	mov    QWORD PTR [rsp-0x10],rdx
  4699c4:	jmp    468ffb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x22b>
