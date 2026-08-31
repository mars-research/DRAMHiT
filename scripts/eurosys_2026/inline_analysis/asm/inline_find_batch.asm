000000000043caf0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)>:
  43caf0:	55                   	push   rbp
  43caf1:	48 89 e5             	mov    rbp,rsp
  43caf4:	41 57                	push   r15
  43caf6:	49 89 ff             	mov    r15,rdi
  43caf9:	41 56                	push   r14
  43cafb:	41 55                	push   r13
  43cafd:	41 54                	push   r12
  43caff:	53                   	push   rbx
  43cb00:	48 89 d3             	mov    rbx,rdx
  43cb03:	48 83 e4 c0          	and    rsp,0xffffffffffffffc0
  43cb07:	48 89 54 24 e0       	mov    QWORD PTR [rsp-0x20],rdx
  43cb0c:	8b bf b0 00 00 00    	mov    edi,DWORD PTR [rdi+0xb0]
  43cb12:	48 8b 46 08          	mov    rax,QWORD PTR [rsi+0x8]
  43cb16:	41 8b 97 b4 00 00 00 	mov    edx,DWORD PTR [r15+0xb4]
  43cb1d:	45 8b 47 78          	mov    r8d,DWORD PTR [r15+0x78]
  43cb21:	4c 8b 2e             	mov    r13,QWORD PTR [rsi]
  43cb24:	45 8b 57 6c          	mov    r10d,DWORD PTR [r15+0x6c]
  43cb28:	41 89 f9             	mov    r9d,edi
  43cb2b:	48 8d 0c 40          	lea    rcx,[rax+rax*2]
  43cb2f:	41 29 d1             	sub    r9d,edx
  43cb32:	49 8d 74 cd 00       	lea    rsi,[r13+rcx*8+0x0]
  43cb37:	45 21 c1             	and    r9d,r8d
  43cb3a:	41 ff ca             	dec    r10d
  43cb3d:	48 89 44 24 e8       	mov    QWORD PTR [rsp-0x18],rax
  43cb42:	48 89 74 24 f8       	mov    QWORD PTR [rsp-0x8],rsi
  43cb47:	45 39 d1             	cmp    r9d,r10d
  43cb4a:	0f 82 79 01 00 00    	jb     43ccc9 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1d9>
  43cb50:	4c 8b 73 08          	mov    r14,QWORD PTR [rbx+0x8]
  43cb54:	49 39 f5             	cmp    r13,rsi
  43cb57:	0f 84 36 01 00 00    	je     43cc93 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1a3>
  43cb5d:	41 bb 55 00 00 00    	mov    r11d,0x55
  43cb63:	c7 44 24 f0 00 00 00 	mov    DWORD PTR [rsp-0x10],0x0
  43cb6a:	00 
  43cb6b:	4c 8b 15 b6 12 05 00 	mov    r10,QWORD PTR [rip+0x512b6]        # 48de28 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43cb72:	4d 8b 8f a0 00 00 00 	mov    r9,QWORD PTR [r15+0xa0]
  43cb79:	4d 8b a7 80 00 00 00 	mov    r12,QWORD PTR [r15+0x80]
  43cb80:	c5 c1 ef ff          	vpxor  xmm7,xmm7,xmm7
  43cb84:	c4 c1 79 92 cb       	kmovb  k1,r11d
  43cb89:	eb 3a                	jmp    43cbc5 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xd5>
  43cb8b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  43cb90:	62 f3 bd 49 1e ef 00 	vpcmpequq k5{k1},zmm8,zmm7
  43cb97:	c5 f9 98 ed          	kortestb k5,k5
  43cb9b:	0f 85 1f 01 00 00    	jne    43ccc0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1d0>
  43cba1:	83 c0 04             	add    eax,0x4
  43cba4:	44 21 e0             	and    eax,r12d
  43cba7:	89 c3                	mov    ebx,eax
  43cba9:	48 c1 e3 04          	shl    rbx,0x4
  43cbad:	c5 79 6e d0          	vmovd  xmm10,eax
  43cbb1:	41 0f 18 1c 1a       	prefetcht2 BYTE PTR [r10+rbx*1]
  43cbb6:	c4 63 29 22 59 14 01 	vpinsrd xmm11,xmm10,DWORD PTR [rcx+0x14],0x1
  43cbbd:	4c 89 1e             	mov    QWORD PTR [rsi],r11
  43cbc0:	c5 79 d6 5e 10       	vmovq  QWORD PTR [rsi+0x10],xmm11
  43cbc5:	89 d1                	mov    ecx,edx
  43cbc7:	8d 42 08             	lea    eax,[rdx+0x8]
  43cbca:	44 21 c0             	and    eax,r8d
  43cbcd:	4c 8d 1c 49          	lea    r11,[rcx+rcx*2]
  43cbd1:	48 8d 1c 40          	lea    rbx,[rax+rax*2]
  43cbd5:	4b 8d 0c d9          	lea    rcx,[r9+r11*8]
  43cbd9:	41 8b 74 d9 10       	mov    esi,DWORD PTR [r9+rbx*8+0x10]
  43cbde:	8b 59 10             	mov    ebx,DWORD PTR [rcx+0x10]
  43cbe1:	4c 8b 19             	mov    r11,QWORD PTR [rcx]
  43cbe4:	48 89 d8             	mov    rax,rbx
  43cbe7:	48 c1 e3 04          	shl    rbx,0x4
  43cbeb:	4c 01 d3             	add    rbx,r10
  43cbee:	62 71 fd 48 6f 03    	vmovdqa64 zmm8,ZMMWORD PTR [rbx]
  43cbf4:	62 52 fd 48 7c cb    	vpbroadcastq zmm9,r11
  43cbfa:	48 c1 e6 04          	shl    rsi,0x4
  43cbfe:	62 d3 bd 49 1e e1 00 	vpcmpequq k4{k1},zmm8,zmm9
  43cc05:	41 0f 18 0c 32       	prefetcht0 BYTE PTR [r10+rsi*1]
  43cc0a:	89 fe                	mov    esi,edi
  43cc0c:	ff c2                	inc    edx
  43cc0e:	ff c7                	inc    edi
  43cc10:	48 8d 34 76          	lea    rsi,[rsi+rsi*2]
  43cc14:	44 21 c2             	and    edx,r8d
  43cc17:	44 21 c7             	and    edi,r8d
  43cc1a:	49 8d 34 f1          	lea    rsi,[r9+rsi*8]
  43cc1e:	c5 f9 98 e4          	kortestb k4,k4
  43cc22:	0f 84 68 ff ff ff    	je     43cb90 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xa0>
  43cc28:	c5 f9 93 c4          	kmovb  eax,k4
  43cc2c:	f3 0f bc c0          	tzcnt  eax,eax
  43cc30:	ff c0                	inc    eax
  43cc32:	48 98                	cdqe   
  43cc34:	4c 8b 1c c3          	mov    r11,QWORD PTR [rbx+rax*8]
  43cc38:	8b 49 14             	mov    ecx,DWORD PTR [rcx+0x14]
  43cc3b:	4d 89 5e 08          	mov    QWORD PTR [r14+0x8],r11
  43cc3f:	41 89 0e             	mov    DWORD PTR [r14],ecx
  43cc42:	49 83 c6 10          	add    r14,0x10
  43cc46:	49 8b 5d 00          	mov    rbx,QWORD PTR [r13+0x0]
  43cc4a:	b8 ff ff ff ff       	mov    eax,0xffffffff
  43cc4f:	f2 48 0f 38 f1 c3    	crc32  rax,rbx
  43cc55:	44 21 e0             	and    eax,r12d
  43cc58:	c5 79 6e e0          	vmovd  xmm12,eax
  43cc5c:	c4 43 19 22 6d 10 01 	vpinsrd xmm13,xmm12,DWORD PTR [r13+0x10],0x1
  43cc63:	41 89 c3             	mov    r11d,eax
  43cc66:	49 c1 e3 04          	shl    r11,0x4
  43cc6a:	49 83 c5 18          	add    r13,0x18
  43cc6e:	43 0f 18 1c 1a       	prefetcht2 BYTE PTR [r10+r11*1]
  43cc73:	48 89 1e             	mov    QWORD PTR [rsi],rbx
  43cc76:	c5 79 d6 6e 10       	vmovq  QWORD PTR [rsi+0x10],xmm13
  43cc7b:	4c 39 6c 24 f8       	cmp    QWORD PTR [rsp-0x8],r13
  43cc80:	0f 85 3f ff ff ff    	jne    43cbc5 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xd5>
  43cc86:	44 8b 44 24 f0       	mov    r8d,DWORD PTR [rsp-0x10]
  43cc8b:	4c 29 44 24 e8       	sub    QWORD PTR [rsp-0x18],r8
  43cc90:	c5 f8 77             	vzeroupper 
  43cc93:	41 89 97 b4 00 00 00 	mov    DWORD PTR [r15+0xb4],edx
  43cc9a:	41 89 bf b0 00 00 00 	mov    DWORD PTR [r15+0xb0],edi
  43cca1:	44 8b 6c 24 e8       	mov    r13d,DWORD PTR [rsp-0x18]
  43cca6:	4c 8b 7c 24 e0       	mov    r15,QWORD PTR [rsp-0x20]
  43ccab:	45 01 2f             	add    DWORD PTR [r15],r13d
  43ccae:	48 8d 65 d8          	lea    rsp,[rbp-0x28]
  43ccb2:	5b                   	pop    rbx
  43ccb3:	41 5c                	pop    r12
  43ccb5:	41 5d                	pop    r13
  43ccb7:	41 5e                	pop    r14
  43ccb9:	41 5f                	pop    r15
  43ccbb:	5d                   	pop    rbp
  43ccbc:	c3                   	ret    
  43ccbd:	0f 1f 00             	nop    DWORD PTR [rax]
  43ccc0:	ff 44 24 f0          	inc    DWORD PTR [rsp-0x10]
  43ccc4:	e9 7d ff ff ff       	jmp    43cc46 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x156>
  43ccc9:	4c 3b 6c 24 f8       	cmp    r13,QWORD PTR [rsp-0x8]
  43ccce:	74 de                	je     43ccae <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1be>
  43ccd0:	4c 89 e8             	mov    rax,r13
  43ccd3:	4d 8b af 88 00 00 00 	mov    r13,QWORD PTR [r15+0x88]
  43ccda:	49 89 dc             	mov    r12,rbx
  43ccdd:	49 8b 5f 60          	mov    rbx,QWORD PTR [r15+0x60]
  43cce1:	49 8d 4d ff          	lea    rcx,[r13-0x1]
  43cce5:	48 89 5c 24 e8       	mov    QWORD PTR [rsp-0x18],rbx
  43ccea:	48 89 4c 24 f0       	mov    QWORD PTR [rsp-0x10],rcx
  43ccef:	4c 8b 1d 32 11 05 00 	mov    r11,QWORD PTR [rip+0x51132]        # 48de28 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43ccf6:	4c 8b 35 1b 11 05 00 	mov    r14,QWORD PTR [rip+0x5111b]        # 48de18 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_>
  43ccfd:	4d 8b 97 a0 00 00 00 	mov    r10,QWORD PTR [r15+0xa0]
  43cd04:	41 89 f9             	mov    r9d,edi
  43cd07:	c5 e9 ef d2          	vpxor  xmm2,xmm2,xmm2
  43cd0b:	c5 f9 90 05 fd 10 05 	kmovb  k0,BYTE PTR [rip+0x510fd]        # 48de10 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_exists_>
  43cd12:	00 
  43cd13:	eb 7a                	jmp    43cd8f <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x29f>
  43cd15:	48 83 7c 24 e8 08    	cmp    QWORD PTR [rsp-0x18],0x8
  43cd1b:	75 10                	jne    43cd2d <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x23d>
  43cd1d:	ba ff ff ff ff       	mov    edx,0xffffffff
  43cd22:	f2 48 0f 38 f1 10    	crc32  rdx,QWORD PTR [rax]
  43cd28:	48 89 54 24 d8       	mov    QWORD PTR [rsp-0x28],rdx
  43cd2d:	48 8b 5c 24 f0       	mov    rbx,QWORD PTR [rsp-0x10]
  43cd32:	44 89 ce             	mov    esi,r9d
  43cd35:	48 23 5c 24 d8       	and    rbx,QWORD PTR [rsp-0x28]
  43cd3a:	48 83 e3 fc          	and    rbx,0xfffffffffffffffc
  43cd3e:	c5 f9 6e eb          	vmovd  xmm5,ebx
  43cd42:	48 8b 08             	mov    rcx,QWORD PTR [rax]
  43cd45:	c4 e3 51 22 60 10 01 	vpinsrd xmm4,xmm5,DWORD PTR [rax+0x10],0x1
  43cd4c:	49 89 dd             	mov    r13,rbx
  43cd4f:	48 8d 14 76          	lea    rdx,[rsi+rsi*2]
  43cd53:	49 8d 3c d2          	lea    rdi,[r10+rdx*8]
  43cd57:	49 c1 e5 04          	shl    r13,0x4
  43cd5b:	43 0f 18 1c 2b       	prefetcht2 BYTE PTR [r11+r13*1]
  43cd60:	48 89 0f             	mov    QWORD PTR [rdi],rcx
  43cd63:	c5 f9 d6 67 10       	vmovq  QWORD PTR [rdi+0x10],xmm4
  43cd68:	41 8d 79 01          	lea    edi,[r9+0x1]
  43cd6c:	44 21 c7             	and    edi,r8d
  43cd6f:	48 83 c0 18          	add    rax,0x18
  43cd73:	41 89 bf b0 00 00 00 	mov    DWORD PTR [r15+0xb0],edi
  43cd7a:	48 39 44 24 f8       	cmp    QWORD PTR [rsp-0x8],rax
  43cd7f:	0f 84 70 01 00 00    	je     43cef5 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x405>
  43cd85:	41 8b 97 b4 00 00 00 	mov    edx,DWORD PTR [r15+0xb4]
  43cd8c:	41 89 f9             	mov    r9d,edi
  43cd8f:	29 d7                	sub    edi,edx
  43cd91:	44 21 c7             	and    edi,r8d
  43cd94:	41 39 f8             	cmp    r8d,edi
  43cd97:	76 7d                	jbe    43ce16 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x326>
  43cd99:	48 83 7c 24 e8 04    	cmp    QWORD PTR [rsp-0x18],0x4
  43cd9f:	0f 85 70 ff ff ff    	jne    43cd15 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x225>
  43cda5:	b9 ff ff ff ff       	mov    ecx,0xffffffff
  43cdaa:	f2 0f 38 f1 08       	crc32  ecx,DWORD PTR [rax]
  43cdaf:	89 cf                	mov    edi,ecx
  43cdb1:	48 89 7c 24 d8       	mov    QWORD PTR [rsp-0x28],rdi
  43cdb6:	e9 72 ff ff ff       	jmp    43cd2d <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x23d>
  43cdbb:	62 f3 fd 48 1e da 00 	vpcmpequq k3,zmm0,zmm2
  43cdc2:	c5 f9 93 fb          	kmovb  edi,k3
  43cdc6:	83 e7 55             	and    edi,0x55
  43cdc9:	0f 85 1a 01 00 00    	jne    43cee9 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x3f9>
  43cdcf:	48 83 c3 04          	add    rbx,0x4
  43cdd3:	48 23 5c 24 f0       	and    rbx,QWORD PTR [rsp-0x10]
  43cdd8:	48 89 d9             	mov    rcx,rbx
  43cddb:	44 89 cf             	mov    edi,r9d
  43cdde:	48 c1 e1 04          	shl    rcx,0x4
  43cde2:	c5 f9 6e f3          	vmovd  xmm6,ebx
  43cde6:	41 0f 18 1c 0b       	prefetcht2 BYTE PTR [r11+rcx*1]
  43cdeb:	c4 e3 49 22 5e 14 01 	vpinsrd xmm3,xmm6,DWORD PTR [rsi+0x14],0x1
  43cdf2:	48 8d 0c 7f          	lea    rcx,[rdi+rdi*2]
  43cdf6:	41 ff c1             	inc    r9d
  43cdf9:	49 8d 3c ca          	lea    rdi,[r10+rcx*8]
  43cdfd:	45 21 c1             	and    r9d,r8d
  43ce00:	4c 89 2f             	mov    QWORD PTR [rdi],r13
  43ce03:	c5 f9 d6 5f 10       	vmovq  QWORD PTR [rdi+0x10],xmm3
  43ce08:	45 89 8f b0 00 00 00 	mov    DWORD PTR [r15+0xb0],r9d
  43ce0f:	41 89 97 b4 00 00 00 	mov    DWORD PTR [r15+0xb4],edx
  43ce16:	8d 7a 08             	lea    edi,[rdx+0x8]
  43ce19:	41 89 d5             	mov    r13d,edx
  43ce1c:	44 21 c7             	and    edi,r8d
  43ce1f:	48 8d 34 7f          	lea    rsi,[rdi+rdi*2]
  43ce23:	4b 8d 4c 6d 00       	lea    rcx,[r13+r13*2+0x0]
  43ce28:	41 8b 5c f2 10       	mov    ebx,DWORD PTR [r10+rsi*8+0x10]
  43ce2d:	49 8d 34 ca          	lea    rsi,[r10+rcx*8]
  43ce31:	4c 8b 2e             	mov    r13,QWORD PTR [rsi]
  43ce34:	48 c1 e3 04          	shl    rbx,0x4
  43ce38:	ff c2                	inc    edx
  43ce3a:	44 21 c2             	and    edx,r8d
  43ce3d:	41 0f 18 0c 1b       	prefetcht0 BYTE PTR [r11+rbx*1]
  43ce42:	4d 3b af 90 00 00 00 	cmp    r13,QWORD PTR [r15+0x90]
  43ce49:	75 3d                	jne    43ce88 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x398>
  43ce4b:	c5 f9 98 c0          	kortestb k0,k0
  43ce4f:	74 20                	je     43ce71 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x381>
  43ce51:	41 8b 1c 24          	mov    ebx,DWORD PTR [r12]
  43ce55:	8b 76 14             	mov    esi,DWORD PTR [rsi+0x14]
  43ce58:	49 89 dd             	mov    r13,rbx
  43ce5b:	48 c1 e3 04          	shl    rbx,0x4
  43ce5f:	49 03 5c 24 08       	add    rbx,QWORD PTR [r12+0x8]
  43ce64:	41 ff c5             	inc    r13d
  43ce67:	89 33                	mov    DWORD PTR [rbx],esi
  43ce69:	4c 89 73 08          	mov    QWORD PTR [rbx+0x8],r14
  43ce6d:	45 89 2c 24          	mov    DWORD PTR [r12],r13d
  43ce71:	41 89 97 b4 00 00 00 	mov    DWORD PTR [r15+0xb4],edx
  43ce78:	4d 85 f6             	test   r14,r14
  43ce7b:	75 99                	jne    43ce16 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x326>
  43ce7d:	e9 17 ff ff ff       	jmp    43cd99 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2a9>
  43ce82:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  43ce88:	8b 5e 10             	mov    ebx,DWORD PTR [rsi+0x10]
  43ce8b:	62 d2 fd 48 7c cd    	vpbroadcastq zmm1,r13
  43ce91:	48 89 df             	mov    rdi,rbx
  43ce94:	48 c1 e7 04          	shl    rdi,0x4
  43ce98:	4c 01 df             	add    rdi,r11
  43ce9b:	62 f1 fd 48 6f 07    	vmovdqa64 zmm0,ZMMWORD PTR [rdi]
  43cea1:	62 f3 fd 48 1e d1 00 	vpcmpequq k2,zmm0,zmm1
  43cea8:	c5 f9 93 ca          	kmovb  ecx,k2
  43ceac:	83 e1 55             	and    ecx,0x55
  43ceaf:	0f 84 06 ff ff ff    	je     43cdbb <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2cb>
  43ceb5:	44 0f b6 e9          	movzx  r13d,cl
  43ceb9:	31 c9                	xor    ecx,ecx
  43cebb:	f3 41 0f bc cd       	tzcnt  ecx,r13d
  43cec0:	41 8b 1c 24          	mov    ebx,DWORD PTR [r12]
  43cec4:	ff c1                	inc    ecx
  43cec6:	48 63 c9             	movsxd rcx,ecx
  43cec9:	8b 76 14             	mov    esi,DWORD PTR [rsi+0x14]
  43cecc:	48 8b 3c cf          	mov    rdi,QWORD PTR [rdi+rcx*8]
  43ced0:	49 89 dd             	mov    r13,rbx
  43ced3:	48 c1 e3 04          	shl    rbx,0x4
  43ced7:	49 03 5c 24 08       	add    rbx,QWORD PTR [r12+0x8]
  43cedc:	41 ff c5             	inc    r13d
  43cedf:	89 33                	mov    DWORD PTR [rbx],esi
  43cee1:	48 89 7b 08          	mov    QWORD PTR [rbx+0x8],rdi
  43cee5:	45 89 2c 24          	mov    DWORD PTR [r12],r13d
  43cee9:	41 89 97 b4 00 00 00 	mov    DWORD PTR [r15+0xb4],edx
  43cef0:	e9 a4 fe ff ff       	jmp    43cd99 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2a9>
  43cef5:	c5 f8 77             	vzeroupper 
  43cef8:	e9 b1 fd ff ff       	jmp    43ccae <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1be>
  43cefd:	90                   	nop
  43cefe:	66 90                	xchg   ax,ax

000000000043cf00 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)>:
  43cf00:	48 89 f9             	mov    rcx,rdi
  43cf03:	44 8b 99 b0 00 00 00 	mov    r11d,DWORD PTR [rcx+0xb0]
  43cf0a:	8b 7f 78             	mov    edi,DWORD PTR [rdi+0x78]
  43cf0d:	44 2b 99 b4 00 00 00 	sub    r11d,DWORD PTR [rcx+0xb4]
  43cf14:	41 21 fb             	and    r11d,edi
  43cf17:	4d 85 db             	test   r11,r11
  43cf1a:	0f 84 c3 01 00 00    	je     43d0e3 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1e3>
  43cf20:	55                   	push   rbp
  43cf21:	49 89 f1             	mov    r9,rsi
  43cf24:	c5 e9 ef d2          	vpxor  xmm2,xmm2,xmm2
  43cf28:	48 89 e5             	mov    rbp,rsp
  43cf2b:	41 57                	push   r15
  43cf2d:	41 56                	push   r14
  43cf2f:	41 55                	push   r13
  43cf31:	41 54                	push   r12
  43cf33:	53                   	push   rbx
  43cf34:	48 83 e4 c0          	and    rsp,0xffffffffffffffc0
  43cf38:	8b 05 d6 0d 05 00    	mov    eax,DWORD PTR [rip+0x50dd6]        # 48dd14 <kmercounter::config+0x114>
  43cf3e:	4c 8b 05 e3 0e 05 00 	mov    r8,QWORD PTR [rip+0x50ee3]        # 48de28 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43cf45:	89 44 24 fc          	mov    DWORD PTR [rsp-0x4],eax
  43cf49:	0f b6 1d c0 0e 05 00 	movzx  ebx,BYTE PTR [rip+0x50ec0]        # 48de10 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_exists_>
  43cf50:	4c 8b 15 c1 0e 05 00 	mov    r10,QWORD PTR [rip+0x50ec1]        # 48de18 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_>
  43cf57:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  43cf5e:	00 00 
  43cf60:	8b 54 24 fc          	mov    edx,DWORD PTR [rsp-0x4]
  43cf64:	41 39 11             	cmp    DWORD PTR [r9],edx
  43cf67:	0f 83 6e 01 00 00    	jae    43d0db <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1db>
  43cf6d:	48 8b b1 a0 00 00 00 	mov    rsi,QWORD PTR [rcx+0xa0]
  43cf74:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  43cf78:	8b 81 b4 00 00 00    	mov    eax,DWORD PTR [rcx+0xb4]
  43cf7e:	44 8d 60 08          	lea    r12d,[rax+0x8]
  43cf82:	41 21 fc             	and    r12d,edi
  43cf85:	41 89 c7             	mov    r15d,eax
  43cf88:	4f 8d 2c 64          	lea    r13,[r12+r12*2]
  43cf8c:	4b 8d 14 7f          	lea    rdx,[r15+r15*2]
  43cf90:	46 8b 74 ee 10       	mov    r14d,DWORD PTR [rsi+r13*8+0x10]
  43cf95:	4c 8d 24 d6          	lea    r12,[rsi+rdx*8]
  43cf99:	4d 8b 2c 24          	mov    r13,QWORD PTR [r12]
  43cf9d:	49 c1 e6 04          	shl    r14,0x4
  43cfa1:	ff c0                	inc    eax
  43cfa3:	21 f8                	and    eax,edi
  43cfa5:	43 0f 18 0c 30       	prefetcht0 BYTE PTR [r8+r14*1]
  43cfaa:	4c 3b a9 90 00 00 00 	cmp    r13,QWORD PTR [rcx+0x90]
  43cfb1:	75 35                	jne    43cfe8 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xe8>
  43cfb3:	84 db                	test   bl,bl
  43cfb5:	74 20                	je     43cfd7 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xd7>
  43cfb7:	45 8b 39             	mov    r15d,DWORD PTR [r9]
  43cfba:	45 8b 64 24 14       	mov    r12d,DWORD PTR [r12+0x14]
  43cfbf:	4d 89 fd             	mov    r13,r15
  43cfc2:	49 c1 e7 04          	shl    r15,0x4
  43cfc6:	4d 03 79 08          	add    r15,QWORD PTR [r9+0x8]
  43cfca:	41 ff c5             	inc    r13d
  43cfcd:	45 89 27             	mov    DWORD PTR [r15],r12d
  43cfd0:	4d 89 57 08          	mov    QWORD PTR [r15+0x8],r10
  43cfd4:	45 89 29             	mov    DWORD PTR [r9],r13d
  43cfd7:	89 81 b4 00 00 00    	mov    DWORD PTR [rcx+0xb4],eax
  43cfdd:	4d 85 d2             	test   r10,r10
  43cfe0:	75 96                	jne    43cf78 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x78>
  43cfe2:	eb 6a                	jmp    43d04e <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x14e>
  43cfe4:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  43cfe8:	45 8b 7c 24 10       	mov    r15d,DWORD PTR [r12+0x10]
  43cfed:	62 d2 fd 48 7c cd    	vpbroadcastq zmm1,r13
  43cff3:	4d 89 fe             	mov    r14,r15
  43cff6:	49 c1 e6 04          	shl    r14,0x4
  43cffa:	4d 01 c6             	add    r14,r8
  43cffd:	62 d1 fd 48 6f 06    	vmovdqa64 zmm0,ZMMWORD PTR [r14]
  43d003:	62 f3 fd 48 1e c1 00 	vpcmpequq k0,zmm0,zmm1
  43d00a:	c5 f9 93 d0          	kmovb  edx,k0
  43d00e:	83 e2 55             	and    edx,0x55
  43d011:	74 5d                	je     43d070 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x170>
  43d013:	0f b6 f2             	movzx  esi,dl
  43d016:	45 31 ff             	xor    r15d,r15d
  43d019:	f3 44 0f bc fe       	tzcnt  r15d,esi
  43d01e:	41 ff c7             	inc    r15d
  43d021:	41 8b 31             	mov    esi,DWORD PTR [r9]
  43d024:	49 63 d7             	movsxd rdx,r15d
  43d027:	45 8b 64 24 14       	mov    r12d,DWORD PTR [r12+0x14]
  43d02c:	4d 8b 34 d6          	mov    r14,QWORD PTR [r14+rdx*8]
  43d030:	49 89 f5             	mov    r13,rsi
  43d033:	48 c1 e6 04          	shl    rsi,0x4
  43d037:	49 03 71 08          	add    rsi,QWORD PTR [r9+0x8]
  43d03b:	41 ff c5             	inc    r13d
  43d03e:	44 89 26             	mov    DWORD PTR [rsi],r12d
  43d041:	4c 89 76 08          	mov    QWORD PTR [rsi+0x8],r14
  43d045:	45 89 29             	mov    DWORD PTR [r9],r13d
  43d048:	89 81 b4 00 00 00    	mov    DWORD PTR [rcx+0xb4],eax
  43d04e:	49 ff cb             	dec    r11
  43d051:	0f 85 09 ff ff ff    	jne    43cf60 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x60>
  43d057:	c5 f8 77             	vzeroupper 
  43d05a:	45 31 db             	xor    r11d,r11d
  43d05d:	48 8d 65 d8          	lea    rsp,[rbp-0x28]
  43d061:	4c 89 d8             	mov    rax,r11
  43d064:	5b                   	pop    rbx
  43d065:	41 5c                	pop    r12
  43d067:	41 5d                	pop    r13
  43d069:	41 5e                	pop    r14
  43d06b:	41 5f                	pop    r15
  43d06d:	5d                   	pop    rbp
  43d06e:	c3                   	ret    
  43d06f:	90                   	nop
  43d070:	62 f3 fd 48 1e ca 00 	vpcmpequq k1,zmm0,zmm2
  43d077:	c5 79 93 f1          	kmovb  r14d,k1
  43d07b:	41 83 e6 55          	and    r14d,0x55
  43d07f:	75 c7                	jne    43d048 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x148>
  43d081:	49 8d 57 04          	lea    rdx,[r15+0x4]
  43d085:	4c 8b b9 88 00 00 00 	mov    r15,QWORD PTR [rcx+0x88]
  43d08c:	49 ff cf             	dec    r15
  43d08f:	49 21 d7             	and    r15,rdx
  43d092:	4d 89 fe             	mov    r14,r15
  43d095:	49 c1 e6 04          	shl    r14,0x4
  43d099:	43 0f 18 1c 30       	prefetcht2 BYTE PTR [r8+r14*1]
  43d09e:	44 8b b1 b0 00 00 00 	mov    r14d,DWORD PTR [rcx+0xb0]
  43d0a5:	c4 c1 79 6e df       	vmovd  xmm3,r15d
  43d0aa:	4c 89 f2             	mov    rdx,r14
  43d0ad:	c4 c3 61 22 64 24 14 	vpinsrd xmm4,xmm3,DWORD PTR [r12+0x14],0x1
  43d0b4:	01 
  43d0b5:	4f 8d 34 76          	lea    r14,[r14+r14*2]
  43d0b9:	ff c2                	inc    edx
  43d0bb:	4e 8d 34 f6          	lea    r14,[rsi+r14*8]
  43d0bf:	21 fa                	and    edx,edi
  43d0c1:	4d 89 2e             	mov    QWORD PTR [r14],r13
  43d0c4:	c4 c1 79 d6 66 10    	vmovq  QWORD PTR [r14+0x10],xmm4
  43d0ca:	89 91 b0 00 00 00    	mov    DWORD PTR [rcx+0xb0],edx
  43d0d0:	89 81 b4 00 00 00    	mov    DWORD PTR [rcx+0xb4],eax
  43d0d6:	e9 9d fe ff ff       	jmp    43cf78 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x78>
  43d0db:	c5 f8 77             	vzeroupper 
  43d0de:	e9 7a ff ff ff       	jmp    43d05d <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x15d>
  43d0e3:	31 c0                	xor    eax,eax
  43d0e5:	c3                   	ret    
  43d0e6:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
  43d0ed:	00 00 00 

