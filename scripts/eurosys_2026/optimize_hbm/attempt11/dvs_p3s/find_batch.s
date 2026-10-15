0000000000468ed0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468ed0:	lea    r10,[rsp+0x8]
  468ed5:	and    rsp,0xffffffffffffffc0
  468ed9:	push   QWORD PTR [r10-0x8]
  468edd:	mov    r11,rdx
  468ee0:	push   rbp
  468ee1:	mov    rbp,rsp
  468ee4:	push   r15
  468ee6:	push   r14
  468ee8:	push   r13
  468eea:	push   r12
  468eec:	mov    r12,rdi
  468eef:	push   r10
  468ef1:	push   rbx
  468ef2:	add    rsp,0xffffffffffffff80
  468ef6:	mov    rcx,QWORD PTR [rsi+0x8]
  468efa:	mov    edi,DWORD PTR [rdi+0xb0]
  468f00:	mov    eax,DWORD PTR [r12+0xb4]
  468f08:	mov    r13,QWORD PTR [rsi]
  468f0b:	mov    r8d,DWORD PTR [r12+0x6c]
  468f10:	mov    esi,DWORD PTR [r12+0x78]
  468f15:	mov    r9,rcx
  468f18:	mov    edx,edi
  468f1a:	shl    r9,0x4
  468f1e:	sub    edx,eax
  468f20:	lea    rbx,[r13+r9*1+0x0]
  468f25:	and    edx,esi
  468f27:	lea    r14d,[r8-0x1]
  468f2b:	mov    QWORD PTR [rbp-0x58],rbx
  468f2f:	cmp    edx,r14d
  468f32:	jb     46973a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x86a>
  468f38:	and    rcx,0xfffffffffffffffc
  468f3c:	shl    rcx,0x4
  468f40:	mov    r14d,DWORD PTR [r12+0x80]
  468f48:	shl    r8,0x4
  468f4c:	mov    ebx,eax
  468f4e:	lea    r10,[r13+rcx*1+0x0]
  468f53:	mov    QWORD PTR [rbp-0x68],rcx
  468f57:	mov    edx,edi
  468f59:	mov    ecx,0x55
  468f5e:	mov    QWORD PTR [rbp-0x50],r8
  468f62:	lea    rsi,[r8-0x1]
  468f66:	mov    QWORD PTR [rbp-0x38],r10
  468f6a:	mov    DWORD PTR [rbp-0x60],0x0
  468f71:	mov    r15,QWORD PTR [r12+0xa0]
  468f79:	mov    r9,QWORD PTR [r11+0x8]
  468f7d:	mov    rax,QWORD PTR [rip+0x29c64]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468f84:	shl    rbx,0x4
  468f88:	shl    rdx,0x4
  468f8c:	not    r14d
  468f8f:	vpxor  xmm8,xmm8,xmm8
  468f94:	xor    r8d,r8d
  468f97:	kmovb  k2,ecx
  468f9b:	cmp    r13,r10
  468f9e:	je     4692dc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x40c>
  468fa4:	mov    QWORD PTR [rbp-0x70],r12
  468fa8:	mov    QWORD PTR [rbp-0x78],r11
  468fac:	mov    r12,r9
  468faf:	jmp    469230 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x360>
  468fb4:	nop    DWORD PTR [rax+0x0]
  468fb8:	vmovd  xmm14,DWORD PTR [r9+0xc]
  468fbe:	kshiftlb k6,k4,0x1
  468fc4:	vpcompressq zmm13{k6}{z},zmm9
  468fca:	vpunpcklqdq xmm15,xmm14,xmm13
  468fcf:	mov    r8d,0xf
  468fd5:	kmovw  k7,r8d
  468fda:	vshufi32x4 zmm0{k7}{z},zmm15,zmm15,0x0
  468fe1:	vmovdqa64 zmm13,zmm0
  468fe7:	mov    ecx,0x1
  468fec:	lea    r11,[r15+rbx*1]
  468ff0:	lea    r9,[rbx+0x180]
  468ff7:	and    r9,rsi
  468ffa:	mov    r8d,DWORD PTR [r11+0x8]
  468ffe:	andn   edi,r14d,DWORD PTR [r15+r9*1+0x8]
  469005:	shl    rdi,0x4
  469009:	andn   r9d,r14d,r8d
  46900e:	shl    r9,0x4
  469012:	vmovdqa64 zmm7,ZMMWORD PTR [rax+r9*1]
  469019:	vpbroadcastq zmm2,QWORD PTR [r11]
  46901f:	vpcmpequq k1{k2},zmm7,zmm2
  469026:	add    rbx,0x10
  46902a:	and    rbx,rsi
  46902d:	prefetcht0 BYTE PTR [rax+rdi*1]
  469031:	kortestb k1,k1
  469035:	je     4696c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7f0>
  46903b:	vmovd  xmm1,DWORD PTR [r11+0xc]
  469041:	kshiftlb k3,k1,0x1
  469047:	vpcompressq zmm5{k3}{z},zmm7
  46904d:	vpunpcklqdq xmm6,xmm1,xmm5
  469051:	mov    r11d,0xf0
  469057:	kmovw  k4,r11d
  46905c:	vshufi32x4 zmm0{k4},zmm6,zmm6,0x0
  469063:	vmovdqa64 zmm13,zmm0
  469069:	or     ecx,0x2
  46906c:	lea    r10,[r15+rbx*1]
  469070:	lea    r8,[rbx+0x180]
  469077:	and    r8,rsi
  46907a:	mov    r11d,DWORD PTR [r10+0x8]
  46907e:	andn   edi,r14d,DWORD PTR [r15+r8*1+0x8]
  469085:	shl    rdi,0x4
  469089:	andn   r8d,r14d,r11d
  46908e:	shl    r8,0x4
  469092:	vmovdqa64 zmm9,ZMMWORD PTR [rax+r8*1]
  469099:	vpbroadcastq zmm10,QWORD PTR [r10]
  46909f:	vpcmpequq k5{k2},zmm9,zmm10
  4690a6:	add    rbx,0x10
  4690aa:	and    rbx,rsi
  4690ad:	prefetcht0 BYTE PTR [rax+rdi*1]
  4690b1:	kortestb k5,k5
  4690b5:	je     469670 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7a0>
  4690bb:	vmovd  xmm14,DWORD PTR [r10+0xc]
  4690c1:	kshiftlb k7,k5,0x1
  4690c7:	vpcompressq zmm13{k7}{z},zmm9
  4690cd:	vpunpcklqdq xmm15,xmm14,xmm13
  4690d2:	mov    r10d,0xf00
  4690d8:	kmovw  k1,r10d
  4690dd:	vshufi32x4 zmm0{k1},zmm15,zmm15,0x0
  4690e4:	vmovdqa64 zmm13,zmm0
  4690ea:	or     ecx,0x4
  4690ed:	lea    r10,[r15+rbx*1]
  4690f1:	lea    r11,[rbx+0x180]
  4690f8:	and    r11,rsi
  4690fb:	andn   edi,r14d,DWORD PTR [r15+r11*1+0x8]
  469102:	shl    rdi,0x4
  469106:	mov    r11d,DWORD PTR [r10+0x8]
  46910a:	andn   r9d,r14d,r11d
  46910f:	shl    r9,0x4
  469113:	vmovdqa64 zmm7,ZMMWORD PTR [rax+r9*1]
  46911a:	vpbroadcastq zmm2,QWORD PTR [r10]
  469120:	vpcmpequq k0{k2},zmm7,zmm2
  469127:	add    rbx,0x10
  46912b:	and    rbx,rsi
  46912e:	prefetcht0 BYTE PTR [rax+rdi*1]
  469132:	kortestb k0,k0
  469136:	je     469620 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x750>
  46913c:	vmovd  xmm1,DWORD PTR [r10+0xc]
  469142:	kshiftlb k4,k0,0x1
  469148:	vpcompressq zmm5{k4}{z},zmm7
  46914e:	vpunpcklqdq xmm6,xmm1,xmm5
  469152:	mov    r10d,0xfffff000
  469158:	kmovw  k5,r10d
  46915d:	or     ecx,0x8
  469160:	vshufi32x4 zmm0{k5},zmm6,zmm6,0x0
  469167:	vmovdqa64 zmm13,zmm0
  46916d:	cmp    ecx,0xf
  469170:	jne    469710 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x840>
  469176:	vmovdqu64 ZMMWORD PTR [r12],zmm0
  46917d:	add    r12,0x40
  469181:	mov    ecx,0xffffffff
  469186:	mov    r8d,0xffffffff
  46918c:	crc32  rcx,QWORD PTR [r13+0x20]
  469193:	andn   edi,r14d,ecx
  469198:	shl    rdi,0x4
  46919c:	prefetcht2 BYTE PTR [rax+rdi*1]
  4691a0:	mov    edi,0xffffffff
  4691a5:	crc32  r8,QWORD PTR [r13+0x0]
  4691ac:	mov    r9d,0xffffffff
  4691b2:	andn   r10d,r14d,r8d
  4691b7:	shl    r10,0x4
  4691bb:	crc32  rdi,QWORD PTR [r13+0x30]
  4691c2:	prefetcht2 BYTE PTR [rax+r10*1]
  4691c7:	andn   r10d,r14d,edi
  4691cc:	shl    r10,0x4
  4691d0:	prefetcht2 BYTE PTR [rax+r10*1]
  4691d5:	lea    r10,[rdx+0x40]
  4691d9:	crc32  r9,QWORD PTR [r13+0x10]
  4691e0:	andn   r11d,r14d,r9d
  4691e5:	shl    r11,0x4
  4691e9:	prefetcht2 BYTE PTR [rax+r11*1]
  4691ee:	cmp    QWORD PTR [rbp-0x50],r10
  4691f2:	jb     40e2e2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0.cold>
  4691f8:	vmovdqu64 zmm0,ZMMWORD PTR [r13+0x0]
  4691ff:	lea    r11,[r15+rdx*1]
  469203:	vmovdqu64 ZMMWORD PTR [r11],zmm0
  469209:	add    r13,0x40
  46920d:	mov    DWORD PTR [r11+0x8],r8d
  469211:	mov    DWORD PTR [r15+rdx*1+0x18],r9d
  469216:	mov    DWORD PTR [r15+rdx*1+0x28],ecx
  46921b:	mov    DWORD PTR [r15+rdx*1+0x38],edi
  469220:	mov    rdx,r10
  469223:	and    rdx,rsi
  469226:	cmp    QWORD PTR [rbp-0x38],r13
  46922a:	je     4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x400>
  469230:	lea    r9,[r15+rbx*1]
  469234:	mov    edi,DWORD PTR [r9+0x8]
  469238:	andn   r10d,r14d,edi
  46923d:	shl    r10,0x4
  469241:	vmovdqa64 zmm9,ZMMWORD PTR [rax+r10*1]
  469248:	vpbroadcastq zmm10,QWORD PTR [r9]
  46924e:	vpcmpequq k4{k2},zmm9,zmm10
  469255:	lea    r11,[rbx+0x180]
  46925c:	add    rbx,0x10
  469260:	and    r11,rsi
  469263:	and    rbx,rsi
  469266:	andn   ecx,r14d,DWORD PTR [r15+r11*1+0x8]
  46926d:	shl    rcx,0x4
  469271:	kortestb k4,k4
  469275:	prefetcht0 BYTE PTR [rax+rcx*1]
  469279:	jne    468fb8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xe8>
  46927f:	vpcmpequq k5{k2},zmm9,zmm8
  469286:	kortestb k5,k5
  46928a:	jne    4699d5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb05>
  469290:	vmovdqu xmm11,XMMWORD PTR [r9]
  469295:	mov    r11d,0xffffffff
  46929b:	crc32  r11,rdi
  4692a1:	vpinsrd xmm12,xmm11,r11d,0x2
  4692a7:	andn   ecx,r14d,r11d
  4692ac:	shl    rcx,0x4
  4692b0:	prefetcht2 BYTE PTR [rax+rcx*1]
  4692b4:	vmovdqu XMMWORD PTR [r15+rdx*1],xmm12
  4692ba:	add    rdx,0x10
  4692be:	and    rdx,rsi
  4692c1:	jmp    469230 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x360>
  4692c6:	cs nop WORD PTR [rax+rax*1+0x0]
  4692d0:	mov    r12,QWORD PTR [rbp-0x70]
  4692d4:	mov    r11,QWORD PTR [rbp-0x78]
  4692d8:	mov    r8d,DWORD PTR [rbp-0x60]
  4692dc:	vmovq  xmm8,rdx
  4692e1:	mov    rsi,QWORD PTR [rbp-0x68]
  4692e5:	vpinsrq xmm9,xmm8,rbx,0x1
  4692eb:	vpsrlq xmm10,xmm9,0x4
  4692f1:	vpmovqd xmm11,xmm10
  4692f7:	sar    rsi,0x4
  4692fb:	vmovq  QWORD PTR [r12+0xb0],xmm11
  469305:	sub    rsi,r8
  469308:	add    DWORD PTR [r11],esi
  46930b:	vpextrd eax,xmm11,0x1
  469311:	cmp    r13,QWORD PTR [rbp-0x58]
  469315:	je     469608 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
  46931b:	mov    rcx,QWORD PTR [r12+0x88]
  469323:	mov    r10,QWORD PTR [r12+0x80]
  46932b:	mov    rdx,QWORD PTR [r12+0x60]
  469330:	dec    rcx
  469333:	mov    QWORD PTR [rbp-0x50],r10
  469337:	mov    QWORD PTR [rbp-0x38],rdx
  46933b:	mov    QWORD PTR [rbp-0x60],rcx
  46933f:	mov    r8d,DWORD PTR [r12+0x78]
  469344:	mov    r9,QWORD PTR [rip+0x2989d]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46934b:	mov    rdi,QWORD PTR [r12+0xa0]
  469353:	movzx  ebx,BYTE PTR [rip+0x297a6]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  46935a:	mov    r15,QWORD PTR [rip+0x297a7]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469361:	mov    r14d,0x55
  469367:	vpxor  xmm12,xmm12,xmm12
  46936c:	kmovb  k2,r14d
  469371:	nop    DWORD PTR [rax+0x0]
  469378:	lea    edx,[rax+0x18]
  46937b:	and    edx,r8d
  46937e:	shl    rdx,0x4
  469382:	mov    esi,r10d
  469385:	and    esi,DWORD PTR [rdi+rdx*1+0x8]
  469389:	mov    edx,eax
  46938b:	shl    rdx,0x4
  46938f:	shl    rsi,0x4
  469393:	add    rdx,rdi
  469396:	prefetcht0 BYTE PTR [r9+rsi*1]
  46939b:	mov    rsi,QWORD PTR [rdx]
  46939e:	cmp    rsi,QWORD PTR [r12+0x90]
  4693a6:	jne    469468 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x598>
  4693ac:	test   bl,bl
  4693ae:	je     4693cd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fd>
  4693b0:	mov    r14d,DWORD PTR [r11]
  4693b3:	mov    edx,DWORD PTR [rdx+0xc]
  4693b6:	mov    rsi,r14
  4693b9:	shl    r14,0x4
  4693bd:	add    r14,QWORD PTR [r11+0x8]
  4693c1:	inc    esi
  4693c3:	mov    DWORD PTR [r14],edx
  4693c6:	mov    QWORD PTR [r14+0x8],r15
  4693ca:	mov    DWORD PTR [r11],esi
  4693cd:	inc    eax
  4693cf:	and    eax,r8d
  4693d2:	mov    DWORD PTR [r12+0xb4],eax
  4693da:	test   r15,r15
  4693dd:	jne    469378 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a8>
  4693df:	cmp    QWORD PTR [rbp-0x38],0x4
  4693e4:	je     469566 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x696>
  4693ea:	nop    WORD PTR [rax+rax*1+0x0]
  4693f0:	cmp    QWORD PTR [rbp-0x38],0x8
  4693f5:	je     4695e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x718>
  4693fb:	vmovd  xmm4,DWORD PTR [rbp-0x48]
  469400:	mov    rcx,QWORD PTR [r13+0x0]
  469404:	mov    edx,DWORD PTR [r12+0xb0]
  46940c:	mov    rsi,QWORD PTR [rbp-0x60]
  469410:	mov    rax,rdx
  469413:	and    rsi,QWORD PTR [rbp-0x48]
  469417:	vpinsrd xmm1,xmm4,DWORD PTR [r13+0xc],0x1
  46941e:	and    rsi,0xfffffffffffffffc
  469422:	shl    rdx,0x4
  469426:	inc    eax
  469428:	add    rdx,rdi
  46942b:	shl    rsi,0x4
  46942f:	and    eax,r8d
  469432:	add    r13,0x10
  469436:	prefetcht2 BYTE PTR [r9+rsi*1]
  46943b:	mov    QWORD PTR [rdx],rcx
  46943e:	vmovq  QWORD PTR [rdx+0x8],xmm1
  469443:	mov    DWORD PTR [r12+0xb0],eax
  46944b:	cmp    r13,QWORD PTR [rbp-0x58]
  46944f:	je     469608 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
  469455:	mov    eax,DWORD PTR [r12+0xb4]
  46945d:	jmp    469378 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a8>
  469462:	nop    WORD PTR [rax+rax*1+0x0]
  469468:	mov    r14d,DWORD PTR [rdx+0x8]
  46946c:	mov    ecx,r10d
  46946f:	and    ecx,r14d
  469472:	shl    rcx,0x4
  469476:	add    rcx,r9
  469479:	vmovdqa64 zmm14,ZMMWORD PTR [rcx]
  46947f:	vpbroadcastq zmm15,rsi
  469485:	vpcmpequq k7{k2},zmm14,zmm15
  46948c:	kortestb k7,k7
  469490:	jne    469520 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x650>
  469496:	vpcmpequq k1{k2},zmm14,zmm12
  46949d:	kortestb k1,k1
  4694a1:	jne    469590 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  4694a7:	cmp    QWORD PTR [rbp-0x38],0x4
  4694ac:	mov    ecx,r14d
  4694af:	je     4695a8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d8>
  4694b5:	cmp    QWORD PTR [rbp-0x38],0x8
  4694ba:	je     4695c8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6f8>
  4694c0:	vmovd  xmm7,DWORD PTR [rbp-0x40]
  4694c5:	mov    ecx,DWORD PTR [r12+0xb0]
  4694cd:	mov    r14,QWORD PTR [rbp-0x50]
  4694d1:	vpinsrd xmm3,xmm7,DWORD PTR [rdx+0xc],0x1
  4694d8:	mov    rdx,rcx
  4694db:	and    r14,QWORD PTR [rbp-0x40]
  4694df:	shl    rcx,0x4
  4694e3:	inc    edx
  4694e5:	inc    eax
  4694e7:	add    rcx,rdi
  4694ea:	shl    r14,0x4
  4694ee:	and    edx,r8d
  4694f1:	and    eax,r8d
  4694f4:	prefetcht2 BYTE PTR [r9+r14*1]
  4694f9:	mov    QWORD PTR [rcx],rsi
  4694fc:	vmovq  QWORD PTR [rcx+0x8],xmm3
  469501:	mov    DWORD PTR [r12+0xb0],edx
  469509:	mov    DWORD PTR [r12+0xb4],eax
  469511:	jmp    469378 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a8>
  469516:	cs nop WORD PTR [rax+rax*1+0x0]
  469520:	mov    esi,DWORD PTR [r11]
  469523:	mov    edx,DWORD PTR [rdx+0xc]
  469526:	mov    r14,rsi
  469529:	shl    rsi,0x4
  46952d:	add    rsi,QWORD PTR [r11+0x8]
  469531:	mov    DWORD PTR [rsi],edx
  469533:	kmovb  edx,k7
  469537:	tzcnt  edx,edx
  46953b:	inc    edx
  46953d:	movsxd rdx,edx
  469540:	mov    rcx,QWORD PTR [rcx+rdx*8]
  469544:	inc    eax
  469546:	inc    r14d
  469549:	and    eax,r8d
  46954c:	cmp    QWORD PTR [rbp-0x38],0x4
  469551:	mov    QWORD PTR [rsi+0x8],rcx
  469555:	mov    DWORD PTR [r11],r14d
  469558:	mov    DWORD PTR [r12+0xb4],eax
  469560:	jne    4693f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x520>
  469566:	mov    r14d,0xffffffff
  46956c:	crc32  r14d,DWORD PTR [r13+0x0]
  469573:	vmovd  xmm5,r14d
  469578:	mov    rcx,QWORD PTR [r13+0x0]
  46957c:	vmovdqa xmm4,xmm5
  469580:	vmovq  QWORD PTR [rbp-0x48],xmm5
  469585:	jmp    469404 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x534>
  46958a:	nop    WORD PTR [rax+rax*1+0x0]
  469590:	inc    eax
  469592:	and    eax,r8d
  469595:	mov    DWORD PTR [r12+0xb4],eax
  46959d:	jmp    4693df <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50f>
  4695a2:	nop    WORD PTR [rax+rax*1+0x0]
  4695a8:	mov    ecx,0xffffffff
  4695ad:	crc32  ecx,r14d
  4695b3:	vmovd  xmm2,ecx
  4695b7:	vmovdqa xmm7,xmm2
  4695bb:	vmovq  QWORD PTR [rbp-0x40],xmm2
  4695c0:	jmp    4694c5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5f5>
  4695c5:	nop    DWORD PTR [rax]
  4695c8:	mov    r14d,0xffffffff
  4695ce:	crc32  r14,rcx
  4695d4:	mov    QWORD PTR [rbp-0x40],r14
  4695d8:	vmovd  xmm7,r14d
  4695dd:	jmp    4694c5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5f5>
  4695e2:	nop    WORD PTR [rax+rax*1+0x0]
  4695e8:	mov    rcx,QWORD PTR [r13+0x0]
  4695ec:	mov    eax,0xffffffff
  4695f1:	crc32  rax,rcx
  4695f7:	mov    QWORD PTR [rbp-0x48],rax
  4695fb:	vmovd  xmm4,eax
  4695ff:	jmp    469404 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x534>
  469604:	nop    DWORD PTR [rax+0x0]
  469608:	vzeroupper 
  46960b:	lea    rsp,[rbp-0x30]
  46960f:	pop    rbx
  469610:	pop    r11
  469612:	pop    r12
  469614:	pop    r13
  469616:	pop    r14
  469618:	pop    r15
  46961a:	pop    rbp
  46961b:	lea    rsp,[r11-0x8]
  46961f:	ret    
  469620:	vpcmpequq k3{k2},zmm7,zmm8
  469627:	kortestb k3,k3
  46962b:	jne    469707 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x837>
  469631:	vmovdqu xmm3,XMMWORD PTR [r10]
  469636:	mov    edi,0xffffffff
  46963b:	crc32  rdi,r11
  469641:	vpinsrd xmm4,xmm3,edi,0x2
  469647:	andn   r8d,r14d,edi
  46964c:	shl    r8,0x4
  469650:	prefetcht2 BYTE PTR [rax+r8*1]
  469655:	vmovdqu XMMWORD PTR [r15+rdx*1],xmm4
  46965b:	add    rdx,0x10
  46965f:	and    rdx,rsi
  469662:	jmp    4690ed <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x21d>
  469667:	nop    WORD PTR [rax+rax*1+0x0]
  469670:	vpcmpequq k6{k2},zmm9,zmm8
  469677:	kortestb k6,k6
  46967b:	jne    4699f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb20>
  469681:	vmovdqu xmm11,XMMWORD PTR [r10]
  469686:	mov    edi,0xffffffff
  46968b:	crc32  rdi,r11
  469691:	vpinsrd xmm12,xmm11,edi,0x2
  469697:	andn   r9d,r14d,edi
  46969c:	shl    r9,0x4
  4696a0:	prefetcht2 BYTE PTR [rax+r9*1]
  4696a5:	vmovdqu XMMWORD PTR [r15+rdx*1],xmm12
  4696ab:	add    rdx,0x10
  4696af:	and    rdx,rsi
  4696b2:	jmp    46906c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x19c>
  4696b7:	nop    WORD PTR [rax+rax*1+0x0]
  4696c0:	vpcmpequq k0{k2},zmm7,zmm8
  4696c7:	kortestb k0,k0
  4696cb:	jne    4699e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb18>
  4696d1:	vmovdqu xmm3,XMMWORD PTR [r11]
  4696d6:	mov    edi,0xffffffff
  4696db:	crc32  rdi,r8
  4696e1:	vpinsrd xmm4,xmm3,edi,0x2
  4696e7:	andn   r10d,r14d,edi
  4696ec:	shl    r10,0x4
  4696f0:	prefetcht2 BYTE PTR [rax+r10*1]
  4696f5:	vmovdqu XMMWORD PTR [r15+rdx*1],xmm4
  4696fb:	add    rdx,0x10
  4696ff:	and    rdx,rsi
  469702:	jmp    468fec <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x11c>
  469707:	inc    DWORD PTR [rbp-0x60]
  46970a:	nop    WORD PTR [rax+rax*1+0x0]
  469710:	mov    r11d,0x55
  469716:	pdep   r9d,ecx,r11d
  46971b:	popcnt ecx,ecx
  46971f:	lea    edi,[r9+r9*2]
  469723:	shl    rcx,0x4
  469727:	kmovb  k6,edi
  46972b:	vpcompressq ZMMWORD PTR [r12]{k6},zmm13
  469732:	add    r12,rcx
  469735:	jmp    469181 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b1>
  46973a:	cmp    r13,QWORD PTR [rbp-0x58]
  46973e:	je     46960b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x73b>
  469744:	mov    r8,QWORD PTR [r12+0x88]
  46974c:	mov    r10,QWORD PTR [r12+0x60]
  469751:	mov    ecx,0x55
  469756:	dec    r8
  469759:	mov    QWORD PTR [rbp-0x38],r10
  46975d:	mov    QWORD PTR [rbp-0x40],r8
  469761:	mov    r14,QWORD PTR [rip+0x29480]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469768:	mov    r15,QWORD PTR [rip+0x29399]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46976f:	mov    r9,QWORD PTR [r12+0xa0]
  469777:	mov    ebx,edi
  469779:	vpxor  xmm2,xmm2,xmm2
  46977d:	kmovb  k2,BYTE PTR [rip+0x2937b]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469785:	kmovb  k1,ecx
  469789:	jmp    4697f1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x921>
  46978b:	cmp    QWORD PTR [rbp-0x38],0x8
  469790:	je     469991 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xac1>
  469796:	vmovd  xmm4,DWORD PTR [rbp-0x50]
  46979b:	mov    rbx,QWORD PTR [rbp-0x40]
  46979f:	mov    edx,edi
  4697a1:	and    rbx,QWORD PTR [rbp-0x50]
  4697a5:	and    rbx,0xfffffffffffffffc
  4697a9:	shl    rbx,0x4
  4697ad:	vpinsrd xmm6,xmm4,DWORD PTR [r13+0xc],0x1
  4697b4:	mov    r8,QWORD PTR [r13+0x0]
  4697b8:	prefetcht2 BYTE PTR [r14+rbx*1]
  4697bd:	shl    rdx,0x4
  4697c1:	lea    ebx,[rdi+0x1]
  4697c4:	add    rdx,r9
  4697c7:	and    ebx,esi
  4697c9:	add    r13,0x10
  4697cd:	mov    QWORD PTR [rdx],r8
  4697d0:	vmovq  QWORD PTR [rdx+0x8],xmm6
  4697d5:	mov    DWORD PTR [r12+0xb0],ebx
  4697dd:	cmp    QWORD PTR [rbp-0x58],r13
  4697e1:	je     469608 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
  4697e7:	mov    eax,DWORD PTR [r12+0xb4]
  4697ef:	mov    edi,ebx
  4697f1:	sub    ebx,eax
  4697f3:	and    ebx,esi
  4697f5:	cmp    esi,ebx
  4697f7:	jbe    469820 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x950>
  4697f9:	cmp    QWORD PTR [rbp-0x38],0x4
  4697fe:	jne    46978b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8bb>
  469800:	mov    r10d,0xffffffff
  469806:	crc32  r10d,DWORD PTR [r13+0x0]
  46980d:	vmovd  xmm5,r10d
  469812:	vmovdqa xmm4,xmm5
  469816:	vmovq  QWORD PTR [rbp-0x50],xmm5
  46981b:	jmp    46979b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8cb>
  469820:	mov    r10,QWORD PTR [r12+0x80]
  469828:	mov    QWORD PTR [rbp-0x48],r10
  46982c:	nop    DWORD PTR [rax+0x0]
  469830:	lea    edx,[rax+0x18]
  469833:	and    edx,esi
  469835:	shl    rdx,0x4
  469839:	mov    ebx,r10d
  46983c:	and    ebx,DWORD PTR [r9+rdx*1+0x8]
  469841:	mov    edx,eax
  469843:	shl    rdx,0x4
  469847:	add    rdx,r9
  46984a:	mov    r8,QWORD PTR [rdx]
  46984d:	shl    rbx,0x4
  469851:	prefetcht0 BYTE PTR [r14+rbx*1]
  469856:	cmp    r8,QWORD PTR [r12+0x90]
  46985e:	jne    4698a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9d0>
  469860:	kortestb k2,k2
  469864:	je     469884 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b4>
  469866:	mov    ebx,DWORD PTR [r11]
  469869:	mov    edx,DWORD PTR [rdx+0xc]
  46986c:	mov    r8,rbx
  46986f:	shl    rbx,0x4
  469873:	add    rbx,QWORD PTR [r11+0x8]
  469877:	lea    ecx,[r8+0x1]
  46987b:	mov    DWORD PTR [rbx],edx
  46987d:	mov    QWORD PTR [rbx+0x8],r15
  469881:	mov    DWORD PTR [r11],ecx
  469884:	inc    eax
  469886:	and    eax,esi
  469888:	mov    DWORD PTR [r12+0xb4],eax
  469890:	test   r15,r15
  469893:	jne    469830 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x960>
  469895:	jmp    4697f9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x929>
  46989a:	nop    WORD PTR [rax+rax*1+0x0]
  4698a0:	mov    ebx,DWORD PTR [rdx+0x8]
  4698a3:	mov    ecx,r10d
  4698a6:	and    ecx,ebx
  4698a8:	shl    rcx,0x4
  4698ac:	add    rcx,r14
  4698af:	vmovdqa64 zmm0,ZMMWORD PTR [rcx]
  4698b5:	vpbroadcastq zmm1,r8
  4698bb:	vpcmpequq k0{k1},zmm0,zmm1
  4698c2:	kortestb k0,k0
  4698c6:	jne    46993e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa6e>
  4698c8:	vpcmpequq k3{k1},zmm0,zmm2
  4698cf:	kortestb k3,k3
  4698d3:	jne    469980 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xab0>
  4698d9:	cmp    QWORD PTR [rbp-0x38],0x4
  4698de:	mov    ecx,ebx
  4698e0:	je     4699aa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xada>
  4698e6:	cmp    QWORD PTR [rbp-0x38],0x8
  4698eb:	je     4699bf <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaef>
  4698f1:	mov    ecx,DWORD PTR [rbp-0x60]
  4698f4:	mov    rbx,QWORD PTR [rbp-0x48]
  4698f8:	vmovd  xmm7,ecx
  4698fc:	vpinsrd xmm3,xmm7,DWORD PTR [rdx+0xc],0x1
  469903:	mov    edx,edi
  469905:	and    rbx,QWORD PTR [rbp-0x60]
  469909:	shl    rdx,0x4
  46990d:	inc    edi
  46990f:	inc    eax
  469911:	add    rdx,r9
  469914:	shl    rbx,0x4
  469918:	and    edi,esi
  46991a:	and    eax,esi
  46991c:	prefetcht2 BYTE PTR [r14+rbx*1]
  469921:	mov    QWORD PTR [rdx],r8
  469924:	vmovq  QWORD PTR [rdx+0x8],xmm3
  469929:	mov    DWORD PTR [r12+0xb0],edi
  469931:	mov    DWORD PTR [r12+0xb4],eax
  469939:	jmp    469830 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x960>
  46993e:	mov    r8d,DWORD PTR [r11]
  469941:	mov    ebx,DWORD PTR [rdx+0xc]
  469944:	mov    r10,r8
  469947:	shl    r8,0x4
  46994b:	add    r8,QWORD PTR [r11+0x8]
  46994f:	mov    DWORD PTR [r8],ebx
  469952:	xor    ebx,ebx
  469954:	kmovb  edx,k0
  469958:	tzcnt  ebx,edx
  46995c:	inc    ebx
  46995e:	movsxd rdx,ebx
  469961:	mov    rcx,QWORD PTR [rcx+rdx*8]
  469965:	inc    eax
  469967:	inc    r10d
  46996a:	and    eax,esi
  46996c:	mov    QWORD PTR [r8+0x8],rcx
  469970:	mov    DWORD PTR [r11],r10d
  469973:	mov    DWORD PTR [r12+0xb4],eax
  46997b:	jmp    4697f9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x929>
  469980:	inc    eax
  469982:	and    eax,esi
  469984:	mov    DWORD PTR [r12+0xb4],eax
  46998c:	jmp    4697f9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x929>
  469991:	mov    eax,0xffffffff
  469996:	crc32  rax,QWORD PTR [r13+0x0]
  46999d:	mov    QWORD PTR [rbp-0x50],rax
  4699a1:	vmovd  xmm4,eax
  4699a5:	jmp    46979b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8cb>
  4699aa:	mov    ecx,0xffffffff
  4699af:	crc32  ecx,ebx
  4699b4:	mov    ebx,ecx
  4699b6:	mov    QWORD PTR [rbp-0x60],rbx
  4699ba:	jmp    4698f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa24>
  4699bf:	mov    ebx,0xffffffff
  4699c4:	crc32  rbx,rcx
  4699ca:	mov    QWORD PTR [rbp-0x60],rbx
  4699ce:	mov    ecx,ebx
  4699d0:	jmp    4698f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa24>
  4699d5:	inc    DWORD PTR [rbp-0x60]
  4699d8:	vpxor  xmm0,xmm0,xmm0
  4699dc:	xor    ecx,ecx
  4699de:	vpxor  xmm13,xmm13,xmm13
  4699e3:	jmp    468fec <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x11c>
  4699e8:	inc    DWORD PTR [rbp-0x60]
  4699eb:	jmp    46906c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x19c>
  4699f0:	inc    DWORD PTR [rbp-0x60]
  4699f3:	jmp    4690ed <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x21d>
