000000000043db30 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)>:
  43db30:	push   %rbp
  43db31:	mov    %rsp,%rbp
  43db34:	push   %r15
  43db36:	push   %r14
  43db38:	push   %r13
  43db3a:	push   %r12
  43db3c:	push   %rbx
  43db3d:	mov    %rdi,%rbx
  43db40:	and    $0xffffffffffffffc0,%rsp
  43db44:	mov    %rdi,-0x20(%rsp)
  43db49:	mov    %rdx,-0x28(%rsp)
  43db4e:	mov    0xb0(%rdi),%ecx
  43db54:	mov    0xb4(%rdi),%eax
  43db5a:	mov    0x8(%rsi),%r15
  43db5e:	mov    (%rsi),%r14
  43db61:	mov    0x78(%rdi),%edi
  43db64:	mov    0x6c(%rbx),%r8d
  43db68:	mov    %ecx,%r11d
  43db6b:	lea    (%r15,%r15,2),%rsi
  43db6f:	sub    %eax,%r11d
  43db72:	lea    (%r14,%rsi,8),%r10
  43db76:	and    %edi,%r11d
  43db79:	lea    -0x1(%r8),%r9d
  43db7d:	mov    %r15,-0x18(%rsp)
  43db82:	mov    %r10,-0x8(%rsp)
  43db87:	cmp    %r9d,%r11d
  43db8a:	jb     43dd4c <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x21c>
  43db90:	mov    %rdx,%rdi
  43db93:	shl    $0x5,%r8
  43db97:	mov    %ecx,%edx
  43db99:	mov    0xa0(%rbx),%r9
  43dba0:	mov    0x8(%rdi),%r15
  43dba4:	dec    %r8
  43dba7:	shl    $0x5,%rax
  43dbab:	shl    $0x5,%rdx
  43dbaf:	cmp    %r10,%r14
  43dbb2:	je     43dd02 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1d2>
  43dbb8:	mov    $0x55,%r11d
  43dbbe:	movl   $0x0,-0x10(%rsp)
  43dbc6:	mov    0x5326b(%rip),%r10        # 490e38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43dbcd:	mov    0x80(%rbx),%r13d
  43dbd4:	vpxor  %xmm9,%xmm9,%xmm9
  43dbd9:	mov    $0xffffffff,%r12d
  43dbdf:	kmovb  %r11d,%k2
  43dbe4:	jmp    43dc3e <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x10e>
  43dbe6:	cs nopw 0x0(%rax,%rax,1)
  43dbf0:	vpcmpequq %zmm9,%zmm7,%k5{%k2}
  43dbf7:	lea    (%r9,%rdx,1),%rsi
  43dbfb:	mov    %rdx,%rbx
  43dbfe:	lea    0x20(%rdx),%rdx
  43dc02:	and    %r8,%rdx
  43dc05:	kortestb %k5,%k5
  43dc09:	jne    43dd40 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x210>
  43dc0f:	mov    %r12,%rbx
  43dc12:	crc32q 0x18(%rcx),%rbx
  43dc19:	mov    %r13d,%edi
  43dc1c:	and    %ebx,%edi
  43dc1e:	vmovd  %edi,%xmm10
  43dc22:	shl    $0x4,%rdi
  43dc26:	prefetcht2 (%r10,%rdi,1)
  43dc2b:	vpinsrd $0x1,0x14(%rcx),%xmm10,%xmm11
  43dc32:	mov    %rbx,0x18(%rsi)
  43dc36:	mov    %r11,(%rsi)
  43dc39:	vmovq  %xmm11,0x10(%rsi)
  43dc3e:	lea    (%r9,%rax,1),%rcx
  43dc42:	mov    0x10(%rcx),%edi
  43dc45:	mov    (%rcx),%r11
  43dc48:	shl    $0x4,%rdi
  43dc4c:	lea    0x100(%rax),%rbx
  43dc53:	vmovdqa64 (%r10,%rdi,1),%zmm7
  43dc5a:	and    %r8,%rbx
  43dc5d:	vpbroadcastq %r11,%zmm8
  43dc63:	vpcmpequq %zmm8,%zmm7,%k1{%k2}
  43dc6a:	mov    0x10(%r9,%rbx,1),%esi
  43dc6f:	add    $0x20,%rax
  43dc73:	shl    $0x4,%rsi
  43dc77:	and    %r8,%rax
  43dc7a:	prefetcht0 (%r10,%rsi,1)
  43dc7f:	kortestb %k1,%k1
  43dc83:	je     43dbf0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xc0>
  43dc89:	mov    0x14(%rcx),%ecx
  43dc8c:	kshiftlb $0x1,%k1,%k6
  43dc92:	vpcompressq %zmm7,%zmm0{%k6}{z}
  43dc98:	mov    %ecx,(%r15)
  43dc9b:	vmovq  %xmm0,0x8(%r15)
  43dca1:	add    $0x10,%r15
  43dca5:	mov    (%r14),%rbx
  43dca8:	mov    %r12,%rsi
  43dcab:	crc32  %rbx,%rsi
  43dcb1:	mov    %r13d,%r11d
  43dcb4:	and    %esi,%r11d
  43dcb7:	vmovd  %r11d,%xmm13
  43dcbc:	vpinsrd $0x1,0x10(%r14),%xmm13,%xmm14
  43dcc3:	mov    %r11d,%edi
  43dcc6:	lea    (%r9,%rdx,1),%rcx
  43dcca:	shl    $0x4,%rdi
  43dcce:	add    $0x20,%rdx
  43dcd2:	add    $0x18,%r14
  43dcd6:	prefetcht2 (%r10,%rdi,1)
  43dcdb:	and    %r8,%rdx
  43dcde:	mov    %rbx,(%rcx)
  43dce1:	mov    %rsi,0x18(%rcx)
  43dce5:	vmovq  %xmm14,0x10(%rcx)
  43dcea:	cmp    -0x8(%rsp),%r14
  43dcef:	jne    43dc3e <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x10e>
  43dcf5:	mov    -0x10(%rsp),%r8d
  43dcfa:	sub    %r8,-0x18(%rsp)
  43dcff:	vzeroupper 
  43dd02:	vmovq  %rdx,%xmm15
  43dd07:	vpinsrq $0x1,%rax,%xmm15,%xmm2
  43dd0d:	mov    -0x20(%rsp),%rax
  43dd12:	mov    -0x28(%rsp),%r9
  43dd17:	mov    -0x18(%rsp),%r10d
  43dd1c:	vpsrlq $0x5,%xmm2,%xmm1
  43dd21:	vpmovqd %xmm1,0xb0(%rax)
  43dd28:	add    %r10d,(%r9)
  43dd2b:	lea    -0x28(%rbp),%rsp
  43dd2f:	pop    %rbx
  43dd30:	pop    %r12
  43dd32:	pop    %r13
  43dd34:	pop    %r14
  43dd36:	pop    %r15
  43dd38:	pop    %rbp
  43dd39:	ret    
  43dd3a:	nopw   0x0(%rax,%rax,1)
  43dd40:	incl   -0x10(%rsp)
  43dd44:	mov    %rbx,%rdx
  43dd47:	jmp    43dca5 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x175>
  43dd4c:	cmp    -0x8(%rsp),%r14
  43dd51:	je     43dd2b <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1fb>
  43dd53:	mov    0x60(%rbx),%r8
  43dd57:	mov    0xa0(%rbx),%r10
  43dd5e:	mov    %rbx,%r9
  43dd61:	mov    0x88(%rbx),%rbx
  43dd68:	mov    %r13,-0x18(%rsp)
  43dd6d:	dec    %rbx
  43dd70:	mov    %rbx,-0x20(%rsp)
  43dd75:	mov    %r8,-0x10(%rsp)
  43dd7a:	mov    0x530b7(%rip),%r11        # 490e38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43dd81:	mov    0x530a0(%rip),%r12        # 490e28 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_>
  43dd88:	mov    -0x28(%rsp),%r13
  43dd8d:	mov    %ecx,%r15d
  43dd90:	vpxor  %xmm2,%xmm2,%xmm2
  43dd94:	kmovb  0x53084(%rip),%k0        # 490e20 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_exists_>
  43dd9c:	jmp    43de21 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2f1>
  43dda1:	cmpq   $0x8,-0x10(%rsp)
  43dda7:	jne    43ddb9 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x289>
  43dda9:	mov    $0xffffffff,%eax
  43ddae:	crc32q (%r14),%rax
  43ddb4:	mov    %rax,-0x30(%rsp)
  43ddb9:	mov    -0x30(%rsp),%rbx
  43ddbe:	mov    -0x20(%rsp),%r15
  43ddc3:	mov    %ecx,%eax
  43ddc5:	and    %rbx,%r15
  43ddc8:	and    $0xfffffffffffffffc,%r15
  43ddcc:	vmovd  %r15d,%xmm5
  43ddd1:	mov    (%r14),%rdx
  43ddd4:	vpinsrd $0x1,0x10(%r14),%xmm5,%xmm4
  43dddb:	mov    %r15,%rsi
  43ddde:	shl    $0x5,%rax
  43dde2:	lea    0x1(%rcx),%r15d
  43dde6:	add    %r10,%rax
  43dde9:	shl    $0x4,%rsi
  43dded:	and    %edi,%r15d
  43ddf0:	add    $0x18,%r14
  43ddf4:	prefetcht2 (%r11,%rsi,1)
  43ddf9:	mov    %rdx,(%rax)
  43ddfc:	mov    %rbx,0x18(%rax)
  43de00:	vmovq  %xmm4,0x10(%rax)
  43de05:	mov    %r15d,0xb0(%r9)
  43de0c:	cmp    %r14,-0x8(%rsp)
  43de11:	je     43dfd7 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x4a7>
  43de17:	mov    0xb4(%r9),%eax
  43de1e:	mov    %r15d,%ecx
  43de21:	sub    %eax,%r15d
  43de24:	and    %edi,%r15d
  43de27:	cmp    %r15d,%edi
  43de2a:	jbe    43dee7 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x3b7>
  43de30:	cmpq   $0x4,-0x10(%rsp)
  43de36:	jne    43dda1 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x271>
  43de3c:	mov    $0xffffffff,%edx
  43de41:	crc32l (%r14),%edx
  43de47:	mov    %edx,%r8d
  43de4a:	mov    %r8,-0x30(%rsp)
  43de4f:	jmp    43ddb9 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x289>
  43de54:	vpcmpequq %zmm2,%zmm0,%k4
  43de5b:	kmovb  %k4,%r15d
  43de5f:	and    $0x55,%r15d
  43de63:	jne    43dfae <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x47e>
  43de69:	cmpq   $0x4,-0x10(%rsp)
  43de6f:	mov    0x18(%rdx),%r8
  43de73:	je     43dfbe <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x48e>
  43de79:	mov    -0x18(%rsp),%r15
  43de7e:	mov    $0xffffffff,%esi
  43de83:	cmpq   $0x8,-0x10(%rsp)
  43de89:	crc32  %r8,%rsi
  43de8f:	cmove  %rsi,%r15
  43de93:	mov    %r15,-0x18(%rsp)
  43de98:	mov    -0x20(%rsp),%r8
  43de9d:	mov    %ecx,%esi
  43de9f:	and    %r15,%r8
  43dea2:	and    $0xfffffffffffffffc,%r8
  43dea6:	shl    $0x5,%rsi
  43deaa:	add    %r10,%rsi
  43dead:	vmovd  %r8d,%xmm6
  43deb2:	mov    %r15,0x18(%rsi)
  43deb6:	vpinsrd $0x1,0x14(%rdx),%xmm6,%xmm3
  43debd:	mov    %r8,%r15
  43dec0:	inc    %ecx
  43dec2:	inc    %eax
  43dec4:	shl    $0x4,%r15
  43dec8:	and    %edi,%ecx
  43deca:	and    %edi,%eax
  43decc:	prefetcht2 (%r11,%r15,1)
  43ded1:	mov    %rbx,(%rsi)
  43ded4:	vmovq  %xmm3,0x10(%rsi)
  43ded9:	mov    %ecx,0xb0(%r9)
  43dee0:	mov    %eax,0xb4(%r9)
  43dee7:	lea    0x8(%rax),%edx
  43deea:	and    %edi,%edx
  43deec:	shl    $0x5,%rdx
  43def0:	mov    0x10(%r10,%rdx,1),%r15d
  43def5:	mov    %eax,%edx
  43def7:	shl    $0x5,%rdx
  43defb:	add    %r10,%rdx
  43defe:	mov    (%rdx),%rbx
  43df01:	shl    $0x4,%r15
  43df05:	prefetcht0 (%r11,%r15,1)
  43df0a:	cmp    0x90(%r9),%rbx
  43df11:	jne    43df50 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x420>
  43df13:	kortestb %k0,%k0
  43df17:	je     43df38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x408>
  43df19:	mov    0x0(%r13),%ebx
  43df1d:	mov    0x14(%rdx),%esi
  43df20:	mov    %rbx,%r15
  43df23:	shl    $0x4,%rbx
  43df27:	add    0x8(%r13),%rbx
  43df2b:	inc    %r15d
  43df2e:	mov    %esi,(%rbx)
  43df30:	mov    %r12,0x8(%rbx)
  43df34:	mov    %r15d,0x0(%r13)
  43df38:	inc    %eax
  43df3a:	and    %edi,%eax
  43df3c:	mov    %eax,0xb4(%r9)
  43df43:	test   %r12,%r12
  43df46:	jne    43dee7 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x3b7>
  43df48:	jmp    43de30 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x300>
  43df4d:	nopl   (%rax)
  43df50:	mov    0x10(%rdx),%r8d
  43df54:	vpbroadcastq %rbx,%zmm1
  43df5a:	shl    $0x4,%r8
  43df5e:	add    %r11,%r8
  43df61:	vmovdqa64 (%r8),%zmm0
  43df67:	vpcmpequq %zmm1,%zmm0,%k3
  43df6e:	kmovb  %k3,%esi
  43df72:	and    $0x55,%esi
  43df75:	je     43de54 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x324>
  43df7b:	movzbl %sil,%ebx
  43df7f:	xor    %esi,%esi
  43df81:	tzcnt  %ebx,%esi
  43df85:	mov    0x0(%r13),%ebx
  43df89:	mov    0x14(%rdx),%edx
  43df8c:	mov    %rbx,%r15
  43df8f:	shl    $0x4,%rbx
  43df93:	add    0x8(%r13),%rbx
  43df97:	lea    0x1(%rsi),%esi
  43df9a:	mov    %edx,(%rbx)
  43df9c:	movslq %esi,%rdx
  43df9f:	mov    (%r8,%rdx,8),%r8
  43dfa3:	inc    %r15d
  43dfa6:	mov    %r8,0x8(%rbx)
  43dfaa:	mov    %r15d,0x0(%r13)
  43dfae:	inc    %eax
  43dfb0:	and    %edi,%eax
  43dfb2:	mov    %eax,0xb4(%r9)
  43dfb9:	jmp    43de30 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x300>
  43dfbe:	mov    $0xffffffff,%r15d
  43dfc4:	crc32  %r8d,%r15d
  43dfca:	mov    %r15d,%r15d
  43dfcd:	mov    %r15,-0x18(%rsp)
  43dfd2:	jmp    43de98 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x368>
  43dfd7:	vzeroupper 
  43dfda:	jmp    43dd2b <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1fb>
  43dfdf:	nop
