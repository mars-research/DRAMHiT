
/opt/DRAMHiT/scripts/eurosys_2026/optimize_hbm/attempt11/dvs_p3/dramhit:     file format elf64-x86-64


Disassembly of section .text:

0000000000468de0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:703
  468de0:	push   %rbp
  468de1:	mov    %rdi,%rcx
  468de4:	mov    %rsp,%rbp
  468de7:	push   %r15
  468de9:	mov    %rdx,%r15
  468dec:	push   %r14
  468dee:	push   %r13
  468df0:	push   %r12
  468df2:	push   %rbx
  468df3:	and    $0xffffffffffffffc0,%rsp
  468df7:	sub    $0x8,%rsp
  468dfb:	mov    0x8(%rsi),%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:717
  468dff:	mov    0xb0(%rdi),%edi
  468e05:	mov    0xb4(%rcx),%eax
  468e0b:	mov    (%rsi),%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:718
  468e0e:	mov    0x78(%rcx),%r8d
  468e12:	mov    0x6c(%rcx),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:873
  468e16:	mov    %r11,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:717
  468e19:	mov    %edi,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:873
  468e1b:	shl    $0x4,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:717
  468e1f:	sub    %eax,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:873
  468e21:	lea    (%rdx,%r10,1),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:717
  468e25:	and    %r8d,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:718
  468e28:	lea    -0x1(%r9),%r12d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:873
  468e2c:	mov    %rbx,-0x20(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:720
  468e31:	cmp    %r12d,%esi
  468e34:	jb     46969c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8bc>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:779
  468e3a:	and    $0xfffffffffffffffc,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:727
  468e3e:	shl    $0x4,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:779
  468e42:	shl    $0x4,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:732
  468e46:	mov    0x8(%r15),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:736
  468e4a:	mov    0x80(%rcx),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:727
  468e50:	mov    %r9,-0x18(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:779
  468e55:	mov    %r11,-0x38(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:727
  468e5a:	lea    -0x1(%r9),%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:779
  468e5e:	lea    (%rdx,%r11,1),%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:729
  468e62:	mov    %edi,%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:732
  468e65:	mov    %r14,(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:779
  468e69:	mov    %r11,-0x28(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:731
  468e6e:	movl   $0x0,-0x2c(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:726
  468e76:	mov    0xa0(%rcx),%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:745
  468e7d:	mov    0x29d64(%rip),%rdi        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:728
  468e84:	shl    $0x4,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:729
  468e88:	shl    $0x4,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:736
  468e8c:	not    %esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:780
  468e8e:	cmp    %r11,%rdx
  468e91:	je     46993a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb5a>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468e97:	mov    $0x55,%r13d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468e9d:	mov    $0xf,%ebx
  468ea2:	mov    $0xf0,%r12d
  468ea8:	mov    $0xf00,%r11d
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468eae:	kmovb  %r13d,%k2
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468eb3:	mov    $0xfffff000,%r13d
  468eb9:	mov    %rcx,-0x40(%rsp)
  468ebe:	mov    %r15,-0x48(%rsp)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468ec3:	vpxor  %xmm4,%xmm4,%xmm4
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468ec7:	mov    $0xffffffff,%r14d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468ecd:	kmovw  %ebx,%k6
  468ed1:	kmovw  %r12d,%k5
  468ed6:	kmovw  %r11d,%k4
  468edb:	kmovw  %r13d,%k3
  468ee0:	jmp    469139 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  468ee5:	nopl   (%rax)
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468ee8:	vmovd  0xc(%r12),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468eef:	kshiftlb $0x1,%k7,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468ef5:	vpcompressq %zmm8,%zmm12{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468efb:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468f00:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k6}{z}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468f07:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:799
  468f0d:	mov    $0x1,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:788
  468f13:	lea    (%r8,%rax,1),%r13
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:787
  468f17:	lea    0x180(%rax),%r12
  468f1e:	and    %r10,%r12
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:747
  468f21:	mov    0x8(%r13),%r15d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  468f25:	andn   0x8(%r8,%r12,1),%esi,%ecx
  468f2c:	shl    $0x4,%rcx
  468f30:	andn   %r15d,%esi,%r12d
  468f35:	shl    $0x4,%r12
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468f39:	vmovdqa64 (%rdi,%r12,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:752
  468f40:	vpbroadcastq 0x0(%r13),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468f47:	vpcmpequq %zmm2,%zmm0,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:789
  468f4e:	add    $0x10,%rax
  468f52:	and    %r10,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:787
  468f55:	prefetcht0 (%rdi,%rcx,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:793
  468f59:	kortestb %k0,%k0
  468f5d:	je     4695b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468f63:	vmovd  0xc(%r13),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468f69:	kshiftlb $0x1,%k0,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468f6f:	vpcompressq %zmm0,%zmm6{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468f75:	vpunpcklqdq %xmm6,%xmm1,%xmm7
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468f79:	vshufi32x4 $0x0,%zmm7,%zmm7,%zmm15{%k5}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468f80:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:799
  468f86:	or     $0x2,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:787
  468f8a:	lea    0x180(%rax),%r13
  468f91:	and    %r10,%r13
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  468f94:	andn   0x8(%r8,%r13,1),%esi,%ecx
  468f9b:	shl    $0x4,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:788
  468f9f:	lea    (%r8,%rax,1),%r13
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:747
  468fa3:	mov    0x8(%r13),%ebx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  468fa7:	andn   %ebx,%esi,%r12d
  468fac:	shl    $0x4,%r12
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468fb0:	vmovdqa64 (%rdi,%r12,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:752
  468fb7:	vpbroadcastq 0x0(%r13),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468fbe:	vpcmpequq %zmm9,%zmm8,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:789
  468fc5:	add    $0x10,%rax
  468fc9:	and    %r10,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:787
  468fcc:	prefetcht0 (%rdi,%rcx,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:793
  468fd0:	kortestb %k0,%k0
  468fd4:	je     469560 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x780>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468fda:	vmovd  0xc(%r13),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468fe0:	kshiftlb $0x1,%k0,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468fe6:	vpcompressq %zmm8,%zmm12{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468fec:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468ff1:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k4}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468ff8:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:799
  468ffe:	or     $0x4,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:788
  469002:	lea    (%r8,%rax,1),%r15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:787
  469006:	lea    0x180(%rax),%r13
  46900d:	and    %r10,%r13
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:747
  469010:	mov    0x8(%r15),%r12d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  469014:	andn   0x8(%r8,%r13,1),%esi,%ecx
  46901b:	shl    $0x4,%rcx
  46901f:	andn   %r12d,%esi,%r13d
  469024:	shl    $0x4,%r13
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469028:	vmovdqa64 (%rdi,%r13,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:752
  46902f:	vpbroadcastq (%r15),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469035:	vpcmpequq %zmm2,%zmm0,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:789
  46903c:	add    $0x10,%rax
  469040:	and    %r10,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:787
  469043:	prefetcht0 (%rdi,%rcx,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:793
  469047:	kortestb %k0,%k0
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:852
  46904b:	lea    (%r8,%r9,1),%rcx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:793
  46904f:	je     469518 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469055:	vmovd  0xc(%r15),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  46905b:	kshiftlb $0x1,%k0,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  469061:	vpcompressq %zmm0,%zmm6{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  469067:	vpunpcklqdq %xmm6,%xmm1,%xmm7
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  46906b:	vshufi32x4 $0x0,%zmm7,%zmm7,%zmm15{%k3}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:799
  469072:	or     $0x8,%r11d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  469076:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:823
  46907c:	cmp    $0xf,%r11d
  469080:	jne    469668 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x888>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  469086:	mov    (%rsp),%r15
  46908a:	vmovdqu64 %zmm15,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:825
  469090:	add    $0x40,%r15
  469094:	mov    %r15,(%rsp)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469098:	mov    %r14,%rbx
  46909b:	mov    %r14,%r11
  46909e:	crc32q (%rdx),%rbx
  4690a4:	crc32q 0x20(%rdx),%r11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  4690ab:	andn   %ebx,%esi,%r13d
  4690b0:	shl    $0x4,%r13
  4690b4:	andn   %r11d,%esi,%r15d
  4690b9:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:836
  4690bd:	prefetcht2 (%rdi,%r13,1)
  4690c2:	prefetcht2 (%rdi,%r15,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690c7:	mov    %r14,%r13
  4690ca:	mov    %r14,%r15
  4690cd:	crc32q 0x10(%rdx),%r13
  4690d4:	crc32q 0x30(%rdx),%r15
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  4690db:	andn   %r13d,%esi,%r12d
  4690e0:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:836
  4690e4:	prefetcht2 (%rdi,%r12,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  4690e9:	andn   %r15d,%esi,%r12d
  4690ee:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:836
  4690f2:	prefetcht2 (%rdi,%r12,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:848
  4690f7:	lea    0x40(%r9),%r12
_Z18_mm512_loadu_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6414
  4690fb:	vmovdqu64 (%rdx),%zmm15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:848
  469101:	cmp    %r12,-0x18(%rsp)
  469106:	jb     4695f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x818>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  46910c:	vmovdqu64 %zmm15,(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:854
  469112:	mov    %ebx,0x8(%rcx)
  469115:	mov    %r13d,0x18(%r8,%r9,1)
  46911a:	mov    %r11d,0x28(%r8,%r9,1)
  46911f:	mov    %r15d,0x38(%r8,%r9,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:866
  469124:	mov    %r12,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:780
  469127:	add    $0x40,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:866
  46912b:	and    %r10,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:780
  46912e:	cmp    %rdx,-0x28(%rsp)
  469133:	je     4691d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3f8>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:788
  469139:	lea    (%r8,%rax,1),%r12
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:747
  46913d:	mov    0x8(%r12),%r11d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  469142:	andn   %r11d,%esi,%r13d
  469147:	shl    $0x4,%r13
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  46914b:	vmovdqa64 (%rdi,%r13,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:752
  469152:	vpbroadcastq (%r12),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469159:	vpcmpequq %zmm9,%zmm8,%k7{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:787
  469160:	lea    0x180(%rax),%rcx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:789
  469167:	add    $0x10,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:787
  46916b:	and    %r10,%rcx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:789
  46916e:	and    %r10,%rax
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  469171:	andn   0x8(%r8,%rcx,1),%esi,%r15d
  469178:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:793
  46917c:	kortestb %k7,%k7
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:787
  469180:	prefetcht0 (%rdi,%r15,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:793
  469185:	jne    468ee8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46918b:	vpcmpequq %zmm4,%zmm8,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:802
  469192:	kortestb %k1,%k1
  469196:	jne    469963 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb83>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  46919c:	vmovdqu (%r12),%xmm10
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4691a2:	mov    %r14,%rcx
  4691a5:	crc32  %r11,%rcx
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  4691ab:	vpinsrd $0x2,%ecx,%xmm10,%xmm11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  4691b1:	andn   %ecx,%esi,%r15d
  4691b6:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:812
  4691ba:	prefetcht2 (%rdi,%r15,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  4691bf:	vmovdqu %xmm11,(%r8,%r9,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:817
  4691c5:	add    $0x10,%r9
  4691c9:	and    %r10,%r9
  4691cc:	jmp    469139 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  4691d1:	nopl   0x0(%rax)
  4691d8:	mov    -0x40(%rsp),%rcx
  4691dd:	mov    -0x48(%rsp),%r15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:871
  4691e2:	mov    -0x2c(%rsp),%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:869
  4691e6:	vmovq  %r9,%xmm14
  4691eb:	vpinsrq $0x1,%rax,%xmm14,%xmm0
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:871
  4691f1:	mov    -0x38(%rsp),%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:869
  4691f6:	vpsrlq $0x4,%xmm0,%xmm2
  4691fb:	vpmovqd %xmm2,%xmm3
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:871
  469201:	sar    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:869
  469205:	vmovq  %xmm3,0xb0(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:871
  46920d:	sub    %rdi,%rsi
  469210:	add    %esi,(%r15)
  469213:	vpextrd $0x1,%xmm3,%eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:873
  469219:	cmp    -0x20(%rsp),%rdx
  46921e:	je     469500 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1678
  469224:	mov    0x88(%rcx),%rdi
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1219
  46922b:	mov    0x80(%rcx),%rbx
  469232:	mov    0x60(%rcx),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1678
  469236:	dec    %rdi
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1219
  469239:	mov    %rbx,-0x18(%rsp)
  46923e:	mov    %r8,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1678
  469242:	mov    %rdi,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:618
  469247:	mov    0x78(%rcx),%r10d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  46924b:	mov    0x29996(%rip),%r11        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469252:	mov    0xa0(%rcx),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1427
  469259:	movzbl 0x2989f(%rip),%r13d        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1429
  469261:	mov    0x298a0(%rip),%r12        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469268:	mov    $0x55,%r14d
  46926e:	vpxor  %xmm7,%xmm7,%xmm7
  469272:	kmovb  %r14d,%k2
  469277:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:618
  469280:	lea    0x18(%rax),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  469283:	and    %r10d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1224
  469286:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  46928a:	mov    %ebx,%r8d
  46928d:	and    0x8(%r9,%rsi,1),%r8d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:622
  469292:	mov    %eax,%esi
  469294:	shl    $0x4,%rsi
  469298:	add    %r9,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  46929b:	mov    %r8,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1411
  46929e:	mov    (%rsi),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  4692a1:	shl    $0x4,%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:620
  4692a5:	prefetcht0 (%r11,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1411
  4692aa:	cmp    0x90(%rcx),%r8
  4692b1:	jne    469370 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x590>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1427
  4692b7:	test   %r13b,%r13b
  4692ba:	je     4692da <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fa>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1428
  4692bc:	mov    (%r15),%r14d
  4692bf:	mov    0xc(%rsi),%esi
  4692c2:	mov    %r14,%r8
  4692c5:	shl    $0x4,%r14
  4692c9:	add    0x8(%r15),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1430
  4692cd:	inc    %r8d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1428
  4692d0:	mov    %esi,(%r14)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1429
  4692d3:	mov    %r12,0x8(%r14)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1430
  4692d7:	mov    %r8d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  4692da:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  4692dc:	and    %r10d,%eax
  4692df:	mov    %eax,0xb4(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:626
  4692e5:	test   %r12,%r12
  4692e8:	jne    469280 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4692ea:	cmpq   $0x4,(%rsp)
  4692ef:	je     469465 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x685>
  4692f5:	nopl   (%rax)
/opt/DRAMHiT/include/hasher.hpp:39
  4692f8:	cmpq   $0x8,(%rsp)
  4692fd:	je     4694e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  469303:	vmovd  -0x10(%rsp),%xmm15
  469309:	mov    (%rdx),%rdi
  46930c:	mov    0xb0(%rcx),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1678
  469312:	mov    -0x28(%rsp),%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  469317:	mov    %rsi,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1678
  46931a:	and    -0x10(%rsp),%r8
  46931f:	vpinsrd $0x1,0xc(%rdx),%xmm15,%xmm9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1681
  469326:	and    $0xfffffffffffffffc,%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  46932a:	shl    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1706
  46932e:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  469330:	add    %r9,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1469
  469333:	shl    $0x4,%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1707
  469337:	and    %r10d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:873
  46933a:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1469
  46933e:	prefetcht2 (%r11,%r8,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1235
  469343:	mov    %rdi,(%rsi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1236
  469346:	vmovq  %xmm9,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1707
  46934b:	mov    %eax,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:873
  469351:	cmp    -0x20(%rsp),%rdx
  469356:	je     469500 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:618
  46935c:	mov    0xb4(%rcx),%eax
  469362:	jmp    469280 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  469367:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1224
  469370:	mov    0x8(%rsi),%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1274
  469374:	mov    %ebx,%edi
  469376:	and    %r14d,%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1276
  469379:	shl    $0x4,%rdi
  46937d:	add    %r11,%rdi
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469380:	vmovdqa64 (%rdi),%zmm5
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  469386:	vpbroadcastq %r8,%zmm6
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46938c:	vpcmpequq %zmm6,%zmm5,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  469393:	kortestb %k0,%k0
  469397:	jne    469420 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x640>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46939d:	vpcmpequq %zmm7,%zmm5,%k3{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1288
  4693a4:	kortestb %k3,%k3
  4693a8:	jne    469490 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4693ae:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1290
  4693b3:	mov    %r14d,%edi
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4693b6:	je     4694a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
/opt/DRAMHiT/include/hasher.hpp:39
  4693bc:	cmpq   $0x8,(%rsp)
  4693c1:	je     4694c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1298
  4693c7:	vmovd  -0x8(%rsp),%xmm1
  4693cd:	mov    0xb0(%rcx),%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1292
  4693d3:	mov    -0x18(%rsp),%r14
  4693d8:	vpinsrd $0x1,0xc(%rsi),%xmm1,%xmm4
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1298
  4693df:	mov    %rdi,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1292
  4693e2:	and    -0x8(%rsp),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1298
  4693e7:	shl    $0x4,%rdi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1299
  4693eb:	inc    %esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  4693ed:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1298
  4693ef:	add    %r9,%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1469
  4693f2:	shl    $0x4,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  4693f6:	and    %r10d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  4693f9:	and    %r10d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1469
  4693fc:	prefetcht2 (%r11,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1235
  469401:	mov    %r8,(%rdi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1236
  469404:	vmovq  %xmm4,0x8(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  469409:	mov    %esi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  46940f:	mov    %eax,0xb4(%rcx)
  469415:	jmp    469280 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  46941a:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1281
  469420:	mov    (%r15),%r8d
  469423:	mov    0xc(%rsi),%esi
  469426:	mov    %r8,%r14
  469429:	shl    $0x4,%r8
  46942d:	add    0x8(%r15),%r8
  469431:	mov    %esi,(%r8)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469434:	kmovb  %k0,%esi
  469438:	tzcnt  %esi,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1282
  46943c:	inc    %esi
  46943e:	movslq %esi,%rsi
  469441:	mov    (%rdi,%rsi,8),%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  469445:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1283
  469447:	inc    %r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  46944a:	and    %r10d,%eax
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  46944d:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1282
  469452:	mov    %rdi,0x8(%r8)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1283
  469456:	mov    %r14d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469459:	mov    %eax,0xb4(%rcx)
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  46945f:	jne    4692f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x518>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469465:	mov    $0xffffffff,%r14d
  46946b:	crc32l (%rdx),%r14d
  469471:	vmovd  %r14d,%xmm8
  469476:	mov    (%rdx),%rdi
  469479:	vmovdqa %xmm8,%xmm15
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  46947e:	vmovq  %xmm8,-0x10(%rsp)
  469484:	jmp    46930c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  469489:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  469490:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469492:	and    %r10d,%eax
  469495:	mov    %eax,0xb4(%rcx)
  46949b:	jmp    4692ea <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4694a0:	mov    $0xffffffff,%edi
  4694a5:	crc32  %r14d,%edi
  4694ab:	vmovd  %edi,%xmm12
  4694af:	vmovdqa %xmm12,%xmm1
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  4694b3:	vmovq  %xmm12,-0x8(%rsp)
  4694b9:	jmp    4693cd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  4694be:	xchg   %ax,%ax
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4694c0:	mov    $0xffffffff,%r14d
  4694c6:	crc32  %rdi,%r14
  4694cc:	mov    %r14,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1298
  4694d1:	vmovd  %r14d,%xmm1
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1298
  4694d6:	jmp    4693cd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  4694db:	nopl   0x0(%rax,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4694e0:	mov    (%rdx),%rdi
  4694e3:	mov    $0xffffffff,%eax
  4694e8:	crc32  %rdi,%rax
  4694ee:	mov    %rax,-0x10(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  4694f3:	vmovd  %eax,%xmm15
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  4694f7:	jmp    46930c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  4694fc:	nopl   0x0(%rax)
  469500:	vzeroupper 
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:705
  469503:	lea    -0x28(%rbp),%rsp
  469507:	pop    %rbx
  469508:	pop    %r12
  46950a:	pop    %r13
  46950c:	pop    %r14
  46950e:	pop    %r15
  469510:	pop    %rbp
  469511:	ret    
  469512:	nopw   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469518:	vpcmpequq %zmm4,%zmm0,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:802
  46951f:	kortestb %k1,%k1
  469523:	jne    469660 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x880>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  469529:	vmovdqu (%r15),%xmm3
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  46952e:	mov    %r14,%rbx
  469531:	crc32  %r12,%rbx
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  469537:	vpinsrd $0x2,%ebx,%xmm3,%xmm5
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:817
  46953d:	add    $0x10,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  469541:	andn   %ebx,%esi,%r12d
  469546:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:817
  46954a:	and    %r10,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:812
  46954d:	prefetcht2 (%rdi,%r12,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469552:	vmovdqu %xmm5,(%rcx)
  469556:	jmp    469002 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
  46955b:	nopl   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469560:	vpcmpequq %zmm4,%zmm8,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:802
  469567:	kortestb %k1,%k1
  46956b:	jne    469979 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb99>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  469571:	vmovdqu 0x0(%r13),%xmm10
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469577:	mov    %r14,%rcx
  46957a:	crc32  %rbx,%rcx
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  469580:	vpinsrd $0x2,%ecx,%xmm10,%xmm11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  469586:	andn   %ecx,%esi,%r15d
  46958b:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:812
  46958f:	prefetcht2 (%rdi,%r15,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469594:	vmovdqu %xmm11,(%r8,%r9,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:817
  46959a:	add    $0x10,%r9
  46959e:	and    %r10,%r9
  4695a1:	jmp    468f8a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  4695a6:	cs nopw 0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4695b0:	vpcmpequq %zmm4,%zmm0,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:802
  4695b7:	kortestb %k1,%k1
  4695bb:	jne    46995a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb7a>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  4695c1:	vmovdqu 0x0(%r13),%xmm3
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4695c7:	mov    %r14,%rcx
  4695ca:	crc32  %r15,%rcx
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  4695d0:	vpinsrd $0x2,%ecx,%xmm3,%xmm5
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:742
  4695d6:	andn   %ecx,%esi,%ebx
  4695db:	shl    $0x4,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:812
  4695df:	prefetcht2 (%rdi,%rbx,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  4695e3:	vmovdqu %xmm5,(%r8,%r9,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:817
  4695e9:	add    $0x10,%r9
  4695ed:	and    %r10,%r9
  4695f0:	jmp    468f13 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  4695f5:	nopl   (%rax)
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  4695f8:	vmovd  %ebx,%xmm10
  4695fc:	vpinsrd $0x1,%r13d,%xmm10,%xmm11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:861
  469602:	mov    -0x18(%rsp),%r13
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469607:	vmovd  %r11d,%xmm8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:861
  46960c:	mov    %r13,%r11
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46960f:	vpinsrd $0x1,%r15d,%xmm8,%xmm9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:861
  469615:	sub    %r9,%r11
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  469618:	mov    $0x4444,%ebx
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46961d:	vpunpcklqdq %xmm9,%xmm11,%xmm13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:862
  469622:	shr    $0x2,%r11
  469626:	mov    $0x1,%r15d
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  46962c:	kmovw  %ebx,%k7
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:862
  469630:	shlx   %r11d,%r15d,%r11d
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  469635:	vpexpandd %zmm13,%zmm15{%k7}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:862
  46963b:	lea    -0x1(%r11),%ebx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:864
  46963f:	sub    %r13,%r9
  469642:	neg    %r11d
_Z24_mm512_mask_storeu_epi32PvtDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6461
  469645:	kmovw  %ebx,%k1
  469649:	vmovdqu32 %zmm15,(%rcx){%k1}
  46964f:	kmovw  %r11d,%k7
  469654:	vmovdqu32 %zmm15,(%r8,%r9,1){%k7}
  46965b:	jmp    469124 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x344>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:803
  469660:	incl   -0x2c(%rsp)
  469664:	nopl   0x0(%rax)
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  469668:	mov    (%rsp),%r12
_Z9_pdep_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmi2intrin.h:48
  46966c:	mov    $0x55,%r15d
  469672:	pdep   %r15d,%r11d,%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:828
  469677:	popcnt %r11d,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:827
  46967c:	lea    0x0(%r13,%r13,2),%ebx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:828
  469681:	shl    $0x4,%r11
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  469685:	kmovb  %ebx,%k1
  469689:	vpcompressq %zmm12,(%r12){%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:828
  469690:	add    %r11,%r12
  469693:	mov    %r12,(%rsp)
  469697:	jmp    469098 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b8>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1089
  46969c:	cmp    -0x20(%rsp),%rdx
  4696a1:	je     469503 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x723>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1678
  4696a7:	mov    0x88(%rcx),%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1427
  4696ae:	movzbl 0x2944a(%rip),%r13d        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1429
  4696b6:	mov    0x2944b(%rip),%r9        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4696bd:	mov    0x60(%rcx),%r10
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4696c1:	mov    $0x55,%ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1678
  4696c6:	dec    %r12
  4696c9:	kmovb  %r13d,%k2
  4696ce:	mov    %r10,(%rsp)
  4696d2:	mov    %r12,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  4696d7:	mov    0x2950a(%rip),%r14        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4696de:	mov    0xa0(%rcx),%r11
  4696e5:	mov    %edi,%esi
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4696e7:	vpxor  %xmm2,%xmm2,%xmm2
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1678
  4696eb:	mov    %r9,%r13
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4696ee:	kmovb  %ebx,%k1
  4696f2:	jmp    46975a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x97a>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:39
  4696f4:	cmpq   $0x8,(%rsp)
  4696f9:	je     469908 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb28>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  4696ff:	vmovd  -0x18(%rsp),%xmm5
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1678
  469705:	mov    -0x8(%rsp),%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  46970a:	mov    %edi,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1678
  46970c:	and    -0x18(%rsp),%r12
  469711:	vpinsrd $0x1,0xc(%rdx),%xmm5,%xmm7
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  469718:	mov    (%rdx),%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1681
  46971b:	and    $0xfffffffffffffffc,%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  46971f:	shl    $0x4,%rsi
  469723:	add    %r11,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1469
  469726:	shl    $0x4,%r12
  46972a:	prefetcht2 (%r14,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1235
  46972f:	mov    %r10,(%rsi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1236
  469732:	vmovq  %xmm7,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1706
  469737:	lea    0x1(%rdi),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1707
  46973a:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1089
  46973d:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1707
  469741:	mov    %esi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1089
  469747:	cmp    %rdx,-0x20(%rsp)
  46974c:	je     469500 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17get_find_queue_szEv():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:525
  469752:	mov    0xb4(%rcx),%eax
  469758:	mov    %esi,%edi
  46975a:	sub    %eax,%esi
  46975c:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1090
  46975f:	cmp    %esi,%r8d
  469762:	jbe    469785 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a5>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  469764:	cmpq   $0x4,(%rsp)
  469769:	jne    4696f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x914>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  46976b:	mov    $0xffffffff,%ebx
  469770:	crc32l (%rdx),%ebx
  469775:	vmovd  %ebx,%xmm6
  469779:	vmovdqa %xmm6,%xmm5
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  46977d:	vmovq  %xmm6,-0x18(%rsp)
  469783:	jmp    469705 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1219
  469785:	mov    0x80(%rcx),%rbx
  46978c:	mov    %rbx,-0x10(%rsp)
  469791:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:618
  469798:	lea    0x18(%rax),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  46979b:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1224
  46979e:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  4697a2:	mov    %ebx,%r9d
  4697a5:	and    0x8(%r11,%rsi,1),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:622
  4697aa:	mov    %eax,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  4697ac:	mov    %r9,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:622
  4697af:	shl    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  4697b3:	shl    $0x4,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:622
  4697b7:	add    %r11,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:620
  4697ba:	prefetcht0 (%r14,%r10,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1411
  4697bf:	mov    (%rsi),%r10
  4697c2:	cmp    0x90(%rcx),%r10
  4697c9:	jne    469810 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa30>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1427
  4697cb:	kortestb %k2,%k2
  4697cf:	je     4697f2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa12>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1428
  4697d1:	mov    (%r15),%r12d
  4697d4:	mov    0xc(%rsi),%esi
  4697d7:	mov    %r12,%r10
  4697da:	shl    $0x4,%r12
  4697de:	add    0x8(%r15),%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1430
  4697e2:	lea    0x1(%r10),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1428
  4697e6:	mov    %esi,(%r12)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1429
  4697ea:	mov    %r13,0x8(%r12)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1430
  4697ef:	mov    %r9d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  4697f2:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  4697f4:	and    %r8d,%eax
  4697f7:	mov    %eax,0xb4(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:626
  4697fd:	test   %r13,%r13
  469800:	jne    469798 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  469802:	jmp    469764 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  469807:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1224
  469810:	mov    0x8(%rsi),%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1274
  469814:	mov    %ebx,%r9d
  469817:	and    %r12d,%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1276
  46981a:	shl    $0x4,%r9
  46981e:	add    %r14,%r9
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469821:	vmovdqa64 (%r9),%zmm0
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  469827:	vpbroadcastq %r10,%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46982d:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  469834:	kortestb %k0,%k0
  469838:	jne    4698b4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad4>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46983a:	vpcmpequq %zmm2,%zmm0,%k3{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1288
  469841:	kortestb %k3,%k3
  469845:	jne    4698f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb18>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  46984b:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1290
  469850:	mov    %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  469853:	je     469921 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb41>
/opt/DRAMHiT/include/hasher.hpp:39
  469859:	cmpq   $0x8,(%rsp)
  46985e:	je     469941 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb61>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1298
  469864:	mov    -0x28(%rsp),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1292
  469869:	mov    -0x10(%rsp),%r12
  46986e:	vmovd  %r9d,%xmm4
  469873:	vpinsrd $0x1,0xc(%rsi),%xmm4,%xmm3
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1298
  46987a:	mov    %edi,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1292
  46987c:	and    -0x28(%rsp),%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1298
  469881:	shl    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1299
  469885:	inc    %edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  469887:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1298
  469889:	add    %r11,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1469
  46988c:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  469890:	and    %r8d,%edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469893:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1469
  469896:	prefetcht2 (%r14,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1235
  46989b:	mov    %r10,(%rsi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1236
  46989e:	vmovq  %xmm3,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1300
  4698a3:	mov    %edi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  4698a9:	mov    %eax,0xb4(%rcx)
  4698af:	jmp    469798 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1281
  4698b4:	mov    (%r15),%r10d
  4698b7:	mov    0xc(%rsi),%r12d
  4698bb:	mov    %r10,%rbx
  4698be:	shl    $0x4,%r10
  4698c2:	add    0x8(%r15),%r10
  4698c6:	mov    %r12d,(%r10)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  4698c9:	xor    %r12d,%r12d
  4698cc:	kmovb  %k0,%esi
  4698d0:	tzcnt  %esi,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1282
  4698d5:	inc    %r12d
  4698d8:	movslq %r12d,%rsi
  4698db:	mov    (%r9,%rsi,8),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  4698df:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1283
  4698e1:	inc    %ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  4698e3:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1282
  4698e6:	mov    %r9,0x8(%r10)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1283
  4698ea:	mov    %ebx,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  4698ed:	mov    %eax,0xb4(%rcx)
  4698f3:	jmp    469764 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  4698f8:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  4698fa:	and    %r8d,%eax
  4698fd:	mov    %eax,0xb4(%rcx)
  469903:	jmp    469764 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469908:	mov    $0xffffffff,%eax
  46990d:	crc32q (%rdx),%rax
  469913:	mov    %rax,-0x18(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  469918:	vmovd  %eax,%xmm5
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  46991c:	jmp    469705 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469921:	mov    $0xffffffff,%r9d
  469927:	crc32  %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  46992d:	mov    %r9d,%r12d
  469930:	mov    %r12,-0x28(%rsp)
  469935:	jmp    469869 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:780
  46993a:	xor    %edi,%edi
  46993c:	jmp    4691e6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x406>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469941:	mov    $0xffffffff,%r12d
  469947:	crc32  %r9,%r12
  46994d:	mov    %r12,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1298
  469952:	mov    %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1298
  469955:	jmp    469869 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:803
  46995a:	incl   -0x2c(%rsp)
  46995e:	jmp    468f8a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469963:	incl   -0x2c(%rsp)
  469967:	vpxor  %xmm15,%xmm15,%xmm15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  46996c:	xor    %r11d,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:782
  46996f:	vpxor  %xmm12,%xmm12,%xmm12
  469974:	jmp    468f13 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:803
  469979:	incl   -0x2c(%rsp)
  46997d:	jmp    469002 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
