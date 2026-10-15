
/opt/DRAMHiT/scripts/eurosys_2026/optimize_hbm/attempt11/dvs_p3s/dramhit:     file format elf64-x86-64


Disassembly of section .text:

0000000000468ed0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:703
  468ed0:	lea    0x8(%rsp),%r10
  468ed5:	and    $0xffffffffffffffc0,%rsp
  468ed9:	push   -0x8(%r10)
  468edd:	mov    %rdx,%r11
  468ee0:	push   %rbp
  468ee1:	mov    %rsp,%rbp
  468ee4:	push   %r15
  468ee6:	push   %r14
  468ee8:	push   %r13
  468eea:	push   %r12
  468eec:	mov    %rdi,%r12
  468eef:	push   %r10
  468ef1:	push   %rbx
  468ef2:	add    $0xffffffffffffff80,%rsp
  468ef6:	mov    0x8(%rsi),%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:717
  468efa:	mov    0xb0(%rdi),%edi
  468f00:	mov    0xb4(%r12),%eax
  468f08:	mov    (%rsi),%r13
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:718
  468f0b:	mov    0x6c(%r12),%r8d
  468f10:	mov    0x78(%r12),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:864
  468f15:	mov    %rcx,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:717
  468f18:	mov    %edi,%edx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:864
  468f1a:	shl    $0x4,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:717
  468f1e:	sub    %eax,%edx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:864
  468f20:	lea    0x0(%r13,%r9,1),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:717
  468f25:	and    %esi,%edx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:718
  468f27:	lea    -0x1(%r8),%r14d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:864
  468f2b:	mov    %rbx,-0x58(%rbp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:720
  468f2f:	cmp    %r14d,%edx
  468f32:	jb     46973a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x86a>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:778
  468f38:	and    $0xfffffffffffffffc,%rcx
  468f3c:	shl    $0x4,%rcx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:736
  468f40:	mov    0x80(%r12),%r14d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:727
  468f48:	shl    $0x4,%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:728
  468f4c:	mov    %eax,%ebx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:778
  468f4e:	lea    0x0(%r13,%rcx,1),%r10
  468f53:	mov    %rcx,-0x68(%rbp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:729
  468f57:	mov    %edi,%edx
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468f59:	mov    $0x55,%ecx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:727
  468f5e:	mov    %r8,-0x50(%rbp)
  468f62:	lea    -0x1(%r8),%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:778
  468f66:	mov    %r10,-0x38(%rbp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:731
  468f6a:	movl   $0x0,-0x60(%rbp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:726
  468f71:	mov    0xa0(%r12),%r15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:732
  468f79:	mov    0x8(%r11),%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:745
  468f7d:	mov    0x29c64(%rip),%rax        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:728
  468f84:	shl    $0x4,%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:729
  468f88:	shl    $0x4,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:736
  468f8c:	not    %r14d
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468f8f:	vpxor  %xmm8,%xmm8,%xmm8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:779
  468f94:	xor    %r8d,%r8d
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468f97:	kmovb  %ecx,%k2
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:779
  468f9b:	cmp    %r10,%r13
  468f9e:	je     4692dc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x40c>
  468fa4:	mov    %r12,-0x70(%rbp)
  468fa8:	mov    %r11,-0x78(%rbp)
  468fac:	mov    %r9,%r12
  468faf:	jmp    469230 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x360>
  468fb4:	nopl   0x0(%rax)
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468fb8:	vmovd  0xc(%r9),%xmm14
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468fbe:	kshiftlb $0x1,%k4,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468fc4:	vpcompressq %zmm9,%zmm13{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468fca:	vpunpcklqdq %xmm13,%xmm14,%xmm15
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468fcf:	mov    $0xf,%r8d
  468fd5:	kmovw  %r8d,%k7
  468fda:	vshufi32x4 $0x0,%zmm15,%zmm15,%zmm0{%k7}{z}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468fe1:	vmovdqa64 %zmm0,%zmm13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:798
  468fe7:	mov    $0x1,%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:787
  468fec:	lea    (%r15,%rbx,1),%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:786
  468ff0:	lea    0x180(%rbx),%r9
  468ff7:	and    %rsi,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:747
  468ffa:	mov    0x8(%r11),%r8d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  468ffe:	andn   0x8(%r15,%r9,1),%r14d,%edi
  469005:	shl    $0x4,%rdi
  469009:	andn   %r8d,%r14d,%r9d
  46900e:	shl    $0x4,%r9
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469012:	vmovdqa64 (%rax,%r9,1),%zmm7
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:752
  469019:	vpbroadcastq (%r11),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46901f:	vpcmpequq %zmm2,%zmm7,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:788
  469026:	add    $0x10,%rbx
  46902a:	and    %rsi,%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:786
  46902d:	prefetcht0 (%rax,%rdi,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:792
  469031:	kortestb %k1,%k1
  469035:	je     4696c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7f0>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46903b:	vmovd  0xc(%r11),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  469041:	kshiftlb $0x1,%k1,%k3
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  469047:	vpcompressq %zmm7,%zmm5{%k3}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  46904d:	vpunpcklqdq %xmm5,%xmm1,%xmm6
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  469051:	mov    $0xf0,%r11d
  469057:	kmovw  %r11d,%k4
  46905c:	vshufi32x4 $0x0,%zmm6,%zmm6,%zmm0{%k4}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  469063:	vmovdqa64 %zmm0,%zmm13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:798
  469069:	or     $0x2,%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:787
  46906c:	lea    (%r15,%rbx,1),%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:786
  469070:	lea    0x180(%rbx),%r8
  469077:	and    %rsi,%r8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:747
  46907a:	mov    0x8(%r10),%r11d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  46907e:	andn   0x8(%r15,%r8,1),%r14d,%edi
  469085:	shl    $0x4,%rdi
  469089:	andn   %r11d,%r14d,%r8d
  46908e:	shl    $0x4,%r8
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469092:	vmovdqa64 (%rax,%r8,1),%zmm9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:752
  469099:	vpbroadcastq (%r10),%zmm10
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46909f:	vpcmpequq %zmm10,%zmm9,%k5{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:788
  4690a6:	add    $0x10,%rbx
  4690aa:	and    %rsi,%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:786
  4690ad:	prefetcht0 (%rax,%rdi,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:792
  4690b1:	kortestb %k5,%k5
  4690b5:	je     469670 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7a0>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  4690bb:	vmovd  0xc(%r10),%xmm14
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  4690c1:	kshiftlb $0x1,%k5,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  4690c7:	vpcompressq %zmm9,%zmm13{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  4690cd:	vpunpcklqdq %xmm13,%xmm14,%xmm15
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  4690d2:	mov    $0xf00,%r10d
  4690d8:	kmovw  %r10d,%k1
  4690dd:	vshufi32x4 $0x0,%zmm15,%zmm15,%zmm0{%k1}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  4690e4:	vmovdqa64 %zmm0,%zmm13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:798
  4690ea:	or     $0x4,%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:787
  4690ed:	lea    (%r15,%rbx,1),%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:786
  4690f1:	lea    0x180(%rbx),%r11
  4690f8:	and    %rsi,%r11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  4690fb:	andn   0x8(%r15,%r11,1),%r14d,%edi
  469102:	shl    $0x4,%rdi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:747
  469106:	mov    0x8(%r10),%r11d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  46910a:	andn   %r11d,%r14d,%r9d
  46910f:	shl    $0x4,%r9
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469113:	vmovdqa64 (%rax,%r9,1),%zmm7
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:752
  46911a:	vpbroadcastq (%r10),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469120:	vpcmpequq %zmm2,%zmm7,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:788
  469127:	add    $0x10,%rbx
  46912b:	and    %rsi,%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:786
  46912e:	prefetcht0 (%rax,%rdi,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:792
  469132:	kortestb %k0,%k0
  469136:	je     469620 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x750>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46913c:	vmovd  0xc(%r10),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  469142:	kshiftlb $0x1,%k0,%k4
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  469148:	vpcompressq %zmm7,%zmm5{%k4}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  46914e:	vpunpcklqdq %xmm5,%xmm1,%xmm6
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  469152:	mov    $0xfffff000,%r10d
  469158:	kmovw  %r10d,%k5
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:798
  46915d:	or     $0x8,%ecx
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  469160:	vshufi32x4 $0x0,%zmm6,%zmm6,%zmm0{%k5}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  469167:	vmovdqa64 %zmm0,%zmm13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:822
  46916d:	cmp    $0xf,%ecx
  469170:	jne    469710 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x840>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  469176:	vmovdqu64 %zmm0,(%r12)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:824
  46917d:	add    $0x40,%r12
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469181:	mov    $0xffffffff,%ecx
  469186:	mov    $0xffffffff,%r8d
  46918c:	crc32q 0x20(%r13),%rcx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  469193:	andn   %ecx,%r14d,%edi
  469198:	shl    $0x4,%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:835
  46919c:	prefetcht2 (%rax,%rdi,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4691a0:	mov    $0xffffffff,%edi
  4691a5:	crc32q 0x0(%r13),%r8
  4691ac:	mov    $0xffffffff,%r9d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  4691b2:	andn   %r8d,%r14d,%r10d
  4691b7:	shl    $0x4,%r10
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4691bb:	crc32q 0x30(%r13),%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:835
  4691c2:	prefetcht2 (%rax,%r10,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  4691c7:	andn   %edi,%r14d,%r10d
  4691cc:	shl    $0x4,%r10
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:835
  4691d0:	prefetcht2 (%rax,%r10,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:840
  4691d5:	lea    0x40(%rdx),%r10
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4691d9:	crc32q 0x10(%r13),%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  4691e0:	andn   %r9d,%r14d,%r11d
  4691e5:	shl    $0x4,%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:835
  4691e9:	prefetcht2 (%rax,%r11,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:840
  4691ee:	cmp    %r10,-0x50(%rbp)
  4691f2:	jb     40e2e2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0.cold>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  4691f8:	vmovdqu64 0x0(%r13),%zmm0
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:851
  4691ff:	lea    (%r15,%rdx,1),%r11
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  469203:	vmovdqu64 %zmm0,(%r11)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:779
  469209:	add    $0x40,%r13
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:853
  46920d:	mov    %r8d,0x8(%r11)
  469211:	mov    %r9d,0x18(%r15,%rdx,1)
  469216:	mov    %ecx,0x28(%r15,%rdx,1)
  46921b:	mov    %edi,0x38(%r15,%rdx,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:857
  469220:	mov    %r10,%rdx
  469223:	and    %rsi,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:779
  469226:	cmp    %r13,-0x38(%rbp)
  46922a:	je     4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x400>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:787
  469230:	lea    (%r15,%rbx,1),%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:747
  469234:	mov    0x8(%r9),%edi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  469238:	andn   %edi,%r14d,%r10d
  46923d:	shl    $0x4,%r10
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469241:	vmovdqa64 (%rax,%r10,1),%zmm9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:752
  469248:	vpbroadcastq (%r9),%zmm10
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46924e:	vpcmpequq %zmm10,%zmm9,%k4{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:786
  469255:	lea    0x180(%rbx),%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:788
  46925c:	add    $0x10,%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:786
  469260:	and    %rsi,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:788
  469263:	and    %rsi,%rbx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  469266:	andn   0x8(%r15,%r11,1),%r14d,%ecx
  46926d:	shl    $0x4,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:792
  469271:	kortestb %k4,%k4
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:786
  469275:	prefetcht0 (%rax,%rcx,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:792
  469279:	jne    468fb8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xe8>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46927f:	vpcmpequq %zmm8,%zmm9,%k5{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:801
  469286:	kortestb %k5,%k5
  46928a:	jne    4699d5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb05>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  469290:	vmovdqu (%r9),%xmm11
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469295:	mov    $0xffffffff,%r11d
  46929b:	crc32  %rdi,%r11
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  4692a1:	vpinsrd $0x2,%r11d,%xmm11,%xmm12
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  4692a7:	andn   %r11d,%r14d,%ecx
  4692ac:	shl    $0x4,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:811
  4692b0:	prefetcht2 (%rax,%rcx,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  4692b4:	vmovdqu %xmm12,(%r15,%rdx,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:816
  4692ba:	add    $0x10,%rdx
  4692be:	and    %rsi,%rdx
  4692c1:	jmp    469230 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x360>
  4692c6:	cs nopw 0x0(%rax,%rax,1)
  4692d0:	mov    -0x70(%rbp),%r12
  4692d4:	mov    -0x78(%rbp),%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:862
  4692d8:	mov    -0x60(%rbp),%r8d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:860
  4692dc:	vmovq  %rdx,%xmm8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:862
  4692e1:	mov    -0x68(%rbp),%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:860
  4692e5:	vpinsrq $0x1,%rbx,%xmm8,%xmm9
  4692eb:	vpsrlq $0x4,%xmm9,%xmm10
  4692f1:	vpmovqd %xmm10,%xmm11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:862
  4692f7:	sar    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:860
  4692fb:	vmovq  %xmm11,0xb0(%r12)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:862
  469305:	sub    %r8,%rsi
  469308:	add    %esi,(%r11)
  46930b:	vpextrd $0x1,%xmm11,%eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:864
  469311:	cmp    -0x58(%rbp),%r13
  469315:	je     469608 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1680
  46931b:	mov    0x88(%r12),%rcx
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1210
  469323:	mov    0x80(%r12),%r10
  46932b:	mov    0x60(%r12),%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1680
  469330:	dec    %rcx
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1210
  469333:	mov    %r10,-0x50(%rbp)
  469337:	mov    %rdx,-0x38(%rbp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1680
  46933b:	mov    %rcx,-0x60(%rbp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:618
  46933f:	mov    0x78(%r12),%r8d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  469344:	mov    0x2989d(%rip),%r9        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46934b:	mov    0xa0(%r12),%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1429
  469353:	movzbl 0x297a6(%rip),%ebx        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1431
  46935a:	mov    0x297a7(%rip),%r15        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469361:	mov    $0x55,%r14d
  469367:	vpxor  %xmm12,%xmm12,%xmm12
  46936c:	kmovb  %r14d,%k2
  469371:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:618
  469378:	lea    0x18(%rax),%edx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  46937b:	and    %r8d,%edx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1215
  46937e:	shl    $0x4,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  469382:	mov    %r10d,%esi
  469385:	and    0x8(%rdi,%rdx,1),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:622
  469389:	mov    %eax,%edx
  46938b:	shl    $0x4,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  46938f:	shl    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:622
  469393:	add    %rdi,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:620
  469396:	prefetcht0 (%r9,%rsi,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1413
  46939b:	mov    (%rdx),%rsi
  46939e:	cmp    0x90(%r12),%rsi
  4693a6:	jne    469468 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x598>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1429
  4693ac:	test   %bl,%bl
  4693ae:	je     4693cd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fd>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1430
  4693b0:	mov    (%r11),%r14d
  4693b3:	mov    0xc(%rdx),%edx
  4693b6:	mov    %r14,%rsi
  4693b9:	shl    $0x4,%r14
  4693bd:	add    0x8(%r11),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1432
  4693c1:	inc    %esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1430
  4693c3:	mov    %edx,(%r14)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1431
  4693c6:	mov    %r15,0x8(%r14)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1432
  4693ca:	mov    %esi,(%r11)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  4693cd:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  4693cf:	and    %r8d,%eax
  4693d2:	mov    %eax,0xb4(%r12)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:626
  4693da:	test   %r15,%r15
  4693dd:	jne    469378 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a8>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4693df:	cmpq   $0x4,-0x38(%rbp)
  4693e4:	je     469566 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x696>
  4693ea:	nopw   0x0(%rax,%rax,1)
/opt/DRAMHiT/include/hasher.hpp:39
  4693f0:	cmpq   $0x8,-0x38(%rbp)
  4693f5:	je     4695e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x718>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1690
  4693fb:	vmovd  -0x48(%rbp),%xmm4
  469400:	mov    0x0(%r13),%rcx
  469404:	mov    0xb0(%r12),%edx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1680
  46940c:	mov    -0x60(%rbp),%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1690
  469410:	mov    %rdx,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1680
  469413:	and    -0x48(%rbp),%rsi
  469417:	vpinsrd $0x1,0xc(%r13),%xmm4,%xmm1
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1683
  46941e:	and    $0xfffffffffffffffc,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1690
  469422:	shl    $0x4,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1708
  469426:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1690
  469428:	add    %rdi,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1471
  46942b:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1709
  46942f:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:864
  469432:	add    $0x10,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1471
  469436:	prefetcht2 (%r9,%rsi,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1237
  46943b:	mov    %rcx,(%rdx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1238
  46943e:	vmovq  %xmm1,0x8(%rdx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1709
  469443:	mov    %eax,0xb0(%r12)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:864
  46944b:	cmp    -0x58(%rbp),%r13
  46944f:	je     469608 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:618
  469455:	mov    0xb4(%r12),%eax
  46945d:	jmp    469378 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a8>
  469462:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1215
  469468:	mov    0x8(%rdx),%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1276
  46946c:	mov    %r10d,%ecx
  46946f:	and    %r14d,%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1278
  469472:	shl    $0x4,%rcx
  469476:	add    %r9,%rcx
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469479:	vmovdqa64 (%rcx),%zmm14
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  46947f:	vpbroadcastq %rsi,%zmm15
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469485:	vpcmpequq %zmm15,%zmm14,%k7{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1282
  46948c:	kortestb %k7,%k7
  469490:	jne    469520 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x650>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469496:	vpcmpequq %zmm12,%zmm14,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1290
  46949d:	kortestb %k1,%k1
  4694a1:	jne    469590 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4694a7:	cmpq   $0x4,-0x38(%rbp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1292
  4694ac:	mov    %r14d,%ecx
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4694af:	je     4695a8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d8>
/opt/DRAMHiT/include/hasher.hpp:39
  4694b5:	cmpq   $0x8,-0x38(%rbp)
  4694ba:	je     4695c8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6f8>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  4694c0:	vmovd  -0x40(%rbp),%xmm7
  4694c5:	mov    0xb0(%r12),%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1294
  4694cd:	mov    -0x50(%rbp),%r14
  4694d1:	vpinsrd $0x1,0xc(%rdx),%xmm7,%xmm3
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  4694d8:	mov    %rcx,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1294
  4694db:	and    -0x40(%rbp),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  4694df:	shl    $0x4,%rcx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1301
  4694e3:	inc    %edx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  4694e5:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  4694e7:	add    %rdi,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1471
  4694ea:	shl    $0x4,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1302
  4694ee:	and    %r8d,%edx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  4694f1:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1471
  4694f4:	prefetcht2 (%r9,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1237
  4694f9:	mov    %rsi,(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1238
  4694fc:	vmovq  %xmm3,0x8(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1302
  469501:	mov    %edx,0xb0(%r12)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469509:	mov    %eax,0xb4(%r12)
  469511:	jmp    469378 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a8>
  469516:	cs nopw 0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1283
  469520:	mov    (%r11),%esi
  469523:	mov    0xc(%rdx),%edx
  469526:	mov    %rsi,%r14
  469529:	shl    $0x4,%rsi
  46952d:	add    0x8(%r11),%rsi
  469531:	mov    %edx,(%rsi)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469533:	kmovb  %k7,%edx
  469537:	tzcnt  %edx,%edx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1284
  46953b:	inc    %edx
  46953d:	movslq %edx,%rdx
  469540:	mov    (%rcx,%rdx,8),%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  469544:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1285
  469546:	inc    %r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469549:	and    %r8d,%eax
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  46954c:	cmpq   $0x4,-0x38(%rbp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1284
  469551:	mov    %rcx,0x8(%rsi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1285
  469555:	mov    %r14d,(%r11)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469558:	mov    %eax,0xb4(%r12)
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  469560:	jne    4693f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x520>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469566:	mov    $0xffffffff,%r14d
  46956c:	crc32l 0x0(%r13),%r14d
  469573:	vmovd  %r14d,%xmm5
  469578:	mov    0x0(%r13),%rcx
  46957c:	vmovdqa %xmm5,%xmm4
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  469580:	vmovq  %xmm5,-0x48(%rbp)
  469585:	jmp    469404 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x534>
  46958a:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  469590:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469592:	and    %r8d,%eax
  469595:	mov    %eax,0xb4(%r12)
  46959d:	jmp    4693df <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50f>
  4695a2:	nopw   0x0(%rax,%rax,1)
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4695a8:	mov    $0xffffffff,%ecx
  4695ad:	crc32  %r14d,%ecx
  4695b3:	vmovd  %ecx,%xmm2
  4695b7:	vmovdqa %xmm2,%xmm7
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  4695bb:	vmovq  %xmm2,-0x40(%rbp)
  4695c0:	jmp    4694c5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5f5>
  4695c5:	nopl   (%rax)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4695c8:	mov    $0xffffffff,%r14d
  4695ce:	crc32  %rcx,%r14
  4695d4:	mov    %r14,-0x40(%rbp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  4695d8:	vmovd  %r14d,%xmm7
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  4695dd:	jmp    4694c5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5f5>
  4695e2:	nopw   0x0(%rax,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4695e8:	mov    0x0(%r13),%rcx
  4695ec:	mov    $0xffffffff,%eax
  4695f1:	crc32  %rcx,%rax
  4695f7:	mov    %rax,-0x48(%rbp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1690
  4695fb:	vmovd  %eax,%xmm4
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1690
  4695ff:	jmp    469404 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x534>
  469604:	nopl   0x0(%rax)
  469608:	vzeroupper 
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:705
  46960b:	lea    -0x30(%rbp),%rsp
  46960f:	pop    %rbx
  469610:	pop    %r11
  469612:	pop    %r12
  469614:	pop    %r13
  469616:	pop    %r14
  469618:	pop    %r15
  46961a:	pop    %rbp
  46961b:	lea    -0x8(%r11),%rsp
  46961f:	ret    
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469620:	vpcmpequq %zmm8,%zmm7,%k3{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:801
  469627:	kortestb %k3,%k3
  46962b:	jne    469707 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x837>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  469631:	vmovdqu (%r10),%xmm3
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469636:	mov    $0xffffffff,%edi
  46963b:	crc32  %r11,%rdi
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  469641:	vpinsrd $0x2,%edi,%xmm3,%xmm4
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  469647:	andn   %edi,%r14d,%r8d
  46964c:	shl    $0x4,%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:811
  469650:	prefetcht2 (%rax,%r8,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469655:	vmovdqu %xmm4,(%r15,%rdx,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:816
  46965b:	add    $0x10,%rdx
  46965f:	and    %rsi,%rdx
  469662:	jmp    4690ed <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x21d>
  469667:	nopw   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469670:	vpcmpequq %zmm8,%zmm9,%k6{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:801
  469677:	kortestb %k6,%k6
  46967b:	jne    4699f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb20>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  469681:	vmovdqu (%r10),%xmm11
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469686:	mov    $0xffffffff,%edi
  46968b:	crc32  %r11,%rdi
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  469691:	vpinsrd $0x2,%edi,%xmm11,%xmm12
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  469697:	andn   %edi,%r14d,%r9d
  46969c:	shl    $0x4,%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:811
  4696a0:	prefetcht2 (%rax,%r9,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  4696a5:	vmovdqu %xmm12,(%r15,%rdx,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:816
  4696ab:	add    $0x10,%rdx
  4696af:	and    %rsi,%rdx
  4696b2:	jmp    46906c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x19c>
  4696b7:	nopw   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4696c0:	vpcmpequq %zmm8,%zmm7,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:801
  4696c7:	kortestb %k0,%k0
  4696cb:	jne    4699e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb18>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  4696d1:	vmovdqu (%r11),%xmm3
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4696d6:	mov    $0xffffffff,%edi
  4696db:	crc32  %r8,%rdi
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  4696e1:	vpinsrd $0x2,%edi,%xmm3,%xmm4
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  4696e7:	andn   %edi,%r14d,%r10d
  4696ec:	shl    $0x4,%r10
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:811
  4696f0:	prefetcht2 (%rax,%r10,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  4696f5:	vmovdqu %xmm4,(%r15,%rdx,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:816
  4696fb:	add    $0x10,%rdx
  4696ff:	and    %rsi,%rdx
  469702:	jmp    468fec <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x11c>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:802
  469707:	incl   -0x60(%rbp)
  46970a:	nopw   0x0(%rax,%rax,1)
_Z9_pdep_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmi2intrin.h:48
  469710:	mov    $0x55,%r11d
  469716:	pdep   %r11d,%ecx,%r9d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:827
  46971b:	popcnt %ecx,%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:826
  46971f:	lea    (%r9,%r9,2),%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:827
  469723:	shl    $0x4,%rcx
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  469727:	kmovb  %edi,%k6
  46972b:	vpcompressq %zmm13,(%r12){%k6}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:827
  469732:	add    %rcx,%r12
  469735:	jmp    469181 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b1>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1080
  46973a:	cmp    -0x58(%rbp),%r13
  46973e:	je     46960b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x73b>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1680
  469744:	mov    0x88(%r12),%r8
  46974c:	mov    0x60(%r12),%r10
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469751:	mov    $0x55,%ecx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1680
  469756:	dec    %r8
  469759:	mov    %r10,-0x38(%rbp)
  46975d:	mov    %r8,-0x40(%rbp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  469761:	mov    0x29480(%rip),%r14        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1431
  469768:	mov    0x29399(%rip),%r15        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46976f:	mov    0xa0(%r12),%r9
  469777:	mov    %edi,%ebx
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469779:	vpxor  %xmm2,%xmm2,%xmm2
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1429
  46977d:	kmovb  0x2937b(%rip),%k2        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469785:	kmovb  %ecx,%k1
  469789:	jmp    4697f1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x921>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:39
  46978b:	cmpq   $0x8,-0x38(%rbp)
  469790:	je     469991 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xac1>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1690
  469796:	vmovd  -0x50(%rbp),%xmm4
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1680
  46979b:	mov    -0x40(%rbp),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1690
  46979f:	mov    %edi,%edx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1680
  4697a1:	and    -0x50(%rbp),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1683
  4697a5:	and    $0xfffffffffffffffc,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1471
  4697a9:	shl    $0x4,%rbx
  4697ad:	vpinsrd $0x1,0xc(%r13),%xmm4,%xmm6
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1690
  4697b4:	mov    0x0(%r13),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1471
  4697b8:	prefetcht2 (%r14,%rbx,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1690
  4697bd:	shl    $0x4,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1708
  4697c1:	lea    0x1(%rdi),%ebx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1690
  4697c4:	add    %r9,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1709
  4697c7:	and    %esi,%ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1080
  4697c9:	add    $0x10,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1237
  4697cd:	mov    %r8,(%rdx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1238
  4697d0:	vmovq  %xmm6,0x8(%rdx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1709
  4697d5:	mov    %ebx,0xb0(%r12)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1080
  4697dd:	cmp    %r13,-0x58(%rbp)
  4697e1:	je     469608 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17get_find_queue_szEv():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:525
  4697e7:	mov    0xb4(%r12),%eax
  4697ef:	mov    %ebx,%edi
  4697f1:	sub    %eax,%ebx
  4697f3:	and    %esi,%ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1081
  4697f5:	cmp    %ebx,%esi
  4697f7:	jbe    469820 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x950>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4697f9:	cmpq   $0x4,-0x38(%rbp)
  4697fe:	jne    46978b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8bb>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469800:	mov    $0xffffffff,%r10d
  469806:	crc32l 0x0(%r13),%r10d
  46980d:	vmovd  %r10d,%xmm5
  469812:	vmovdqa %xmm5,%xmm4
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  469816:	vmovq  %xmm5,-0x50(%rbp)
  46981b:	jmp    46979b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8cb>
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1210
  469820:	mov    0x80(%r12),%r10
  469828:	mov    %r10,-0x48(%rbp)
  46982c:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:618
  469830:	lea    0x18(%rax),%edx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  469833:	and    %esi,%edx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1215
  469835:	shl    $0x4,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  469839:	mov    %r10d,%ebx
  46983c:	and    0x8(%r9,%rdx,1),%ebx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:622
  469841:	mov    %eax,%edx
  469843:	shl    $0x4,%rdx
  469847:	add    %r9,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1413
  46984a:	mov    (%rdx),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  46984d:	shl    $0x4,%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:620
  469851:	prefetcht0 (%r14,%rbx,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1413
  469856:	cmp    0x90(%r12),%r8
  46985e:	jne    4698a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9d0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1429
  469860:	kortestb %k2,%k2
  469864:	je     469884 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b4>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1430
  469866:	mov    (%r11),%ebx
  469869:	mov    0xc(%rdx),%edx
  46986c:	mov    %rbx,%r8
  46986f:	shl    $0x4,%rbx
  469873:	add    0x8(%r11),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1432
  469877:	lea    0x1(%r8),%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1430
  46987b:	mov    %edx,(%rbx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1431
  46987d:	mov    %r15,0x8(%rbx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1432
  469881:	mov    %ecx,(%r11)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  469884:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469886:	and    %esi,%eax
  469888:	mov    %eax,0xb4(%r12)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:626
  469890:	test   %r15,%r15
  469893:	jne    469830 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x960>
  469895:	jmp    4697f9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x929>
  46989a:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1215
  4698a0:	mov    0x8(%rdx),%ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1276
  4698a3:	mov    %r10d,%ecx
  4698a6:	and    %ebx,%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1278
  4698a8:	shl    $0x4,%rcx
  4698ac:	add    %r14,%rcx
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4698af:	vmovdqa64 (%rcx),%zmm0
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  4698b5:	vpbroadcastq %r8,%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4698bb:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1282
  4698c2:	kortestb %k0,%k0
  4698c6:	jne    46993e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa6e>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4698c8:	vpcmpequq %zmm2,%zmm0,%k3{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1290
  4698cf:	kortestb %k3,%k3
  4698d3:	jne    469980 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xab0>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4698d9:	cmpq   $0x4,-0x38(%rbp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1292
  4698de:	mov    %ebx,%ecx
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4698e0:	je     4699aa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xada>
/opt/DRAMHiT/include/hasher.hpp:39
  4698e6:	cmpq   $0x8,-0x38(%rbp)
  4698eb:	je     4699bf <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaef>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  4698f1:	mov    -0x60(%rbp),%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1294
  4698f4:	mov    -0x48(%rbp),%rbx
  4698f8:	vmovd  %ecx,%xmm7
  4698fc:	vpinsrd $0x1,0xc(%rdx),%xmm7,%xmm3
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  469903:	mov    %edi,%edx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1294
  469905:	and    -0x60(%rbp),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  469909:	shl    $0x4,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1301
  46990d:	inc    %edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  46990f:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  469911:	add    %r9,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1471
  469914:	shl    $0x4,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1302
  469918:	and    %esi,%edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  46991a:	and    %esi,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1471
  46991c:	prefetcht2 (%r14,%rbx,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1237
  469921:	mov    %r8,(%rdx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1238
  469924:	vmovq  %xmm3,0x8(%rdx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1302
  469929:	mov    %edi,0xb0(%r12)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469931:	mov    %eax,0xb4(%r12)
  469939:	jmp    469830 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x960>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1283
  46993e:	mov    (%r11),%r8d
  469941:	mov    0xc(%rdx),%ebx
  469944:	mov    %r8,%r10
  469947:	shl    $0x4,%r8
  46994b:	add    0x8(%r11),%r8
  46994f:	mov    %ebx,(%r8)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469952:	xor    %ebx,%ebx
  469954:	kmovb  %k0,%edx
  469958:	tzcnt  %edx,%ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1284
  46995c:	inc    %ebx
  46995e:	movslq %ebx,%rdx
  469961:	mov    (%rcx,%rdx,8),%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  469965:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1285
  469967:	inc    %r10d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  46996a:	and    %esi,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1284
  46996c:	mov    %rcx,0x8(%r8)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1285
  469970:	mov    %r10d,(%r11)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469973:	mov    %eax,0xb4(%r12)
  46997b:	jmp    4697f9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x929>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  469980:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469982:	and    %esi,%eax
  469984:	mov    %eax,0xb4(%r12)
  46998c:	jmp    4697f9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x929>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469991:	mov    $0xffffffff,%eax
  469996:	crc32q 0x0(%r13),%rax
  46999d:	mov    %rax,-0x50(%rbp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1690
  4699a1:	vmovd  %eax,%xmm4
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1690
  4699a5:	jmp    46979b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8cb>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4699aa:	mov    $0xffffffff,%ecx
  4699af:	crc32  %ebx,%ecx
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  4699b4:	mov    %ecx,%ebx
  4699b6:	mov    %rbx,-0x60(%rbp)
  4699ba:	jmp    4698f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa24>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4699bf:	mov    $0xffffffff,%ebx
  4699c4:	crc32  %rcx,%rbx
  4699ca:	mov    %rbx,-0x60(%rbp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  4699ce:	mov    %ebx,%ecx
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  4699d0:	jmp    4698f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa24>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:802
  4699d5:	incl   -0x60(%rbp)
  4699d8:	vpxor  %xmm0,%xmm0,%xmm0
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:782
  4699dc:	xor    %ecx,%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:781
  4699de:	vpxor  %xmm13,%xmm13,%xmm13
  4699e3:	jmp    468fec <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x11c>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:802
  4699e8:	incl   -0x60(%rbp)
  4699eb:	jmp    46906c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x19c>
  4699f0:	incl   -0x60(%rbp)
  4699f3:	jmp    4690ed <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x21d>
