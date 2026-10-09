000000000043dab0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)>:
  43dab0:	push   %rbp
  43dab1:	mov    %rdi,%rcx
  43dab4:	mov    %rsp,%rbp
  43dab7:	push   %r15
  43dab9:	mov    %rdx,%r15
  43dabc:	push   %r14
  43dabe:	push   %r13
  43dac0:	push   %r12
  43dac2:	push   %rbx
  43dac3:	and    $0xffffffffffffffc0,%rsp
  43dac7:	sub    $0x8,%rsp
  43dacb:	mov    %rsi,-0x50(%rsp)
  43dad0:	mov    0xb0(%rdi),%r10d
  43dad7:	mov    0xb4(%rdi),%eax
  43dadd:	mov    0x6c(%rcx),%r11d
  43dae1:	mov    0x78(%rdi),%edi
  43dae4:	mov    %r10d,%r8d
  43dae7:	sub    %eax,%r8d
  43daea:	mov    0x8(%rsi),%r9
  43daee:	mov    (%rsi),%rdx
  43daf1:	and    %edi,%r8d
  43daf4:	lea    -0x1(%r11),%esi
  43daf8:	cmp    %esi,%r8d
  43dafb:	jb     43e442 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x992>
  43db01:	shl    $0x4,%r11
  43db05:	mov    %r11,-0x28(%rsp)
  43db0a:	lea    -0x1(%r11),%rdi
  43db0e:	mov    %r9,%r11
  43db11:	and    $0xfffffffffffffffc,%r11
  43db15:	mov    0x80(%rcx),%r14
  43db1c:	shl    $0x4,%r10
  43db20:	mov    0x8(%r15),%rbx
  43db24:	lea    (%r11,%r11,2),%r12
  43db28:	mov    %r10,%r13
  43db2b:	lea    (%rdx,%r12,8),%r10
  43db2f:	mov    %r14d,-0x18(%rsp)
  43db34:	mov    %rbx,(%rsp)
  43db38:	mov    %r10,-0x20(%rsp)
  43db3d:	movl   $0x0,-0x44(%rsp)
  43db45:	mov    0xa0(%rcx),%r8
  43db4c:	mov    0x542e5(%rip),%rsi        # 491e38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43db53:	shl    $0x4,%rax
  43db57:	not    %r14d
  43db5a:	cmp    %rdx,%r10
  43db5d:	je     43e6eb <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xc3b>
  43db63:	mov    $0x55,%r9d
  43db69:	mov    $0xf,%ebx
  43db6e:	mov    $0xf0,%r11d
  43db74:	mov    $0xf00,%r10d
  43db7a:	kmovb  %r9d,%k1
  43db7f:	mov    $0xfffff000,%r9d
  43db85:	mov    %rcx,-0x58(%rsp)
  43db8a:	mov    %r15,-0x60(%rsp)
  43db8f:	vmovdqa32 0x3de27(%rip),%zmm4        # 47b9c0 <std::_Sp_make_shared_tag::_S_ti()::__tag+0x20>
  43db99:	vpxor  %xmm5,%xmm5,%xmm5
  43db9d:	mov    $0xffffffff,%r12d
  43dba3:	kmovw  %ebx,%k5
  43dba7:	kmovw  %r11d,%k4
  43dbac:	kmovw  %r10d,%k3
  43dbb1:	kmovw  %r9d,%k2
  43dbb6:	jmp    43de62 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x3b2>
  43dbbb:	nopl   0x0(%rax,%rax,1)
  43dbc0:	vmovd  0xc(%r9),%xmm13
  43dbc6:	kshiftlb $0x1,%k6,%k6
  43dbcc:	vpcompressq %zmm8,%zmm12{%k6}{z}
  43dbd2:	vpunpcklqdq %xmm12,%xmm13,%xmm14
  43dbd7:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k5}{z}
  43dbde:	vmovdqa64 %zmm15,%zmm13
  43dbe4:	mov    $0x1,%ecx
  43dbe9:	lea    (%r8,%rax,1),%r10
  43dbed:	lea    0x180(%rax),%r11
  43dbf4:	and    %rdi,%r11
  43dbf7:	andn   0x8(%r8,%r11,1),%r14d,%r15d
  43dbfe:	mov    0x8(%r10),%r11d
  43dc02:	mov    %r15d,%ebx
  43dc05:	andn   %r11d,%r14d,%r9d
  43dc0a:	mov    %r9d,%r15d
  43dc0d:	shl    $0x4,%r15
  43dc11:	vmovdqa64 (%rsi,%r15,1),%zmm0
  43dc18:	vpbroadcastq (%r10),%zmm2
  43dc1e:	vpcmpequq %zmm2,%zmm0,%k0{%k1}
  43dc25:	shl    $0x4,%rbx
  43dc29:	add    $0x10,%rax
  43dc2d:	and    %rdi,%rax
  43dc30:	prefetcht0 (%rsi,%rbx,1)
  43dc34:	kortestb %k0,%k0
  43dc38:	je     43e328 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x878>
  43dc3e:	vmovd  0xc(%r10),%xmm1
  43dc44:	kshiftlb $0x1,%k0,%k6
  43dc4a:	vpcompressq %zmm0,%zmm7{%k6}{z}
  43dc50:	vpunpcklqdq %xmm7,%xmm1,%xmm8
  43dc54:	vshufi32x4 $0x0,%zmm8,%zmm8,%zmm15{%k4}
  43dc5b:	vmovdqa64 %zmm15,%zmm13
  43dc61:	or     $0x2,%ecx
  43dc64:	lea    (%r8,%rax,1),%r10
  43dc68:	lea    0x180(%rax),%r15
  43dc6f:	and    %rdi,%r15
  43dc72:	andn   0x8(%r8,%r15,1),%r14d,%ebx
  43dc79:	mov    0x8(%r10),%r15d
  43dc7d:	mov    %ebx,%r11d
  43dc80:	andn   %r15d,%r14d,%r9d
  43dc85:	mov    %r9d,%ebx
  43dc88:	shl    $0x4,%rbx
  43dc8c:	vmovdqa64 (%rsi,%rbx,1),%zmm9
  43dc93:	vpbroadcastq (%r10),%zmm10
  43dc99:	vpcmpequq %zmm10,%zmm9,%k0{%k1}
  43dca0:	shl    $0x4,%r11
  43dca4:	add    $0x10,%rax
  43dca8:	and    %rdi,%rax
  43dcab:	prefetcht0 (%rsi,%r11,1)
  43dcb0:	kortestb %k0,%k0
  43dcb4:	je     43e2d0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x820>
  43dcba:	vmovd  0xc(%r10),%xmm14
  43dcc0:	kshiftlb $0x1,%k0,%k6
  43dcc6:	vpcompressq %zmm9,%zmm13{%k6}{z}
  43dccc:	vpunpcklqdq %xmm13,%xmm14,%xmm0
  43dcd1:	vshufi32x4 $0x0,%zmm0,%zmm0,%zmm15{%k3}
  43dcd8:	vmovdqa64 %zmm15,%zmm13
  43dcde:	or     $0x4,%ecx
  43dce1:	lea    (%r8,%rax,1),%r10
  43dce5:	lea    0x180(%rax),%rbx
  43dcec:	and    %rdi,%rbx
  43dcef:	mov    0x8(%r10),%r15d
  43dcf3:	andn   0x8(%r8,%rbx,1),%r14d,%r9d
  43dcfa:	andn   %r15d,%r14d,%ebx
  43dcff:	mov    %r9d,%r11d
  43dd02:	mov    %ebx,%r9d
  43dd05:	shl    $0x4,%r9
  43dd09:	vmovdqa64 (%rsi,%r9,1),%zmm3
  43dd10:	vpbroadcastq (%r10),%zmm2
  43dd16:	vpcmpequq %zmm2,%zmm3,%k0{%k1}
  43dd1d:	shl    $0x4,%r11
  43dd21:	add    $0x10,%rax
  43dd25:	and    %rdi,%rax
  43dd28:	prefetcht0 (%rsi,%r11,1)
  43dd2d:	kortestb %k0,%k0
  43dd31:	je     43e278 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x7c8>
  43dd37:	vmovd  0xc(%r10),%xmm1
  43dd3d:	kshiftlb $0x1,%k0,%k6
  43dd43:	vpcompressq %zmm3,%zmm8{%k6}{z}
  43dd49:	vpunpcklqdq %xmm8,%xmm1,%xmm9
  43dd4e:	vshufi32x4 $0x0,%zmm9,%zmm9,%zmm15{%k2}
  43dd55:	or     $0x8,%ecx
  43dd58:	vmovdqa64 %zmm15,%zmm13
  43dd5e:	cmp    $0xf,%ecx
  43dd61:	jne    43e410 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x960>
  43dd67:	mov    (%rsp),%r15
  43dd6b:	vmovdqu64 %zmm15,(%r15)
  43dd71:	add    $0x40,%r15
  43dd75:	mov    %r15,(%rsp)
  43dd79:	mov    -0x18(%rsp),%r10d
  43dd7e:	mov    (%rdx),%r9
  43dd81:	mov    %r12,%r15
  43dd84:	crc32  %r9,%r15
  43dd8a:	mov    %r10d,%ebx
  43dd8d:	mov    0x18(%rdx),%r11
  43dd91:	and    %r15d,%ebx
  43dd94:	shl    $0x4,%rbx
  43dd98:	mov    %r12,%rcx
  43dd9b:	prefetcht2 (%rsi,%rbx,1)
  43dd9f:	crc32  %r11,%rcx
  43dda5:	mov    %r9,-0x30(%rsp)
  43ddaa:	mov    0x30(%rdx),%rbx
  43ddae:	mov    %r10d,%r9d
  43ddb1:	mov    %r11,-0x38(%rsp)
  43ddb6:	and    %ecx,%r9d
  43ddb9:	mov    %r12,%r11
  43ddbc:	crc32  %rbx,%r11
  43ddc2:	shl    $0x4,%r9
  43ddc6:	prefetcht2 (%rsi,%r9,1)
  43ddcb:	mov    %r11d,%r9d
  43ddce:	and    %r10d,%r9d
  43ddd1:	shl    $0x4,%r9
  43ddd5:	vmovq  %r11,%xmm15
  43ddda:	mov    0x48(%rdx),%r11
  43ddde:	prefetcht2 (%rsi,%r9,1)
  43dde3:	mov    %r12,%r9
  43dde6:	crc32  %r11,%r9
  43ddec:	and    %r9d,%r10d
  43ddef:	mov    %r11,-0x40(%rsp)
  43ddf4:	mov    %r10,%r11
  43ddf7:	shl    $0x4,%r11
  43ddfb:	lea    0x40(%r13),%r10
  43ddff:	prefetcht2 (%rsi,%r11,1)
  43de04:	cmp    %r10,-0x28(%rsp)
  43de09:	jb     43e380 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x8d0>
  43de0f:	vmovdqu32 (%rdx),%zmm7
  43de15:	vmovd  %r15d,%xmm6
  43de1a:	vpinsrd $0x1,%r9d,%xmm15,%xmm8
  43de20:	vpinsrd $0x1,%ecx,%xmm6,%xmm1
  43de26:	vpermt2d 0x20(%rdx),%zmm4,%zmm7
  43de30:	vpunpcklqdq %xmm8,%xmm1,%xmm9
  43de35:	mov    $0x4444,%r9d
  43de3b:	kmovw  %r9d,%k6
  43de40:	vpexpandd %zmm9,%zmm7{%k6}
  43de46:	vmovdqu64 %zmm7,(%r8,%r13,1)
  43de4d:	and    %rdi,%r10
  43de50:	add    $0x60,%rdx
  43de54:	mov    %r10,%r13
  43de57:	cmp    %rdx,-0x20(%rsp)
  43de5c:	je     43df10 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x460>
  43de62:	lea    (%r8,%rax,1),%r9
  43de66:	lea    0x180(%rax),%rcx
  43de6d:	and    %rdi,%rcx
  43de70:	mov    0x8(%r9),%r10d
  43de74:	andn   0x8(%r8,%rcx,1),%r14d,%r15d
  43de7b:	andn   %r10d,%r14d,%r11d
  43de80:	mov    %r11d,%ecx
  43de83:	shl    $0x4,%rcx
  43de87:	vmovdqa64 (%rsi,%rcx,1),%zmm8
  43de8e:	vpbroadcastq (%r9),%zmm9
  43de94:	vpcmpequq %zmm9,%zmm8,%k6{%k1}
  43de9b:	mov    %r15d,%ebx
  43de9e:	shl    $0x4,%rbx
  43dea2:	add    $0x10,%rax
  43dea6:	and    %rdi,%rax
  43dea9:	prefetcht0 (%rsi,%rbx,1)
  43dead:	kortestb %k6,%k6
  43deb1:	jne    43dbc0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x110>
  43deb7:	vpcmpequq %zmm5,%zmm8,%k7{%k1}
  43debe:	kortestb %k7,%k7
  43dec2:	jne    43e718 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xc68>
  43dec8:	mov    %r12,%r15
  43decb:	crc32  %r10,%r15
  43ded1:	mov    -0x18(%rsp),%ebx
  43ded5:	vmovd  %r15d,%xmm10
  43deda:	vpinsrd $0x1,0xc(%r9),%xmm10,%xmm11
  43dee1:	and    %r15d,%ebx
  43dee4:	mov    (%r9),%r9
  43dee7:	lea    (%r8,%r13,1),%r10
  43deeb:	shl    $0x4,%rbx
  43deef:	lea    0x10(%r13),%r13
  43def3:	prefetcht2 (%rsi,%rbx,1)
  43def7:	and    %rdi,%r13
  43defa:	mov    %r9,(%r10)
  43defd:	vmovq  %xmm11,0x8(%r10)
  43df03:	jmp    43de62 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x3b2>
  43df08:	nopl   0x0(%rax,%rax,1)
  43df10:	mov    -0x50(%rsp),%rsi
  43df15:	mov    -0x58(%rsp),%rcx
  43df1a:	mov    -0x60(%rsp),%r15
  43df1f:	mov    (%rsi),%rdi
  43df22:	mov    -0x44(%rsp),%r8d
  43df27:	mov    0x8(%rsi),%r9
  43df2b:	mov    -0x20(%rsp),%r12
  43df30:	vmovq  %r13,%xmm13
  43df35:	sub    %rdi,%r12
  43df38:	sar    $0x3,%r12
  43df3c:	movabs $0xaaaaaaaaaaaaaaab,%r14
  43df46:	vpinsrq $0x1,%rax,%xmm13,%xmm4
  43df4c:	imul   %r14,%r12
  43df50:	vpsrlq $0x4,%xmm4,%xmm5
  43df55:	vpmovqd %xmm5,%xmm15
  43df5b:	lea    (%r9,%r9,2),%r10
  43df5f:	vmovq  %xmm15,0xb0(%rcx)
  43df67:	sub    %r8,%r12
  43df6a:	lea    (%rdi,%r10,8),%r11
  43df6e:	add    %r12d,(%r15)
  43df71:	mov    %r11,-0x20(%rsp)
  43df76:	vpextrd $0x1,%xmm15,%eax
  43df7c:	cmp    %rdx,%r11
  43df7f:	je     43e260 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x7b0>
  43df85:	mov    0x88(%rcx),%r8
  43df8c:	mov    0x80(%rcx),%rbx
  43df93:	mov    0x60(%rcx),%rsi
  43df97:	dec    %r8
  43df9a:	mov    %rbx,-0x18(%rsp)
  43df9f:	mov    %rsi,(%rsp)
  43dfa3:	mov    %r8,-0x28(%rsp)
  43dfa8:	mov    0x78(%rcx),%r10d
  43dfac:	mov    0x53e85(%rip),%r11        # 491e38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43dfb3:	mov    0xa0(%rcx),%r9
  43dfba:	movzbl 0x53e5e(%rip),%r13d        # 491e20 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_exists_>
  43dfc2:	mov    0x53e5f(%rip),%r12        # 491e28 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_>
  43dfc9:	mov    $0x55,%edi
  43dfce:	vpxor  %xmm10,%xmm10,%xmm10
  43dfd3:	kmovb  %edi,%k1
  43dfd7:	nopw   0x0(%rax,%rax,1)
  43dfe0:	lea    0x18(%rax),%r14d
  43dfe4:	and    %r10d,%r14d
  43dfe7:	shl    $0x4,%r14
  43dfeb:	mov    %ebx,%esi
  43dfed:	and    0x8(%r9,%r14,1),%esi
  43dff2:	mov    %rsi,%rdi
  43dff5:	mov    %eax,%esi
  43dff7:	shl    $0x4,%rsi
  43dffb:	add    %r9,%rsi
  43dffe:	mov    (%rsi),%r8
  43e001:	shl    $0x4,%rdi
  43e005:	prefetcht0 (%r11,%rdi,1)
  43e00a:	cmp    0x90(%rcx),%r8
  43e011:	jne    43e0d0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x620>
  43e017:	test   %r13b,%r13b
  43e01a:	je     43e03a <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x58a>
  43e01c:	mov    (%r15),%r14d
  43e01f:	mov    0xc(%rsi),%esi
  43e022:	mov    %r14,%r8
  43e025:	shl    $0x4,%r14
  43e029:	add    0x8(%r15),%r14
  43e02d:	inc    %r8d
  43e030:	mov    %esi,(%r14)
  43e033:	mov    %r12,0x8(%r14)
  43e037:	mov    %r8d,(%r15)
  43e03a:	inc    %eax
  43e03c:	and    %r10d,%eax
  43e03f:	mov    %eax,0xb4(%rcx)
  43e045:	test   %r12,%r12
  43e048:	jne    43dfe0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x530>
  43e04a:	cmpq   $0x4,(%rsp)
  43e04f:	je     43e1c5 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x715>
  43e055:	nopl   (%rax)
  43e058:	cmpq   $0x8,(%rsp)
  43e05d:	je     43e240 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x790>
  43e063:	vmovd  -0x10(%rsp),%xmm2
  43e069:	mov    (%rdx),%rdi
  43e06c:	mov    0xb0(%rcx),%esi
  43e072:	mov    -0x28(%rsp),%r8
  43e077:	mov    %rsi,%rax
  43e07a:	and    -0x10(%rsp),%r8
  43e07f:	vpinsrd $0x1,0x10(%rdx),%xmm2,%xmm8
  43e086:	and    $0xfffffffffffffffc,%r8
  43e08a:	shl    $0x4,%rsi
  43e08e:	inc    %eax
  43e090:	add    %r9,%rsi
  43e093:	shl    $0x4,%r8
  43e097:	and    %r10d,%eax
  43e09a:	add    $0x18,%rdx
  43e09e:	prefetcht2 (%r11,%r8,1)
  43e0a3:	mov    %rdi,(%rsi)
  43e0a6:	vmovq  %xmm8,0x8(%rsi)
  43e0ab:	mov    %eax,0xb0(%rcx)
  43e0b1:	cmp    %rdx,-0x20(%rsp)
  43e0b6:	je     43e260 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x7b0>
  43e0bc:	mov    0xb4(%rcx),%eax
  43e0c2:	jmp    43dfe0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x530>
  43e0c7:	nopw   0x0(%rax,%rax,1)
  43e0d0:	mov    0x8(%rsi),%r14d
  43e0d4:	mov    %ebx,%edi
  43e0d6:	and    %r14d,%edi
  43e0d9:	shl    $0x4,%rdi
  43e0dd:	add    %r11,%rdi
  43e0e0:	vmovdqa64 (%rdi),%zmm11
  43e0e6:	vpbroadcastq %r8,%zmm12
  43e0ec:	vpcmpequq %zmm12,%zmm11,%k0{%k1}
  43e0f3:	kortestb %k0,%k0
  43e0f7:	jne    43e180 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x6d0>
  43e0fd:	vpcmpequq %zmm10,%zmm11,%k2{%k1}
  43e104:	kortestb %k2,%k2
  43e108:	jne    43e1f0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x740>
  43e10e:	cmpq   $0x4,(%rsp)
  43e113:	mov    %r14d,%edi
  43e116:	je     43e200 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x750>
  43e11c:	cmpq   $0x8,(%rsp)
  43e121:	je     43e220 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x770>
  43e127:	vmovd  -0x8(%rsp),%xmm14
  43e12d:	mov    0xb0(%rcx),%edi
  43e133:	mov    -0x18(%rsp),%r14
  43e138:	vpinsrd $0x1,0xc(%rsi),%xmm14,%xmm3
  43e13f:	mov    %rdi,%rsi
  43e142:	and    -0x8(%rsp),%r14
  43e147:	shl    $0x4,%rdi
  43e14b:	inc    %esi
  43e14d:	inc    %eax
  43e14f:	add    %r9,%rdi
  43e152:	shl    $0x4,%r14
  43e156:	and    %r10d,%esi
  43e159:	and    %r10d,%eax
  43e15c:	prefetcht2 (%r11,%r14,1)
  43e161:	mov    %r8,(%rdi)
  43e164:	vmovq  %xmm3,0x8(%rdi)
  43e169:	mov    %esi,0xb0(%rcx)
  43e16f:	mov    %eax,0xb4(%rcx)
  43e175:	jmp    43dfe0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x530>
  43e17a:	nopw   0x0(%rax,%rax,1)
  43e180:	mov    (%r15),%r8d
  43e183:	mov    0xc(%rsi),%esi
  43e186:	mov    %r8,%r14
  43e189:	shl    $0x4,%r8
  43e18d:	add    0x8(%r15),%r8
  43e191:	mov    %esi,(%r8)
  43e194:	kmovb  %k0,%esi
  43e198:	tzcnt  %esi,%esi
  43e19c:	inc    %esi
  43e19e:	movslq %esi,%rsi
  43e1a1:	mov    (%rdi,%rsi,8),%rdi
  43e1a5:	inc    %eax
  43e1a7:	inc    %r14d
  43e1aa:	and    %r10d,%eax
  43e1ad:	cmpq   $0x4,(%rsp)
  43e1b2:	mov    %rdi,0x8(%r8)
  43e1b6:	mov    %r14d,(%r15)
  43e1b9:	mov    %eax,0xb4(%rcx)
  43e1bf:	jne    43e058 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x5a8>
  43e1c5:	mov    $0xffffffff,%r14d
  43e1cb:	crc32l (%rdx),%r14d
  43e1d1:	vmovd  %r14d,%xmm7
  43e1d6:	mov    (%rdx),%rdi
  43e1d9:	vmovdqa %xmm7,%xmm2
  43e1dd:	vmovq  %xmm7,-0x10(%rsp)
  43e1e3:	jmp    43e06c <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x5bc>
  43e1e8:	nopl   0x0(%rax,%rax,1)
  43e1f0:	inc    %eax
  43e1f2:	and    %r10d,%eax
  43e1f5:	mov    %eax,0xb4(%rcx)
  43e1fb:	jmp    43e04a <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x59a>
  43e200:	mov    $0xffffffff,%edi
  43e205:	crc32  %r14d,%edi
  43e20b:	vmovd  %edi,%xmm0
  43e20f:	vmovdqa %xmm0,%xmm14
  43e213:	vmovq  %xmm0,-0x8(%rsp)
  43e219:	jmp    43e12d <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x67d>
  43e21e:	xchg   %ax,%ax
  43e220:	mov    $0xffffffff,%r14d
  43e226:	crc32  %rdi,%r14
  43e22c:	mov    %r14,-0x8(%rsp)
  43e231:	vmovd  %r14d,%xmm14
  43e236:	jmp    43e12d <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x67d>
  43e23b:	nopl   0x0(%rax,%rax,1)
  43e240:	mov    (%rdx),%rdi
  43e243:	mov    $0xffffffff,%eax
  43e248:	crc32  %rdi,%rax
  43e24e:	mov    %rax,-0x10(%rsp)
  43e253:	vmovd  %eax,%xmm2
  43e257:	jmp    43e06c <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x5bc>
  43e25c:	nopl   0x0(%rax)
  43e260:	vzeroupper 
  43e263:	lea    -0x28(%rbp),%rsp
  43e267:	pop    %rbx
  43e268:	pop    %r12
  43e26a:	pop    %r13
  43e26c:	pop    %r14
  43e26e:	pop    %r15
  43e270:	pop    %rbp
  43e271:	ret    
  43e272:	nopw   0x0(%rax,%rax,1)
  43e278:	vpcmpequq %zmm5,%zmm3,%k7{%k1}
  43e27f:	kortestb %k7,%k7
  43e283:	jne    43e40a <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x95a>
  43e289:	mov    %r12,%rbx
  43e28c:	crc32  %r15,%rbx
  43e292:	mov    -0x18(%rsp),%r11d
  43e297:	vmovd  %ebx,%xmm6
  43e29b:	vpinsrd $0x1,0xc(%r10),%xmm6,%xmm7
  43e2a2:	and    %ebx,%r11d
  43e2a5:	mov    (%r10),%r10
  43e2a8:	lea    (%r8,%r13,1),%r15
  43e2ac:	shl    $0x4,%r11
  43e2b0:	add    $0x10,%r13
  43e2b4:	prefetcht2 (%rsi,%r11,1)
  43e2b9:	and    %rdi,%r13
  43e2bc:	mov    %r10,(%r15)
  43e2bf:	vmovq  %xmm7,0x8(%r15)
  43e2c5:	jmp    43dce1 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x231>
  43e2ca:	nopw   0x0(%rax,%rax,1)
  43e2d0:	vpcmpequq %zmm5,%zmm9,%k7{%k1}
  43e2d7:	kortestb %k7,%k7
  43e2db:	jne    43e72d <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xc7d>
  43e2e1:	mov    %r12,%r9
  43e2e4:	crc32  %r15,%r9
  43e2ea:	mov    -0x18(%rsp),%r11d
  43e2ef:	vmovd  %r9d,%xmm11
  43e2f4:	vpinsrd $0x1,0xc(%r10),%xmm11,%xmm12
  43e2fb:	and    %r9d,%r11d
  43e2fe:	mov    (%r10),%r10
  43e301:	lea    (%r8,%r13,1),%r15
  43e305:	shl    $0x4,%r11
  43e309:	add    $0x10,%r13
  43e30d:	prefetcht2 (%rsi,%r11,1)
  43e312:	and    %rdi,%r13
  43e315:	mov    %r10,(%r15)
  43e318:	vmovq  %xmm12,0x8(%r15)
  43e31e:	jmp    43dc64 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1b4>
  43e323:	nopl   0x0(%rax,%rax,1)
  43e328:	vpcmpequq %zmm5,%zmm0,%k7{%k1}
  43e32f:	kortestb %k7,%k7
  43e333:	jne    43e70f <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xc5f>
  43e339:	mov    %r12,%rbx
  43e33c:	crc32  %r11,%rbx
  43e342:	mov    -0x18(%rsp),%r11d
  43e347:	vmovd  %ebx,%xmm3
  43e34b:	vpinsrd $0x1,0xc(%r10),%xmm3,%xmm6
  43e352:	and    %ebx,%r11d
  43e355:	mov    (%r10),%r10
  43e358:	lea    (%r8,%r13,1),%r9
  43e35c:	shl    $0x4,%r11
  43e360:	add    $0x10,%r13
  43e364:	prefetcht2 (%rsi,%r11,1)
  43e369:	and    %rdi,%r13
  43e36c:	mov    %r10,(%r9)
  43e36f:	vmovq  %xmm6,0x8(%r9)
  43e375:	jmp    43dbe9 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x139>
  43e37a:	nopw   0x0(%rax,%rax,1)
  43e380:	vmovd  %r15d,%xmm10
  43e385:	mov    %rdi,%r15
  43e388:	vpinsrd $0x1,0x10(%rdx),%xmm10,%xmm11
  43e38f:	mov    -0x30(%rsp),%r11
  43e394:	and    %r13,%r15
  43e397:	add    %r8,%r15
  43e39a:	vmovq  %xmm11,0x8(%r15)
  43e3a0:	mov    %r11,(%r15)
  43e3a3:	vmovd  %ecx,%xmm12
  43e3a7:	lea    0x10(%r13),%r15
  43e3ab:	vpinsrd $0x1,0x28(%rdx),%xmm12,%xmm14
  43e3b2:	and    %rdi,%r15
  43e3b5:	add    %r8,%r15
  43e3b8:	vmovq  %xmm14,0x8(%r15)
  43e3be:	lea    0x20(%r13),%r11
  43e3c2:	vpinsrd $0x1,0x40(%rdx),%xmm15,%xmm0
  43e3c9:	mov    -0x38(%rsp),%rcx
  43e3ce:	and    %rdi,%r11
  43e3d1:	add    %r8,%r11
  43e3d4:	mov    %rcx,(%r15)
  43e3d7:	vmovd  %r9d,%xmm3
  43e3dc:	vmovq  %xmm0,0x8(%r11)
  43e3e2:	lea    0x30(%r13),%r13
  43e3e6:	mov    %rbx,(%r11)
  43e3e9:	vpinsrd $0x1,0x58(%rdx),%xmm3,%xmm2
  43e3f0:	mov    -0x40(%rsp),%rbx
  43e3f5:	and    %rdi,%r13
  43e3f8:	add    %r8,%r13
  43e3fb:	mov    %rbx,0x0(%r13)
  43e3ff:	vmovq  %xmm2,0x8(%r13)
  43e405:	jmp    43de4d <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x39d>
  43e40a:	incl   -0x44(%rsp)
  43e40e:	xchg   %ax,%ax
  43e410:	mov    (%rsp),%r10
  43e414:	mov    $0x55,%r9d
  43e41a:	pdep   %r9d,%ecx,%ebx
  43e41f:	popcnt %ecx,%ecx
  43e423:	lea    (%rbx,%rbx,2),%r11d
  43e427:	shl    $0x4,%rcx
  43e42b:	kmovb  %r11d,%k7
  43e430:	vpcompressq %zmm13,(%r10){%k7}
  43e436:	add    %rcx,%r10
  43e439:	mov    %r10,(%rsp)
  43e43d:	jmp    43dd79 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2c9>
  43e442:	lea    (%r9,%r9,2),%r9
  43e446:	lea    (%rdx,%r9,8),%r12
  43e44a:	mov    %r12,-0x8(%rsp)
  43e44f:	cmp    %rdx,%r12
  43e452:	je     43e263 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x7b3>
  43e458:	mov    0x88(%rcx),%r12
  43e45f:	movzbl 0x539b9(%rip),%r14d        # 491e20 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_exists_>
  43e467:	mov    0x539ba(%rip),%r13        # 491e28 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_>
  43e46e:	mov    0x60(%rcx),%r8
  43e472:	mov    $0x55,%r9d
  43e478:	dec    %r12
  43e47b:	kmovb  %r14d,%k2
  43e480:	mov    %r8,(%rsp)
  43e484:	mov    %r12,-0x10(%rsp)
  43e489:	mov    0x539a8(%rip),%rbx        # 491e38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43e490:	mov    0xa0(%rcx),%r11
  43e497:	mov    %r10d,%esi
  43e49a:	vpxor  %xmm2,%xmm2,%xmm2
  43e49e:	mov    %r13,%r14
  43e4a1:	kmovb  %r9d,%k1
  43e4a6:	jmp    43e510 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xa60>
  43e4a8:	cmpq   $0x8,(%rsp)
  43e4ad:	je     43e6b9 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xc09>
  43e4b3:	vmovd  -0x18(%rsp),%xmm5
  43e4b9:	mov    -0x10(%rsp),%r13
  43e4be:	mov    %r10d,%esi
  43e4c1:	and    -0x18(%rsp),%r13
  43e4c6:	vpinsrd $0x1,0x10(%rdx),%xmm5,%xmm7
  43e4cd:	mov    (%rdx),%r9
  43e4d0:	and    $0xfffffffffffffffc,%r13
  43e4d4:	shl    $0x4,%rsi
  43e4d8:	add    %r11,%rsi
  43e4db:	shl    $0x4,%r13
  43e4df:	prefetcht2 (%rbx,%r13,1)
  43e4e4:	mov    %r9,(%rsi)
  43e4e7:	vmovq  %xmm7,0x8(%rsi)
  43e4ec:	lea    0x1(%r10),%esi
  43e4f0:	and    %edi,%esi
  43e4f2:	add    $0x18,%rdx
  43e4f6:	mov    %esi,0xb0(%rcx)
  43e4fc:	cmp    %rdx,-0x8(%rsp)
  43e501:	je     43e260 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x7b0>
  43e507:	mov    0xb4(%rcx),%eax
  43e50d:	mov    %esi,%r10d
  43e510:	sub    %eax,%esi
  43e512:	and    %edi,%esi
  43e514:	cmp    %esi,%edi
  43e516:	jbe    43e53f <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xa8f>
  43e518:	cmpq   $0x4,(%rsp)
  43e51d:	jne    43e4a8 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x9f8>
  43e51f:	mov    $0xffffffff,%r12d
  43e525:	crc32l (%rdx),%r12d
  43e52b:	vmovd  %r12d,%xmm6
  43e530:	vmovdqa %xmm6,%xmm5
  43e534:	vmovq  %xmm6,-0x18(%rsp)
  43e53a:	jmp    43e4b9 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xa09>
  43e53f:	mov    0x80(%rcx),%r12
  43e546:	mov    %r12,-0x28(%rsp)
  43e54b:	nopl   0x0(%rax,%rax,1)
  43e550:	lea    0x18(%rax),%esi
  43e553:	and    %edi,%esi
  43e555:	shl    $0x4,%rsi
  43e559:	mov    %r12d,%r13d
  43e55c:	and    0x8(%r11,%rsi,1),%r13d
  43e561:	mov    %eax,%esi
  43e563:	shl    $0x4,%rsi
  43e567:	add    %r11,%rsi
  43e56a:	mov    %r13,%r8
  43e56d:	mov    (%rsi),%r9
  43e570:	shl    $0x4,%r8
  43e574:	prefetcht0 (%rbx,%r8,1)
  43e579:	cmp    0x90(%rcx),%r9
  43e580:	jne    43e5c0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xb10>
  43e582:	kortestb %k2,%k2
  43e586:	je     43e5a8 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xaf8>
  43e588:	mov    (%r15),%r13d
  43e58b:	mov    0xc(%rsi),%esi
  43e58e:	mov    %r13,%r9
  43e591:	shl    $0x4,%r13
  43e595:	add    0x8(%r15),%r13
  43e599:	lea    0x1(%r9),%r8d
  43e59d:	mov    %esi,0x0(%r13)
  43e5a1:	mov    %r14,0x8(%r13)
  43e5a5:	mov    %r8d,(%r15)
  43e5a8:	inc    %eax
  43e5aa:	and    %edi,%eax
  43e5ac:	mov    %eax,0xb4(%rcx)
  43e5b2:	test   %r14,%r14
  43e5b5:	jne    43e550 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xaa0>
  43e5b7:	jmp    43e518 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xa68>
  43e5bc:	nopl   0x0(%rax)
  43e5c0:	mov    0x8(%rsi),%r13d
  43e5c4:	mov    %r12d,%r8d
  43e5c7:	and    %r13d,%r8d
  43e5ca:	shl    $0x4,%r8
  43e5ce:	add    %rbx,%r8
  43e5d1:	vmovdqa64 (%r8),%zmm0
  43e5d7:	vpbroadcastq %r9,%zmm1
  43e5dd:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
  43e5e4:	kortestb %k0,%k0
  43e5e8:	jne    43e666 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xbb6>
  43e5ea:	vpcmpequq %zmm2,%zmm0,%k3{%k1}
  43e5f1:	kortestb %k3,%k3
  43e5f5:	jne    43e6aa <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xbfa>
  43e5fb:	cmpq   $0x4,(%rsp)
  43e600:	mov    %r13d,%r8d
  43e603:	je     43e6d2 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xc22>
  43e609:	cmpq   $0x8,(%rsp)
  43e60e:	je     43e6f6 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xc46>
  43e614:	mov    -0x20(%rsp),%r8d
  43e619:	mov    -0x28(%rsp),%r13
  43e61e:	vmovd  %r8d,%xmm4
  43e623:	vpinsrd $0x1,0xc(%rsi),%xmm4,%xmm3
  43e62a:	mov    %r10d,%esi
  43e62d:	and    -0x20(%rsp),%r13
  43e632:	shl    $0x4,%rsi
  43e636:	inc    %r10d
  43e639:	inc    %eax
  43e63b:	add    %r11,%rsi
  43e63e:	shl    $0x4,%r13
  43e642:	and    %edi,%r10d
  43e645:	and    %edi,%eax
  43e647:	prefetcht2 (%rbx,%r13,1)
  43e64c:	mov    %r9,(%rsi)
  43e64f:	vmovq  %xmm3,0x8(%rsi)
  43e654:	mov    %r10d,0xb0(%rcx)
  43e65b:	mov    %eax,0xb4(%rcx)
  43e661:	jmp    43e550 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xaa0>
  43e666:	mov    (%r15),%r9d
  43e669:	mov    0xc(%rsi),%r13d
  43e66d:	mov    %r9,%r12
  43e670:	shl    $0x4,%r9
  43e674:	add    0x8(%r15),%r9
  43e678:	mov    %r13d,(%r9)
  43e67b:	xor    %r13d,%r13d
  43e67e:	kmovb  %k0,%esi
  43e682:	tzcnt  %esi,%r13d
  43e687:	inc    %r13d
  43e68a:	movslq %r13d,%rsi
  43e68d:	mov    (%r8,%rsi,8),%r8
  43e691:	inc    %eax
  43e693:	inc    %r12d
  43e696:	and    %edi,%eax
  43e698:	mov    %r8,0x8(%r9)
  43e69c:	mov    %r12d,(%r15)
  43e69f:	mov    %eax,0xb4(%rcx)
  43e6a5:	jmp    43e518 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xa68>
  43e6aa:	inc    %eax
  43e6ac:	and    %edi,%eax
  43e6ae:	mov    %eax,0xb4(%rcx)
  43e6b4:	jmp    43e518 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xa68>
  43e6b9:	mov    $0xffffffff,%eax
  43e6be:	crc32q (%rdx),%rax
  43e6c4:	mov    %rax,-0x18(%rsp)
  43e6c9:	vmovd  %eax,%xmm5
  43e6cd:	jmp    43e4b9 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xa09>
  43e6d2:	mov    $0xffffffff,%r8d
  43e6d8:	crc32  %r13d,%r8d
  43e6de:	mov    %r8d,%r13d
  43e6e1:	mov    %r13,-0x20(%rsp)
  43e6e6:	jmp    43e619 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xb69>
  43e6eb:	mov    %r10,%rdi
  43e6ee:	xor    %r8d,%r8d
  43e6f1:	jmp    43df2b <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x47b>
  43e6f6:	mov    $0xffffffff,%r13d
  43e6fc:	crc32  %r8,%r13
  43e702:	mov    %r13,-0x20(%rsp)
  43e707:	mov    %r13d,%r8d
  43e70a:	jmp    43e619 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xb69>
  43e70f:	incl   -0x44(%rsp)
  43e713:	jmp    43dc64 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1b4>
  43e718:	incl   -0x44(%rsp)
  43e71c:	vpxor  %xmm15,%xmm15,%xmm15
  43e721:	xor    %ecx,%ecx
  43e723:	vpxor  %xmm13,%xmm13,%xmm13
  43e728:	jmp    43dbe9 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x139>
  43e72d:	incl   -0x44(%rsp)
  43e731:	jmp    43dce1 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x231>
  43e736:	cs nopw 0x0(%rax,%rax,1)
