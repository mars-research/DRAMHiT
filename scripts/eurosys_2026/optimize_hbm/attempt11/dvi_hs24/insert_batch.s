00000000004695e0:
  4695e0:	lea    r10,[rsp+0x8]
  4695e5:	and    rsp,0xffffffffffffffc0
  4695e9:	push   QWORD PTR [r10-0x8]
  4695ed:	mov    rcx,rdi
  4695f0:	push   rbp
  4695f1:	mov    rbp,rsp
  4695f4:	push   r15
  4695f6:	push   r14
  4695f8:	push   r13
  4695fa:	push   r12
  4695fc:	push   r10
  4695fe:	push   rbx
  4695ff:	sub    rsp,0x100
  469606:	mov    r15,QWORD PTR [rsi]
  469609:	mov    rax,QWORD PTR [rsi+0x8]
  46960d:	mov    esi,DWORD PTR [rdi+0xc8]
  469613:	mov    edi,DWORD PTR [rdi+0xcc]
  469619:	mov    r8d,DWORD PTR [rcx+0x70]
  46961d:	mov    rdx,rax
  469620:	mov    r11d,esi
  469623:	shl    rdx,0x4
  469627:	sub    r11d,edi
  46962a:	add    rdx,r15
  46962d:	and    r11d,DWORD PTR [rcx+0x74]
  469631:	lea    r9d,[r8-0x1]
  469635:	mov    QWORD PTR [rbp-0x80],rdx
  469639:	cmp    r11d,r9d
  46963c:	jb     46994b
  469642:	and    rax,0xfffffffffffffffc
  469646:	lea    rdx,[r8*4+0x0]
  46964e:	mov    r12d,DWORD PTR [rcx+0x80]
  469655:	shl    rax,0x4
  469659:	lea    r8,[rdi*4+0x0]
  469661:	add    rax,r15
  469664:	lea    rdi,[rdx-0x14]
  469668:	mov    QWORD PTR [rbp-0x88],rdi
  46966f:	mov    QWORD PTR [rbp-0x90],rax
  469676:	mov    r10,QWORD PTR [rcx+0xb0]
  46967d:	mov    r14,QWORD PTR [rcx+0xb8]
  469684:	mov    r13,QWORD PTR [rip+0x2a565]        # 493bf0
  46968b:	lea    rbx,[rdx-0x1]
  46968f:	lea    r11,[rsi*4+0x0]
  469697:	not    r12d
  46969a:	cmp    r15,rax
  46969d:	je     46a1d6
  4696a3:	mov    QWORD PTR [rbp-0x108],rcx
  4696aa:	mov    eax,0x55
  4696af:	mov    r9,r15
  4696b2:	kmovb  k2,eax
  4696b6:	cs nop WORD PTR [rax+rax*1+0x0]
  4696c0:	mov    rcx,r13
  4696c3:	mov    QWORD PTR [rbp-0x78],r9
  4696c7:	mov    r13,rdx
  4696ca:	vpxor  xmm11,xmm11,xmm11
  4696cf:	mov    rdx,QWORD PTR [rbp-0x88]
  4696d6:	mov    r15,r8
  4696d9:	jmp    4696e3
  4696db:	nop    DWORD PTR [rax+rax*1+0x0]
  4696e0:	mov    r15,r8
  4696e3:	lea    r8,[r15+0x10]
  4696e7:	lea    rax,[r10+r15*4]
  4696eb:	cmp    r13,r8
  4696ee:	jb     469af0
  4696f4:	vmovdqu64 zmm8,ZMMWORD PTR [rax]
  4696fa:	lea    rdi,[r15+0x60]
  4696fe:	lea    r9,[r15+0x64]
  469702:	mov    rsi,rbx
  469705:	and    rdi,rbx
  469708:	and    r9,rbx
  46970b:	andn   eax,r12d,DWORD PTR [r14+rdi*1]
  469711:	shl    rax,0x4
  469715:	and    rsi,r15
  469718:	prefetchw BYTE PTR [rcx+rax*1]
  46971c:	lea    rdi,[r15+0x6c]
  469720:	andn   eax,r12d,DWORD PTR [r14+r9*1]
  469726:	shl    rax,0x4
  46972a:	lea    r9,[r15+0x68]
  46972e:	and    r9,rbx
  469731:	and    rdi,rbx
  469734:	prefetchw BYTE PTR [rcx+rax*1]
  469738:	andn   eax,r12d,DWORD PTR [r14+r9*1]
  46973e:	shl    rax,0x4
  469742:	mov    r9d,DWORD PTR [r14+rsi*1]
  469746:	prefetchw BYTE PTR [rcx+rax*1]
  46974a:	andn   eax,r12d,DWORD PTR [r14+rdi*1]
  469750:	shl    rax,0x4
  469754:	andn   edi,r12d,r9d
  469759:	shl    rdi,0x4
  46975d:	add    rdi,rcx
  469760:	vmovdqa64 zmm5,ZMMWORD PTR [rdi]
  469766:	vshufi64x2 zmm0,zmm8,zmm8,0x0
  46976d:	vpcmpequq k4{k2},zmm5,zmm0
  469774:	and    r8,rbx
  469777:	prefetchw BYTE PTR [rcx+rax*1]
  46977b:	kortestb k4,k4
  46977f:	je     469df0
  469785:	kshiftlb k1,k4,0x1
  46978b:	vmovdqu64 ZMMWORD PTR [rdi]{k1},zmm0
  469791:	lea    rsi,[r15+0x4]
  469795:	and    rsi,rbx
  469798:	mov    r9d,DWORD PTR [r14+rsi*1]
  46979c:	andn   edi,r12d,r9d
  4697a1:	shl    rdi,0x4
  4697a5:	add    rdi,rcx
  4697a8:	vmovdqa64 zmm6,ZMMWORD PTR [rdi]
  4697ae:	vshufi64x2 zmm0,zmm8,zmm8,0x55
  4697b5:	vpcmpequq k0{k2},zmm6,zmm0
  4697bc:	kortestb k0,k0
  4697c0:	je     469d00
  4697c6:	kshiftlb k5,k0,0x1
  4697cc:	vmovdqu64 ZMMWORD PTR [rdi]{k5},zmm0
  4697d2:	lea    rsi,[r15+0x8]
  4697d6:	and    rsi,rbx
  4697d9:	mov    r9d,DWORD PTR [r14+rsi*1]
  4697dd:	andn   edi,r12d,r9d
  4697e2:	shl    rdi,0x4
  4697e6:	add    rdi,rcx
  4697e9:	vmovdqa64 zmm7,ZMMWORD PTR [rdi]
  4697ef:	vshufi64x2 zmm0,zmm8,zmm8,0xaa
  4697f6:	vpcmpequq k6{k2},zmm7,zmm0
  4697fd:	kortestb k6,k6
  469801:	je     469c10
  469807:	kshiftlb k7,k6,0x1
  46980d:	vmovdqu64 ZMMWORD PTR [rdi]{k7},zmm0
  469813:	add    r15,0xc
  469817:	and    r15,rbx
  46981a:	mov    r15d,DWORD PTR [r14+r15*1]
  46981e:	andn   edi,r12d,r15d
  469823:	shl    rdi,0x4
  469827:	add    rdi,rcx
  46982a:	vmovdqa64 zmm9,ZMMWORD PTR [rdi]
  469830:	vshufi64x2 zmm10,zmm8,zmm8,0xff
  469837:	vpcmpequq k1{k2},zmm9,zmm10
  46983e:	kortestb k1,k1
  469842:	je     469b38
  469848:	kshiftlb k3,k1,0x1
  46984e:	vmovdqu64 ZMMWORD PTR [rdi]{k3},zmm10
  469854:	mov    rdi,r11
  469857:	sub    rdi,r8
  46985a:	and    rdi,rbx
  46985d:	cmp    rdx,rdi
  469860:	jb     4696e0
  469866:	mov    r9,QWORD PTR [rbp-0x78]
  46986a:	mov    rdx,r13
  46986d:	mov    r13,rcx
  469870:	mov    ecx,0xffffffff
  469875:	crc32  rcx,QWORD PTR [r9]
  46987b:	mov    edi,0xffffffff
  469880:	andn   eax,r12d,ecx
  469885:	shl    rax,0x4
  469889:	prefetcht1 BYTE PTR [r13+rax*1+0x0]
  46988f:	mov    eax,0xffffffff
  469894:	crc32  rax,QWORD PTR [r9+0x20]
  46989b:	mov    QWORD PTR [rbp-0x70],r8
  46989f:	crc32  rdi,QWORD PTR [r9+0x10]
  4698a6:	andn   r8d,r12d,eax
  4698ab:	shl    r8,0x4
  4698af:	andn   r15d,r12d,edi
  4698b4:	shl    r15,0x4
  4698b8:	prefetcht1 BYTE PTR [r13+r8*1+0x0]
  4698be:	prefetcht1 BYTE PTR [r13+r15*1+0x0]
  4698c4:	mov    r8d,0xffffffff
  4698ca:	lea    r15,[r10+r11*4]
  4698ce:	crc32  r8,QWORD PTR [r9+0x30]
  4698d5:	kmovq  k5,r15
  4698da:	andn   esi,r12d,r8d
  4698df:	shl    rsi,0x4
  4698e3:	lea    r15,[r14+r11*1]
  4698e7:	prefetcht1 BYTE PTR [r13+rsi*1+0x0]
  4698ed:	lea    rsi,[r11+0x10]
  4698f1:	mov    QWORD PTR [rbp-0x78],rax
  4698f5:	vmovdqu64 zmm12,ZMMWORD PTR [r9]
  4698fb:	kmovq  k6,r15
  469900:	cmp    rdx,rsi
  469903:	jb     46a123
  469909:	kmovq  r15,k5
  46990e:	vmovdqu64 ZMMWORD PTR [r15],zmm12
  469914:	kmovq  r15,k6
  469919:	mov    DWORD PTR [r15],ecx
  46991c:	mov    DWORD PTR [r14+r11*1+0x4],edi
  469921:	mov    DWORD PTR [r14+r11*1+0x8],eax
  469926:	mov    DWORD PTR [r14+r11*1+0xc],r8d
  46992b:	and    rsi,rbx
  46992e:	add    r9,0x40
  469932:	mov    r11,rsi
  469935:	cmp    QWORD PTR [rbp-0x90],r9
  46993c:	je     469ede
  469942:	mov    r8,QWORD PTR [rbp-0x70]
  469946:	jmp    4696c0
  46994b:	cmp    r15,QWORD PTR [rbp-0x80]
  46994f:	je     469ad8
  469955:	mov    r12,QWORD PTR [rcx+0x88]
  46995c:	mov    r9,QWORD PTR [rcx+0x60]
  469960:	mov    r8,QWORD PTR [rip+0x2a289]        # 493bf0
  469967:	mov    rsi,QWORD PTR [rcx+0xb0]
  46996e:	mov    rdi,QWORD PTR [rcx+0xb8]
  469975:	lea    r10,[r12-0x1]
  46997a:	mov    r12d,0xffffffff
  469980:	cmp    r9,0x4
  469984:	je     469ac1
  46998a:	cmp    r9,0x8
  46998e:	jne    469999
  469990:	mov    rbx,r12
  469993:	crc32  rbx,QWORD PTR [r15]
  469999:	mov    r13d,ebx
  46999c:	mov    eax,DWORD PTR [rcx+0xc8]
  4699a2:	mov    r14,r10
  4699a5:	and    r14,rbx
  4699a8:	vmovdqu xmm4,XMMWORD PTR [r15]
  4699ad:	mov    rdx,rax
  4699b0:	and    r14,0xfffffffffffffffc
  4699b4:	shl    rdx,0x4
  4699b8:	shl    r14,0x4
  4699bc:	prefetcht1 BYTE PTR [r8+r14*1]
  4699c1:	vmovdqu XMMWORD PTR [rsi+rdx*1],xmm4
  4699c6:	mov    DWORD PTR [rdi+rax*4],r13d
  4699ca:	add    r15,0x10
  4699ce:	mov    eax,DWORD PTR [rcx+0xc8]
  4699d4:	mov    edx,DWORD PTR [rcx+0x74]
  4699d7:	inc    eax
  4699d9:	and    eax,edx
  4699db:	mov    DWORD PTR [rcx+0xc8],eax
  4699e1:	cmp    r15,QWORD PTR [rbp-0x80]
  4699e5:	je     469ad5
  4699eb:	mov    r11d,DWORD PTR [rcx+0xcc]
  4699f2:	mov    r13d,DWORD PTR [rcx+0x70]
  4699f6:	sub    eax,r11d
  4699f9:	and    eax,edx
  4699fb:	lea    r14d,[r13-0x1]
  4699ff:	cmp    eax,r14d
  469a02:	jb     469980
  469a08:	mov    r13d,DWORD PTR [rcx+0x80]
  469a0f:	lea    r9d,[r11+0x18]
  469a13:	and    r9d,edx
  469a16:	mov    eax,r13d
  469a19:	and    eax,DWORD PTR [rdi+r9*4]
  469a1d:	lea    r14d,[r11+0x1]
  469a21:	mov    r10,rax
  469a24:	and    r14d,edx
  469a27:	shl    r10,0x4
  469a2b:	prefetchw BYTE PTR [r8+r10*1]
  469a30:	mov    DWORD PTR [rcx+0xcc],r14d
  469a37:	mov    r14d,DWORD PTR [rdi+r11*4]
  469a3b:	shl    r11,0x4
  469a3f:	vbroadcasti32x4 zmm1,XMMWORD PTR [rsi+r11*1]
  469a46:	lea    r9,[rsi+r11*1]
  469a4a:	mov    r11,QWORD PTR [rcx+0x90]
  469a51:	cmp    QWORD PTR [r9],r11
  469a54:	je     46a233
  469a5a:	mov    edi,r13d
  469a5d:	and    edi,r14d
  469a60:	shl    rdi,0x4
  469a64:	add    rdi,r8
  469a67:	vmovdqa64 zmm0,ZMMWORD PTR [rdi]
  469a6d:	mov    edx,0x55
  469a72:	kmovb  k1,edx
  469a76:	vpcmpequq k0{k1},zmm0,zmm1
  469a7d:	kortestb k0,k0
  469a81:	je     46a259
  469a87:	kshiftlb k3,k0,0x1
  469a8d:	vmovdqu64 ZMMWORD PTR [rdi]{k3},zmm1
  469a93:	mov    r13,QWORD PTR [rcx+0x88]
  469a9a:	mov    r9,QWORD PTR [rcx+0x60]
  469a9e:	mov    r8,QWORD PTR [rip+0x2a14b]        # 493bf0
  469aa5:	mov    rsi,QWORD PTR [rcx+0xb0]
  469aac:	mov    rdi,QWORD PTR [rcx+0xb8]
  469ab3:	lea    r10,[r13-0x1]
  469ab7:	cmp    r9,0x4
  469abb:	jne    46998a
  469ac1:	mov    r13d,0xffffffff
  469ac7:	crc32  r13d,DWORD PTR [r15]
  469acd:	mov    ebx,r13d
  469ad0:	jmp    46999c
  469ad5:	vzeroupper
  469ad8:	add    rsp,0x100
  469adf:	pop    rbx
  469ae0:	pop    rsi
  469ae1:	pop    r12
  469ae3:	pop    r13
  469ae5:	pop    r14
  469ae7:	pop    r15
  469ae9:	pop    rbp
  469aea:	lea    rsp,[rsi-0x8]
  469aee:	ret
  469aef:	nop
  469af0:	mov    rdi,r13
  469af3:	sub    rdi,r15
  469af6:	mov    rsi,rdi
  469af9:	mov    r9d,0x1
  469aff:	shr    rsi,1
  469b02:	shlx   esi,r9d,esi
  469b07:	lea    r9d,[rsi-0x1]
  469b0b:	shl    rdi,0x2
  469b0f:	kmovb  k5,r9d
  469b14:	vmovdqu64 zmm8{k5}{z},ZMMWORD PTR [rax]
  469b1a:	mov    rax,r10
  469b1d:	sub    rax,rdi
  469b20:	neg    esi
  469b22:	kmovb  k6,esi
  469b26:	vmovdqu64 zmm8{k6},ZMMWORD PTR [rax]
  469b2c:	jmp    4696fa
  469b31:	nop    DWORD PTR [rax+0x0]
  469b38:	vpcmpequq k0{k2},zmm9,zmm11
  469b3f:	kortestb k0,k0
  469b43:	je     469bd8
  469b49:	xor    esi,esi
  469b4b:	mov    QWORD PTR [rbp-0xa0],r11
  469b52:	kmovb  r11d,k0
  469b56:	tzcnt  esi,r11d
  469b5b:	sar    esi,1
  469b5d:	vmovdqa64 zmm0,zmm10
  469b63:	mov    QWORD PTR [rbp-0xb0],r8
  469b6a:	mov    QWORD PTR [rbp-0xa8],r10
  469b71:	mov    QWORD PTR [rbp-0x98],rdx
  469b78:	mov    QWORD PTR [rbp-0xf0],rcx
  469b7f:	vmovdqa64 ZMMWORD PTR [rbp-0x70],zmm10
  469b89:	call   433800
  469b8e:	test   al,al
  469b90:	mov    r8d,0x55
  469b96:	kmovb  k2,r8d
  469b9b:	vmovdqa64 zmm10,ZMMWORD PTR [rbp-0x70]
  469ba5:	mov    rcx,QWORD PTR [rbp-0xf0]
  469bac:	mov    rdx,QWORD PTR [rbp-0x98]
  469bb3:	mov    r11,QWORD PTR [rbp-0xa0]
  469bba:	mov    r10,QWORD PTR [rbp-0xa8]
  469bc1:	mov    r8,QWORD PTR [rbp-0xb0]
  469bc8:	vpxor  xmm11,xmm11,xmm11
  469bcd:	jne    469854
  469bd3:	nop    DWORD PTR [rax+rax*1+0x0]
  469bd8:	mov    r9d,0xffffffff
  469bde:	crc32  r9,r15
  469be4:	andn   esi,r12d,r9d
  469be9:	shl    rsi,0x4
  469bed:	prefetcht1 BYTE PTR [rcx+rsi*1]
  469bf1:	vmovdqu XMMWORD PTR [r10+r11*4],xmm10
  469bf7:	mov    DWORD PTR [r14+r11*1],r9d
  469bfb:	add    r11,0x4
  469bff:	and    r11,rbx
  469c02:	jmp    469854
  469c07:	nop    WORD PTR [rax+rax*1+0x0]
  469c10:	vpcmpequq k4{k2},zmm7,zmm11
  469c17:	kortestb k4,k4
  469c1b:	je     469cc8
  469c21:	xor    esi,esi
  469c23:	mov    QWORD PTR [rbp-0xa8],rdx
  469c2a:	kmovb  edx,k4
  469c2e:	tzcnt  esi,edx
  469c32:	sar    esi,1
  469c34:	mov    QWORD PTR [rbp-0x100],r8
  469c3b:	mov    QWORD PTR [rbp-0xf8],r10
  469c42:	mov    QWORD PTR [rbp-0xb0],r11
  469c49:	mov    QWORD PTR [rbp-0xa0],rcx
  469c50:	mov    DWORD PTR [rbp-0x98],r9d
  469c57:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm8
  469c61:	vmovdqa64 ZMMWORD PTR [rbp-0x70],zmm0
  469c6b:	call   433800
  469c70:	test   al,al
  469c72:	mov    ecx,0x55
  469c77:	kmovb  k2,ecx
  469c7b:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0x70]
  469c85:	vmovdqa64 zmm8,ZMMWORD PTR [rbp-0xf0]
  469c8f:	mov    r9d,DWORD PTR [rbp-0x98]
  469c96:	mov    rcx,QWORD PTR [rbp-0xa0]
  469c9d:	mov    rdx,QWORD PTR [rbp-0xa8]
  469ca4:	mov    r11,QWORD PTR [rbp-0xb0]
  469cab:	mov    r10,QWORD PTR [rbp-0xf8]
  469cb2:	mov    r8,QWORD PTR [rbp-0x100]
  469cb9:	vpxor  xmm11,xmm11,xmm11
  469cbe:	jne    469813
  469cc4:	nop    DWORD PTR [rax+0x0]
  469cc8:	mov    edi,0xffffffff
  469ccd:	crc32  rdi,r9
  469cd3:	andn   eax,r12d,edi
  469cd8:	shl    rax,0x4
  469cdc:	prefetcht1 BYTE PTR [rcx+rax*1]
  469ce0:	vmovdqu XMMWORD PTR [r10+r11*4],xmm0
  469ce6:	mov    DWORD PTR [r14+r11*1],edi
  469cea:	add    r11,0x4
  469cee:	and    r11,rbx
  469cf1:	jmp    469813
  469cf6:	cs nop WORD PTR [rax+rax*1+0x0]
  469d00:	vpcmpequq k3{k2},zmm6,zmm11
  469d07:	kortestb k3,k3
  469d0b:	je     469dc0
  469d11:	xor    esi,esi
  469d13:	mov    QWORD PTR [rbp-0x100],r8
  469d1a:	kmovb  r8d,k3
  469d1e:	tzcnt  esi,r8d
  469d23:	sar    esi,1
  469d25:	mov    QWORD PTR [rbp-0xf8],r10
  469d2c:	mov    QWORD PTR [rbp-0xb0],r11
  469d33:	mov    QWORD PTR [rbp-0xa8],rdx
  469d3a:	mov    QWORD PTR [rbp-0xa0],rcx
  469d41:	mov    DWORD PTR [rbp-0x98],r9d
  469d48:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm8
  469d52:	vmovdqa64 ZMMWORD PTR [rbp-0x70],zmm0
  469d5c:	call   433800
  469d61:	test   al,al
  469d63:	mov    r10d,0x55
  469d69:	kmovb  k2,r10d
  469d6e:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0x70]
  469d78:	vmovdqa64 zmm8,ZMMWORD PTR [rbp-0xf0]
  469d82:	mov    r9d,DWORD PTR [rbp-0x98]
  469d89:	mov    rcx,QWORD PTR [rbp-0xa0]
  469d90:	mov    rdx,QWORD PTR [rbp-0xa8]
  469d97:	mov    r11,QWORD PTR [rbp-0xb0]
  469d9e:	mov    r10,QWORD PTR [rbp-0xf8]
  469da5:	mov    r8,QWORD PTR [rbp-0x100]
  469dac:	vpxor  xmm11,xmm11,xmm11
  469db1:	jne    4697d2
  469db7:	nop    WORD PTR [rax+rax*1+0x0]
  469dc0:	mov    edi,0xffffffff
  469dc5:	crc32  rdi,r9
  469dcb:	andn   eax,r12d,edi
  469dd0:	shl    rax,0x4
  469dd4:	prefetcht1 BYTE PTR [rcx+rax*1]
  469dd8:	vmovdqu XMMWORD PTR [r10+r11*4],xmm0
  469dde:	mov    DWORD PTR [r14+r11*1],edi
  469de2:	add    r11,0x4
  469de6:	and    r11,rbx
  469de9:	jmp    4697d2
  469dee:	xchg   ax,ax
  469df0:	vpcmpequq k7{k2},zmm5,zmm11
  469df7:	kortestb k7,k7
  469dfb:	je     469eb0
  469e01:	xor    esi,esi
  469e03:	mov    QWORD PTR [rbp-0xa0],rcx
  469e0a:	kmovb  ecx,k7
  469e0e:	tzcnt  esi,ecx
  469e12:	sar    esi,1
  469e14:	mov    QWORD PTR [rbp-0x100],r8
  469e1b:	mov    QWORD PTR [rbp-0xf8],r10
  469e22:	mov    QWORD PTR [rbp-0xb0],r11
  469e29:	mov    QWORD PTR [rbp-0xa8],rdx
  469e30:	mov    DWORD PTR [rbp-0x98],r9d
  469e37:	vmovdqa64 ZMMWORD PTR [rbp-0xf0],zmm8
  469e41:	vmovdqa64 ZMMWORD PTR [rbp-0x70],zmm0
  469e4b:	call   433800
  469e50:	test   al,al
  469e52:	mov    r11d,0x55
  469e58:	kmovb  k2,r11d
  469e5d:	vmovdqa64 zmm0,ZMMWORD PTR [rbp-0x70]
  469e67:	vmovdqa64 zmm8,ZMMWORD PTR [rbp-0xf0]
  469e71:	mov    r9d,DWORD PTR [rbp-0x98]
  469e78:	mov    rcx,QWORD PTR [rbp-0xa0]
  469e7f:	mov    rdx,QWORD PTR [rbp-0xa8]
  469e86:	mov    r11,QWORD PTR [rbp-0xb0]
  469e8d:	mov    r10,QWORD PTR [rbp-0xf8]
  469e94:	mov    r8,QWORD PTR [rbp-0x100]
  469e9b:	vpxor  xmm11,xmm11,xmm11
  469ea0:	jne    469791
  469ea6:	cs nop WORD PTR [rax+rax*1+0x0]
  469eb0:	mov    edi,0xffffffff
  469eb5:	crc32  rdi,r9
  469ebb:	andn   eax,r12d,edi
  469ec0:	shl    rax,0x4
  469ec4:	prefetcht1 BYTE PTR [rcx+rax*1]
  469ec8:	vmovdqu XMMWORD PTR [r10+r11*4],xmm0
  469ece:	mov    DWORD PTR [r14+r11*1],edi
  469ed2:	add    r11,0x4
  469ed6:	and    r11,rbx
  469ed9:	jmp    469791
  469ede:	mov    rbx,QWORD PTR [rbp-0x70]
  469ee2:	mov    rcx,QWORD PTR [rbp-0x108]
  469ee9:	mov    r15,r9
  469eec:	vmovq  xmm0,r11
  469ef1:	vpinsrq xmm3,xmm0,rbx,0x1
  469ef7:	vpsrlq xmm1,xmm3,0x2
  469efc:	mov    r14,QWORD PTR [rbp-0x80]
  469f00:	vpmovqd xmm5,xmm1
  469f06:	vpextrd eax,xmm5,0x1
  469f0c:	vmovq  QWORD PTR [rcx+0xc8],xmm5
  469f14:	cmp    r15,r14
  469f17:	je     469ad5
  469f1d:	mov    r8,QWORD PTR [rip+0x29ccc]        # 493bf0
  469f24:	mov    rsi,QWORD PTR [rcx+0xb8]
  469f2b:	mov    edi,DWORD PTR [rcx+0x74]
  469f2e:	mov    rdx,QWORD PTR [rcx+0xb0]
  469f35:	mov    r13,QWORD PTR [rbp-0x110]
  469f3c:	mov    ebx,0xffffffff
  469f41:	mov    r12,rcx
  469f44:	jmp    469fca
  469f49:	nop    DWORD PTR [rax+0x0]
  469f50:	cmp    rcx,0x8
  469f54:	jne    469f5f
  469f56:	mov    r13,rbx
  469f59:	crc32  r13,QWORD PTR [r15]
  469f5f:	mov    r10d,r13d
  469f62:	mov    r11,QWORD PTR [r12+0x88]
  469f6a:	mov    eax,DWORD PTR [r12+0xc8]
  469f72:	dec    r11
  469f75:	and    r11,r13
  469f78:	vmovdqu xmm10,XMMWORD PTR [r15]
  469f7d:	and    r11,0xfffffffffffffffc
  469f81:	mov    rdi,rax
  469f84:	shl    rdi,0x4
  469f88:	shl    r11,0x4
  469f8c:	prefetcht1 BYTE PTR [r8+r11*1]
  469f91:	vmovdqu XMMWORD PTR [rdx+rdi*1],xmm10
  469f96:	mov    DWORD PTR [rsi+rax*4],r10d
  469f9a:	add    r15,0x10
  469f9e:	mov    r9d,DWORD PTR [r12+0xc8]
  469fa6:	mov    edi,DWORD PTR [r12+0x74]
  469fab:	inc    r9d
  469fae:	and    r9d,edi
  469fb1:	mov    DWORD PTR [r12+0xc8],r9d
  469fb9:	cmp    r15,r14
  469fbc:	je     469ad5
  469fc2:	mov    eax,DWORD PTR [r12+0xcc]
  469fca:	mov    ecx,DWORD PTR [r12+0x80]
  469fd2:	lea    r9d,[rax+0x18]
  469fd6:	and    r9d,edi
  469fd9:	mov    r10d,ecx
  469fdc:	and    r10d,DWORD PTR [rsi+r9*4]
  469fe0:	lea    r11d,[rax+0x1]
  469fe4:	and    edi,r11d
  469fe7:	shl    r10,0x4
  469feb:	prefetchw BYTE PTR [r8+r10*1]
  469ff0:	mov    DWORD PTR [r12+0xcc],edi
  469ff8:	mov    r9d,DWORD PTR [rsi+rax*4]
  469ffc:	shl    rax,0x4
  46a000:	vbroadcasti32x4 zmm9,XMMWORD PTR [rdx+rax*1]
  46a007:	lea    rdi,[rdx+rax*1]
  46a00b:	mov    rax,QWORD PTR [r12+0x90]
  46a013:	cmp    QWORD PTR [rdi],rax
  46a016:	je     46a086
  46a018:	mov    edi,ecx
  46a01a:	and    edi,r9d
  46a01d:	shl    rdi,0x4
  46a021:	add    rdi,r8
  46a024:	vmovdqa64 zmm7,ZMMWORD PTR [rdi]
  46a02a:	mov    esi,0x55
  46a02f:	kmovb  k2,esi
  46a033:	vpcmpequq k0{k2},zmm7,zmm9
  46a03a:	kortestb k0,k0
  46a03e:	je     46a09a
  46a040:	kshiftlb k7,k0,0x1
  46a046:	vmovdqu64 ZMMWORD PTR [rdi]{k7},zmm9
  46a04c:	mov    r8,QWORD PTR [rip+0x29b9d]        # 493bf0
  46a053:	mov    rdx,QWORD PTR [r12+0xb0]
  46a05b:	mov    rsi,QWORD PTR [r12+0xb8]
  46a063:	mov    rcx,QWORD PTR [r12+0x60]
  46a068:	cmp    rcx,0x4
  46a06c:	jne    469f50
  46a072:	mov    r10d,0xffffffff
  46a078:	crc32  r10d,DWORD PTR [r15]
  46a07e:	mov    r13d,r10d
  46a081:	jmp    469f62
  46a086:	mov    r9,QWORD PTR [rdi+0x8]
  46a08a:	mov    BYTE PTR [rip+0x29a6f],0x1        # 493b00
  46a091:	mov    QWORD PTR [rip+0x29a70],r9        # 493b08
  46a098:	jmp    46a063
  46a09a:	vpxor  xmm8,xmm8,xmm8
  46a09f:	vpcmpequq k4{k2},zmm7,zmm8
  46a0a6:	kortestb k4,k4
  46a0aa:	jne    46a1de
  46a0b0:	mov    r10,rbx
  46a0b3:	crc32  r10,r9
  46a0b9:	mov    r11d,ecx
  46a0bc:	and    r11d,r10d
  46a0bf:	shl    r11,0x4
  46a0c3:	prefetcht1 BYTE PTR [r8+r11*1]
  46a0c8:	mov    r8d,DWORD PTR [r12+0xc8]
  46a0d0:	shl    r8,0x4
  46a0d4:	vmovdqa XMMWORD PTR [rdx+r8*1],xmm9
  46a0da:	mov    edi,DWORD PTR [r12+0xc8]
  46a0e2:	mov    rsi,QWORD PTR [r12+0xb8]
  46a0ea:	mov    r8,QWORD PTR [rip+0x29aff]        # 493bf0
  46a0f1:	mov    DWORD PTR [rsi+rdi*4],r10d
  46a0f5:	mov    rdx,QWORD PTR [r12+0xb0]
  46a0fd:	mov    eax,DWORD PTR [r12+0xc8]
  46a105:	mov    edi,DWORD PTR [r12+0x74]
  46a10a:	inc    eax
  46a10c:	and    eax,edi
  46a10e:	mov    DWORD PTR [r12+0xc8],eax
  46a116:	mov    eax,DWORD PTR [r12+0xcc]
  46a11e:	jmp    469fd2
  46a123:	mov    rax,rdx
  46a126:	sub    rax,r11
  46a129:	mov    r15,rax
  46a12c:	mov    QWORD PTR [rbp-0xf0],rax
  46a133:	shr    r15,1
  46a136:	mov    eax,0x1
  46a13b:	shlx   eax,eax,r15d
  46a140:	mov    r15d,eax
  46a143:	dec    r15d
  46a146:	kmovd  k7,eax
  46a14a:	kmovb  k1,r15d
  46a14f:	kmovq  rax,k5
  46a154:	vmovdqu64 ZMMWORD PTR [rax]{k1},zmm12
  46a15a:	mov    r15,QWORD PTR [rbp-0xf0]
  46a161:	mov    rax,r10
  46a164:	shl    r15,0x2
  46a168:	sub    rax,r15
  46a16b:	kmovb  r15d,k7
  46a16f:	neg    r15d
  46a172:	vmovd  xmm15,ecx
  46a176:	kmovb  k3,r15d
  46a17b:	vmovdqu64 ZMMWORD PTR [rax]{k3},zmm12
  46a181:	vmovd  xmm13,DWORD PTR [rbp-0x78]
  46a186:	vpinsrd xmm4,xmm15,edi,0x1
  46a18c:	mov    rdi,QWORD PTR [rbp-0xf0]
  46a193:	vpinsrd xmm14,xmm13,r8d,0x1
  46a199:	shr    rdi,0x2
  46a19d:	mov    ecx,0x1
  46a1a2:	vpunpcklqdq xmm2,xmm4,xmm14
  46a1a7:	shlx   r8d,ecx,edi
  46a1ac:	lea    eax,[r8-0x1]
  46a1b0:	kmovq  r15,k6
  46a1b5:	sub    r11,rdx
  46a1b8:	neg    r8d
  46a1bb:	kmovb  k5,eax
  46a1bf:	vmovdqu32 XMMWORD PTR [r15]{k5},xmm2
  46a1c5:	kmovb  k6,r8d
  46a1ca:	vmovdqu32 XMMWORD PTR [r14+r11*1]{k6},xmm2
  46a1d1:	jmp    46992b
  46a1d6:	mov    rbx,r8
  46a1d9:	jmp    469eec
  46a1de:	xor    esi,esi
  46a1e0:	kmovb  edx,k4
  46a1e4:	tzcnt  esi,edx
  46a1e8:	sar    esi,1
  46a1ea:	vmovdqa64 zmm0,zmm9
  46a1f0:	mov    DWORD PTR [rbp-0x80],r9d
  46a1f4:	mov    DWORD PTR [rbp-0x78],ecx
  46a1f7:	vmovdqa32 ZMMWORD PTR [rbp-0x70],zmm9
  46a201:	call   433800
  46a206:	mov    r8,QWORD PTR [rip+0x299e3]        # 493bf0
  46a20d:	mov    rdx,QWORD PTR [r12+0xb0]
  46a215:	test   al,al
  46a217:	jne    46a31a
  46a21d:	mov    r9d,DWORD PTR [rbp-0x80]
  46a221:	mov    ecx,DWORD PTR [rbp-0x78]
  46a224:	vmovdqa32 zmm9,ZMMWORD PTR [rbp-0x70]
  46a22e:	jmp    46a0b0
  46a233:	mov    r14,QWORD PTR [r9+0x8]
  46a237:	mov    rdx,QWORD PTR [rcx+0x88]
  46a23e:	mov    QWORD PTR [rip+0x298c3],r14        # 493b08
  46a245:	mov    BYTE PTR [rip+0x298b4],0x1        # 493b00
  46a24c:	mov    r9,QWORD PTR [rcx+0x60]
  46a250:	lea    r10,[rdx-0x1]
  46a254:	jmp    469980
  46a259:	vpxor  xmm3,xmm3,xmm3
  46a25d:	vpcmpequq k2{k1},zmm0,zmm3
  46a264:	kortestb k2,k2
  46a268:	je     46a2b3
  46a26a:	xor    esi,esi
  46a26c:	mov    QWORD PTR [rbp-0x78],rcx
  46a270:	kmovb  ecx,k2
  46a274:	tzcnt  esi,ecx
  46a278:	sar    esi,1
  46a27a:	vmovdqa64 zmm0,zmm1
  46a280:	vmovdqa32 ZMMWORD PTR [rbp-0x70],zmm1
  46a28a:	call   433800
  46a28f:	test   al,al
  46a291:	vmovdqa32 zmm1,ZMMWORD PTR [rbp-0x70]
  46a29b:	mov    rcx,QWORD PTR [rbp-0x78]
  46a29f:	jne    469a93
  46a2a5:	mov    r8,QWORD PTR [rip+0x29944]        # 493bf0
  46a2ac:	mov    rsi,QWORD PTR [rcx+0xb0]
  46a2b3:	mov    r10,r12
  46a2b6:	crc32  r10,r14
  46a2bc:	mov    edi,r13d
  46a2bf:	and    edi,r10d
  46a2c2:	shl    rdi,0x4
  46a2c6:	prefetcht1 BYTE PTR [r8+rdi*1]
  46a2cb:	mov    r8d,DWORD PTR [rcx+0xc8]
  46a2d2:	shl    r8,0x4
  46a2d6:	vmovdqa XMMWORD PTR [rsi+r8*1],xmm1
  46a2dc:	mov    esi,DWORD PTR [rcx+0xc8]
  46a2e2:	mov    rdi,QWORD PTR [rcx+0xb8]
  46a2e9:	mov    r8,QWORD PTR [rip+0x29900]        # 493bf0
  46a2f0:	mov    DWORD PTR [rdi+rsi*4],r10d
  46a2f4:	mov    rsi,QWORD PTR [rcx+0xb0]
  46a2fb:	mov    eax,DWORD PTR [rcx+0xc8]
  46a301:	mov    edx,DWORD PTR [rcx+0x74]
  46a304:	inc    eax
  46a306:	and    eax,edx
  46a308:	mov    DWORD PTR [rcx+0xc8],eax
  46a30e:	mov    r11d,DWORD PTR [rcx+0xcc]
  46a315:	jmp    469a0f
  46a31a:	mov    rsi,QWORD PTR [r12+0xb8]
  46a322:	jmp    46a063
