0000000000468d80 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468d80:	push   rbp
  468d81:	mov    rcx,rdi
  468d84:	mov    rbp,rsp
  468d87:	push   r15
  468d89:	mov    r15,rdx
  468d8c:	push   r14
  468d8e:	push   r13
  468d90:	push   r12
  468d92:	push   rbx
  468d93:	and    rsp,0xffffffffffffffc0
  468d97:	sub    rsp,0x8
  468d9b:	mov    r11,QWORD PTR [rsi+0x8]
  468d9f:	mov    edi,DWORD PTR [rdi+0xc0]
  468da5:	mov    eax,DWORD PTR [rcx+0xc4]
  468dab:	mov    rdx,QWORD PTR [rsi]
  468dae:	mov    r8d,DWORD PTR [rcx+0x78]
  468db2:	mov    r9d,DWORD PTR [rcx+0x6c]
  468db6:	mov    r10,r11
  468db9:	mov    esi,edi
  468dbb:	shl    r10,0x4
  468dbf:	sub    esi,eax
  468dc1:	lea    rbx,[rdx+r10*1]
  468dc5:	and    esi,r8d
  468dc8:	lea    r12d,[r9-0x1]
  468dcc:	mov    QWORD PTR [rsp-0x20],rbx
  468dd1:	cmp    esi,r12d
  468dd4:	jb     46958f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x80f>
  468dda:	and    r11,0xfffffffffffffffc
  468dde:	shl    r11,0x4
  468de2:	mov    esi,DWORD PTR [rcx+0x80]
  468de8:	shl    r9,0x4
  468dec:	shl    rdi,0x4
  468df0:	mov    QWORD PTR [rsp-0x30],r11
  468df5:	lea    r11,[rdx+r11*1]
  468df9:	mov    QWORD PTR [rsp],r9
  468dfd:	lea    r10,[r9-0x1]
  468e01:	mov    r14,rdi
  468e04:	mov    QWORD PTR [rsp-0x18],r11
  468e09:	mov    DWORD PTR [rsp-0x28],0x0
  468e11:	mov    r8,QWORD PTR [rcx+0xa0]
  468e18:	mov    r9,QWORD PTR [r15+0x8]
  468e1c:	mov    rdi,QWORD PTR [rip+0x2bdcd]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468e23:	shl    rax,0x4
  468e27:	not    esi
  468e29:	cmp    rdx,r11
  468e2c:	je     46982a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaaa>
  468e32:	mov    r13d,0x55
  468e38:	mov    ebx,0x4444
  468e3d:	mov    QWORD PTR [rsp-0x38],rcx
  468e42:	mov    QWORD PTR [rsp-0x40],r15
  468e47:	vpxor  xmm2,xmm2,xmm2
  468e4b:	kmovb  k2,r13d
  468e50:	kmovw  k3,ebx
  468e54:	jmp    469075 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2f5>
  468e59:	nop    DWORD PTR [rax+0x0]
  468e60:	vmovd  xmm13,DWORD PTR [r13+0xc]
  468e66:	kaddb  k6,k4,k4
  468e6a:	vpcompressq zmm12{k6}{z},zmm8
  468e70:	vpunpcklqdq xmm14,xmm13,xmm12
  468e75:	vmovdqu XMMWORD PTR [r9],xmm14
  468e7a:	add    r9,0x10
  468e7e:	lea    r15,[r8+rax*1]
  468e82:	mov    r11d,DWORD PTR [r15+0x8]
  468e86:	andn   ebx,esi,r11d
  468e8b:	shl    rbx,0x4
  468e8f:	vmovdqa64 zmm15,ZMMWORD PTR [rdi+rbx*1]
  468e96:	vpbroadcastq zmm0,QWORD PTR [r15]
  468e9c:	vpcmpequq k7{k2},zmm15,zmm0
  468ea3:	lea    r12,[rax+0x180]
  468eaa:	add    rax,0x10
  468eae:	and    r12,r10
  468eb1:	and    rax,r10
  468eb4:	andn   ecx,esi,DWORD PTR [r8+r12*1+0x8]
  468ebb:	shl    rcx,0x4
  468ebf:	kortestb k7,k7
  468ec3:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468ec7:	je     4694e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x760>
  468ecd:	vmovd  xmm4,DWORD PTR [r15+0xc]
  468ed3:	kaddb  k4,k7,k7
  468ed7:	vpcompressq zmm3{k4}{z},zmm15
  468edd:	vpunpcklqdq xmm6,xmm4,xmm3
  468ee1:	vmovdqu XMMWORD PTR [r9],xmm6
  468ee6:	add    r9,0x10
  468eea:	lea    r12,[r8+rax*1]
  468eee:	mov    r11d,DWORD PTR [r12+0x8]
  468ef3:	andn   ebx,esi,r11d
  468ef8:	shl    rbx,0x4
  468efc:	vmovdqa64 zmm5,ZMMWORD PTR [rdi+rbx*1]
  468f03:	vpbroadcastq zmm8,QWORD PTR [r12]
  468f0a:	vpcmpequq k0{k2},zmm5,zmm8
  468f11:	lea    r13,[rax+0x180]
  468f18:	add    rax,0x10
  468f1c:	and    r13,r10
  468f1f:	and    rax,r10
  468f22:	andn   ecx,esi,DWORD PTR [r8+r13*1+0x8]
  468f29:	shl    rcx,0x4
  468f2d:	kortestb k0,k0
  468f31:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468f35:	je     469490 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x710>
  468f3b:	vmovd  xmm12,DWORD PTR [r12+0xc]
  468f42:	kaddb  k6,k0,k0
  468f46:	vpcompressq zmm11{k6}{z},zmm5
  468f4c:	vpunpcklqdq xmm13,xmm12,xmm11
  468f51:	vmovdqu XMMWORD PTR [r9],xmm13
  468f56:	add    r9,0x10
  468f5a:	lea    r11,[r8+rax*1]
  468f5e:	mov    ebx,DWORD PTR [r11+0x8]
  468f62:	andn   r13d,esi,ebx
  468f67:	shl    r13,0x4
  468f6b:	vmovdqa64 zmm14,ZMMWORD PTR [rdi+r13*1]
  468f72:	vpbroadcastq zmm15,QWORD PTR [r11]
  468f78:	vpcmpequq k7{k2},zmm14,zmm15
  468f7f:	lea    r15,[rax+0x180]
  468f86:	add    rax,0x10
  468f8a:	and    r15,r10
  468f8d:	and    rax,r10
  468f90:	andn   ecx,esi,DWORD PTR [r8+r15*1+0x8]
  468f97:	shl    rcx,0x4
  468f9b:	kortestb k7,k7
  468f9f:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468fa3:	lea    rcx,[r8+r14*1]
  468fa7:	je     469448 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c8>
  468fad:	vmovd  xmm3,DWORD PTR [r11+0xc]
  468fb3:	kaddb  k4,k7,k7
  468fb7:	vpcompressq zmm7{k4}{z},zmm14
  468fbd:	vpunpcklqdq xmm4,xmm3,xmm7
  468fc1:	vmovdqu XMMWORD PTR [r9],xmm4
  468fc6:	add    r9,0x10
  468fca:	mov    r13d,0xffffffff
  468fd0:	crc32  r13,QWORD PTR [rdx]
  468fd6:	andn   r11d,esi,r13d
  468fdb:	shl    r11,0x4
  468fdf:	prefetcht2 BYTE PTR [rdi+r11*1]
  468fe4:	mov    r11d,0xffffffff
  468fea:	crc32  r11,QWORD PTR [rdx+0x10]
  468ff1:	mov    r15d,0xffffffff
  468ff7:	andn   ebx,esi,r11d
  468ffc:	shl    rbx,0x4
  469000:	prefetcht2 BYTE PTR [rdi+rbx*1]
  469004:	mov    ebx,0xffffffff
  469009:	crc32  r15,QWORD PTR [rdx+0x20]
  469010:	crc32  rbx,QWORD PTR [rdx+0x30]
  469017:	andn   r12d,esi,r15d
  46901c:	shl    r12,0x4
  469020:	prefetcht2 BYTE PTR [rdi+r12*1]
  469025:	andn   r12d,esi,ebx
  46902a:	shl    r12,0x4
  46902e:	prefetcht2 BYTE PTR [rdi+r12*1]
  469033:	lea    r12,[r14+0x40]
  469037:	vmovdqu64 zmm6,ZMMWORD PTR [rdx]
  46903d:	cmp    QWORD PTR [rsp],r12
  469041:	jb     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7b0>
  469047:	vmovdqu64 ZMMWORD PTR [rcx],zmm6
  46904d:	mov    DWORD PTR [rcx+0x8],r13d
  469051:	mov    DWORD PTR [r8+r14*1+0x18],r11d
  469056:	mov    DWORD PTR [r8+r14*1+0x28],r15d
  46905b:	mov    DWORD PTR [r8+r14*1+0x38],ebx
  469060:	mov    r14,r12
  469063:	add    rdx,0x40
  469067:	and    r14,r10
  46906a:	cmp    QWORD PTR [rsp-0x18],rdx
  46906f:	je     469110 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x390>
  469075:	lea    r13,[r8+rax*1]
  469079:	mov    r11d,DWORD PTR [r13+0x8]
  46907d:	andn   ebx,esi,r11d
  469082:	shl    rbx,0x4
  469086:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+rbx*1]
  46908d:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  469094:	vpcmpequq k4{k2},zmm8,zmm9
  46909b:	lea    rcx,[rax+0x180]
  4690a2:	add    rax,0x10
  4690a6:	and    rcx,r10
  4690a9:	and    rax,r10
  4690ac:	andn   r15d,esi,DWORD PTR [r8+rcx*1+0x8]
  4690b3:	shl    r15,0x4
  4690b7:	kortestb k4,k4
  4690bb:	prefetcht0 BYTE PTR [rdi+r15*1]
  4690c0:	jne    468e60 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xe0>
  4690c6:	vpcmpequq k5{k2},zmm8,zmm2
  4690cd:	kortestb k5,k5
  4690d1:	jne    469854 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad4>
  4690d7:	vmovdqu xmm10,XMMWORD PTR [r13+0x0]
  4690dd:	mov    ecx,0xffffffff
  4690e2:	crc32  rcx,r11
  4690e8:	vpinsrd xmm11,xmm10,ecx,0x2
  4690ee:	andn   r15d,esi,ecx
  4690f3:	shl    r15,0x4
  4690f7:	prefetcht2 BYTE PTR [rdi+r15*1]
  4690fc:	vmovdqu XMMWORD PTR [r8+r14*1],xmm11
  469102:	add    r14,0x10
  469106:	and    r14,r10
  469109:	jmp    469075 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2f5>
  46910e:	xchg   ax,ax
  469110:	mov    rcx,QWORD PTR [rsp-0x38]
  469115:	mov    r15,QWORD PTR [rsp-0x40]
  46911a:	mov    r12d,DWORD PTR [rsp-0x28]
  46911f:	vmovq  xmm12,r14
  469124:	vpinsrq xmm13,xmm12,rax,0x1
  46912a:	mov    rsi,QWORD PTR [rsp-0x30]
  46912f:	vpsrlq xmm14,xmm13,0x4
  469135:	vpmovqd xmm15,xmm14
  46913b:	sar    rsi,0x4
  46913f:	vmovq  QWORD PTR [rcx+0xc0],xmm15
  469147:	sub    rsi,r12
  46914a:	add    DWORD PTR [r15],esi
  46914d:	vpextrd eax,xmm15,0x1
  469153:	cmp    rdx,QWORD PTR [rsp-0x20]
  469158:	je     469430 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  46915e:	mov    r14,QWORD PTR [rcx+0x88]
  469165:	mov    rbx,QWORD PTR [rcx+0x80]
  46916c:	mov    rdi,QWORD PTR [rcx+0x60]
  469170:	dec    r14
  469173:	mov    QWORD PTR [rsp-0x18],rbx
  469178:	mov    QWORD PTR [rsp],rdi
  46917c:	mov    QWORD PTR [rsp-0x28],r14
  469181:	mov    r10d,DWORD PTR [rcx+0x78]
  469185:	mov    r11,QWORD PTR [rip+0x2ba64]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46918c:	mov    r9,QWORD PTR [rcx+0xa0]
  469193:	movzx  r13d,BYTE PTR [rip+0x2b965]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  46919b:	mov    r12,QWORD PTR [rip+0x2b966]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4691a2:	mov    r8d,0x55
  4691a8:	vpxor  xmm7,xmm7,xmm7
  4691ac:	kmovb  k7,r8d
  4691b1:	nop    DWORD PTR [rax+0x0]
  4691b8:	lea    esi,[rax+0x18]
  4691bb:	and    esi,r10d
  4691be:	shl    rsi,0x4
  4691c2:	mov    edi,ebx
  4691c4:	and    edi,DWORD PTR [r9+rsi*1+0x8]
  4691c9:	mov    esi,eax
  4691cb:	shl    rsi,0x4
  4691cf:	add    rsi,r9
  4691d2:	mov    r8,QWORD PTR [rsi]
  4691d5:	shl    rdi,0x4
  4691d9:	prefetcht0 BYTE PTR [r11+rdi*1]
  4691de:	cmp    r8,QWORD PTR [rcx+0x90]
  4691e5:	jne    4692a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x520>
  4691eb:	test   r13b,r13b
  4691ee:	je     46920e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x48e>
  4691f0:	mov    r14d,DWORD PTR [r15]
  4691f3:	mov    esi,DWORD PTR [rsi+0xc]
  4691f6:	mov    r8,r14
  4691f9:	shl    r14,0x4
  4691fd:	add    r14,QWORD PTR [r15+0x8]
  469201:	inc    r8d
  469204:	mov    DWORD PTR [r14],esi
  469207:	mov    QWORD PTR [r14+0x8],r12
  46920b:	mov    DWORD PTR [r15],r8d
  46920e:	inc    eax
  469210:	and    eax,r10d
  469213:	mov    DWORD PTR [rcx+0xc4],eax
  469219:	test   r12,r12
  46921c:	jne    4691b8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x438>
  46921e:	cmp    QWORD PTR [rsp],0x4
  469223:	je     469395 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x615>
  469229:	nop    DWORD PTR [rax+0x0]
  469230:	cmp    QWORD PTR [rsp],0x8
  469235:	je     469410 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x690>
  46923b:	vmovd  xmm2,DWORD PTR [rsp-0x10]
  469241:	mov    rdi,QWORD PTR [rdx]
  469244:	mov    esi,DWORD PTR [rcx+0xc0]
  46924a:	mov    r8,QWORD PTR [rsp-0x28]
  46924f:	mov    rax,rsi
  469252:	and    r8,QWORD PTR [rsp-0x10]
  469257:	vpinsrd xmm8,xmm2,DWORD PTR [rdx+0xc],0x1
  46925e:	and    r8,0xfffffffffffffffc
  469262:	shl    rsi,0x4
  469266:	inc    eax
  469268:	add    rsi,r9
  46926b:	shl    r8,0x4
  46926f:	and    eax,r10d
  469272:	add    rdx,0x10
  469276:	prefetcht2 BYTE PTR [r11+r8*1]
  46927b:	mov    QWORD PTR [rsi],rdi
  46927e:	vmovq  QWORD PTR [rsi+0x8],xmm8
  469283:	mov    DWORD PTR [rcx+0xc0],eax
  469289:	cmp    rdx,QWORD PTR [rsp-0x20]
  46928e:	je     469430 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  469294:	mov    eax,DWORD PTR [rcx+0xc4]
  46929a:	jmp    4691b8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x438>
  46929f:	nop
  4692a0:	mov    r14d,DWORD PTR [rsi+0x8]
  4692a4:	mov    edi,ebx
  4692a6:	and    edi,r14d
  4692a9:	shl    rdi,0x4
  4692ad:	add    rdi,r11
  4692b0:	vmovdqa64 zmm0,ZMMWORD PTR [rdi]
  4692b6:	vpbroadcastq zmm1,r8
  4692bc:	vpcmpequq k0{k7},zmm0,zmm1
  4692c3:	kortestb k0,k0
  4692c7:	jne    469350 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5d0>
  4692cd:	vpcmpequq k1{k7},zmm0,zmm7
  4692d4:	kortestb k1,k1
  4692d8:	jne    4693c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x640>
  4692de:	cmp    QWORD PTR [rsp],0x4
  4692e3:	mov    edi,r14d
  4692e6:	je     4693d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x650>
  4692ec:	cmp    QWORD PTR [rsp],0x8
  4692f1:	je     4693f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x670>
  4692f7:	vmovd  xmm3,DWORD PTR [rsp-0x8]
  4692fd:	mov    edi,DWORD PTR [rcx+0xc0]
  469303:	mov    r14,QWORD PTR [rsp-0x18]
  469308:	vpinsrd xmm6,xmm3,DWORD PTR [rsi+0xc],0x1
  46930f:	mov    rsi,rdi
  469312:	and    r14,QWORD PTR [rsp-0x8]
  469317:	shl    rdi,0x4
  46931b:	inc    esi
  46931d:	inc    eax
  46931f:	add    rdi,r9
  469322:	shl    r14,0x4
  469326:	and    esi,r10d
  469329:	and    eax,r10d
  46932c:	prefetcht2 BYTE PTR [r11+r14*1]
  469331:	mov    QWORD PTR [rdi],r8
  469334:	vmovq  QWORD PTR [rdi+0x8],xmm6
  469339:	mov    DWORD PTR [rcx+0xc0],esi
  46933f:	mov    DWORD PTR [rcx+0xc4],eax
  469345:	jmp    4691b8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x438>
  46934a:	nop    WORD PTR [rax+rax*1+0x0]
  469350:	mov    r8d,DWORD PTR [r15]
  469353:	mov    esi,DWORD PTR [rsi+0xc]
  469356:	mov    r14,r8
  469359:	shl    r8,0x4
  46935d:	add    r8,QWORD PTR [r15+0x8]
  469361:	mov    DWORD PTR [r8],esi
  469364:	kmovb  esi,k0
  469368:	tzcnt  esi,esi
  46936c:	inc    esi
  46936e:	movsxd rsi,esi
  469371:	mov    rdi,QWORD PTR [rdi+rsi*8]
  469375:	inc    eax
  469377:	inc    r14d
  46937a:	and    eax,r10d
  46937d:	cmp    QWORD PTR [rsp],0x4
  469382:	mov    QWORD PTR [r8+0x8],rdi
  469386:	mov    DWORD PTR [r15],r14d
  469389:	mov    DWORD PTR [rcx+0xc4],eax
  46938f:	jne    469230 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4b0>
  469395:	mov    r14d,0xffffffff
  46939b:	crc32  r14d,DWORD PTR [rdx]
  4693a1:	vmovd  xmm5,r14d
  4693a6:	mov    rdi,QWORD PTR [rdx]
  4693a9:	vmovdqa xmm2,xmm5
  4693ad:	vmovq  QWORD PTR [rsp-0x10],xmm5
  4693b3:	jmp    469244 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4c4>
  4693b8:	nop    DWORD PTR [rax+rax*1+0x0]
  4693c0:	inc    eax
  4693c2:	and    eax,r10d
  4693c5:	mov    DWORD PTR [rcx+0xc4],eax
  4693cb:	jmp    46921e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x49e>
  4693d0:	mov    edi,0xffffffff
  4693d5:	crc32  edi,r14d
  4693db:	vmovd  xmm4,edi
  4693df:	vmovdqa xmm3,xmm4
  4693e3:	vmovq  QWORD PTR [rsp-0x8],xmm4
  4693e9:	jmp    4692fd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x57d>
  4693ee:	xchg   ax,ax
  4693f0:	mov    r14d,0xffffffff
  4693f6:	crc32  r14,rdi
  4693fc:	mov    QWORD PTR [rsp-0x8],r14
  469401:	vmovd  xmm3,r14d
  469406:	jmp    4692fd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x57d>
  46940b:	nop    DWORD PTR [rax+rax*1+0x0]
  469410:	mov    rdi,QWORD PTR [rdx]
  469413:	mov    eax,0xffffffff
  469418:	crc32  rax,rdi
  46941e:	mov    QWORD PTR [rsp-0x10],rax
  469423:	vmovd  xmm2,eax
  469427:	jmp    469244 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4c4>
  46942c:	nop    DWORD PTR [rax+0x0]
  469430:	vzeroupper 
  469433:	lea    rsp,[rbp-0x28]
  469437:	pop    rbx
  469438:	pop    r12
  46943a:	pop    r13
  46943c:	pop    r14
  46943e:	pop    r15
  469440:	pop    rbp
  469441:	ret    
  469442:	nop    WORD PTR [rax+rax*1+0x0]
  469448:	vpcmpequq k1{k2},zmm14,zmm2
  46944f:	kortestb k1,k1
  469453:	jne    469866 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xae6>
  469459:	vmovdqu xmm0,XMMWORD PTR [r11]
  46945e:	mov    r15d,0xffffffff
  469464:	crc32  r15,rbx
  46946a:	vpinsrd xmm1,xmm0,r15d,0x2
  469470:	add    r14,0x10
  469474:	andn   r12d,esi,r15d
  469479:	shl    r12,0x4
  46947d:	and    r14,r10
  469480:	prefetcht2 BYTE PTR [rdi+r12*1]
  469485:	vmovdqu XMMWORD PTR [rcx],xmm1
  469489:	jmp    468f5a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1da>
  46948e:	xchg   ax,ax
  469490:	vpcmpequq k5{k2},zmm5,zmm2
  469497:	kortestb k5,k5
  46949b:	jne    46985d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xadd>
  4694a1:	vmovdqu xmm9,XMMWORD PTR [r12]
  4694a7:	mov    r13d,0xffffffff
  4694ad:	crc32  r13,r11
  4694b3:	vpinsrd xmm10,xmm9,r13d,0x2
  4694b9:	andn   ecx,esi,r13d
  4694be:	shl    rcx,0x4
  4694c2:	prefetcht2 BYTE PTR [rdi+rcx*1]
  4694c6:	vmovdqu XMMWORD PTR [r8+r14*1],xmm10
  4694cc:	add    r14,0x10
  4694d0:	and    r14,r10
  4694d3:	jmp    468eea <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x16a>
  4694d8:	nop    DWORD PTR [rax+rax*1+0x0]
  4694e0:	vpcmpequq k1{k2},zmm15,zmm2
  4694e7:	kortestb k1,k1
  4694eb:	jne    46984b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xacb>
  4694f1:	vmovdqu xmm1,XMMWORD PTR [r15]
  4694f6:	mov    r12d,0xffffffff
  4694fc:	crc32  r12,r11
  469502:	vpinsrd xmm7,xmm1,r12d,0x2
  469508:	andn   ecx,esi,r12d
  46950d:	shl    rcx,0x4
  469511:	prefetcht2 BYTE PTR [rdi+rcx*1]
  469515:	vmovdqu XMMWORD PTR [r8+r14*1],xmm7
  46951b:	add    r14,0x10
  46951f:	and    r14,r10
  469522:	jmp    468e7e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xfe>
  469527:	nop    WORD PTR [rax+rax*1+0x0]
  469530:	vmovd  xmm9,r13d
  469535:	mov    r13,QWORD PTR [rsp]
  469539:	vmovd  xmm5,r15d
  46953e:	vpinsrd xmm10,xmm9,r11d,0x1
  469544:	mov    r11,r13
  469547:	vpinsrd xmm8,xmm5,ebx,0x1
  46954d:	sub    r11,r14
  469550:	vpunpcklqdq xmm11,xmm10,xmm8
  469555:	shr    r11,0x2
  469559:	mov    r15d,0x1
  46955f:	vpexpandd zmm6{k3},zmm11
  469565:	shlx   r11d,r15d,r11d
  46956a:	lea    ebx,[r11-0x1]
  46956e:	sub    r14,r13
  469571:	neg    r11d
  469574:	kmovw  k5,ebx
  469578:	vmovdqu32 ZMMWORD PTR [rcx]{k5},zmm6
  46957e:	kmovw  k6,r11d
  469583:	vmovdqu32 ZMMWORD PTR [r8+r14*1]{k6},zmm6
  46958a:	jmp    469060 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2e0>
  46958f:	cmp    rdx,QWORD PTR [rsp-0x20]
  469594:	je     469433 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b3>
  46959a:	mov    r9,QWORD PTR [rcx+0x60]
  46959e:	mov    r12,QWORD PTR [rcx+0x88]
  4695a5:	movzx  r13d,BYTE PTR [rip+0x2b553]        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4695ad:	mov    rbx,QWORD PTR [rip+0x2b554]        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4695b4:	mov    QWORD PTR [rsp],r9
  4695b8:	mov    r10d,0x55
  4695be:	lea    r9,[r12-0x1]
  4695c3:	kmovb  k2,r13d
  4695c8:	mov    QWORD PTR [rsp-0x8],r9
  4695cd:	mov    r14,QWORD PTR [rip+0x2b61c]        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4695d4:	mov    r11,QWORD PTR [rcx+0xa0]
  4695db:	mov    esi,edi
  4695dd:	vpxor  xmm2,xmm2,xmm2
  4695e1:	mov    r13,rbx
  4695e4:	kmovb  k1,r10d
  4695e9:	jmp    469651 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8d1>
  4695eb:	cmp    QWORD PTR [rsp],0x8
  4695f0:	je     4697f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa78>
  4695f6:	vmovd  xmm4,DWORD PTR [rsp-0x18]
  4695fc:	mov    r12,QWORD PTR [rsp-0x8]
  469601:	mov    esi,edi
  469603:	and    r12,QWORD PTR [rsp-0x18]
  469608:	vpinsrd xmm5,xmm4,DWORD PTR [rdx+0xc],0x1
  46960f:	mov    r10,QWORD PTR [rdx]
  469612:	and    r12,0xfffffffffffffffc
  469616:	shl    rsi,0x4
  46961a:	add    rsi,r11
  46961d:	shl    r12,0x4
  469621:	prefetcht2 BYTE PTR [r14+r12*1]
  469626:	mov    QWORD PTR [rsi],r10
  469629:	vmovq  QWORD PTR [rsi+0x8],xmm5
  46962e:	lea    esi,[rdi+0x1]
  469631:	and    esi,r8d
  469634:	add    rdx,0x10
  469638:	mov    DWORD PTR [rcx+0xc0],esi
  46963e:	cmp    QWORD PTR [rsp-0x20],rdx
  469643:	je     469430 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  469649:	mov    eax,DWORD PTR [rcx+0xc4]
  46964f:	mov    edi,esi
  469651:	sub    esi,eax
  469653:	and    esi,r8d
  469656:	cmp    r8d,esi
  469659:	jbe    46967c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8fc>
  46965b:	cmp    QWORD PTR [rsp],0x4
  469660:	jne    4695eb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x86b>
  469662:	mov    ebx,0xffffffff
  469667:	crc32  ebx,DWORD PTR [rdx]
  46966c:	vmovd  xmm6,ebx
  469670:	vmovdqa xmm4,xmm6
  469674:	vmovq  QWORD PTR [rsp-0x18],xmm6
  46967a:	jmp    4695fc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x87c>
  46967c:	mov    rbx,QWORD PTR [rcx+0x80]
  469683:	mov    QWORD PTR [rsp-0x10],rbx
  469688:	nop    DWORD PTR [rax+rax*1+0x0]
  469690:	lea    esi,[rax+0x18]
  469693:	and    esi,r8d
  469696:	shl    rsi,0x4
  46969a:	mov    r10d,ebx
  46969d:	and    r10d,DWORD PTR [r11+rsi*1+0x8]
  4696a2:	mov    esi,eax
  4696a4:	shl    rsi,0x4
  4696a8:	add    rsi,r11
  4696ab:	mov    r12,r10
  4696ae:	mov    r10,QWORD PTR [rsi]
  4696b1:	shl    r12,0x4
  4696b5:	prefetcht0 BYTE PTR [r14+r12*1]
  4696ba:	cmp    r10,QWORD PTR [rcx+0x90]
  4696c1:	jne    469700 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x980>
  4696c3:	kortestb k2,k2
  4696c7:	je     4696ea <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x96a>
  4696c9:	mov    r12d,DWORD PTR [r15]
  4696cc:	mov    esi,DWORD PTR [rsi+0xc]
  4696cf:	mov    r10,r12
  4696d2:	shl    r12,0x4
  4696d6:	add    r12,QWORD PTR [r15+0x8]
  4696da:	lea    r9d,[r10+0x1]
  4696de:	mov    DWORD PTR [r12],esi
  4696e2:	mov    QWORD PTR [r12+0x8],r13
  4696e7:	mov    DWORD PTR [r15],r9d
  4696ea:	inc    eax
  4696ec:	and    eax,r8d
  4696ef:	mov    DWORD PTR [rcx+0xc4],eax
  4696f5:	test   r13,r13
  4696f8:	jne    469690 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x910>
  4696fa:	jmp    46965b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8db>
  4696ff:	nop
  469700:	mov    r12d,DWORD PTR [rsi+0x8]
  469704:	mov    r9d,ebx
  469707:	and    r9d,r12d
  46970a:	shl    r9,0x4
  46970e:	add    r9,r14
  469711:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  469717:	vpbroadcastq zmm1,r10
  46971d:	vpcmpequq k0{k1},zmm0,zmm1
  469724:	kortestb k0,k0
  469728:	jne    4697a4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa24>
  46972a:	vpcmpequq k3{k1},zmm0,zmm2
  469731:	kortestb k3,k3
  469735:	jne    4697e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa68>
  46973b:	cmp    QWORD PTR [rsp],0x4
  469740:	mov    r9d,r12d
  469743:	je     469811 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa91>
  469749:	cmp    QWORD PTR [rsp],0x8
  46974e:	je     469832 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xab2>
  469754:	mov    r9d,DWORD PTR [rsp-0x28]
  469759:	mov    r12,QWORD PTR [rsp-0x10]
  46975e:	vmovd  xmm7,r9d
  469763:	vpinsrd xmm3,xmm7,DWORD PTR [rsi+0xc],0x1
  46976a:	mov    esi,edi
  46976c:	and    r12,QWORD PTR [rsp-0x28]
  469771:	shl    rsi,0x4
  469775:	inc    edi
  469777:	inc    eax
  469779:	add    rsi,r11
  46977c:	shl    r12,0x4
  469780:	and    edi,r8d
  469783:	and    eax,r8d
  469786:	prefetcht2 BYTE PTR [r14+r12*1]
  46978b:	mov    QWORD PTR [rsi],r10
  46978e:	vmovq  QWORD PTR [rsi+0x8],xmm3
  469793:	mov    DWORD PTR [rcx+0xc0],edi
  469799:	mov    DWORD PTR [rcx+0xc4],eax
  46979f:	jmp    469690 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x910>
  4697a4:	mov    r10d,DWORD PTR [r15]
  4697a7:	mov    r12d,DWORD PTR [rsi+0xc]
  4697ab:	mov    rbx,r10
  4697ae:	shl    r10,0x4
  4697b2:	add    r10,QWORD PTR [r15+0x8]
  4697b6:	mov    DWORD PTR [r10],r12d
  4697b9:	xor    r12d,r12d
  4697bc:	kmovb  esi,k0
  4697c0:	tzcnt  r12d,esi
  4697c5:	inc    r12d
  4697c8:	movsxd rsi,r12d
  4697cb:	mov    r9,QWORD PTR [r9+rsi*8]
  4697cf:	inc    eax
  4697d1:	inc    ebx
  4697d3:	and    eax,r8d
  4697d6:	mov    QWORD PTR [r10+0x8],r9
  4697da:	mov    DWORD PTR [r15],ebx
  4697dd:	mov    DWORD PTR [rcx+0xc4],eax
  4697e3:	jmp    46965b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8db>
  4697e8:	inc    eax
  4697ea:	and    eax,r8d
  4697ed:	mov    DWORD PTR [rcx+0xc4],eax
  4697f3:	jmp    46965b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8db>
  4697f8:	mov    eax,0xffffffff
  4697fd:	crc32  rax,QWORD PTR [rdx]
  469803:	mov    QWORD PTR [rsp-0x18],rax
  469808:	vmovd  xmm4,eax
  46980c:	jmp    4695fc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x87c>
  469811:	mov    r9d,0xffffffff
  469817:	crc32  r9d,r12d
  46981d:	mov    r12d,r9d
  469820:	mov    QWORD PTR [rsp-0x28],r12
  469825:	jmp    469759 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9d9>
  46982a:	xor    r12d,r12d
  46982d:	jmp    46911f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x39f>
  469832:	mov    r12d,0xffffffff
  469838:	crc32  r12,r9
  46983e:	mov    QWORD PTR [rsp-0x28],r12
  469843:	mov    r9d,r12d
  469846:	jmp    469759 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9d9>
  46984b:	inc    DWORD PTR [rsp-0x28]
  46984f:	jmp    468eea <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x16a>
  469854:	inc    DWORD PTR [rsp-0x28]
  469858:	jmp    468e7e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xfe>
  46985d:	inc    DWORD PTR [rsp-0x28]
  469861:	jmp    468f5a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1da>
  469866:	inc    DWORD PTR [rsp-0x28]
  46986a:	jmp    468fca <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x24a>
