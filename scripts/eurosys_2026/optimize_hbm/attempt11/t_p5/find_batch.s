0000000000468cc0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468cc0:	push   rbp
  468cc1:	mov    rbp,rsp
  468cc4:	push   r15
  468cc6:	push   r14
  468cc8:	push   r13
  468cca:	push   r12
  468ccc:	mov    r12,rdx
  468ccf:	push   rbx
  468cd0:	and    rsp,0xffffffffffffffc0
  468cd4:	mov    rbx,QWORD PTR [rsi+0x8]
  468cd8:	mov    ecx,DWORD PTR [rdi+0xb0]
  468cde:	mov    eax,DWORD PTR [rdi+0xb4]
  468ce4:	mov    r11,QWORD PTR [rsi]
  468ce7:	mov    r9d,DWORD PTR [rdi+0x6c]
  468ceb:	mov    esi,DWORD PTR [rdi+0x78]
  468cee:	mov    r8,rbx
  468cf1:	mov    edx,ecx
  468cf3:	shl    r8,0x4
  468cf7:	sub    edx,eax
  468cf9:	lea    r10,[r11+r8*1]
  468cfd:	and    edx,esi
  468cff:	lea    r13d,[r9-0x1]
  468d03:	mov    QWORD PTR [rsp-0x28],r10
  468d08:	cmp    edx,r13d
  468d0b:	jb     4694af <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7ef>
  468d11:	and    rbx,0xfffffffffffffffc
  468d15:	mov    r10d,ecx
  468d18:	shl    rbx,0x4
  468d1c:	mov    ecx,DWORD PTR [rdi+0x80]
  468d22:	shl    r9,0x4
  468d26:	mov    QWORD PTR [rsp-0x38],rbx
  468d2b:	add    rbx,r11
  468d2e:	mov    QWORD PTR [rsp-0x8],r9
  468d33:	mov    QWORD PTR [rsp-0x20],rbx
  468d38:	mov    DWORD PTR [rsp-0x30],0x0
  468d40:	mov    r8,QWORD PTR [rdi+0xa0]
  468d47:	mov    rdx,QWORD PTR [r12+0x8]
  468d4c:	mov    rsi,QWORD PTR [rip+0x29e95]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468d53:	dec    r9
  468d56:	shl    rax,0x4
  468d5a:	shl    r10,0x4
  468d5e:	not    ecx
  468d60:	cmp    r11,rbx
  468d63:	je     46974b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa8b>
  468d69:	mov    r15d,0x55
  468d6f:	mov    r14d,0x4444
  468d75:	mov    QWORD PTR [rsp-0x40],rdi
  468d7a:	vpxor  xmm2,xmm2,xmm2
  468d7e:	mov    r13d,0xffffffff
  468d84:	kmovb  k1,r15d
  468d89:	kmovw  k2,r14d
  468d8e:	jmp    468fce <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x30e>
  468d93:	nop    DWORD PTR [rax+rax*1+0x0]
  468d98:	xor    r15d,r15d
  468d9b:	mov    r14d,DWORD PTR [r14+0xc]
  468d9f:	kmovb  edi,k4
  468da3:	tzcnt  r15d,edi
  468da8:	inc    r15d
  468dab:	mov    DWORD PTR [rdx],r14d
  468dae:	movsxd r14,r15d
  468db1:	mov    rbx,QWORD PTR [rbx+r14*8]
  468db5:	add    rdx,0x10
  468db9:	mov    QWORD PTR [rdx-0x8],rbx
  468dbd:	lea    rdi,[rax+0x180]
  468dc4:	and    rdi,r9
  468dc7:	andn   r15d,ecx,DWORD PTR [r8+rdi*1+0x8]
  468dce:	shl    r15,0x4
  468dd2:	prefetcht0 BYTE PTR [rsi+r15*1]
  468dd7:	lea    r15,[r8+rax*1]
  468ddb:	mov    edi,DWORD PTR [r15+0x8]
  468ddf:	andn   ebx,ecx,edi
  468de4:	shl    rbx,0x4
  468de8:	add    rbx,rsi
  468deb:	vmovdqa64 zmm12,ZMMWORD PTR [rbx]
  468df1:	vpbroadcastq zmm13,QWORD PTR [r15]
  468df7:	vpcmpequq k6{k1},zmm12,zmm13
  468dfe:	add    rax,0x10
  468e02:	and    rax,r9
  468e05:	kortestb k6,k6
  468e09:	je     469428 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x768>
  468e0f:	xor    edi,edi
  468e11:	mov    r15d,DWORD PTR [r15+0xc]
  468e15:	kmovb  r14d,k6
  468e19:	tzcnt  edi,r14d
  468e1e:	inc    edi
  468e20:	mov    DWORD PTR [rdx],r15d
  468e23:	movsxd r15,edi
  468e26:	mov    rbx,QWORD PTR [rbx+r15*8]
  468e2a:	add    rdx,0x10
  468e2e:	mov    QWORD PTR [rdx-0x8],rbx
  468e32:	lea    r14,[rax+0x180]
  468e39:	and    r14,r9
  468e3c:	andn   edi,ecx,DWORD PTR [r8+r14*1+0x8]
  468e43:	shl    rdi,0x4
  468e47:	lea    r14,[r8+rax*1]
  468e4b:	prefetcht0 BYTE PTR [rsi+rdi*1]
  468e4f:	mov    edi,DWORD PTR [r14+0x8]
  468e53:	andn   ebx,ecx,edi
  468e58:	shl    rbx,0x4
  468e5c:	add    rbx,rsi
  468e5f:	vmovdqa64 zmm0,ZMMWORD PTR [rbx]
  468e65:	vpbroadcastq zmm1,QWORD PTR [r14]
  468e6b:	vpcmpequq k0{k1},zmm0,zmm1
  468e72:	add    rax,0x10
  468e76:	and    rax,r9
  468e79:	kortestb k0,k0
  468e7d:	je     4693e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
  468e83:	xor    edi,edi
  468e85:	mov    r14d,DWORD PTR [r14+0xc]
  468e89:	kmovb  r15d,k0
  468e8d:	tzcnt  edi,r15d
  468e92:	inc    edi
  468e94:	mov    DWORD PTR [rdx],r14d
  468e97:	movsxd r14,edi
  468e9a:	mov    rbx,QWORD PTR [rbx+r14*8]
  468e9e:	add    rdx,0x10
  468ea2:	mov    QWORD PTR [rdx-0x8],rbx
  468ea6:	lea    r14,[r8+rax*1]
  468eaa:	lea    r15,[rax+0x180]
  468eb1:	and    r15,r9
  468eb4:	andn   edi,ecx,DWORD PTR [r8+r15*1+0x8]
  468ebb:	shl    rdi,0x4
  468ebf:	mov    r15d,DWORD PTR [r14+0x8]
  468ec3:	andn   ebx,ecx,r15d
  468ec8:	shl    rbx,0x4
  468ecc:	add    rbx,rsi
  468ecf:	vmovdqa64 zmm4,ZMMWORD PTR [rbx]
  468ed5:	vpbroadcastq zmm7,QWORD PTR [r14]
  468edb:	vpcmpequq k4{k1},zmm4,zmm7
  468ee2:	add    rax,0x10
  468ee6:	and    rax,r9
  468ee9:	prefetcht0 BYTE PTR [rsi+rdi*1]
  468eed:	kortestb k4,k4
  468ef1:	lea    rdi,[r8+r10*1]
  468ef5:	je     469398 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d8>
  468efb:	mov    r14d,DWORD PTR [r14+0xc]
  468eff:	kmovb  r15d,k4
  468f03:	mov    DWORD PTR [rdx],r14d
  468f06:	xor    r14d,r14d
  468f09:	tzcnt  r14d,r15d
  468f0e:	inc    r14d
  468f11:	movsxd r15,r14d
  468f14:	mov    rbx,QWORD PTR [rbx+r15*8]
  468f18:	add    rdx,0x10
  468f1c:	mov    QWORD PTR [rdx-0x8],rbx
  468f20:	mov    r14,r13
  468f23:	crc32  r14,QWORD PTR [r11]
  468f29:	vmovq  xmm9,r14
  468f2e:	andn   ebx,ecx,r14d
  468f33:	shl    rbx,0x4
  468f37:	mov    r14,r13
  468f3a:	prefetcht2 BYTE PTR [rsi+rbx*1]
  468f3e:	mov    rbx,r13
  468f41:	crc32  rbx,QWORD PTR [r11+0x20]
  468f48:	crc32  r14,QWORD PTR [r11+0x10]
  468f4f:	andn   r15d,ecx,r14d
  468f54:	shl    r15,0x4
  468f58:	prefetcht2 BYTE PTR [rsi+r15*1]
  468f5d:	andn   r15d,ecx,ebx
  468f62:	shl    r15,0x4
  468f66:	prefetcht2 BYTE PTR [rsi+r15*1]
  468f6b:	mov    r15,r13
  468f6e:	vmovq  xmm10,rbx
  468f73:	crc32  r15,QWORD PTR [r11+0x30]
  468f7a:	vmovdqu32 zmm14,ZMMWORD PTR [r11]
  468f80:	vpinsrd xmm11,xmm10,r15d,0x1
  468f86:	vpinsrd xmm12,xmm9,r14d,0x1
  468f8c:	andn   ebx,ecx,r15d
  468f91:	shl    rbx,0x4
  468f95:	vpunpcklqdq xmm13,xmm12,xmm11
  468f9a:	prefetcht2 BYTE PTR [rsi+rbx*1]
  468f9e:	lea    rbx,[r10+0x40]
  468fa2:	vpexpandd zmm14{k2},zmm13
  468fa8:	cmp    QWORD PTR [rsp-0x8],rbx
  468fad:	jb     469470 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7b0>
  468fb3:	vmovdqu64 ZMMWORD PTR [rdi],zmm14
  468fb9:	and    rbx,r9
  468fbc:	add    r11,0x40
  468fc0:	mov    r10,rbx
  468fc3:	cmp    QWORD PTR [rsp-0x20],r11
  468fc8:	je     469068 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3a8>
  468fce:	lea    r14,[r8+rax*1]
  468fd2:	lea    rbx,[rax+0x180]
  468fd9:	and    rbx,r9
  468fdc:	mov    r15d,DWORD PTR [r14+0x8]
  468fe0:	andn   edi,ecx,DWORD PTR [r8+rbx*1+0x8]
  468fe7:	shl    rdi,0x4
  468feb:	andn   ebx,ecx,r15d
  468ff0:	shl    rbx,0x4
  468ff4:	add    rbx,rsi
  468ff7:	vmovdqa64 zmm8,ZMMWORD PTR [rbx]
  468ffd:	vpbroadcastq zmm9,QWORD PTR [r14]
  469003:	vpcmpequq k4{k1},zmm8,zmm9
  46900a:	add    rax,0x10
  46900e:	and    rax,r9
  469011:	prefetcht0 BYTE PTR [rsi+rdi*1]
  469015:	kortestb k4,k4
  469019:	jne    468d98 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xd8>
  46901f:	vpcmpequq k5{k1},zmm8,zmm2
  469026:	kortestb k5,k5
  46902a:	jne    469774 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xab4>
  469030:	vmovdqu xmm10,XMMWORD PTR [r14]
  469035:	mov    rdi,r13
  469038:	crc32  rdi,r15
  46903e:	vpinsrd xmm11,xmm10,edi,0x2
  469044:	andn   r15d,ecx,edi
  469049:	shl    r15,0x4
  46904d:	prefetcht2 BYTE PTR [rsi+r15*1]
  469052:	vmovdqu XMMWORD PTR [r8+r10*1],xmm11
  469058:	add    r10,0x10
  46905c:	and    r10,r9
  46905f:	jmp    468fce <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x30e>
  469064:	nop    DWORD PTR [rax+0x0]
  469068:	mov    rdi,QWORD PTR [rsp-0x40]
  46906d:	mov    ebx,DWORD PTR [rsp-0x30]
  469071:	vmovq  xmm15,r10
  469076:	vpinsrq xmm0,xmm15,rax,0x1
  46907c:	mov    rdx,QWORD PTR [rsp-0x38]
  469081:	vpsrlq xmm1,xmm0,0x4
  469086:	vpmovqd xmm6,xmm1
  46908c:	sar    rdx,0x4
  469090:	vmovq  QWORD PTR [rdi+0xb0],xmm6
  469098:	sub    rdx,rbx
  46909b:	add    DWORD PTR [r12],edx
  46909f:	vpextrd eax,xmm6,0x1
  4690a5:	cmp    r11,QWORD PTR [rsp-0x28]
  4690aa:	je     469380 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  4690b0:	mov    r15,QWORD PTR [rdi+0x88]
  4690b7:	mov    rbx,QWORD PTR [rdi+0x80]
  4690be:	mov    rcx,QWORD PTR [rdi+0x60]
  4690c2:	dec    r15
  4690c5:	mov    QWORD PTR [rsp-0x20],rbx
  4690ca:	mov    QWORD PTR [rsp-0x8],rcx
  4690cf:	mov    QWORD PTR [rsp-0x30],r15
  4690d4:	mov    r9d,DWORD PTR [rdi+0x78]
  4690d8:	mov    r10,QWORD PTR [rip+0x29b09]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4690df:	mov    r8,QWORD PTR [rdi+0xa0]
  4690e6:	movzx  r14d,BYTE PTR [rip+0x29a12]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4690ee:	mov    r13,QWORD PTR [rip+0x29a13]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4690f5:	mov    esi,0x55
  4690fa:	vpxor  xmm7,xmm7,xmm7
  4690fe:	kmovb  k3,esi
  469102:	nop    WORD PTR [rax+rax*1+0x0]
  469108:	lea    edx,[rax+0x18]
  46910b:	and    edx,r9d
  46910e:	shl    rdx,0x4
  469112:	mov    ecx,ebx
  469114:	and    ecx,DWORD PTR [r8+rdx*1+0x8]
  469119:	mov    edx,eax
  46911b:	mov    rsi,rcx
  46911e:	shl    rdx,0x4
  469122:	shl    rsi,0x4
  469126:	add    rdx,r8
  469129:	prefetcht0 BYTE PTR [r10+rsi*1]
  46912e:	mov    rsi,QWORD PTR [rdx]
  469131:	cmp    rsi,QWORD PTR [rdi+0x90]
  469138:	jne    4691f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x530>
  46913e:	test   r14b,r14b
  469141:	je     469163 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a3>
  469143:	mov    r15d,DWORD PTR [r12]
  469147:	mov    edx,DWORD PTR [rdx+0xc]
  46914a:	mov    rsi,r15
  46914d:	shl    r15,0x4
  469151:	add    r15,QWORD PTR [r12+0x8]
  469156:	inc    esi
  469158:	mov    DWORD PTR [r15],edx
  46915b:	mov    QWORD PTR [r15+0x8],r13
  46915f:	mov    DWORD PTR [r12],esi
  469163:	inc    eax
  469165:	and    eax,r9d
  469168:	mov    DWORD PTR [rdi+0xb4],eax
  46916e:	test   r13,r13
  469171:	jne    469108 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
  469173:	cmp    QWORD PTR [rsp-0x8],0x4
  469179:	je     4692e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x628>
  46917f:	nop
  469180:	cmp    QWORD PTR [rsp-0x8],0x8
  469186:	je     469360 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6a0>
  46918c:	vmovd  xmm10,DWORD PTR [rsp-0x18]
  469192:	mov    rcx,QWORD PTR [r11]
  469195:	mov    edx,DWORD PTR [rdi+0xb0]
  46919b:	mov    rsi,QWORD PTR [rsp-0x30]
  4691a0:	mov    rax,rdx
  4691a3:	and    rsi,QWORD PTR [rsp-0x18]
  4691a8:	vpinsrd xmm12,xmm10,DWORD PTR [r11+0xc],0x1
  4691af:	and    rsi,0xfffffffffffffffc
  4691b3:	shl    rdx,0x4
  4691b7:	inc    eax
  4691b9:	add    rdx,r8
  4691bc:	shl    rsi,0x4
  4691c0:	and    eax,r9d
  4691c3:	add    r11,0x10
  4691c7:	prefetcht2 BYTE PTR [r10+rsi*1]
  4691cc:	mov    QWORD PTR [rdx],rcx
  4691cf:	vmovq  QWORD PTR [rdx+0x8],xmm12
  4691d4:	mov    DWORD PTR [rdi+0xb0],eax
  4691da:	cmp    r11,QWORD PTR [rsp-0x28]
  4691df:	je     469380 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  4691e5:	mov    eax,DWORD PTR [rdi+0xb4]
  4691eb:	jmp    469108 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
  4691f0:	mov    r15d,DWORD PTR [rdx+0x8]
  4691f4:	mov    ecx,ebx
  4691f6:	and    ecx,r15d
  4691f9:	shl    rcx,0x4
  4691fd:	add    rcx,r10
  469200:	vmovdqa64 zmm3,ZMMWORD PTR [rcx]
  469206:	vpbroadcastq zmm4,rsi
  46920c:	vpcmpequq k0{k3},zmm3,zmm4
  469213:	kortestb k0,k0
  469217:	jne    4692a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5e0>
  46921d:	vpcmpequq k4{k3},zmm3,zmm7
  469224:	kortestb k4,k4
  469228:	jne    469310 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x650>
  46922e:	cmp    QWORD PTR [rsp-0x8],0x4
  469234:	mov    ecx,r15d
  469237:	je     469320 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x660>
  46923d:	cmp    QWORD PTR [rsp-0x8],0x8
  469243:	je     469340 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x680>
  469249:	vmovd  xmm5,DWORD PTR [rsp-0x10]
  46924f:	mov    ecx,DWORD PTR [rdi+0xb0]
  469255:	mov    r15,QWORD PTR [rsp-0x20]
  46925a:	vpinsrd xmm9,xmm5,DWORD PTR [rdx+0xc],0x1
  469261:	mov    rdx,rcx
  469264:	and    r15,QWORD PTR [rsp-0x10]
  469269:	shl    rcx,0x4
  46926d:	inc    edx
  46926f:	inc    eax
  469271:	add    rcx,r8
  469274:	shl    r15,0x4
  469278:	and    edx,r9d
  46927b:	and    eax,r9d
  46927e:	prefetcht2 BYTE PTR [r10+r15*1]
  469283:	mov    QWORD PTR [rcx],rsi
  469286:	vmovq  QWORD PTR [rcx+0x8],xmm9
  46928b:	mov    DWORD PTR [rdi+0xb0],edx
  469291:	mov    DWORD PTR [rdi+0xb4],eax
  469297:	jmp    469108 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
  46929c:	nop    DWORD PTR [rax+0x0]
  4692a0:	mov    esi,DWORD PTR [r12]
  4692a4:	mov    edx,DWORD PTR [rdx+0xc]
  4692a7:	mov    r15,rsi
  4692aa:	shl    rsi,0x4
  4692ae:	add    rsi,QWORD PTR [r12+0x8]
  4692b3:	mov    DWORD PTR [rsi],edx
  4692b5:	kmovb  edx,k0
  4692b9:	tzcnt  edx,edx
  4692bd:	inc    edx
  4692bf:	movsxd rdx,edx
  4692c2:	mov    rcx,QWORD PTR [rcx+rdx*8]
  4692c6:	inc    eax
  4692c8:	inc    r15d
  4692cb:	and    eax,r9d
  4692ce:	cmp    QWORD PTR [rsp-0x8],0x4
  4692d4:	mov    QWORD PTR [rsi+0x8],rcx
  4692d8:	mov    DWORD PTR [r12],r15d
  4692dc:	mov    DWORD PTR [rdi+0xb4],eax
  4692e2:	jne    469180 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4c0>
  4692e8:	mov    r15d,0xffffffff
  4692ee:	crc32  r15d,DWORD PTR [r11]
  4692f4:	vmovd  xmm11,r15d
  4692f9:	mov    rcx,QWORD PTR [r11]
  4692fc:	vmovdqa xmm10,xmm11
  469301:	vmovq  QWORD PTR [rsp-0x18],xmm11
  469307:	jmp    469195 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4d5>
  46930c:	nop    DWORD PTR [rax+0x0]
  469310:	inc    eax
  469312:	and    eax,r9d
  469315:	mov    DWORD PTR [rdi+0xb4],eax
  46931b:	jmp    469173 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4b3>
  469320:	mov    ecx,0xffffffff
  469325:	crc32  ecx,r15d
  46932b:	vmovd  xmm8,ecx
  46932f:	vmovdqa xmm5,xmm8
  469333:	vmovq  QWORD PTR [rsp-0x10],xmm8
  469339:	jmp    46924f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x58f>
  46933e:	xchg   ax,ax
  469340:	mov    r15d,0xffffffff
  469346:	crc32  r15,rcx
  46934c:	mov    QWORD PTR [rsp-0x10],r15
  469351:	vmovd  xmm5,r15d
  469356:	jmp    46924f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x58f>
  46935b:	nop    DWORD PTR [rax+rax*1+0x0]
  469360:	mov    rcx,QWORD PTR [r11]
  469363:	mov    eax,0xffffffff
  469368:	crc32  rax,rcx
  46936e:	mov    QWORD PTR [rsp-0x18],rax
  469373:	vmovd  xmm10,eax
  469377:	jmp    469195 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4d5>
  46937c:	nop    DWORD PTR [rax+0x0]
  469380:	vzeroupper 
  469383:	lea    rsp,[rbp-0x28]
  469387:	pop    rbx
  469388:	pop    r12
  46938a:	pop    r13
  46938c:	pop    r14
  46938e:	pop    r15
  469390:	pop    rbp
  469391:	ret    
  469392:	nop    WORD PTR [rax+rax*1+0x0]
  469398:	vpcmpequq k5{k1},zmm4,zmm2
  46939f:	kortestb k5,k5
  4693a3:	jne    469786 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xac6>
  4693a9:	vmovdqu xmm5,XMMWORD PTR [r14]
  4693ae:	mov    rbx,r13
  4693b1:	crc32  rbx,r15
  4693b7:	vpinsrd xmm8,xmm5,ebx,0x2
  4693bd:	add    r10,0x10
  4693c1:	andn   r15d,ecx,ebx
  4693c6:	shl    r15,0x4
  4693ca:	and    r10,r9
  4693cd:	prefetcht2 BYTE PTR [rsi+r15*1]
  4693d2:	vmovdqu XMMWORD PTR [rdi],xmm8
  4693d6:	jmp    468ea6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1e6>
  4693db:	nop    DWORD PTR [rax+rax*1+0x0]
  4693e0:	vpcmpequq k3{k1},zmm0,zmm2
  4693e7:	kortestb k3,k3
  4693eb:	jne    46977d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xabd>
  4693f1:	vmovdqu xmm6,XMMWORD PTR [r14]
  4693f6:	mov    r15,r13
  4693f9:	crc32  r15,rdi
  4693ff:	vpinsrd xmm3,xmm6,r15d,0x2
  469405:	andn   edi,ecx,r15d
  46940a:	shl    rdi,0x4
  46940e:	prefetcht2 BYTE PTR [rsi+rdi*1]
  469412:	vmovdqu XMMWORD PTR [r8+r10*1],xmm3
  469418:	add    r10,0x10
  46941c:	and    r10,r9
  46941f:	jmp    468e32 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x172>
  469424:	nop    DWORD PTR [rax+0x0]
  469428:	vpcmpequq k7{k1},zmm12,zmm2
  46942f:	kortestb k7,k7
  469433:	jne    46976b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaab>
  469439:	vmovdqu xmm14,XMMWORD PTR [r15]
  46943e:	mov    r14,r13
  469441:	crc32  r14,rdi
  469447:	vpinsrd xmm15,xmm14,r14d,0x2
  46944d:	andn   edi,ecx,r14d
  469452:	shl    rdi,0x4
  469456:	prefetcht2 BYTE PTR [rsi+rdi*1]
  46945a:	vmovdqu XMMWORD PTR [r8+r10*1],xmm15
  469460:	add    r10,0x10
  469464:	and    r10,r9
  469467:	jmp    468dbd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xfd>
  46946c:	nop    DWORD PTR [rax+0x0]
  469470:	mov    r14,QWORD PTR [rsp-0x8]
  469475:	mov    r15d,0x1
  46947b:	sub    r14,r10
  46947e:	shr    r14,0x2
  469482:	shlx   r14d,r15d,r14d
  469487:	lea    r15d,[r14-0x1]
  46948b:	kmovw  k6,r15d
  469490:	vmovdqu32 ZMMWORD PTR [rdi]{k6},zmm14
  469496:	sub    r10,QWORD PTR [rsp-0x8]
  46949b:	neg    r14d
  46949e:	kmovw  k7,r14d
  4694a3:	vmovdqu32 ZMMWORD PTR [r8+r10*1]{k7},zmm14
  4694aa:	jmp    468fb9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2f9>
  4694af:	cmp    r11,QWORD PTR [rsp-0x28]
  4694b4:	je     469383 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c3>
  4694ba:	mov    r8,QWORD PTR [rdi+0x88]
  4694c1:	mov    r9,QWORD PTR [rdi+0x60]
  4694c5:	mov    ebx,0x55
  4694ca:	dec    r8
  4694cd:	mov    QWORD PTR [rsp-0x8],r9
  4694d2:	mov    QWORD PTR [rsp-0x10],r8
  4694d7:	mov    r15,QWORD PTR [rip+0x2970a]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4694de:	mov    r14,QWORD PTR [rip+0x29623]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4694e5:	mov    r10,QWORD PTR [rdi+0xa0]
  4694ec:	mov    r13d,ecx
  4694ef:	vpxor  xmm2,xmm2,xmm2
  4694f3:	kmovb  k2,BYTE PTR [rip+0x29605]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  4694fb:	kmovb  k1,ebx
  4694ff:	jmp    46956b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8ab>
  469501:	cmp    QWORD PTR [rsp-0x8],0x8
  469507:	je     469719 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa59>
  46950d:	vmovd  xmm4,DWORD PTR [rsp-0x20]
  469513:	mov    r13,QWORD PTR [rsp-0x10]
  469518:	mov    edx,ecx
  46951a:	and    r13,QWORD PTR [rsp-0x20]
  46951f:	and    r13,0xfffffffffffffffc
  469523:	shl    r13,0x4
  469527:	vpinsrd xmm5,xmm4,DWORD PTR [r11+0xc],0x1
  46952e:	mov    r9,QWORD PTR [r11]
  469531:	prefetcht2 BYTE PTR [r15+r13*1]
  469536:	shl    rdx,0x4
  46953a:	lea    r13d,[rcx+0x1]
  46953e:	add    rdx,r10
  469541:	and    r13d,esi
  469544:	add    r11,0x10
  469548:	mov    QWORD PTR [rdx],r9
  46954b:	vmovq  QWORD PTR [rdx+0x8],xmm5
  469550:	mov    DWORD PTR [rdi+0xb0],r13d
  469557:	cmp    QWORD PTR [rsp-0x28],r11
  46955c:	je     469380 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
  469562:	mov    eax,DWORD PTR [rdi+0xb4]
  469568:	mov    ecx,r13d
  46956b:	sub    r13d,eax
  46956e:	and    r13d,esi
  469571:	cmp    esi,r13d
  469574:	jbe    46959c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8dc>
  469576:	cmp    QWORD PTR [rsp-0x8],0x4
  46957c:	jne    469501 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x841>
  46957e:	mov    ebx,0xffffffff
  469583:	crc32  ebx,DWORD PTR [r11]
  469589:	vmovd  xmm7,ebx
  46958d:	vmovdqa xmm4,xmm7
  469591:	vmovq  QWORD PTR [rsp-0x20],xmm7
  469597:	jmp    469513 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x853>
  46959c:	mov    rbx,QWORD PTR [rdi+0x80]
  4695a3:	mov    QWORD PTR [rsp-0x18],rbx
  4695a8:	nop    DWORD PTR [rax+rax*1+0x0]
  4695b0:	lea    edx,[rax+0x18]
  4695b3:	and    edx,esi
  4695b5:	shl    rdx,0x4
  4695b9:	mov    r13d,ebx
  4695bc:	and    r13d,DWORD PTR [r10+rdx*1+0x8]
  4695c1:	mov    edx,eax
  4695c3:	mov    r9,r13
  4695c6:	shl    rdx,0x4
  4695ca:	shl    r9,0x4
  4695ce:	add    rdx,r10
  4695d1:	prefetcht0 BYTE PTR [r15+r9*1]
  4695d6:	mov    r9,QWORD PTR [rdx]
  4695d9:	cmp    r9,QWORD PTR [rdi+0x90]
  4695e0:	jne    469620 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x960>
  4695e2:	kortestb k2,k2
  4695e6:	je     46960b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x94b>
  4695e8:	mov    r13d,DWORD PTR [r12]
  4695ec:	mov    edx,DWORD PTR [rdx+0xc]
  4695ef:	mov    r9,r13
  4695f2:	shl    r13,0x4
  4695f6:	add    r13,QWORD PTR [r12+0x8]
  4695fb:	lea    r8d,[r9+0x1]
  4695ff:	mov    DWORD PTR [r13+0x0],edx
  469603:	mov    QWORD PTR [r13+0x8],r14
  469607:	mov    DWORD PTR [r12],r8d
  46960b:	inc    eax
  46960d:	and    eax,esi
  46960f:	mov    DWORD PTR [rdi+0xb4],eax
  469615:	test   r14,r14
  469618:	jne    4695b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8f0>
  46961a:	jmp    469576 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8b6>
  46961f:	nop
  469620:	mov    r13d,DWORD PTR [rdx+0x8]
  469624:	mov    r8d,ebx
  469627:	and    r8d,r13d
  46962a:	shl    r8,0x4
  46962e:	add    r8,r15
  469631:	vmovdqa64 zmm0,ZMMWORD PTR [r8]
  469637:	vpbroadcastq zmm1,r9
  46963d:	vpcmpequq k0{k1},zmm0,zmm1
  469644:	kortestb k0,k0
  469648:	jne    4696c4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa04>
  46964a:	vpcmpequq k3{k1},zmm0,zmm2
  469651:	kortestb k3,k3
  469655:	jne    46970a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa4a>
  46965b:	cmp    QWORD PTR [rsp-0x8],0x4
  469661:	mov    r8d,r13d
  469664:	je     469732 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa72>
  46966a:	cmp    QWORD PTR [rsp-0x8],0x8
  469670:	je     469752 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa92>
  469676:	mov    r8d,DWORD PTR [rsp-0x30]
  46967b:	mov    r13,QWORD PTR [rsp-0x18]
  469680:	vmovd  xmm6,r8d
  469685:	vpinsrd xmm3,xmm6,DWORD PTR [rdx+0xc],0x1
  46968c:	mov    edx,ecx
  46968e:	and    r13,QWORD PTR [rsp-0x30]
  469693:	shl    rdx,0x4
  469697:	inc    ecx
  469699:	inc    eax
  46969b:	add    rdx,r10
  46969e:	shl    r13,0x4
  4696a2:	and    ecx,esi
  4696a4:	and    eax,esi
  4696a6:	prefetcht2 BYTE PTR [r15+r13*1]
  4696ab:	mov    QWORD PTR [rdx],r9
  4696ae:	vmovq  QWORD PTR [rdx+0x8],xmm3
  4696b3:	mov    DWORD PTR [rdi+0xb0],ecx
  4696b9:	mov    DWORD PTR [rdi+0xb4],eax
  4696bf:	jmp    4695b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8f0>
  4696c4:	mov    r9d,DWORD PTR [r12]
  4696c8:	mov    r13d,DWORD PTR [rdx+0xc]
  4696cc:	mov    rbx,r9
  4696cf:	shl    r9,0x4
  4696d3:	add    r9,QWORD PTR [r12+0x8]
  4696d8:	mov    DWORD PTR [r9],r13d
  4696db:	xor    r13d,r13d
  4696de:	kmovb  edx,k0
  4696e2:	tzcnt  r13d,edx
  4696e7:	inc    r13d
  4696ea:	movsxd rdx,r13d
  4696ed:	mov    r8,QWORD PTR [r8+rdx*8]
  4696f1:	inc    eax
  4696f3:	inc    ebx
  4696f5:	and    eax,esi
  4696f7:	mov    QWORD PTR [r9+0x8],r8
  4696fb:	mov    DWORD PTR [r12],ebx
  4696ff:	mov    DWORD PTR [rdi+0xb4],eax
  469705:	jmp    469576 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8b6>
  46970a:	inc    eax
  46970c:	and    eax,esi
  46970e:	mov    DWORD PTR [rdi+0xb4],eax
  469714:	jmp    469576 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8b6>
  469719:	mov    eax,0xffffffff
  46971e:	crc32  rax,QWORD PTR [r11]
  469724:	mov    QWORD PTR [rsp-0x20],rax
  469729:	vmovd  xmm4,eax
  46972d:	jmp    469513 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x853>
  469732:	mov    r8d,0xffffffff
  469738:	crc32  r8d,r13d
  46973e:	mov    r13d,r8d
  469741:	mov    QWORD PTR [rsp-0x30],r13
  469746:	jmp    46967b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9bb>
  46974b:	xor    ebx,ebx
  46974d:	jmp    469071 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3b1>
  469752:	mov    r13d,0xffffffff
  469758:	crc32  r13,r8
  46975e:	mov    QWORD PTR [rsp-0x30],r13
  469763:	mov    r8d,r13d
  469766:	jmp    46967b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9bb>
  46976b:	inc    DWORD PTR [rsp-0x30]
  46976f:	jmp    468e32 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x172>
  469774:	inc    DWORD PTR [rsp-0x30]
  469778:	jmp    468dbd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xfd>
  46977d:	inc    DWORD PTR [rsp-0x30]
  469781:	jmp    468ea6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1e6>
  469786:	inc    DWORD PTR [rsp-0x30]
  46978a:	jmp    468f20 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x260>
