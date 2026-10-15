0000000000468df0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468df0:	push   rbp
  468df1:	mov    rcx,rdi
  468df4:	mov    rdi,rdx
  468df7:	mov    rbp,rsp
  468dfa:	push   r15
  468dfc:	push   r14
  468dfe:	push   r13
  468e00:	push   r12
  468e02:	push   rbx
  468e03:	and    rsp,0xffffffffffffffc0
  468e07:	sub    rsp,0x8
  468e0b:	mov    r11,QWORD PTR [rsi+0x8]
  468e0f:	mov    r10d,DWORD PTR [rcx+0xb0]
  468e16:	mov    eax,DWORD PTR [rcx+0xb4]
  468e1c:	mov    rdx,QWORD PTR [rsi]
  468e1f:	mov    r8d,DWORD PTR [rcx+0x78]
  468e23:	mov    r9d,DWORD PTR [rcx+0x6c]
  468e27:	mov    rbx,r11
  468e2a:	mov    esi,r10d
  468e2d:	shl    rbx,0x4
  468e31:	sub    esi,eax
  468e33:	add    rbx,rdx
  468e36:	and    esi,r8d
  468e39:	lea    r12d,[r9-0x1]
  468e3d:	mov    QWORD PTR [rsp-0x28],rbx
  468e42:	cmp    esi,r12d
  468e45:	jb     469705 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x915>
  468e4b:	and    r11,0xfffffffffffffffc
  468e4f:	mov    ebx,r10d
  468e52:	shl    r11,0x4
  468e56:	mov    r10,QWORD PTR [rcx+0x80]
  468e5d:	mov    r15,QWORD PTR [rdi+0x8]
  468e61:	shl    r9,0x4
  468e65:	lea    r14,[rdx+r11*1]
  468e69:	mov    QWORD PTR [rsp-0x30],r9
  468e6e:	mov    DWORD PTR [rsp],r10d
  468e72:	mov    QWORD PTR [rsp-0x10],r15
  468e77:	mov    QWORD PTR [rsp-0x48],r11
  468e7c:	mov    QWORD PTR [rsp-0x38],r14
  468e81:	mov    DWORD PTR [rsp-0x3c],0x0
  468e89:	mov    r8,QWORD PTR [rcx+0xa0]
  468e90:	mov    rsi,QWORD PTR [rip+0x29d51]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468e97:	dec    r9
  468e9a:	shl    rax,0x4
  468e9e:	shl    rbx,0x4
  468ea2:	not    r10d
  468ea5:	cmp    rdx,r14
  468ea8:	je     46999e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbae>
  468eae:	mov    r13d,0x55
  468eb4:	mov    r11d,0xf
  468eba:	mov    r12d,0xf0
  468ec0:	mov    r15d,0xf00
  468ec6:	mov    r14d,0xfffff000
  468ecc:	kmovb  k1,r13d
  468ed1:	vpxor  xmm4,xmm4,xmm4
  468ed5:	mov    r13d,0xffffffff
  468edb:	kmovw  k5,r11d
  468ee0:	kmovw  k4,r12d
  468ee5:	kmovw  k3,r15d
  468eea:	kmovw  k2,r14d
  468eef:	jmp    469189 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x399>
  468ef4:	nop    DWORD PTR [rax+0x0]
  468ef8:	vmovd  xmm13,DWORD PTR [r12+0xc]
  468eff:	kshiftlb k6,k6,0x1
  468f05:	vpcompressq zmm12{k6}{z},zmm8
  468f0b:	vpunpcklqdq xmm14,xmm13,xmm12
  468f10:	vshufi32x4 zmm15{k5}{z},zmm14,zmm14,0x0
  468f17:	vmovdqa64 zmm12,zmm15
  468f1d:	mov    r11d,0x1
  468f23:	lea    r15,[rax+0x180]
  468f2a:	and    r15,r9
  468f2d:	andn   r14d,r10d,DWORD PTR [r8+r15*1+0x8]
  468f34:	mov    r12d,r14d
  468f37:	shl    r12,0x4
  468f3b:	lea    r14,[r8+rax*1]
  468f3f:	mov    r15d,DWORD PTR [r14+0x8]
  468f43:	prefetcht0 BYTE PTR [rsi+r12*1]
  468f48:	andn   r12d,r10d,r15d
  468f4d:	mov    r12d,r12d
  468f50:	shl    r12,0x4
  468f54:	vmovdqa64 zmm0,ZMMWORD PTR [rsi+r12*1]
  468f5b:	vpbroadcastq zmm2,QWORD PTR [r14]
  468f61:	vpcmpequq k0{k1},zmm0,zmm2
  468f68:	add    rax,0x10
  468f6c:	and    rax,r9
  468f6f:	kortestb k0,k0
  468f73:	je     469620 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x830>
  468f79:	vmovd  xmm1,DWORD PTR [r14+0xc]
  468f7f:	kshiftlb k6,k0,0x1
  468f85:	vpcompressq zmm5{k6}{z},zmm0
  468f8b:	vpunpcklqdq xmm6,xmm1,xmm5
  468f8f:	vshufi32x4 zmm15{k4},zmm6,zmm6,0x0
  468f96:	vmovdqa64 zmm12,zmm15
  468f9c:	or     r11d,0x2
  468fa0:	lea    r14,[rax+0x180]
  468fa7:	and    r14,r9
  468faa:	andn   r12d,r10d,DWORD PTR [r8+r14*1+0x8]
  468fb1:	mov    r15d,r12d
  468fb4:	shl    r15,0x4
  468fb8:	lea    r14,[r8+rax*1]
  468fbc:	prefetcht0 BYTE PTR [rsi+r15*1]
  468fc1:	mov    r15d,DWORD PTR [r14+0x8]
  468fc5:	andn   r12d,r10d,r15d
  468fca:	mov    r12d,r12d
  468fcd:	shl    r12,0x4
  468fd1:	vmovdqa64 zmm8,ZMMWORD PTR [rsi+r12*1]
  468fd8:	vpbroadcastq zmm9,QWORD PTR [r14]
  468fde:	vpcmpequq k0{k1},zmm8,zmm9
  468fe5:	add    rax,0x10
  468fe9:	and    rax,r9
  468fec:	kortestb k0,k0
  468ff0:	je     4695c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
  468ff6:	vmovd  xmm13,DWORD PTR [r14+0xc]
  468ffc:	kshiftlb k6,k0,0x1
  469002:	vpcompressq zmm12{k6}{z},zmm8
  469008:	vpunpcklqdq xmm14,xmm13,xmm12
  46900d:	mov    QWORD PTR [rsp-0x18],rdx
  469012:	vshufi32x4 zmm15{k3},zmm14,zmm14,0x0
  469019:	vmovdqa64 zmm12,zmm15
  46901f:	or     r11d,0x4
  469023:	lea    rdx,[rax+0x180]
  46902a:	and    rdx,r9
  46902d:	andn   r14d,r10d,DWORD PTR [r8+rdx*1+0x8]
  469034:	mov    r12d,r14d
  469037:	shl    r12,0x4
  46903b:	lea    r14,[r8+rax*1]
  46903f:	mov    r15d,DWORD PTR [r14+0x8]
  469043:	prefetcht0 BYTE PTR [rsi+r12*1]
  469048:	andn   edx,r10d,r15d
  46904d:	mov    r12d,edx
  469050:	shl    r12,0x4
  469054:	vmovdqa64 zmm0,ZMMWORD PTR [rsi+r12*1]
  46905b:	vpbroadcastq zmm2,QWORD PTR [r14]
  469061:	vpcmpequq k0{k1},zmm0,zmm2
  469068:	add    rax,0x10
  46906c:	and    rax,r9
  46906f:	lea    r12,[r8+rbx*1]
  469073:	kortestb k0,k0
  469077:	je     469568 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x778>
  46907d:	vmovd  xmm1,DWORD PTR [r14+0xc]
  469083:	kshiftlb k6,k0,0x1
  469089:	vpcompressq zmm5{k6}{z},zmm0
  46908f:	vpunpcklqdq xmm6,xmm1,xmm5
  469093:	vshufi32x4 zmm15{k2},zmm6,zmm6,0x0
  46909a:	or     r11d,0x8
  46909e:	mov    rdx,QWORD PTR [rsp-0x18]
  4690a3:	vmovdqa64 zmm12,zmm15
  4690a9:	cmp    r11d,0xf
  4690ad:	jne    4696d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8e0>
  4690b3:	mov    r14,QWORD PTR [rsp-0x10]
  4690b8:	vmovdqu64 ZMMWORD PTR [r14],zmm15
  4690be:	add    r14,0x40
  4690c2:	mov    QWORD PTR [rsp-0x10],r14
  4690c7:	mov    r15,r13
  4690ca:	crc32  r15,QWORD PTR [rdx]
  4690d0:	vmovq  xmm15,r15
  4690d5:	mov    r11d,r15d
  4690d8:	mov    r15d,DWORD PTR [rsp]
  4690dc:	mov    r14,r13
  4690df:	and    r11d,r15d
  4690e2:	shl    r11,0x4
  4690e6:	crc32  r14,QWORD PTR [rdx+0x10]
  4690ed:	prefetcht2 BYTE PTR [rsi+r11*1]
  4690f2:	mov    r11d,r15d
  4690f5:	and    r11d,r14d
  4690f8:	shl    r11,0x4
  4690fc:	prefetcht2 BYTE PTR [rsi+r11*1]
  469101:	mov    r11,r13
  469104:	crc32  r11,QWORD PTR [rdx+0x20]
  46910b:	vmovq  xmm8,r11
  469110:	and    r11d,r15d
  469113:	shl    r11,0x4
  469117:	mov    r15,r13
  46911a:	prefetcht2 BYTE PTR [rsi+r11*1]
  46911f:	mov    r11d,DWORD PTR [rsp]
  469123:	crc32  r15,QWORD PTR [rdx+0x30]
  46912a:	and    r11d,r15d
  46912d:	shl    r11,0x4
  469131:	vpinsrd xmm10,xmm15,r14d,0x1
  469137:	vmovdqu32 zmm13,ZMMWORD PTR [rdx]
  46913d:	vpinsrd xmm9,xmm8,r15d,0x1
  469143:	vpunpcklqdq xmm11,xmm10,xmm9
  469148:	mov    r14d,0x4444
  46914e:	prefetcht2 BYTE PTR [rsi+r11*1]
  469153:	lea    r11,[rbx+0x40]
  469157:	kmovw  k6,r14d
  46915c:	vpexpandd zmm13{k6},zmm11
  469162:	cmp    QWORD PTR [rsp-0x30],r11
  469167:	jb     469680 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x890>
  46916d:	vmovdqu64 ZMMWORD PTR [r12],zmm13
  469174:	mov    rbx,r11
  469177:	add    rdx,0x40
  46917b:	and    rbx,r9
  46917e:	cmp    QWORD PTR [rsp-0x38],rdx
  469183:	je     469238 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
  469189:	lea    r11,[rax+0x180]
  469190:	and    r11,r9
  469193:	andn   r12d,r10d,DWORD PTR [r8+r11*1+0x8]
  46919a:	mov    r15d,r12d
  46919d:	shl    r15,0x4
  4691a1:	lea    r12,[r8+rax*1]
  4691a5:	mov    r14d,DWORD PTR [r12+0x8]
  4691aa:	prefetcht0 BYTE PTR [rsi+r15*1]
  4691af:	andn   r11d,r10d,r14d
  4691b4:	mov    r15d,r11d
  4691b7:	shl    r15,0x4
  4691bb:	vmovdqa64 zmm8,ZMMWORD PTR [rsi+r15*1]
  4691c2:	vpbroadcastq zmm9,QWORD PTR [r12]
  4691c9:	vpcmpequq k6{k1},zmm8,zmm9
  4691d0:	add    rax,0x10
  4691d4:	and    rax,r9
  4691d7:	kortestb k6,k6
  4691db:	jne    468ef8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
  4691e1:	vpcmpequq k7{k1},zmm8,zmm4
  4691e8:	kortestb k7,k7
  4691ec:	jne    4699c8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbd8>
  4691f2:	mov    r15,r13
  4691f5:	crc32  r15,r14
  4691fb:	mov    r14d,DWORD PTR [rsp]
  4691ff:	vmovd  xmm10,r15d
  469204:	vpinsrd xmm11,xmm10,DWORD PTR [r12+0xc],0x1
  46920c:	and    r14d,r15d
  46920f:	mov    r12,QWORD PTR [r12]
  469213:	lea    r11,[r8+rbx*1]
  469217:	shl    r14,0x4
  46921b:	add    rbx,0x10
  46921f:	prefetcht2 BYTE PTR [rsi+r14*1]
  469224:	and    rbx,r9
  469227:	mov    QWORD PTR [r11],r12
  46922a:	vmovq  QWORD PTR [r11+0x8],xmm11
  469230:	jmp    469189 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x399>
  469235:	nop    DWORD PTR [rax]
  469238:	mov    r12d,DWORD PTR [rsp-0x3c]
  46923d:	vmovq  xmm14,rbx
  469242:	vpinsrq xmm0,xmm14,rax,0x1
  469248:	mov    rsi,QWORD PTR [rsp-0x48]
  46924d:	vpsrlq xmm2,xmm0,0x4
  469252:	vpmovqd xmm7,xmm2
  469258:	sar    rsi,0x4
  46925c:	vmovq  QWORD PTR [rcx+0xb0],xmm7
  469264:	sub    rsi,r12
  469267:	add    DWORD PTR [rdi],esi
  469269:	vpextrd eax,xmm7,0x1
  46926f:	cmp    rdx,QWORD PTR [rsp-0x28]
  469274:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x760>
  46927a:	mov    r15,QWORD PTR [rcx+0x88]
  469281:	mov    r12,QWORD PTR [rcx+0x80]
  469288:	mov    r8,QWORD PTR [rcx+0x60]
  46928c:	dec    r15
  46928f:	mov    QWORD PTR [rsp-0x10],r12
  469294:	mov    QWORD PTR [rsp],r8
  469298:	mov    QWORD PTR [rsp-0x18],r15
  46929d:	mov    r11d,DWORD PTR [rcx+0x78]
  4692a1:	mov    rbx,QWORD PTR [rip+0x29940]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4692a8:	mov    r10,QWORD PTR [rcx+0xa0]
  4692af:	movzx  r14d,BYTE PTR [rip+0x29849]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4692b7:	mov    r13,QWORD PTR [rip+0x2984a]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4692be:	mov    r9d,0x55
  4692c4:	vpxor  xmm3,xmm3,xmm3
  4692c8:	kmovb  k1,r9d
  4692cd:	nop    DWORD PTR [rax]
  4692d0:	lea    esi,[rax+0x18]
  4692d3:	and    esi,r11d
  4692d6:	shl    rsi,0x4
  4692da:	mov    r8d,r12d
  4692dd:	and    r8d,DWORD PTR [r10+rsi*1+0x8]
  4692e2:	mov    esi,eax
  4692e4:	mov    r9,r8
  4692e7:	shl    rsi,0x4
  4692eb:	shl    r9,0x4
  4692ef:	add    rsi,r10
  4692f2:	prefetcht0 BYTE PTR [rbx+r9*1]
  4692f7:	mov    r9,QWORD PTR [rsi]
  4692fa:	cmp    r9,QWORD PTR [rcx+0x90]
  469301:	jne    4693c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5d0>
  469307:	test   r14b,r14b
  46930a:	je     46932a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x53a>
  46930c:	mov    r15d,DWORD PTR [rdi]
  46930f:	mov    esi,DWORD PTR [rsi+0xc]
  469312:	mov    r9,r15
  469315:	shl    r15,0x4
  469319:	add    r15,QWORD PTR [rdi+0x8]
  46931d:	inc    r9d
  469320:	mov    DWORD PTR [r15],esi
  469323:	mov    QWORD PTR [r15+0x8],r13
  469327:	mov    DWORD PTR [rdi],r9d
  46932a:	inc    eax
  46932c:	and    eax,r11d
  46932f:	mov    DWORD PTR [rcx+0xb4],eax
  469335:	test   r13,r13
  469338:	jne    4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4e0>
  46933a:	cmp    QWORD PTR [rsp],0x4
  46933f:	je     4694b5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c5>
  469345:	nop    DWORD PTR [rax]
  469348:	cmp    QWORD PTR [rsp],0x8
  46934d:	je     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x740>
  469353:	vmovd  xmm15,DWORD PTR [rsp-0x20]
  469359:	mov    r8,QWORD PTR [rdx]
  46935c:	mov    esi,DWORD PTR [rcx+0xb0]
  469362:	mov    r9,QWORD PTR [rsp-0x18]
  469367:	mov    rax,rsi
  46936a:	and    r9,QWORD PTR [rsp-0x20]
  46936f:	vpinsrd xmm9,xmm15,DWORD PTR [rdx+0xc],0x1
  469376:	and    r9,0xfffffffffffffffc
  46937a:	shl    rsi,0x4
  46937e:	inc    eax
  469380:	add    rsi,r10
  469383:	shl    r9,0x4
  469387:	and    eax,r11d
  46938a:	add    rdx,0x10
  46938e:	prefetcht2 BYTE PTR [rbx+r9*1]
  469393:	mov    QWORD PTR [rsi],r8
  469396:	vmovq  QWORD PTR [rsi+0x8],xmm9
  46939b:	mov    DWORD PTR [rcx+0xb0],eax
  4693a1:	cmp    rdx,QWORD PTR [rsp-0x28]
  4693a6:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x760>
  4693ac:	mov    eax,DWORD PTR [rcx+0xb4]
  4693b2:	jmp    4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4e0>
  4693b7:	nop    WORD PTR [rax+rax*1+0x0]
  4693c0:	mov    r15d,DWORD PTR [rsi+0x8]
  4693c4:	mov    r8d,r12d
  4693c7:	and    r8d,r15d
  4693ca:	shl    r8,0x4
  4693ce:	add    r8,rbx
  4693d1:	vmovdqa64 zmm5,ZMMWORD PTR [r8]
  4693d7:	vpbroadcastq zmm1,r9
  4693dd:	vpcmpequq k0{k1},zmm5,zmm1
  4693e4:	kortestb k0,k0
  4693e8:	jne    469470 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x680>
  4693ee:	vpcmpequq k2{k1},zmm5,zmm3
  4693f5:	kortestb k2,k2
  4693f9:	jne    4694e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6f0>
  4693ff:	cmp    QWORD PTR [rsp],0x4
  469404:	mov    r8d,r15d
  469407:	je     4694f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
  46940d:	cmp    QWORD PTR [rsp],0x8
  469412:	je     469510 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  469418:	vmovd  xmm6,DWORD PTR [rsp-0x8]
  46941e:	mov    r8d,DWORD PTR [rcx+0xb0]
  469425:	mov    r15,QWORD PTR [rsp-0x10]
  46942a:	vpinsrd xmm4,xmm6,DWORD PTR [rsi+0xc],0x1
  469431:	mov    rsi,r8
  469434:	and    r15,QWORD PTR [rsp-0x8]
  469439:	shl    r8,0x4
  46943d:	inc    esi
  46943f:	inc    eax
  469441:	add    r8,r10
  469444:	shl    r15,0x4
  469448:	and    esi,r11d
  46944b:	and    eax,r11d
  46944e:	prefetcht2 BYTE PTR [rbx+r15*1]
  469453:	mov    QWORD PTR [r8],r9
  469456:	vmovq  QWORD PTR [r8+0x8],xmm4
  46945c:	mov    DWORD PTR [rcx+0xb0],esi
  469462:	mov    DWORD PTR [rcx+0xb4],eax
  469468:	jmp    4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4e0>
  46946d:	nop    DWORD PTR [rax]
  469470:	mov    r9d,DWORD PTR [rdi]
  469473:	mov    esi,DWORD PTR [rsi+0xc]
  469476:	mov    r15,r9
  469479:	shl    r9,0x4
  46947d:	add    r9,QWORD PTR [rdi+0x8]
  469481:	mov    DWORD PTR [r9],esi
  469484:	kmovb  esi,k0
  469488:	tzcnt  esi,esi
  46948c:	inc    esi
  46948e:	movsxd rsi,esi
  469491:	mov    r8,QWORD PTR [r8+rsi*8]
  469495:	inc    eax
  469497:	inc    r15d
  46949a:	and    eax,r11d
  46949d:	cmp    QWORD PTR [rsp],0x4
  4694a2:	mov    QWORD PTR [r9+0x8],r8
  4694a6:	mov    DWORD PTR [rdi],r15d
  4694a9:	mov    DWORD PTR [rcx+0xb4],eax
  4694af:	jne    469348 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x558>
  4694b5:	mov    r15d,0xffffffff
  4694bb:	crc32  r15d,DWORD PTR [rdx]
  4694c1:	vmovd  xmm8,r15d
  4694c6:	mov    r8,QWORD PTR [rdx]
  4694c9:	vmovdqa xmm15,xmm8
  4694ce:	vmovq  QWORD PTR [rsp-0x20],xmm8
  4694d4:	jmp    46935c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x56c>
  4694d9:	nop    DWORD PTR [rax+0x0]
  4694e0:	inc    eax
  4694e2:	and    eax,r11d
  4694e5:	mov    DWORD PTR [rcx+0xb4],eax
  4694eb:	jmp    46933a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x54a>
  4694f0:	mov    r8d,0xffffffff
  4694f6:	crc32  r8d,r15d
  4694fc:	vmovd  xmm12,r8d
  469501:	vmovdqa xmm6,xmm12
  469505:	vmovq  QWORD PTR [rsp-0x8],xmm12
  46950b:	jmp    46941e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x62e>
  469510:	mov    r15d,0xffffffff
  469516:	crc32  r15,r8
  46951c:	mov    QWORD PTR [rsp-0x8],r15
  469521:	vmovd  xmm6,r15d
  469526:	jmp    46941e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x62e>
  46952b:	nop    DWORD PTR [rax+rax*1+0x0]
  469530:	mov    r8,QWORD PTR [rdx]
  469533:	mov    eax,0xffffffff
  469538:	crc32  rax,r8
  46953e:	mov    QWORD PTR [rsp-0x20],rax
  469543:	vmovd  xmm15,eax
  469547:	jmp    46935c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x56c>
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
  469568:	vpcmpequq k7{k1},zmm0,zmm4
  46956f:	kortestb k7,k7
  469573:	jne    4696c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8d0>
  469579:	mov    rdx,r13
  46957c:	crc32  rdx,r15
  469582:	vmovq  xmm7,rdx
  469587:	mov    r15d,edx
  46958a:	vpinsrd xmm3,xmm7,DWORD PTR [r14+0xc],0x1
  469591:	and    r15d,DWORD PTR [rsp]
  469595:	mov    r14,QWORD PTR [r14]
  469598:	shl    r15,0x4
  46959c:	add    rbx,0x10
  4695a0:	prefetcht2 BYTE PTR [rsi+r15*1]
  4695a5:	and    rbx,r9
  4695a8:	mov    QWORD PTR [r12],r14
  4695ac:	vmovq  QWORD PTR [r12+0x8],xmm3
  4695b3:	jmp    469023 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x233>
  4695b8:	nop    DWORD PTR [rax+rax*1+0x0]
  4695c0:	vpcmpequq k7{k1},zmm8,zmm4
  4695c7:	kortestb k7,k7
  4695cb:	jne    4699de <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbee>
  4695d1:	lea    r12,[r8+rbx*1]
  4695d5:	mov    QWORD PTR [rsp-0x18],r12
  4695da:	mov    r12,r13
  4695dd:	crc32  r12,r15
  4695e3:	vmovq  xmm10,r12
  4695e8:	mov    r15d,r12d
  4695eb:	vpinsrd xmm11,xmm10,DWORD PTR [r14+0xc],0x1
  4695f2:	mov    r12,QWORD PTR [rsp-0x18]
  4695f7:	mov    r14,QWORD PTR [r14]
  4695fa:	and    r15d,DWORD PTR [rsp]
  4695fe:	shl    r15,0x4
  469602:	add    rbx,0x10
  469606:	prefetcht2 BYTE PTR [rsi+r15*1]
  46960b:	and    rbx,r9
  46960e:	mov    QWORD PTR [r12],r14
  469612:	vmovq  QWORD PTR [r12+0x8],xmm11
  469619:	jmp    468fa0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1b0>
  46961e:	xchg   ax,ax
  469620:	vpcmpequq k7{k1},zmm0,zmm4
  469627:	kortestb k7,k7
  46962b:	jne    4699bf <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbcf>
  469631:	lea    r12,[r8+rbx*1]
  469635:	mov    QWORD PTR [rsp-0x18],r12
  46963a:	mov    r12,r13
  46963d:	crc32  r12,r15
  469643:	vmovq  xmm7,r12
  469648:	mov    r15d,r12d
  46964b:	vpinsrd xmm3,xmm7,DWORD PTR [r14+0xc],0x1
  469652:	mov    r12,QWORD PTR [rsp-0x18]
  469657:	mov    r14,QWORD PTR [r14]
  46965a:	and    r15d,DWORD PTR [rsp]
  46965e:	shl    r15,0x4
  469662:	add    rbx,0x10
  469666:	prefetcht2 BYTE PTR [rsi+r15*1]
  46966b:	and    rbx,r9
  46966e:	mov    QWORD PTR [r12],r14
  469672:	vmovq  QWORD PTR [r12+0x8],xmm3
  469679:	jmp    468f23 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  46967e:	xchg   ax,ax
  469680:	mov    r14,QWORD PTR [rsp-0x30]
  469685:	mov    r15d,0x1
  46968b:	sub    r14,rbx
  46968e:	shr    r14,0x2
  469692:	shlx   r14d,r15d,r14d
  469697:	lea    r15d,[r14-0x1]
  46969b:	kmovw  k7,r15d
  4696a0:	vmovdqu32 ZMMWORD PTR [r12]{k7},zmm13
  4696a7:	sub    rbx,QWORD PTR [rsp-0x30]
  4696ac:	neg    r14d
  4696af:	kmovw  k6,r14d
  4696b4:	vmovdqu32 ZMMWORD PTR [r8+rbx*1]{k6},zmm13
  4696bb:	jmp    469174 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x384>
  4696c0:	inc    DWORD PTR [rsp-0x3c]
  4696c4:	mov    rdx,QWORD PTR [rsp-0x18]
  4696c9:	nop    DWORD PTR [rax+0x0]
  4696d0:	mov    r15d,0x55
  4696d6:	pdep   r14d,r11d,r15d
  4696db:	mov    r15,QWORD PTR [rsp-0x10]
  4696e0:	lea    r14d,[r14+r14*2]
  4696e4:	popcnt r11d,r11d
  4696e9:	shl    r11,0x4
  4696ed:	kmovb  k7,r14d
  4696f2:	vpcompressq ZMMWORD PTR [r15]{k7},zmm12
  4696f8:	add    r15,r11
  4696fb:	mov    QWORD PTR [rsp-0x10],r15
  469700:	jmp    4690c7 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2d7>
  469705:	cmp    rdx,QWORD PTR [rsp-0x28]
  46970a:	je     469553 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x763>
  469710:	mov    r11,QWORD PTR [rcx+0x88]
  469717:	mov    r9,QWORD PTR [rcx+0x60]
  46971b:	mov    r13d,0x55
  469721:	dec    r11
  469724:	mov    QWORD PTR [rsp],r9
  469728:	mov    QWORD PTR [rsp-0x8],r11
  46972d:	mov    r15,QWORD PTR [rip+0x294b4]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469734:	mov    r14,QWORD PTR [rip+0x293cd]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46973b:	mov    rbx,QWORD PTR [rcx+0xa0]
  469742:	mov    r12d,r10d
  469745:	vpxor  xmm2,xmm2,xmm2
  469749:	kmovb  k2,BYTE PTR [rip+0x293af]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469751:	kmovb  k1,r13d
  469756:	jmp    4697c2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9d2>
  469758:	cmp    QWORD PTR [rsp],0x8
  46975d:	je     46996c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb7c>
  469763:	vmovd  xmm4,DWORD PTR [rsp-0x10]
  469769:	mov    r13,QWORD PTR [rsp-0x8]
  46976e:	mov    esi,r10d
  469771:	and    r13,QWORD PTR [rsp-0x10]
  469776:	vpinsrd xmm6,xmm4,DWORD PTR [rdx+0xc],0x1
  46977d:	mov    r11,QWORD PTR [rdx]
  469780:	and    r13,0xfffffffffffffffc
  469784:	shl    rsi,0x4
  469788:	lea    r12d,[r10+0x1]
  46978c:	add    rsi,rbx
  46978f:	shl    r13,0x4
  469793:	and    r12d,r8d
  469796:	add    rdx,0x10
  46979a:	prefetcht2 BYTE PTR [r15+r13*1]
  46979f:	mov    QWORD PTR [rsi],r11
  4697a2:	vmovq  QWORD PTR [rsi+0x8],xmm6
  4697a7:	mov    DWORD PTR [rcx+0xb0],r12d
  4697ae:	cmp    QWORD PTR [rsp-0x28],rdx
  4697b3:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x760>
  4697b9:	mov    eax,DWORD PTR [rcx+0xb4]
  4697bf:	mov    r10d,r12d
  4697c2:	sub    r12d,eax
  4697c5:	and    r12d,r8d
  4697c8:	cmp    r8d,r12d
  4697cb:	jbe    4697f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa04>
  4697cd:	cmp    QWORD PTR [rsp],0x4
  4697d2:	jne    469758 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x968>
  4697d4:	mov    r12d,0xffffffff
  4697da:	crc32  r12d,DWORD PTR [rdx]
  4697e0:	vmovd  xmm5,r12d
  4697e5:	vmovdqa xmm4,xmm5
  4697e9:	vmovq  QWORD PTR [rsp-0x10],xmm5
  4697ef:	jmp    469769 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x979>
  4697f4:	mov    r12,QWORD PTR [rcx+0x80]
  4697fb:	mov    QWORD PTR [rsp-0x20],r12
  469800:	lea    esi,[rax+0x18]
  469803:	and    esi,r8d
  469806:	shl    rsi,0x4
  46980a:	mov    r9d,r12d
  46980d:	and    r9d,DWORD PTR [rbx+rsi*1+0x8]
  469812:	mov    esi,eax
  469814:	shl    rsi,0x4
  469818:	add    rsi,rbx
  46981b:	mov    r11,QWORD PTR [rsi]
  46981e:	shl    r9,0x4
  469822:	prefetcht0 BYTE PTR [r15+r9*1]
  469827:	cmp    r11,QWORD PTR [rcx+0x90]
  46982e:	jne    469870 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa80>
  469830:	kortestb k2,k2
  469834:	je     469856 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa66>
  469836:	mov    r13d,DWORD PTR [rdi]
  469839:	mov    esi,DWORD PTR [rsi+0xc]
  46983c:	mov    r11,r13
  46983f:	shl    r13,0x4
  469843:	add    r13,QWORD PTR [rdi+0x8]
  469847:	lea    r9d,[r11+0x1]
  46984b:	mov    DWORD PTR [r13+0x0],esi
  46984f:	mov    QWORD PTR [r13+0x8],r14
  469853:	mov    DWORD PTR [rdi],r9d
  469856:	inc    eax
  469858:	and    eax,r8d
  46985b:	mov    DWORD PTR [rcx+0xb4],eax
  469861:	test   r14,r14
  469864:	jne    469800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa10>
  469866:	jmp    4697cd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9dd>
  46986b:	nop    DWORD PTR [rax+rax*1+0x0]
  469870:	mov    r13d,DWORD PTR [rsi+0x8]
  469874:	mov    r9d,r12d
  469877:	and    r9d,r13d
  46987a:	shl    r9,0x4
  46987e:	add    r9,r15
  469881:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  469887:	vpbroadcastq zmm1,r11
  46988d:	vpcmpequq k0{k1},zmm0,zmm1
  469894:	kortestb k0,k0
  469898:	jne    469917 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb27>
  46989a:	vpcmpequq k3{k1},zmm0,zmm2
  4698a1:	kortestb k3,k3
  4698a5:	jne    46995c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb6c>
  4698ab:	cmp    QWORD PTR [rsp],0x4
  4698b0:	mov    r9d,r13d
  4698b3:	je     469985 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb95>
  4698b9:	cmp    QWORD PTR [rsp],0x8
  4698be:	je     4699a6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbb6>
  4698c4:	mov    r9d,DWORD PTR [rsp-0x18]
  4698c9:	mov    r13,QWORD PTR [rsp-0x20]
  4698ce:	vmovd  xmm7,r9d
  4698d3:	vpinsrd xmm3,xmm7,DWORD PTR [rsi+0xc],0x1
  4698da:	mov    esi,r10d
  4698dd:	and    r13,QWORD PTR [rsp-0x18]
  4698e2:	shl    rsi,0x4
  4698e6:	inc    r10d
  4698e9:	inc    eax
  4698eb:	add    rsi,rbx
  4698ee:	shl    r13,0x4
  4698f2:	and    r10d,r8d
  4698f5:	and    eax,r8d
  4698f8:	prefetcht2 BYTE PTR [r15+r13*1]
  4698fd:	mov    QWORD PTR [rsi],r11
  469900:	vmovq  QWORD PTR [rsi+0x8],xmm3
  469905:	mov    DWORD PTR [rcx+0xb0],r10d
  46990c:	mov    DWORD PTR [rcx+0xb4],eax
  469912:	jmp    469800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa10>
  469917:	mov    r11d,DWORD PTR [rdi]
  46991a:	mov    r13d,DWORD PTR [rsi+0xc]
  46991e:	mov    r12,r11
  469921:	shl    r11,0x4
  469925:	add    r11,QWORD PTR [rdi+0x8]
  469929:	mov    DWORD PTR [r11],r13d
  46992c:	xor    r13d,r13d
  46992f:	kmovb  esi,k0
  469933:	tzcnt  r13d,esi
  469938:	inc    r13d
  46993b:	movsxd rsi,r13d
  46993e:	mov    r9,QWORD PTR [r9+rsi*8]
  469942:	inc    eax
  469944:	inc    r12d
  469947:	and    eax,r8d
  46994a:	mov    QWORD PTR [r11+0x8],r9
  46994e:	mov    DWORD PTR [rdi],r12d
  469951:	mov    DWORD PTR [rcx+0xb4],eax
  469957:	jmp    4697cd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9dd>
  46995c:	inc    eax
  46995e:	and    eax,r8d
  469961:	mov    DWORD PTR [rcx+0xb4],eax
  469967:	jmp    4697cd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9dd>
  46996c:	mov    eax,0xffffffff
  469971:	crc32  rax,QWORD PTR [rdx]
  469977:	mov    QWORD PTR [rsp-0x10],rax
  46997c:	vmovd  xmm4,eax
  469980:	jmp    469769 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x979>
  469985:	mov    r9d,0xffffffff
  46998b:	crc32  r9d,r13d
  469991:	mov    r13d,r9d
  469994:	mov    QWORD PTR [rsp-0x18],r13
  469999:	jmp    4698c9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad9>
  46999e:	xor    r12d,r12d
  4699a1:	jmp    46923d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x44d>
  4699a6:	mov    r13d,0xffffffff
  4699ac:	crc32  r13,r9
  4699b2:	mov    QWORD PTR [rsp-0x18],r13
  4699b7:	mov    r9d,r13d
  4699ba:	jmp    4698c9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad9>
  4699bf:	inc    DWORD PTR [rsp-0x3c]
  4699c3:	jmp    468fa0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1b0>
  4699c8:	inc    DWORD PTR [rsp-0x3c]
  4699cc:	vpxor  xmm15,xmm15,xmm15
  4699d1:	xor    r11d,r11d
  4699d4:	vpxor  xmm12,xmm12,xmm12
  4699d9:	jmp    468f23 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  4699de:	inc    DWORD PTR [rsp-0x3c]
  4699e2:	mov    QWORD PTR [rsp-0x18],rdx
  4699e7:	jmp    469023 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x233>
