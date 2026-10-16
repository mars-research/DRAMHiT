0000000000468d90 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468d90:	push   rbp
  468d91:	mov    rcx,rdi
  468d94:	mov    rbp,rsp
  468d97:	push   r15
  468d99:	mov    r15,rdx
  468d9c:	push   r14
  468d9e:	push   r13
  468da0:	push   r12
  468da2:	push   rbx
  468da3:	and    rsp,0xffffffffffffffc0
  468da7:	sub    rsp,0x8
  468dab:	mov    r11,QWORD PTR [rsi+0x8]
  468daf:	mov    edi,DWORD PTR [rdi+0xc0]
  468db5:	mov    eax,DWORD PTR [rcx+0xc4]
  468dbb:	mov    rdx,QWORD PTR [rsi]
  468dbe:	mov    r8d,DWORD PTR [rcx+0x78]
  468dc2:	mov    r9d,DWORD PTR [rcx+0x6c]
  468dc6:	mov    r10,r11
  468dc9:	mov    esi,edi
  468dcb:	shl    r10,0x4
  468dcf:	sub    esi,eax
  468dd1:	lea    rbx,[rdx+r10*1]
  468dd5:	and    esi,r8d
  468dd8:	lea    r12d,[r9-0x1]
  468ddc:	mov    QWORD PTR [rsp-0x20],rbx
  468de1:	cmp    esi,r12d
  468de4:	jb     4695af <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x81f>
  468dea:	and    r11,0xfffffffffffffffc
  468dee:	shl    r11,0x4
  468df2:	mov    esi,DWORD PTR [rcx+0x80]
  468df8:	shl    r9,0x4
  468dfc:	shl    rdi,0x4
  468e00:	mov    QWORD PTR [rsp-0x30],r11
  468e05:	lea    r11,[rdx+r11*1]
  468e09:	mov    QWORD PTR [rsp],r9
  468e0d:	lea    r10,[r9-0x1]
  468e11:	mov    r14,rdi
  468e14:	mov    QWORD PTR [rsp-0x18],r11
  468e19:	mov    DWORD PTR [rsp-0x28],0x0
  468e21:	mov    r8,QWORD PTR [rcx+0xa0]
  468e28:	mov    r9,QWORD PTR [r15+0x8]
  468e2c:	mov    rdi,QWORD PTR [rip+0x2bdbd]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468e33:	shl    rax,0x4
  468e37:	not    esi
  468e39:	cmp    rdx,r11
  468e3c:	je     46984a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaba>
  468e42:	mov    r13d,0x55
  468e48:	mov    ebx,0x4444
  468e4d:	mov    QWORD PTR [rsp-0x38],rcx
  468e52:	mov    QWORD PTR [rsp-0x40],r15
  468e57:	vpxor  xmm2,xmm2,xmm2
  468e5b:	kmovb  k2,r13d
  468e60:	kmovw  k3,ebx
  468e64:	jmp    46908d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2fd>
  468e69:	nop    DWORD PTR [rax+0x0]
  468e70:	vmovd  xmm13,DWORD PTR [r13+0xc]
  468e76:	kshiftlb k6,k4,0x1
  468e7c:	vpcompressq zmm12{k6}{z},zmm8
  468e82:	vpunpcklqdq xmm14,xmm13,xmm12
  468e87:	vmovdqu XMMWORD PTR [r9],xmm14
  468e8c:	add    r9,0x10
  468e90:	lea    r15,[r8+rax*1]
  468e94:	mov    r11d,DWORD PTR [r15+0x8]
  468e98:	andn   ebx,esi,r11d
  468e9d:	shl    rbx,0x4
  468ea1:	vmovdqa64 zmm15,ZMMWORD PTR [rdi+rbx*1]
  468ea8:	vpbroadcastq zmm0,QWORD PTR [r15]
  468eae:	vpcmpequq k7{k2},zmm15,zmm0
  468eb5:	lea    r12,[rax+0x180]
  468ebc:	add    rax,0x10
  468ec0:	and    r12,r10
  468ec3:	and    rax,r10
  468ec6:	andn   ecx,esi,DWORD PTR [r8+r12*1+0x8]
  468ecd:	shl    rcx,0x4
  468ed1:	kortestb k7,k7
  468ed5:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468ed9:	je     469500 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x770>
  468edf:	vmovd  xmm4,DWORD PTR [r15+0xc]
  468ee5:	kshiftlb k4,k7,0x1
  468eeb:	vpcompressq zmm3{k4}{z},zmm15
  468ef1:	vpunpcklqdq xmm6,xmm4,xmm3
  468ef5:	vmovdqu XMMWORD PTR [r9],xmm6
  468efa:	add    r9,0x10
  468efe:	lea    r12,[r8+rax*1]
  468f02:	mov    r11d,DWORD PTR [r12+0x8]
  468f07:	andn   ebx,esi,r11d
  468f0c:	shl    rbx,0x4
  468f10:	vmovdqa64 zmm5,ZMMWORD PTR [rdi+rbx*1]
  468f17:	vpbroadcastq zmm8,QWORD PTR [r12]
  468f1e:	vpcmpequq k0{k2},zmm5,zmm8
  468f25:	lea    r13,[rax+0x180]
  468f2c:	add    rax,0x10
  468f30:	and    r13,r10
  468f33:	and    rax,r10
  468f36:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  468f3d:	shl    rcx,0x4
  468f41:	kortestb k0,k0
  468f45:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468f49:	je     4694b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  468f4f:	vmovd  xmm12,DWORD PTR [r12+0xc]
  468f56:	kshiftlb k6,k0,0x1
  468f5c:	vpcompressq zmm11{k6}{z},zmm5
  468f62:	vpunpcklqdq xmm13,xmm12,xmm11
  468f67:	vmovdqu XMMWORD PTR [r9],xmm13
  468f6c:	add    r9,0x10
  468f70:	lea    r11,[r8+rax*1]
  468f74:	mov    ebx,DWORD PTR [r11+0x8]
  468f78:	andn   r13d,esi,ebx
  468f7d:	shl    r13,0x4
  468f81:	vmovdqa64 zmm14,ZMMWORD PTR [rdi+r13*1]
  468f88:	vpbroadcastq zmm15,QWORD PTR [r11]
  468f8e:	vpcmpequq k7{k2},zmm14,zmm15
  468f95:	lea    r15,[rax+0x180]
  468f9c:	add    rax,0x10
  468fa0:	and    r15,r10
  468fa3:	and    rax,r10
  468fa6:	andn   ecx,esi,DWORD PTR [r8+r15*1+0x8]
  468fad:	shl    rcx,0x4
  468fb1:	kortestb k7,k7
  468fb5:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468fb9:	lea    rcx,[r8+r14*1]
  468fbd:	je     469468 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d8>
  468fc3:	vmovd  xmm3,DWORD PTR [r11+0xc]
  468fc9:	kshiftlb k4,k7,0x1
  468fcf:	vpcompressq zmm7{k4}{z},zmm14
  468fd5:	vpunpcklqdq xmm4,xmm3,xmm7
  468fd9:	vmovdqu XMMWORD PTR [r9],xmm4
  468fde:	add    r9,0x10
  468fe2:	mov    r13d,0xffffffff
  468fe8:	crc32  r13,QWORD PTR [rdx]
  468fee:	andn   r11d,esi,r13d
  468ff3:	shl    r11,0x4
  468ff7:	prefetcht2 BYTE PTR [rdi+r11*1]
  468ffc:	mov    r11d,0xffffffff
  469002:	crc32  r11,QWORD PTR [rdx+0x10]
  469009:	mov    r15d,0xffffffff
  46900f:	andn   ebx,esi,r11d
  469014:	shl    rbx,0x4
  469018:	prefetcht2 BYTE PTR [rdi+rbx*1]
  46901c:	mov    ebx,0xffffffff
  469021:	crc32  r15,QWORD PTR [rdx+0x20]
  469028:	crc32  rbx,QWORD PTR [rdx+0x30]
  46902f:	andn   r12d,esi,r15d
  469034:	shl    r12,0x4
  469038:	prefetcht2 BYTE PTR [rdi+r12*1]
  46903d:	andn   r12d,esi,ebx
  469042:	shl    r12,0x4
  469046:	prefetcht2 BYTE PTR [rdi+r12*1]
  46904b:	lea    r12,[r14+0x40]
  46904f:	vmovdqu64 zmm6,ZMMWORD PTR [rdx]
  469055:	cmp    QWORD PTR [rsp],r12
  469059:	jb     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7c0>
  46905f:	vmovdqu64 ZMMWORD PTR [rcx],zmm6
  469065:	mov    DWORD PTR [rcx+0x8],r13d
  469069:	mov    DWORD PTR [r8+r14*1+0x18],r11d
  46906e:	mov    DWORD PTR [r8+r14*1+0x28],r15d
  469073:	mov    DWORD PTR [r8+r14*1+0x38],ebx
  469078:	mov    r14,r12
  46907b:	add    rdx,0x40
  46907f:	and    r14,r10
  469082:	cmp    QWORD PTR [rsp-0x18],rdx
  469087:	je     469130 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3a0>
  46908d:	lea    r13,[r8+rax*1]
  469091:	mov    r11d,DWORD PTR [r13+0x8]
  469095:	andn   ebx,esi,r11d
  46909a:	shl    rbx,0x4
  46909e:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+rbx*1]
  4690a5:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  4690ac:	vpcmpequq k4{k2},zmm8,zmm9
  4690b3:	lea    rcx,[rax+0x180]
  4690ba:	add    rax,0x10
  4690be:	and    rcx,r10
  4690c1:	and    rax,r10
  4690c4:	andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
  4690cb:	shl    r15,0x4
  4690cf:	kortestb k4,k4
  4690d3:	prefetcht0 BYTE PTR [rdi+r15*1]
  4690d8:	jne    468e70 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xe0>
  4690de:	vpcmpequq k5{k2},zmm8,zmm2
  4690e5:	kortestb k5,k5
  4690e9:	jne    469874 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xae4>
  4690ef:	vmovdqu xmm10,XMMWORD PTR [r13+0x0]
  4690f5:	mov    ecx,0xffffffff
  4690fa:	crc32  rcx,r11
  469100:	vpinsrd xmm11,xmm10,ecx,0x2
  469106:	andn   r15d,esi,ecx
  46910b:	shl    r15,0x4
  46910f:	prefetcht2 BYTE PTR [rdi+r15*1]
  469114:	vmovdqu XMMWORD PTR [r8+r14*1],xmm11
  46911a:	add    r14,0x10
  46911e:	and    r14,r10
  469121:	jmp    46908d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2fd>
  469126:	cs nop WORD PTR [rax+rax*1+0x0]
  469130:	mov    rcx,QWORD PTR [rsp-0x38]
  469135:	mov    r15,QWORD PTR [rsp-0x40]
  46913a:	mov    r12d,DWORD PTR [rsp-0x28]
  46913f:	vmovq  xmm12,r14
  469144:	vpinsrq xmm13,xmm12,rax,0x1
  46914a:	mov    rsi,QWORD PTR [rsp-0x30]
  46914f:	vpsrlq xmm14,xmm13,0x4
  469155:	vpmovqd xmm15,xmm14
  46915b:	sar    rsi,0x4
  46915f:	vmovq  QWORD PTR [rcx+0xc0],xmm15
  469167:	sub    rsi,r12
  46916a:	add    DWORD PTR [r15],esi
  46916d:	vpextrd eax,xmm15,0x1
  469173:	cmp    rdx,QWORD PTR [rsp-0x20]
  469178:	je     469450 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  46917e:	mov    r14,QWORD PTR [rcx+0x88]
  469185:	mov    rbx,QWORD PTR [rcx+0x80]
  46918c:	mov    rdi,QWORD PTR [rcx+0x60]
  469190:	dec    r14
  469193:	mov    QWORD PTR [rsp-0x18],rbx
  469198:	mov    QWORD PTR [rsp],rdi
  46919c:	mov    QWORD PTR [rsp-0x28],r14
  4691a1:	mov    r10d,DWORD PTR [rcx+0x78]
  4691a5:	mov    r11,QWORD PTR [rip+0x2ba44]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4691ac:	mov    r9,QWORD PTR [rcx+0xa0]
  4691b3:	movzx  r13d,BYTE PTR [rip+0x2b945]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4691bb:	mov    r12,QWORD PTR [rip+0x2b946]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4691c2:	mov    r8d,0x55
  4691c8:	vpxor  xmm7,xmm7,xmm7
  4691cc:	kmovb  k7,r8d
  4691d1:	nop    DWORD PTR [rax+0x0]
  4691d8:	lea    esi,[rax+0x18]
  4691db:	and    esi,r10d
  4691de:	shl    rsi,0x4
  4691e2:	mov    edi,ebx
  4691e4:	and    edi,DWORD PTR [r9+rsi*1+0x8]
  4691e9:	mov    esi,eax
  4691eb:	shl    rsi,0x4
  4691ef:	add    rsi,r9
  4691f2:	mov    r8,QWORD PTR [rsi]
  4691f5:	shl    rdi,0x4
  4691f9:	prefetcht0 BYTE PTR [r11+rdi*1]
  4691fe:	cmp    r8,QWORD PTR [rcx+0x90]
  469205:	jne    4692c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x530>
  46920b:	test   r13b,r13b
  46920e:	je     46922e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x49e>
  469210:	mov    r14d,DWORD PTR [r15]
  469213:	mov    esi,DWORD PTR [rsi+0xc]
  469216:	mov    r8,r14
  469219:	shl    r14,0x4
  46921d:	add    r14,QWORD PTR [r15+0x8]
  469221:	inc    r8d
  469224:	mov    DWORD PTR [r14],esi
  469227:	mov    QWORD PTR [r14+0x8],r12
  46922b:	mov    DWORD PTR [r15],r8d
  46922e:	inc    eax
  469230:	and    eax,r10d
  469233:	mov    DWORD PTR [rcx+0xc4],eax
  469239:	test   r12,r12
  46923c:	jne    4691d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
  46923e:	cmp    QWORD PTR [rsp],0x4
  469243:	je     4693b5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x625>
  469249:	nop    DWORD PTR [rax+0x0]
  469250:	cmp    QWORD PTR [rsp],0x8
  469255:	je     469430 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6a0>
  46925b:	vmovd  xmm2,DWORD PTR [rsp-0x10]
  469261:	mov    rdi,QWORD PTR [rdx]
  469264:	mov    esi,DWORD PTR [rcx+0xc0]
  46926a:	mov    r8,QWORD PTR [rsp-0x28]
  46926f:	mov    rax,rsi
  469272:	and    r8,QWORD PTR [rsp-0x10]
  469277:	vpinsrd xmm8,xmm2,DWORD PTR [rdx+0xc],0x1
  46927e:	and    r8,0xfffffffffffffffc
  469282:	shl    rsi,0x4
  469286:	inc    eax
  469288:	add    rsi,r9
  46928b:	shl    r8,0x4
  46928f:	and    eax,r10d
  469292:	add    rdx,0x10
  469296:	prefetcht2 BYTE PTR [r11+r8*1]
  46929b:	mov    QWORD PTR [rsi],rdi
  46929e:	vmovq  QWORD PTR [rsi+0x8],xmm8
  4692a3:	mov    DWORD PTR [rcx+0xc0],eax
  4692a9:	cmp    rdx,QWORD PTR [rsp-0x20]
  4692ae:	je     469450 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  4692b4:	mov    eax,DWORD PTR [rcx+0xc4]
  4692ba:	jmp    4691d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
  4692bf:	nop
  4692c0:	mov    r14d,DWORD PTR [rsi+0x8]
  4692c4:	mov    edi,ebx
  4692c6:	and    edi,r14d
  4692c9:	shl    rdi,0x4
  4692cd:	add    rdi,r11
  4692d0:	vmovdqa64 zmm0,ZMMWORD PTR [rdi]
  4692d6:	vpbroadcastq zmm1,r8
  4692dc:	vpcmpequq k0{k7},zmm0,zmm1
  4692e3:	kortestb k0,k0
  4692e7:	jne    469370 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5e0>
  4692ed:	vpcmpequq k1{k7},zmm0,zmm7
  4692f4:	kortestb k1,k1
  4692f8:	jne    4693e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x650>
  4692fe:	cmp    QWORD PTR [rsp],0x4
  469303:	mov    edi,r14d
  469306:	je     4693f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x660>
  46930c:	cmp    QWORD PTR [rsp],0x8
  469311:	je     469410 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x680>
  469317:	vmovd  xmm3,DWORD PTR [rsp-0x8]
  46931d:	mov    edi,DWORD PTR [rcx+0xc0]
  469323:	mov    r14,QWORD PTR [rsp-0x18]
  469328:	vpinsrd xmm6,xmm3,DWORD PTR [rsi+0xc],0x1
  46932f:	mov    rsi,rdi
  469332:	and    r14,QWORD PTR [rsp-0x8]
  469337:	shl    rdi,0x4
  46933b:	inc    esi
  46933d:	inc    eax
  46933f:	add    rdi,r9
  469342:	shl    r14,0x4
  469346:	and    esi,r10d
  469349:	and    eax,r10d
  46934c:	prefetcht2 BYTE PTR [r11+r14*1]
  469351:	mov    QWORD PTR [rdi],r8
  469354:	vmovq  QWORD PTR [rdi+0x8],xmm6
  469359:	mov    DWORD PTR [rcx+0xc0],esi
  46935f:	mov    DWORD PTR [rcx+0xc4],eax
  469365:	jmp    4691d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
  46936a:	nop    WORD PTR [rax+rax*1+0x0]
  469370:	mov    r8d,DWORD PTR [r15]
  469373:	mov    esi,DWORD PTR [rsi+0xc]
  469376:	mov    r14,r8
  469379:	shl    r8,0x4
  46937d:	add    r8,QWORD PTR [r15+0x8]
  469381:	mov    DWORD PTR [r8],esi
  469384:	kmovb  esi,k0
  469388:	tzcnt  esi,esi
  46938c:	inc    esi
  46938e:	movsxd rsi,esi
  469391:	mov    rdi,QWORD PTR [rdi+rsi*8]
  469395:	inc    eax
  469397:	inc    r14d
  46939a:	and    eax,r10d
  46939d:	cmp    QWORD PTR [rsp],0x4
  4693a2:	mov    QWORD PTR [r8+0x8],rdi
  4693a6:	mov    DWORD PTR [r15],r14d
  4693a9:	mov    DWORD PTR [rcx+0xc4],eax
  4693af:	jne    469250 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4c0>
  4693b5:	mov    r14d,0xffffffff
  4693bb:	crc32  r14d,DWORD PTR [rdx]
  4693c1:	vmovd  xmm5,r14d
  4693c6:	mov    rdi,QWORD PTR [rdx]
  4693c9:	vmovdqa xmm2,xmm5
  4693cd:	vmovq  QWORD PTR [rsp-0x10],xmm5
  4693d3:	jmp    469264 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4d4>
  4693d8:	nop    DWORD PTR [rax+rax*1+0x0]
  4693e0:	inc    eax
  4693e2:	and    eax,r10d
  4693e5:	mov    DWORD PTR [rcx+0xc4],eax
  4693eb:	jmp    46923e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4ae>
  4693f0:	mov    edi,0xffffffff
  4693f5:	crc32  edi,r14d
  4693fb:	vmovd  xmm4,edi
  4693ff:	vmovdqa xmm3,xmm4
  469403:	vmovq  QWORD PTR [rsp-0x8],xmm4
  469409:	jmp    46931d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x58d>
  46940e:	xchg   ax,ax
  469410:	mov    r14d,0xffffffff
  469416:	crc32  r14,rdi
  46941c:	mov    QWORD PTR [rsp-0x8],r14
  469421:	vmovd  xmm3,r14d
  469426:	jmp    46931d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x58d>
  46942b:	nop    DWORD PTR [rax+rax*1+0x0]
  469430:	mov    rdi,QWORD PTR [rdx]
  469433:	mov    eax,0xffffffff
  469438:	crc32  rax,rdi
  46943e:	mov    QWORD PTR [rsp-0x10],rax
  469443:	vmovd  xmm2,eax
  469447:	jmp    469264 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4d4>
  46944c:	nop    DWORD PTR [rax+0x0]
  469450:	vzeroupper 
  469453:	lea    rsp,[rbp-0x28]
  469457:	pop    rbx
  469458:	pop    r12
  46945a:	pop    r13
  46945c:	pop    r14
  46945e:	pop    r15
  469460:	pop    rbp
  469461:	ret    
  469462:	nop    WORD PTR [rax+rax*1+0x0]
  469468:	vpcmpequq k1{k2},zmm14,zmm2
  46946f:	kortestb k1,k1
  469473:	jne    469886 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaf6>
  469479:	vmovdqu xmm0,XMMWORD PTR [r11]
  46947e:	mov    r15d,0xffffffff
  469484:	crc32  r15,rbx
  46948a:	vpinsrd xmm1,xmm0,r15d,0x2
  469490:	add    r14,0x10
  469494:	andn   r12d,esi,r15d
  469499:	shl    r12,0x4
  46949d:	and    r14,r10
  4694a0:	prefetcht2 BYTE PTR [rdi+r12*1]
  4694a5:	vmovdqu XMMWORD PTR [rcx],xmm1
  4694a9:	jmp    468f70 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1e0>
  4694ae:	xchg   ax,ax
  4694b0:	vpcmpequq k5{k2},zmm5,zmm2
  4694b7:	kortestb k5,k5
  4694bb:	jne    46987d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaed>
  4694c1:	vmovdqu xmm9,XMMWORD PTR [r12]
  4694c7:	mov    r13d,0xffffffff
  4694cd:	crc32  r13,r11
  4694d3:	vpinsrd xmm10,xmm9,r13d,0x2
  4694d9:	andn   ecx,esi,r13d
  4694de:	shl    rcx,0x4
  4694e2:	prefetcht2 BYTE PTR [rdi+rcx*1]
  4694e6:	vmovdqu XMMWORD PTR [r8+r14*1],xmm10
  4694ec:	add    r14,0x10
  4694f0:	and    r14,r10
  4694f3:	jmp    468efe <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x16e>
  4694f8:	nop    DWORD PTR [rax+rax*1+0x0]
  469500:	vpcmpequq k1{k2},zmm15,zmm2
  469507:	kortestb k1,k1
  46950b:	jne    46986b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xadb>
  469511:	vmovdqu xmm1,XMMWORD PTR [r15]
  469516:	mov    r12d,0xffffffff
  46951c:	crc32  r12,r11
  469522:	vpinsrd xmm7,xmm1,r12d,0x2
  469528:	andn   ecx,esi,r12d
  46952d:	shl    rcx,0x4
  469531:	prefetcht2 BYTE PTR [rdi+rcx*1]
  469535:	vmovdqu XMMWORD PTR [r8+r14*1],xmm7
  46953b:	add    r14,0x10
  46953f:	and    r14,r10
  469542:	jmp    468e90 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x100>
  469547:	nop    WORD PTR [rax+rax*1+0x0]
  469550:	vmovd  xmm9,r13d
  469555:	mov    r13,QWORD PTR [rsp]
  469559:	vmovd  xmm5,r15d
  46955e:	vpinsrd xmm10,xmm9,r11d,0x1
  469564:	mov    r11,r13
  469567:	vpinsrd xmm8,xmm5,ebx,0x1
  46956d:	sub    r11,r14
  469570:	vpunpcklqdq xmm11,xmm10,xmm8
  469575:	shr    r11,0x2
  469579:	mov    r15d,0x1
  46957f:	vpexpandd zmm6{k3},zmm11
  469585:	shlx   r11d,r15d,r11d
  46958a:	lea    ebx,[r11-0x1]
  46958e:	sub    r14,r13
  469591:	neg    r11d
  469594:	kmovw  k5,ebx
  469598:	vmovdqu32 ZMMWORD PTR [rcx]{k5},zmm6
  46959e:	kmovw  k6,r11d
  4695a3:	vmovdqu32 ZMMWORD PTR [r8+r14*1]{k6},zmm6
  4695aa:	jmp    469078 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2e8>
  4695af:	cmp    rdx,QWORD PTR [rsp-0x20]
  4695b4:	je     469453 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c3>
  4695ba:	mov    r9,QWORD PTR [rcx+0x60]
  4695be:	mov    r12,QWORD PTR [rcx+0x88]
  4695c5:	movzx  r13d,BYTE PTR [rip+0x2b533]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4695cd:	mov    rbx,QWORD PTR [rip+0x2b534]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4695d4:	mov    QWORD PTR [rsp],r9
  4695d8:	mov    r10d,0x55
  4695de:	lea    r9,[r12-0x1]
  4695e3:	kmovb  k2,r13d
  4695e8:	mov    QWORD PTR [rsp-0x8],r9
  4695ed:	mov    r14,QWORD PTR [rip+0x2b5fc]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4695f4:	mov    r11,QWORD PTR [rcx+0xa0]
  4695fb:	mov    esi,edi
  4695fd:	vpxor  xmm2,xmm2,xmm2
  469601:	mov    r13,rbx
  469604:	kmovb  k1,r10d
  469609:	jmp    469671 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8e1>
  46960b:	cmp    QWORD PTR [rsp],0x8
  469610:	je     469818 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa88>
  469616:	vmovd  xmm4,DWORD PTR [rsp-0x18]
  46961c:	mov    r12,QWORD PTR [rsp-0x8]
  469621:	mov    esi,edi
  469623:	and    r12,QWORD PTR [rsp-0x18]
  469628:	vpinsrd xmm5,xmm4,DWORD PTR [rdx+0xc],0x1
  46962f:	mov    r10,QWORD PTR [rdx]
  469632:	and    r12,0xfffffffffffffffc
  469636:	shl    rsi,0x4
  46963a:	add    rsi,r11
  46963d:	shl    r12,0x4
  469641:	prefetcht2 BYTE PTR [r14+r12*1]
  469646:	mov    QWORD PTR [rsi],r10
  469649:	vmovq  QWORD PTR [rsi+0x8],xmm5
  46964e:	lea    esi,[rdi+0x1]
  469651:	and    esi,r8d
  469654:	add    rdx,0x10
  469658:	mov    DWORD PTR [rcx+0xc0],esi
  46965e:	cmp    QWORD PTR [rsp-0x20],rdx
  469663:	je     469450 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  469669:	mov    eax,DWORD PTR [rcx+0xc4]
  46966f:	mov    edi,esi
  469671:	sub    esi,eax
  469673:	and    esi,r8d
  469676:	cmp    r8d,esi
  469679:	jbe    46969c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x90c>
  46967b:	cmp    QWORD PTR [rsp],0x4
  469680:	jne    46960b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x87b>
  469682:	mov    ebx,0xffffffff
  469687:	crc32  ebx,DWORD PTR [rdx]
  46968c:	vmovd  xmm6,ebx
  469690:	vmovdqa xmm4,xmm6
  469694:	vmovq  QWORD PTR [rsp-0x18],xmm6
  46969a:	jmp    46961c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x88c>
  46969c:	mov    rbx,QWORD PTR [rcx+0x80]
  4696a3:	mov    QWORD PTR [rsp-0x10],rbx
  4696a8:	nop    DWORD PTR [rax+rax*1+0x0]
  4696b0:	lea    esi,[rax+0x18]
  4696b3:	and    esi,r8d
  4696b6:	shl    rsi,0x4
  4696ba:	mov    r10d,ebx
  4696bd:	and    r10d,DWORD PTR [r11+rsi*1+0x8]
  4696c2:	mov    esi,eax
  4696c4:	shl    rsi,0x4
  4696c8:	add    rsi,r11
  4696cb:	mov    r12,r10
  4696ce:	mov    r10,QWORD PTR [rsi]
  4696d1:	shl    r12,0x4
  4696d5:	prefetcht0 BYTE PTR [r14+r12*1]
  4696da:	cmp    r10,QWORD PTR [rcx+0x90]
  4696e1:	jne    469720 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x990>
  4696e3:	kortestb k2,k2
  4696e7:	je     46970a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x97a>
  4696e9:	mov    r12d,DWORD PTR [r15]
  4696ec:	mov    esi,DWORD PTR [rsi+0xc]
  4696ef:	mov    r10,r12
  4696f2:	shl    r12,0x4
  4696f6:	add    r12,QWORD PTR [r15+0x8]
  4696fa:	lea    r9d,[r10+0x1]
  4696fe:	mov    DWORD PTR [r12],esi
  469702:	mov    QWORD PTR [r12+0x8],r13
  469707:	mov    DWORD PTR [r15],r9d
  46970a:	inc    eax
  46970c:	and    eax,r8d
  46970f:	mov    DWORD PTR [rcx+0xc4],eax
  469715:	test   r13,r13
  469718:	jne    4696b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x920>
  46971a:	jmp    46967b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8eb>
  46971f:	nop
  469720:	mov    r12d,DWORD PTR [rsi+0x8]
  469724:	mov    r9d,ebx
  469727:	and    r9d,r12d
  46972a:	shl    r9,0x4
  46972e:	add    r9,r14
  469731:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  469737:	vpbroadcastq zmm1,r10
  46973d:	vpcmpequq k0{k1},zmm0,zmm1
  469744:	kortestb k0,k0
  469748:	jne    4697c4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa34>
  46974a:	vpcmpequq k3{k1},zmm0,zmm2
  469751:	kortestb k3,k3
  469755:	jne    469808 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa78>
  46975b:	cmp    QWORD PTR [rsp],0x4
  469760:	mov    r9d,r12d
  469763:	je     469831 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaa1>
  469769:	cmp    QWORD PTR [rsp],0x8
  46976e:	je     469852 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xac2>
  469774:	mov    r9d,DWORD PTR [rsp-0x28]
  469779:	mov    r12,QWORD PTR [rsp-0x10]
  46977e:	vmovd  xmm7,r9d
  469783:	vpinsrd xmm3,xmm7,DWORD PTR [rsi+0xc],0x1
  46978a:	mov    esi,edi
  46978c:	and    r12,QWORD PTR [rsp-0x28]
  469791:	shl    rsi,0x4
  469795:	inc    edi
  469797:	inc    eax
  469799:	add    rsi,r11
  46979c:	shl    r12,0x4
  4697a0:	and    edi,r8d
  4697a3:	and    eax,r8d
  4697a6:	prefetcht2 BYTE PTR [r14+r12*1]
  4697ab:	mov    QWORD PTR [rsi],r10
  4697ae:	vmovq  QWORD PTR [rsi+0x8],xmm3
  4697b3:	mov    DWORD PTR [rcx+0xc0],edi
  4697b9:	mov    DWORD PTR [rcx+0xc4],eax
  4697bf:	jmp    4696b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x920>
  4697c4:	mov    r10d,DWORD PTR [r15]
  4697c7:	mov    r12d,DWORD PTR [rsi+0xc]
  4697cb:	mov    rbx,r10
  4697ce:	shl    r10,0x4
  4697d2:	add    r10,QWORD PTR [r15+0x8]
  4697d6:	mov    DWORD PTR [r10],r12d
  4697d9:	xor    r12d,r12d
  4697dc:	kmovb  esi,k0
  4697e0:	tzcnt  r12d,esi
  4697e5:	inc    r12d
  4697e8:	movsxd rsi,r12d
  4697eb:	mov    r9,QWORD PTR [r9+rsi*8]
  4697ef:	inc    eax
  4697f1:	inc    ebx
  4697f3:	and    eax,r8d
  4697f6:	mov    QWORD PTR [r10+0x8],r9
  4697fa:	mov    DWORD PTR [r15],ebx
  4697fd:	mov    DWORD PTR [rcx+0xc4],eax
  469803:	jmp    46967b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8eb>
  469808:	inc    eax
  46980a:	and    eax,r8d
  46980d:	mov    DWORD PTR [rcx+0xc4],eax
  469813:	jmp    46967b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8eb>
  469818:	mov    eax,0xffffffff
  46981d:	crc32  rax,QWORD PTR [rdx]
  469823:	mov    QWORD PTR [rsp-0x18],rax
  469828:	vmovd  xmm4,eax
  46982c:	jmp    46961c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x88c>
  469831:	mov    r9d,0xffffffff
  469837:	crc32  r9d,r12d
  46983d:	mov    r12d,r9d
  469840:	mov    QWORD PTR [rsp-0x28],r12
  469845:	jmp    469779 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9e9>
  46984a:	xor    r12d,r12d
  46984d:	jmp    46913f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3af>
  469852:	mov    r12d,0xffffffff
  469858:	crc32  r12,r9
  46985e:	mov    QWORD PTR [rsp-0x28],r12
  469863:	mov    r9d,r12d
  469866:	jmp    469779 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9e9>
  46986b:	inc    DWORD PTR [rsp-0x28]
  46986f:	jmp    468efe <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x16e>
  469874:	inc    DWORD PTR [rsp-0x28]
  469878:	jmp    468e90 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x100>
  46987d:	inc    DWORD PTR [rsp-0x28]
  469881:	jmp    468f70 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1e0>
  469886:	inc    DWORD PTR [rsp-0x28]
  46988a:	jmp    468fe2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x252>
