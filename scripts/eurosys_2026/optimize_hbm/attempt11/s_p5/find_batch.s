0000000000468d30 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468d30:	push   rbp
  468d31:	mov    rcx,rdi
  468d34:	mov    rbp,rsp
  468d37:	push   r15
  468d39:	mov    r15,rdx
  468d3c:	push   r14
  468d3e:	push   r13
  468d40:	push   r12
  468d42:	push   rbx
  468d43:	and    rsp,0xffffffffffffffc0
  468d47:	sub    rsp,0x8
  468d4b:	mov    rdi,QWORD PTR [rsi]
  468d4e:	mov    r11,QWORD PTR [rsi+0x8]
  468d52:	mov    esi,DWORD PTR [rcx+0xb0]
  468d58:	mov    eax,DWORD PTR [rcx+0xb4]
  468d5e:	mov    r8d,DWORD PTR [rcx+0x78]
  468d62:	mov    r10d,DWORD PTR [rcx+0x6c]
  468d66:	mov    r9,r11
  468d69:	mov    edx,esi
  468d6b:	shl    r9,0x4
  468d6f:	sub    edx,eax
  468d71:	lea    rbx,[rdi+r9*1]
  468d75:	and    edx,r8d
  468d78:	lea    r12d,[r10-0x1]
  468d7c:	mov    QWORD PTR [rsp-0x20],rbx
  468d81:	cmp    edx,r12d
  468d84:	jb     46958f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x85f>
  468d8a:	shl    rsi,0x4
  468d8e:	and    r11,0xfffffffffffffffc
  468d92:	shl    r11,0x4
  468d96:	mov    r14,rsi
  468d99:	mov    esi,DWORD PTR [rcx+0x80]
  468d9f:	shl    r10,0x4
  468da3:	mov    QWORD PTR [rsp-0x30],r11
  468da8:	lea    r11,[rdi+r11*1]
  468dac:	mov    QWORD PTR [rsp],r10
  468db0:	mov    QWORD PTR [rsp-0x18],r11
  468db5:	mov    DWORD PTR [rsp-0x28],0x0
  468dbd:	mov    r9,QWORD PTR [rcx+0xa0]
  468dc4:	mov    rdx,QWORD PTR [r15+0x8]
  468dc8:	mov    r8,QWORD PTR [rip+0x29e19]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468dcf:	dec    r10
  468dd2:	shl    rax,0x4
  468dd6:	not    esi
  468dd8:	cmp    rdi,r11
  468ddb:	je     46982a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xafa>
  468de1:	mov    r13d,0x55
  468de7:	mov    ebx,0x4444
  468dec:	mov    QWORD PTR [rsp-0x38],rcx
  468df1:	mov    QWORD PTR [rsp-0x40],r15
  468df6:	vpxor  xmm2,xmm2,xmm2
  468dfa:	kmovb  k1,r13d
  468dff:	kmovw  k2,ebx
  468e03:	jmp    469047 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x317>
  468e08:	nop    DWORD PTR [rax+rax*1+0x0]
  468e10:	xor    ecx,ecx
  468e12:	kmovb  r15d,k4
  468e16:	tzcnt  ecx,r15d
  468e1b:	inc    ecx
  468e1d:	movsxd r12,ecx
  468e20:	mov    ebx,DWORD PTR [r13+0xc]
  468e24:	mov    r11,QWORD PTR [r11+r12*8]
  468e28:	mov    DWORD PTR [rdx],ebx
  468e2a:	mov    QWORD PTR [rdx+0x8],r11
  468e2e:	add    rdx,0x10
  468e32:	lea    r15,[r9+rax*1]
  468e36:	lea    r13,[rax+0x180]
  468e3d:	and    r13,r10
  468e40:	andn   ecx,esi,DWORD PTR [r9+r13*1+0x8]
  468e47:	shl    rcx,0x4
  468e4b:	mov    r13d,DWORD PTR [r15+0x8]
  468e4f:	andn   r12d,esi,r13d
  468e54:	shl    r12,0x4
  468e58:	add    r12,r8
  468e5b:	vmovdqa64 zmm12,ZMMWORD PTR [r12]
  468e62:	vpbroadcastq zmm13,QWORD PTR [r15]
  468e68:	vpcmpequq k6{k1},zmm12,zmm13
  468e6f:	add    rax,0x10
  468e73:	and    rax,r10
  468e76:	prefetcht0 BYTE PTR [r8+rcx*1]
  468e7b:	kortestb k6,k6
  468e7f:	je     4694d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7a8>
  468e85:	xor    r11d,r11d
  468e88:	kmovb  r13d,k6
  468e8c:	tzcnt  r11d,r13d
  468e91:	inc    r11d
  468e94:	movsxd rcx,r11d
  468e97:	mov    r15d,DWORD PTR [r15+0xc]
  468e9b:	mov    r12,QWORD PTR [r12+rcx*8]
  468e9f:	mov    DWORD PTR [rdx],r15d
  468ea2:	mov    QWORD PTR [rdx+0x8],r12
  468ea6:	add    rdx,0x10
  468eaa:	lea    r13,[r9+rax*1]
  468eae:	lea    r15,[rax+0x180]
  468eb5:	and    r15,r10
  468eb8:	andn   ecx,esi,DWORD PTR [r9+r15*1+0x8]
  468ebf:	shl    rcx,0x4
  468ec3:	mov    r15d,DWORD PTR [r13+0x8]
  468ec7:	andn   r11d,esi,r15d
  468ecc:	shl    r11,0x4
  468ed0:	add    r11,r8
  468ed3:	vmovdqa64 zmm0,ZMMWORD PTR [r11]
  468ed9:	vpbroadcastq zmm1,QWORD PTR [r13+0x0]
  468ee0:	vpcmpequq k0{k1},zmm0,zmm1
  468ee7:	add    rax,0x10
  468eeb:	and    rax,r10
  468eee:	prefetcht0 BYTE PTR [r8+rcx*1]
  468ef3:	kortestb k0,k0
  468ef7:	je     469480 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x750>
  468efd:	xor    ecx,ecx
  468eff:	kmovb  r12d,k0
  468f03:	tzcnt  ecx,r12d
  468f08:	inc    ecx
  468f0a:	movsxd rbx,ecx
  468f0d:	mov    r15d,DWORD PTR [r13+0xc]
  468f11:	mov    r11,QWORD PTR [r11+rbx*8]
  468f15:	mov    DWORD PTR [rdx],r15d
  468f18:	mov    QWORD PTR [rdx+0x8],r11
  468f1c:	add    rdx,0x10
  468f20:	lea    rbx,[r9+rax*1]
  468f24:	mov    r12d,DWORD PTR [rbx+0x8]
  468f28:	andn   r11d,esi,r12d
  468f2d:	shl    r11,0x4
  468f31:	add    r11,r8
  468f34:	vmovdqa64 zmm4,ZMMWORD PTR [r11]
  468f3a:	vpbroadcastq zmm5,QWORD PTR [rbx]
  468f40:	vpcmpequq k4{k1},zmm4,zmm5
  468f47:	lea    r13,[rax+0x180]
  468f4e:	add    rax,0x10
  468f52:	and    r13,r10
  468f55:	and    rax,r10
  468f58:	andn   ecx,esi,DWORD PTR [r9+r13*1+0x8]
  468f5f:	shl    rcx,0x4
  468f63:	kortestb k4,k4
  468f67:	prefetcht0 BYTE PTR [r8+rcx*1]
  468f6c:	lea    rcx,[r9+r14*1]
  468f70:	je     469428 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6f8>
  468f76:	xor    r15d,r15d
  468f79:	kmovb  r13d,k4
  468f7d:	tzcnt  r15d,r13d
  468f82:	inc    r15d
  468f85:	mov    r12d,DWORD PTR [rbx+0xc]
  468f89:	movsxd rbx,r15d
  468f8c:	mov    r11,QWORD PTR [r11+rbx*8]
  468f90:	mov    DWORD PTR [rdx],r12d
  468f93:	mov    QWORD PTR [rdx+0x8],r11
  468f97:	add    rdx,0x10
  468f9b:	mov    r11d,0xffffffff
  468fa1:	crc32  r11,QWORD PTR [rdi+0x10]
  468fa8:	andn   r15d,esi,r11d
  468fad:	shl    r15,0x4
  468fb1:	prefetcht2 BYTE PTR [r8+r15*1]
  468fb6:	mov    r15d,0xffffffff
  468fbc:	mov    r13d,0xffffffff
  468fc2:	crc32  r15,QWORD PTR [rdi+0x20]
  468fc9:	andn   ebx,esi,r15d
  468fce:	shl    rbx,0x4
  468fd2:	prefetcht2 BYTE PTR [r8+rbx*1]
  468fd7:	mov    ebx,0xffffffff
  468fdc:	crc32  r13,QWORD PTR [rdi]
  468fe2:	crc32  rbx,QWORD PTR [rdi+0x30]
  468fe9:	andn   r12d,esi,r13d
  468fee:	shl    r12,0x4
  468ff2:	prefetcht2 BYTE PTR [r8+r12*1]
  468ff7:	andn   r12d,esi,ebx
  468ffc:	shl    r12,0x4
  469000:	prefetcht2 BYTE PTR [r8+r12*1]
  469005:	lea    r12,[r14+0x40]
  469009:	vmovdqu64 zmm9,ZMMWORD PTR [rdi]
  46900f:	cmp    QWORD PTR [rsp],r12
  469013:	jb     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x800>
  469019:	vmovdqu64 ZMMWORD PTR [rcx],zmm9
  46901f:	mov    DWORD PTR [rcx+0x8],r13d
  469023:	mov    DWORD PTR [r9+r14*1+0x18],r11d
  469028:	mov    DWORD PTR [r9+r14*1+0x28],r15d
  46902d:	mov    DWORD PTR [r9+r14*1+0x38],ebx
  469032:	mov    r14,r12
  469035:	add    rdi,0x40
  469039:	and    r14,r10
  46903c:	cmp    QWORD PTR [rsp-0x18],rdi
  469041:	je     4690f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3c0>
  469047:	lea    r13,[r9+rax*1]
  46904b:	mov    ebx,DWORD PTR [r13+0x8]
  46904f:	andn   r11d,esi,ebx
  469054:	shl    r11,0x4
  469058:	add    r11,r8
  46905b:	vmovdqa64 zmm8,ZMMWORD PTR [r11]
  469061:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  469068:	vpcmpequq k4{k1},zmm8,zmm9
  46906f:	lea    rcx,[rax+0x180]
  469076:	add    rax,0x10
  46907a:	and    rcx,r10
  46907d:	and    rax,r10
  469080:	andn   r15d,esi,DWORD PTR [r9+rcx*1+0x8]
  469087:	shl    r15,0x4
  46908b:	kortestb k4,k4
  46908f:	prefetcht0 BYTE PTR [r8+r15*1]
  469094:	jne    468e10 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xe0>
  46909a:	vpcmpequq k5{k1},zmm8,zmm2
  4690a1:	kortestb k5,k5
  4690a5:	jne    469854 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb24>
  4690ab:	mov    ecx,0xffffffff
  4690b0:	crc32  rcx,rbx
  4690b6:	vmovd  xmm10,ecx
  4690ba:	vpinsrd xmm11,xmm10,DWORD PTR [r13+0xc],0x1
  4690c1:	mov    r13,QWORD PTR [r13+0x0]
  4690c5:	lea    r15,[r9+r14*1]
  4690c9:	add    r14,0x10
  4690cd:	andn   r12d,esi,ecx
  4690d2:	shl    r12,0x4
  4690d6:	and    r14,r10
  4690d9:	prefetcht2 BYTE PTR [r8+r12*1]
  4690de:	mov    QWORD PTR [r15],r13
  4690e1:	vmovq  QWORD PTR [r15+0x8],xmm11
  4690e7:	jmp    469047 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x317>
  4690ec:	nop    DWORD PTR [rax+0x0]
  4690f0:	mov    rcx,QWORD PTR [rsp-0x38]
  4690f5:	mov    r15,QWORD PTR [rsp-0x40]
  4690fa:	mov    r12d,DWORD PTR [rsp-0x28]
  4690ff:	vmovq  xmm15,r14
  469104:	vpinsrq xmm0,xmm15,rax,0x1
  46910a:	mov    rdx,QWORD PTR [rsp-0x30]
  46910f:	vpsrlq xmm1,xmm0,0x4
  469114:	vpmovqd xmm6,xmm1
  46911a:	sar    rdx,0x4
  46911e:	vmovq  QWORD PTR [rcx+0xb0],xmm6
  469126:	sub    rdx,r12
  469129:	add    DWORD PTR [r15],edx
  46912c:	vpextrd eax,xmm6,0x1
  469132:	cmp    rdi,QWORD PTR [rsp-0x20]
  469137:	je     469410 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
  46913d:	mov    r14,QWORD PTR [rcx+0x88]
  469144:	mov    rbx,QWORD PTR [rcx+0x80]
  46914b:	mov    rsi,QWORD PTR [rcx+0x60]
  46914f:	dec    r14
  469152:	mov    QWORD PTR [rsp-0x18],rbx
  469157:	mov    QWORD PTR [rsp],rsi
  46915b:	mov    QWORD PTR [rsp-0x28],r14
  469160:	mov    r10d,DWORD PTR [rcx+0x78]
  469164:	mov    r11,QWORD PTR [rip+0x29a7d]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46916b:	mov    r9,QWORD PTR [rcx+0xa0]
  469172:	movzx  r13d,BYTE PTR [rip+0x29986]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  46917a:	mov    r12,QWORD PTR [rip+0x29987]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469181:	mov    r8d,0x55
  469187:	vpxor  xmm3,xmm3,xmm3
  46918b:	kmovb  k3,r8d
  469190:	lea    edx,[rax+0x18]
  469193:	and    edx,r10d
  469196:	shl    rdx,0x4
  46919a:	mov    esi,ebx
  46919c:	and    esi,DWORD PTR [r9+rdx*1+0x8]
  4691a1:	mov    edx,eax
  4691a3:	shl    rdx,0x4
  4691a7:	add    rdx,r9
  4691aa:	mov    r8,QWORD PTR [rdx]
  4691ad:	shl    rsi,0x4
  4691b1:	prefetcht0 BYTE PTR [r11+rsi*1]
  4691b6:	cmp    r8,QWORD PTR [rcx+0x90]
  4691bd:	jne    469280 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x550>
  4691c3:	test   r13b,r13b
  4691c6:	je     4691e6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4b6>
  4691c8:	mov    r14d,DWORD PTR [r15]
  4691cb:	mov    edx,DWORD PTR [rdx+0xc]
  4691ce:	mov    r8,r14
  4691d1:	shl    r14,0x4
  4691d5:	add    r14,QWORD PTR [r15+0x8]
  4691d9:	inc    r8d
  4691dc:	mov    DWORD PTR [r14],edx
  4691df:	mov    QWORD PTR [r14+0x8],r12
  4691e3:	mov    DWORD PTR [r15],r8d
  4691e6:	inc    eax
  4691e8:	and    eax,r10d
  4691eb:	mov    DWORD PTR [rcx+0xb4],eax
  4691f1:	test   r12,r12
  4691f4:	jne    469190 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x460>
  4691f6:	cmp    QWORD PTR [rsp],0x4
  4691fb:	je     469375 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x645>
  469201:	nop    DWORD PTR [rax+0x0]
  469208:	cmp    QWORD PTR [rsp],0x8
  46920d:	je     4693f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  469213:	vmovd  xmm2,DWORD PTR [rsp-0x10]
  469219:	mov    rsi,QWORD PTR [rdi]
  46921c:	mov    edx,DWORD PTR [rcx+0xb0]
  469222:	mov    r8,QWORD PTR [rsp-0x28]
  469227:	mov    rax,rdx
  46922a:	and    r8,QWORD PTR [rsp-0x10]
  46922f:	vpinsrd xmm11,xmm2,DWORD PTR [rdi+0xc],0x1
  469236:	and    r8,0xfffffffffffffffc
  46923a:	shl    rdx,0x4
  46923e:	inc    eax
  469240:	add    rdx,r9
  469243:	shl    r8,0x4
  469247:	and    eax,r10d
  46924a:	add    rdi,0x10
  46924e:	prefetcht2 BYTE PTR [r11+r8*1]
  469253:	mov    QWORD PTR [rdx],rsi
  469256:	vmovq  QWORD PTR [rdx+0x8],xmm11
  46925b:	mov    DWORD PTR [rcx+0xb0],eax
  469261:	cmp    rdi,QWORD PTR [rsp-0x20]
  469266:	je     469410 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
  46926c:	mov    eax,DWORD PTR [rcx+0xb4]
  469272:	jmp    469190 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x460>
  469277:	nop    WORD PTR [rax+rax*1+0x0]
  469280:	mov    r14d,DWORD PTR [rdx+0x8]
  469284:	mov    esi,ebx
  469286:	and    esi,r14d
  469289:	shl    rsi,0x4
  46928d:	add    rsi,r11
  469290:	vmovdqa64 zmm4,ZMMWORD PTR [rsi]
  469296:	vpbroadcastq zmm5,r8
  46929c:	vpcmpequq k0{k3},zmm4,zmm5
  4692a3:	kortestb k0,k0
  4692a7:	jne    469330 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x600>
  4692ad:	vpcmpequq k4{k3},zmm4,zmm3
  4692b4:	kortestb k4,k4
  4692b8:	jne    4693a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x670>
  4692be:	cmp    QWORD PTR [rsp],0x4
  4692c3:	mov    esi,r14d
  4692c6:	je     4693b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x680>
  4692cc:	cmp    QWORD PTR [rsp],0x8
  4692d1:	je     4693d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6a0>
  4692d7:	vmovd  xmm7,DWORD PTR [rsp-0x8]
  4692dd:	mov    esi,DWORD PTR [rcx+0xb0]
  4692e3:	mov    r14,QWORD PTR [rsp-0x18]
  4692e8:	vpinsrd xmm9,xmm7,DWORD PTR [rdx+0xc],0x1
  4692ef:	mov    rdx,rsi
  4692f2:	and    r14,QWORD PTR [rsp-0x8]
  4692f7:	shl    rsi,0x4
  4692fb:	inc    edx
  4692fd:	inc    eax
  4692ff:	add    rsi,r9
  469302:	shl    r14,0x4
  469306:	and    edx,r10d
  469309:	and    eax,r10d
  46930c:	prefetcht2 BYTE PTR [r11+r14*1]
  469311:	mov    QWORD PTR [rsi],r8
  469314:	vmovq  QWORD PTR [rsi+0x8],xmm9
  469319:	mov    DWORD PTR [rcx+0xb0],edx
  46931f:	mov    DWORD PTR [rcx+0xb4],eax
  469325:	jmp    469190 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x460>
  46932a:	nop    WORD PTR [rax+rax*1+0x0]
  469330:	mov    r8d,DWORD PTR [r15]
  469333:	mov    edx,DWORD PTR [rdx+0xc]
  469336:	mov    r14,r8
  469339:	shl    r8,0x4
  46933d:	add    r8,QWORD PTR [r15+0x8]
  469341:	mov    DWORD PTR [r8],edx
  469344:	kmovb  edx,k0
  469348:	tzcnt  edx,edx
  46934c:	inc    edx
  46934e:	movsxd rdx,edx
  469351:	mov    rsi,QWORD PTR [rsi+rdx*8]
  469355:	inc    eax
  469357:	inc    r14d
  46935a:	and    eax,r10d
  46935d:	cmp    QWORD PTR [rsp],0x4
  469362:	mov    QWORD PTR [r8+0x8],rsi
  469366:	mov    DWORD PTR [r15],r14d
  469369:	mov    DWORD PTR [rcx+0xb4],eax
  46936f:	jne    469208 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4d8>
  469375:	mov    r14d,0xffffffff
  46937b:	crc32  r14d,DWORD PTR [rdi]
  469381:	vmovd  xmm10,r14d
  469386:	mov    rsi,QWORD PTR [rdi]
  469389:	vmovdqa xmm2,xmm10
  46938d:	vmovq  QWORD PTR [rsp-0x10],xmm10
  469393:	jmp    46921c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4ec>
  469398:	nop    DWORD PTR [rax+rax*1+0x0]
  4693a0:	inc    eax
  4693a2:	and    eax,r10d
  4693a5:	mov    DWORD PTR [rcx+0xb4],eax
  4693ab:	jmp    4691f6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4c6>
  4693b0:	mov    esi,0xffffffff
  4693b5:	crc32  esi,r14d
  4693bb:	vmovd  xmm8,esi
  4693bf:	vmovdqa xmm7,xmm8
  4693c3:	vmovq  QWORD PTR [rsp-0x8],xmm8
  4693c9:	jmp    4692dd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ad>
  4693ce:	xchg   ax,ax
  4693d0:	mov    r14d,0xffffffff
  4693d6:	crc32  r14,rsi
  4693dc:	mov    QWORD PTR [rsp-0x8],r14
  4693e1:	vmovd  xmm7,r14d
  4693e6:	jmp    4692dd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ad>
  4693eb:	nop    DWORD PTR [rax+rax*1+0x0]
  4693f0:	mov    rsi,QWORD PTR [rdi]
  4693f3:	mov    eax,0xffffffff
  4693f8:	crc32  rax,rsi
  4693fe:	mov    QWORD PTR [rsp-0x10],rax
  469403:	vmovd  xmm2,eax
  469407:	jmp    46921c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4ec>
  46940c:	nop    DWORD PTR [rax+0x0]
  469410:	vzeroupper 
  469413:	lea    rsp,[rbp-0x28]
  469417:	pop    rbx
  469418:	pop    r12
  46941a:	pop    r13
  46941c:	pop    r14
  46941e:	pop    r15
  469420:	pop    rbp
  469421:	ret    
  469422:	nop    WORD PTR [rax+rax*1+0x0]
  469428:	vpcmpequq k5{k1},zmm4,zmm2
  46942f:	kortestb k5,k5
  469433:	jne    469866 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb36>
  469439:	mov    r13d,0xffffffff
  46943f:	crc32  r13,r12
  469445:	vmovd  xmm7,r13d
  46944a:	vpinsrd xmm8,xmm7,DWORD PTR [rbx+0xc],0x1
  469451:	mov    rbx,QWORD PTR [rbx]
  469454:	add    r14,0x10
  469458:	andn   r15d,esi,r13d
  46945d:	shl    r15,0x4
  469461:	and    r14,r10
  469464:	prefetcht2 BYTE PTR [r8+r15*1]
  469469:	mov    QWORD PTR [rcx],rbx
  46946c:	vmovq  QWORD PTR [rcx+0x8],xmm8
  469471:	jmp    468f20 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1f0>
  469476:	cs nop WORD PTR [rax+rax*1+0x0]
  469480:	vpcmpequq k3{k1},zmm0,zmm2
  469487:	kortestb k3,k3
  46948b:	jne    46985d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb2d>
  469491:	mov    ecx,0xffffffff
  469496:	crc32  rcx,r15
  46949c:	vmovd  xmm6,ecx
  4694a0:	vpinsrd xmm3,xmm6,DWORD PTR [r13+0xc],0x1
  4694a7:	mov    r13,QWORD PTR [r13+0x0]
  4694ab:	lea    r12,[r9+r14*1]
  4694af:	add    r14,0x10
  4694b3:	andn   ebx,esi,ecx
  4694b8:	shl    rbx,0x4
  4694bc:	and    r14,r10
  4694bf:	prefetcht2 BYTE PTR [r8+rbx*1]
  4694c4:	mov    QWORD PTR [r12],r13
  4694c8:	vmovq  QWORD PTR [r12+0x8],xmm3
  4694cf:	jmp    468eaa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x17a>
  4694d4:	nop    DWORD PTR [rax+0x0]
  4694d8:	vpcmpequq k7{k1},zmm12,zmm2
  4694df:	kortestb k7,k7
  4694e3:	jne    46984b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb1b>
  4694e9:	mov    r11d,0xffffffff
  4694ef:	crc32  r11,r13
  4694f5:	vmovd  xmm14,r11d
  4694fa:	vpinsrd xmm15,xmm14,DWORD PTR [r15+0xc],0x1
  469501:	mov    rbx,QWORD PTR [r15]
  469504:	lea    r12,[r9+r14*1]
  469508:	add    r14,0x10
  46950c:	andn   ecx,esi,r11d
  469511:	shl    rcx,0x4
  469515:	and    r14,r10
  469518:	prefetcht2 BYTE PTR [r8+rcx*1]
  46951d:	mov    QWORD PTR [r12],rbx
  469521:	vmovq  QWORD PTR [r12+0x8],xmm15
  469528:	jmp    468e32 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x102>
  46952d:	nop    DWORD PTR [rax]
  469530:	vmovd  xmm12,r13d
  469535:	mov    r13,QWORD PTR [rsp]
  469539:	vmovd  xmm10,r15d
  46953e:	vpinsrd xmm13,xmm12,r11d,0x1
  469544:	mov    r11,r13
  469547:	vpinsrd xmm11,xmm10,ebx,0x1
  46954d:	sub    r11,r14
  469550:	vpunpcklqdq xmm14,xmm13,xmm11
  469555:	shr    r11,0x2
  469559:	mov    r15d,0x1
  46955f:	vpexpandd zmm9{k2},zmm14
  469565:	shlx   r11d,r15d,r11d
  46956a:	lea    ebx,[r11-0x1]
  46956e:	sub    r14,r13
  469571:	neg    r11d
  469574:	kmovw  k6,ebx
  469578:	vmovdqu32 ZMMWORD PTR [rcx]{k6},zmm9
  46957e:	kmovw  k7,r11d
  469583:	vmovdqu32 ZMMWORD PTR [r9+r14*1]{k7},zmm9
  46958a:	jmp    469032 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x302>
  46958f:	cmp    rdi,QWORD PTR [rsp-0x20]
  469594:	je     469413 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e3>
  46959a:	mov    r12,QWORD PTR [rcx+0x88]
  4695a1:	movzx  r13d,BYTE PTR [rip+0x29557]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4695a9:	mov    r9,QWORD PTR [rip+0x29558]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4695b0:	mov    r10,QWORD PTR [rcx+0x60]
  4695b4:	mov    ebx,0x55
  4695b9:	dec    r12
  4695bc:	kmovb  k2,r13d
  4695c1:	mov    QWORD PTR [rsp],r10
  4695c5:	mov    QWORD PTR [rsp-0x8],r12
  4695ca:	mov    r14,QWORD PTR [rip+0x29617]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4695d1:	mov    r11,QWORD PTR [rcx+0xa0]
  4695d8:	mov    edx,esi
  4695da:	vpxor  xmm2,xmm2,xmm2
  4695de:	mov    r13,r9
  4695e1:	kmovb  k1,ebx
  4695e5:	jmp    46964d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x91d>
  4695e7:	cmp    QWORD PTR [rsp],0x8
  4695ec:	je     4697f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xac8>
  4695f2:	vmovd  xmm4,DWORD PTR [rsp-0x18]
  4695f8:	mov    r12,QWORD PTR [rsp-0x8]
  4695fd:	mov    edx,esi
  4695ff:	and    r12,QWORD PTR [rsp-0x18]
  469604:	vpinsrd xmm7,xmm4,DWORD PTR [rdi+0xc],0x1
  46960b:	mov    r10,QWORD PTR [rdi]
  46960e:	and    r12,0xfffffffffffffffc
  469612:	shl    rdx,0x4
  469616:	add    rdx,r11
  469619:	shl    r12,0x4
  46961d:	prefetcht2 BYTE PTR [r14+r12*1]
  469622:	mov    QWORD PTR [rdx],r10
  469625:	vmovq  QWORD PTR [rdx+0x8],xmm7
  46962a:	lea    edx,[rsi+0x1]
  46962d:	and    edx,r8d
  469630:	add    rdi,0x10
  469634:	mov    DWORD PTR [rcx+0xb0],edx
  46963a:	cmp    QWORD PTR [rsp-0x20],rdi
  46963f:	je     469410 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
  469645:	mov    eax,DWORD PTR [rcx+0xb4]
  46964b:	mov    esi,edx
  46964d:	sub    edx,eax
  46964f:	and    edx,r8d
  469652:	cmp    r8d,edx
  469655:	jbe    469678 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x948>
  469657:	cmp    QWORD PTR [rsp],0x4
  46965c:	jne    4695e7 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8b7>
  46965e:	mov    ebx,0xffffffff
  469663:	crc32  ebx,DWORD PTR [rdi]
  469668:	vmovd  xmm5,ebx
  46966c:	vmovdqa xmm4,xmm5
  469670:	vmovq  QWORD PTR [rsp-0x18],xmm5
  469676:	jmp    4695f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8c8>
  469678:	mov    rbx,QWORD PTR [rcx+0x80]
  46967f:	mov    QWORD PTR [rsp-0x10],rbx
  469684:	nop    DWORD PTR [rax+0x0]
  469688:	lea    edx,[rax+0x18]
  46968b:	and    edx,r8d
  46968e:	shl    rdx,0x4
  469692:	mov    r9d,ebx
  469695:	and    r9d,DWORD PTR [r11+rdx*1+0x8]
  46969a:	mov    edx,eax
  46969c:	mov    r10,r9
  46969f:	shl    rdx,0x4
  4696a3:	shl    r10,0x4
  4696a7:	add    rdx,r11
  4696aa:	prefetcht0 BYTE PTR [r14+r10*1]
  4696af:	mov    r10,QWORD PTR [rdx]
  4696b2:	cmp    r10,QWORD PTR [rcx+0x90]
  4696b9:	jne    469700 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9d0>
  4696bb:	kortestb k2,k2
  4696bf:	je     4696e2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b2>
  4696c1:	mov    r12d,DWORD PTR [r15]
  4696c4:	mov    edx,DWORD PTR [rdx+0xc]
  4696c7:	mov    r10,r12
  4696ca:	shl    r12,0x4
  4696ce:	add    r12,QWORD PTR [r15+0x8]
  4696d2:	lea    r9d,[r10+0x1]
  4696d6:	mov    DWORD PTR [r12],edx
  4696da:	mov    QWORD PTR [r12+0x8],r13
  4696df:	mov    DWORD PTR [r15],r9d
  4696e2:	inc    eax
  4696e4:	and    eax,r8d
  4696e7:	mov    DWORD PTR [rcx+0xb4],eax
  4696ed:	test   r13,r13
  4696f0:	jne    469688 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x958>
  4696f2:	jmp    469657 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x927>
  4696f7:	nop    WORD PTR [rax+rax*1+0x0]
  469700:	mov    r12d,DWORD PTR [rdx+0x8]
  469704:	mov    r9d,ebx
  469707:	and    r9d,r12d
  46970a:	shl    r9,0x4
  46970e:	add    r9,r14
  469711:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  469717:	vpbroadcastq zmm1,r10
  46971d:	vpcmpequq k0{k1},zmm0,zmm1
  469724:	kortestb k0,k0
  469728:	jne    4697a4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa74>
  46972a:	vpcmpequq k3{k1},zmm0,zmm2
  469731:	kortestb k3,k3
  469735:	jne    4697e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xab8>
  46973b:	cmp    QWORD PTR [rsp],0x4
  469740:	mov    r9d,r12d
  469743:	je     469811 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xae1>
  469749:	cmp    QWORD PTR [rsp],0x8
  46974e:	je     469832 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb02>
  469754:	mov    r9d,DWORD PTR [rsp-0x28]
  469759:	mov    r12,QWORD PTR [rsp-0x10]
  46975e:	vmovd  xmm6,r9d
  469763:	vpinsrd xmm3,xmm6,DWORD PTR [rdx+0xc],0x1
  46976a:	mov    edx,esi
  46976c:	and    r12,QWORD PTR [rsp-0x28]
  469771:	shl    rdx,0x4
  469775:	inc    esi
  469777:	inc    eax
  469779:	add    rdx,r11
  46977c:	shl    r12,0x4
  469780:	and    esi,r8d
  469783:	and    eax,r8d
  469786:	prefetcht2 BYTE PTR [r14+r12*1]
  46978b:	mov    QWORD PTR [rdx],r10
  46978e:	vmovq  QWORD PTR [rdx+0x8],xmm3
  469793:	mov    DWORD PTR [rcx+0xb0],esi
  469799:	mov    DWORD PTR [rcx+0xb4],eax
  46979f:	jmp    469688 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x958>
  4697a4:	mov    r10d,DWORD PTR [r15]
  4697a7:	mov    r12d,DWORD PTR [rdx+0xc]
  4697ab:	mov    rbx,r10
  4697ae:	shl    r10,0x4
  4697b2:	add    r10,QWORD PTR [r15+0x8]
  4697b6:	mov    DWORD PTR [r10],r12d
  4697b9:	xor    r12d,r12d
  4697bc:	kmovb  edx,k0
  4697c0:	tzcnt  r12d,edx
  4697c5:	inc    r12d
  4697c8:	movsxd rdx,r12d
  4697cb:	mov    r9,QWORD PTR [r9+rdx*8]
  4697cf:	inc    eax
  4697d1:	inc    ebx
  4697d3:	and    eax,r8d
  4697d6:	mov    QWORD PTR [r10+0x8],r9
  4697da:	mov    DWORD PTR [r15],ebx
  4697dd:	mov    DWORD PTR [rcx+0xb4],eax
  4697e3:	jmp    469657 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x927>
  4697e8:	inc    eax
  4697ea:	and    eax,r8d
  4697ed:	mov    DWORD PTR [rcx+0xb4],eax
  4697f3:	jmp    469657 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x927>
  4697f8:	mov    eax,0xffffffff
  4697fd:	crc32  rax,QWORD PTR [rdi]
  469803:	mov    QWORD PTR [rsp-0x18],rax
  469808:	vmovd  xmm4,eax
  46980c:	jmp    4695f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8c8>
  469811:	mov    r9d,0xffffffff
  469817:	crc32  r9d,r12d
  46981d:	mov    r12d,r9d
  469820:	mov    QWORD PTR [rsp-0x28],r12
  469825:	jmp    469759 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa29>
  46982a:	xor    r12d,r12d
  46982d:	jmp    4690ff <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3cf>
  469832:	mov    r12d,0xffffffff
  469838:	crc32  r12,r9
  46983e:	mov    QWORD PTR [rsp-0x28],r12
  469843:	mov    r9d,r12d
  469846:	jmp    469759 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa29>
  46984b:	inc    DWORD PTR [rsp-0x28]
  46984f:	jmp    468eaa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x17a>
  469854:	inc    DWORD PTR [rsp-0x28]
  469858:	jmp    468e32 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x102>
  46985d:	inc    DWORD PTR [rsp-0x28]
  469861:	jmp    468f20 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1f0>
  469866:	inc    DWORD PTR [rsp-0x28]
  46986a:	jmp    468f9b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x26b>
