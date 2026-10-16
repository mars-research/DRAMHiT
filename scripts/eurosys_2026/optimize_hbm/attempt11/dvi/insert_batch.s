0000000000469640 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
  469640:	lea    r10,[rsp+0x8]
  469645:	and    rsp,0xffffffffffffffc0
  469649:	push   QWORD PTR [r10-0x8]
  46964d:	mov    rcx,rdi
  469650:	push   rbp
  469651:	mov    rbp,rsp
  469654:	push   r15
  469656:	push   r14
  469658:	push   r13
  46965a:	push   r12
  46965c:	push   r10
  46965e:	push   rbx
  46965f:	sub    rsp,0x140
  469666:	mov    r15,QWORD PTR [rsi]
  469669:	mov    rax,QWORD PTR [rsi+0x8]
  46966d:	mov    esi,DWORD PTR [rdi+0xc8]
  469673:	mov    edi,DWORD PTR [rdi+0xcc]
  469679:	mov    r8d,DWORD PTR [rcx+0x70]
  46967d:	mov    rdx,rax
  469680:	mov    r11d,esi
  469683:	shl    rdx,0x4
  469687:	sub    r11d,edi
  46968a:	add    rdx,r15
  46968d:	and    r11d,DWORD PTR [rcx+0x74]
  469691:	lea    r9d,[r8-0x1]
  469695:	mov    QWORD PTR [rbp-0x88],rdx
  46969c:	cmp    r11d,r9d
  46969f:	jb     469b58 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x518>
  4696a5:	and    rax,0xfffffffffffffffc
  4696a9:	shl    r8,0x2
  4696ad:	mov    r12d,DWORD PTR [rcx+0x80]
  4696b4:	shl    rax,0x4
  4696b8:	lea    rbx,[rdi*4+0x0]
  4696c0:	add    rax,r15
  4696c3:	lea    rdi,[r8-0x14]
  4696c7:	mov    QWORD PTR [rbp-0x78],r8
  4696cb:	mov    QWORD PTR [rbp-0x70],rdi
  4696cf:	mov    QWORD PTR [rbp-0x90],rax
  4696d6:	mov    r10,QWORD PTR [rcx+0xb0]
  4696dd:	mov    r9,QWORD PTR [rcx+0xb8]
  4696e4:	mov    r13,QWORD PTR [rip+0x2a505]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4696eb:	lea    r14,[r8-0x1]
  4696ef:	lea    r11,[rsi*4+0x0]
  4696f7:	not    r12d
  4696fa:	cmp    r15,rax
  4696fd:	je     4699a3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x363>
  469703:	mov    QWORD PTR [rbp-0xf0],rbx
  46970a:	mov    QWORD PTR [rbp-0x148],rcx
  469711:	mov    eax,0x55
  469716:	mov    rdx,r15
  469719:	mov    r15,r9
  46971c:	kmovb  k2,eax
  469720:	mov    r8,QWORD PTR [rbp-0x78]
  469724:	mov    rbx,QWORD PTR [rbp-0xf0]
  46972b:	mov    QWORD PTR [rbp-0x80],rdx
  46972f:	vpxor  xmm4,xmm4,xmm4
  469733:	mov    rdx,r14
  469736:	cs nop WORD PTR [rax+rax*1+0x0]
  469740:	lea    rsi,[rbx+0x10]
  469744:	lea    rdi,[r10+rbx*4]
  469748:	lea    rax,[r15+rbx*1]
  46974c:	cmp    r8,rsi
  46974f:	jb     46a058 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa18>
  469755:	vmovdqa64 zmm9,ZMMWORD PTR [rdi]
  46975b:	vmovdqu xmm10,XMMWORD PTR [rax]
  46975f:	lea    rdi,[rbx+0x20]
  469763:	and    rdi,rdx
  469766:	lea    r14,[rbx+0x24]
  46976a:	andn   eax,r12d,DWORD PTR [r15+rdi*1]
  469770:	shl    rax,0x4
  469774:	lea    rdi,[rbx+0x28]
  469778:	add    rbx,0x2c
  46977c:	and    r14,rdx
  46977f:	and    rdi,rdx
  469782:	and    rbx,rdx
  469785:	prefetchw BYTE PTR [r13+rax*1+0x0]
  46978b:	andn   eax,r12d,DWORD PTR [r15+r14*1]
  469791:	shl    rax,0x4
  469795:	andn   r14d,r12d,DWORD PTR [r15+rbx*1]
  46979b:	shl    r14,0x4
  46979f:	prefetchw BYTE PTR [r13+rax*1+0x0]
  4697a5:	prefetchw BYTE PTR [r13+r14*1+0x0]
  4697ab:	andn   eax,r12d,DWORD PTR [r15+rdi*1]
  4697b1:	shl    rax,0x4
  4697b5:	vmovd  r14d,xmm10
  4697ba:	andn   edi,r12d,r14d
  4697bf:	shl    rdi,0x4
  4697c3:	add    rdi,r13
  4697c6:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  4697cc:	vshufi64x2 zmm0,zmm9,zmm9,0x0
  4697d3:	vpcmpequq k1{k2},zmm5,zmm0
  4697da:	and    rsi,rdx
  4697dd:	prefetchw BYTE PTR [r13+rax*1+0x0]
  4697e3:	mov    rbx,rsi
  4697e6:	kortestb k1,k1
  4697ea:	je     469f70 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x930>
  4697f0:	kshiftlb k3,k1,0x1
  4697f6:	vmovdqu64 ZMMWORD PTR [rdi]{k3},zmm0
  4697fc:	vpextrd r14d,xmm10,0x1
  469802:	andn   edi,r12d,r14d
  469807:	shl    rdi,0x4
  46980b:	add    rdi,r13
  46980e:	vmovdqa64 zmm7,ZMMWORD PTR [rdi]
  469814:	vshufi64x2 zmm0,zmm9,zmm9,0x55
  46981b:	vpcmpequq k4{k2},zmm7,zmm0
  469822:	kortestb k4,k4
  469826:	je     469e98 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x858>
  46982c:	kshiftlb k6,k4,0x1
  469832:	vmovdqu64 ZMMWORD PTR [rdi]{k6},zmm0
  469838:	vpextrd r14d,xmm10,0x2
  46983e:	andn   edi,r12d,r14d
  469843:	shl    rdi,0x4
  469847:	add    rdi,r13
  46984a:	vmovdqa64 zmm8,ZMMWORD PTR [rdi]
  469850:	vshufi64x2 zmm0,zmm9,zmm9,0xaa
  469857:	vpcmpequq k7{k2},zmm8,zmm0
  46985e:	kortestb k7,k7
  469862:	je     469db0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x770>
  469868:	kshiftlb k3,k7,0x1
  46986e:	vmovdqu64 ZMMWORD PTR [rdi]{k3},zmm0
  469874:	vpextrd r14d,xmm10,0x3
  46987a:	andn   edi,r12d,r14d
  46987f:	shl    rdi,0x4
  469883:	add    rdi,r13
  469886:	vmovdqa64 zmm11,ZMMWORD PTR [rdi]
  46988c:	vshufi64x2 zmm12,zmm9,zmm9,0xff
  469893:	vpcmpequq k0{k2},zmm11,zmm12
  46989a:	kortestb k0,k0
  46989e:	je     469cf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
  4698a4:	kshiftlb k5,k0,0x1
  4698aa:	vmovdqu64 ZMMWORD PTR [rdi]{k5},zmm12
  4698b0:	mov    rcx,r11
  4698b3:	sub    rcx,rbx
  4698b6:	and    rcx,rdx
  4698b9:	cmp    QWORD PTR [rbp-0x70],rcx
  4698bd:	jb     469740 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x100>
  4698c3:	mov    r14,rdx
  4698c6:	mov    rdx,QWORD PTR [rbp-0x80]
  4698ca:	mov    ecx,0xffffffff
  4698cf:	mov    edi,0xffffffff
  4698d4:	mov    eax,0xffffffff
  4698d9:	mov    r8d,0xffffffff
  4698df:	mov    QWORD PTR [rbp-0xf0],rbx
  4698e6:	crc32  rcx,QWORD PTR [rdx]
  4698ec:	crc32  rdi,QWORD PTR [rdx+0x10]
  4698f3:	andn   ebx,r12d,ecx
  4698f8:	shl    rbx,0x4
  4698fc:	andn   r9d,r12d,edi
  469901:	shl    r9,0x4
  469905:	crc32  rax,QWORD PTR [rdx+0x20]
  46990c:	crc32  r8,QWORD PTR [rdx+0x30]
  469913:	andn   esi,r12d,eax
  469918:	shl    rsi,0x4
  46991c:	prefetcht1 BYTE PTR [r13+rbx*1+0x0]
  469922:	prefetcht1 BYTE PTR [r13+r9*1+0x0]
  469928:	andn   ebx,r12d,r8d
  46992d:	shl    rbx,0x4
  469931:	lea    r9,[r15+r11*1]
  469935:	prefetcht1 BYTE PTR [r13+rsi*1+0x0]
  46993b:	prefetcht1 BYTE PTR [r13+rbx*1+0x0]
  469941:	lea    rsi,[r11+0x10]
  469945:	lea    rbx,[r10+r11*4]
  469949:	vmovdqu64 zmm13,ZMMWORD PTR [rdx]
  46994f:	kmovq  k6,rbx
  469954:	kmovq  k7,r9
  469959:	cmp    QWORD PTR [rbp-0x78],rsi
  46995d:	jb     46a0e6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaa6>
  469963:	vmovdqa64 ZMMWORD PTR [rbx],zmm13
  469969:	mov    DWORD PTR [r9],ecx
  46996c:	mov    DWORD PTR [r15+r11*1+0x4],edi
  469971:	mov    DWORD PTR [r15+r11*1+0x8],eax
  469976:	mov    DWORD PTR [r15+r11*1+0xc],r8d
  46997b:	and    rsi,r14
  46997e:	add    rdx,0x40
  469982:	mov    r11,rsi
  469985:	cmp    QWORD PTR [rbp-0x90],rdx
  46998c:	jne    469720 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xe0>
  469992:	mov    rbx,QWORD PTR [rbp-0xf0]
  469999:	mov    rcx,QWORD PTR [rbp-0x148]
  4699a0:	mov    r15,rdx
  4699a3:	vmovq  xmm3,r11
  4699a8:	vpinsrq xmm1,xmm3,rbx,0x1
  4699ae:	vpsrlq xmm5,xmm1,0x2
  4699b3:	mov    r14,QWORD PTR [rbp-0x88]
  4699ba:	vpmovqd xmm7,xmm5
  4699c0:	vpextrd eax,xmm7,0x1
  4699c6:	vmovq  QWORD PTR [rcx+0xc8],xmm7
  4699ce:	cmp    r15,r14
  4699d1:	je     469b3e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fe>
  4699d7:	mov    r8,QWORD PTR [rip+0x2a212]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4699de:	mov    rsi,QWORD PTR [rcx+0xb8]
  4699e5:	mov    edi,DWORD PTR [rcx+0x74]
  4699e8:	mov    rdx,QWORD PTR [rcx+0xb0]
  4699ef:	mov    r13,QWORD PTR [rbp-0x150]
  4699f6:	mov    ebx,0xffffffff
  4699fb:	mov    r12,rcx
  4699fe:	jmp    469a7a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x43a>
  469a00:	cmp    rcx,0x8
  469a04:	jne    469a0f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3cf>
  469a06:	mov    r13,rbx
  469a09:	crc32  r13,QWORD PTR [r15]
  469a0f:	mov    r10d,r13d
  469a12:	mov    r11,QWORD PTR [r12+0x88]
  469a1a:	mov    eax,DWORD PTR [r12+0xc8]
  469a22:	dec    r11
  469a25:	and    r11,r13
  469a28:	vmovdqu xmm12,XMMWORD PTR [r15]
  469a2d:	and    r11,0xfffffffffffffffc
  469a31:	mov    rdi,rax
  469a34:	shl    rdi,0x4
  469a38:	shl    r11,0x4
  469a3c:	prefetcht1 BYTE PTR [r8+r11*1]
  469a41:	vmovdqu XMMWORD PTR [rdx+rdi*1],xmm12
  469a46:	mov    DWORD PTR [rsi+rax*4],r10d
  469a4a:	add    r15,0x10
  469a4e:	mov    r9d,DWORD PTR [r12+0xc8]
  469a56:	mov    edi,DWORD PTR [r12+0x74]
  469a5b:	inc    r9d
  469a5e:	and    r9d,edi
  469a61:	mov    DWORD PTR [r12+0xc8],r9d
  469a69:	cmp    r15,r14
  469a6c:	je     469b3e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fe>
  469a72:	mov    eax,DWORD PTR [r12+0xcc]
  469a7a:	mov    ecx,DWORD PTR [r12+0x80]
  469a82:	lea    r9d,[rax+0x8]
  469a86:	and    r9d,edi
  469a89:	mov    r10d,ecx
  469a8c:	and    r10d,DWORD PTR [rsi+r9*4]
  469a90:	lea    r11d,[rax+0x1]
  469a94:	and    edi,r11d
  469a97:	shl    r10,0x4
  469a9b:	prefetchw BYTE PTR [r8+r10*1]
  469aa0:	mov    DWORD PTR [r12+0xcc],edi
  469aa8:	mov    r9d,DWORD PTR [rsi+rax*4]
  469aac:	shl    rax,0x4
  469ab0:	vbroadcasti32x4 zmm11,XMMWORD PTR [rdx+rax*1]
  469ab7:	lea    rdi,[rdx+rax*1]
  469abb:	mov    rax,QWORD PTR [r12+0x90]
  469ac3:	cmp    QWORD PTR [rdi],rax
  469ac6:	je     46a0cf <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa8f>
  469acc:	mov    edi,ecx
  469ace:	and    edi,r9d
  469ad1:	shl    rdi,0x4
  469ad5:	add    rdi,r8
  469ad8:	vmovdqa64 zmm9,ZMMWORD PTR [rdi]
  469ade:	mov    esi,0x55
  469ae3:	kmovb  k2,esi
  469ae7:	vpcmpequq k7{k2},zmm9,zmm11
  469aee:	kortestb k7,k7
  469af2:	je     46a195 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb55>
  469af8:	kshiftlb k3,k7,0x1
  469afe:	vmovdqu64 ZMMWORD PTR [rdi]{k3},zmm11
  469b04:	mov    r8,QWORD PTR [rip+0x2a0e5]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469b0b:	mov    rdx,QWORD PTR [r12+0xb0]
  469b13:	mov    rsi,QWORD PTR [r12+0xb8]
  469b1b:	mov    rcx,QWORD PTR [r12+0x60]
  469b20:	cmp    rcx,0x4
  469b24:	jne    469a00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3c0>
  469b2a:	mov    r10d,0xffffffff
  469b30:	crc32  r10d,DWORD PTR [r15]
  469b36:	mov    r13d,r10d
  469b39:	jmp    469a12 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3d2>
  469b3e:	vzeroupper
  469b41:	add    rsp,0x140
  469b48:	pop    rbx
  469b49:	pop    rsi
  469b4a:	pop    r12
  469b4c:	pop    r13
  469b4e:	pop    r14
  469b50:	pop    r15
  469b52:	pop    rbp
  469b53:	lea    rsp,[rsi-0x8]
  469b57:	ret
  469b58:	cmp    r15,QWORD PTR [rbp-0x88]
  469b5f:	je     469b41 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x501>
  469b61:	mov    r12,QWORD PTR [rcx+0x88]
  469b68:	mov    r9,QWORD PTR [rcx+0x60]
  469b6c:	mov    r8,QWORD PTR [rip+0x2a07d]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469b73:	mov    rsi,QWORD PTR [rcx+0xb0]
  469b7a:	mov    rdi,QWORD PTR [rcx+0xb8]
  469b81:	lea    r10,[r12-0x1]
  469b86:	mov    r12d,0xffffffff
  469b8c:	nop    DWORD PTR [rax+0x0]
  469b90:	cmp    r9,0x4
  469b94:	je     469cd4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x694>
  469b9a:	cmp    r9,0x8
  469b9e:	jne    469ba9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x569>
  469ba0:	mov    rbx,r12
  469ba3:	crc32  rbx,QWORD PTR [r15]
  469ba9:	mov    r13d,ebx
  469bac:	mov    eax,DWORD PTR [rcx+0xc8]
  469bb2:	mov    r14,r10
  469bb5:	and    r14,rbx
  469bb8:	vmovdqu xmm6,XMMWORD PTR [r15]
  469bbd:	mov    rdx,rax
  469bc0:	and    r14,0xfffffffffffffffc
  469bc4:	shl    rdx,0x4
  469bc8:	shl    r14,0x4
  469bcc:	prefetcht1 BYTE PTR [r8+r14*1]
  469bd1:	vmovdqu XMMWORD PTR [rsi+rdx*1],xmm6
  469bd6:	mov    DWORD PTR [rdi+rax*4],r13d
  469bda:	add    r15,0x10
  469bde:	mov    eax,DWORD PTR [rcx+0xc8]
  469be4:	mov    edx,DWORD PTR [rcx+0x74]
  469be7:	inc    eax
  469be9:	and    eax,edx
  469beb:	mov    DWORD PTR [rcx+0xc8],eax
  469bf1:	cmp    r15,QWORD PTR [rbp-0x88]
  469bf8:	je     469b3e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fe>
  469bfe:	mov    r11d,DWORD PTR [rcx+0xcc]
  469c05:	mov    r13d,DWORD PTR [rcx+0x70]
  469c09:	sub    eax,r11d
  469c0c:	and    eax,edx
  469c0e:	lea    r14d,[r13-0x1]
  469c12:	cmp    eax,r14d
  469c15:	jb     469b90 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x550>
  469c1b:	mov    r13d,DWORD PTR [rcx+0x80]
  469c22:	lea    r9d,[r11+0x8]
  469c26:	and    r9d,edx
  469c29:	mov    eax,r13d
  469c2c:	and    eax,DWORD PTR [rdi+r9*4]
  469c30:	lea    r14d,[r11+0x1]
  469c34:	mov    r10,rax
  469c37:	and    r14d,edx
  469c3a:	shl    r10,0x4
  469c3e:	prefetchw BYTE PTR [r8+r10*1]
  469c43:	mov    DWORD PTR [rcx+0xcc],r14d
  469c4a:	mov    r14d,DWORD PTR [rdi+r11*4]
  469c4e:	shl    r11,0x4
  469c52:	vbroadcasti32x4 zmm1,XMMWORD PTR [rsi+r11*1]
  469c59:	lea    r9,[rsi+r11*1]
  469c5d:	mov    r11,QWORD PTR [rcx+0x90]
  469c64:	cmp    QWORD PTR [r9],r11
  469c67:	je     46a275 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xc35>
  469c6d:	mov    edi,r13d
  469c70:	and    edi,r14d
  469c73:	shl    rdi,0x4
  469c77:	add    rdi,r8
  469c7a:	vmovdqa64 zmm0,ZMMWORD PTR [rdi]
  469c80:	mov    edx,0x55
  469c85:	kmovb  k1,edx
  469c89:	vpcmpequq k0{k1},zmm0,zmm1
  469c90:	kortestb k0,k0
  469c94:	je     46a29b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xc5b>
  469c9a:	kshiftlb k3,k0,0x1
  469ca0:	vmovdqu64 ZMMWORD PTR [rdi]{k3},zmm1
  469ca6:	mov    r13,QWORD PTR [rcx+0x88]
  469cad:	mov    r9,QWORD PTR [rcx+0x60]
  469cb1:	mov    r8,QWORD PTR [rip+0x29f38]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469cb8:	mov    rsi,QWORD PTR [rcx+0xb0]
  469cbf:	mov    rdi,QWORD PTR [rcx+0xb8]
  469cc6:	lea    r10,[r13-0x1]
  469cca:	cmp    r9,0x4
  469cce:	jne    469b9a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x55a>
  469cd4:	mov    r13d,0xffffffff
  469cda:	crc32  r13d,DWORD PTR [r15]
  469ce0:	mov    ebx,r13d
  469ce3:	jmp    469bac <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x56c>
  469ce8:	nop    DWORD PTR [rax+rax*1+0x0]
  469cf0:	vpcmpequq k4{k2},zmm11,zmm4
  469cf7:	kortestb k4,k4
  469cfb:	je     469d80 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x740>
  469d01:	xor    esi,esi
  469d03:	mov    QWORD PTR [rbp-0x130],r8
  469d0a:	kmovb  r8d,k4
  469d0e:	tzcnt  esi,r8d
  469d13:	sar    esi,1
  469d15:	vmovdqa64 zmm0,zmm12
  469d1b:	mov    QWORD PTR [rbp-0xb0],r10
  469d22:	mov    QWORD PTR [rbp-0xa8],r11
  469d29:	mov    QWORD PTR [rbp-0xa0],rdx
  469d30:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm12
  469d3a:	call   4337f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_claimEPS1_jDv8_x>
  469d3f:	test   al,al
  469d41:	mov    r10d,0x55
  469d47:	kmovb  k2,r10d
  469d4c:	vmovdqa64 zmm12,ZMMWORD PTR [rbp-0xf0]
  469d56:	mov    r8,QWORD PTR [rbp-0x130]
  469d5d:	mov    rdx,QWORD PTR [rbp-0xa0]
  469d64:	mov    r11,QWORD PTR [rbp-0xa8]
  469d6b:	mov    r10,QWORD PTR [rbp-0xb0]
  469d72:	vpxor  xmm4,xmm4,xmm4
  469d76:	jne    4698b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x270>
  469d7c:	nop    DWORD PTR [rax+0x0]
  469d80:	mov    edi,0xffffffff
  469d85:	crc32  rdi,r14
  469d8b:	andn   eax,r12d,edi
  469d90:	shl    rax,0x4
  469d94:	prefetcht1 BYTE PTR [r13+rax*1+0x0]
  469d9a:	vmovdqu XMMWORD PTR [r10+r11*4],xmm12
  469da0:	mov    DWORD PTR [r15+r11*1],edi
  469da4:	add    r11,0x4
  469da8:	and    r11,rdx
  469dab:	jmp    4698b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x270>
  469db0:	vpcmpequq k1{k2},zmm8,zmm4
  469db7:	kortestb k1,k1
  469dbb:	je     469e60 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x820>
  469dc1:	xor    esi,esi
  469dc3:	kmovb  ecx,k1
  469dc7:	tzcnt  esi,ecx
  469dcb:	sar    esi,1
  469dcd:	mov    QWORD PTR [rbp-0x140],r10
  469dd4:	mov    QWORD PTR [rbp-0x138],r11
  469ddb:	mov    QWORD PTR [rbp-0xb0],rdx
  469de2:	mov    QWORD PTR [rbp-0xa8],r8
  469de9:	vmovdqa XMMWORD PTR [rbp-0xa0],xmm10
  469df1:	vmovdqa64 ZMMWORD PTR [rbp-0x130],zmm9
  469dfb:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm0
  469e05:	call   4337f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_claimEPS1_jDv8_x>
  469e0a:	test   al,al
  469e0c:	mov    r11d,0x55
  469e12:	kmovb  k2,r11d
  469e17:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0xf0]
  469e21:	vmovdqa64 zmm9,ZMMWORD PTR [rbp-0x130]
  469e2b:	vmovdqa xmm10,XMMWORD PTR [rbp-0xa0]
  469e33:	mov    r8,QWORD PTR [rbp-0xa8]
  469e3a:	mov    rdx,QWORD PTR [rbp-0xb0]
  469e41:	mov    r11,QWORD PTR [rbp-0x138]
  469e48:	mov    r10,QWORD PTR [rbp-0x140]
  469e4f:	vpxor  xmm4,xmm4,xmm4
  469e53:	jne    469874 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x234>
  469e59:	nop    DWORD PTR [rax+0x0]
  469e60:	mov    r9d,0xffffffff
  469e66:	crc32  r9,r14
  469e6c:	andn   esi,r12d,r9d
  469e71:	shl    rsi,0x4
  469e75:	prefetcht1 BYTE PTR [r13+rsi*1+0x0]
  469e7b:	vmovdqu XMMWORD PTR [r10+r11*4],xmm0
  469e81:	mov    DWORD PTR [r15+r11*1],r9d
  469e85:	add    r11,0x4
  469e89:	and    r11,rdx
  469e8c:	jmp    469874 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x234>
  469e91:	nop    DWORD PTR [rax+0x0]
  469e98:	vpcmpequq k5{k2},zmm7,zmm4
  469e9f:	kortestb k5,k5
  469ea3:	je     469f40 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x900>
  469ea9:	xor    esi,esi
  469eab:	mov    QWORD PTR [rbp-0x140],r10
  469eb2:	kmovb  r10d,k5
  469eb6:	tzcnt  esi,r10d
  469ebb:	sar    esi,1
  469ebd:	mov    QWORD PTR [rbp-0x138],r11
  469ec4:	mov    QWORD PTR [rbp-0xb0],rdx
  469ecb:	mov    QWORD PTR [rbp-0xa8],r8
  469ed2:	vmovdqa XMMWORD PTR [rbp-0xa0],xmm10
  469eda:	vmovdqa64 ZMMWORD PTR [rbp-0x130],zmm9
  469ee4:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm0
  469eee:	call   4337f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_claimEPS1_jDv8_x>
  469ef3:	test   al,al
  469ef5:	mov    edx,0x55
  469efa:	kmovb  k2,edx
  469efe:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0xf0]
  469f08:	vmovdqa64 zmm9,ZMMWORD PTR [rbp-0x130]
  469f12:	vmovdqa xmm10,XMMWORD PTR [rbp-0xa0]
  469f1a:	mov    r8,QWORD PTR [rbp-0xa8]
  469f21:	mov    rdx,QWORD PTR [rbp-0xb0]
  469f28:	mov    r11,QWORD PTR [rbp-0x138]
  469f2f:	mov    r10,QWORD PTR [rbp-0x140]
  469f36:	vpxor  xmm4,xmm4,xmm4
  469f3a:	jne    469838 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1f8>
  469f40:	mov    edi,0xffffffff
  469f45:	crc32  rdi,r14
  469f4b:	andn   eax,r12d,edi
  469f50:	shl    rax,0x4
  469f54:	prefetcht1 BYTE PTR [r13+rax*1+0x0]
  469f5a:	vmovdqu XMMWORD PTR [r10+r11*4],xmm0
  469f60:	mov    DWORD PTR [r15+r11*1],edi
  469f64:	add    r11,0x4
  469f68:	and    r11,rdx
  469f6b:	jmp    469838 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1f8>
  469f70:	vpcmpequq k0{k2},zmm5,zmm4
  469f77:	kortestb k0,k0
  469f7b:	je     46a020 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9e0>
  469f81:	xor    esi,esi
  469f83:	mov    QWORD PTR [rbp-0x138],r11
  469f8a:	kmovb  r11d,k0
  469f8e:	tzcnt  esi,r11d
  469f93:	sar    esi,1
  469f95:	mov    QWORD PTR [rbp-0x140],r10
  469f9c:	mov    QWORD PTR [rbp-0xb0],rdx
  469fa3:	mov    QWORD PTR [rbp-0xa8],r8
  469faa:	vmovdqa XMMWORD PTR [rbp-0xa0],xmm10
  469fb2:	vmovdqa64 ZMMWORD PTR [rbp-0x130],zmm9
  469fbc:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm0
  469fc6:	call   4337f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_claimEPS1_jDv8_x>
  469fcb:	test   al,al
  469fcd:	mov    r8d,0x55
  469fd3:	kmovb  k2,r8d
  469fd8:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0xf0]
  469fe2:	vmovdqa64 zmm9,ZMMWORD PTR [rbp-0x130]
  469fec:	vmovdqa xmm10,XMMWORD PTR [rbp-0xa0]
  469ff4:	mov    r8,QWORD PTR [rbp-0xa8]
  469ffb:	mov    rdx,QWORD PTR [rbp-0xb0]
  46a002:	mov    r11,QWORD PTR [rbp-0x138]
  46a009:	mov    r10,QWORD PTR [rbp-0x140]
  46a010:	vpxor  xmm4,xmm4,xmm4
  46a014:	jne    4697fc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1bc>
  46a01a:	nop    WORD PTR [rax+rax*1+0x0]
  46a020:	mov    r9d,0xffffffff
  46a026:	crc32  r9,r14
  46a02c:	andn   esi,r12d,r9d
  46a031:	shl    rsi,0x4
  46a035:	prefetcht1 BYTE PTR [r13+rsi*1+0x0]
  46a03b:	vmovdqu XMMWORD PTR [r10+r11*4],xmm0
  46a041:	mov    DWORD PTR [r15+r11*1],r9d
  46a045:	add    r11,0x4
  46a049:	and    r11,rdx
  46a04c:	jmp    4697fc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1bc>
  46a051:	nop    DWORD PTR [rax+0x0]
  46a058:	mov    r14,r8
  46a05b:	sub    r14,rbx
  46a05e:	mov    rcx,r14
  46a061:	mov    r9d,0x1
  46a067:	shr    rcx,1
  46a06a:	shlx   ecx,r9d,ecx
  46a06f:	lea    r9d,[rcx-0x1]
  46a073:	neg    ecx
  46a075:	kmovb  k4,r9d
  46a07a:	lea    r9,[r14*4+0x0]
  46a082:	vmovdqu64 zmm9{k4}{z},ZMMWORD PTR [rdi]
  46a088:	shr    r14,0x2
  46a08c:	kmovb  k4,ecx
  46a090:	mov    rdi,r10
  46a093:	mov    ecx,0x1
  46a098:	sub    rdi,r9
  46a09b:	shlx   r14d,ecx,r14d
  46a0a0:	lea    r9d,[r14-0x1]
  46a0a4:	kmovb  k6,r9d
  46a0a9:	vmovdqu32 xmm10{k6}{z},XMMWORD PTR [rax]
  46a0af:	mov    rax,rbx
  46a0b2:	sub    rax,r8
  46a0b5:	neg    r14d
  46a0b8:	kmovb  k7,r14d
  46a0bd:	vmovdqu64 zmm9{k4},ZMMWORD PTR [rdi]
  46a0c3:	vmovdqu32 xmm10{k7},XMMWORD PTR [r15+rax*1]
  46a0ca:	jmp    46975f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x11f>
  46a0cf:	mov    r9,QWORD PTR [rdi+0x8]
  46a0d3:	mov    BYTE PTR [rip+0x29a26],0x1        # 493b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  46a0da:	mov    QWORD PTR [rip+0x29a27],r9        # 493b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46a0e1:	jmp    469b1b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4db>
  46a0e6:	mov    rbx,QWORD PTR [rbp-0x78]
  46a0ea:	vmovd  xmm6,ecx
  46a0ee:	sub    rbx,r11
  46a0f1:	mov    r9,rbx
  46a0f4:	mov    QWORD PTR [rbp-0x80],rbx
  46a0f8:	shr    r9,1
  46a0fb:	mov    ebx,0x1
  46a100:	shlx   ebx,ebx,r9d
  46a105:	mov    r9d,ebx
  46a108:	dec    r9d
  46a10b:	kmovd  k0,ebx
  46a10f:	kmovb  k3,r9d
  46a114:	kmovq  rbx,k6
  46a119:	vmovdqu64 ZMMWORD PTR [rbx]{k3},zmm13
  46a11f:	mov    r9,QWORD PTR [rbp-0x80]
  46a123:	mov    rbx,r10
  46a126:	lea    r9,[r9*4+0x0]
  46a12e:	sub    rbx,r9
  46a131:	mov    r9,rbx
  46a134:	kmovb  ebx,k0
  46a138:	neg    ebx
  46a13a:	kmovb  k4,ebx
  46a13e:	vmovdqu64 ZMMWORD PTR [r9]{k4},zmm13
  46a144:	mov    rcx,QWORD PTR [rbp-0x80]
  46a148:	vmovd  xmm14,eax
  46a14c:	vpinsrd xmm15,xmm14,r8d,0x1
  46a152:	vpinsrd xmm2,xmm6,edi,0x1
  46a158:	shr    rcx,0x2
  46a15c:	mov    edi,0x1
  46a161:	vpunpcklqdq xmm0,xmm2,xmm15
  46a166:	shlx   eax,edi,ecx
  46a16b:	lea    r8d,[rax-0x1]
  46a16f:	kmovq  r9,k7
  46a174:	kmovb  k5,r8d
  46a179:	vmovdqu32 XMMWORD PTR [r9]{k5},xmm0
  46a17f:	sub    r11,QWORD PTR [rbp-0x78]
  46a183:	neg    eax
  46a185:	kmovb  k6,eax
  46a189:	vmovdqu32 XMMWORD PTR [r15+r11*1]{k6},xmm0
  46a190:	jmp    46997b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x33b>
  46a195:	vpxor  xmm10,xmm10,xmm10
  46a19a:	vpcmpequq k1{k2},zmm9,zmm10
  46a1a1:	kortestb k1,k1
  46a1a5:	jne    46a21a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbda>
  46a1a7:	mov    r10,rbx
  46a1aa:	crc32  r10,r9
  46a1b0:	mov    r11d,ecx
  46a1b3:	and    r11d,r10d
  46a1b6:	shl    r11,0x4
  46a1ba:	prefetcht1 BYTE PTR [r8+r11*1]
  46a1bf:	mov    r8d,DWORD PTR [r12+0xc8]
  46a1c7:	shl    r8,0x4
  46a1cb:	vmovdqa XMMWORD PTR [rdx+r8*1],xmm11
  46a1d1:	mov    edi,DWORD PTR [r12+0xc8]
  46a1d9:	mov    rsi,QWORD PTR [r12+0xb8]
  46a1e1:	mov    r8,QWORD PTR [rip+0x29a08]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46a1e8:	mov    DWORD PTR [rsi+rdi*4],r10d
  46a1ec:	mov    rdx,QWORD PTR [r12+0xb0]
  46a1f4:	mov    eax,DWORD PTR [r12+0xc8]
  46a1fc:	mov    edi,DWORD PTR [r12+0x74]
  46a201:	inc    eax
  46a203:	and    eax,edi
  46a205:	mov    DWORD PTR [r12+0xc8],eax
  46a20d:	mov    eax,DWORD PTR [r12+0xcc]
  46a215:	jmp    469a82 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x442>
  46a21a:	xor    esi,esi
  46a21c:	kmovb  edx,k1
  46a220:	tzcnt  esi,edx
  46a224:	sar    esi,1
  46a226:	vmovdqa64 zmm0,zmm11
  46a22c:	mov    DWORD PTR [rbp-0xf0],r9d
  46a233:	mov    DWORD PTR [rbp-0x78],ecx
  46a236:	vmovdqa32 ZMMWORD PTR [rbp-0x70],zmm11
  46a240:	call   4337f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_claimEPS1_jDv8_x>
  46a245:	mov    r8,QWORD PTR [rip+0x299a4]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46a24c:	mov    rdx,QWORD PTR [r12+0xb0]
  46a254:	test   al,al
  46a256:	jne    46a35c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xd1c>
  46a25c:	mov    r9d,DWORD PTR [rbp-0xf0]
  46a263:	mov    ecx,DWORD PTR [rbp-0x78]
  46a266:	vmovdqa32 zmm11,ZMMWORD PTR [rbp-0x70]
  46a270:	jmp    46a1a7 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb67>
  46a275:	mov    r14,QWORD PTR [r9+0x8]
  46a279:	mov    rdx,QWORD PTR [rcx+0x88]
  46a280:	mov    QWORD PTR [rip+0x29881],r14        # 493b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46a287:	mov    BYTE PTR [rip+0x29872],0x1        # 493b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
  46a28e:	mov    r9,QWORD PTR [rcx+0x60]
  46a292:	lea    r10,[rdx-0x1]
  46a296:	jmp    469b90 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x550>
  46a29b:	vpxor  xmm3,xmm3,xmm3
  46a29f:	vpcmpequq k2{k1},zmm0,zmm3
  46a2a6:	kortestb k2,k2
  46a2aa:	je     46a2f5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xcb5>
  46a2ac:	xor    esi,esi
  46a2ae:	mov    QWORD PTR [rbp-0x78],rcx
  46a2b2:	kmovb  ecx,k2
  46a2b6:	tzcnt  esi,ecx
  46a2ba:	sar    esi,1
  46a2bc:	vmovdqa64 zmm0,zmm1
  46a2c2:	vmovdqa32 ZMMWORD PTR [rbp-0x70],zmm1
  46a2cc:	call   4337f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_claimEPS1_jDv8_x>
  46a2d1:	test   al,al
  46a2d3:	vmovdqa32 zmm1,ZMMWORD PTR [rbp-0x70]
  46a2dd:	mov    rcx,QWORD PTR [rbp-0x78]
  46a2e1:	jne    469ca6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x666>
  46a2e7:	mov    r8,QWORD PTR [rip+0x29902]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46a2ee:	mov    rsi,QWORD PTR [rcx+0xb0]
  46a2f5:	mov    r10,r12
  46a2f8:	crc32  r10,r14
  46a2fe:	mov    edi,r13d
  46a301:	and    edi,r10d
  46a304:	shl    rdi,0x4
  46a308:	prefetcht1 BYTE PTR [r8+rdi*1]
  46a30d:	mov    r8d,DWORD PTR [rcx+0xc8]
  46a314:	shl    r8,0x4
  46a318:	vmovdqa XMMWORD PTR [rsi+r8*1],xmm1
  46a31e:	mov    esi,DWORD PTR [rcx+0xc8]
  46a324:	mov    rdi,QWORD PTR [rcx+0xb8]
  46a32b:	mov    r8,QWORD PTR [rip+0x298be]        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46a332:	mov    DWORD PTR [rdi+rsi*4],r10d
  46a336:	mov    rsi,QWORD PTR [rcx+0xb0]
  46a33d:	mov    eax,DWORD PTR [rcx+0xc8]
  46a343:	mov    edx,DWORD PTR [rcx+0x74]
  46a346:	inc    eax
  46a348:	and    eax,edx
  46a34a:	mov    DWORD PTR [rcx+0xc8],eax
  46a350:	mov    r11d,DWORD PTR [rcx+0xcc]
  46a357:	jmp    469c22 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5e2>
  46a35c:	mov    rsi,QWORD PTR [r12+0xb8]
  46a364:	jmp    469b1b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4db>
