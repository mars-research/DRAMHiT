000000000043db30 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)>:
  43db30:	push   %rbp
  43db31:	mov    %rsp,%rbp
  43db34:	push   %r15
  43db36:	mov    %rdi,%r15
  43db39:	push   %r14
  43db3b:	push   %r13
  43db3d:	push   %r12
  43db3f:	push   %rbx
  43db40:	and    $0xffffffffffffffc0,%rsp
  43db44:	mov    %rdx,-0x18(%rsp)
  43db49:	mov    0xb0(%rdi),%ecx
  43db4f:	mov    0xb4(%rdi),%eax
  43db55:	mov    0x8(%rsi),%rbx
  43db59:	mov    (%rsi),%r13
  43db5c:	mov    0x78(%rdi),%edi
  43db5f:	mov    0x6c(%r15),%r8d
  43db63:	mov    %ecx,%r10d
  43db66:	lea    (%rbx,%rbx,2),%rsi
  43db6a:	sub    %eax,%r10d
  43db6d:	lea    0x0(%r13,%rsi,8),%r11
  43db72:	and    %edi,%r10d
  43db75:	lea    -0x1(%r8),%r9d
  43db79:	mov    %rbx,-0x10(%rsp)
  43db7e:	mov    %r11,-0x8(%rsp)
  43db83:	cmp    %r9d,%r10d
  43db86:	jb     43dd87 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x257>
  43db8c:	shl    $0x5,%r8
  43db90:	mov    0xa0(%r15),%r9
  43db97:	mov    0x8(%rdx),%r14
  43db9b:	dec    %r8
  43db9e:	shl    $0x5,%rax
  43dba2:	shl    $0x5,%rcx
  43dba6:	cmp    %r11,%r13
  43dba9:	je     43dd2e <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1fe>
  43dbaf:	mov    $0x55,%r12d
  43dbb5:	xor    %r11d,%r11d
  43dbb8:	mov    0x53279(%rip),%r10        # 490e38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43dbbf:	mov    %r15,-0x20(%rsp)
  43dbc4:	kmovb  %r12d,%k2
  43dbc9:	vpxor  %xmm8,%xmm8,%xmm8
  43dbce:	mov    0x80(%r15),%r12d
  43dbd5:	mov    $0xffffffff,%ebx
  43dbda:	mov    %r11d,%r15d
  43dbdd:	nopl   (%rax)
  43dbe0:	lea    0x100(%rax),%rsi
  43dbe7:	and    %r8,%rsi
  43dbea:	mov    0x10(%r9,%rsi,1),%edx
  43dbef:	shl    $0x4,%rdx
  43dbf3:	prefetcht0 (%r10,%rdx,1)
  43dbf8:	lea    (%r9,%rax,1),%rdx
  43dbfc:	mov    0x10(%rdx),%edi
  43dbff:	add    $0x20,%rax
  43dc03:	shl    $0x4,%rdi
  43dc07:	vmovdqa64 (%r10,%rdi,1),%zmm7
  43dc0e:	and    %r8,%rax
  43dc11:	vpcmpequq (%rdx){1to8},%zmm7,%k4{%k2}
  43dc18:	kmovb  %k4,%r11d
  43dc1c:	test   %r11b,%r11b
  43dc1f:	je     43dca8 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x178>
  43dc25:	jmp    43dd60 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x230>
  43dc2a:	nopw   0x0(%rax,%rax,1)
  43dc30:	mov    %rbx,%r11
  43dc33:	crc32q 0x18(%rdx),%r11
  43dc3a:	mov    %r12d,%edi
  43dc3d:	and    %r11d,%edi
  43dc40:	vmovd  %edi,%xmm9
  43dc44:	vpinsrd $0x1,0x14(%rdx),%xmm9,%xmm10
  43dc4b:	shl    $0x4,%rdi
  43dc4f:	prefetcht2 (%r10,%rdi,1)
  43dc54:	mov    %r11,0x18(%rsi)
  43dc58:	mov    (%rdx),%r11
  43dc5b:	lea    0x100(%rax),%rdx
  43dc62:	vmovq  %xmm10,0x10(%rsi)
  43dc67:	and    %r8,%rdx
  43dc6a:	mov    %r11,(%rsi)
  43dc6d:	mov    0x10(%r9,%rdx,1),%esi
  43dc72:	lea    (%r9,%rax,1),%rdx
  43dc76:	mov    0x10(%rdx),%edi
  43dc79:	shl    $0x4,%rsi
  43dc7d:	shl    $0x4,%rdi
  43dc81:	add    $0x20,%rax
  43dc85:	vmovdqa64 (%r10,%rdi,1),%zmm7
  43dc8c:	and    %r8,%rax
  43dc8f:	vpcmpequq (%rdx){1to8},%zmm7,%k3{%k2}
  43dc96:	prefetcht0 (%r10,%rsi,1)
  43dc9b:	kmovb  %k3,%r11d
  43dc9f:	test   %r11b,%r11b
  43dca2:	jne    43dd60 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x230>
  43dca8:	vpcmpequq %zmm8,%zmm7,%k1{%k2}
  43dcaf:	lea    (%r9,%rcx,1),%rsi
  43dcb3:	mov    %rcx,%rdi
  43dcb6:	lea    0x20(%rcx),%rcx
  43dcba:	and    %r8,%rcx
  43dcbd:	kortestb %k1,%k1
  43dcc1:	je     43dc30 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x100>
  43dcc7:	inc    %r15d
  43dcca:	mov    %rdi,%rcx
  43dccd:	mov    0x0(%r13),%rdi
  43dcd1:	mov    %rbx,%rsi
  43dcd4:	crc32  %rdi,%rsi
  43dcda:	mov    %r12d,%r11d
  43dcdd:	and    %esi,%r11d
  43dce0:	mov    %r11d,%edx
  43dce3:	vmovd  %r11d,%xmm12
  43dce8:	vpinsrd $0x1,0x10(%r13),%xmm12,%xmm13
  43dcef:	shl    $0x4,%rdx
  43dcf3:	prefetcht2 (%r10,%rdx,1)
  43dcf8:	add    $0x18,%r13
  43dcfc:	lea    (%r9,%rcx,1),%rdx
  43dd00:	add    $0x20,%rcx
  43dd04:	mov    %rdi,(%rdx)
  43dd07:	mov    %rsi,0x18(%rdx)
  43dd0b:	vmovq  %xmm13,0x10(%rdx)
  43dd10:	and    %r8,%rcx
  43dd13:	cmp    -0x8(%rsp),%r13
  43dd18:	jne    43dbe0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xb0>
  43dd1e:	mov    %r15d,%ebx
  43dd21:	sub    %rbx,-0x10(%rsp)
  43dd26:	mov    -0x20(%rsp),%r15
  43dd2b:	vzeroupper 
  43dd2e:	vmovq  %rcx,%xmm14
  43dd33:	vpinsrq $0x1,%rax,%xmm14,%xmm15
  43dd39:	mov    -0x10(%rsp),%ecx
  43dd3d:	mov    -0x18(%rsp),%rax
  43dd42:	vpsrlq $0x5,%xmm15,%xmm2
  43dd48:	vpmovqd %xmm2,0xb0(%r15)
  43dd4f:	add    %ecx,(%rax)
  43dd51:	lea    -0x28(%rbp),%rsp
  43dd55:	pop    %rbx
  43dd56:	pop    %r12
  43dd58:	pop    %r13
  43dd5a:	pop    %r14
  43dd5c:	pop    %r15
  43dd5e:	pop    %rbp
  43dd5f:	ret    
  43dd60:	kmovb  %r11d,%k5
  43dd65:	mov    0x14(%rdx),%r11d
  43dd69:	kshiftlb $0x1,%k5,%k6
  43dd6f:	vpcompressq %zmm7,%zmm0{%k6}{z}
  43dd75:	mov    %r11d,(%r14)
  43dd78:	vmovq  %xmm0,0x8(%r14)
  43dd7e:	add    $0x10,%r14
  43dd82:	jmp    43dccd <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x19d>
  43dd87:	cmp    -0x8(%rsp),%r13
  43dd8c:	je     43dd51 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x221>
  43dd8e:	mov    0x88(%r15),%rbx
  43dd95:	mov    0x60(%r15),%r8
  43dd99:	dec    %rbx
  43dd9c:	mov    %rbx,-0x28(%rsp)
  43dda1:	mov    %r8,-0x10(%rsp)
  43dda6:	mov    %r14,-0x20(%rsp)
  43ddab:	mov    0x53086(%rip),%r11        # 490e38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43ddb2:	mov    0x5306f(%rip),%r12        # 490e28 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_>
  43ddb9:	mov    0xa0(%r15),%r10
  43ddc0:	mov    -0x18(%rsp),%rbx
  43ddc5:	mov    %ecx,%r9d
  43ddc8:	vpxor  %xmm2,%xmm2,%xmm2
  43ddcc:	kmovb  0x5304c(%rip),%k0        # 490e20 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_exists_>
  43ddd4:	jmp    43de5b <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x32b>
  43ddd9:	cmpq   $0x8,-0x10(%rsp)
  43dddf:	jne    43ddf2 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2c2>
  43dde1:	mov    $0xffffffff,%eax
  43dde6:	crc32q 0x0(%r13),%rax
  43dded:	mov    %rax,-0x30(%rsp)
  43ddf2:	mov    -0x30(%rsp),%r14
  43ddf7:	mov    -0x28(%rsp),%r9
  43ddfc:	mov    %ecx,%eax
  43ddfe:	and    %r14,%r9
  43de01:	and    $0xfffffffffffffffc,%r9
  43de05:	vmovd  %r9d,%xmm5
  43de0a:	mov    0x0(%r13),%rdx
  43de0e:	vpinsrd $0x1,0x10(%r13),%xmm5,%xmm4
  43de15:	mov    %r9,%rsi
  43de18:	shl    $0x5,%rax
  43de1c:	lea    0x1(%rcx),%r9d
  43de20:	add    %r10,%rax
  43de23:	shl    $0x4,%rsi
  43de27:	and    %edi,%r9d
  43de2a:	add    $0x18,%r13
  43de2e:	prefetcht2 (%r11,%rsi,1)
  43de33:	mov    %rdx,(%rax)
  43de36:	mov    %r14,0x18(%rax)
  43de3a:	vmovq  %xmm4,0x10(%rax)
  43de3f:	mov    %r9d,0xb0(%r15)
  43de46:	cmp    %r13,-0x8(%rsp)
  43de4b:	je     43e017 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x4e7>
  43de51:	mov    0xb4(%r15),%eax
  43de58:	mov    %r9d,%ecx
  43de5b:	sub    %eax,%r9d
  43de5e:	and    %edi,%r9d
  43de61:	cmp    %r9d,%edi
  43de64:	jbe    43df22 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x3f2>
  43de6a:	cmpq   $0x4,-0x10(%rsp)
  43de70:	jne    43ddd9 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2a9>
  43de76:	mov    $0xffffffff,%edx
  43de7b:	crc32l 0x0(%r13),%edx
  43de82:	mov    %edx,%r8d
  43de85:	mov    %r8,-0x30(%rsp)
  43de8a:	jmp    43ddf2 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2c2>
  43de8f:	vpcmpequq %zmm2,%zmm0,%k7
  43de96:	kmovb  %k7,%r14d
  43de9a:	and    $0x55,%r14d
  43de9e:	jne    43dfee <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x4be>
  43dea4:	cmpq   $0x4,-0x10(%rsp)
  43deaa:	mov    0x18(%rdx),%r8
  43deae:	je     43dffe <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x4ce>
  43deb4:	mov    -0x20(%rsp),%r14
  43deb9:	mov    $0xffffffff,%esi
  43debe:	cmpq   $0x8,-0x10(%rsp)
  43dec4:	crc32  %r8,%rsi
  43deca:	cmove  %rsi,%r14
  43dece:	mov    %r14,-0x20(%rsp)
  43ded3:	mov    -0x28(%rsp),%r8
  43ded8:	mov    %ecx,%esi
  43deda:	and    %r14,%r8
  43dedd:	and    $0xfffffffffffffffc,%r8
  43dee1:	shl    $0x5,%rsi
  43dee5:	add    %r10,%rsi
  43dee8:	vmovd  %r8d,%xmm6
  43deed:	mov    %r14,0x18(%rsi)
  43def1:	vpinsrd $0x1,0x14(%rdx),%xmm6,%xmm3
  43def8:	mov    %r8,%r14
  43defb:	inc    %ecx
  43defd:	inc    %eax
  43deff:	shl    $0x4,%r14
  43df03:	and    %edi,%ecx
  43df05:	and    %edi,%eax
  43df07:	prefetcht2 (%r11,%r14,1)
  43df0c:	mov    %r9,(%rsi)
  43df0f:	vmovq  %xmm3,0x10(%rsi)
  43df14:	mov    %ecx,0xb0(%r15)
  43df1b:	mov    %eax,0xb4(%r15)
  43df22:	lea    0x8(%rax),%edx
  43df25:	and    %edi,%edx
  43df27:	shl    $0x5,%rdx
  43df2b:	mov    0x10(%r10,%rdx,1),%r14d
  43df30:	mov    %eax,%edx
  43df32:	shl    $0x5,%rdx
  43df36:	add    %r10,%rdx
  43df39:	mov    (%rdx),%r9
  43df3c:	shl    $0x4,%r14
  43df40:	prefetcht0 (%r11,%r14,1)
  43df45:	cmp    0x90(%r15),%r9
  43df4c:	jne    43df90 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x460>
  43df4e:	kortestb %k0,%k0
  43df52:	je     43df72 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x442>
  43df54:	mov    (%rbx),%r9d
  43df57:	mov    0x14(%rdx),%esi
  43df5a:	mov    %r9,%r14
  43df5d:	shl    $0x4,%r9
  43df61:	add    0x8(%rbx),%r9
  43df65:	inc    %r14d
  43df68:	mov    %esi,(%r9)
  43df6b:	mov    %r12,0x8(%r9)
  43df6f:	mov    %r14d,(%rbx)
  43df72:	inc    %eax
  43df74:	and    %edi,%eax
  43df76:	mov    %eax,0xb4(%r15)
  43df7d:	test   %r12,%r12
  43df80:	jne    43df22 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x3f2>
  43df82:	jmp    43de6a <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x33a>
  43df87:	nopw   0x0(%rax,%rax,1)
  43df90:	mov    0x10(%rdx),%r8d
  43df94:	vpbroadcastq %r9,%zmm1
  43df9a:	shl    $0x4,%r8
  43df9e:	add    %r11,%r8
  43dfa1:	vmovdqa64 (%r8),%zmm0
  43dfa7:	vpcmpequq %zmm1,%zmm0,%k6
  43dfae:	kmovb  %k6,%esi
  43dfb2:	and    $0x55,%esi
  43dfb5:	je     43de8f <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x35f>
  43dfbb:	movzbl %sil,%r9d
  43dfbf:	xor    %esi,%esi
  43dfc1:	tzcnt  %r9d,%esi
  43dfc6:	mov    (%rbx),%r9d
  43dfc9:	mov    0x14(%rdx),%edx
  43dfcc:	mov    %r9,%r14
  43dfcf:	shl    $0x4,%r9
  43dfd3:	add    0x8(%rbx),%r9
  43dfd7:	lea    0x1(%rsi),%esi
  43dfda:	mov    %edx,(%r9)
  43dfdd:	movslq %esi,%rdx
  43dfe0:	mov    (%r8,%rdx,8),%r8
  43dfe4:	inc    %r14d
  43dfe7:	mov    %r8,0x8(%r9)
  43dfeb:	mov    %r14d,(%rbx)
  43dfee:	inc    %eax
  43dff0:	and    %edi,%eax
  43dff2:	mov    %eax,0xb4(%r15)
  43dff9:	jmp    43de6a <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x33a>
  43dffe:	mov    $0xffffffff,%r14d
  43e004:	crc32  %r8d,%r14d
  43e00a:	mov    %r14d,%r14d
  43e00d:	mov    %r14,-0x20(%rsp)
  43e012:	jmp    43ded3 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x3a3>
  43e017:	vzeroupper 
  43e01a:	jmp    43dd51 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x221>
  43e01f:	nop
