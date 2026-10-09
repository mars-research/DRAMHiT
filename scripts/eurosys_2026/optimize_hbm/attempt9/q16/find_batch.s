000000000043db10 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)>:
  43db10:	push   %rbp
  43db11:	mov    %rsp,%rbp
  43db14:	push   %r15
  43db16:	mov    %rdx,%r15
  43db19:	push   %r14
  43db1b:	push   %r13
  43db1d:	push   %r12
  43db1f:	push   %rbx
  43db20:	mov    %rdi,%rbx
  43db23:	and    $0xffffffffffffffc0,%rsp
  43db27:	mov    %rdi,-0x20(%rsp)
  43db2c:	mov    %rdx,-0x28(%rsp)
  43db31:	mov    0xb0(%rdi),%ecx
  43db37:	mov    0xb4(%rdi),%eax
  43db3d:	mov    0x8(%rsi),%r14
  43db41:	mov    (%rsi),%r13
  43db44:	mov    0x78(%rdi),%edi
  43db47:	mov    0x6c(%rbx),%r9d
  43db4b:	mov    %ecx,%edx
  43db4d:	lea    (%r14,%r14,2),%rsi
  43db51:	sub    %eax,%edx
  43db53:	lea    0x0(%r13,%rsi,8),%r10
  43db58:	and    %edi,%edx
  43db5a:	lea    -0x1(%r9),%r8d
  43db5e:	mov    %r14,-0x18(%rsp)
  43db63:	mov    %r10,-0x8(%rsp)
  43db68:	cmp    %r8d,%edx
  43db6b:	jb     43dd19 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x209>
  43db71:	shl    $0x4,%r9
  43db75:	mov    %ecx,%edx
  43db77:	lea    -0x1(%r9),%rdi
  43db7b:	mov    0xa0(%rbx),%r8
  43db82:	mov    0x8(%r15),%r14
  43db86:	mov    0x80(%rbx),%r9d
  43db8d:	shl    $0x4,%rax
  43db91:	shl    $0x4,%rdx
  43db95:	cmp    %r10,%r13
  43db98:	je     43dcd0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1c0>
  43db9e:	mov    $0x55,%r15d
  43dba4:	movl   $0x0,-0x10(%rsp)
  43dbac:	mov    0x54285(%rip),%r10        # 491e38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43dbb3:	vpxor  %xmm5,%xmm5,%xmm5
  43dbb7:	mov    $0xffffffff,%r12d
  43dbbd:	kmovb  %r15d,%k4
  43dbc2:	jmp    43dc06 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xf6>
  43dbc4:	nopl   0x0(%rax)
  43dbc8:	vpcmpequq %zmm5,%zmm8,%k6{%k4}
  43dbcf:	kortestb %k6,%k6
  43dbd3:	jne    43dd10 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x200>
  43dbd9:	mov    %r12,%r15
  43dbdc:	crc32  %rcx,%r15
  43dbe2:	mov    %r9d,%ecx
  43dbe5:	and    %r15d,%ecx
  43dbe8:	shl    $0x4,%rcx
  43dbec:	vmovd  %r15d,%xmm10
  43dbf1:	vpinsrd $0x1,0xc(%rsi),%xmm10,%xmm11
  43dbf8:	prefetcht2 (%r10,%rcx,1)
  43dbfd:	mov    %rbx,(%r11)
  43dc00:	vmovq  %xmm11,0x8(%r11)
  43dc06:	lea    0x80(%rax),%r11
  43dc0d:	and    %rdi,%r11
  43dc10:	mov    %r9d,%ecx
  43dc13:	and    0x8(%r8,%r11,1),%ecx
  43dc18:	mov    %rcx,%rsi
  43dc1b:	shl    $0x4,%rsi
  43dc1f:	prefetcht0 (%r10,%rsi,1)
  43dc24:	lea    (%r8,%rax,1),%rsi
  43dc28:	mov    0x8(%rsi),%ecx
  43dc2b:	mov    %r9d,%ebx
  43dc2e:	and    %ecx,%ebx
  43dc30:	shl    $0x4,%rbx
  43dc34:	vmovdqa64 (%r10,%rbx,1),%zmm8
  43dc3b:	mov    (%rsi),%rbx
  43dc3e:	add    $0x10,%rax
  43dc42:	vpbroadcastq %rbx,%zmm9
  43dc48:	vpcmpequq %zmm9,%zmm8,%k5{%k4}
  43dc4f:	lea    (%r8,%rdx,1),%r11
  43dc53:	add    $0x10,%rdx
  43dc57:	and    %rdi,%rax
  43dc5a:	and    %rdi,%rdx
  43dc5d:	kortestb %k5,%k5
  43dc61:	je     43dbc8 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xb8>
  43dc67:	mov    0xc(%rsi),%esi
  43dc6a:	kshiftlb $0x1,%k5,%k7
  43dc70:	vpcompressq %zmm8,%zmm0{%k7}{z}
  43dc76:	mov    %esi,(%r14)
  43dc79:	vmovq  %xmm0,0x8(%r14)
  43dc7f:	add    $0x10,%r14
  43dc83:	mov    0x0(%r13),%rbx
  43dc87:	mov    %r12,%r15
  43dc8a:	crc32  %rbx,%r15
  43dc90:	mov    %r9d,%ecx
  43dc93:	vmovd  %r15d,%xmm13
  43dc98:	vpinsrd $0x1,0x10(%r13),%xmm13,%xmm14
  43dc9f:	and    %r15d,%ecx
  43dca2:	shl    $0x4,%rcx
  43dca6:	add    $0x18,%r13
  43dcaa:	prefetcht2 (%r10,%rcx,1)
  43dcaf:	mov    %rbx,(%r11)
  43dcb2:	vmovq  %xmm14,0x8(%r11)
  43dcb8:	cmp    -0x8(%rsp),%r13
  43dcbd:	jne    43dc06 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xf6>
  43dcc3:	mov    -0x10(%rsp),%r13d
  43dcc8:	sub    %r13,-0x18(%rsp)
  43dccd:	vzeroupper 
  43dcd0:	vmovq  %rdx,%xmm15
  43dcd5:	vpinsrq $0x1,%rax,%xmm15,%xmm2
  43dcdb:	mov    -0x20(%rsp),%rax
  43dce0:	mov    -0x28(%rsp),%r8
  43dce5:	mov    -0x18(%rsp),%edi
  43dce9:	vpsrlq $0x4,%xmm2,%xmm1
  43dcee:	vpmovqd %xmm1,0xb0(%rax)
  43dcf5:	add    %edi,(%r8)
  43dcf8:	lea    -0x28(%rbp),%rsp
  43dcfc:	pop    %rbx
  43dcfd:	pop    %r12
  43dcff:	pop    %r13
  43dd01:	pop    %r14
  43dd03:	pop    %r15
  43dd05:	pop    %rbp
  43dd06:	ret    
  43dd07:	nopw   0x0(%rax,%rax,1)
  43dd10:	incl   -0x10(%rsp)
  43dd14:	jmp    43dc83 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x173>
  43dd19:	cmp    -0x8(%rsp),%r13
  43dd1e:	je     43dcf8 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1e8>
  43dd20:	mov    %rbx,%r8
  43dd23:	mov    0x88(%r8),%rsi
  43dd2a:	mov    0x60(%r8),%r14
  43dd2e:	mov    %rsi,-0x18(%rsp)
  43dd33:	mov    %r14,-0x10(%rsp)
  43dd38:	movzbl 0x540e0(%rip),%r11d        # 491e20 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_exists_>
  43dd40:	mov    -0x18(%rsp),%r14
  43dd45:	mov    $0x55,%r10d
  43dd4b:	dec    %r14
  43dd4e:	mov    %r14,-0x18(%rsp)
  43dd53:	mov    0x540de(%rip),%r12        # 491e38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43dd5a:	mov    0x540c7(%rip),%rbx        # 491e28 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_>
  43dd61:	mov    0xa0(%r8),%r9
  43dd68:	mov    %ecx,%edx
  43dd6a:	vpxor  %xmm2,%xmm2,%xmm2
  43dd6e:	kmovb  %r10d,%k1
  43dd73:	kmovb  %r11d,%k2
  43dd78:	jmp    43dde7 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2d7>
  43dd7a:	cmpq   $0x8,-0x10(%rsp)
  43dd80:	je     43df89 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x479>
  43dd86:	mov    -0x30(%rsp),%r11d
  43dd8b:	mov    -0x18(%rsp),%r14
  43dd90:	vmovd  %r11d,%xmm6
  43dd95:	and    -0x30(%rsp),%r14
  43dd9a:	mov    %ecx,%esi
  43dd9c:	vpinsrd $0x1,0x10(%r13),%xmm6,%xmm4
  43dda3:	mov    0x0(%r13),%r10
  43dda7:	and    $0xfffffffffffffffc,%r14
  43ddab:	shl    $0x4,%rsi
  43ddaf:	lea    0x1(%rcx),%edx
  43ddb2:	add    %r9,%rsi
  43ddb5:	shl    $0x4,%r14
  43ddb9:	and    %edi,%edx
  43ddbb:	add    $0x18,%r13
  43ddbf:	prefetcht2 (%r12,%r14,1)
  43ddc4:	mov    %r10,(%rsi)
  43ddc7:	vmovq  %xmm4,0x8(%rsi)
  43ddcc:	mov    %edx,0xb0(%r8)
  43ddd3:	cmp    %r13,-0x8(%rsp)
  43ddd8:	je     43dfba <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x4aa>
  43ddde:	mov    0xb4(%r8),%eax
  43dde5:	mov    %edx,%ecx
  43dde7:	sub    %eax,%edx
  43dde9:	and    %edi,%edx
  43ddeb:	cmp    %edx,%edi
  43dded:	jbe    43de11 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x301>
  43ddef:	cmpq   $0x4,-0x10(%rsp)
  43ddf5:	jne    43dd7a <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x26a>
  43ddf7:	mov    $0xffffffff,%r11d
  43ddfd:	crc32l 0x0(%r13),%r11d
  43de04:	mov    %r11d,%eax
  43de07:	mov    %rax,-0x30(%rsp)
  43de0c:	jmp    43dd8b <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x27b>
  43de11:	mov    0x80(%r8),%r11
  43de18:	mov    %r11,-0x20(%rsp)
  43de1d:	nopl   (%rax)
  43de20:	lea    0x8(%rax),%edx
  43de23:	and    %edi,%edx
  43de25:	shl    $0x4,%rdx
  43de29:	mov    %r11d,%esi
  43de2c:	and    0x8(%r9,%rdx,1),%esi
  43de31:	mov    %eax,%edx
  43de33:	shl    $0x4,%rdx
  43de37:	add    %r9,%rdx
  43de3a:	mov    (%rdx),%r10
  43de3d:	shl    $0x4,%rsi
  43de41:	prefetcht0 (%r12,%rsi,1)
  43de46:	cmp    0x90(%r8),%r10
  43de4d:	jne    43de90 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x380>
  43de4f:	kortestb %k2,%k2
  43de53:	je     43de74 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x364>
  43de55:	mov    (%r15),%r14d
  43de58:	mov    0xc(%rdx),%edx
  43de5b:	mov    %r14,%r10
  43de5e:	shl    $0x4,%r14
  43de62:	add    0x8(%r15),%r14
  43de66:	lea    0x1(%r10),%esi
  43de6a:	mov    %edx,(%r14)
  43de6d:	mov    %rbx,0x8(%r14)
  43de71:	mov    %esi,(%r15)
  43de74:	inc    %eax
  43de76:	and    %edi,%eax
  43de78:	mov    %eax,0xb4(%r8)
  43de7f:	test   %rbx,%rbx
  43de82:	jne    43de20 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x310>
  43de84:	jmp    43ddef <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2df>
  43de89:	nopl   0x0(%rax)
  43de90:	mov    0x8(%rdx),%r14d
  43de94:	mov    %r11d,%esi
  43de97:	and    %r14d,%esi
  43de9a:	shl    $0x4,%rsi
  43de9e:	add    %r12,%rsi
  43dea1:	vmovdqa64 (%rsi),%zmm0
  43dea7:	vpbroadcastq %r10,%zmm1
  43dead:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
  43deb4:	kortestb %k0,%k0
  43deb8:	jne    43df34 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x424>
  43deba:	vpcmpequq %zmm2,%zmm0,%k3{%k1}
  43dec1:	kortestb %k3,%k3
  43dec5:	jne    43df79 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x469>
  43decb:	cmpq   $0x4,-0x10(%rsp)
  43ded1:	mov    %r14d,%esi
  43ded4:	je     43dfa2 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x492>
  43deda:	cmpq   $0x8,-0x10(%rsp)
  43dee0:	je     43dfc2 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x4b2>
  43dee6:	mov    -0x38(%rsp),%esi
  43deea:	mov    -0x20(%rsp),%r14
  43deef:	vmovd  %esi,%xmm7
  43def3:	vpinsrd $0x1,0xc(%rdx),%xmm7,%xmm3
  43defa:	mov    %ecx,%edx
  43defc:	and    -0x38(%rsp),%r14
  43df01:	shl    $0x4,%rdx
  43df05:	inc    %ecx
  43df07:	inc    %eax
  43df09:	add    %r9,%rdx
  43df0c:	shl    $0x4,%r14
  43df10:	and    %edi,%ecx
  43df12:	and    %edi,%eax
  43df14:	prefetcht2 (%r12,%r14,1)
  43df19:	mov    %r10,(%rdx)
  43df1c:	vmovq  %xmm3,0x8(%rdx)
  43df21:	mov    %ecx,0xb0(%r8)
  43df28:	mov    %eax,0xb4(%r8)
  43df2f:	jmp    43de20 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x310>
  43df34:	mov    (%r15),%r10d
  43df37:	mov    0xc(%rdx),%r14d
  43df3b:	mov    %r10,%r11
  43df3e:	shl    $0x4,%r10
  43df42:	add    0x8(%r15),%r10
  43df46:	mov    %r14d,(%r10)
  43df49:	xor    %r14d,%r14d
  43df4c:	kmovb  %k0,%edx
  43df50:	tzcnt  %edx,%r14d
  43df55:	inc    %r14d
  43df58:	movslq %r14d,%rdx
  43df5b:	mov    (%rsi,%rdx,8),%rsi
  43df5f:	inc    %eax
  43df61:	inc    %r11d
  43df64:	and    %edi,%eax
  43df66:	mov    %rsi,0x8(%r10)
  43df6a:	mov    %r11d,(%r15)
  43df6d:	mov    %eax,0xb4(%r8)
  43df74:	jmp    43ddef <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2df>
  43df79:	inc    %eax
  43df7b:	and    %edi,%eax
  43df7d:	mov    %eax,0xb4(%r8)
  43df84:	jmp    43ddef <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2df>
  43df89:	mov    $0xffffffff,%edx
  43df8e:	crc32q 0x0(%r13),%rdx
  43df95:	mov    %rdx,-0x30(%rsp)
  43df9a:	mov    %edx,%r11d
  43df9d:	jmp    43dd8b <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x27b>
  43dfa2:	mov    $0xffffffff,%esi
  43dfa7:	crc32  %r14d,%esi
  43dfad:	mov    %esi,%r14d
  43dfb0:	mov    %r14,-0x38(%rsp)
  43dfb5:	jmp    43deea <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x3da>
  43dfba:	vzeroupper 
  43dfbd:	jmp    43dcf8 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1e8>
  43dfc2:	mov    $0xffffffff,%r14d
  43dfc8:	crc32  %rsi,%r14
  43dfce:	mov    %r14,-0x38(%rsp)
  43dfd3:	mov    %r14d,%esi
  43dfd6:	jmp    43deea <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x3da>
  43dfdb:	nop
  43dfdc:	nopl   0x0(%rax)
