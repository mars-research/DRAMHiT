0000000000468e20 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468e20:	push   rbp
  468e21:	mov    rcx,rdi
  468e24:	mov    rbp,rsp
  468e27:	push   r15
  468e29:	mov    r15,rdx
  468e2c:	push   r14
  468e2e:	push   r13
  468e30:	push   r12
  468e32:	push   rbx
  468e33:	and    rsp,0xffffffffffffffc0
  468e37:	sub    rsp,0x8
  468e3b:	mov    r11,QWORD PTR [rsi+0x8]
  468e3f:	mov    edi,DWORD PTR [rdi+0xb0]
  468e45:	mov    eax,DWORD PTR [rcx+0xb4]
  468e4b:	mov    rdx,QWORD PTR [rsi]
  468e4e:	mov    r8d,DWORD PTR [rcx+0x78]
  468e52:	mov    r9d,DWORD PTR [rcx+0x6c]
  468e56:	mov    r10,r11
  468e59:	mov    esi,edi
  468e5b:	shl    r10,0x4
  468e5f:	sub    esi,eax
  468e61:	lea    rbx,[rdx+r10*1]
  468e65:	and    esi,r8d
  468e68:	lea    r12d,[r9-0x1]
  468e6c:	mov    QWORD PTR [rsp-0x20],rbx
  468e71:	cmp    esi,r12d
  468e74:	jb     469703 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8e3>
  468e7a:	and    r11,0xfffffffffffffffc
  468e7e:	shl    r9,0x4
  468e82:	shl    r11,0x4
  468e86:	mov    r14,QWORD PTR [r15+0x8]
  468e8a:	mov    esi,DWORD PTR [rcx+0x80]
  468e90:	mov    QWORD PTR [rsp-0x18],r9
  468e95:	mov    QWORD PTR [rsp-0x38],r11
  468e9a:	lea    r10,[r9-0x1]
  468e9e:	lea    r11,[rdx+r11*1]
  468ea2:	mov    r9d,edi
  468ea5:	mov    QWORD PTR [rsp],r14
  468ea9:	mov    QWORD PTR [rsp-0x28],r11
  468eae:	mov    DWORD PTR [rsp-0x2c],0x0
  468eb6:	mov    r8,QWORD PTR [rcx+0xa0]
  468ebd:	mov    rdi,QWORD PTR [rip+0x29d24]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468ec4:	shl    rax,0x4
  468ec8:	shl    r9,0x4
  468ecc:	not    esi
  468ece:	cmp    rdx,r11
  468ed1:	je     46999a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb7a>
  468ed7:	mov    r13d,0x55
  468edd:	mov    ebx,0xf
  468ee2:	mov    r12d,0xf0
  468ee8:	mov    r11d,0xf00
  468eee:	kmovb  k2,r13d
  468ef3:	mov    r13d,0xfffff000
  468ef9:	mov    QWORD PTR [rsp-0x40],rcx
  468efe:	mov    QWORD PTR [rsp-0x48],r15
  468f03:	vpxor  xmm4,xmm4,xmm4
  468f07:	mov    r14d,0xffffffff
  468f0d:	kmovw  k6,ebx
  468f11:	kmovw  k5,r12d
  468f16:	kmovw  k4,r11d
  468f1b:	kmovw  k3,r13d
  468f20:	jmp    469188 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x368>
  468f25:	nop    DWORD PTR [rax]
  468f28:	vmovd  xmm13,DWORD PTR [r11+0xc]
  468f2e:	kshiftlb k7,k7,0x1
  468f34:	vpcompressq zmm12{k7}{z},zmm8
  468f3a:	vpunpcklqdq xmm14,xmm13,xmm12
  468f3f:	vshufi32x4 zmm15{k6}{z},zmm14,zmm14,0x0
  468f46:	vmovdqa64 zmm12,zmm15
  468f4c:	mov    r11d,0x1
  468f52:	lea    rbx,[r8+rax*1]
  468f56:	lea    r13,[rax+0x180]
  468f5d:	and    r13,r10
  468f60:	mov    r12d,DWORD PTR [rbx+0x8]
  468f64:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  468f6b:	andn   r13d,esi,r12d
  468f70:	mov    r15d,ecx
  468f73:	mov    ecx,r13d
  468f76:	shl    rcx,0x4
  468f7a:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+rcx*1]
  468f81:	vpbroadcastq zmm2,QWORD PTR [rbx]
  468f87:	vpcmpequq k0{k2},zmm0,zmm2
  468f8e:	shl    r15,0x4
  468f92:	add    rax,0x10
  468f96:	and    rax,r10
  468f99:	prefetcht0 BYTE PTR [rdi+r15*1]
  468f9e:	kortestb k0,k0
  468fa2:	je     469610 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7f0>
  468fa8:	vmovd  xmm1,DWORD PTR [rbx+0xc]
  468fad:	kshiftlb k7,k0,0x1
  468fb3:	vpcompressq zmm6{k7}{z},zmm0
  468fb9:	vpunpcklqdq xmm7,xmm1,xmm6
  468fbd:	vshufi32x4 zmm15{k5},zmm7,zmm7,0x0
  468fc4:	vmovdqa64 zmm12,zmm15
  468fca:	or     r11d,0x2
  468fce:	lea    rbx,[r8+rax*1]
  468fd2:	lea    rcx,[rax+0x180]
  468fd9:	and    rcx,r10
  468fdc:	mov    r12d,DWORD PTR [rbx+0x8]
  468fe0:	andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
  468fe7:	andn   ecx,esi,r12d
  468fec:	mov    r13d,r15d
  468fef:	mov    r15d,ecx
  468ff2:	shl    r15,0x4
  468ff6:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r15*1]
  468ffd:	vpbroadcastq zmm9,QWORD PTR [rbx]
  469003:	vpcmpequq k0{k2},zmm8,zmm9
  46900a:	shl    r13,0x4
  46900e:	add    rax,0x10
  469012:	and    rax,r10
  469015:	prefetcht0 BYTE PTR [rdi+r13*1]
  46901a:	kortestb k0,k0
  46901e:	je     4695b8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x798>
  469024:	vmovd  xmm13,DWORD PTR [rbx+0xc]
  469029:	kshiftlb k7,k0,0x1
  46902f:	vpcompressq zmm12{k7}{z},zmm8
  469035:	vpunpcklqdq xmm14,xmm13,xmm12
  46903a:	vshufi32x4 zmm15{k4},zmm14,zmm14,0x0
  469041:	vmovdqa64 zmm12,zmm15
  469047:	or     r11d,0x4
  46904b:	lea    rbx,[r8+rax*1]
  46904f:	lea    r15,[rax+0x180]
  469056:	and    r15,r10
  469059:	mov    r12d,DWORD PTR [rbx+0x8]
  46905d:	andn   r13d,esi,DWORD PTR [r8+r15*1+0x8]
  469064:	andn   r15d,esi,r12d
  469069:	mov    ecx,r13d
  46906c:	mov    r13d,r15d
  46906f:	shl    r13,0x4
  469073:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r13*1]
  46907a:	vpbroadcastq zmm2,QWORD PTR [rbx]
  469080:	vpcmpequq k0{k2},zmm0,zmm2
  469087:	shl    rcx,0x4
  46908b:	add    rax,0x10
  46908f:	and    rax,r10
  469092:	prefetcht0 BYTE PTR [rdi+rcx*1]
  469096:	kortestb k0,k0
  46909a:	lea    rcx,[r8+r9*1]
  46909e:	je     469568 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x748>
  4690a4:	vmovd  xmm1,DWORD PTR [rbx+0xc]
  4690a9:	kshiftlb k7,k0,0x1
  4690af:	vpcompressq zmm6{k7}{z},zmm0
  4690b5:	vpunpcklqdq xmm7,xmm1,xmm6
  4690b9:	vshufi32x4 zmm15{k3},zmm7,zmm7,0x0
  4690c0:	or     r11d,0x8
  4690c4:	vmovdqa64 zmm12,zmm15
  4690ca:	cmp    r11d,0xf
  4690ce:	jne    4696d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8b0>
  4690d4:	mov    r13,QWORD PTR [rsp]
  4690d8:	vmovdqu64 ZMMWORD PTR [r13+0x0],zmm15
  4690df:	add    r13,0x40
  4690e3:	mov    QWORD PTR [rsp],r13
  4690e7:	mov    rbx,r14
  4690ea:	mov    r11,r14
  4690ed:	crc32  rbx,QWORD PTR [rdx]
  4690f3:	mov    r13,r14
  4690f6:	andn   r15d,esi,ebx
  4690fb:	shl    r15,0x4
  4690ff:	crc32  r11,QWORD PTR [rdx+0x20]
  469106:	prefetcht2 BYTE PTR [rdi+r15*1]
  46910b:	andn   r15d,esi,r11d
  469110:	shl    r15,0x4
  469114:	prefetcht2 BYTE PTR [rdi+r15*1]
  469119:	mov    r15,r14
  46911c:	crc32  r13,QWORD PTR [rdx+0x10]
  469123:	crc32  r15,QWORD PTR [rdx+0x30]
  46912a:	andn   r12d,esi,r13d
  46912f:	shl    r12,0x4
  469133:	prefetcht2 BYTE PTR [rdi+r12*1]
  469138:	andn   r12d,esi,r15d
  46913d:	shl    r12,0x4
  469141:	prefetcht2 BYTE PTR [rdi+r12*1]
  469146:	lea    r12,[r9+0x40]
  46914a:	vmovdqu64 zmm15,ZMMWORD PTR [rdx]
  469150:	cmp    QWORD PTR [rsp-0x18],r12
  469155:	jb     469660 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x840>
  46915b:	vmovdqu64 ZMMWORD PTR [rcx],zmm15
  469161:	mov    DWORD PTR [rcx+0x8],ebx
  469164:	mov    DWORD PTR [r8+r9*1+0x18],r13d
  469169:	mov    DWORD PTR [r8+r9*1+0x28],r11d
  46916e:	mov    DWORD PTR [r8+r9*1+0x38],r15d
  469173:	mov    r9,r12
  469176:	add    rdx,0x40
  46917a:	and    r9,r10
  46917d:	cmp    QWORD PTR [rsp-0x28],rdx
  469182:	je     469230 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x410>
  469188:	lea    r11,[r8+rax*1]
  46918c:	lea    rcx,[rax+0x180]
  469193:	and    rcx,r10
  469196:	mov    r13d,DWORD PTR [r11+0x8]
  46919a:	andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
  4691a1:	andn   r12d,esi,r13d
  4691a6:	mov    ecx,r12d
  4691a9:	shl    rcx,0x4
  4691ad:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+rcx*1]
  4691b4:	vpbroadcastq zmm9,QWORD PTR [r11]
  4691ba:	vpcmpequq k7{k2},zmm8,zmm9
  4691c1:	mov    ebx,r15d
  4691c4:	shl    rbx,0x4
  4691c8:	add    rax,0x10
  4691cc:	and    rax,r10
  4691cf:	prefetcht0 BYTE PTR [rdi+rbx*1]
  4691d3:	kortestb k7,k7
  4691d7:	jne    468f28 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
  4691dd:	vpcmpequq k1{k2},zmm8,zmm4
  4691e4:	kortestb k1,k1
  4691e8:	jne    4699c3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xba3>
  4691ee:	mov    r12,r14
  4691f1:	crc32  r12,r13
  4691f7:	vmovd  xmm10,r12d
  4691fc:	vpinsrd xmm11,xmm10,DWORD PTR [r11+0xc],0x1
  469203:	mov    r11,QWORD PTR [r11]
  469206:	lea    r15,[r8+r9*1]
  46920a:	add    r9,0x10
  46920e:	andn   ebx,esi,r12d
  469213:	shl    rbx,0x4
  469217:	and    r9,r10
  46921a:	prefetcht2 BYTE PTR [rdi+rbx*1]
  46921e:	mov    QWORD PTR [r15],r11
  469221:	vmovq  QWORD PTR [r15+0x8],xmm11
  469227:	jmp    469188 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x368>
  46922c:	nop    DWORD PTR [rax+0x0]
  469230:	mov    rcx,QWORD PTR [rsp-0x40]
  469235:	mov    r15,QWORD PTR [rsp-0x48]
  46923a:	mov    edi,DWORD PTR [rsp-0x2c]
  46923e:	vmovq  xmm14,r9
  469243:	vpinsrq xmm0,xmm14,rax,0x1
  469249:	mov    rsi,QWORD PTR [rsp-0x38]
  46924e:	vpsrlq xmm2,xmm0,0x4
  469253:	vpmovqd xmm3,xmm2
  469259:	sar    rsi,0x4
  46925d:	vmovq  QWORD PTR [rcx+0xb0],xmm3
  469265:	sub    rsi,rdi
  469268:	add    DWORD PTR [r15],esi
  46926b:	vpextrd eax,xmm3,0x1
  469271:	cmp    rdx,QWORD PTR [rsp-0x20]
  469276:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x730>
  46927c:	mov    rdi,QWORD PTR [rcx+0x88]
  469283:	mov    rbx,QWORD PTR [rcx+0x80]
  46928a:	mov    r8,QWORD PTR [rcx+0x60]
  46928e:	dec    rdi
  469291:	mov    QWORD PTR [rsp-0x18],rbx
  469296:	mov    QWORD PTR [rsp],r8
  46929a:	mov    QWORD PTR [rsp-0x28],rdi
  46929f:	mov    r10d,DWORD PTR [rcx+0x78]
  4692a3:	mov    r11,QWORD PTR [rip+0x2993e]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4692aa:	mov    r9,QWORD PTR [rcx+0xa0]
  4692b1:	movzx  r13d,BYTE PTR [rip+0x29847]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4692b9:	mov    r12,QWORD PTR [rip+0x29848]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4692c0:	mov    r14d,0x55
  4692c6:	vpxor  xmm7,xmm7,xmm7
  4692ca:	kmovb  k2,r14d
  4692cf:	nop
  4692d0:	lea    esi,[rax+0x18]
  4692d3:	and    esi,r10d
  4692d6:	shl    rsi,0x4
  4692da:	mov    r8d,ebx
  4692dd:	and    r8d,DWORD PTR [r9+rsi*1+0x8]
  4692e2:	mov    esi,eax
  4692e4:	shl    rsi,0x4
  4692e8:	add    rsi,r9
  4692eb:	mov    r14,r8
  4692ee:	mov    r8,QWORD PTR [rsi]
  4692f1:	shl    r14,0x4
  4692f5:	prefetcht0 BYTE PTR [r11+r14*1]
  4692fa:	cmp    r8,QWORD PTR [rcx+0x90]
  469301:	jne    4693c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5a0>
  469307:	test   r13b,r13b
  46930a:	je     46932a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
  46930c:	mov    r14d,DWORD PTR [r15]
  46930f:	mov    esi,DWORD PTR [rsi+0xc]
  469312:	mov    r8,r14
  469315:	shl    r14,0x4
  469319:	add    r14,QWORD PTR [r15+0x8]
  46931d:	inc    r8d
  469320:	mov    DWORD PTR [r14],esi
  469323:	mov    QWORD PTR [r14+0x8],r12
  469327:	mov    DWORD PTR [r15],r8d
  46932a:	inc    eax
  46932c:	and    eax,r10d
  46932f:	mov    DWORD PTR [rcx+0xb4],eax
  469335:	test   r12,r12
  469338:	jne    4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4b0>
  46933a:	cmp    QWORD PTR [rsp],0x4
  46933f:	je     4694b5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x695>
  469345:	nop    DWORD PTR [rax]
  469348:	cmp    QWORD PTR [rsp],0x8
  46934d:	je     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x710>
  469353:	vmovd  xmm15,DWORD PTR [rsp-0x10]
  469359:	mov    rdi,QWORD PTR [rdx]
  46935c:	mov    esi,DWORD PTR [rcx+0xb0]
  469362:	mov    r8,QWORD PTR [rsp-0x28]
  469367:	mov    rax,rsi
  46936a:	and    r8,QWORD PTR [rsp-0x10]
  46936f:	vpinsrd xmm9,xmm15,DWORD PTR [rdx+0xc],0x1
  469376:	and    r8,0xfffffffffffffffc
  46937a:	shl    rsi,0x4
  46937e:	inc    eax
  469380:	add    rsi,r9
  469383:	shl    r8,0x4
  469387:	and    eax,r10d
  46938a:	add    rdx,0x10
  46938e:	prefetcht2 BYTE PTR [r11+r8*1]
  469393:	mov    QWORD PTR [rsi],rdi
  469396:	vmovq  QWORD PTR [rsi+0x8],xmm9
  46939b:	mov    DWORD PTR [rcx+0xb0],eax
  4693a1:	cmp    rdx,QWORD PTR [rsp-0x20]
  4693a6:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x730>
  4693ac:	mov    eax,DWORD PTR [rcx+0xb4]
  4693b2:	jmp    4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4b0>
  4693b7:	nop    WORD PTR [rax+rax*1+0x0]
  4693c0:	mov    r14d,DWORD PTR [rsi+0x8]
  4693c4:	mov    edi,ebx
  4693c6:	and    edi,r14d
  4693c9:	shl    rdi,0x4
  4693cd:	add    rdi,r11
  4693d0:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  4693d6:	vpbroadcastq zmm6,r8
  4693dc:	vpcmpequq k0{k2},zmm5,zmm6
  4693e3:	kortestb k0,k0
  4693e7:	jne    469470 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x650>
  4693ed:	vpcmpequq k3{k2},zmm5,zmm7
  4693f4:	kortestb k3,k3
  4693f8:	jne    4694e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  4693fe:	cmp    QWORD PTR [rsp],0x4
  469403:	mov    edi,r14d
  469406:	je     4694f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d0>
  46940c:	cmp    QWORD PTR [rsp],0x8
  469411:	je     469510 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6f0>
  469417:	vmovd  xmm1,DWORD PTR [rsp-0x8]
  46941d:	mov    edi,DWORD PTR [rcx+0xb0]
  469423:	mov    r14,QWORD PTR [rsp-0x18]
  469428:	vpinsrd xmm4,xmm1,DWORD PTR [rsi+0xc],0x1
  46942f:	mov    rsi,rdi
  469432:	and    r14,QWORD PTR [rsp-0x8]
  469437:	shl    rdi,0x4
  46943b:	inc    esi
  46943d:	inc    eax
  46943f:	add    rdi,r9
  469442:	shl    r14,0x4
  469446:	and    esi,r10d
  469449:	and    eax,r10d
  46944c:	prefetcht2 BYTE PTR [r11+r14*1]
  469451:	mov    QWORD PTR [rdi],r8
  469454:	vmovq  QWORD PTR [rdi+0x8],xmm4
  469459:	mov    DWORD PTR [rcx+0xb0],esi
  46945f:	mov    DWORD PTR [rcx+0xb4],eax
  469465:	jmp    4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4b0>
  46946a:	nop    WORD PTR [rax+rax*1+0x0]
  469470:	mov    r8d,DWORD PTR [r15]
  469473:	mov    esi,DWORD PTR [rsi+0xc]
  469476:	mov    r14,r8
  469479:	shl    r8,0x4
  46947d:	add    r8,QWORD PTR [r15+0x8]
  469481:	mov    DWORD PTR [r8],esi
  469484:	kmovb  esi,k0
  469488:	tzcnt  esi,esi
  46948c:	inc    esi
  46948e:	movsxd rsi,esi
  469491:	mov    rdi,QWORD PTR [rdi+rsi*8]
  469495:	inc    eax
  469497:	inc    r14d
  46949a:	and    eax,r10d
  46949d:	cmp    QWORD PTR [rsp],0x4
  4694a2:	mov    QWORD PTR [r8+0x8],rdi
  4694a6:	mov    DWORD PTR [r15],r14d
  4694a9:	mov    DWORD PTR [rcx+0xb4],eax
  4694af:	jne    469348 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x528>
  4694b5:	mov    r14d,0xffffffff
  4694bb:	crc32  r14d,DWORD PTR [rdx]
  4694c1:	vmovd  xmm8,r14d
  4694c6:	mov    rdi,QWORD PTR [rdx]
  4694c9:	vmovdqa xmm15,xmm8
  4694ce:	vmovq  QWORD PTR [rsp-0x10],xmm8
  4694d4:	jmp    46935c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x53c>
  4694d9:	nop    DWORD PTR [rax+0x0]
  4694e0:	inc    eax
  4694e2:	and    eax,r10d
  4694e5:	mov    DWORD PTR [rcx+0xb4],eax
  4694eb:	jmp    46933a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x51a>
  4694f0:	mov    edi,0xffffffff
  4694f5:	crc32  edi,r14d
  4694fb:	vmovd  xmm12,edi
  4694ff:	vmovdqa xmm1,xmm12
  469503:	vmovq  QWORD PTR [rsp-0x8],xmm12
  469509:	jmp    46941d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5fd>
  46950e:	xchg   ax,ax
  469510:	mov    r14d,0xffffffff
  469516:	crc32  r14,rdi
  46951c:	mov    QWORD PTR [rsp-0x8],r14
  469521:	vmovd  xmm1,r14d
  469526:	jmp    46941d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5fd>
  46952b:	nop    DWORD PTR [rax+rax*1+0x0]
  469530:	mov    rdi,QWORD PTR [rdx]
  469533:	mov    eax,0xffffffff
  469538:	crc32  rax,rdi
  46953e:	mov    QWORD PTR [rsp-0x10],rax
  469543:	vmovd  xmm15,eax
  469547:	jmp    46935c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x53c>
  46954c:	nop    DWORD PTR [rax+0x0]
  469550:	vzeroupper 
  469553:	lea    rsp,[rbp-0x28]
  469557:	pop    rbx
  469558:	pop    r12
  46955a:	pop    r13
  46955c:	pop    r14
  46955e:	pop    r15
  469560:	pop    rbp
  469561:	ret    
  469562:	nop    WORD PTR [rax+rax*1+0x0]
  469568:	vpcmpequq k1{k2},zmm0,zmm4
  46956f:	kortestb k1,k1
  469573:	jne    4696c8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8a8>
  469579:	mov    r15,r14
  46957c:	crc32  r15,r12
  469582:	vmovd  xmm3,r15d
  469587:	vpinsrd xmm5,xmm3,DWORD PTR [rbx+0xc],0x1
  46958e:	mov    rbx,QWORD PTR [rbx]
  469591:	add    r9,0x10
  469595:	andn   r12d,esi,r15d
  46959a:	shl    r12,0x4
  46959e:	and    r9,r10
  4695a1:	prefetcht2 BYTE PTR [rdi+r12*1]
  4695a6:	mov    QWORD PTR [rcx],rbx
  4695a9:	vmovq  QWORD PTR [rcx+0x8],xmm5
  4695ae:	jmp    46904b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x22b>
  4695b3:	nop    DWORD PTR [rax+rax*1+0x0]
  4695b8:	vpcmpequq k1{k2},zmm8,zmm4
  4695bf:	kortestb k1,k1
  4695c3:	jne    4699d9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbb9>
  4695c9:	mov    rcx,r14
  4695cc:	crc32  rcx,r12
  4695d2:	vmovd  xmm10,ecx
  4695d6:	vpinsrd xmm11,xmm10,DWORD PTR [rbx+0xc],0x1
  4695dd:	mov    rbx,QWORD PTR [rbx]
  4695e0:	lea    r13,[r8+r9*1]
  4695e4:	add    r9,0x10
  4695e8:	andn   r12d,esi,ecx
  4695ed:	shl    r12,0x4
  4695f1:	and    r9,r10
  4695f4:	prefetcht2 BYTE PTR [rdi+r12*1]
  4695f9:	mov    QWORD PTR [r13+0x0],rbx
  4695fd:	vmovq  QWORD PTR [r13+0x8],xmm11
  469603:	jmp    468fce <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1ae>
  469608:	nop    DWORD PTR [rax+rax*1+0x0]
  469610:	vpcmpequq k1{k2},zmm0,zmm4
  469617:	kortestb k1,k1
  46961b:	jne    4699ba <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb9a>
  469621:	mov    r13,r14
  469624:	crc32  r13,r12
  46962a:	vmovd  xmm3,r13d
  46962f:	vpinsrd xmm5,xmm3,DWORD PTR [rbx+0xc],0x1
  469636:	mov    rbx,QWORD PTR [rbx]
  469639:	lea    r15,[r8+r9*1]
  46963d:	add    r9,0x10
  469641:	andn   r12d,esi,r13d
  469646:	shl    r12,0x4
  46964a:	and    r9,r10
  46964d:	prefetcht2 BYTE PTR [rdi+r12*1]
  469652:	mov    QWORD PTR [r15],rbx
  469655:	vmovq  QWORD PTR [r15+0x8],xmm5
  46965b:	jmp    468f52 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x132>
  469660:	vmovd  xmm10,ebx
  469664:	vpinsrd xmm11,xmm10,r13d,0x1
  46966a:	mov    r13,QWORD PTR [rsp-0x18]
  46966f:	vmovd  xmm8,r11d
  469674:	mov    r11,r13
  469677:	vpinsrd xmm9,xmm8,r15d,0x1
  46967d:	sub    r11,r9
  469680:	mov    ebx,0x4444
  469685:	vpunpcklqdq xmm13,xmm11,xmm9
  46968a:	shr    r11,0x2
  46968e:	mov    r15d,0x1
  469694:	kmovw  k7,ebx
  469698:	shlx   r11d,r15d,r11d
  46969d:	vpexpandd zmm15{k7},zmm13
  4696a3:	lea    ebx,[r11-0x1]
  4696a7:	sub    r9,r13
  4696aa:	neg    r11d
  4696ad:	kmovw  k1,ebx
  4696b1:	vmovdqu32 ZMMWORD PTR [rcx]{k1},zmm15
  4696b7:	kmovw  k7,r11d
  4696bc:	vmovdqu32 ZMMWORD PTR [r8+r9*1]{k7},zmm15
  4696c3:	jmp    469173 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x353>
  4696c8:	inc    DWORD PTR [rsp-0x2c]
  4696cc:	nop    DWORD PTR [rax+0x0]
  4696d0:	mov    rbx,QWORD PTR [rsp]
  4696d4:	mov    r13d,0x55
  4696da:	pdep   r15d,r11d,r13d
  4696df:	popcnt r11d,r11d
  4696e4:	lea    r12d,[r15+r15*2]
  4696e8:	shl    r11,0x4
  4696ec:	kmovb  k1,r12d
  4696f1:	vpcompressq ZMMWORD PTR [rbx]{k1},zmm12
  4696f7:	add    rbx,r11
  4696fa:	mov    QWORD PTR [rsp],rbx
  4696fe:	jmp    4690e7 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2c7>
  469703:	cmp    rdx,QWORD PTR [rsp-0x20]
  469708:	je     469553 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x733>
  46970e:	mov    r12,QWORD PTR [rcx+0x88]
  469715:	movzx  r13d,BYTE PTR [rip+0x293e3]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  46971d:	mov    r9,QWORD PTR [rip+0x293e4]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469724:	mov    r10,QWORD PTR [rcx+0x60]
  469728:	mov    ebx,0x55
  46972d:	dec    r12
  469730:	kmovb  k2,r13d
  469735:	mov    QWORD PTR [rsp],r10
  469739:	mov    QWORD PTR [rsp-0x8],r12
  46973e:	mov    r14,QWORD PTR [rip+0x294a3]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469745:	mov    r11,QWORD PTR [rcx+0xa0]
  46974c:	mov    esi,edi
  46974e:	vpxor  xmm2,xmm2,xmm2
  469752:	mov    r13,r9
  469755:	kmovb  k1,ebx
  469759:	jmp    4697c1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a1>
  46975b:	cmp    QWORD PTR [rsp],0x8
  469760:	je     469968 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb48>
  469766:	vmovd  xmm5,DWORD PTR [rsp-0x18]
  46976c:	mov    r12,QWORD PTR [rsp-0x8]
  469771:	mov    esi,edi
  469773:	and    r12,QWORD PTR [rsp-0x18]
  469778:	vpinsrd xmm7,xmm5,DWORD PTR [rdx+0xc],0x1
  46977f:	mov    r10,QWORD PTR [rdx]
  469782:	and    r12,0xfffffffffffffffc
  469786:	shl    rsi,0x4
  46978a:	add    rsi,r11
  46978d:	shl    r12,0x4
  469791:	prefetcht2 BYTE PTR [r14+r12*1]
  469796:	mov    QWORD PTR [rsi],r10
  469799:	vmovq  QWORD PTR [rsi+0x8],xmm7
  46979e:	lea    esi,[rdi+0x1]
  4697a1:	and    esi,r8d
  4697a4:	add    rdx,0x10
  4697a8:	mov    DWORD PTR [rcx+0xb0],esi
  4697ae:	cmp    QWORD PTR [rsp-0x20],rdx
  4697b3:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x730>
  4697b9:	mov    eax,DWORD PTR [rcx+0xb4]
  4697bf:	mov    edi,esi
  4697c1:	sub    esi,eax
  4697c3:	and    esi,r8d
  4697c6:	cmp    r8d,esi
  4697c9:	jbe    4697ec <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9cc>
  4697cb:	cmp    QWORD PTR [rsp],0x4
  4697d0:	jne    46975b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x93b>
  4697d2:	mov    ebx,0xffffffff
  4697d7:	crc32  ebx,DWORD PTR [rdx]
  4697dc:	vmovd  xmm6,ebx
  4697e0:	vmovdqa xmm5,xmm6
  4697e4:	vmovq  QWORD PTR [rsp-0x18],xmm6
  4697ea:	jmp    46976c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x94c>
  4697ec:	mov    rbx,QWORD PTR [rcx+0x80]
  4697f3:	mov    QWORD PTR [rsp-0x10],rbx
  4697f8:	nop    DWORD PTR [rax+rax*1+0x0]
  469800:	lea    esi,[rax+0x18]
  469803:	and    esi,r8d
  469806:	shl    rsi,0x4
  46980a:	mov    r9d,ebx
  46980d:	and    r9d,DWORD PTR [r11+rsi*1+0x8]
  469812:	mov    esi,eax
  469814:	mov    r10,r9
  469817:	shl    rsi,0x4
  46981b:	shl    r10,0x4
  46981f:	add    rsi,r11
  469822:	prefetcht0 BYTE PTR [r14+r10*1]
  469827:	mov    r10,QWORD PTR [rsi]
  46982a:	cmp    r10,QWORD PTR [rcx+0x90]
  469831:	jne    469870 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa50>
  469833:	kortestb k2,k2
  469837:	je     46985a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa3a>
  469839:	mov    r12d,DWORD PTR [r15]
  46983c:	mov    esi,DWORD PTR [rsi+0xc]
  46983f:	mov    r10,r12
  469842:	shl    r12,0x4
  469846:	add    r12,QWORD PTR [r15+0x8]
  46984a:	lea    r9d,[r10+0x1]
  46984e:	mov    DWORD PTR [r12],esi
  469852:	mov    QWORD PTR [r12+0x8],r13
  469857:	mov    DWORD PTR [r15],r9d
  46985a:	inc    eax
  46985c:	and    eax,r8d
  46985f:	mov    DWORD PTR [rcx+0xb4],eax
  469865:	test   r13,r13
  469868:	jne    469800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9e0>
  46986a:	jmp    4697cb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9ab>
  46986f:	nop
  469870:	mov    r12d,DWORD PTR [rsi+0x8]
  469874:	mov    r9d,ebx
  469877:	and    r9d,r12d
  46987a:	shl    r9,0x4
  46987e:	add    r9,r14
  469881:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  469887:	vpbroadcastq zmm1,r10
  46988d:	vpcmpequq k0{k1},zmm0,zmm1
  469894:	kortestb k0,k0
  469898:	jne    469914 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaf4>
  46989a:	vpcmpequq k3{k1},zmm0,zmm2
  4698a1:	kortestb k3,k3
  4698a5:	jne    469958 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb38>
  4698ab:	cmp    QWORD PTR [rsp],0x4
  4698b0:	mov    r9d,r12d
  4698b3:	je     469981 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb61>
  4698b9:	cmp    QWORD PTR [rsp],0x8
  4698be:	je     4699a1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb81>
  4698c4:	mov    r9d,DWORD PTR [rsp-0x28]
  4698c9:	mov    r12,QWORD PTR [rsp-0x10]
  4698ce:	vmovd  xmm4,r9d
  4698d3:	vpinsrd xmm3,xmm4,DWORD PTR [rsi+0xc],0x1
  4698da:	mov    esi,edi
  4698dc:	and    r12,QWORD PTR [rsp-0x28]
  4698e1:	shl    rsi,0x4
  4698e5:	inc    edi
  4698e7:	inc    eax
  4698e9:	add    rsi,r11
  4698ec:	shl    r12,0x4
  4698f0:	and    edi,r8d
  4698f3:	and    eax,r8d
  4698f6:	prefetcht2 BYTE PTR [r14+r12*1]
  4698fb:	mov    QWORD PTR [rsi],r10
  4698fe:	vmovq  QWORD PTR [rsi+0x8],xmm3
  469903:	mov    DWORD PTR [rcx+0xb0],edi
  469909:	mov    DWORD PTR [rcx+0xb4],eax
  46990f:	jmp    469800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9e0>
  469914:	mov    r10d,DWORD PTR [r15]
  469917:	mov    r12d,DWORD PTR [rsi+0xc]
  46991b:	mov    rbx,r10
  46991e:	shl    r10,0x4
  469922:	add    r10,QWORD PTR [r15+0x8]
  469926:	mov    DWORD PTR [r10],r12d
  469929:	xor    r12d,r12d
  46992c:	kmovb  esi,k0
  469930:	tzcnt  r12d,esi
  469935:	inc    r12d
  469938:	movsxd rsi,r12d
  46993b:	mov    r9,QWORD PTR [r9+rsi*8]
  46993f:	inc    eax
  469941:	inc    ebx
  469943:	and    eax,r8d
  469946:	mov    QWORD PTR [r10+0x8],r9
  46994a:	mov    DWORD PTR [r15],ebx
  46994d:	mov    DWORD PTR [rcx+0xb4],eax
  469953:	jmp    4697cb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9ab>
  469958:	inc    eax
  46995a:	and    eax,r8d
  46995d:	mov    DWORD PTR [rcx+0xb4],eax
  469963:	jmp    4697cb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9ab>
  469968:	mov    eax,0xffffffff
  46996d:	crc32  rax,QWORD PTR [rdx]
  469973:	mov    QWORD PTR [rsp-0x18],rax
  469978:	vmovd  xmm5,eax
  46997c:	jmp    46976c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x94c>
  469981:	mov    r9d,0xffffffff
  469987:	crc32  r9d,r12d
  46998d:	mov    r12d,r9d
  469990:	mov    QWORD PTR [rsp-0x28],r12
  469995:	jmp    4698c9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaa9>
  46999a:	xor    edi,edi
  46999c:	jmp    46923e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x41e>
  4699a1:	mov    r12d,0xffffffff
  4699a7:	crc32  r12,r9
  4699ad:	mov    QWORD PTR [rsp-0x28],r12
  4699b2:	mov    r9d,r12d
  4699b5:	jmp    4698c9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaa9>
  4699ba:	inc    DWORD PTR [rsp-0x2c]
  4699be:	jmp    468fce <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1ae>
  4699c3:	inc    DWORD PTR [rsp-0x2c]
  4699c7:	vpxor  xmm15,xmm15,xmm15
  4699cc:	xor    r11d,r11d
  4699cf:	vpxor  xmm12,xmm12,xmm12
  4699d4:	jmp    468f52 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x132>
  4699d9:	inc    DWORD PTR [rsp-0x2c]
  4699dd:	jmp    46904b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x22b>
