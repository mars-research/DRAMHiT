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
  468e1b:	mov    r9,QWORD PTR [rsi+0x8]
  468e1f:	mov    r10d,DWORD PTR [rdi+0xb0]
  468e26:	mov    eax,DWORD PTR [rdi+0xb4]
  468e2c:	mov    rdx,QWORD PTR [rsi]
  468e2f:	mov    edi,DWORD PTR [rdi+0x78]
  468e32:	mov    r11d,DWORD PTR [rcx+0x6c]
  468e36:	mov    r8,r9
  468e39:	mov    esi,r10d
  468e3c:	shl    r8,0x4
  468e40:	sub    esi,eax
  468e42:	lea    rbx,[rdx+r8*1]
  468e46:	and    esi,edi
  468e48:	lea    r12d,[r11-0x1]
  468e4c:	mov    QWORD PTR [rsp-0x20],rbx
  468e51:	cmp    esi,r12d
  468e54:	jb     469752 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x952>
  468e5a:	mov    r14,QWORD PTR [r15+0x8]
  468e5e:	and    r9,0xfffffffffffffffc
  468e62:	shl    r11,0x4
  468e66:	shl    r9,0x4
  468e6a:	mov    QWORD PTR [rsp],r14
  468e6e:	mov    r14,QWORD PTR [rcx+0x80]
  468e75:	mov    QWORD PTR [rsp-0x28],r11
  468e7a:	lea    rdi,[r11-0x1]
  468e7e:	shl    r10,0x4
  468e82:	lea    r11,[rdx+r9*1]
  468e86:	mov    DWORD PTR [rsp-0x18],r14d
  468e8b:	mov    QWORD PTR [rsp-0x58],r9
  468e90:	mov    QWORD PTR [rsp-0x30],r11
  468e95:	mov    DWORD PTR [rsp-0x4c],0x0
  468e9d:	mov    r8,QWORD PTR [rcx+0xa0]
  468ea4:	mov    rsi,QWORD PTR [rip+0x29d3d]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468eab:	shl    rax,0x4
  468eaf:	mov    r13,r10
  468eb2:	not    r14d
  468eb5:	cmp    rdx,r11
  468eb8:	je     4699ea <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbea>
  468ebe:	mov    ebx,0x55
  468ec3:	mov    r9d,0xf
  468ec9:	mov    r10d,0xf0
  468ecf:	mov    r11d,0xf00
  468ed5:	kmovb  k1,ebx
  468ed9:	mov    ebx,0xfffff000
  468ede:	mov    QWORD PTR [rsp-0x60],rcx
  468ee3:	mov    QWORD PTR [rsp-0x68],r15
  468ee8:	vpxor  xmm4,xmm4,xmm4
  468eec:	mov    r12d,0xffffffff
  468ef2:	kmovw  k5,r9d
  468ef7:	kmovw  k4,r10d
  468efc:	kmovw  k3,r11d
  468f01:	kmovw  k2,ebx
  468f05:	jmp    4691a2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3a2>
  468f0a:	nop    WORD PTR [rax+rax*1+0x0]
  468f10:	vmovd  xmm13,DWORD PTR [rbx+0xc]
  468f15:	kshiftlb k6,k6,0x1
  468f1b:	vpcompressq zmm12{k6}{z},zmm8
  468f21:	vpunpcklqdq xmm14,xmm13,xmm12
  468f26:	vshufi32x4 zmm15{k5}{z},zmm14,zmm14,0x0
  468f2d:	vmovdqa64 zmm12,zmm15
  468f33:	mov    ecx,0x1
  468f38:	lea    rbx,[r8+rax*1]
  468f3c:	lea    r11,[rax+0x180]
  468f43:	and    r11,rdi
  468f46:	mov    r10d,DWORD PTR [rbx+0x8]
  468f4a:	andn   r15d,r14d,DWORD PTR [r8+r11*1+0x8]
  468f51:	andn   r11d,r14d,r10d
  468f56:	mov    r9d,r15d
  468f59:	mov    r15d,r11d
  468f5c:	shl    r15,0x4
  468f60:	vmovdqa64 zmm0,ZMMWORD PTR [rsi+r15*1]
  468f67:	vpbroadcastq zmm2,QWORD PTR [rbx]
  468f6d:	vpcmpequq k0{k1},zmm0,zmm2
  468f74:	shl    r9,0x4
  468f78:	add    rax,0x10
  468f7c:	and    rax,rdi
  468f7f:	prefetcht0 BYTE PTR [rsi+r9*1]
  468f84:	kortestb k0,k0
  468f88:	je     469638 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x838>
  468f8e:	vmovd  xmm1,DWORD PTR [rbx+0xc]
  468f93:	kshiftlb k6,k0,0x1
  468f99:	vpcompressq zmm6{k6}{z},zmm0
  468f9f:	vpunpcklqdq xmm7,xmm1,xmm6
  468fa3:	vshufi32x4 zmm15{k4},zmm7,zmm7,0x0
  468faa:	vmovdqa64 zmm12,zmm15
  468fb0:	or     ecx,0x2
  468fb3:	lea    rbx,[r8+rax*1]
  468fb7:	lea    r15,[rax+0x180]
  468fbe:	and    r15,rdi
  468fc1:	mov    r11d,DWORD PTR [rbx+0x8]
  468fc5:	andn   r9d,r14d,DWORD PTR [r8+r15*1+0x8]
  468fcc:	andn   r15d,r14d,r11d
  468fd1:	mov    r10d,r9d
  468fd4:	mov    r9d,r15d
  468fd7:	shl    r9,0x4
  468fdb:	vmovdqa64 zmm8,ZMMWORD PTR [rsi+r9*1]
  468fe2:	vpbroadcastq zmm9,QWORD PTR [rbx]
  468fe8:	vpcmpequq k0{k1},zmm8,zmm9
  468fef:	shl    r10,0x4
  468ff3:	add    rax,0x10
  468ff7:	and    rax,rdi
  468ffa:	prefetcht0 BYTE PTR [rsi+r10*1]
  468fff:	kortestb k0,k0
  469003:	je     4695e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7e0>
  469009:	vmovd  xmm13,DWORD PTR [rbx+0xc]
  46900e:	kshiftlb k6,k0,0x1
  469014:	vpcompressq zmm12{k6}{z},zmm8
  46901a:	vpunpcklqdq xmm14,xmm13,xmm12
  46901f:	vshufi32x4 zmm15{k3},zmm14,zmm14,0x0
  469026:	vmovdqa64 zmm12,zmm15
  46902c:	or     ecx,0x4
  46902f:	lea    rbx,[r8+rax*1]
  469033:	lea    r9,[rax+0x180]
  46903a:	and    r9,rdi
  46903d:	mov    r15d,DWORD PTR [rbx+0x8]
  469041:	andn   r10d,r14d,DWORD PTR [r8+r9*1+0x8]
  469048:	andn   r9d,r14d,r15d
  46904d:	mov    r11d,r10d
  469050:	mov    r10d,r9d
  469053:	shl    r10,0x4
  469057:	vmovdqa64 zmm0,ZMMWORD PTR [rsi+r10*1]
  46905e:	vpbroadcastq zmm2,QWORD PTR [rbx]
  469064:	vpcmpequq k0{k1},zmm0,zmm2
  46906b:	shl    r11,0x4
  46906f:	add    rax,0x10
  469073:	and    rax,rdi
  469076:	prefetcht0 BYTE PTR [rsi+r11*1]
  46907b:	kortestb k0,k0
  46907f:	je     469588 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x788>
  469085:	vmovd  xmm1,DWORD PTR [rbx+0xc]
  46908a:	kshiftlb k6,k0,0x1
  469090:	vpcompressq zmm6{k6}{z},zmm0
  469096:	vpunpcklqdq xmm7,xmm1,xmm6
  46909a:	vshufi32x4 zmm15{k2},zmm7,zmm7,0x0
  4690a1:	or     ecx,0x8
  4690a4:	vmovdqa64 zmm12,zmm15
  4690aa:	cmp    ecx,0xf
  4690ad:	jne    469720 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x920>
  4690b3:	mov    r15,QWORD PTR [rsp]
  4690b7:	vmovdqu64 ZMMWORD PTR [r15],zmm15
  4690bd:	add    r15,0x40
  4690c1:	mov    QWORD PTR [rsp],r15
  4690c5:	mov    r10,QWORD PTR [rdx]
  4690c8:	mov    r15,r12
  4690cb:	mov    r11,QWORD PTR [rdx+0x10]
  4690cf:	crc32  r15,r10
  4690d5:	mov    QWORD PTR [rsp-0x38],r10
  4690da:	mov    r10d,DWORD PTR [rsp-0x18]
  4690df:	mov    rcx,r12
  4690e2:	crc32  rcx,r11
  4690e8:	mov    ebx,r10d
  4690eb:	mov    r9d,r10d
  4690ee:	and    ebx,ecx
  4690f0:	shl    rbx,0x4
  4690f4:	and    r9d,r15d
  4690f7:	shl    r9,0x4
  4690fb:	prefetcht2 BYTE PTR [rsi+rbx*1]
  4690ff:	mov    rbx,QWORD PTR [rdx+0x20]
  469103:	prefetcht2 BYTE PTR [rsi+r9*1]
  469108:	mov    r9,r12
  46910b:	crc32  r9,rbx
  469111:	mov    QWORD PTR [rsp-0x40],r11
  469116:	mov    r11d,r9d
  469119:	and    r11d,r10d
  46911c:	shl    r11,0x4
  469120:	prefetcht2 BYTE PTR [rsi+r11*1]
  469125:	mov    r11,QWORD PTR [rdx+0x30]
  469129:	vmovq  xmm15,r9
  46912e:	mov    r9,r12
  469131:	crc32  r9,r11
  469137:	and    r10d,r9d
  46913a:	mov    QWORD PTR [rsp-0x48],r11
  46913f:	mov    r11,r10
  469142:	shl    r11,0x4
  469146:	lea    r10,[r13+0x40]
  46914a:	prefetcht2 BYTE PTR [rsi+r11*1]
  46914f:	cmp    QWORD PTR [rsp-0x28],r10
  469154:	jb     469690 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x890>
  46915a:	vmovd  xmm3,r15d
  46915f:	vmovdqu32 zmm1,ZMMWORD PTR [rdx]
  469165:	vpinsrd xmm2,xmm15,r9d,0x1
  46916b:	vpinsrd xmm5,xmm3,ecx,0x1
  469171:	vpunpcklqdq xmm6,xmm5,xmm2
  469175:	mov    r9d,0x4444
  46917b:	kmovw  k6,r9d
  469180:	vpexpandd zmm1{k6},zmm6
  469186:	vmovdqu64 ZMMWORD PTR [r8+r13*1],zmm1
  46918d:	and    r10,rdi
  469190:	add    rdx,0x40
  469194:	mov    r13,r10
  469197:	cmp    QWORD PTR [rsp-0x30],rdx
  46919c:	je     469250 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x450>
  4691a2:	lea    rbx,[r8+rax*1]
  4691a6:	lea    rcx,[rax+0x180]
  4691ad:	and    rcx,rdi
  4691b0:	mov    r10d,DWORD PTR [rbx+0x8]
  4691b4:	andn   r15d,r14d,DWORD PTR [r8+rcx*1+0x8]
  4691bb:	andn   r11d,r14d,r10d
  4691c0:	mov    ecx,r11d
  4691c3:	shl    rcx,0x4
  4691c7:	vmovdqa64 zmm8,ZMMWORD PTR [rsi+rcx*1]
  4691ce:	vpbroadcastq zmm9,QWORD PTR [rbx]
  4691d4:	vpcmpequq k6{k1},zmm8,zmm9
  4691db:	mov    r9d,r15d
  4691de:	shl    r9,0x4
  4691e2:	add    rax,0x10
  4691e6:	and    rax,rdi
  4691e9:	prefetcht0 BYTE PTR [rsi+r9*1]
  4691ee:	kortestb k6,k6
  4691f2:	jne    468f10 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x110>
  4691f8:	vpcmpequq k7{k1},zmm8,zmm4
  4691ff:	kortestb k7,k7
  469203:	jne    469a13 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xc13>
  469209:	mov    r15,r12
  46920c:	crc32  r15,r10
  469212:	mov    r9d,DWORD PTR [rsp-0x18]
  469217:	vmovd  xmm10,r15d
  46921c:	vpinsrd xmm11,xmm10,DWORD PTR [rbx+0xc],0x1
  469223:	and    r9d,r15d
  469226:	mov    rbx,QWORD PTR [rbx]
  469229:	lea    r10,[r8+r13*1]
  46922d:	shl    r9,0x4
  469231:	lea    r13,[r13+0x10]
  469235:	prefetcht2 BYTE PTR [rsi+r9*1]
  46923a:	and    r13,rdi
  46923d:	mov    QWORD PTR [r10],rbx
  469240:	vmovq  QWORD PTR [r10+0x8],xmm11
  469246:	jmp    4691a2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3a2>
  46924b:	nop    DWORD PTR [rax+rax*1+0x0]
  469250:	mov    rcx,QWORD PTR [rsp-0x60]
  469255:	mov    r15,QWORD PTR [rsp-0x68]
  46925a:	mov    edi,DWORD PTR [rsp-0x4c]
  46925e:	vmovq  xmm7,r13
  469263:	vpinsrq xmm12,xmm7,rax,0x1
  469269:	mov    rsi,QWORD PTR [rsp-0x58]
  46926e:	vpsrlq xmm4,xmm12,0x4
  469274:	vpmovqd xmm15,xmm4
  46927a:	sar    rsi,0x4
  46927e:	vmovq  QWORD PTR [rcx+0xb0],xmm15
  469286:	sub    rsi,rdi
  469289:	add    DWORD PTR [r15],esi
  46928c:	vpextrd eax,xmm15,0x1
  469292:	cmp    rdx,QWORD PTR [rsp-0x20]
  469297:	je     469570 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x770>
  46929d:	mov    rdi,QWORD PTR [rcx+0x88]
  4692a4:	mov    rbx,QWORD PTR [rcx+0x80]
  4692ab:	mov    r8,QWORD PTR [rcx+0x60]
  4692af:	dec    rdi
  4692b2:	mov    QWORD PTR [rsp-0x18],rbx
  4692b7:	mov    QWORD PTR [rsp],r8
  4692bb:	mov    QWORD PTR [rsp-0x28],rdi
  4692c0:	mov    r10d,DWORD PTR [rcx+0x78]
  4692c4:	mov    r11,QWORD PTR [rip+0x2991d]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4692cb:	mov    r9,QWORD PTR [rcx+0xa0]
  4692d2:	movzx  r13d,BYTE PTR [rip+0x29826]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4692da:	mov    r12,QWORD PTR [rip+0x29827]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4692e1:	mov    r14d,0x55
  4692e7:	vpxor  xmm8,xmm8,xmm8
  4692ec:	kmovb  k1,r14d
  4692f1:	nop    DWORD PTR [rax+0x0]
  4692f8:	lea    esi,[rax+0x18]
  4692fb:	and    esi,r10d
  4692fe:	shl    rsi,0x4
  469302:	mov    r8d,ebx
  469305:	and    r8d,DWORD PTR [r9+rsi*1+0x8]
  46930a:	mov    esi,eax
  46930c:	shl    rsi,0x4
  469310:	add    rsi,r9
  469313:	mov    r14,r8
  469316:	mov    r8,QWORD PTR [rsi]
  469319:	shl    r14,0x4
  46931d:	prefetcht0 BYTE PTR [r11+r14*1]
  469322:	cmp    r8,QWORD PTR [rcx+0x90]
  469329:	jne    4693e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5e0>
  46932f:	test   r13b,r13b
  469332:	je     469352 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x552>
  469334:	mov    r14d,DWORD PTR [r15]
  469337:	mov    esi,DWORD PTR [rsi+0xc]
  46933a:	mov    r8,r14
  46933d:	shl    r14,0x4
  469341:	add    r14,QWORD PTR [r15+0x8]
  469345:	inc    r8d
  469348:	mov    DWORD PTR [r14],esi
  46934b:	mov    QWORD PTR [r14+0x8],r12
  46934f:	mov    DWORD PTR [r15],r8d
  469352:	inc    eax
  469354:	and    eax,r10d
  469357:	mov    DWORD PTR [rcx+0xb4],eax
  46935d:	test   r12,r12
  469360:	jne    4692f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4f8>
  469362:	cmp    QWORD PTR [rsp],0x4
  469367:	je     4694d5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d5>
  46936d:	nop    DWORD PTR [rax]
  469370:	cmp    QWORD PTR [rsp],0x8
  469375:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x750>
  46937b:	vmovd  xmm0,DWORD PTR [rsp-0x10]
  469381:	mov    rdi,QWORD PTR [rdx]
  469384:	mov    esi,DWORD PTR [rcx+0xb0]
  46938a:	mov    r8,QWORD PTR [rsp-0x28]
  46938f:	mov    rax,rsi
  469392:	and    r8,QWORD PTR [rsp-0x10]
  469397:	vpinsrd xmm3,xmm0,DWORD PTR [rdx+0xc],0x1
  46939e:	and    r8,0xfffffffffffffffc
  4693a2:	shl    rsi,0x4
  4693a6:	inc    eax
  4693a8:	add    rsi,r9
  4693ab:	shl    r8,0x4
  4693af:	and    eax,r10d
  4693b2:	add    rdx,0x10
  4693b6:	prefetcht2 BYTE PTR [r11+r8*1]
  4693bb:	mov    QWORD PTR [rsi],rdi
  4693be:	vmovq  QWORD PTR [rsi+0x8],xmm3
  4693c3:	mov    DWORD PTR [rcx+0xb0],eax
  4693c9:	cmp    rdx,QWORD PTR [rsp-0x20]
  4693ce:	je     469570 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x770>
  4693d4:	mov    eax,DWORD PTR [rcx+0xb4]
  4693da:	jmp    4692f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4f8>
  4693df:	nop
  4693e0:	mov    r14d,DWORD PTR [rsi+0x8]
  4693e4:	mov    edi,ebx
  4693e6:	and    edi,r14d
  4693e9:	shl    rdi,0x4
  4693ed:	add    rdi,r11
  4693f0:	vmovdqa64 zmm9,ZMMWORD PTR [rdi]
  4693f6:	vpbroadcastq zmm10,r8
  4693fc:	vpcmpequq k0{k1},zmm9,zmm10
  469403:	kortestb k0,k0
  469407:	jne    469490 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x690>
  46940d:	vpcmpequq k2{k1},zmm9,zmm8
  469414:	kortestb k2,k2
  469418:	jne    469500 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
  46941e:	cmp    QWORD PTR [rsp],0x4
  469423:	mov    edi,r14d
  469426:	je     469510 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x710>
  46942c:	cmp    QWORD PTR [rsp],0x8
  469431:	je     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x730>
  469437:	vmovd  xmm11,DWORD PTR [rsp-0x8]
  46943d:	mov    edi,DWORD PTR [rcx+0xb0]
  469443:	mov    r14,QWORD PTR [rsp-0x18]
  469448:	vpinsrd xmm14,xmm11,DWORD PTR [rsi+0xc],0x1
  46944f:	mov    rsi,rdi
  469452:	and    r14,QWORD PTR [rsp-0x8]
  469457:	shl    rdi,0x4
  46945b:	inc    esi
  46945d:	inc    eax
  46945f:	add    rdi,r9
  469462:	shl    r14,0x4
  469466:	and    esi,r10d
  469469:	and    eax,r10d
  46946c:	prefetcht2 BYTE PTR [r11+r14*1]
  469471:	mov    QWORD PTR [rdi],r8
  469474:	vmovq  QWORD PTR [rdi+0x8],xmm14
  469479:	mov    DWORD PTR [rcx+0xb0],esi
  46947f:	mov    DWORD PTR [rcx+0xb4],eax
  469485:	jmp    4692f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4f8>
  46948a:	nop    WORD PTR [rax+rax*1+0x0]
  469490:	mov    r8d,DWORD PTR [r15]
  469493:	mov    esi,DWORD PTR [rsi+0xc]
  469496:	mov    r14,r8
  469499:	shl    r8,0x4
  46949d:	add    r8,QWORD PTR [r15+0x8]
  4694a1:	mov    DWORD PTR [r8],esi
  4694a4:	kmovb  esi,k0
  4694a8:	tzcnt  esi,esi
  4694ac:	inc    esi
  4694ae:	movsxd rsi,esi
  4694b1:	mov    rdi,QWORD PTR [rdi+rsi*8]
  4694b5:	inc    eax
  4694b7:	inc    r14d
  4694ba:	and    eax,r10d
  4694bd:	cmp    QWORD PTR [rsp],0x4
  4694c2:	mov    QWORD PTR [r8+0x8],rdi
  4694c6:	mov    DWORD PTR [r15],r14d
  4694c9:	mov    DWORD PTR [rcx+0xb4],eax
  4694cf:	jne    469370 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x570>
  4694d5:	mov    r14d,0xffffffff
  4694db:	crc32  r14d,DWORD PTR [rdx]
  4694e1:	vmovd  xmm2,r14d
  4694e6:	mov    rdi,QWORD PTR [rdx]
  4694e9:	vmovdqa xmm0,xmm2
  4694ed:	vmovq  QWORD PTR [rsp-0x10],xmm2
  4694f3:	jmp    469384 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x584>
  4694f8:	nop    DWORD PTR [rax+rax*1+0x0]
  469500:	inc    eax
  469502:	and    eax,r10d
  469505:	mov    DWORD PTR [rcx+0xb4],eax
  46950b:	jmp    469362 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x562>
  469510:	mov    edi,0xffffffff
  469515:	crc32  edi,r14d
  46951b:	vmovd  xmm13,edi
  46951f:	vmovdqa xmm11,xmm13
  469524:	vmovq  QWORD PTR [rsp-0x8],xmm13
  46952a:	jmp    46943d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x63d>
  46952f:	nop
  469530:	mov    r14d,0xffffffff
  469536:	crc32  r14,rdi
  46953c:	mov    QWORD PTR [rsp-0x8],r14
  469541:	vmovd  xmm11,r14d
  469546:	jmp    46943d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x63d>
  46954b:	nop    DWORD PTR [rax+rax*1+0x0]
  469550:	mov    rdi,QWORD PTR [rdx]
  469553:	mov    eax,0xffffffff
  469558:	crc32  rax,rdi
  46955e:	mov    QWORD PTR [rsp-0x10],rax
  469563:	vmovd  xmm0,eax
  469567:	jmp    469384 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x584>
  46956c:	nop    DWORD PTR [rax+0x0]
  469570:	vzeroupper 
  469573:	lea    rsp,[rbp-0x28]
  469577:	pop    rbx
  469578:	pop    r12
  46957a:	pop    r13
  46957c:	pop    r14
  46957e:	pop    r15
  469580:	pop    rbp
  469581:	ret    
  469582:	nop    WORD PTR [rax+rax*1+0x0]
  469588:	vpcmpequq k7{k1},zmm0,zmm4
  46958f:	kortestb k7,k7
  469593:	jne    46971a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x91a>
  469599:	mov    r9,r12
  46959c:	crc32  r9,r15
  4695a2:	mov    r11d,DWORD PTR [rsp-0x18]
  4695a7:	vmovd  xmm3,r9d
  4695ac:	vpinsrd xmm5,xmm3,DWORD PTR [rbx+0xc],0x1
  4695b3:	and    r11d,r9d
  4695b6:	mov    rbx,QWORD PTR [rbx]
  4695b9:	lea    r15,[r8+r13*1]
  4695bd:	shl    r11,0x4
  4695c1:	add    r13,0x10
  4695c5:	prefetcht2 BYTE PTR [rsi+r11*1]
  4695ca:	and    r13,rdi
  4695cd:	mov    QWORD PTR [r15],rbx
  4695d0:	vmovq  QWORD PTR [r15+0x8],xmm5
  4695d6:	jmp    46902f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x22f>
  4695db:	nop    DWORD PTR [rax+rax*1+0x0]
  4695e0:	vpcmpequq k7{k1},zmm8,zmm4
  4695e7:	kortestb k7,k7
  4695eb:	jne    469a28 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xc28>
  4695f1:	mov    r10,r12
  4695f4:	crc32  r10,r11
  4695fa:	mov    r11d,DWORD PTR [rsp-0x18]
  4695ff:	vmovd  xmm10,r10d
  469604:	vpinsrd xmm11,xmm10,DWORD PTR [rbx+0xc],0x1
  46960b:	and    r11d,r10d
  46960e:	mov    rbx,QWORD PTR [rbx]
  469611:	lea    r15,[r8+r13*1]
  469615:	shl    r11,0x4
  469619:	add    r13,0x10
  46961d:	prefetcht2 BYTE PTR [rsi+r11*1]
  469622:	and    r13,rdi
  469625:	mov    QWORD PTR [r15],rbx
  469628:	vmovq  QWORD PTR [r15+0x8],xmm11
  46962e:	jmp    468fb3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1b3>
  469633:	nop    DWORD PTR [rax+rax*1+0x0]
  469638:	vpcmpequq k7{k1},zmm0,zmm4
  46963f:	kortestb k7,k7
  469643:	jne    469a0a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xc0a>
  469649:	mov    r9,r12
  46964c:	crc32  r9,r10
  469652:	mov    r10d,DWORD PTR [rsp-0x18]
  469657:	vmovd  xmm3,r9d
  46965c:	vpinsrd xmm5,xmm3,DWORD PTR [rbx+0xc],0x1
  469663:	and    r10d,r9d
  469666:	mov    rbx,QWORD PTR [rbx]
  469669:	lea    r11,[r8+r13*1]
  46966d:	shl    r10,0x4
  469671:	add    r13,0x10
  469675:	prefetcht2 BYTE PTR [rsi+r10*1]
  46967a:	and    r13,rdi
  46967d:	mov    QWORD PTR [r11],rbx
  469680:	vmovq  QWORD PTR [r11+0x8],xmm5
  469686:	jmp    468f38 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x138>
  46968b:	nop    DWORD PTR [rax+rax*1+0x0]
  469690:	vmovd  xmm8,r15d
  469695:	mov    r15,rdi
  469698:	vpinsrd xmm9,xmm8,DWORD PTR [rdx+0xc],0x1
  46969f:	mov    r11,QWORD PTR [rsp-0x38]
  4696a4:	and    r15,r13
  4696a7:	add    r15,r8
  4696aa:	vmovq  QWORD PTR [r15+0x8],xmm9
  4696b0:	mov    QWORD PTR [r15],r11
  4696b3:	vmovd  xmm10,ecx
  4696b7:	lea    r15,[r13+0x10]
  4696bb:	vpinsrd xmm11,xmm10,DWORD PTR [rdx+0x1c],0x1
  4696c2:	and    r15,rdi
  4696c5:	add    r15,r8
  4696c8:	vmovq  QWORD PTR [r15+0x8],xmm11
  4696ce:	lea    r11,[r13+0x20]
  4696d2:	vpinsrd xmm13,xmm15,DWORD PTR [rdx+0x2c],0x1
  4696d9:	mov    rcx,QWORD PTR [rsp-0x40]
  4696de:	and    r11,rdi
  4696e1:	add    r11,r8
  4696e4:	mov    QWORD PTR [r15],rcx
  4696e7:	vmovd  xmm14,r9d
  4696ec:	vmovq  QWORD PTR [r11+0x8],xmm13
  4696f2:	lea    r13,[r13+0x30]
  4696f6:	mov    QWORD PTR [r11],rbx
  4696f9:	vpinsrd xmm0,xmm14,DWORD PTR [rdx+0x3c],0x1
  469700:	mov    rbx,QWORD PTR [rsp-0x48]
  469705:	and    r13,rdi
  469708:	add    r13,r8
  46970b:	mov    QWORD PTR [r13+0x0],rbx
  46970f:	vmovq  QWORD PTR [r13+0x8],xmm0
  469715:	jmp    46918d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x38d>
  46971a:	inc    DWORD PTR [rsp-0x4c]
  46971e:	xchg   ax,ax
  469720:	mov    rbx,QWORD PTR [rsp]
  469724:	mov    r10d,0x55
  46972a:	pdep   r9d,ecx,r10d
  46972f:	popcnt ecx,ecx
  469733:	lea    r11d,[r9+r9*2]
  469737:	shl    rcx,0x4
  46973b:	kmovb  k7,r11d
  469740:	vpcompressq ZMMWORD PTR [rbx]{k7},zmm12
  469746:	add    rbx,rcx
  469749:	mov    QWORD PTR [rsp],rbx
  46974d:	jmp    4690c5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2c5>
  469752:	cmp    rdx,QWORD PTR [rsp-0x20]
  469757:	je     469573 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x773>
  46975d:	mov    r12,QWORD PTR [rcx+0x88]
  469764:	movzx  r13d,BYTE PTR [rip+0x29394]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  46976c:	mov    r9,QWORD PTR [rip+0x29395]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469773:	mov    r8,QWORD PTR [rcx+0x60]
  469777:	mov    ebx,0x55
  46977c:	dec    r12
  46977f:	kmovb  k2,r13d
  469784:	mov    QWORD PTR [rsp],r8
  469788:	mov    QWORD PTR [rsp-0x8],r12
  46978d:	mov    r14,QWORD PTR [rip+0x29454]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469794:	mov    r11,QWORD PTR [rcx+0xa0]
  46979b:	mov    esi,r10d
  46979e:	vpxor  xmm2,xmm2,xmm2
  4697a2:	mov    r13,r9
  4697a5:	kmovb  k1,ebx
  4697a9:	jmp    469813 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa13>
  4697ab:	cmp    QWORD PTR [rsp],0x8
  4697b0:	je     4699b8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbb8>
  4697b6:	vmovd  xmm5,DWORD PTR [rsp-0x18]
  4697bc:	mov    r12,QWORD PTR [rsp-0x8]
  4697c1:	mov    esi,r10d
  4697c4:	and    r12,QWORD PTR [rsp-0x18]
  4697c9:	vpinsrd xmm7,xmm5,DWORD PTR [rdx+0xc],0x1
  4697d0:	mov    r9,QWORD PTR [rdx]
  4697d3:	and    r12,0xfffffffffffffffc
  4697d7:	shl    rsi,0x4
  4697db:	add    rsi,r11
  4697de:	shl    r12,0x4
  4697e2:	prefetcht2 BYTE PTR [r14+r12*1]
  4697e7:	mov    QWORD PTR [rsi],r9
  4697ea:	vmovq  QWORD PTR [rsi+0x8],xmm7
  4697ef:	lea    esi,[r10+0x1]
  4697f3:	and    esi,edi
  4697f5:	add    rdx,0x10
  4697f9:	mov    DWORD PTR [rcx+0xb0],esi
  4697ff:	cmp    QWORD PTR [rsp-0x20],rdx
  469804:	je     469570 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x770>
  46980a:	mov    eax,DWORD PTR [rcx+0xb4]
  469810:	mov    r10d,esi
  469813:	sub    esi,eax
  469815:	and    esi,edi
  469817:	cmp    edi,esi
  469819:	jbe    46983c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa3c>
  46981b:	cmp    QWORD PTR [rsp],0x4
  469820:	jne    4697ab <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9ab>
  469822:	mov    ebx,0xffffffff
  469827:	crc32  ebx,DWORD PTR [rdx]
  46982c:	vmovd  xmm6,ebx
  469830:	vmovdqa xmm5,xmm6
  469834:	vmovq  QWORD PTR [rsp-0x18],xmm6
  46983a:	jmp    4697bc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9bc>
  46983c:	mov    rbx,QWORD PTR [rcx+0x80]
  469843:	mov    QWORD PTR [rsp-0x10],rbx
  469848:	nop    DWORD PTR [rax+rax*1+0x0]
  469850:	lea    esi,[rax+0x18]
  469853:	and    esi,edi
  469855:	shl    rsi,0x4
  469859:	mov    r9d,ebx
  46985c:	and    r9d,DWORD PTR [r11+rsi*1+0x8]
  469861:	mov    esi,eax
  469863:	shl    rsi,0x4
  469867:	add    rsi,r11
  46986a:	mov    r8,r9
  46986d:	mov    r9,QWORD PTR [rsi]
  469870:	shl    r8,0x4
  469874:	prefetcht0 BYTE PTR [r14+r8*1]
  469879:	cmp    r9,QWORD PTR [rcx+0x90]
  469880:	jne    4698c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xac0>
  469882:	kortestb k2,k2
  469886:	je     4698a9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaa9>
  469888:	mov    r12d,DWORD PTR [r15]
  46988b:	mov    esi,DWORD PTR [rsi+0xc]
  46988e:	mov    r9,r12
  469891:	shl    r12,0x4
  469895:	add    r12,QWORD PTR [r15+0x8]
  469899:	lea    r8d,[r9+0x1]
  46989d:	mov    DWORD PTR [r12],esi
  4698a1:	mov    QWORD PTR [r12+0x8],r13
  4698a6:	mov    DWORD PTR [r15],r8d
  4698a9:	inc    eax
  4698ab:	and    eax,edi
  4698ad:	mov    DWORD PTR [rcx+0xb4],eax
  4698b3:	test   r13,r13
  4698b6:	jne    469850 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa50>
  4698b8:	jmp    46981b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa1b>
  4698bd:	nop    DWORD PTR [rax]
  4698c0:	mov    r12d,DWORD PTR [rsi+0x8]
  4698c4:	mov    r8d,ebx
  4698c7:	and    r8d,r12d
  4698ca:	shl    r8,0x4
  4698ce:	add    r8,r14
  4698d1:	vmovdqa64 zmm0,ZMMWORD PTR [r8]
  4698d7:	vpbroadcastq zmm1,r9
  4698dd:	vpcmpequq k0{k1},zmm0,zmm1
  4698e4:	kortestb k0,k0
  4698e8:	jne    469966 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb66>
  4698ea:	vpcmpequq k3{k1},zmm0,zmm2
  4698f1:	kortestb k3,k3
  4698f5:	jne    4699a9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xba9>
  4698fb:	cmp    QWORD PTR [rsp],0x4
  469900:	mov    r8d,r12d
  469903:	je     4699d1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbd1>
  469909:	cmp    QWORD PTR [rsp],0x8
  46990e:	je     4699f1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbf1>
  469914:	mov    r8d,DWORD PTR [rsp-0x28]
  469919:	mov    r12,QWORD PTR [rsp-0x10]
  46991e:	vmovd  xmm4,r8d
  469923:	vpinsrd xmm3,xmm4,DWORD PTR [rsi+0xc],0x1
  46992a:	mov    esi,r10d
  46992d:	and    r12,QWORD PTR [rsp-0x28]
  469932:	shl    rsi,0x4
  469936:	inc    r10d
  469939:	inc    eax
  46993b:	add    rsi,r11
  46993e:	shl    r12,0x4
  469942:	and    r10d,edi
  469945:	and    eax,edi
  469947:	prefetcht2 BYTE PTR [r14+r12*1]
  46994c:	mov    QWORD PTR [rsi],r9
  46994f:	vmovq  QWORD PTR [rsi+0x8],xmm3
  469954:	mov    DWORD PTR [rcx+0xb0],r10d
  46995b:	mov    DWORD PTR [rcx+0xb4],eax
  469961:	jmp    469850 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa50>
  469966:	mov    r9d,DWORD PTR [r15]
  469969:	mov    r12d,DWORD PTR [rsi+0xc]
  46996d:	mov    rbx,r9
  469970:	shl    r9,0x4
  469974:	add    r9,QWORD PTR [r15+0x8]
  469978:	mov    DWORD PTR [r9],r12d
  46997b:	xor    r12d,r12d
  46997e:	kmovb  esi,k0
  469982:	tzcnt  r12d,esi
  469987:	inc    r12d
  46998a:	movsxd rsi,r12d
  46998d:	mov    r8,QWORD PTR [r8+rsi*8]
  469991:	inc    eax
  469993:	inc    ebx
  469995:	and    eax,edi
  469997:	mov    QWORD PTR [r9+0x8],r8
  46999b:	mov    DWORD PTR [r15],ebx
  46999e:	mov    DWORD PTR [rcx+0xb4],eax
  4699a4:	jmp    46981b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa1b>
  4699a9:	inc    eax
  4699ab:	and    eax,edi
  4699ad:	mov    DWORD PTR [rcx+0xb4],eax
  4699b3:	jmp    46981b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa1b>
  4699b8:	mov    eax,0xffffffff
  4699bd:	crc32  rax,QWORD PTR [rdx]
  4699c3:	mov    QWORD PTR [rsp-0x18],rax
  4699c8:	vmovd  xmm5,eax
  4699cc:	jmp    4697bc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9bc>
  4699d1:	mov    r8d,0xffffffff
  4699d7:	crc32  r8d,r12d
  4699dd:	mov    r12d,r8d
  4699e0:	mov    QWORD PTR [rsp-0x28],r12
  4699e5:	jmp    469919 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb19>
  4699ea:	xor    edi,edi
  4699ec:	jmp    46925e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x45e>
  4699f1:	mov    r12d,0xffffffff
  4699f7:	crc32  r12,r8
  4699fd:	mov    QWORD PTR [rsp-0x28],r12
  469a02:	mov    r8d,r12d
  469a05:	jmp    469919 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb19>
  469a0a:	inc    DWORD PTR [rsp-0x4c]
  469a0e:	jmp    468fb3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1b3>
  469a13:	inc    DWORD PTR [rsp-0x4c]
  469a17:	vpxor  xmm15,xmm15,xmm15
  469a1c:	xor    ecx,ecx
  469a1e:	vpxor  xmm12,xmm12,xmm12
  469a23:	jmp    468f38 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x138>
  469a28:	inc    DWORD PTR [rsp-0x4c]
  469a2c:	jmp    46902f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x22f>
