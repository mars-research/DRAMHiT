
dvi_hs24/dramhit:     file format elf64-x86-64


Disassembly of section .text:

00000000004695e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0():
  4695e0:	lea    0x8(%rsp),%r10
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:427
  4695e5:	and    $0xffffffffffffffc0,%rsp
  4695e9:	push   -0x8(%r10)
  4695ed:	mov    %rdi,%rcx
  4695f0:	push   %rbp
  4695f1:	mov    %rsp,%rbp
  4695f4:	push   %r15
  4695f6:	push   %r14
  4695f8:	push   %r13
  4695fa:	push   %r12
  4695fc:	push   %r10
  4695fe:	push   %rbx
  4695ff:	sub    $0x100,%rsp
  469606:	mov    (%rsi),%r15
  469609:	mov    0x8(%rsi),%rax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:437
  46960d:	mov    0xc8(%rdi),%esi
  469613:	mov    0xcc(%rdi),%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:438
  469619:	mov    0x70(%rcx),%r8d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:572
  46961d:	mov    %rax,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:437
  469620:	mov    %esi,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:572
  469623:	shl    $0x4,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:437
  469627:	sub    %edi,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:572
  46962a:	add    %r15,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:437
  46962d:	and    0x74(%rcx),%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:438
  469631:	lea    -0x1(%r8),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:572
  469635:	mov    %rdx,-0x80(%rbp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:439
  469639:	cmp    %r9d,%r11d
  46963c:	jb     46994b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x36b>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:477
  469642:	and    $0xfffffffffffffffc,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:453
  469646:	lea    0x0(,%r8,4),%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:459
  46964e:	mov    0x80(%rcx),%r12d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:477
  469655:	shl    $0x4,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:454
  469659:	lea    0x0(,%rdi,4),%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:477
  469661:	add    %r15,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:470
  469664:	lea    -0x14(%rdx),%rdi
  469668:	mov    %rdi,-0x88(%rbp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:477
  46966f:	mov    %rax,-0x90(%rbp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:451
  469676:	mov    0xb0(%rcx),%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:452
  46967d:	mov    0xb8(%rcx),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:467
  469684:	mov    0x2a565(%rip),%r13        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:453
  46968b:	lea    -0x1(%rdx),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:455
  46968f:	lea    0x0(,%rsi,4),%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:459
  469697:	not    %r12d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:478
  46969a:	cmp    %rax,%r15
  46969d:	je     46a1d6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbf6>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4696a3:	mov    %rcx,-0x108(%rbp)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4696aa:	mov    $0x55,%eax
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4696af:	mov    %r15,%r9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4696b2:	kmovb  %eax,%k2
  4696b6:	cs nopw 0x0(%rax,%rax,1)
  4696c0:	mov    %r13,%rcx
  4696c3:	mov    %r9,-0x78(%rbp)
  4696c7:	mov    %rdx,%r13
  4696ca:	vpxor  %xmm11,%xmm11,%xmm11
  4696cf:	mov    -0x88(%rbp),%rdx
  4696d6:	mov    %r8,%r15
  4696d9:	jmp    4696e3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x103>
  4696db:	nopl   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:505
  4696e0:	mov    %r8,%r15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:485
  4696e3:	lea    0x10(%r15),%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:486
  4696e7:	lea    (%r10,%r15,4),%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:485
  4696eb:	cmp    %r8,%r13
  4696ee:	jb     469af0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x510>
_Z18_mm512_loadu_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6414
  4696f4:	vmovdqu64 (%rax),%zmm8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:503
  4696fa:	lea    0x60(%r15),%rdi
  4696fe:	lea    0x64(%r15),%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi0EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:512
  469702:	mov    %rbx,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:503
  469705:	and    %rbx,%rdi
  469708:	and    %rbx,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  46970b:	andn   (%r14,%rdi,1),%r12d,%eax
  469711:	shl    $0x4,%rax
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi0EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:512
  469715:	and    %r15,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:503
  469718:	prefetchw (%rcx,%rax,1)
  46971c:	lea    0x6c(%r15),%rdi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  469720:	andn   (%r14,%r9,1),%r12d,%eax
  469726:	shl    $0x4,%rax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:503
  46972a:	lea    0x68(%r15),%r9
  46972e:	and    %rbx,%r9
  469731:	and    %rbx,%rdi
  469734:	prefetchw (%rcx,%rax,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  469738:	andn   (%r14,%r9,1),%r12d,%eax
  46973e:	shl    $0x4,%rax
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi0EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:512
  469742:	mov    (%r14,%rsi,1),%r9d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:503
  469746:	prefetchw (%rcx,%rax,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  46974a:	andn   (%r14,%rdi,1),%r12d,%eax
  469750:	shl    $0x4,%rax
  469754:	andn   %r9d,%r12d,%edi
  469759:	shl    $0x4,%rdi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi0EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:516
  46975d:	add    %rcx,%rdi
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469760:	vmovdqa64 (%rdi),%zmm5
_Z20_mm512_shuffle_i64x2Dv8_xS_i():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4414
  469766:	vshufi64x2 $0x0,%zmm8,%zmm8,%zmm0
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46976d:	vpcmpequq %zmm0,%zmm5,%k4{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:505
  469774:	and    %rbx,%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:503
  469777:	prefetchw (%rcx,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:297
  46977b:	kortestb %k4,%k4
  46977f:	je     469df0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x810>
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  469785:	kshiftlb $0x1,%k4,%k1
_Z24_mm512_mask_storeu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6406
  46978b:	vmovdqu64 %zmm0,(%rdi){%k1}
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi1EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:512
  469791:	lea    0x4(%r15),%rsi
  469795:	and    %rbx,%rsi
  469798:	mov    (%r14,%rsi,1),%r9d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  46979c:	andn   %r9d,%r12d,%edi
  4697a1:	shl    $0x4,%rdi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi1EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:516
  4697a5:	add    %rcx,%rdi
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4697a8:	vmovdqa64 (%rdi),%zmm6
_Z20_mm512_shuffle_i64x2Dv8_xS_i():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4414
  4697ae:	vshufi64x2 $0x55,%zmm8,%zmm8,%zmm0
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4697b5:	vpcmpequq %zmm0,%zmm6,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:297
  4697bc:	kortestb %k0,%k0
  4697c0:	je     469d00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  4697c6:	kshiftlb $0x1,%k0,%k5
_Z24_mm512_mask_storeu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6406
  4697cc:	vmovdqu64 %zmm0,(%rdi){%k5}
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi2EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:512
  4697d2:	lea    0x8(%r15),%rsi
  4697d6:	and    %rbx,%rsi
  4697d9:	mov    (%r14,%rsi,1),%r9d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  4697dd:	andn   %r9d,%r12d,%edi
  4697e2:	shl    $0x4,%rdi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi2EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:516
  4697e6:	add    %rcx,%rdi
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4697e9:	vmovdqa64 (%rdi),%zmm7
_Z20_mm512_shuffle_i64x2Dv8_xS_i():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4414
  4697ef:	vshufi64x2 $0xaa,%zmm8,%zmm8,%zmm0
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4697f6:	vpcmpequq %zmm0,%zmm7,%k6{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:297
  4697fd:	kortestb %k6,%k6
  469801:	je     469c10 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x630>
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  469807:	kshiftlb $0x1,%k6,%k7
_Z24_mm512_mask_storeu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6406
  46980d:	vmovdqu64 %zmm0,(%rdi){%k7}
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi3EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:512
  469813:	add    $0xc,%r15
  469817:	and    %rbx,%r15
  46981a:	mov    (%r14,%r15,1),%r15d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  46981e:	andn   %r15d,%r12d,%edi
  469823:	shl    $0x4,%rdi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi3EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:516
  469827:	add    %rcx,%rdi
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  46982a:	vmovdqa64 (%rdi),%zmm9
_Z20_mm512_shuffle_i64x2Dv8_xS_i():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4414
  469830:	vshufi64x2 $0xff,%zmm8,%zmm8,%zmm10
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469837:	vpcmpequq %zmm10,%zmm9,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:297
  46983e:	kortestb %k1,%k1
  469842:	je     469b38 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x558>
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  469848:	kshiftlb $0x1,%k1,%k3
_Z24_mm512_mask_storeu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6406
  46984e:	vmovdqu64 %zmm10,(%rdi){%k3}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:531
  469854:	mov    %r11,%rdi
  469857:	sub    %r8,%rdi
  46985a:	and    %rbx,%rdi
  46985d:	cmp    %rdi,%rdx
  469860:	jb     4696e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x100>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469866:	mov    -0x78(%rbp),%r9
  46986a:	mov    %r13,%rdx
  46986d:	mov    %rcx,%r13
  469870:	mov    $0xffffffff,%ecx
  469875:	crc32q (%r9),%rcx
  46987b:	mov    $0xffffffff,%edi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  469880:	andn   %ecx,%r12d,%eax
  469885:	shl    $0x4,%rax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:538
  469889:	prefetcht1 0x0(%r13,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  46988f:	mov    $0xffffffff,%eax
  469894:	crc32q 0x20(%r9),%rax
  46989b:	mov    %r8,-0x70(%rbp)
  46989f:	crc32q 0x10(%r9),%rdi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  4698a6:	andn   %eax,%r12d,%r8d
  4698ab:	shl    $0x4,%r8
  4698af:	andn   %edi,%r12d,%r15d
  4698b4:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:538
  4698b8:	prefetcht1 0x0(%r13,%r8,1)
  4698be:	prefetcht1 0x0(%r13,%r15,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4698c4:	mov    $0xffffffff,%r8d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:550
  4698ca:	lea    (%r10,%r11,4),%r15
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4698ce:	crc32q 0x30(%r9),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:550
  4698d5:	kmovq  %r15,%k5
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  4698da:	andn   %r8d,%r12d,%esi
  4698df:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:552
  4698e3:	lea    (%r14,%r11,1),%r15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:538
  4698e7:	prefetcht1 0x0(%r13,%rsi,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:549
  4698ed:	lea    0x10(%r11),%rsi
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4698f1:	mov    %rax,-0x78(%rbp)
_Z18_mm512_loadu_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6414
  4698f5:	vmovdqu64 (%r9),%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:552
  4698fb:	kmovq  %r15,%k6
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:549
  469900:	cmp    %rsi,%rdx
  469903:	jb     46a123 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb43>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  469909:	kmovq  %k5,%r15
  46990e:	vmovdqu64 %zmm12,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:552
  469914:	kmovq  %k6,%r15
  469919:	mov    %ecx,(%r15)
  46991c:	mov    %edi,0x4(%r14,%r11,1)
  469921:	mov    %eax,0x8(%r14,%r11,1)
  469926:	mov    %r8d,0xc(%r14,%r11,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:565
  46992b:	and    %rbx,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:478
  46992e:	add    $0x40,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:565
  469932:	mov    %rsi,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:478
  469935:	cmp    %r9,-0x90(%rbp)
  46993c:	je     469ede <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8fe>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:505
  469942:	mov    -0x70(%rbp),%r8
  469946:	jmp    4696c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xe0>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:738
  46994b:	cmp    -0x80(%rbp),%r15
  46994f:	je     469ad8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4f8>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE21add_to_insert_queue_tINS_14InsertArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1977
  469955:	mov    0x88(%rcx),%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE4hashEPKv():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1508
  46995c:	mov    0x60(%rcx),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:467
  469960:	mov    0x2a289(%rip),%r8        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469967:	mov    0xb0(%rcx),%rsi
  46996e:	mov    0xb8(%rcx),%rdi
  469975:	lea    -0x1(%r12),%r10
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  46997a:	mov    $0xffffffff,%r12d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  469980:	cmp    $0x4,%r9
  469984:	je     469ac1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4e1>
/opt/DRAMHiT/include/hasher.hpp:39
  46998a:	cmp    $0x8,%r9
  46998e:	jne    469999 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3b9>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469990:	mov    %r12,%rbx
  469993:	crc32q (%r15),%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE21add_to_insert_queue_tINS_14InsertArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1982
  469999:	mov    %ebx,%r13d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1979
  46999c:	mov    0xc8(%rcx),%eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1977
  4699a2:	mov    %r10,%r14
  4699a5:	and    %rbx,%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1979
  4699a8:	vmovdqu (%r15),%xmm4
  4699ad:	mov    %rax,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1977
  4699b0:	and    $0xfffffffffffffffc,%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1979
  4699b4:	shl    $0x4,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15prefetch_insertEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1702
  4699b8:	shl    $0x4,%r14
  4699bc:	prefetcht1 (%r8,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE21add_to_insert_queue_tINS_14InsertArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1979
  4699c1:	vmovdqu %xmm4,(%rsi,%rdx,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1982
  4699c6:	mov    %r13d,(%rdi,%rax,4)
_ZN9__gnu_cxx17__normal_iteratorIPN11kmercounter14InsertArgumentESt4spanIS2_Lm18446744073709551615EEEppEv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/include/c++/11.3.0/bits/stl_iterator.h:1037
  4699ca:	add    $0x10,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE21add_to_insert_queue_tINS_14InsertArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1986
  4699ce:	mov    0xc8(%rcx),%eax
  4699d4:	mov    0x74(%rcx),%edx
  4699d7:	inc    %eax
  4699d9:	and    %edx,%eax
  4699db:	mov    %eax,0xc8(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:738
  4699e1:	cmp    -0x80(%rbp),%r15
  4699e5:	je     469ad5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4f5>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:739
  4699eb:	mov    0xcc(%rcx),%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:740
  4699f2:	mov    0x70(%rcx),%r13d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:739
  4699f6:	sub    %r11d,%eax
  4699f9:	and    %edx,%eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:740
  4699fb:	lea    -0x1(%r13),%r14d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:739
  4699ff:	cmp    %r14d,%eax
  469a02:	jb     469980 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3a0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE16pop_insert_queueEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:331
  469a08:	mov    0x80(%rcx),%r13d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:334
  469a0f:	lea    0x18(%r11),%r9d
  469a13:	and    %edx,%r9d
  469a16:	mov    %r13d,%eax
  469a19:	and    (%rdi,%r9,4),%eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:336
  469a1d:	lea    0x1(%r11),%r14d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:334
  469a21:	mov    %rax,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:336
  469a24:	and    %edx,%r14d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:334
  469a27:	shl    $0x4,%r10
  469a2b:	prefetchw (%r8,%r10,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:336
  469a30:	mov    %r14d,0xcc(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:337
  469a37:	mov    (%rdi,%r11,4),%r14d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:338
  469a3b:	shl    $0x4,%r11
_Z22_mm512_broadcast_i32x4Dv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4203
  469a3f:	vbroadcasti32x4 (%rsi,%r11,1),%zmm1
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE16pop_insert_queueEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:338
  469a46:	lea    (%rsi,%r11,1),%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:339
  469a4a:	mov    0x90(%rcx),%r11
  469a51:	cmp    %r11,(%r9)
  469a54:	je     46a233 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xc53>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:346
  469a5a:	mov    %r13d,%edi
  469a5d:	and    %r14d,%edi
  469a60:	shl    $0x4,%rdi
  469a64:	add    %r8,%rdi
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469a67:	vmovdqa64 (%rdi),%zmm0
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469a6d:	mov    $0x55,%edx
  469a72:	kmovb  %edx,%k1
  469a76:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:297
  469a7d:	kortestb %k0,%k0
  469a81:	je     46a259 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xc79>
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  469a87:	kshiftlb $0x1,%k0,%k3
_Z24_mm512_mask_storeu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6406
  469a8d:	vmovdqu64 %zmm1,(%rdi){%k3}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE21add_to_insert_queue_tINS_14InsertArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1977
  469a93:	mov    0x88(%rcx),%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE4hashEPKv():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1508
  469a9a:	mov    0x60(%rcx),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15prefetch_insertEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1702
  469a9e:	mov    0x2a14b(%rip),%r8        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469aa5:	mov    0xb0(%rcx),%rsi
  469aac:	mov    0xb8(%rcx),%rdi
  469ab3:	lea    -0x1(%r13),%r10
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  469ab7:	cmp    $0x4,%r9
  469abb:	jne    46998a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3aa>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469ac1:	mov    $0xffffffff,%r13d
  469ac7:	crc32l (%r15),%r13d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  469acd:	mov    %r13d,%ebx
  469ad0:	jmp    46999c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3bc>
  469ad5:	vzeroupper
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:429
  469ad8:	add    $0x100,%rsp
  469adf:	pop    %rbx
  469ae0:	pop    %rsi
  469ae1:	pop    %r12
  469ae3:	pop    %r13
  469ae5:	pop    %r14
  469ae7:	pop    %r15
  469ae9:	pop    %rbp
  469aea:	lea    -0x8(%rsi),%rsp
  469aee:	ret
  469aef:	nop
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:491
  469af0:	mov    %r13,%rdi
  469af3:	sub    %r15,%rdi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:492
  469af6:	mov    %rdi,%rsi
  469af9:	mov    $0x1,%r9d
  469aff:	shr    $1,%rsi
  469b02:	shlx   %esi,%r9d,%esi
  469b07:	lea    -0x1(%rsi),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:494
  469b0b:	shl    $0x2,%rdi
_Z24_mm512_maskz_loadu_epi64hPKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6389
  469b0f:	kmovb  %r9d,%k5
  469b14:	vmovdqu64 (%rax),%zmm8{%k5}{z}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:494
  469b1a:	mov    %r10,%rax
  469b1d:	sub    %rdi,%rax
  469b20:	neg    %esi
_Z23_mm512_mask_loadu_epi64Dv8_xhPKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6380
  469b22:	kmovb  %esi,%k6
  469b26:	vmovdqu64 (%rax),%zmm8{%k6}
  469b2c:	jmp    4696fa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x11a>
  469b31:	nopl   0x0(%rax)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469b38:	vpcmpequq %zmm11,%zmm9,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:307
  469b3f:	kortestb %k0,%k0
  469b43:	je     469bd8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5f8>
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469b49:	xor    %esi,%esi
  469b4b:	mov    %r11,-0xa0(%rbp)
  469b52:	kmovb  %k0,%r11d
  469b56:	tzcnt  %r11d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:308
  469b5b:	sar    $1,%esi
  469b5d:	vmovdqa64 %zmm10,%zmm0
  469b63:	mov    %r8,-0xb0(%rbp)
  469b6a:	mov    %r10,-0xa8(%rbp)
  469b71:	mov    %rdx,-0x98(%rbp)
  469b78:	mov    %rcx,-0xf0(%rbp)
  469b7f:	vmovdqa64 %zmm10,-0x70(%rbp)
  469b89:	call   433800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_claimEPS1_jDv8_x>
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi3EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:516
  469b8e:	test   %al,%al
  469b90:	mov    $0x55,%r8d
  469b96:	kmovb  %r8d,%k2
  469b9b:	vmovdqa64 -0x70(%rbp),%zmm10
  469ba5:	mov    -0xf0(%rbp),%rcx
  469bac:	mov    -0x98(%rbp),%rdx
  469bb3:	mov    -0xa0(%rbp),%r11
  469bba:	mov    -0xa8(%rbp),%r10
  469bc1:	mov    -0xb0(%rbp),%r8
  469bc8:	vpxor  %xmm11,%xmm11,%xmm11
  469bcd:	jne    469854 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x274>
  469bd3:	nopl   0x0(%rax,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469bd8:	mov    $0xffffffff,%r9d
  469bde:	crc32  %r15,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  469be4:	andn   %r9d,%r12d,%esi
  469be9:	shl    $0x4,%rsi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi3EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:518
  469bed:	prefetcht1 (%rcx,%rsi,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469bf1:	vmovdqu %xmm10,(%r10,%r11,4)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi3EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:520
  469bf7:	mov    %r9d,(%r14,%r11,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:521
  469bfb:	add    $0x4,%r11
  469bff:	and    %rbx,%r11
  469c02:	jmp    469854 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x274>
  469c07:	nopw   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469c10:	vpcmpequq %zmm11,%zmm7,%k4{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:307
  469c17:	kortestb %k4,%k4
  469c1b:	je     469cc8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e8>
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469c21:	xor    %esi,%esi
  469c23:	mov    %rdx,-0xa8(%rbp)
  469c2a:	kmovb  %k4,%edx
  469c2e:	tzcnt  %edx,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:308
  469c32:	sar    $1,%esi
  469c34:	mov    %r8,-0x100(%rbp)
  469c3b:	mov    %r10,-0xf8(%rbp)
  469c42:	mov    %r11,-0xb0(%rbp)
  469c49:	mov    %rcx,-0xa0(%rbp)
  469c50:	mov    %r9d,-0x98(%rbp)
  469c57:	vmovdqa64 %zmm8,-0xf0(%rbp)
  469c61:	vmovdqa64 %zmm0,-0x70(%rbp)
  469c6b:	call   433800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_claimEPS1_jDv8_x>
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi2EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:516
  469c70:	test   %al,%al
  469c72:	mov    $0x55,%ecx
  469c77:	kmovb  %ecx,%k2
  469c7b:	vmovdqa64 -0x70(%rbp),%zmm0
  469c85:	vmovdqa64 -0xf0(%rbp),%zmm8
  469c8f:	mov    -0x98(%rbp),%r9d
  469c96:	mov    -0xa0(%rbp),%rcx
  469c9d:	mov    -0xa8(%rbp),%rdx
  469ca4:	mov    -0xb0(%rbp),%r11
  469cab:	mov    -0xf8(%rbp),%r10
  469cb2:	mov    -0x100(%rbp),%r8
  469cb9:	vpxor  %xmm11,%xmm11,%xmm11
  469cbe:	jne    469813 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x233>
  469cc4:	nopl   0x0(%rax)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469cc8:	mov    $0xffffffff,%edi
  469ccd:	crc32  %r9,%rdi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  469cd3:	andn   %edi,%r12d,%eax
  469cd8:	shl    $0x4,%rax
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi2EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:518
  469cdc:	prefetcht1 (%rcx,%rax,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469ce0:	vmovdqu %xmm0,(%r10,%r11,4)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi2EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:520
  469ce6:	mov    %edi,(%r14,%r11,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:521
  469cea:	add    $0x4,%r11
  469cee:	and    %rbx,%r11
  469cf1:	jmp    469813 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x233>
  469cf6:	cs nopw 0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469d00:	vpcmpequq %zmm11,%zmm6,%k3{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:307
  469d07:	kortestb %k3,%k3
  469d0b:	je     469dc0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7e0>
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469d11:	xor    %esi,%esi
  469d13:	mov    %r8,-0x100(%rbp)
  469d1a:	kmovb  %k3,%r8d
  469d1e:	tzcnt  %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:308
  469d23:	sar    $1,%esi
  469d25:	mov    %r10,-0xf8(%rbp)
  469d2c:	mov    %r11,-0xb0(%rbp)
  469d33:	mov    %rdx,-0xa8(%rbp)
  469d3a:	mov    %rcx,-0xa0(%rbp)
  469d41:	mov    %r9d,-0x98(%rbp)
  469d48:	vmovdqa64 %zmm8,-0xf0(%rbp)
  469d52:	vmovdqa64 %zmm0,-0x70(%rbp)
  469d5c:	call   433800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_claimEPS1_jDv8_x>
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi1EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:516
  469d61:	test   %al,%al
  469d63:	mov    $0x55,%r10d
  469d69:	kmovb  %r10d,%k2
  469d6e:	vmovdqa64 -0x70(%rbp),%zmm0
  469d78:	vmovdqa64 -0xf0(%rbp),%zmm8
  469d82:	mov    -0x98(%rbp),%r9d
  469d89:	mov    -0xa0(%rbp),%rcx
  469d90:	mov    -0xa8(%rbp),%rdx
  469d97:	mov    -0xb0(%rbp),%r11
  469d9e:	mov    -0xf8(%rbp),%r10
  469da5:	mov    -0x100(%rbp),%r8
  469dac:	vpxor  %xmm11,%xmm11,%xmm11
  469db1:	jne    4697d2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1f2>
  469db7:	nopw   0x0(%rax,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469dc0:	mov    $0xffffffff,%edi
  469dc5:	crc32  %r9,%rdi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  469dcb:	andn   %edi,%r12d,%eax
  469dd0:	shl    $0x4,%rax
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi1EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:518
  469dd4:	prefetcht1 (%rcx,%rax,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469dd8:	vmovdqu %xmm0,(%r10,%r11,4)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi1EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:520
  469dde:	mov    %edi,(%r14,%r11,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:521
  469de2:	add    $0x4,%r11
  469de6:	and    %rbx,%r11
  469de9:	jmp    4697d2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1f2>
  469dee:	xchg   %ax,%ax
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469df0:	vpcmpequq %zmm11,%zmm5,%k7{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:307
  469df7:	kortestb %k7,%k7
  469dfb:	je     469eb0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8d0>
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469e01:	xor    %esi,%esi
  469e03:	mov    %rcx,-0xa0(%rbp)
  469e0a:	kmovb  %k7,%ecx
  469e0e:	tzcnt  %ecx,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:308
  469e12:	sar    $1,%esi
  469e14:	mov    %r8,-0x100(%rbp)
  469e1b:	mov    %r10,-0xf8(%rbp)
  469e22:	mov    %r11,-0xb0(%rbp)
  469e29:	mov    %rdx,-0xa8(%rbp)
  469e30:	mov    %r9d,-0x98(%rbp)
  469e37:	vmovdqa64 %zmm8,-0xf0(%rbp)
  469e41:	vmovdqa64 %zmm0,-0x70(%rbp)
  469e4b:	call   433800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_claimEPS1_jDv8_x>
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi0EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:516
  469e50:	test   %al,%al
  469e52:	mov    $0x55,%r11d
  469e58:	kmovb  %r11d,%k2
  469e5d:	vmovdqa64 -0x70(%rbp),%zmm0
  469e67:	vmovdqa64 -0xf0(%rbp),%zmm8
  469e71:	mov    -0x98(%rbp),%r9d
  469e78:	mov    -0xa0(%rbp),%rcx
  469e7f:	mov    -0xa8(%rbp),%rdx
  469e86:	mov    -0xb0(%rbp),%r11
  469e8d:	mov    -0xf8(%rbp),%r10
  469e94:	mov    -0x100(%rbp),%r8
  469e9b:	vpxor  %xmm11,%xmm11,%xmm11
  469ea0:	jne    469791 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1b1>
  469ea6:	cs nopw 0x0(%rax,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469eb0:	mov    $0xffffffff,%edi
  469eb5:	crc32  %r9,%rdi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:464
  469ebb:	andn   %edi,%r12d,%eax
  469ec0:	shl    $0x4,%rax
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi0EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:518
  469ec4:	prefetcht1 (%rcx,%rax,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469ec8:	vmovdqu %xmm0,(%r10,%r11,4)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEEENKUlS7_E0_clISt17integral_constantIiLi0EEEEDaS7_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:520
  469ece:	mov    %edi,(%r14,%r11,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:521
  469ed2:	add    $0x4,%r11
  469ed6:	and    %rbx,%r11
  469ed9:	jmp    469791 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1b1>
  469ede:	mov    -0x70(%rbp),%rbx
  469ee2:	mov    -0x108(%rbp),%rcx
  469ee9:	mov    %r9,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:568
  469eec:	vmovq  %r11,%xmm0
  469ef1:	vpinsrq $0x1,%rbx,%xmm0,%xmm3
  469ef7:	vpsrlq $0x2,%xmm3,%xmm1
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:572
  469efc:	mov    -0x80(%rbp),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:568
  469f00:	vpmovqd %xmm1,%xmm5
  469f06:	vpextrd $0x1,%xmm5,%eax
  469f0c:	vmovq  %xmm5,0xc8(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:572
  469f14:	cmp    %r14,%r15
  469f17:	je     469ad5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4f5>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE16pop_insert_queueEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:334
  469f1d:	mov    0x29ccc(%rip),%r8        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469f24:	mov    0xb8(%rcx),%rsi
  469f2b:	mov    0x74(%rcx),%edi
  469f2e:	mov    0xb0(%rcx),%rdx
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469f35:	mov    -0x110(%rbp),%r13
  469f3c:	mov    $0xffffffff,%ebx
  469f41:	mov    %rcx,%r12
  469f44:	jmp    469fca <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9ea>
  469f49:	nopl   0x0(%rax)
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:39
  469f50:	cmp    $0x8,%rcx
  469f54:	jne    469f5f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x97f>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469f56:	mov    %rbx,%r13
  469f59:	crc32q (%r15),%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE21add_to_insert_queue_tINS_14InsertArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1982
  469f5f:	mov    %r13d,%r10d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1977
  469f62:	mov    0x88(%r12),%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1979
  469f6a:	mov    0xc8(%r12),%eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1977
  469f72:	dec    %r11
  469f75:	and    %r13,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1979
  469f78:	vmovdqu (%r15),%xmm10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1977
  469f7d:	and    $0xfffffffffffffffc,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1979
  469f81:	mov    %rax,%rdi
  469f84:	shl    $0x4,%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15prefetch_insertEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1702
  469f88:	shl    $0x4,%r11
  469f8c:	prefetcht1 (%r8,%r11,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE21add_to_insert_queue_tINS_14InsertArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1979
  469f91:	vmovdqu %xmm10,(%rdx,%rdi,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1982
  469f96:	mov    %r10d,(%rsi,%rax,4)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:572
  469f9a:	add    $0x10,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE21add_to_insert_queue_tINS_14InsertArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1986
  469f9e:	mov    0xc8(%r12),%r9d
  469fa6:	mov    0x74(%r12),%edi
  469fab:	inc    %r9d
  469fae:	and    %edi,%r9d
  469fb1:	mov    %r9d,0xc8(%r12)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:572
  469fb9:	cmp    %r14,%r15
  469fbc:	je     469ad5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4f5>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE16pop_insert_queueEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:333
  469fc2:	mov    0xcc(%r12),%eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:331
  469fca:	mov    0x80(%r12),%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:334
  469fd2:	lea    0x18(%rax),%r9d
  469fd6:	and    %edi,%r9d
  469fd9:	mov    %ecx,%r10d
  469fdc:	and    (%rsi,%r9,4),%r10d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:336
  469fe0:	lea    0x1(%rax),%r11d
  469fe4:	and    %r11d,%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:334
  469fe7:	shl    $0x4,%r10
  469feb:	prefetchw (%r8,%r10,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:336
  469ff0:	mov    %edi,0xcc(%r12)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:337
  469ff8:	mov    (%rsi,%rax,4),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:338
  469ffc:	shl    $0x4,%rax
_Z22_mm512_broadcast_i32x4Dv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4203
  46a000:	vbroadcasti32x4 (%rdx,%rax,1),%zmm9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE16pop_insert_queueEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:338
  46a007:	lea    (%rdx,%rax,1),%rdi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:339
  46a00b:	mov    0x90(%r12),%rax
  46a013:	cmp    %rax,(%rdi)
  46a016:	je     46a086 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaa6>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:346
  46a018:	mov    %ecx,%edi
  46a01a:	and    %r9d,%edi
  46a01d:	shl    $0x4,%rdi
  46a021:	add    %r8,%rdi
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  46a024:	vmovdqa64 (%rdi),%zmm7
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46a02a:	mov    $0x55,%esi
  46a02f:	kmovb  %esi,%k2
  46a033:	vpcmpequq %zmm9,%zmm7,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:297
  46a03a:	kortestb %k0,%k0
  46a03e:	je     46a09a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaba>
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  46a040:	kshiftlb $0x1,%k0,%k7
_Z24_mm512_mask_storeu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6406
  46a046:	vmovdqu64 %zmm9,(%rdi){%k7}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15prefetch_insertEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1702
  46a04c:	mov    0x29b9d(%rip),%r8        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46a053:	mov    0xb0(%r12),%rdx
  46a05b:	mov    0xb8(%r12),%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE4hashEPKv():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1508
  46a063:	mov    0x60(%r12),%rcx
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  46a068:	cmp    $0x4,%rcx
  46a06c:	jne    469f50 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x970>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  46a072:	mov    $0xffffffff,%r10d
  46a078:	crc32l (%r15),%r10d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  46a07e:	mov    %r10d,%r13d
  46a081:	jmp    469f62 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x982>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14__insert_emptyEPS2_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1910
  46a086:	mov    0x8(%rdi),%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1916
  46a08a:	movb   $0x1,0x29a6f(%rip)        # 493b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1910
  46a091:	mov    %r9,0x29a70(%rip)        # 493b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46a098:	jmp    46a063 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa83>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46a09a:	vpxor  %xmm8,%xmm8,%xmm8
  46a09f:	vpcmpequq %zmm8,%zmm7,%k4{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:307
  46a0a6:	kortestb %k4,%k4
  46a0aa:	jne    46a1de <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbfe>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  46a0b0:	mov    %rbx,%r10
  46a0b3:	crc32  %r9,%r10
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE16pop_insert_queueEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:348
  46a0b9:	mov    %ecx,%r11d
  46a0bc:	and    %r10d,%r11d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15prefetch_insertEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1702
  46a0bf:	shl    $0x4,%r11
  46a0c3:	prefetcht1 (%r8,%r11,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE16pop_insert_queueEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:349
  46a0c8:	mov    0xc8(%r12),%r8d
_Z15_mm_store_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:733
  46a0d0:	shl    $0x4,%r8
  46a0d4:	vmovdqa %xmm9,(%rdx,%r8,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE16pop_insert_queueEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:350
  46a0da:	mov    0xc8(%r12),%edi
  46a0e2:	mov    0xb8(%r12),%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:334
  46a0ea:	mov    0x29aff(%rip),%r8        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:350
  46a0f1:	mov    %r10d,(%rsi,%rdi,4)
  46a0f5:	mov    0xb0(%r12),%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:351
  46a0fd:	mov    0xc8(%r12),%eax
  46a105:	mov    0x74(%r12),%edi
  46a10a:	inc    %eax
  46a10c:	and    %edi,%eax
  46a10e:	mov    %eax,0xc8(%r12)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:333
  46a116:	mov    0xcc(%r12),%eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:332
  46a11e:	jmp    469fd2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9f2>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:554
  46a123:	mov    %rdx,%rax
  46a126:	sub    %r11,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:555
  46a129:	mov    %rax,%r15
  46a12c:	mov    %rax,-0xf0(%rbp)
  46a133:	shr    $1,%r15
  46a136:	mov    $0x1,%eax
  46a13b:	shlx   %r15d,%eax,%eax
  46a140:	mov    %eax,%r15d
  46a143:	dec    %r15d
  46a146:	kmovd  %eax,%k7
  46a14a:	kmovb  %r15d,%k1
_Z24_mm512_mask_storeu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6406
  46a14f:	kmovq  %k5,%rax
  46a154:	vmovdqu64 %zmm12,(%rax){%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:557
  46a15a:	mov    -0xf0(%rbp),%r15
  46a161:	mov    %r10,%rax
  46a164:	shl    $0x2,%r15
  46a168:	sub    %r15,%rax
  46a16b:	kmovb  %k7,%r15d
  46a16f:	neg    %r15d
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46a172:	vmovd  %ecx,%xmm15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:557
  46a176:	kmovb  %r15d,%k3
_Z24_mm512_mask_storeu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6406
  46a17b:	vmovdqu64 %zmm12,(%rax){%k3}
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46a181:	vmovd  -0x78(%rbp),%xmm13
  46a186:	vpinsrd $0x1,%edi,%xmm15,%xmm4
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:561
  46a18c:	mov    -0xf0(%rbp),%rdi
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46a193:	vpinsrd $0x1,%r8d,%xmm13,%xmm14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:561
  46a199:	shr    $0x2,%rdi
  46a19d:	mov    $0x1,%ecx
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46a1a2:	vpunpcklqdq %xmm14,%xmm4,%xmm2
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:561
  46a1a7:	shlx   %edi,%ecx,%r8d
  46a1ac:	lea    -0x1(%r8),%eax
_Z21_mm_mask_storeu_epi32PvhDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512vlintrin.h:933
  46a1b0:	kmovq  %k6,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:563
  46a1b5:	sub    %rdx,%r11
  46a1b8:	neg    %r8d
_Z21_mm_mask_storeu_epi32PvhDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512vlintrin.h:933
  46a1bb:	kmovb  %eax,%k5
  46a1bf:	vmovdqu32 %xmm2,(%r15){%k5}
  46a1c5:	kmovb  %r8d,%k6
  46a1ca:	vmovdqu32 %xmm2,(%r14,%r11,1){%k6}
  46a1d1:	jmp    46992b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x34b>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17insert_batch_implINS_14InsertArgumentEEEvSt4spanIT_Lm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:454
  46a1d6:	mov    %r8,%rbx
  46a1d9:	jmp    469eec <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x90c>
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  46a1de:	xor    %esi,%esi
  46a1e0:	kmovb  %k4,%edx
  46a1e4:	tzcnt  %edx,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:308
  46a1e8:	sar    $1,%esi
  46a1ea:	vmovdqa64 %zmm9,%zmm0
  46a1f0:	mov    %r9d,-0x80(%rbp)
  46a1f4:	mov    %ecx,-0x78(%rbp)
  46a1f7:	vmovdqa32 %zmm9,-0x70(%rbp)
  46a201:	call   433800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_claimEPS1_jDv8_x>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15prefetch_insertEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1702
  46a206:	mov    0x299e3(%rip),%r8        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46a20d:	mov    0xb0(%r12),%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE16pop_insert_queueEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:346
  46a215:	test   %al,%al
  46a217:	jne    46a31a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xd3a>
  46a21d:	mov    -0x80(%rbp),%r9d
  46a221:	mov    -0x78(%rbp),%ecx
  46a224:	vmovdqa32 -0x70(%rbp),%zmm9
  46a22e:	jmp    46a0b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14__insert_emptyEPS2_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1910
  46a233:	mov    0x8(%r9),%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE21add_to_insert_queue_tINS_14InsertArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1977
  46a237:	mov    0x88(%rcx),%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14__insert_emptyEPS2_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1910
  46a23e:	mov    %r14,0x298c3(%rip)        # 493b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1916
  46a245:	movb   $0x1,0x298b4(%rip)        # 493b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE4hashEPKv():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1508
  46a24c:	mov    0x60(%rcx),%r9
  46a250:	lea    -0x1(%rdx),%r10
  46a254:	jmp    469980 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3a0>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46a259:	vpxor  %xmm3,%xmm3,%xmm3
  46a25d:	vpcmpequq %zmm3,%zmm0,%k2{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:307
  46a264:	kortestb %k2,%k2
  46a268:	je     46a2b3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xcd3>
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  46a26a:	xor    %esi,%esi
  46a26c:	mov    %rcx,-0x78(%rbp)
  46a270:	kmovb  %k2,%ecx
  46a274:	tzcnt  %ecx,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_entryEPS1_Dv8_x():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:308
  46a278:	sar    $1,%esi
  46a27a:	vmovdqa64 %zmm1,%zmm0
  46a280:	vmovdqa32 %zmm1,-0x70(%rbp)
  46a28a:	call   433800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9ins_claimEPS1_jDv8_x>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE16pop_insert_queueEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:346
  46a28f:	test   %al,%al
  46a291:	vmovdqa32 -0x70(%rbp),%zmm1
  46a29b:	mov    -0x78(%rbp),%rcx
  46a29f:	jne    469a93 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4b3>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15prefetch_insertEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1702
  46a2a5:	mov    0x29944(%rip),%r8        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46a2ac:	mov    0xb0(%rcx),%rsi
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  46a2b3:	mov    %r12,%r10
  46a2b6:	crc32  %r14,%r10
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE16pop_insert_queueEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:348
  46a2bc:	mov    %r13d,%edi
  46a2bf:	and    %r10d,%edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15prefetch_insertEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1702
  46a2c2:	shl    $0x4,%rdi
  46a2c6:	prefetcht1 (%r8,%rdi,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE16pop_insert_queueEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:349
  46a2cb:	mov    0xc8(%rcx),%r8d
_Z15_mm_store_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:733
  46a2d2:	shl    $0x4,%r8
  46a2d6:	vmovdqa %xmm1,(%rsi,%r8,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE16pop_insert_queueEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:350
  46a2dc:	mov    0xc8(%rcx),%esi
  46a2e2:	mov    0xb8(%rcx),%rdi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:334
  46a2e9:	mov    0x29900(%rip),%r8        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:350
  46a2f0:	mov    %r10d,(%rdi,%rsi,4)
  46a2f4:	mov    0xb0(%rcx),%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:351
  46a2fb:	mov    0xc8(%rcx),%eax
  46a301:	mov    0x74(%rcx),%edx
  46a304:	inc    %eax
  46a306:	and    %edx,%eax
  46a308:	mov    %eax,0xc8(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:333
  46a30e:	mov    0xcc(%rcx),%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:332
  46a315:	jmp    469a0f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x42f>
  46a31a:	mov    0xb8(%r12),%rsi
  46a322:	jmp    46a063 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batchERKSt4spanINS_14InsertArgumentELm18446744073709551615EEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa83>
