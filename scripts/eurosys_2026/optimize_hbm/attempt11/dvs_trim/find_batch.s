0000000000468d50 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468d50:	push   rbp
  468d51:	mov    rcx,rdi
  468d54:	mov    r8,rdx
  468d57:	mov    rbp,rsp
  468d5a:	push   r15
  468d5c:	push   r14
  468d5e:	push   r13
  468d60:	push   r12
  468d62:	push   rbx
  468d63:	and    rsp,0xffffffffffffffc0
  468d67:	sub    rsp,0x8
  468d6b:	mov    r11,QWORD PTR [rsi+0x8]
  468d6f:	mov    edi,DWORD PTR [rdi+0xb0]
  468d75:	mov    eax,DWORD PTR [rcx+0xb4]
  468d7b:	mov    rdx,QWORD PTR [rsi]
  468d7e:	mov    r9d,DWORD PTR [rcx+0x78]
  468d82:	mov    r10d,DWORD PTR [rcx+0x6c]
  468d86:	mov    rbx,r11
  468d89:	mov    esi,edi
  468d8b:	shl    rbx,0x4
  468d8f:	sub    esi,eax
  468d91:	add    rbx,rdx
  468d94:	and    esi,r9d
  468d97:	lea    r12d,[r10-0x1]
  468d9b:	mov    QWORD PTR [rsp-0x20],rbx
  468da0:	cmp    esi,r12d
  468da3:	jb     4695db <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x88b>
  468da9:	and    r11,0xfffffffffffffffc
  468dad:	shl    r11,0x4
  468db1:	mov    r15,QWORD PTR [r8+0x8]
  468db5:	mov    esi,DWORD PTR [rcx+0x80]
  468dbb:	shl    r10,0x4
  468dbf:	mov    ebx,edi
  468dc1:	lea    r14,[rdx+r11*1]
  468dc5:	mov    QWORD PTR [rsp-0x18],r10
  468dca:	mov    QWORD PTR [rsp],r15
  468dce:	mov    QWORD PTR [rsp-0x38],r11
  468dd3:	mov    QWORD PTR [rsp-0x28],r14
  468dd8:	mov    DWORD PTR [rsp-0x2c],0x0
  468de0:	mov    r9,QWORD PTR [rcx+0xa0]
  468de7:	mov    rdi,QWORD PTR [rip+0x29dfa]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468dee:	dec    r10
  468df1:	shl    rax,0x4
  468df5:	shl    rbx,0x4
  468df9:	not    esi
  468dfb:	cmp    rdx,r14
  468dfe:	je     469873 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb23>
  468e04:	mov    r13d,0x55
  468e0a:	mov    r11d,0xf
  468e10:	mov    r15d,0xf0
  468e16:	mov    r14d,0xf00
  468e1c:	kmovb  k1,r13d
  468e21:	mov    r13d,0xfffff000
  468e27:	mov    QWORD PTR [rsp-0x40],rcx
  468e2c:	vpxor  xmm4,xmm4,xmm4
  468e30:	mov    r12d,0xffffffff
  468e36:	kmovw  k5,r11d
  468e3b:	kmovw  k4,r15d
  468e40:	kmovw  k3,r14d
  468e45:	kmovw  k2,r13d
  468e4a:	jmp    4690bd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x36d>
  468e4f:	nop
  468e50:	vmovd  xmm13,DWORD PTR [r15+0xc]
  468e56:	kshiftlb k6,k6,0x1
  468e5c:	vpcompressq zmm12{k6}{z},zmm8
  468e62:	vpunpcklqdq xmm14,xmm13,xmm12
  468e67:	vshufi32x4 zmm15{k5}{z},zmm14,zmm14,0x0
  468e6e:	vmovdqa64 zmm12,zmm15
  468e74:	mov    r11d,0x1
  468e7a:	lea    r13,[rax+0x180]
  468e81:	and    r13,r10
  468e84:	andn   ecx,esi,DWORD PTR [r9+r13*1+0x8]
  468e8b:	shl    rcx,0x4
  468e8f:	lea    r13,[r9+rax*1]
  468e93:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468e97:	mov    ecx,DWORD PTR [r13+0x8]
  468e9b:	andn   r14d,esi,ecx
  468ea0:	shl    r14,0x4
  468ea4:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r14*1]
  468eab:	vpbroadcastq zmm2,QWORD PTR [r13+0x0]
  468eb2:	vpcmpequq k0{k1},zmm0,zmm2
  468eb9:	add    rax,0x10
  468ebd:	and    rax,r10
  468ec0:	kortestb k0,k0
  468ec4:	je     469518 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7c8>
  468eca:	vmovd  xmm1,DWORD PTR [r13+0xc]
  468ed0:	kshiftlb k6,k0,0x1
  468ed6:	vpcompressq zmm5{k6}{z},zmm0
  468edc:	vpunpcklqdq xmm6,xmm1,xmm5
  468ee0:	vshufi32x4 zmm15{k4},zmm6,zmm6,0x0
  468ee7:	vmovdqa64 zmm12,zmm15
  468eed:	or     r11d,0x2
  468ef1:	lea    r15,[r9+rax*1]
  468ef5:	lea    r13,[rax+0x180]
  468efc:	and    r13,r10
  468eff:	andn   ecx,esi,DWORD PTR [r9+r13*1+0x8]
  468f06:	shl    rcx,0x4
  468f0a:	mov    r13d,DWORD PTR [r15+0x8]
  468f0e:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468f12:	andn   ecx,esi,r13d
  468f17:	shl    rcx,0x4
  468f1b:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+rcx*1]
  468f22:	vpbroadcastq zmm9,QWORD PTR [r15]
  468f28:	vpcmpequq k0{k1},zmm8,zmm9
  468f2f:	add    rax,0x10
  468f33:	and    rax,r10
  468f36:	kortestb k0,k0
  468f3a:	je     4694d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x780>
  468f40:	vmovd  xmm13,DWORD PTR [r15+0xc]
  468f46:	kshiftlb k6,k0,0x1
  468f4c:	vpcompressq zmm12{k6}{z},zmm8
  468f52:	vpunpcklqdq xmm14,xmm13,xmm12
  468f57:	vshufi32x4 zmm15{k3},zmm14,zmm14,0x0
  468f5e:	vmovdqa64 zmm12,zmm15
  468f64:	or     r11d,0x4
  468f68:	lea    r13,[r9+rax*1]
  468f6c:	lea    r15,[rax+0x180]
  468f73:	and    r15,r10
  468f76:	mov    r14d,DWORD PTR [r13+0x8]
  468f7a:	andn   ecx,esi,DWORD PTR [r9+r15*1+0x8]
  468f81:	shl    rcx,0x4
  468f85:	andn   r15d,esi,r14d
  468f8a:	shl    r15,0x4
  468f8e:	vmovdqa64 zmm0,ZMMWORD PTR [rdi+r15*1]
  468f95:	vpbroadcastq zmm2,QWORD PTR [r13+0x0]
  468f9c:	vpcmpequq k0{k1},zmm0,zmm2
  468fa3:	add    rax,0x10
  468fa7:	and    rax,r10
  468faa:	prefetcht0 BYTE PTR [rdi+rcx*1]
  468fae:	kortestb k0,k0
  468fb2:	lea    rcx,[r9+rbx*1]
  468fb6:	je     469488 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
  468fbc:	vmovd  xmm1,DWORD PTR [r13+0xc]
  468fc2:	kshiftlb k6,k0,0x1
  468fc8:	vpcompressq zmm5{k6}{z},zmm0
  468fce:	vpunpcklqdq xmm6,xmm1,xmm5
  468fd2:	vshufi32x4 zmm15{k2},zmm6,zmm6,0x0
  468fd9:	or     r11d,0x8
  468fdd:	vmovdqa64 zmm12,zmm15
  468fe3:	cmp    r11d,0xf
  468fe7:	jne    4695a8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x858>
  468fed:	mov    r15,QWORD PTR [rsp]
  468ff1:	vmovdqu64 ZMMWORD PTR [r15],zmm15
  468ff7:	add    r15,0x40
  468ffb:	mov    QWORD PTR [rsp],r15
  468fff:	mov    r15,r12
  469002:	crc32  r15,QWORD PTR [rdx]
  469008:	andn   r13d,esi,r15d
  46900d:	shl    r13,0x4
  469011:	prefetcht2 BYTE PTR [rdi+r13*1]
  469016:	mov    r13,r12
  469019:	crc32  r13,QWORD PTR [rdx+0x20]
  469020:	mov    r11,r12
  469023:	crc32  r11,QWORD PTR [rdx+0x10]
  46902a:	vmovq  xmm15,r13
  46902f:	andn   r14d,esi,r11d
  469034:	shl    r14,0x4
  469038:	prefetcht2 BYTE PTR [rdi+r14*1]
  46903d:	mov    r14d,r13d
  469040:	andn   r13d,esi,r14d
  469045:	shl    r13,0x4
  469049:	prefetcht2 BYTE PTR [rdi+r13*1]
  46904e:	mov    r13,r12
  469051:	crc32  r13,QWORD PTR [rdx+0x30]
  469058:	vmovd  xmm9,r15d
  46905d:	vpinsrd xmm10,xmm9,r11d,0x1
  469063:	vmovdqu32 zmm13,ZMMWORD PTR [rdx]
  469069:	vpinsrd xmm8,xmm15,r13d,0x1
  46906f:	vpunpcklqdq xmm11,xmm10,xmm8
  469074:	mov    r15d,0x4444
  46907a:	lea    r11,[rbx+0x40]
  46907e:	andn   r14d,esi,r13d
  469083:	shl    r14,0x4
  469087:	kmovw  k6,r15d
  46908c:	prefetcht2 BYTE PTR [rdi+r14*1]
  469091:	vpexpandd zmm13{k6},zmm11
  469097:	cmp    QWORD PTR [rsp-0x18],r11
  46909c:	jb     469560 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x810>
  4690a2:	vmovdqu64 ZMMWORD PTR [rcx],zmm13
  4690a8:	mov    rbx,r11
  4690ab:	add    rdx,0x40
  4690af:	and    rbx,r10
  4690b2:	cmp    QWORD PTR [rsp-0x28],rdx
  4690b7:	je     469150 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x400>
  4690bd:	lea    r15,[r9+rax*1]
  4690c1:	mov    r13d,DWORD PTR [r15+0x8]
  4690c5:	andn   r14d,esi,r13d
  4690ca:	shl    r14,0x4
  4690ce:	vmovdqa64 zmm8,ZMMWORD PTR [rdi+r14*1]
  4690d5:	vpbroadcastq zmm9,QWORD PTR [r15]
  4690db:	vpcmpequq k6{k1},zmm8,zmm9
  4690e2:	lea    r11,[rax+0x180]
  4690e9:	add    rax,0x10
  4690ed:	and    r11,r10
  4690f0:	and    rax,r10
  4690f3:	andn   ecx,esi,DWORD PTR [r9+r11*1+0x8]
  4690fa:	shl    rcx,0x4
  4690fe:	kortestb k6,k6
  469102:	prefetcht0 BYTE PTR [rdi+rcx*1]
  469106:	jne    468e50 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x100>
  46910c:	vpcmpequq k7{k1},zmm8,zmm4
  469113:	kortestb k7,k7
  469117:	jne    46989c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb4c>
  46911d:	vmovdqu xmm10,XMMWORD PTR [r15]
  469122:	mov    r11,r12
  469125:	crc32  r11,r13
  46912b:	vpinsrd xmm11,xmm10,r11d,0x2
  469131:	andn   ecx,esi,r11d
  469136:	shl    rcx,0x4
  46913a:	prefetcht2 BYTE PTR [rdi+rcx*1]
  46913e:	vmovdqu XMMWORD PTR [r9+rbx*1],xmm11
  469144:	add    rbx,0x10
  469148:	and    rbx,r10
  46914b:	jmp    4690bd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x36d>
  469150:	mov    rcx,QWORD PTR [rsp-0x40]
  469155:	mov    edi,DWORD PTR [rsp-0x2c]
  469159:	vmovq  xmm14,rbx
  46915e:	vpinsrq xmm0,xmm14,rax,0x1
  469164:	mov    rsi,QWORD PTR [rsp-0x38]
  469169:	vpsrlq xmm2,xmm0,0x4
  46916e:	vpmovqd xmm7,xmm2
  469174:	sar    rsi,0x4
  469178:	vmovq  QWORD PTR [rcx+0xb0],xmm7
  469180:	sub    rsi,rdi
  469183:	add    DWORD PTR [r8],esi
  469186:	vpextrd eax,xmm7,0x1
  46918c:	cmp    rdx,QWORD PTR [rsp-0x20]
  469191:	je     469470 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  469197:	mov    rdi,QWORD PTR [rcx+0x88]
  46919e:	mov    r12,QWORD PTR [rcx+0x80]
  4691a5:	mov    r9,QWORD PTR [rcx+0x60]
  4691a9:	dec    rdi
  4691ac:	mov    QWORD PTR [rsp-0x18],r12
  4691b1:	mov    QWORD PTR [rsp],r9
  4691b5:	mov    QWORD PTR [rsp-0x28],rdi
  4691ba:	mov    r11d,DWORD PTR [rcx+0x78]
  4691be:	mov    rbx,QWORD PTR [rip+0x29a23]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4691c5:	mov    r10,QWORD PTR [rcx+0xa0]
  4691cc:	movzx  r14d,BYTE PTR [rip+0x2992c]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4691d4:	mov    r13,QWORD PTR [rip+0x2992d]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4691db:	mov    r15d,0x55
  4691e1:	vpxor  xmm3,xmm3,xmm3
  4691e5:	kmovb  k1,r15d
  4691ea:	nop    WORD PTR [rax+rax*1+0x0]
  4691f0:	lea    esi,[rax+0x18]
  4691f3:	and    esi,r11d
  4691f6:	shl    rsi,0x4
  4691fa:	mov    r9d,r12d
  4691fd:	and    r9d,DWORD PTR [r10+rsi*1+0x8]
  469202:	mov    esi,eax
  469204:	shl    rsi,0x4
  469208:	add    rsi,r10
  46920b:	mov    r15,r9
  46920e:	mov    r9,QWORD PTR [rsi]
  469211:	shl    r15,0x4
  469215:	prefetcht0 BYTE PTR [rbx+r15*1]
  46921a:	cmp    r9,QWORD PTR [rcx+0x90]
  469221:	jne    4692e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x590>
  469227:	test   r14b,r14b
  46922a:	je     46924a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fa>
  46922c:	mov    r15d,DWORD PTR [r8]
  46922f:	mov    esi,DWORD PTR [rsi+0xc]
  469232:	mov    r9,r15
  469235:	shl    r15,0x4
  469239:	add    r15,QWORD PTR [r8+0x8]
  46923d:	inc    r9d
  469240:	mov    DWORD PTR [r15],esi
  469243:	mov    QWORD PTR [r15+0x8],r13
  469247:	mov    DWORD PTR [r8],r9d
  46924a:	inc    eax
  46924c:	and    eax,r11d
  46924f:	mov    DWORD PTR [rcx+0xb4],eax
  469255:	test   r13,r13
  469258:	jne    4691f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  46925a:	cmp    QWORD PTR [rsp],0x4
  46925f:	je     4693d5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x685>
  469265:	nop    DWORD PTR [rax]
  469268:	cmp    QWORD PTR [rsp],0x8
  46926d:	je     469450 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
  469273:	vmovd  xmm15,DWORD PTR [rsp-0x10]
  469279:	mov    rdi,QWORD PTR [rdx]
  46927c:	mov    esi,DWORD PTR [rcx+0xb0]
  469282:	mov    r9,QWORD PTR [rsp-0x28]
  469287:	mov    rax,rsi
  46928a:	and    r9,QWORD PTR [rsp-0x10]
  46928f:	vpinsrd xmm9,xmm15,DWORD PTR [rdx+0xc],0x1
  469296:	and    r9,0xfffffffffffffffc
  46929a:	shl    rsi,0x4
  46929e:	inc    eax
  4692a0:	add    rsi,r10
  4692a3:	shl    r9,0x4
  4692a7:	and    eax,r11d
  4692aa:	add    rdx,0x10
  4692ae:	prefetcht2 BYTE PTR [rbx+r9*1]
  4692b3:	mov    QWORD PTR [rsi],rdi
  4692b6:	vmovq  QWORD PTR [rsi+0x8],xmm9
  4692bb:	mov    DWORD PTR [rcx+0xb0],eax
  4692c1:	cmp    rdx,QWORD PTR [rsp-0x20]
  4692c6:	je     469470 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  4692cc:	mov    eax,DWORD PTR [rcx+0xb4]
  4692d2:	jmp    4691f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  4692d7:	nop    WORD PTR [rax+rax*1+0x0]
  4692e0:	mov    r15d,DWORD PTR [rsi+0x8]
  4692e4:	mov    edi,r12d
  4692e7:	and    edi,r15d
  4692ea:	shl    rdi,0x4
  4692ee:	add    rdi,rbx
  4692f1:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  4692f7:	vpbroadcastq zmm1,r9
  4692fd:	vpcmpequq k0{k1},zmm5,zmm1
  469304:	kortestb k0,k0
  469308:	jne    469390 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x640>
  46930e:	vpcmpequq k2{k1},zmm5,zmm3
  469315:	kortestb k2,k2
  469319:	jne    469400 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  46931f:	cmp    QWORD PTR [rsp],0x4
  469324:	mov    edi,r15d
  469327:	je     469410 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  46932d:	cmp    QWORD PTR [rsp],0x8
  469332:	je     469430 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
  469338:	vmovd  xmm12,DWORD PTR [rsp-0x8]
  46933e:	mov    edi,DWORD PTR [rcx+0xb0]
  469344:	mov    r15,QWORD PTR [rsp-0x18]
  469349:	vpinsrd xmm4,xmm12,DWORD PTR [rsi+0xc],0x1
  469350:	mov    rsi,rdi
  469353:	and    r15,QWORD PTR [rsp-0x8]
  469358:	shl    rdi,0x4
  46935c:	inc    esi
  46935e:	inc    eax
  469360:	add    rdi,r10
  469363:	shl    r15,0x4
  469367:	and    esi,r11d
  46936a:	and    eax,r11d
  46936d:	prefetcht2 BYTE PTR [rbx+r15*1]
  469372:	mov    QWORD PTR [rdi],r9
  469375:	vmovq  QWORD PTR [rdi+0x8],xmm4
  46937a:	mov    DWORD PTR [rcx+0xb0],esi
  469380:	mov    DWORD PTR [rcx+0xb4],eax
  469386:	jmp    4691f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  46938b:	nop    DWORD PTR [rax+rax*1+0x0]
  469390:	mov    r9d,DWORD PTR [r8]
  469393:	mov    esi,DWORD PTR [rsi+0xc]
  469396:	mov    r15,r9
  469399:	shl    r9,0x4
  46939d:	add    r9,QWORD PTR [r8+0x8]
  4693a1:	mov    DWORD PTR [r9],esi
  4693a4:	kmovb  esi,k0
  4693a8:	tzcnt  esi,esi
  4693ac:	inc    esi
  4693ae:	movsxd rsi,esi
  4693b1:	mov    rdi,QWORD PTR [rdi+rsi*8]
  4693b5:	inc    eax
  4693b7:	inc    r15d
  4693ba:	and    eax,r11d
  4693bd:	cmp    QWORD PTR [rsp],0x4
  4693c2:	mov    QWORD PTR [r9+0x8],rdi
  4693c6:	mov    DWORD PTR [r8],r15d
  4693c9:	mov    DWORD PTR [rcx+0xb4],eax
  4693cf:	jne    469268 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x518>
  4693d5:	mov    r15d,0xffffffff
  4693db:	crc32  r15d,DWORD PTR [rdx]
  4693e1:	vmovd  xmm8,r15d
  4693e6:	mov    rdi,QWORD PTR [rdx]
  4693e9:	vmovdqa xmm15,xmm8
  4693ee:	vmovq  QWORD PTR [rsp-0x10],xmm8
  4693f4:	jmp    46927c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  4693f9:	nop    DWORD PTR [rax+0x0]
  469400:	inc    eax
  469402:	and    eax,r11d
  469405:	mov    DWORD PTR [rcx+0xb4],eax
  46940b:	jmp    46925a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
  469410:	mov    edi,0xffffffff
  469415:	crc32  edi,r15d
  46941b:	vmovd  xmm6,edi
  46941f:	vmovdqa xmm12,xmm6
  469423:	vmovq  QWORD PTR [rsp-0x8],xmm6
  469429:	jmp    46933e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ee>
  46942e:	xchg   ax,ax
  469430:	mov    r15d,0xffffffff
  469436:	crc32  r15,rdi
  46943c:	mov    QWORD PTR [rsp-0x8],r15
  469441:	vmovd  xmm12,r15d
  469446:	jmp    46933e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ee>
  46944b:	nop    DWORD PTR [rax+rax*1+0x0]
  469450:	mov    rdi,QWORD PTR [rdx]
  469453:	mov    eax,0xffffffff
  469458:	crc32  rax,rdi
  46945e:	mov    QWORD PTR [rsp-0x10],rax
  469463:	vmovd  xmm15,eax
  469467:	jmp    46927c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  46946c:	nop    DWORD PTR [rax+0x0]
  469470:	vzeroupper 
  469473:	lea    rsp,[rbp-0x28]
  469477:	pop    rbx
  469478:	pop    r12
  46947a:	pop    r13
  46947c:	pop    r14
  46947e:	pop    r15
  469480:	pop    rbp
  469481:	ret    
  469482:	nop    WORD PTR [rax+rax*1+0x0]
  469488:	vpcmpequq k7{k1},zmm0,zmm4
  46948f:	kortestb k7,k7
  469493:	jne    4695a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x850>
  469499:	vmovdqu xmm7,XMMWORD PTR [r13+0x0]
  46949f:	mov    r15,r12
  4694a2:	crc32  r15,r14
  4694a8:	vpinsrd xmm3,xmm7,r15d,0x2
  4694ae:	add    rbx,0x10
  4694b2:	andn   r14d,esi,r15d
  4694b7:	shl    r14,0x4
  4694bb:	and    rbx,r10
  4694be:	prefetcht2 BYTE PTR [rdi+r14*1]
  4694c3:	vmovdqu XMMWORD PTR [rcx],xmm3
  4694c7:	jmp    468f68 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x218>
  4694cc:	nop    DWORD PTR [rax+0x0]
  4694d0:	vpcmpequq k7{k1},zmm8,zmm4
  4694d7:	kortestb k7,k7
  4694db:	jne    4698b2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb62>
  4694e1:	vmovdqu xmm10,XMMWORD PTR [r15]
  4694e6:	mov    r14,r12
  4694e9:	crc32  r14,r13
  4694ef:	vpinsrd xmm11,xmm10,r14d,0x2
  4694f5:	andn   r13d,esi,r14d
  4694fa:	shl    r13,0x4
  4694fe:	prefetcht2 BYTE PTR [rdi+r13*1]
  469503:	vmovdqu XMMWORD PTR [r9+rbx*1],xmm11
  469509:	add    rbx,0x10
  46950d:	and    rbx,r10
  469510:	jmp    468ef1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a1>
  469515:	nop    DWORD PTR [rax]
  469518:	vpcmpequq k7{k1},zmm0,zmm4
  46951f:	kortestb k7,k7
  469523:	jne    469893 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb43>
  469529:	vmovdqu xmm7,XMMWORD PTR [r13+0x0]
  46952f:	mov    r15,r12
  469532:	crc32  r15,rcx
  469538:	vpinsrd xmm3,xmm7,r15d,0x2
  46953e:	andn   ecx,esi,r15d
  469543:	shl    rcx,0x4
  469547:	prefetcht2 BYTE PTR [rdi+rcx*1]
  46954b:	vmovdqu XMMWORD PTR [r9+rbx*1],xmm3
  469551:	add    rbx,0x10
  469555:	and    rbx,r10
  469558:	jmp    468e7a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x12a>
  46955d:	nop    DWORD PTR [rax]
  469560:	mov    r15,QWORD PTR [rsp-0x18]
  469565:	mov    r14d,0x1
  46956b:	mov    r13,r15
  46956e:	sub    r13,rbx
  469571:	shr    r13,0x2
  469575:	shlx   r13d,r14d,r13d
  46957a:	lea    r14d,[r13-0x1]
  46957e:	sub    rbx,r15
  469581:	neg    r13d
  469584:	kmovw  k7,r14d
  469589:	vmovdqu32 ZMMWORD PTR [rcx]{k7},zmm13
  46958f:	kmovw  k6,r13d
  469594:	vmovdqu32 ZMMWORD PTR [r9+rbx*1]{k6},zmm13
  46959b:	jmp    4690a8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x358>
  4695a0:	inc    DWORD PTR [rsp-0x2c]
  4695a4:	nop    DWORD PTR [rax+0x0]
  4695a8:	mov    r14,QWORD PTR [rsp]
  4695ac:	mov    r13d,0x55
  4695b2:	pdep   r15d,r11d,r13d
  4695b7:	popcnt r11d,r11d
  4695bc:	lea    r13d,[r15+r15*2]
  4695c0:	shl    r11,0x4
  4695c4:	kmovb  k7,r13d
  4695c9:	vpcompressq ZMMWORD PTR [r14]{k7},zmm12
  4695cf:	add    r14,r11
  4695d2:	mov    QWORD PTR [rsp],r14
  4695d6:	jmp    468fff <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2af>
  4695db:	cmp    rdx,QWORD PTR [rsp-0x20]
  4695e0:	je     469473 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x723>
  4695e6:	mov    r11,QWORD PTR [rcx+0x88]
  4695ed:	mov    r10,QWORD PTR [rcx+0x60]
  4695f1:	mov    r13d,0x55
  4695f7:	dec    r11
  4695fa:	mov    QWORD PTR [rsp],r10
  4695fe:	mov    QWORD PTR [rsp-0x8],r11
  469603:	mov    r15,QWORD PTR [rip+0x295de]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46960a:	mov    r14,QWORD PTR [rip+0x294f7]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469611:	mov    rbx,QWORD PTR [rcx+0xa0]
  469618:	mov    r12d,edi
  46961b:	vpxor  xmm2,xmm2,xmm2
  46961f:	kmovb  k2,BYTE PTR [rip+0x294d9]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469627:	kmovb  k1,r13d
  46962c:	jmp    469697 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x947>
  46962e:	cmp    QWORD PTR [rsp],0x8
  469633:	je     469841 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaf1>
  469639:	vmovd  xmm4,DWORD PTR [rsp-0x18]
  46963f:	mov    r13,QWORD PTR [rsp-0x8]
  469644:	mov    esi,edi
  469646:	and    r13,QWORD PTR [rsp-0x18]
  46964b:	vpinsrd xmm6,xmm4,DWORD PTR [rdx+0xc],0x1
  469652:	mov    r11,QWORD PTR [rdx]
  469655:	and    r13,0xfffffffffffffffc
  469659:	shl    rsi,0x4
  46965d:	lea    r12d,[rdi+0x1]
  469661:	add    rsi,rbx
  469664:	shl    r13,0x4
  469668:	and    r12d,r9d
  46966b:	add    rdx,0x10
  46966f:	prefetcht2 BYTE PTR [r15+r13*1]
  469674:	mov    QWORD PTR [rsi],r11
  469677:	vmovq  QWORD PTR [rsi+0x8],xmm6
  46967c:	mov    DWORD PTR [rcx+0xb0],r12d
  469683:	cmp    QWORD PTR [rsp-0x20],rdx
  469688:	je     469470 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  46968e:	mov    eax,DWORD PTR [rcx+0xb4]
  469694:	mov    edi,r12d
  469697:	sub    r12d,eax
  46969a:	and    r12d,r9d
  46969d:	cmp    r9d,r12d
  4696a0:	jbe    4696c9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x979>
  4696a2:	cmp    QWORD PTR [rsp],0x4
  4696a7:	jne    46962e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8de>
  4696a9:	mov    r12d,0xffffffff
  4696af:	crc32  r12d,DWORD PTR [rdx]
  4696b5:	vmovd  xmm5,r12d
  4696ba:	vmovdqa xmm4,xmm5
  4696be:	vmovq  QWORD PTR [rsp-0x18],xmm5
  4696c4:	jmp    46963f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8ef>
  4696c9:	mov    r12,QWORD PTR [rcx+0x80]
  4696d0:	mov    QWORD PTR [rsp-0x10],r12
  4696d5:	nop    DWORD PTR [rax]
  4696d8:	lea    esi,[rax+0x18]
  4696db:	and    esi,r9d
  4696de:	shl    rsi,0x4
  4696e2:	mov    r10d,r12d
  4696e5:	and    r10d,DWORD PTR [rbx+rsi*1+0x8]
  4696ea:	mov    esi,eax
  4696ec:	shl    rsi,0x4
  4696f0:	add    rsi,rbx
  4696f3:	mov    r11,QWORD PTR [rsi]
  4696f6:	shl    r10,0x4
  4696fa:	prefetcht0 BYTE PTR [r15+r10*1]
  4696ff:	cmp    r11,QWORD PTR [rcx+0x90]
  469706:	jne    469748 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9f8>
  469708:	kortestb k2,k2
  46970c:	je     46972e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9de>
  46970e:	mov    r13d,DWORD PTR [r8]
  469711:	mov    esi,DWORD PTR [rsi+0xc]
  469714:	mov    r11,r13
  469717:	shl    r13,0x4
  46971b:	add    r13,QWORD PTR [r8+0x8]
  46971f:	lea    r10d,[r11+0x1]
  469723:	mov    DWORD PTR [r13+0x0],esi
  469727:	mov    QWORD PTR [r13+0x8],r14
  46972b:	mov    DWORD PTR [r8],r10d
  46972e:	inc    eax
  469730:	and    eax,r9d
  469733:	mov    DWORD PTR [rcx+0xb4],eax
  469739:	test   r14,r14
  46973c:	jne    4696d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x988>
  46973e:	jmp    4696a2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x952>
  469743:	nop    DWORD PTR [rax+rax*1+0x0]
  469748:	mov    r13d,DWORD PTR [rsi+0x8]
  46974c:	mov    r10d,r12d
  46974f:	and    r10d,r13d
  469752:	shl    r10,0x4
  469756:	add    r10,r15
  469759:	vmovdqa64 zmm0,ZMMWORD PTR [r10]
  46975f:	vpbroadcastq zmm1,r11
  469765:	vpcmpequq k0{k1},zmm0,zmm1
  46976c:	kortestb k0,k0
  469770:	jne    4697ec <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa9c>
  469772:	vpcmpequq k3{k1},zmm0,zmm2
  469779:	kortestb k3,k3
  46977d:	jne    469831 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xae1>
  469783:	cmp    QWORD PTR [rsp],0x4
  469788:	mov    r10d,r13d
  46978b:	je     46985a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb0a>
  469791:	cmp    QWORD PTR [rsp],0x8
  469796:	je     46987a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb2a>
  46979c:	mov    r10d,DWORD PTR [rsp-0x28]
  4697a1:	mov    r13,QWORD PTR [rsp-0x10]
  4697a6:	vmovd  xmm7,r10d
  4697ab:	vpinsrd xmm3,xmm7,DWORD PTR [rsi+0xc],0x1
  4697b2:	mov    esi,edi
  4697b4:	and    r13,QWORD PTR [rsp-0x28]
  4697b9:	shl    rsi,0x4
  4697bd:	inc    edi
  4697bf:	inc    eax
  4697c1:	add    rsi,rbx
  4697c4:	shl    r13,0x4
  4697c8:	and    edi,r9d
  4697cb:	and    eax,r9d
  4697ce:	prefetcht2 BYTE PTR [r15+r13*1]
  4697d3:	mov    QWORD PTR [rsi],r11
  4697d6:	vmovq  QWORD PTR [rsi+0x8],xmm3
  4697db:	mov    DWORD PTR [rcx+0xb0],edi
  4697e1:	mov    DWORD PTR [rcx+0xb4],eax
  4697e7:	jmp    4696d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x988>
  4697ec:	mov    r11d,DWORD PTR [r8]
  4697ef:	mov    r13d,DWORD PTR [rsi+0xc]
  4697f3:	mov    r12,r11
  4697f6:	shl    r11,0x4
  4697fa:	add    r11,QWORD PTR [r8+0x8]
  4697fe:	mov    DWORD PTR [r11],r13d
  469801:	xor    r13d,r13d
  469804:	kmovb  esi,k0
  469808:	tzcnt  r13d,esi
  46980d:	inc    r13d
  469810:	movsxd rsi,r13d
  469813:	mov    r10,QWORD PTR [r10+rsi*8]
  469817:	inc    eax
  469819:	inc    r12d
  46981c:	and    eax,r9d
  46981f:	mov    QWORD PTR [r11+0x8],r10
  469823:	mov    DWORD PTR [r8],r12d
  469826:	mov    DWORD PTR [rcx+0xb4],eax
  46982c:	jmp    4696a2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x952>
  469831:	inc    eax
  469833:	and    eax,r9d
  469836:	mov    DWORD PTR [rcx+0xb4],eax
  46983c:	jmp    4696a2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x952>
  469841:	mov    eax,0xffffffff
  469846:	crc32  rax,QWORD PTR [rdx]
  46984c:	mov    QWORD PTR [rsp-0x18],rax
  469851:	vmovd  xmm4,eax
  469855:	jmp    46963f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8ef>
  46985a:	mov    r10d,0xffffffff
  469860:	crc32  r10d,r13d
  469866:	mov    r13d,r10d
  469869:	mov    QWORD PTR [rsp-0x28],r13
  46986e:	jmp    4697a1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa51>
  469873:	xor    edi,edi
  469875:	jmp    469159 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x409>
  46987a:	mov    r13d,0xffffffff
  469880:	crc32  r13,r10
  469886:	mov    QWORD PTR [rsp-0x28],r13
  46988b:	mov    r10d,r13d
  46988e:	jmp    4697a1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa51>
  469893:	inc    DWORD PTR [rsp-0x2c]
  469897:	jmp    468ef1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a1>
  46989c:	inc    DWORD PTR [rsp-0x2c]
  4698a0:	vpxor  xmm15,xmm15,xmm15
  4698a5:	xor    r11d,r11d
  4698a8:	vpxor  xmm12,xmm12,xmm12
  4698ad:	jmp    468e7a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x12a>
  4698b2:	inc    DWORD PTR [rsp-0x2c]
  4698b6:	jmp    468f68 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x218>
