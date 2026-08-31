000000000043c600 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)>:
  43c600:	55                   	push   rbp
  43c601:	49 89 d3             	mov    r11,rdx
  43c604:	48 89 e5             	mov    rbp,rsp
  43c607:	41 57                	push   r15
  43c609:	41 56                	push   r14
  43c60b:	41 55                	push   r13
  43c60d:	41 54                	push   r12
  43c60f:	53                   	push   rbx
  43c610:	48 83 e4 c0          	and    rsp,0xffffffffffffffc0
  43c614:	48 8b 56 08          	mov    rdx,QWORD PTR [rsi+0x8]
  43c618:	4c 8b 2e             	mov    r13,QWORD PTR [rsi]
  43c61b:	48 8d 0c 52          	lea    rcx,[rdx+rdx*2]
  43c61f:	49 8d 5c cd 00       	lea    rbx,[r13+rcx*8+0x0]
  43c624:	8b 8f b0 00 00 00    	mov    ecx,DWORD PTR [rdi+0xb0]
  43c62a:	8b 87 b4 00 00 00    	mov    eax,DWORD PTR [rdi+0xb4]
  43c630:	44 8b 47 78          	mov    r8d,DWORD PTR [rdi+0x78]
  43c634:	89 ce                	mov    esi,ecx
  43c636:	29 c6                	sub    esi,eax
  43c638:	44 21 c6             	and    esi,r8d
  43c63b:	48 89 5c 24 f0       	mov    QWORD PTR [rsp-0x10],rbx
  43c640:	41 39 f0             	cmp    r8d,esi
  43c643:	0f 87 cf 00 00 00    	ja     43c718 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x118>
  43c649:	49 39 dd             	cmp    r13,rbx
  43c64c:	0f 84 b1 00 00 00    	je     43c703 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x103>
  43c652:	48 8b b7 88 00 00 00 	mov    rsi,QWORD PTR [rdi+0x88]
  43c659:	4c 8b 77 60          	mov    r14,QWORD PTR [rdi+0x60]
  43c65d:	48 ff ce             	dec    rsi
  43c660:	4c 89 74 24 e8       	mov    QWORD PTR [rsp-0x18],r14
  43c665:	48 89 74 24 f8       	mov    QWORD PTR [rsp-0x8],rsi
  43c66a:	48 8b 1d bf 07 05 00 	mov    rbx,QWORD PTR [rip+0x507bf]        # 48ce30 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43c671:	4c 8b 8f a0 00 00 00 	mov    r9,QWORD PTR [rdi+0xa0]
  43c678:	4c 8b 3d 39 07 05 00 	mov    r15,QWORD PTR [rip+0x50739]        # 48cdb8 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_>
  43c67f:	c5 c1 ef ff          	vpxor  xmm7,xmm7,xmm7
  43c683:	c5 f9 90 2d 29 07 05 	kmovb  k5,BYTE PTR [rip+0x50729]        # 48cdb4 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_exists_>
  43c68a:	00 
  43c68b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  43c690:	44 8d 50 08          	lea    r10d,[rax+0x8]
  43c694:	45 21 c2             	and    r10d,r8d
  43c697:	41 89 c6             	mov    r14d,eax
  43c69a:	4f 8d 24 52          	lea    r12,[r10+r10*2]
  43c69e:	4b 8d 34 76          	lea    rsi,[r14+r14*2]
  43c6a2:	43 8b 54 e1 10       	mov    edx,DWORD PTR [r9+r12*8+0x10]
  43c6a7:	4d 8d 14 f1          	lea    r10,[r9+rsi*8]
  43c6ab:	4d 8b 22             	mov    r12,QWORD PTR [r10]
  43c6ae:	48 c1 e2 04          	shl    rdx,0x4
  43c6b2:	ff c0                	inc    eax
  43c6b4:	44 21 c0             	and    eax,r8d
  43c6b7:	0f 18 0c 13          	prefetcht0 BYTE PTR [rbx+rdx*1]
  43c6bb:	4c 3b a7 90 00 00 00 	cmp    r12,QWORD PTR [rdi+0x90]
  43c6c2:	0f 85 18 02 00 00    	jne    43c8e0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2e0>
  43c6c8:	c5 f9 98 ed          	kortestb k5,k5
  43c6cc:	74 1f                	je     43c6ed <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xed>
  43c6ce:	41 8b 13             	mov    edx,DWORD PTR [r11]
  43c6d1:	45 8b 52 14          	mov    r10d,DWORD PTR [r10+0x14]
  43c6d5:	49 89 d4             	mov    r12,rdx
  43c6d8:	48 c1 e2 04          	shl    rdx,0x4
  43c6dc:	49 03 53 08          	add    rdx,QWORD PTR [r11+0x8]
  43c6e0:	41 ff c4             	inc    r12d
  43c6e3:	44 89 12             	mov    DWORD PTR [rdx],r10d
  43c6e6:	4c 89 7a 08          	mov    QWORD PTR [rdx+0x8],r15
  43c6ea:	45 89 23             	mov    DWORD PTR [r11],r12d
  43c6ed:	89 87 b4 00 00 00    	mov    DWORD PTR [rdi+0xb4],eax
  43c6f3:	4d 85 ff             	test   r15,r15
  43c6f6:	75 98                	jne    43c690 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x90>
  43c6f8:	e9 4a 02 00 00       	jmp    43c947 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x347>
  43c6fd:	0f 1f 00             	nop    DWORD PTR [rax]
  43c700:	c5 f8 77             	vzeroupper 
  43c703:	48 8d 65 d8          	lea    rsp,[rbp-0x28]
  43c707:	5b                   	pop    rbx
  43c708:	41 5c                	pop    r12
  43c70a:	41 5d                	pop    r13
  43c70c:	41 5e                	pop    r14
  43c70e:	41 5f                	pop    r15
  43c710:	5d                   	pop    rbp
  43c711:	c3                   	ret    
  43c712:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  43c718:	4c 3b 6c 24 f0       	cmp    r13,QWORD PTR [rsp-0x10]
  43c71d:	74 e4                	je     43c703 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x103>
  43c71f:	4c 8b 8f 88 00 00 00 	mov    r9,QWORD PTR [rdi+0x88]
  43c726:	44 0f b6 35 86 06 05 	movzx  r14d,BYTE PTR [rip+0x50686]        # 48cdb4 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_exists_>
  43c72d:	00 
  43c72e:	48 8b 47 60          	mov    rax,QWORD PTR [rdi+0x60]
  43c732:	49 ff c9             	dec    r9
  43c735:	c4 c1 79 92 c6       	kmovb  k0,r14d
  43c73a:	48 89 44 24 e8       	mov    QWORD PTR [rsp-0x18],rax
  43c73f:	4c 89 4c 24 f8       	mov    QWORD PTR [rsp-0x8],r9
  43c744:	4c 8b 15 e5 06 05 00 	mov    r10,QWORD PTR [rip+0x506e5]        # 48ce30 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43c74b:	4c 8b 25 66 06 05 00 	mov    r12,QWORD PTR [rip+0x50666]        # 48cdb8 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_>
  43c752:	48 8b b7 a0 00 00 00 	mov    rsi,QWORD PTR [rdi+0xa0]
  43c759:	c5 e9 ef d2          	vpxor  xmm2,xmm2,xmm2
  43c75d:	4d 89 fe             	mov    r14,r15
  43c760:	e9 85 00 00 00       	jmp    43c7ea <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1ea>
  43c765:	0f 1f 00             	nop    DWORD PTR [rax]
  43c768:	48 83 7c 24 e8 08    	cmp    QWORD PTR [rsp-0x18],0x8
  43c76e:	4d 8b 7d 00          	mov    r15,QWORD PTR [r13+0x0]
  43c772:	75 0c                	jne    43c780 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x180>
  43c774:	41 be ff ff ff ff    	mov    r14d,0xffffffff
  43c77a:	f2 4d 0f 38 f1 f7    	crc32  r14,r15
  43c780:	48 8b 5c 24 f8       	mov    rbx,QWORD PTR [rsp-0x8]
  43c785:	41 89 c9             	mov    r9d,ecx
  43c788:	4c 21 f3             	and    rbx,r14
  43c78b:	48 83 e3 fc          	and    rbx,0xfffffffffffffffc
  43c78f:	48 89 d8             	mov    rax,rbx
  43c792:	c5 f9 6e eb          	vmovd  xmm5,ebx
  43c796:	c4 c3 51 22 45 10 01 	vpinsrd xmm0,xmm5,DWORD PTR [r13+0x10],0x1
  43c79d:	48 c1 e0 04          	shl    rax,0x4
  43c7a1:	4b 8d 14 49          	lea    rdx,[r9+r9*2]
  43c7a5:	ff c1                	inc    ecx
  43c7a7:	41 0f 18 1c 02       	prefetcht2 BYTE PTR [r10+rax*1]
  43c7ac:	44 21 c1             	and    ecx,r8d
  43c7af:	48 8d 04 d6          	lea    rax,[rsi+rdx*8]
  43c7b3:	49 83 c5 18          	add    r13,0x18
  43c7b7:	4c 89 38             	mov    QWORD PTR [rax],r15
  43c7ba:	c5 f9 d6 40 10       	vmovq  QWORD PTR [rax+0x10],xmm0
  43c7bf:	89 8f b0 00 00 00    	mov    DWORD PTR [rdi+0xb0],ecx
  43c7c5:	4c 3b 6c 24 f0       	cmp    r13,QWORD PTR [rsp-0x10]
  43c7ca:	0f 84 30 ff ff ff    	je     43c700 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x100>
  43c7d0:	8b 87 b4 00 00 00    	mov    eax,DWORD PTR [rdi+0xb4]
  43c7d6:	29 c1                	sub    ecx,eax
  43c7d8:	44 21 c1             	and    ecx,r8d
  43c7db:	41 39 c8             	cmp    r8d,ecx
  43c7de:	0f 86 8d 00 00 00    	jbe    43c871 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x271>
  43c7e4:	8b 8f b0 00 00 00    	mov    ecx,DWORD PTR [rdi+0xb0]
  43c7ea:	48 83 7c 24 e8 04    	cmp    QWORD PTR [rsp-0x18],0x4
  43c7f0:	0f 85 72 ff ff ff    	jne    43c768 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x168>
  43c7f6:	ba ff ff ff ff       	mov    edx,0xffffffff
  43c7fb:	f2 41 0f 38 f1 55 00 	crc32  edx,DWORD PTR [r13+0x0]
  43c802:	4d 8b 7d 00          	mov    r15,QWORD PTR [r13+0x0]
  43c806:	41 89 d6             	mov    r14d,edx
  43c809:	e9 72 ff ff ff       	jmp    43c780 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x180>
  43c80e:	66 90                	xchg   ax,ax
  43c810:	62 f3 e5 48 1e e2 00 	vpcmpequq k4,zmm3,zmm2
  43c817:	c5 79 93 cc          	kmovb  r9d,k4
  43c81b:	41 83 e1 55          	and    r9d,0x55
  43c81f:	0f 85 69 02 00 00    	jne    43ca8e <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x48e>
  43c825:	48 83 c3 04          	add    rbx,0x4
  43c829:	48 23 5c 24 f8       	and    rbx,QWORD PTR [rsp-0x8]
  43c82e:	44 8b 8f b0 00 00 00 	mov    r9d,DWORD PTR [rdi+0xb0]
  43c835:	48 89 da             	mov    rdx,rbx
  43c838:	48 c1 e2 04          	shl    rdx,0x4
  43c83c:	41 0f 18 1c 12       	prefetcht2 BYTE PTR [r10+rdx*1]
  43c841:	c5 f9 6e f3          	vmovd  xmm6,ebx
  43c845:	4c 89 ca             	mov    rdx,r9
  43c848:	c4 e3 49 22 61 14 01 	vpinsrd xmm4,xmm6,DWORD PTR [rcx+0x14],0x1
  43c84f:	4f 8d 0c 49          	lea    r9,[r9+r9*2]
  43c853:	ff c2                	inc    edx
  43c855:	4e 8d 0c ce          	lea    r9,[rsi+r9*8]
  43c859:	44 21 c2             	and    edx,r8d
  43c85c:	4d 89 39             	mov    QWORD PTR [r9],r15
  43c85f:	c4 c1 79 d6 61 10    	vmovq  QWORD PTR [r9+0x10],xmm4
  43c865:	89 97 b0 00 00 00    	mov    DWORD PTR [rdi+0xb0],edx
  43c86b:	89 87 b4 00 00 00    	mov    DWORD PTR [rdi+0xb4],eax
  43c871:	8d 48 08             	lea    ecx,[rax+0x8]
  43c874:	44 21 c1             	and    ecx,r8d
  43c877:	41 89 c1             	mov    r9d,eax
  43c87a:	4c 8d 3c 49          	lea    r15,[rcx+rcx*2]
  43c87e:	4b 8d 14 49          	lea    rdx,[r9+r9*2]
  43c882:	42 8b 5c fe 10       	mov    ebx,DWORD PTR [rsi+r15*8+0x10]
  43c887:	48 8d 0c d6          	lea    rcx,[rsi+rdx*8]
  43c88b:	4c 8b 39             	mov    r15,QWORD PTR [rcx]
  43c88e:	48 c1 e3 04          	shl    rbx,0x4
  43c892:	ff c0                	inc    eax
  43c894:	44 21 c0             	and    eax,r8d
  43c897:	41 0f 18 0c 1a       	prefetcht0 BYTE PTR [r10+rbx*1]
  43c89c:	4c 3b bf 90 00 00 00 	cmp    r15,QWORD PTR [rdi+0x90]
  43c8a3:	0f 85 87 01 00 00    	jne    43ca30 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x430>
  43c8a9:	c5 f9 98 c0          	kortestb k0,k0
  43c8ad:	74 1d                	je     43c8cc <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2cc>
  43c8af:	41 8b 1b             	mov    ebx,DWORD PTR [r11]
  43c8b2:	8b 49 14             	mov    ecx,DWORD PTR [rcx+0x14]
  43c8b5:	49 89 df             	mov    r15,rbx
  43c8b8:	48 c1 e3 04          	shl    rbx,0x4
  43c8bc:	49 03 5b 08          	add    rbx,QWORD PTR [r11+0x8]
  43c8c0:	41 ff c7             	inc    r15d
  43c8c3:	89 0b                	mov    DWORD PTR [rbx],ecx
  43c8c5:	4c 89 63 08          	mov    QWORD PTR [rbx+0x8],r12
  43c8c9:	45 89 3b             	mov    DWORD PTR [r11],r15d
  43c8cc:	89 87 b4 00 00 00    	mov    DWORD PTR [rdi+0xb4],eax
  43c8d2:	4d 85 e4             	test   r12,r12
  43c8d5:	75 9a                	jne    43c871 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x271>
  43c8d7:	e9 08 ff ff ff       	jmp    43c7e4 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1e4>
  43c8dc:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  43c8e0:	41 8b 52 10          	mov    edx,DWORD PTR [r10+0x10]
  43c8e4:	62 52 fd 48 7c cc    	vpbroadcastq zmm9,r12
  43c8ea:	49 89 d6             	mov    r14,rdx
  43c8ed:	49 c1 e6 04          	shl    r14,0x4
  43c8f1:	49 01 de             	add    r14,rbx
  43c8f4:	62 51 fd 48 6f 06    	vmovdqa64 zmm8,ZMMWORD PTR [r14]
  43c8fa:	62 d3 bd 48 1e c9 00 	vpcmpequq k1,zmm8,zmm9
  43c901:	c5 f9 93 f1          	kmovb  esi,k1
  43c905:	83 e6 55             	and    esi,0x55
  43c908:	0f 84 c2 00 00 00    	je     43c9d0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x3d0>
  43c90e:	44 0f b6 e6          	movzx  r12d,sil
  43c912:	31 f6                	xor    esi,esi
  43c914:	f3 41 0f bc f4       	tzcnt  esi,r12d
  43c919:	41 8b 13             	mov    edx,DWORD PTR [r11]
  43c91c:	ff c6                	inc    esi
  43c91e:	48 63 f6             	movsxd rsi,esi
  43c921:	45 8b 52 14          	mov    r10d,DWORD PTR [r10+0x14]
  43c925:	4d 8b 34 f6          	mov    r14,QWORD PTR [r14+rsi*8]
  43c929:	49 89 d4             	mov    r12,rdx
  43c92c:	48 c1 e2 04          	shl    rdx,0x4
  43c930:	49 03 53 08          	add    rdx,QWORD PTR [r11+0x8]
  43c934:	41 ff c4             	inc    r12d
  43c937:	44 89 12             	mov    DWORD PTR [rdx],r10d
  43c93a:	4c 89 72 08          	mov    QWORD PTR [rdx+0x8],r14
  43c93e:	45 89 23             	mov    DWORD PTR [r11],r12d
  43c941:	89 87 b4 00 00 00    	mov    DWORD PTR [rdi+0xb4],eax
  43c947:	48 83 7c 24 e8 04    	cmp    QWORD PTR [rsp-0x18],0x4
  43c94d:	0f 84 4d 01 00 00    	je     43caa0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x4a0>
  43c953:	48 83 7c 24 e8 08    	cmp    QWORD PTR [rsp-0x18],0x8
  43c959:	75 11                	jne    43c96c <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x36c>
  43c95b:	b8 ff ff ff ff       	mov    eax,0xffffffff
  43c960:	f2 49 0f 38 f1 45 00 	crc32  rax,QWORD PTR [r13+0x0]
  43c967:	48 89 44 24 e0       	mov    QWORD PTR [rsp-0x20],rax
  43c96c:	4c 8b 64 24 f8       	mov    r12,QWORD PTR [rsp-0x8]
  43c971:	41 89 ca             	mov    r10d,ecx
  43c974:	4c 23 64 24 e0       	and    r12,QWORD PTR [rsp-0x20]
  43c979:	49 83 e4 fc          	and    r12,0xfffffffffffffffc
  43c97d:	c4 41 79 6e e4       	vmovd  xmm12,r12d
  43c982:	49 8b 75 00          	mov    rsi,QWORD PTR [r13+0x0]
  43c986:	c4 43 19 22 6d 10 01 	vpinsrd xmm13,xmm12,DWORD PTR [r13+0x10],0x1
  43c98d:	4c 89 e2             	mov    rdx,r12
  43c990:	4b 8d 04 52          	lea    rax,[r10+r10*2]
  43c994:	ff c1                	inc    ecx
  43c996:	4d 8d 34 c1          	lea    r14,[r9+rax*8]
  43c99a:	48 c1 e2 04          	shl    rdx,0x4
  43c99e:	44 21 c1             	and    ecx,r8d
  43c9a1:	49 83 c5 18          	add    r13,0x18
  43c9a5:	0f 18 1c 13          	prefetcht2 BYTE PTR [rbx+rdx*1]
  43c9a9:	49 89 36             	mov    QWORD PTR [r14],rsi
  43c9ac:	c4 41 79 d6 6e 10    	vmovq  QWORD PTR [r14+0x10],xmm13
  43c9b2:	89 8f b0 00 00 00    	mov    DWORD PTR [rdi+0xb0],ecx
  43c9b8:	4c 39 6c 24 f0       	cmp    QWORD PTR [rsp-0x10],r13
  43c9bd:	0f 84 3d fd ff ff    	je     43c700 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x100>
  43c9c3:	8b 87 b4 00 00 00    	mov    eax,DWORD PTR [rdi+0xb4]
  43c9c9:	e9 c2 fc ff ff       	jmp    43c690 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x90>
  43c9ce:	66 90                	xchg   ax,ax
  43c9d0:	62 f3 bd 48 1e d7 00 	vpcmpequq k2,zmm8,zmm7
  43c9d7:	c5 79 93 f2          	kmovb  r14d,k2
  43c9db:	41 83 e6 55          	and    r14d,0x55
  43c9df:	0f 85 5c ff ff ff    	jne    43c941 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x341>
  43c9e5:	48 83 c2 04          	add    rdx,0x4
  43c9e9:	48 23 54 24 f8       	and    rdx,QWORD PTR [rsp-0x8]
  43c9ee:	48 89 d6             	mov    rsi,rdx
  43c9f1:	41 89 ce             	mov    r14d,ecx
  43c9f4:	48 c1 e6 04          	shl    rsi,0x4
  43c9f8:	c5 79 6e d2          	vmovd  xmm10,edx
  43c9fc:	0f 18 1c 33          	prefetcht2 BYTE PTR [rbx+rsi*1]
  43ca00:	c4 43 29 22 5a 14 01 	vpinsrd xmm11,xmm10,DWORD PTR [r10+0x14],0x1
  43ca07:	4b 8d 34 76          	lea    rsi,[r14+r14*2]
  43ca0b:	ff c1                	inc    ecx
  43ca0d:	4d 8d 34 f1          	lea    r14,[r9+rsi*8]
  43ca11:	44 21 c1             	and    ecx,r8d
  43ca14:	4d 89 26             	mov    QWORD PTR [r14],r12
  43ca17:	c4 41 79 d6 5e 10    	vmovq  QWORD PTR [r14+0x10],xmm11
  43ca1d:	89 8f b0 00 00 00    	mov    DWORD PTR [rdi+0xb0],ecx
  43ca23:	89 87 b4 00 00 00    	mov    DWORD PTR [rdi+0xb4],eax
  43ca29:	e9 62 fc ff ff       	jmp    43c690 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x90>
  43ca2e:	66 90                	xchg   ax,ax
  43ca30:	8b 59 10             	mov    ebx,DWORD PTR [rcx+0x10]
  43ca33:	62 d2 fd 48 7c cf    	vpbroadcastq zmm1,r15
  43ca39:	49 89 d9             	mov    r9,rbx
  43ca3c:	49 c1 e1 04          	shl    r9,0x4
  43ca40:	4d 01 d1             	add    r9,r10
  43ca43:	62 d1 fd 48 6f 19    	vmovdqa64 zmm3,ZMMWORD PTR [r9]
  43ca49:	62 f3 e5 48 1e d9 00 	vpcmpequq k3,zmm3,zmm1
  43ca50:	c5 f9 93 d3          	kmovb  edx,k3
  43ca54:	83 e2 55             	and    edx,0x55
  43ca57:	0f 84 b3 fd ff ff    	je     43c810 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x210>
  43ca5d:	44 0f b6 fa          	movzx  r15d,dl
  43ca61:	31 d2                	xor    edx,edx
  43ca63:	f3 41 0f bc d7       	tzcnt  edx,r15d
  43ca68:	41 8b 1b             	mov    ebx,DWORD PTR [r11]
  43ca6b:	ff c2                	inc    edx
  43ca6d:	48 63 d2             	movsxd rdx,edx
  43ca70:	8b 49 14             	mov    ecx,DWORD PTR [rcx+0x14]
  43ca73:	4d 8b 0c d1          	mov    r9,QWORD PTR [r9+rdx*8]
  43ca77:	49 89 df             	mov    r15,rbx
  43ca7a:	48 c1 e3 04          	shl    rbx,0x4
  43ca7e:	49 03 5b 08          	add    rbx,QWORD PTR [r11+0x8]
  43ca82:	41 ff c7             	inc    r15d
  43ca85:	89 0b                	mov    DWORD PTR [rbx],ecx
  43ca87:	4c 89 4b 08          	mov    QWORD PTR [rbx+0x8],r9
  43ca8b:	45 89 3b             	mov    DWORD PTR [r11],r15d
  43ca8e:	89 87 b4 00 00 00    	mov    DWORD PTR [rdi+0xb4],eax
  43ca94:	e9 4b fd ff ff       	jmp    43c7e4 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1e4>
  43ca99:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  43caa0:	be ff ff ff ff       	mov    esi,0xffffffff
  43caa5:	f2 41 0f 38 f1 75 00 	crc32  esi,DWORD PTR [r13+0x0]
  43caac:	41 89 f6             	mov    r14d,esi
  43caaf:	4c 89 74 24 e0       	mov    QWORD PTR [rsp-0x20],r14
  43cab4:	e9 b3 fe ff ff       	jmp    43c96c <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x36c>
  43cab9:	90                   	nop
  43caba:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

000000000043cac0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)>:
  43cac0:	48 89 f9             	mov    rcx,rdi
  43cac3:	44 8b 99 b0 00 00 00 	mov    r11d,DWORD PTR [rcx+0xb0]
  43caca:	8b 7f 78             	mov    edi,DWORD PTR [rdi+0x78]
  43cacd:	44 2b 99 b4 00 00 00 	sub    r11d,DWORD PTR [rcx+0xb4]
  43cad4:	41 21 fb             	and    r11d,edi
  43cad7:	4d 85 db             	test   r11,r11
  43cada:	0f 84 c3 01 00 00    	je     43cca3 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1e3>
  43cae0:	55                   	push   rbp
  43cae1:	49 89 f1             	mov    r9,rsi
  43cae4:	c5 e9 ef d2          	vpxor  xmm2,xmm2,xmm2
  43cae8:	48 89 e5             	mov    rbp,rsp
  43caeb:	41 57                	push   r15
  43caed:	41 56                	push   r14
  43caef:	41 55                	push   r13
  43caf1:	41 54                	push   r12
  43caf3:	53                   	push   rbx
  43caf4:	48 83 e4 c0          	and    rsp,0xffffffffffffffc0
  43caf8:	8b 05 b6 01 05 00    	mov    eax,DWORD PTR [rip+0x501b6]        # 48ccb4 <kmercounter::config+0x114>
  43cafe:	4c 8b 05 2b 03 05 00 	mov    r8,QWORD PTR [rip+0x5032b]        # 48ce30 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43cb05:	89 44 24 fc          	mov    DWORD PTR [rsp-0x4],eax
  43cb09:	0f b6 1d a4 02 05 00 	movzx  ebx,BYTE PTR [rip+0x502a4]        # 48cdb4 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_exists_>
  43cb10:	4c 8b 15 a1 02 05 00 	mov    r10,QWORD PTR [rip+0x502a1]        # 48cdb8 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_>
  43cb17:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  43cb1e:	00 00 
  43cb20:	8b 54 24 fc          	mov    edx,DWORD PTR [rsp-0x4]
  43cb24:	41 39 11             	cmp    DWORD PTR [r9],edx
  43cb27:	0f 83 6e 01 00 00    	jae    43cc9b <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1db>
  43cb2d:	48 8b b1 a0 00 00 00 	mov    rsi,QWORD PTR [rcx+0xa0]
  43cb34:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  43cb38:	8b 81 b4 00 00 00    	mov    eax,DWORD PTR [rcx+0xb4]
  43cb3e:	44 8d 60 08          	lea    r12d,[rax+0x8]
  43cb42:	41 21 fc             	and    r12d,edi
  43cb45:	41 89 c7             	mov    r15d,eax
  43cb48:	4f 8d 2c 64          	lea    r13,[r12+r12*2]
  43cb4c:	4b 8d 14 7f          	lea    rdx,[r15+r15*2]
  43cb50:	46 8b 74 ee 10       	mov    r14d,DWORD PTR [rsi+r13*8+0x10]
  43cb55:	4c 8d 24 d6          	lea    r12,[rsi+rdx*8]
  43cb59:	4d 8b 2c 24          	mov    r13,QWORD PTR [r12]
  43cb5d:	49 c1 e6 04          	shl    r14,0x4
  43cb61:	ff c0                	inc    eax
  43cb63:	21 f8                	and    eax,edi
  43cb65:	43 0f 18 0c 30       	prefetcht0 BYTE PTR [r8+r14*1]
  43cb6a:	4c 3b a9 90 00 00 00 	cmp    r13,QWORD PTR [rcx+0x90]
  43cb71:	75 35                	jne    43cba8 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xe8>
  43cb73:	84 db                	test   bl,bl
  43cb75:	74 20                	je     43cb97 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xd7>
  43cb77:	45 8b 39             	mov    r15d,DWORD PTR [r9]
  43cb7a:	45 8b 64 24 14       	mov    r12d,DWORD PTR [r12+0x14]
  43cb7f:	4d 89 fd             	mov    r13,r15
  43cb82:	49 c1 e7 04          	shl    r15,0x4
  43cb86:	4d 03 79 08          	add    r15,QWORD PTR [r9+0x8]
  43cb8a:	41 ff c5             	inc    r13d
  43cb8d:	45 89 27             	mov    DWORD PTR [r15],r12d
  43cb90:	4d 89 57 08          	mov    QWORD PTR [r15+0x8],r10
  43cb94:	45 89 29             	mov    DWORD PTR [r9],r13d
  43cb97:	89 81 b4 00 00 00    	mov    DWORD PTR [rcx+0xb4],eax
  43cb9d:	4d 85 d2             	test   r10,r10
  43cba0:	75 96                	jne    43cb38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x78>
  43cba2:	eb 6a                	jmp    43cc0e <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x14e>
  43cba4:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  43cba8:	45 8b 7c 24 10       	mov    r15d,DWORD PTR [r12+0x10]
  43cbad:	62 d2 fd 48 7c cd    	vpbroadcastq zmm1,r13
  43cbb3:	4d 89 fe             	mov    r14,r15
  43cbb6:	49 c1 e6 04          	shl    r14,0x4
  43cbba:	4d 01 c6             	add    r14,r8
  43cbbd:	62 d1 fd 48 6f 06    	vmovdqa64 zmm0,ZMMWORD PTR [r14]
  43cbc3:	62 f3 fd 48 1e c1 00 	vpcmpequq k0,zmm0,zmm1
  43cbca:	c5 f9 93 d0          	kmovb  edx,k0
  43cbce:	83 e2 55             	and    edx,0x55
  43cbd1:	74 5d                	je     43cc30 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x170>
  43cbd3:	0f b6 f2             	movzx  esi,dl
  43cbd6:	45 31 ff             	xor    r15d,r15d
  43cbd9:	f3 44 0f bc fe       	tzcnt  r15d,esi
  43cbde:	41 ff c7             	inc    r15d
  43cbe1:	41 8b 31             	mov    esi,DWORD PTR [r9]
  43cbe4:	49 63 d7             	movsxd rdx,r15d
  43cbe7:	45 8b 64 24 14       	mov    r12d,DWORD PTR [r12+0x14]
  43cbec:	4d 8b 34 d6          	mov    r14,QWORD PTR [r14+rdx*8]
  43cbf0:	49 89 f5             	mov    r13,rsi
  43cbf3:	48 c1 e6 04          	shl    rsi,0x4
  43cbf7:	49 03 71 08          	add    rsi,QWORD PTR [r9+0x8]
  43cbfb:	41 ff c5             	inc    r13d
  43cbfe:	44 89 26             	mov    DWORD PTR [rsi],r12d
  43cc01:	4c 89 76 08          	mov    QWORD PTR [rsi+0x8],r14
  43cc05:	45 89 29             	mov    DWORD PTR [r9],r13d
  43cc08:	89 81 b4 00 00 00    	mov    DWORD PTR [rcx+0xb4],eax
  43cc0e:	49 ff cb             	dec    r11
  43cc11:	0f 85 09 ff ff ff    	jne    43cb20 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x60>
  43cc17:	c5 f8 77             	vzeroupper 
  43cc1a:	45 31 db             	xor    r11d,r11d
  43cc1d:	48 8d 65 d8          	lea    rsp,[rbp-0x28]
  43cc21:	4c 89 d8             	mov    rax,r11
  43cc24:	5b                   	pop    rbx
  43cc25:	41 5c                	pop    r12
  43cc27:	41 5d                	pop    r13
  43cc29:	41 5e                	pop    r14
  43cc2b:	41 5f                	pop    r15
  43cc2d:	5d                   	pop    rbp
  43cc2e:	c3                   	ret    
  43cc2f:	90                   	nop
  43cc30:	62 f3 fd 48 1e ca 00 	vpcmpequq k1,zmm0,zmm2
  43cc37:	c5 79 93 f1          	kmovb  r14d,k1
  43cc3b:	41 83 e6 55          	and    r14d,0x55
  43cc3f:	75 c7                	jne    43cc08 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x148>
  43cc41:	49 8d 57 04          	lea    rdx,[r15+0x4]
  43cc45:	4c 8b b9 88 00 00 00 	mov    r15,QWORD PTR [rcx+0x88]
  43cc4c:	49 ff cf             	dec    r15
  43cc4f:	49 21 d7             	and    r15,rdx
  43cc52:	4d 89 fe             	mov    r14,r15
  43cc55:	49 c1 e6 04          	shl    r14,0x4
  43cc59:	43 0f 18 1c 30       	prefetcht2 BYTE PTR [r8+r14*1]
  43cc5e:	44 8b b1 b0 00 00 00 	mov    r14d,DWORD PTR [rcx+0xb0]
  43cc65:	c4 c1 79 6e df       	vmovd  xmm3,r15d
  43cc6a:	4c 89 f2             	mov    rdx,r14
  43cc6d:	c4 c3 61 22 64 24 14 	vpinsrd xmm4,xmm3,DWORD PTR [r12+0x14],0x1
  43cc74:	01 
  43cc75:	4f 8d 34 76          	lea    r14,[r14+r14*2]
  43cc79:	ff c2                	inc    edx
  43cc7b:	4e 8d 34 f6          	lea    r14,[rsi+r14*8]
  43cc7f:	21 fa                	and    edx,edi
  43cc81:	4d 89 2e             	mov    QWORD PTR [r14],r13
  43cc84:	c4 c1 79 d6 66 10    	vmovq  QWORD PTR [r14+0x10],xmm4
  43cc8a:	89 91 b0 00 00 00    	mov    DWORD PTR [rcx+0xb0],edx
  43cc90:	89 81 b4 00 00 00    	mov    DWORD PTR [rcx+0xb4],eax
  43cc96:	e9 9d fe ff ff       	jmp    43cb38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x78>
  43cc9b:	c5 f8 77             	vzeroupper 
  43cc9e:	e9 7a ff ff ff       	jmp    43cc1d <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::flush_find_queue(std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x15d>
  43cca3:	31 c0                	xor    eax,eax
  43cca5:	c3                   	ret    
  43cca6:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
  43ccad:	00 00 00 

