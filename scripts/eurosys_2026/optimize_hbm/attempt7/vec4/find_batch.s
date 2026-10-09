000000000043db70 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)>:
  43db70:	push   %rbp
  43db71:	mov    %rdx,%r11
  43db74:	mov    %rsp,%rbp
  43db77:	push   %r15
  43db79:	push   %r14
  43db7b:	push   %r13
  43db7d:	mov    %rdi,%r13
  43db80:	push   %r12
  43db82:	push   %rbx
  43db83:	mov    %rsi,%rbx
  43db86:	and    $0xffffffffffffffc0,%rsp
  43db8a:	mov    %rdx,-0x20(%rsp)
  43db8f:	mov    %rsi,-0x28(%rsp)
  43db94:	mov    0xb0(%rdi),%ecx
  43db9a:	mov    0xb4(%rdi),%eax
  43dba0:	mov    0x8(%rbx),%rdx
  43dba4:	mov    0x78(%rdi),%esi
  43dba7:	mov    0x6c(%rdi),%r8d
  43dbab:	mov    (%rbx),%r14
  43dbae:	mov    %ecx,%edi
  43dbb0:	lea    (%rdx,%rdx,2),%r9
  43dbb4:	sub    %eax,%edi
  43dbb6:	lea    (%r14,%r9,8),%r12
  43dbba:	and    %esi,%edi
  43dbbc:	lea    -0x1(%r8),%r10d
  43dbc0:	mov    %r12,-0x8(%rsp)
  43dbc5:	cmp    %r10d,%edi
  43dbc8:	jb     43e02e <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x4be>
  43dbce:	shl    $0x5,%r8
  43dbd2:	lea    -0x80(%r8),%rsi
  43dbd6:	mov    %rsi,-0x10(%rsp)
  43dbdb:	mov    0xa0(%r13),%r9
  43dbe2:	mov    0x8(%r11),%r15
  43dbe6:	lea    -0x1(%r8),%r10
  43dbea:	shl    $0x5,%rax
  43dbee:	shl    $0x5,%rcx
  43dbf2:	cmp    %r12,%r14
  43dbf5:	je     43ddcb <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x25b>
  43dbfb:	movl   $0x0,-0x18(%rsp)
  43dc03:	mov    0x5322e(%rip),%r8        # 490e38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43dc0a:	vmovdqa32 0x3cd6c(%rip),%zmm9        # 47a980 <std::_Sp_make_shared_tag::_S_ti()::__tag+0x20>
  43dc14:	vmovdqa64 0x3cda2(%rip),%zmm8        # 47a9c0 <std::_Sp_make_shared_tag::_S_ti()::__tag+0x60>
  43dc1e:	vmovdqa64 0x3cdd8(%rip),%zmm11        # 47aa00 <std::_Sp_make_shared_tag::_S_ti()::__tag+0xa0>
  43dc28:	mov    $0x55,%r11d
  43dc2e:	mov    $0xa,%ebx
  43dc33:	mov    $0xffffffa0,%edi
  43dc38:	mov    $0xffffffff,%r12d
  43dc3e:	vpxor  %xmm10,%xmm10,%xmm10
  43dc43:	kmovb  %r11d,%k1
  43dc48:	kmovb  %ebx,%k5
  43dc4c:	kmovb  %edi,%k6
  43dc50:	lea    0x100(%rax),%rsi
  43dc57:	and    %r10,%rsi
  43dc5a:	mov    0x10(%r9,%rsi,1),%edi
  43dc5f:	mov    -0x8(%rsp),%r11
  43dc64:	shl    $0x4,%rdi
  43dc68:	sub    %r14,%r11
  43dc6b:	lea    (%r9,%rax,1),%rdx
  43dc6f:	add    %r8,%rdi
  43dc72:	cmp    $0x48,%r11
  43dc76:	jle    43dc94 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x124>
  43dc78:	cmp    %rcx,%rax
  43dc7b:	mov    %rcx,%rbx
  43dc7e:	cmovae %rax,%rbx
  43dc82:	cmp    %rsi,%rbx
  43dc85:	cmovb  %rsi,%rbx
  43dc89:	cmp    %rbx,-0x10(%rsp)
  43dc8e:	jae    43de30 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x2c0>
  43dc94:	mov    0x10(%rdx),%esi
  43dc97:	shl    $0x4,%rsi
  43dc9b:	add    $0x20,%rax
  43dc9f:	vmovdqa64 (%r8,%rsi,1),%zmm3
  43dca6:	mov    0x80(%r13),%ebx
  43dcad:	vpcmpequq (%rdx){1to8},%zmm3,%k0{%k1}
  43dcb4:	and    %r10,%rax
  43dcb7:	prefetcht0 (%rdi)
  43dcba:	kmovb  %k0,%r11d
  43dcbe:	test   %r11b,%r11b
  43dcc1:	je     43dd47 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1d7>
  43dcc7:	jmp    43de00 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x290>
  43dccc:	nopl   0x0(%rax)
  43dcd0:	mov    %r12,%r11
  43dcd3:	crc32q 0x18(%rdx),%r11
  43dcda:	mov    %ebx,%edi
  43dcdc:	and    %r11d,%edi
  43dcdf:	vmovd  %edi,%xmm1
  43dce3:	vpinsrd $0x1,0x14(%rdx),%xmm1,%xmm7
  43dcea:	shl    $0x4,%rdi
  43dcee:	prefetcht2 (%r8,%rdi,1)
  43dcf3:	mov    %r11,0x18(%rsi)
  43dcf7:	mov    (%rdx),%r11
  43dcfa:	lea    0x100(%rax),%rdx
  43dd01:	vmovq  %xmm7,0x10(%rsi)
  43dd06:	and    %r10,%rdx
  43dd09:	mov    %r11,(%rsi)
  43dd0c:	mov    0x10(%r9,%rdx,1),%esi
  43dd11:	lea    (%r9,%rax,1),%rdx
  43dd15:	mov    0x10(%rdx),%edi
  43dd18:	shl    $0x4,%rsi
  43dd1c:	shl    $0x4,%rdi
  43dd20:	add    $0x20,%rax
  43dd24:	vmovdqa64 (%r8,%rdi,1),%zmm3
  43dd2b:	and    %r10,%rax
  43dd2e:	vpcmpequq (%rdx){1to8},%zmm3,%k2{%k1}
  43dd35:	prefetcht0 (%r8,%rsi,1)
  43dd3a:	kmovb  %k2,%r11d
  43dd3e:	test   %r11b,%r11b
  43dd41:	jne    43de00 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x290>
  43dd47:	vpcmpequq %zmm10,%zmm3,%k3{%k1}
  43dd4e:	lea    (%r9,%rcx,1),%rsi
  43dd52:	mov    %rcx,%r11
  43dd55:	lea    0x20(%rcx),%rcx
  43dd59:	and    %r10,%rcx
  43dd5c:	kortestb %k3,%k3
  43dd60:	je     43dcd0 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x160>
  43dd66:	incl   -0x18(%rsp)
  43dd6a:	mov    %r11,%rcx
  43dd6d:	mov    (%r14),%r11
  43dd70:	mov    %r12,%rdx
  43dd73:	crc32  %r11,%rdx
  43dd79:	and    %edx,%ebx
  43dd7b:	mov    %ebx,%edi
  43dd7d:	lea    (%r9,%rcx,1),%rsi
  43dd81:	shl    $0x4,%rdi
  43dd85:	vmovd  %ebx,%xmm5
  43dd89:	prefetcht2 (%r8,%rdi,1)
  43dd8e:	vpinsrd $0x1,0x10(%r14),%xmm5,%xmm12
  43dd95:	mov    %r11,(%rsi)
  43dd98:	mov    %rdx,0x18(%rsi)
  43dd9c:	add    $0x20,%rcx
  43dda0:	vmovq  %xmm12,0x10(%rsi)
  43dda5:	and    %r10,%rcx
  43dda8:	add    $0x18,%r14
  43ddac:	cmp    -0x8(%rsp),%r14
  43ddb1:	jne    43dc50 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0xe0>
  43ddb7:	mov    -0x28(%rsp),%r9
  43ddbc:	mov    -0x18(%rsp),%r14d
  43ddc1:	mov    0x8(%r9),%rdx
  43ddc5:	sub    %r14,%rdx
  43ddc8:	vzeroupper 
  43ddcb:	vmovq  %rcx,%xmm10
  43ddd0:	vpinsrq $0x1,%rax,%xmm10,%xmm9
  43ddd6:	vpsrlq $0x5,%xmm9,%xmm8
  43dddc:	vpmovqd %xmm8,0xb0(%r13)
  43dde3:	mov    -0x20(%rsp),%r13
  43dde8:	add    %edx,0x0(%r13)
  43ddec:	lea    -0x28(%rbp),%rsp
  43ddf0:	pop    %rbx
  43ddf1:	pop    %r12
  43ddf3:	pop    %r13
  43ddf5:	pop    %r14
  43ddf7:	pop    %r15
  43ddf9:	pop    %rbp
  43ddfa:	ret    
  43ddfb:	nopl   0x0(%rax,%rax,1)
  43de00:	mov    0x14(%rdx),%esi
  43de03:	kmovb  %r11d,%k7
  43de08:	kshiftlb $0x1,%k7,%k4
  43de0e:	vpcompressq %zmm3,%zmm0{%k4}{z}
  43de14:	mov    %esi,(%r15)
  43de17:	vmovq  %xmm0,0x8(%r15)
  43de1d:	add    $0x10,%r15
  43de21:	jmp    43dd6d <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x1fd>
  43de26:	cs nopw 0x0(%rax,%rax,1)
  43de30:	mov    0x30(%r9,%rsi,1),%r11d
  43de35:	mov    0x50(%r9,%rsi,1),%ebx
  43de3a:	mov    0x70(%r9,%rsi,1),%esi
  43de3f:	shl    $0x4,%rbx
  43de43:	shl    $0x4,%rsi
  43de47:	prefetcht0 (%r8,%rsi,1)
  43de4c:	mov    0x10(%rdx),%esi
  43de4f:	shl    $0x4,%r11
  43de53:	prefetcht0 (%r8,%rbx,1)
  43de58:	mov    0x30(%rdx),%ebx
  43de5b:	prefetcht0 (%r8,%r11,1)
  43de60:	mov    %rsi,%r11
  43de63:	shl    $0x4,%r11
  43de67:	shl    $0x4,%rbx
  43de6b:	vmovdqa64 (%r8,%r11,1),%zmm12
  43de72:	vmovdqa64 (%r8,%rbx,1),%zmm13
  43de79:	mov    0x50(%rdx),%r11d
  43de7d:	mov    0x70(%rdx),%ebx
  43de80:	shl    $0x4,%r11
  43de84:	shl    $0x4,%rbx
  43de88:	vmovdqa64 (%r8,%r11,1),%zmm14
  43de8f:	vmovdqa64 (%r8,%rbx,1),%zmm15
  43de96:	vpcmpequq (%rdx){1to8},%zmm12,%k3{%k1}
  43de9d:	vpcmpequq 0x40(%rdx){1to8},%zmm14,%k7{%k1}
  43dea5:	vpcmpequq 0x20(%rdx){1to8},%zmm13,%k2{%k1}
  43dead:	vpcmpequq 0x60(%rdx){1to8},%zmm15,%k4{%k1}
  43deb5:	kortestb %k2,%k2
  43deb9:	setne  %bl
  43debc:	kortestb %k3,%k3
  43dec0:	setne  %r11b
  43dec4:	and    %ebx,%r11d
  43dec7:	kortestb %k7,%k7
  43decb:	setne  %bl
  43dece:	prefetcht0 (%rdi)
  43ded1:	test   %bl,%r11b
  43ded4:	je     43dc97 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x127>
  43deda:	kortestb %k4,%k4
  43dede:	je     43dc97 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x127>
  43dee4:	vmovdqu32 (%rdx),%zmm0
  43deea:	kshiftlb $0x1,%k3,%k3
  43def0:	kshiftlb $0x1,%k2,%k2
  43def6:	vpcompressq %zmm12,%zmm2{%k3}{z}
  43defc:	vpcompressq %zmm13,%zmm6{%k2}{z}
  43df02:	vpermt2d 0x40(%rdx),%zmm9,%zmm0
  43df09:	vpermt2q %zmm6,%zmm8,%zmm2
  43df0f:	kshiftlb $0x1,%k7,%k7
  43df15:	kshiftlb $0x1,%k4,%k4
  43df1b:	vpcompressq %zmm14,%zmm1{%k7}{z}
  43df21:	vpcompressq %zmm15,%zmm7{%k4}{z}
  43df27:	vmovdqa64 %zmm2,%zmm0{%k5}
  43df2d:	vpermt2q %zmm7,%zmm11,%zmm1
  43df33:	vmovdqa64 %zmm1,%zmm0{%k6}
  43df39:	vmovdqu64 %zmm0,(%r15)
  43df3f:	mov    0x80(%r13),%rdx
  43df46:	mov    (%r14),%rbx
  43df49:	mov    %r12,%r11
  43df4c:	crc32  %rbx,%r11
  43df52:	mov    %edx,%edi
  43df54:	and    %r11d,%edi
  43df57:	lea    (%r9,%rcx,1),%rsi
  43df5b:	vmovd  %edi,%xmm5
  43df5f:	shl    $0x4,%rdi
  43df63:	prefetcht2 (%r8,%rdi,1)
  43df68:	mov    %rbx,(%rsi)
  43df6b:	mov    0x18(%r14),%rbx
  43df6f:	vpinsrd $0x1,0x10(%r14),%xmm5,%xmm12
  43df76:	mov    %r11,0x18(%rsi)
  43df7a:	mov    %r12,%r11
  43df7d:	crc32  %rbx,%r11
  43df83:	mov    %edx,%edi
  43df85:	and    %r11d,%edi
  43df88:	vmovd  %edi,%xmm13
  43df8c:	shl    $0x4,%rdi
  43df90:	prefetcht2 (%r8,%rdi,1)
  43df95:	vmovq  %xmm12,0x10(%rsi)
  43df9a:	mov    %rbx,0x20(%rsi)
  43df9e:	mov    0x30(%r14),%rbx
  43dfa2:	vpinsrd $0x1,0x28(%r14),%xmm13,%xmm14
  43dfa9:	mov    %r11,0x38(%rsi)
  43dfad:	mov    %r12,%r11
  43dfb0:	crc32  %rbx,%r11
  43dfb6:	mov    %edx,%edi
  43dfb8:	and    %r11d,%edi
  43dfbb:	vmovq  %xmm14,0x30(%rsi)
  43dfc0:	vmovd  %edi,%xmm15
  43dfc4:	shl    $0x4,%rdi
  43dfc8:	prefetcht2 (%r8,%rdi,1)
  43dfcd:	vpinsrd $0x1,0x40(%r14),%xmm15,%xmm0
  43dfd4:	mov    %r11,0x58(%rsi)
  43dfd8:	mov    0x48(%r14),%r11
  43dfdc:	mov    %r12,%rdi
  43dfdf:	crc32  %r11,%rdi
  43dfe5:	and    %edi,%edx
  43dfe7:	vmovq  %xmm0,0x50(%rsi)
  43dfec:	vmovd  %edx,%xmm2
  43dff0:	vpinsrd $0x1,0x58(%r14),%xmm2,%xmm6
  43dff7:	mov    %rbx,0x40(%rsi)
  43dffb:	mov    %edx,%ebx
  43dffd:	shl    $0x4,%rbx
  43e001:	sub    $0xffffffffffffff80,%rax
  43e005:	sub    $0xffffffffffffff80,%rcx
  43e009:	prefetcht2 (%r8,%rbx,1)
  43e00e:	add    $0x40,%r15
  43e012:	mov    %r11,0x60(%rsi)
  43e016:	mov    %rdi,0x78(%rsi)
  43e01a:	vmovq  %xmm6,0x70(%rsi)
  43e01f:	and    %r10,%rax
  43e022:	and    %r10,%rcx
  43e025:	add    $0x48,%r14
  43e029:	jmp    43dda8 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x238>
  43e02e:	cmp    -0x8(%rsp),%r14
  43e033:	je     43ddec <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x27c>
  43e039:	mov    0x88(%r13),%rbx
  43e040:	mov    0x60(%r13),%rdx
  43e044:	dec    %rbx
  43e047:	mov    %rbx,-0x28(%rsp)
  43e04c:	mov    %rdx,-0x10(%rsp)
  43e051:	mov    %r15,-0x18(%rsp)
  43e056:	mov    0x52ddb(%rip),%r11        # 490e38 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::hashtable>
  43e05d:	mov    0x52dc4(%rip),%r12        # 490e28 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_>
  43e064:	mov    0xa0(%r13),%r10
  43e06b:	mov    -0x20(%rsp),%rbx
  43e070:	mov    %ecx,%r8d
  43e073:	vpxor  %xmm2,%xmm2,%xmm2
  43e077:	kmovb  0x52da1(%rip),%k0        # 490e20 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::empty_slot_exists_>
  43e07f:	jmp    43e104 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x594>
  43e084:	cmpq   $0x8,-0x10(%rsp)
  43e08a:	jne    43e09c <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x52c>
  43e08c:	mov    $0xffffffff,%eax
  43e091:	crc32q (%r14),%rax
  43e097:	mov    %rax,-0x30(%rsp)
  43e09c:	mov    -0x30(%rsp),%r15
  43e0a1:	mov    -0x28(%rsp),%r9
  43e0a6:	mov    %ecx,%eax
  43e0a8:	and    %r15,%r9
  43e0ab:	and    $0xfffffffffffffffc,%r9
  43e0af:	vmovd  %r9d,%xmm4
  43e0b4:	mov    (%r14),%rdx
  43e0b7:	vpinsrd $0x1,0x10(%r14),%xmm4,%xmm5
  43e0be:	mov    %r9,%rdi
  43e0c1:	shl    $0x5,%rax
  43e0c5:	lea    0x1(%rcx),%r8d
  43e0c9:	add    %r10,%rax
  43e0cc:	shl    $0x4,%rdi
  43e0d0:	and    %esi,%r8d
  43e0d3:	add    $0x18,%r14
  43e0d7:	prefetcht2 (%r11,%rdi,1)
  43e0dc:	mov    %rdx,(%rax)
  43e0df:	mov    %r15,0x18(%rax)
  43e0e3:	vmovq  %xmm5,0x10(%rax)
  43e0e8:	mov    %r8d,0xb0(%r13)
  43e0ef:	cmp    %r14,-0x8(%rsp)
  43e0f4:	je     43e2bf <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x74f>
  43e0fa:	mov    0xb4(%r13),%eax
  43e101:	mov    %r8d,%ecx
  43e104:	sub    %eax,%r8d
  43e107:	and    %esi,%r8d
  43e10a:	cmp    %r8d,%esi
  43e10d:	jbe    43e1ca <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x65a>
  43e113:	cmpq   $0x4,-0x10(%rsp)
  43e119:	jne    43e084 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x514>
  43e11f:	mov    $0xffffffff,%edx
  43e124:	crc32l (%r14),%edx
  43e12a:	mov    %edx,%r8d
  43e12d:	mov    %r8,-0x30(%rsp)
  43e132:	jmp    43e09c <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x52c>
  43e137:	vpcmpequq %zmm2,%zmm0,%k6
  43e13e:	kmovb  %k6,%r15d
  43e142:	and    $0x55,%r15d
  43e146:	jne    43e296 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x726>
  43e14c:	cmpq   $0x4,-0x10(%rsp)
  43e152:	mov    0x18(%rdx),%r8
  43e156:	je     43e2a6 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x736>
  43e15c:	mov    -0x18(%rsp),%r15
  43e161:	mov    $0xffffffff,%edi
  43e166:	cmpq   $0x8,-0x10(%rsp)
  43e16c:	crc32  %r8,%rdi
  43e172:	cmove  %rdi,%r15
  43e176:	mov    %r15,-0x18(%rsp)
  43e17b:	mov    -0x28(%rsp),%r8
  43e180:	mov    %ecx,%edi
  43e182:	and    %r15,%r8
  43e185:	and    $0xfffffffffffffffc,%r8
  43e189:	shl    $0x5,%rdi
  43e18d:	add    %r10,%rdi
  43e190:	vmovd  %r8d,%xmm7
  43e195:	mov    %r15,0x18(%rdi)
  43e199:	vpinsrd $0x1,0x14(%rdx),%xmm7,%xmm3
  43e1a0:	mov    %r8,%r15
  43e1a3:	inc    %ecx
  43e1a5:	inc    %eax
  43e1a7:	shl    $0x4,%r15
  43e1ab:	and    %esi,%ecx
  43e1ad:	and    %esi,%eax
  43e1af:	prefetcht2 (%r11,%r15,1)
  43e1b4:	mov    %r9,(%rdi)
  43e1b7:	vmovq  %xmm3,0x10(%rdi)
  43e1bc:	mov    %ecx,0xb0(%r13)
  43e1c3:	mov    %eax,0xb4(%r13)
  43e1ca:	lea    0x8(%rax),%r15d
  43e1ce:	and    %esi,%r15d
  43e1d1:	mov    %eax,%edx
  43e1d3:	shl    $0x5,%r15
  43e1d7:	shl    $0x5,%rdx
  43e1db:	mov    0x10(%r10,%r15,1),%r8d
  43e1e0:	add    %r10,%rdx
  43e1e3:	mov    (%rdx),%r9
  43e1e6:	shl    $0x4,%r8
  43e1ea:	prefetcht0 (%r11,%r8,1)
  43e1ef:	cmp    0x90(%r13),%r9
  43e1f6:	jne    43e238 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x6c8>
  43e1f8:	kortestb %k0,%k0
  43e1fc:	je     43e21c <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x6ac>
  43e1fe:	mov    (%rbx),%r9d
  43e201:	mov    0x14(%rdx),%edi
  43e204:	mov    %r9,%r15
  43e207:	shl    $0x4,%r9
  43e20b:	add    0x8(%rbx),%r9
  43e20f:	inc    %r15d
  43e212:	mov    %edi,(%r9)
  43e215:	mov    %r12,0x8(%r9)
  43e219:	mov    %r15d,(%rbx)
  43e21c:	inc    %eax
  43e21e:	and    %esi,%eax
  43e220:	mov    %eax,0xb4(%r13)
  43e227:	test   %r12,%r12
  43e22a:	jne    43e1ca <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x65a>
  43e22c:	jmp    43e113 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x5a3>
  43e231:	nopl   0x0(%rax)
  43e238:	mov    0x10(%rdx),%r8d
  43e23c:	vpbroadcastq %r9,%zmm1
  43e242:	shl    $0x4,%r8
  43e246:	add    %r11,%r8
  43e249:	vmovdqa64 (%r8),%zmm0
  43e24f:	vpcmpequq %zmm1,%zmm0,%k5
  43e256:	kmovb  %k5,%edi
  43e25a:	and    $0x55,%edi
  43e25d:	je     43e137 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x5c7>
  43e263:	movzbl %dil,%r9d
  43e267:	xor    %edi,%edi
  43e269:	tzcnt  %r9d,%edi
  43e26e:	mov    (%rbx),%r9d
  43e271:	mov    0x14(%rdx),%edx
  43e274:	mov    %r9,%r15
  43e277:	shl    $0x4,%r9
  43e27b:	add    0x8(%rbx),%r9
  43e27f:	lea    0x1(%rdi),%edi
  43e282:	mov    %edx,(%r9)
  43e285:	movslq %edi,%rdx
  43e288:	mov    (%r8,%rdx,8),%r8
  43e28c:	inc    %r15d
  43e28f:	mov    %r8,0x8(%r9)
  43e293:	mov    %r15d,(%rbx)
  43e296:	inc    %eax
  43e298:	and    %esi,%eax
  43e29a:	mov    %eax,0xb4(%r13)
  43e2a1:	jmp    43e113 <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x5a3>
  43e2a6:	mov    $0xffffffff,%r15d
  43e2ac:	crc32  %r8d,%r15d
  43e2b2:	mov    %r15d,%r15d
  43e2b5:	mov    %r15,-0x18(%rsp)
  43e2ba:	jmp    43e17b <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x60b>
  43e2bf:	vzeroupper 
  43e2c2:	jmp    43ddec <kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(std::span<kmercounter::InsertFindArgument, 18446744073709551615ul> const&, std::pair<unsigned int, kmercounter::FindResult*>&, kmercounter::LatencyCollector<2048ul>*)+0x27c>
  43e2c7:	nop
  43e2c8:	nopl   0x0(%rax,%rax,1)
