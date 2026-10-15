0000000000468cf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  468cf0:	push   rbp
  468cf1:	mov    rcx,rdi
  468cf4:	mov    rbp,rsp
  468cf7:	push   r15
  468cf9:	mov    r15,rdx
  468cfc:	push   r14
  468cfe:	push   r13
  468d00:	push   r12
  468d02:	push   rbx
  468d03:	and    rsp,0xffffffffffffffc0
  468d07:	sub    rsp,0x8
  468d0b:	mov    rdi,QWORD PTR [rsi]
  468d0e:	mov    r11,QWORD PTR [rsi+0x8]
  468d12:	mov    esi,DWORD PTR [rcx+0xb0]
  468d18:	mov    eax,DWORD PTR [rcx+0xb4]
  468d1e:	mov    r8d,DWORD PTR [rcx+0x78]
  468d22:	mov    r10d,DWORD PTR [rcx+0x6c]
  468d26:	mov    r9,r11
  468d29:	mov    edx,esi
  468d2b:	shl    r9,0x4
  468d2f:	sub    edx,eax
  468d31:	lea    rbx,[rdi+r9*1]
  468d35:	and    edx,r8d
  468d38:	lea    r12d,[r10-0x1]
  468d3c:	mov    QWORD PTR [rsp-0x20],rbx
  468d41:	cmp    edx,r12d
  468d44:	jb     46951f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x82f>
  468d4a:	shl    rsi,0x4
  468d4e:	and    r11,0xfffffffffffffffc
  468d52:	shl    r11,0x4
  468d56:	mov    r14,rsi
  468d59:	mov    esi,DWORD PTR [rcx+0x80]
  468d5f:	shl    r10,0x4
  468d63:	mov    QWORD PTR [rsp-0x30],r11
  468d68:	lea    r11,[rdi+r11*1]
  468d6c:	mov    QWORD PTR [rsp],r10
  468d70:	mov    QWORD PTR [rsp-0x18],r11
  468d75:	mov    DWORD PTR [rsp-0x28],0x0
  468d7d:	mov    r9,QWORD PTR [rcx+0xa0]
  468d84:	mov    rdx,QWORD PTR [r15+0x8]
  468d88:	mov    r8,QWORD PTR [rip+0x29e59]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468d8f:	dec    r10
  468d92:	shl    rax,0x4
  468d96:	not    esi
  468d98:	cmp    rdi,r11
  468d9b:	je     4697ba <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaca>
  468da1:	mov    r13d,0x55
  468da7:	mov    ebx,0x4444
  468dac:	mov    QWORD PTR [rsp-0x38],rcx
  468db1:	mov    QWORD PTR [rsp-0x40],r15
  468db6:	vpxor  xmm2,xmm2,xmm2
  468dba:	kmovb  k1,r13d
  468dbf:	kmovw  k2,ebx
  468dc3:	jmp    469005 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x315>
  468dc8:	nop    DWORD PTR [rax+rax*1+0x0]
  468dd0:	xor    ebx,ebx
  468dd2:	mov    r12d,DWORD PTR [r13+0xc]
  468dd6:	kmovb  r13d,k4
  468dda:	tzcnt  ebx,r13d
  468ddf:	inc    ebx
  468de1:	movsxd rcx,ebx
  468de4:	mov    r11,QWORD PTR [r11+rcx*8]
  468de8:	mov    DWORD PTR [rdx],r12d
  468deb:	mov    QWORD PTR [rdx+0x8],r11
  468def:	add    rdx,0x10
  468df3:	lea    r13,[r9+rax*1]
  468df7:	mov    ebx,DWORD PTR [r13+0x8]
  468dfb:	andn   r11d,esi,ebx
  468e00:	shl    r11,0x4
  468e04:	add    r11,r8
  468e07:	vmovdqa64 zmm12,ZMMWORD PTR [r11]
  468e0d:	vpbroadcastq zmm13,QWORD PTR [r13+0x0]
  468e14:	vpcmpequq k6{k1},zmm12,zmm13
  468e1b:	lea    r15,[rax+0x180]
  468e22:	add    rax,0x10
  468e26:	and    r15,r10
  468e29:	and    rax,r10
  468e2c:	andn   ecx,esi,DWORD PTR [r9+r15*1+0x8]
  468e33:	shl    rcx,0x4
  468e37:	kortestb k6,k6
  468e3b:	prefetcht0 BYTE PTR [r8+rcx*1]
  468e40:	je     469470 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x780>
  468e46:	xor    ebx,ebx
  468e48:	mov    r12d,DWORD PTR [r13+0xc]
  468e4c:	kmovb  r13d,k6
  468e50:	tzcnt  ebx,r13d
  468e55:	inc    ebx
  468e57:	movsxd r15,ebx
  468e5a:	mov    r11,QWORD PTR [r11+r15*8]
  468e5e:	mov    DWORD PTR [rdx],r12d
  468e61:	mov    QWORD PTR [rdx+0x8],r11
  468e65:	add    rdx,0x10
  468e69:	lea    r15,[r9+rax*1]
  468e6d:	mov    ebx,DWORD PTR [r15+0x8]
  468e71:	andn   r11d,esi,ebx
  468e76:	shl    r11,0x4
  468e7a:	add    r11,r8
  468e7d:	vmovdqa64 zmm0,ZMMWORD PTR [r11]
  468e83:	vpbroadcastq zmm1,QWORD PTR [r15]
  468e89:	vpcmpequq k0{k1},zmm0,zmm1
  468e90:	lea    rcx,[rax+0x180]
  468e97:	add    rax,0x10
  468e9b:	and    rcx,r10
  468e9e:	and    rax,r10
  468ea1:	andn   r12d,esi,DWORD PTR [r9+rcx*1+0x8]
  468ea8:	shl    r12,0x4
  468eac:	kortestb k0,k0
  468eb0:	prefetcht0 BYTE PTR [r8+r12*1]
  468eb5:	je     469420 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x730>
  468ebb:	xor    ebx,ebx
  468ebd:	mov    r13d,DWORD PTR [r15+0xc]
  468ec1:	kmovb  r15d,k0
  468ec5:	tzcnt  ebx,r15d
  468eca:	inc    ebx
  468ecc:	movsxd rcx,ebx
  468ecf:	mov    r11,QWORD PTR [r11+rcx*8]
  468ed3:	mov    DWORD PTR [rdx],r13d
  468ed6:	mov    QWORD PTR [rdx+0x8],r11
  468eda:	add    rdx,0x10
  468ede:	lea    r15,[r9+rax*1]
  468ee2:	mov    ebx,DWORD PTR [r15+0x8]
  468ee6:	andn   r11d,esi,ebx
  468eeb:	shl    r11,0x4
  468eef:	add    r11,r8
  468ef2:	vmovdqa64 zmm4,ZMMWORD PTR [r11]
  468ef8:	vpbroadcastq zmm6,QWORD PTR [r15]
  468efe:	vpcmpequq k4{k1},zmm4,zmm6
  468f05:	lea    r12,[rax+0x180]
  468f0c:	add    rax,0x10
  468f10:	and    r12,r10
  468f13:	and    rax,r10
  468f16:	andn   ecx,esi,DWORD PTR [r9+r12*1+0x8]
  468f1d:	shl    rcx,0x4
  468f21:	kortestb k4,k4
  468f25:	prefetcht0 BYTE PTR [r8+rcx*1]
  468f2a:	lea    rcx,[r9+r14*1]
  468f2e:	je     4693d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e8>
  468f34:	xor    r13d,r13d
  468f37:	kmovb  ebx,k4
  468f3b:	tzcnt  r13d,ebx
  468f40:	inc    r13d
  468f43:	movsxd r12,r13d
  468f46:	mov    r15d,DWORD PTR [r15+0xc]
  468f4a:	mov    r11,QWORD PTR [r11+r12*8]
  468f4e:	mov    DWORD PTR [rdx],r15d
  468f51:	mov    QWORD PTR [rdx+0x8],r11
  468f55:	add    rdx,0x10
  468f59:	mov    r13d,0xffffffff
  468f5f:	mov    r11d,0xffffffff
  468f65:	crc32  r13,QWORD PTR [rdi]
  468f6b:	crc32  r11,QWORD PTR [rdi+0x10]
  468f72:	andn   r15d,esi,r13d
  468f77:	shl    r15,0x4
  468f7b:	andn   ebx,esi,r11d
  468f80:	shl    rbx,0x4
  468f84:	prefetcht2 BYTE PTR [r8+r15*1]
  468f89:	prefetcht2 BYTE PTR [r8+rbx*1]
  468f8e:	mov    r15d,0xffffffff
  468f94:	mov    ebx,0xffffffff
  468f99:	crc32  r15,QWORD PTR [rdi+0x20]
  468fa0:	crc32  rbx,QWORD PTR [rdi+0x30]
  468fa7:	andn   r12d,esi,r15d
  468fac:	shl    r12,0x4
  468fb0:	prefetcht2 BYTE PTR [r8+r12*1]
  468fb5:	andn   r12d,esi,ebx
  468fba:	shl    r12,0x4
  468fbe:	prefetcht2 BYTE PTR [r8+r12*1]
  468fc3:	lea    r12,[r14+0x40]
  468fc7:	vmovdqu64 zmm9,ZMMWORD PTR [rdi]
  468fcd:	cmp    QWORD PTR [rsp],r12
  468fd1:	jb     4694c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
  468fd7:	vmovdqu64 ZMMWORD PTR [rcx],zmm9
  468fdd:	mov    DWORD PTR [rcx+0x8],r13d
  468fe1:	mov    DWORD PTR [r9+r14*1+0x18],r11d
  468fe6:	mov    DWORD PTR [r9+r14*1+0x28],r15d
  468feb:	mov    DWORD PTR [r9+r14*1+0x38],ebx
  468ff0:	mov    r14,r12
  468ff3:	add    rdi,0x40
  468ff7:	and    r14,r10
  468ffa:	cmp    QWORD PTR [rsp-0x18],rdi
  468fff:	je     4690a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3b0>
  469005:	lea    r13,[r9+rax*1]
  469009:	mov    ebx,DWORD PTR [r13+0x8]
  46900d:	andn   r11d,esi,ebx
  469012:	shl    r11,0x4
  469016:	add    r11,r8
  469019:	vmovdqa64 zmm8,ZMMWORD PTR [r11]
  46901f:	vpbroadcastq zmm9,QWORD PTR [r13+0x0]
  469026:	vpcmpequq k4{k1},zmm8,zmm9
  46902d:	lea    rcx,[rax+0x180]
  469034:	add    rax,0x10
  469038:	and    rcx,r10
  46903b:	and    rax,r10
  46903e:	andn   r15d,esi,DWORD PTR [r9+rcx*1+0x8]
  469045:	shl    r15,0x4
  469049:	kortestb k4,k4
  46904d:	prefetcht0 BYTE PTR [r8+r15*1]
  469052:	jne    468dd0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xe0>
  469058:	vpcmpequq k5{k1},zmm8,zmm2
  46905f:	kortestb k5,k5
  469063:	jne    4697e4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaf4>
  469069:	vmovdqu xmm10,XMMWORD PTR [r13+0x0]
  46906f:	mov    ecx,0xffffffff
  469074:	crc32  rcx,rbx
  46907a:	vpinsrd xmm11,xmm10,ecx,0x2
  469080:	andn   r15d,esi,ecx
  469085:	shl    r15,0x4
  469089:	prefetcht2 BYTE PTR [r8+r15*1]
  46908e:	vmovdqu XMMWORD PTR [r9+r14*1],xmm11
  469094:	add    r14,0x10
  469098:	and    r14,r10
  46909b:	jmp    469005 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x315>
  4690a0:	mov    rcx,QWORD PTR [rsp-0x38]
  4690a5:	mov    r15,QWORD PTR [rsp-0x40]
  4690aa:	mov    r12d,DWORD PTR [rsp-0x28]
  4690af:	vmovq  xmm15,r14
  4690b4:	vpinsrq xmm0,xmm15,rax,0x1
  4690ba:	mov    rdx,QWORD PTR [rsp-0x30]
  4690bf:	vpsrlq xmm1,xmm0,0x4
  4690c4:	vpmovqd xmm7,xmm1
  4690ca:	sar    rdx,0x4
  4690ce:	vmovq  QWORD PTR [rcx+0xb0],xmm7
  4690d6:	sub    rdx,r12
  4690d9:	add    DWORD PTR [r15],edx
  4690dc:	vpextrd eax,xmm7,0x1
  4690e2:	cmp    rdi,QWORD PTR [rsp-0x20]
  4690e7:	je     4693c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d0>
  4690ed:	mov    r14,QWORD PTR [rcx+0x88]
  4690f4:	mov    rbx,QWORD PTR [rcx+0x80]
  4690fb:	mov    rsi,QWORD PTR [rcx+0x60]
  4690ff:	dec    r14
  469102:	mov    QWORD PTR [rsp-0x18],rbx
  469107:	mov    QWORD PTR [rsp],rsi
  46910b:	mov    QWORD PTR [rsp-0x28],r14
  469110:	mov    r10d,DWORD PTR [rcx+0x78]
  469114:	mov    r11,QWORD PTR [rip+0x29acd]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46911b:	mov    r9,QWORD PTR [rcx+0xa0]
  469122:	movzx  r13d,BYTE PTR [rip+0x299d6]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  46912a:	mov    r12,QWORD PTR [rip+0x299d7]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469131:	mov    r8d,0x55
  469137:	vpxor  xmm3,xmm3,xmm3
  46913b:	kmovb  k3,r8d
  469140:	lea    edx,[rax+0x18]
  469143:	and    edx,r10d
  469146:	shl    rdx,0x4
  46914a:	mov    esi,ebx
  46914c:	and    esi,DWORD PTR [r9+rdx*1+0x8]
  469151:	mov    edx,eax
  469153:	shl    rdx,0x4
  469157:	add    rdx,r9
  46915a:	mov    r8,QWORD PTR [rdx]
  46915d:	shl    rsi,0x4
  469161:	prefetcht0 BYTE PTR [r11+rsi*1]
  469166:	cmp    r8,QWORD PTR [rcx+0x90]
  46916d:	jne    469230 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x540>
  469173:	test   r13b,r13b
  469176:	je     469196 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a6>
  469178:	mov    r14d,DWORD PTR [r15]
  46917b:	mov    edx,DWORD PTR [rdx+0xc]
  46917e:	mov    r8,r14
  469181:	shl    r14,0x4
  469185:	add    r14,QWORD PTR [r15+0x8]
  469189:	inc    r8d
  46918c:	mov    DWORD PTR [r14],edx
  46918f:	mov    QWORD PTR [r14+0x8],r12
  469193:	mov    DWORD PTR [r15],r8d
  469196:	inc    eax
  469198:	and    eax,r10d
  46919b:	mov    DWORD PTR [rcx+0xb4],eax
  4691a1:	test   r12,r12
  4691a4:	jne    469140 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x450>
  4691a6:	cmp    QWORD PTR [rsp],0x4
  4691ab:	je     469325 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x635>
  4691b1:	nop    DWORD PTR [rax+0x0]
  4691b8:	cmp    QWORD PTR [rsp],0x8
  4691bd:	je     4693a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  4691c3:	vmovd  xmm2,DWORD PTR [rsp-0x10]
  4691c9:	mov    rsi,QWORD PTR [rdi]
  4691cc:	mov    edx,DWORD PTR [rcx+0xb0]
  4691d2:	mov    r8,QWORD PTR [rsp-0x28]
  4691d7:	mov    rax,rdx
  4691da:	and    r8,QWORD PTR [rsp-0x10]
  4691df:	vpinsrd xmm11,xmm2,DWORD PTR [rdi+0xc],0x1
  4691e6:	and    r8,0xfffffffffffffffc
  4691ea:	shl    rdx,0x4
  4691ee:	inc    eax
  4691f0:	add    rdx,r9
  4691f3:	shl    r8,0x4
  4691f7:	and    eax,r10d
  4691fa:	add    rdi,0x10
  4691fe:	prefetcht2 BYTE PTR [r11+r8*1]
  469203:	mov    QWORD PTR [rdx],rsi
  469206:	vmovq  QWORD PTR [rdx+0x8],xmm11
  46920b:	mov    DWORD PTR [rcx+0xb0],eax
  469211:	cmp    rdi,QWORD PTR [rsp-0x20]
  469216:	je     4693c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d0>
  46921c:	mov    eax,DWORD PTR [rcx+0xb4]
  469222:	jmp    469140 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x450>
  469227:	nop    WORD PTR [rax+rax*1+0x0]
  469230:	mov    r14d,DWORD PTR [rdx+0x8]
  469234:	mov    esi,ebx
  469236:	and    esi,r14d
  469239:	shl    rsi,0x4
  46923d:	add    rsi,r11
  469240:	vmovdqa64 zmm4,ZMMWORD PTR [rsi]
  469246:	vpbroadcastq zmm6,r8
  46924c:	vpcmpequq k0{k3},zmm4,zmm6
  469253:	kortestb k0,k0
  469257:	jne    4692e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5f0>
  46925d:	vpcmpequq k4{k3},zmm4,zmm3
  469264:	kortestb k4,k4
  469268:	jne    469350 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x660>
  46926e:	cmp    QWORD PTR [rsp],0x4
  469273:	mov    esi,r14d
  469276:	je     469360 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x670>
  46927c:	cmp    QWORD PTR [rsp],0x8
  469281:	je     469380 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x690>
  469287:	vmovd  xmm5,DWORD PTR [rsp-0x8]
  46928d:	mov    esi,DWORD PTR [rcx+0xb0]
  469293:	mov    r14,QWORD PTR [rsp-0x18]
  469298:	vpinsrd xmm9,xmm5,DWORD PTR [rdx+0xc],0x1
  46929f:	mov    rdx,rsi
  4692a2:	and    r14,QWORD PTR [rsp-0x8]
  4692a7:	shl    rsi,0x4
  4692ab:	inc    edx
  4692ad:	inc    eax
  4692af:	add    rsi,r9
  4692b2:	shl    r14,0x4
  4692b6:	and    edx,r10d
  4692b9:	and    eax,r10d
  4692bc:	prefetcht2 BYTE PTR [r11+r14*1]
  4692c1:	mov    QWORD PTR [rsi],r8
  4692c4:	vmovq  QWORD PTR [rsi+0x8],xmm9
  4692c9:	mov    DWORD PTR [rcx+0xb0],edx
  4692cf:	mov    DWORD PTR [rcx+0xb4],eax
  4692d5:	jmp    469140 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x450>
  4692da:	nop    WORD PTR [rax+rax*1+0x0]
  4692e0:	mov    r8d,DWORD PTR [r15]
  4692e3:	mov    edx,DWORD PTR [rdx+0xc]
  4692e6:	mov    r14,r8
  4692e9:	shl    r8,0x4
  4692ed:	add    r8,QWORD PTR [r15+0x8]
  4692f1:	mov    DWORD PTR [r8],edx
  4692f4:	kmovb  edx,k0
  4692f8:	tzcnt  edx,edx
  4692fc:	inc    edx
  4692fe:	movsxd rdx,edx
  469301:	mov    rsi,QWORD PTR [rsi+rdx*8]
  469305:	inc    eax
  469307:	inc    r14d
  46930a:	and    eax,r10d
  46930d:	cmp    QWORD PTR [rsp],0x4
  469312:	mov    QWORD PTR [r8+0x8],rsi
  469316:	mov    DWORD PTR [r15],r14d
  469319:	mov    DWORD PTR [rcx+0xb4],eax
  46931f:	jne    4691b8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4c8>
  469325:	mov    r14d,0xffffffff
  46932b:	crc32  r14d,DWORD PTR [rdi]
  469331:	vmovd  xmm10,r14d
  469336:	mov    rsi,QWORD PTR [rdi]
  469339:	vmovdqa xmm2,xmm10
  46933d:	vmovq  QWORD PTR [rsp-0x10],xmm10
  469343:	jmp    4691cc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4dc>
  469348:	nop    DWORD PTR [rax+rax*1+0x0]
  469350:	inc    eax
  469352:	and    eax,r10d
  469355:	mov    DWORD PTR [rcx+0xb4],eax
  46935b:	jmp    4691a6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4b6>
  469360:	mov    esi,0xffffffff
  469365:	crc32  esi,r14d
  46936b:	vmovd  xmm8,esi
  46936f:	vmovdqa xmm5,xmm8
  469373:	vmovq  QWORD PTR [rsp-0x8],xmm8
  469379:	jmp    46928d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x59d>
  46937e:	xchg   ax,ax
  469380:	mov    r14d,0xffffffff
  469386:	crc32  r14,rsi
  46938c:	mov    QWORD PTR [rsp-0x8],r14
  469391:	vmovd  xmm5,r14d
  469396:	jmp    46928d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x59d>
  46939b:	nop    DWORD PTR [rax+rax*1+0x0]
  4693a0:	mov    rsi,QWORD PTR [rdi]
  4693a3:	mov    eax,0xffffffff
  4693a8:	crc32  rax,rsi
  4693ae:	mov    QWORD PTR [rsp-0x10],rax
  4693b3:	vmovd  xmm2,eax
  4693b7:	jmp    4691cc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4dc>
  4693bc:	nop    DWORD PTR [rax+0x0]
  4693c0:	vzeroupper 
  4693c3:	lea    rsp,[rbp-0x28]
  4693c7:	pop    rbx
  4693c8:	pop    r12
  4693ca:	pop    r13
  4693cc:	pop    r14
  4693ce:	pop    r15
  4693d0:	pop    rbp
  4693d1:	ret    
  4693d2:	nop    WORD PTR [rax+rax*1+0x0]
  4693d8:	vpcmpequq k5{k1},zmm4,zmm2
  4693df:	kortestb k5,k5
  4693e3:	jne    4697f6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb06>
  4693e9:	vmovdqu xmm5,XMMWORD PTR [r15]
  4693ee:	mov    r13d,0xffffffff
  4693f4:	crc32  r13,rbx
  4693fa:	vpinsrd xmm8,xmm5,r13d,0x2
  469400:	add    r14,0x10
  469404:	andn   r12d,esi,r13d
  469409:	shl    r12,0x4
  46940d:	and    r14,r10
  469410:	prefetcht2 BYTE PTR [r8+r12*1]
  469415:	vmovdqu XMMWORD PTR [rcx],xmm8
  469419:	jmp    468ede <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1ee>
  46941e:	xchg   ax,ax
  469420:	vpcmpequq k3{k1},zmm0,zmm2
  469427:	kortestb k3,k3
  46942b:	jne    4697ed <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xafd>
  469431:	vmovdqu xmm7,XMMWORD PTR [r15]
  469436:	mov    ecx,0xffffffff
  46943b:	crc32  rcx,rbx
  469441:	vpinsrd xmm3,xmm7,ecx,0x2
  469447:	andn   r12d,esi,ecx
  46944c:	shl    r12,0x4
  469450:	prefetcht2 BYTE PTR [r8+r12*1]
  469455:	vmovdqu XMMWORD PTR [r9+r14*1],xmm3
  46945b:	add    r14,0x10
  46945f:	and    r14,r10
  469462:	jmp    468e69 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x179>
  469467:	nop    WORD PTR [rax+rax*1+0x0]
  469470:	vpcmpequq k7{k1},zmm12,zmm2
  469477:	kortestb k7,k7
  46947b:	jne    4697db <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaeb>
  469481:	vmovdqu xmm14,XMMWORD PTR [r13+0x0]
  469487:	mov    r15d,0xffffffff
  46948d:	crc32  r15,rbx
  469493:	vpinsrd xmm15,xmm14,r15d,0x2
  469499:	andn   ecx,esi,r15d
  46949e:	shl    rcx,0x4
  4694a2:	prefetcht2 BYTE PTR [r8+rcx*1]
  4694a7:	vmovdqu XMMWORD PTR [r9+r14*1],xmm15
  4694ad:	add    r14,0x10
  4694b1:	and    r14,r10
  4694b4:	jmp    468df3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x103>
  4694b9:	nop    DWORD PTR [rax+0x0]
  4694c0:	vmovd  xmm12,r13d
  4694c5:	mov    r13,QWORD PTR [rsp]
  4694c9:	vmovd  xmm10,r15d
  4694ce:	vpinsrd xmm13,xmm12,r11d,0x1
  4694d4:	mov    r11,r13
  4694d7:	vpinsrd xmm11,xmm10,ebx,0x1
  4694dd:	sub    r11,r14
  4694e0:	vpunpcklqdq xmm14,xmm13,xmm11
  4694e5:	shr    r11,0x2
  4694e9:	mov    r15d,0x1
  4694ef:	vpexpandd zmm9{k2},zmm14
  4694f5:	shlx   r11d,r15d,r11d
  4694fa:	lea    ebx,[r11-0x1]
  4694fe:	sub    r14,r13
  469501:	neg    r11d
  469504:	kmovw  k6,ebx
  469508:	vmovdqu32 ZMMWORD PTR [rcx]{k6},zmm9
  46950e:	kmovw  k7,r11d
  469513:	vmovdqu32 ZMMWORD PTR [r9+r14*1]{k7},zmm9
  46951a:	jmp    468ff0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x300>
  46951f:	cmp    rdi,QWORD PTR [rsp-0x20]
  469524:	je     4693c3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d3>
  46952a:	mov    r12,QWORD PTR [rcx+0x88]
  469531:	movzx  r13d,BYTE PTR [rip+0x295c7]        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  469539:	mov    r9,QWORD PTR [rip+0x295c8]        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469540:	mov    r10,QWORD PTR [rcx+0x60]
  469544:	mov    ebx,0x55
  469549:	dec    r12
  46954c:	kmovb  k2,r13d
  469551:	mov    QWORD PTR [rsp],r10
  469555:	mov    QWORD PTR [rsp-0x8],r12
  46955a:	mov    r14,QWORD PTR [rip+0x29687]        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469561:	mov    r11,QWORD PTR [rcx+0xa0]
  469568:	mov    edx,esi
  46956a:	vpxor  xmm2,xmm2,xmm2
  46956e:	mov    r13,r9
  469571:	kmovb  k1,ebx
  469575:	jmp    4695dd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8ed>
  469577:	cmp    QWORD PTR [rsp],0x8
  46957c:	je     469788 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa98>
  469582:	vmovd  xmm4,DWORD PTR [rsp-0x18]
  469588:	mov    r12,QWORD PTR [rsp-0x8]
  46958d:	mov    edx,esi
  46958f:	and    r12,QWORD PTR [rsp-0x18]
  469594:	vpinsrd xmm5,xmm4,DWORD PTR [rdi+0xc],0x1
  46959b:	mov    r10,QWORD PTR [rdi]
  46959e:	and    r12,0xfffffffffffffffc
  4695a2:	shl    rdx,0x4
  4695a6:	add    rdx,r11
  4695a9:	shl    r12,0x4
  4695ad:	prefetcht2 BYTE PTR [r14+r12*1]
  4695b2:	mov    QWORD PTR [rdx],r10
  4695b5:	vmovq  QWORD PTR [rdx+0x8],xmm5
  4695ba:	lea    edx,[rsi+0x1]
  4695bd:	and    edx,r8d
  4695c0:	add    rdi,0x10
  4695c4:	mov    DWORD PTR [rcx+0xb0],edx
  4695ca:	cmp    QWORD PTR [rsp-0x20],rdi
  4695cf:	je     4693c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d0>
  4695d5:	mov    eax,DWORD PTR [rcx+0xb4]
  4695db:	mov    esi,edx
  4695dd:	sub    edx,eax
  4695df:	and    edx,r8d
  4695e2:	cmp    r8d,edx
  4695e5:	jbe    469608 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x918>
  4695e7:	cmp    QWORD PTR [rsp],0x4
  4695ec:	jne    469577 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x887>
  4695ee:	mov    ebx,0xffffffff
  4695f3:	crc32  ebx,DWORD PTR [rdi]
  4695f8:	vmovd  xmm6,ebx
  4695fc:	vmovdqa xmm4,xmm6
  469600:	vmovq  QWORD PTR [rsp-0x18],xmm6
  469606:	jmp    469588 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x898>
  469608:	mov    rbx,QWORD PTR [rcx+0x80]
  46960f:	mov    QWORD PTR [rsp-0x10],rbx
  469614:	nop    DWORD PTR [rax+0x0]
  469618:	lea    edx,[rax+0x18]
  46961b:	and    edx,r8d
  46961e:	shl    rdx,0x4
  469622:	mov    r9d,ebx
  469625:	and    r9d,DWORD PTR [r11+rdx*1+0x8]
  46962a:	mov    edx,eax
  46962c:	mov    r10,r9
  46962f:	shl    rdx,0x4
  469633:	shl    r10,0x4
  469637:	add    rdx,r11
  46963a:	prefetcht0 BYTE PTR [r14+r10*1]
  46963f:	mov    r10,QWORD PTR [rdx]
  469642:	cmp    r10,QWORD PTR [rcx+0x90]
  469649:	jne    469690 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a0>
  46964b:	kortestb k2,k2
  46964f:	je     469672 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x982>
  469651:	mov    r12d,DWORD PTR [r15]
  469654:	mov    edx,DWORD PTR [rdx+0xc]
  469657:	mov    r10,r12
  46965a:	shl    r12,0x4
  46965e:	add    r12,QWORD PTR [r15+0x8]
  469662:	lea    r9d,[r10+0x1]
  469666:	mov    DWORD PTR [r12],edx
  46966a:	mov    QWORD PTR [r12+0x8],r13
  46966f:	mov    DWORD PTR [r15],r9d
  469672:	inc    eax
  469674:	and    eax,r8d
  469677:	mov    DWORD PTR [rcx+0xb4],eax
  46967d:	test   r13,r13
  469680:	jne    469618 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x928>
  469682:	jmp    4695e7 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8f7>
  469687:	nop    WORD PTR [rax+rax*1+0x0]
  469690:	mov    r12d,DWORD PTR [rdx+0x8]
  469694:	mov    r9d,ebx
  469697:	and    r9d,r12d
  46969a:	shl    r9,0x4
  46969e:	add    r9,r14
  4696a1:	vmovdqa64 zmm0,ZMMWORD PTR [r9]
  4696a7:	vpbroadcastq zmm1,r10
  4696ad:	vpcmpequq k0{k1},zmm0,zmm1
  4696b4:	kortestb k0,k0
  4696b8:	jne    469734 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa44>
  4696ba:	vpcmpequq k3{k1},zmm0,zmm2
  4696c1:	kortestb k3,k3
  4696c5:	jne    469778 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa88>
  4696cb:	cmp    QWORD PTR [rsp],0x4
  4696d0:	mov    r9d,r12d
  4696d3:	je     4697a1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xab1>
  4696d9:	cmp    QWORD PTR [rsp],0x8
  4696de:	je     4697c2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad2>
  4696e4:	mov    r9d,DWORD PTR [rsp-0x28]
  4696e9:	mov    r12,QWORD PTR [rsp-0x10]
  4696ee:	vmovd  xmm7,r9d
  4696f3:	vpinsrd xmm3,xmm7,DWORD PTR [rdx+0xc],0x1
  4696fa:	mov    edx,esi
  4696fc:	and    r12,QWORD PTR [rsp-0x28]
  469701:	shl    rdx,0x4
  469705:	inc    esi
  469707:	inc    eax
  469709:	add    rdx,r11
  46970c:	shl    r12,0x4
  469710:	and    esi,r8d
  469713:	and    eax,r8d
  469716:	prefetcht2 BYTE PTR [r14+r12*1]
  46971b:	mov    QWORD PTR [rdx],r10
  46971e:	vmovq  QWORD PTR [rdx+0x8],xmm3
  469723:	mov    DWORD PTR [rcx+0xb0],esi
  469729:	mov    DWORD PTR [rcx+0xb4],eax
  46972f:	jmp    469618 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x928>
  469734:	mov    r10d,DWORD PTR [r15]
  469737:	mov    r12d,DWORD PTR [rdx+0xc]
  46973b:	mov    rbx,r10
  46973e:	shl    r10,0x4
  469742:	add    r10,QWORD PTR [r15+0x8]
  469746:	mov    DWORD PTR [r10],r12d
  469749:	xor    r12d,r12d
  46974c:	kmovb  edx,k0
  469750:	tzcnt  r12d,edx
  469755:	inc    r12d
  469758:	movsxd rdx,r12d
  46975b:	mov    r9,QWORD PTR [r9+rdx*8]
  46975f:	inc    eax
  469761:	inc    ebx
  469763:	and    eax,r8d
  469766:	mov    QWORD PTR [r10+0x8],r9
  46976a:	mov    DWORD PTR [r15],ebx
  46976d:	mov    DWORD PTR [rcx+0xb4],eax
  469773:	jmp    4695e7 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8f7>
  469778:	inc    eax
  46977a:	and    eax,r8d
  46977d:	mov    DWORD PTR [rcx+0xb4],eax
  469783:	jmp    4695e7 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8f7>
  469788:	mov    eax,0xffffffff
  46978d:	crc32  rax,QWORD PTR [rdi]
  469793:	mov    QWORD PTR [rsp-0x18],rax
  469798:	vmovd  xmm4,eax
  46979c:	jmp    469588 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x898>
  4697a1:	mov    r9d,0xffffffff
  4697a7:	crc32  r9d,r12d
  4697ad:	mov    r12d,r9d
  4697b0:	mov    QWORD PTR [rsp-0x28],r12
  4697b5:	jmp    4696e9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9f9>
  4697ba:	xor    r12d,r12d
  4697bd:	jmp    4690af <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3bf>
  4697c2:	mov    r12d,0xffffffff
  4697c8:	crc32  r12,r9
  4697ce:	mov    QWORD PTR [rsp-0x28],r12
  4697d3:	mov    r9d,r12d
  4697d6:	jmp    4696e9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9f9>
  4697db:	inc    DWORD PTR [rsp-0x28]
  4697df:	jmp    468e69 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x179>
  4697e4:	inc    DWORD PTR [rsp-0x28]
  4697e8:	jmp    468df3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x103>
  4697ed:	inc    DWORD PTR [rsp-0x28]
  4697f1:	jmp    468ede <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1ee>
  4697f6:	inc    DWORD PTR [rsp-0x28]
  4697fa:	jmp    468f59 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x269>
