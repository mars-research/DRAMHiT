000000000043dad0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)>:
  43dad0:	push   %rbp
  43dad1:	mov    %rsp,%rbp
  43dad4:	push   %r15
  43dad6:	push   %r14
  43dad8:	push   %r13
  43dada:	push   %r12
  43dadc:	push   %rbx
  43dadd:	mov    %rdi,%rbx
  43dae0:	and    $0xffffffffffffffc0,%rsp
  43dae4:	mov    %rdi,-0x20(%rsp)
  43dae9:	mov    %rdx,-0x28(%rsp)
  43daee:	mov    0xb0(%rdi),%ecx
  43daf4:	mov    0xb4(%rdi),%eax
  43dafa:	mov    0x8(%rsi),%r15
  43dafe:	mov    (%rsi),%r14
  43db01:	mov    0x78(%rdi),%edi
  43db04:	mov    0x6c(%rbx),%r8d
  43db08:	mov    %ecx,%r11d
  43db0b:	lea    (%r15,%r15,2),%rsi
  43db0f:	sub    %eax,%r11d
  43db12:	lea    (%r14,%rsi,8),%r10
  43db16:	and    %edi,%r11d
  43db19:	lea    -0x1(%r8),%r9d
  43db1d:	mov    %r15,-0x18(%rsp)
  43db22:	mov    %r10,-0x8(%rsp)
  43db27:	cmp    %r9d,%r11d
  43db2a:	jb     43dcec <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x21c>
  43db30:	mov    %rdx,%rdi
  43db33:	shl    $0x5,%r8
  43db37:	mov    %ecx,%edx
  43db39:	mov    0xa0(%rbx),%r9
  43db40:	mov    0x8(%rdi),%r15
  43db44:	dec    %r8
  43db47:	shl    $0x5,%rax
  43db4b:	shl    $0x5,%rdx
  43db4f:	cmp    %r10,%r14
  43db52:	je     43dca2 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1d2>
  43db58:	mov    $0x55,%r11d
  43db5e:	movl   $0x0,-0x10(%rsp)
  43db66:	mov    0x542cb(%rip),%r10        # 491e38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43db6d:	mov    0x80(%rbx),%r13d
  43db74:	vpxor  %xmm9,%xmm9,%xmm9
  43db79:	mov    $0xffffffff,%r12d
  43db7f:	kmovb  %r11d,%k2
  43db84:	jmp    43dbde <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x10e>
  43db86:	cs nopw 0x0(%rax,%rax,1)
  43db90:	vpcmpequq %zmm9,%zmm7,%k5{%k2}
  43db97:	lea    (%r9,%rdx,1),%rsi
  43db9b:	mov    %rdx,%rbx
  43db9e:	lea    0x20(%rdx),%rdx
  43dba2:	and    %r8,%rdx
  43dba5:	kortestb %k5,%k5
  43dba9:	jne    43dce0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x210>
  43dbaf:	mov    %r12,%rbx
  43dbb2:	crc32q 0x18(%rcx),%rbx
  43dbb9:	mov    %r13d,%edi
  43dbbc:	and    %ebx,%edi
  43dbbe:	vmovd  %edi,%xmm10
  43dbc2:	shl    $0x4,%rdi
  43dbc6:	prefetcht2 (%r10,%rdi,1)
  43dbcb:	vpinsrd $0x1,0x14(%rcx),%xmm10,%xmm11
  43dbd2:	mov    %rbx,0x18(%rsi)
  43dbd6:	mov    %r11,(%rsi)
  43dbd9:	vmovq  %xmm11,0x10(%rsi)
  43dbde:	lea    (%r9,%rax,1),%rcx
  43dbe2:	mov    0x10(%rcx),%edi
  43dbe5:	mov    (%rcx),%r11
  43dbe8:	shl    $0x4,%rdi
  43dbec:	lea    0x100(%rax),%rbx
  43dbf3:	vmovdqa64 (%r10,%rdi,1),%zmm7
  43dbfa:	and    %r8,%rbx
  43dbfd:	vpbroadcastq %r11,%zmm8
  43dc03:	vpcmpequq %zmm8,%zmm7,%k1{%k2}
  43dc0a:	mov    0x10(%r9,%rbx,1),%esi
  43dc0f:	add    $0x20,%rax
  43dc13:	shl    $0x4,%rsi
  43dc17:	and    %r8,%rax
  43dc1a:	prefetcht0 (%r10,%rsi,1)
  43dc1f:	kortestb %k1,%k1
  43dc23:	je     43db90 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xc0>
  43dc29:	mov    0x14(%rcx),%ecx
  43dc2c:	kshiftlb $0x1,%k1,%k6
  43dc32:	vpcompressq %zmm7,%zmm0{%k6}{z}
  43dc38:	mov    %ecx,(%r15)
  43dc3b:	vmovq  %xmm0,0x8(%r15)
  43dc41:	add    $0x10,%r15
  43dc45:	mov    (%r14),%rbx
  43dc48:	mov    %r12,%rsi
  43dc4b:	crc32  %rbx,%rsi
  43dc51:	mov    %r13d,%r11d
  43dc54:	and    %esi,%r11d
  43dc57:	vmovd  %r11d,%xmm13
  43dc5c:	vpinsrd $0x1,0x10(%r14),%xmm13,%xmm14
  43dc63:	mov    %r11d,%edi
  43dc66:	lea    (%r9,%rdx,1),%rcx
  43dc6a:	shl    $0x4,%rdi
  43dc6e:	add    $0x20,%rdx
  43dc72:	add    $0x18,%r14
  43dc76:	prefetcht2 (%r10,%rdi,1)
  43dc7b:	and    %r8,%rdx
  43dc7e:	mov    %rbx,(%rcx)
  43dc81:	mov    %rsi,0x18(%rcx)
  43dc85:	vmovq  %xmm14,0x10(%rcx)
  43dc8a:	cmp    -0x8(%rsp),%r14
  43dc8f:	jne    43dbde <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x10e>
  43dc95:	mov    -0x10(%rsp),%r8d
  43dc9a:	sub    %r8,-0x18(%rsp)
  43dc9f:	vzeroupper 
  43dca2:	vmovq  %rdx,%xmm15
  43dca7:	vpinsrq $0x1,%rax,%xmm15,%xmm2
  43dcad:	mov    -0x20(%rsp),%rax
  43dcb2:	mov    -0x28(%rsp),%r9
  43dcb7:	mov    -0x18(%rsp),%r10d
  43dcbc:	vpsrlq $0x5,%xmm2,%xmm1
  43dcc1:	vpmovqd %xmm1,0xb0(%rax)
  43dcc8:	add    %r10d,(%r9)
  43dccb:	lea    -0x28(%rbp),%rsp
  43dccf:	pop    %rbx
  43dcd0:	pop    %r12
  43dcd2:	pop    %r13
  43dcd4:	pop    %r14
  43dcd6:	pop    %r15
  43dcd8:	pop    %rbp
  43dcd9:	ret    
  43dcda:	nopw   0x0(%rax,%rax,1)
  43dce0:	incl   -0x10(%rsp)
  43dce4:	mov    %rbx,%rdx
  43dce7:	jmp    43dc45 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x175>
  43dcec:	cmp    -0x8(%rsp),%r14
  43dcf1:	je     43dccb <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1fb>
  43dcf3:	mov    0x60(%rbx),%r8
  43dcf7:	mov    0xa0(%rbx),%r10
  43dcfe:	mov    %rbx,%r9
  43dd01:	mov    0x88(%rbx),%rbx
  43dd08:	mov    %r13,-0x18(%rsp)
  43dd0d:	dec    %rbx
  43dd10:	mov    %rbx,-0x20(%rsp)
  43dd15:	mov    %r8,-0x10(%rsp)
  43dd1a:	mov    0x54117(%rip),%r11        # 491e38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43dd21:	mov    0x54100(%rip),%r12        # 491e28 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_>
  43dd28:	mov    -0x28(%rsp),%r13
  43dd2d:	mov    %ecx,%r15d
  43dd30:	vpxor  %xmm2,%xmm2,%xmm2
  43dd34:	kmovb  0x540e4(%rip),%k0        # 491e20 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_exists_>
  43dd3c:	jmp    43ddc1 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2f1>
  43dd41:	cmpq   $0x8,-0x10(%rsp)
  43dd47:	jne    43dd59 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x289>
  43dd49:	mov    $0xffffffff,%eax
  43dd4e:	crc32q (%r14),%rax
  43dd54:	mov    %rax,-0x30(%rsp)
  43dd59:	mov    -0x30(%rsp),%rbx
  43dd5e:	mov    -0x20(%rsp),%r15
  43dd63:	mov    %ecx,%eax
  43dd65:	and    %rbx,%r15
  43dd68:	and    $0xfffffffffffffffc,%r15
  43dd6c:	vmovd  %r15d,%xmm5
  43dd71:	mov    (%r14),%rdx
  43dd74:	vpinsrd $0x1,0x10(%r14),%xmm5,%xmm4
  43dd7b:	mov    %r15,%rsi
  43dd7e:	shl    $0x5,%rax
  43dd82:	lea    0x1(%rcx),%r15d
  43dd86:	add    %r10,%rax
  43dd89:	shl    $0x4,%rsi
  43dd8d:	and    %edi,%r15d
  43dd90:	add    $0x18,%r14
  43dd94:	prefetcht2 (%r11,%rsi,1)
  43dd99:	mov    %rdx,(%rax)
  43dd9c:	mov    %rbx,0x18(%rax)
  43dda0:	vmovq  %xmm4,0x10(%rax)
  43dda5:	mov    %r15d,0xb0(%r9)
  43ddac:	cmp    %r14,-0x8(%rsp)
  43ddb1:	je     43df77 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x4a7>
  43ddb7:	mov    0xb4(%r9),%eax
  43ddbe:	mov    %r15d,%ecx
  43ddc1:	sub    %eax,%r15d
  43ddc4:	and    %edi,%r15d
  43ddc7:	cmp    %r15d,%edi
  43ddca:	jbe    43de87 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x3b7>
  43ddd0:	cmpq   $0x4,-0x10(%rsp)
  43ddd6:	jne    43dd41 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x271>
  43dddc:	mov    $0xffffffff,%edx
  43dde1:	crc32l (%r14),%edx
  43dde7:	mov    %edx,%r8d
  43ddea:	mov    %r8,-0x30(%rsp)
  43ddef:	jmp    43dd59 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x289>
  43ddf4:	vpcmpequq %zmm2,%zmm0,%k4
  43ddfb:	kmovb  %k4,%r15d
  43ddff:	and    $0x55,%r15d
  43de03:	jne    43df4e <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x47e>
  43de09:	cmpq   $0x4,-0x10(%rsp)
  43de0f:	mov    0x18(%rdx),%r8
  43de13:	je     43df5e <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x48e>
  43de19:	mov    -0x18(%rsp),%r15
  43de1e:	mov    $0xffffffff,%esi
  43de23:	cmpq   $0x8,-0x10(%rsp)
  43de29:	crc32  %r8,%rsi
  43de2f:	cmove  %rsi,%r15
  43de33:	mov    %r15,-0x18(%rsp)
  43de38:	mov    -0x20(%rsp),%r8
  43de3d:	mov    %ecx,%esi
  43de3f:	and    %r15,%r8
  43de42:	and    $0xfffffffffffffffc,%r8
  43de46:	shl    $0x5,%rsi
  43de4a:	add    %r10,%rsi
  43de4d:	vmovd  %r8d,%xmm6
  43de52:	mov    %r15,0x18(%rsi)
  43de56:	vpinsrd $0x1,0x14(%rdx),%xmm6,%xmm3
  43de5d:	mov    %r8,%r15
  43de60:	inc    %ecx
  43de62:	inc    %eax
  43de64:	shl    $0x4,%r15
  43de68:	and    %edi,%ecx
  43de6a:	and    %edi,%eax
  43de6c:	prefetcht2 (%r11,%r15,1)
  43de71:	mov    %rbx,(%rsi)
  43de74:	vmovq  %xmm3,0x10(%rsi)
  43de79:	mov    %ecx,0xb0(%r9)
  43de80:	mov    %eax,0xb4(%r9)
  43de87:	lea    0x8(%rax),%edx
  43de8a:	and    %edi,%edx
  43de8c:	shl    $0x5,%rdx
  43de90:	mov    0x10(%r10,%rdx,1),%r15d
  43de95:	mov    %eax,%edx
  43de97:	shl    $0x5,%rdx
  43de9b:	add    %r10,%rdx
  43de9e:	mov    (%rdx),%rbx
  43dea1:	shl    $0x4,%r15
  43dea5:	prefetcht0 (%r11,%r15,1)
  43deaa:	cmp    0x90(%r9),%rbx
  43deb1:	jne    43def0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x420>
  43deb3:	kortestb %k0,%k0
  43deb7:	je     43ded8 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x408>
  43deb9:	mov    0x0(%r13),%ebx
  43debd:	mov    0x14(%rdx),%esi
  43dec0:	mov    %rbx,%r15
  43dec3:	shl    $0x4,%rbx
  43dec7:	add    0x8(%r13),%rbx
  43decb:	inc    %r15d
  43dece:	mov    %esi,(%rbx)
  43ded0:	mov    %r12,0x8(%rbx)
  43ded4:	mov    %r15d,0x0(%r13)
  43ded8:	inc    %eax
  43deda:	and    %edi,%eax
  43dedc:	mov    %eax,0xb4(%r9)
  43dee3:	test   %r12,%r12
  43dee6:	jne    43de87 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x3b7>
  43dee8:	jmp    43ddd0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x300>
  43deed:	nopl   (%rax)
  43def0:	mov    0x10(%rdx),%r8d
  43def4:	vpbroadcastq %rbx,%zmm1
  43defa:	shl    $0x4,%r8
  43defe:	add    %r11,%r8
  43df01:	vmovdqa64 (%r8),%zmm0
  43df07:	vpcmpequq %zmm1,%zmm0,%k3
  43df0e:	kmovb  %k3,%esi
  43df12:	and    $0x55,%esi
  43df15:	je     43ddf4 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x324>
  43df1b:	movzbl %sil,%ebx
  43df1f:	xor    %esi,%esi
  43df21:	tzcnt  %ebx,%esi
  43df25:	mov    0x0(%r13),%ebx
  43df29:	mov    0x14(%rdx),%edx
  43df2c:	mov    %rbx,%r15
  43df2f:	shl    $0x4,%rbx
  43df33:	add    0x8(%r13),%rbx
  43df37:	lea    0x1(%rsi),%esi
  43df3a:	mov    %edx,(%rbx)
  43df3c:	movslq %esi,%rdx
  43df3f:	mov    (%r8,%rdx,8),%r8
  43df43:	inc    %r15d
  43df46:	mov    %r8,0x8(%rbx)
  43df4a:	mov    %r15d,0x0(%r13)
  43df4e:	inc    %eax
  43df50:	and    %edi,%eax
  43df52:	mov    %eax,0xb4(%r9)
  43df59:	jmp    43ddd0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x300>
  43df5e:	mov    $0xffffffff,%r15d
  43df64:	crc32  %r8d,%r15d
  43df6a:	mov    %r15d,%r15d
  43df6d:	mov    %r15,-0x18(%rsp)
  43df72:	jmp    43de38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x368>
  43df77:	vzeroupper 
  43df7a:	jmp    43dccb <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1fb>
  43df7f:	nop
