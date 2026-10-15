
/opt/DRAMHiT/scripts/eurosys_2026/optimize_hbm/attempt11/dvs/dramhit:     file format elf64-x86-64


Disassembly of section .text:

0000000000468e00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:703
  468e00:	push   %rbp
  468e01:	mov    %rdi,%rcx
  468e04:	mov    %rsp,%rbp
  468e07:	push   %r15
  468e09:	mov    %rdx,%r15
  468e0c:	push   %r14
  468e0e:	push   %r13
  468e10:	push   %r12
  468e12:	push   %rbx
  468e13:	and    $0xffffffffffffffc0,%rsp
  468e17:	sub    $0x8,%rsp
  468e1b:	mov    0x8(%rsi),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:717
  468e1f:	mov    0xb0(%rdi),%r10d
  468e26:	mov    0xb4(%rdi),%eax
  468e2c:	mov    (%rsi),%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:718
  468e2f:	mov    0x78(%rdi),%edi
  468e32:	mov    0x6c(%rcx),%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:855
  468e36:	mov    %r9,%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:717
  468e39:	mov    %r10d,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:855
  468e3c:	shl    $0x4,%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:717
  468e40:	sub    %eax,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:855
  468e42:	lea    (%rdx,%r8,1),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:717
  468e46:	and    %edi,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:718
  468e48:	lea    -0x1(%r11),%r12d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:855
  468e4c:	mov    %rbx,-0x20(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:720
  468e51:	cmp    %r12d,%esi
  468e54:	jb     469752 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x952>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:732
  468e5a:	mov    0x8(%r15),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:775
  468e5e:	and    $0xfffffffffffffffc,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:727
  468e62:	shl    $0x4,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:775
  468e66:	shl    $0x4,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:732
  468e6a:	mov    %r14,(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:733
  468e6e:	mov    0x80(%rcx),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:727
  468e75:	mov    %r11,-0x28(%rsp)
  468e7a:	lea    -0x1(%r11),%rdi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:729
  468e7e:	shl    $0x4,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:775
  468e82:	lea    (%rdx,%r9,1),%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:733
  468e86:	mov    %r14d,-0x18(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:775
  468e8b:	mov    %r9,-0x58(%rsp)
  468e90:	mov    %r11,-0x30(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:731
  468e95:	movl   $0x0,-0x4c(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:726
  468e9d:	mov    0xa0(%rcx),%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:765
  468ea4:	mov    0x29d3d(%rip),%rsi        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:728
  468eab:	shl    $0x4,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:729
  468eaf:	mov    %r10,%r13
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:736
  468eb2:	not    %r14d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:776
  468eb5:	cmp    %r11,%rdx
  468eb8:	je     4699ea <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbea>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468ebe:	mov    $0x55,%ebx
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468ec3:	mov    $0xf,%r9d
  468ec9:	mov    $0xf0,%r10d
  468ecf:	mov    $0xf00,%r11d
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468ed5:	kmovb  %ebx,%k1
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468ed9:	mov    $0xfffff000,%ebx
  468ede:	mov    %rcx,-0x60(%rsp)
  468ee3:	mov    %r15,-0x68(%rsp)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468ee8:	vpxor  %xmm4,%xmm4,%xmm4
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468eec:	mov    $0xffffffff,%r12d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468ef2:	kmovw  %r9d,%k5
  468ef7:	kmovw  %r10d,%k4
  468efc:	kmovw  %r11d,%k3
  468f01:	kmovw  %ebx,%k2
  468f05:	jmp    4691a2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3a2>
  468f0a:	nopw   0x0(%rax,%rax,1)
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468f10:	vmovd  0xc(%rbx),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468f15:	kshiftlb $0x1,%k6,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468f1b:	vpcompressq %zmm8,%zmm12{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468f21:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468f26:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k5}{z}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468f2d:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:794
  468f33:	mov    $0x1,%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:784
  468f38:	lea    (%r8,%rax,1),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  468f3c:	lea    0x180(%rax),%r11
  468f43:	and    %rdi,%r11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:739
  468f46:	mov    0x8(%rbx),%r10d
  468f4a:	andn   0x8(%r8,%r11,1),%r14d,%r15d
  468f51:	andn   %r10d,%r14d,%r11d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  468f56:	mov    %r15d,%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:786
  468f59:	mov    %r11d,%r15d
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468f5c:	shl    $0x4,%r15
  468f60:	vmovdqa64 (%rsi,%r15,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:746
  468f67:	vpbroadcastq (%rbx),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468f6d:	vpcmpequq %zmm2,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  468f74:	shl    $0x4,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:785
  468f78:	add    $0x10,%rax
  468f7c:	and    %rdi,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  468f7f:	prefetcht0 (%rsi,%r9,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:788
  468f84:	kortestb %k0,%k0
  468f88:	je     469638 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x838>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468f8e:	vmovd  0xc(%rbx),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468f93:	kshiftlb $0x1,%k0,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468f99:	vpcompressq %zmm0,%zmm6{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468f9f:	vpunpcklqdq %xmm6,%xmm1,%xmm7
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468fa3:	vshufi32x4 $0x0,%zmm7,%zmm7,%zmm15{%k4}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468faa:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:794
  468fb0:	or     $0x2,%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:784
  468fb3:	lea    (%r8,%rax,1),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  468fb7:	lea    0x180(%rax),%r15
  468fbe:	and    %rdi,%r15
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:739
  468fc1:	mov    0x8(%rbx),%r11d
  468fc5:	andn   0x8(%r8,%r15,1),%r14d,%r9d
  468fcc:	andn   %r11d,%r14d,%r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  468fd1:	mov    %r9d,%r10d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:786
  468fd4:	mov    %r15d,%r9d
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468fd7:	shl    $0x4,%r9
  468fdb:	vmovdqa64 (%rsi,%r9,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:746
  468fe2:	vpbroadcastq (%rbx),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468fe8:	vpcmpequq %zmm9,%zmm8,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  468fef:	shl    $0x4,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:785
  468ff3:	add    $0x10,%rax
  468ff7:	and    %rdi,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  468ffa:	prefetcht0 (%rsi,%r10,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:788
  468fff:	kortestb %k0,%k0
  469003:	je     4695e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7e0>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469009:	vmovd  0xc(%rbx),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  46900e:	kshiftlb $0x1,%k0,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  469014:	vpcompressq %zmm8,%zmm12{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  46901a:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  46901f:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k3}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  469026:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:794
  46902c:	or     $0x4,%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:784
  46902f:	lea    (%r8,%rax,1),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  469033:	lea    0x180(%rax),%r9
  46903a:	and    %rdi,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:739
  46903d:	mov    0x8(%rbx),%r15d
  469041:	andn   0x8(%r8,%r9,1),%r14d,%r10d
  469048:	andn   %r15d,%r14d,%r9d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  46904d:	mov    %r10d,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:786
  469050:	mov    %r9d,%r10d
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469053:	shl    $0x4,%r10
  469057:	vmovdqa64 (%rsi,%r10,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:746
  46905e:	vpbroadcastq (%rbx),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469064:	vpcmpequq %zmm2,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  46906b:	shl    $0x4,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:785
  46906f:	add    $0x10,%rax
  469073:	and    %rdi,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  469076:	prefetcht0 (%rsi,%r11,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:788
  46907b:	kortestb %k0,%k0
  46907f:	je     469588 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x788>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469085:	vmovd  0xc(%rbx),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  46908a:	kshiftlb $0x1,%k0,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  469090:	vpcompressq %zmm0,%zmm6{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  469096:	vpunpcklqdq %xmm6,%xmm1,%xmm7
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  46909a:	vshufi32x4 $0x0,%zmm7,%zmm7,%zmm15{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:794
  4690a1:	or     $0x8,%ecx
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  4690a4:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:815
  4690aa:	cmp    $0xf,%ecx
  4690ad:	jne    469720 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x920>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  4690b3:	mov    (%rsp),%r15
  4690b7:	vmovdqu64 %zmm15,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:817
  4690bd:	add    $0x40,%r15
  4690c1:	mov    %r15,(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:827
  4690c5:	mov    (%rdx),%r10
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690c8:	mov    %r12,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:827
  4690cb:	mov    0x10(%rdx),%r11
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690cf:	crc32  %r10,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:827
  4690d5:	mov    %r10,-0x38(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:828
  4690da:	mov    -0x18(%rsp),%r10d
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690df:	mov    %r12,%rcx
  4690e2:	crc32  %r11,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:828
  4690e8:	mov    %r10d,%ebx
  4690eb:	mov    %r10d,%r9d
  4690ee:	and    %ecx,%ebx
  4690f0:	shl    $0x4,%rbx
  4690f4:	and    %r15d,%r9d
  4690f7:	shl    $0x4,%r9
  4690fb:	prefetcht2 (%rsi,%rbx,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:827
  4690ff:	mov    0x20(%rdx),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:828
  469103:	prefetcht2 (%rsi,%r9,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469108:	mov    %r12,%r9
  46910b:	crc32  %rbx,%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:827
  469111:	mov    %r11,-0x40(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:828
  469116:	mov    %r9d,%r11d
  469119:	and    %r10d,%r11d
  46911c:	shl    $0x4,%r11
  469120:	prefetcht2 (%rsi,%r11,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:827
  469125:	mov    0x30(%rdx),%r11
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469129:	vmovq  %r9,%xmm15
  46912e:	mov    %r12,%r9
  469131:	crc32  %r11,%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:828
  469137:	and    %r9d,%r10d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:827
  46913a:	mov    %r11,-0x48(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:828
  46913f:	mov    %r10,%r11
  469142:	shl    $0x4,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:833
  469146:	lea    0x40(%r13),%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:828
  46914a:	prefetcht2 (%rsi,%r11,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:833
  46914f:	cmp    %r10,-0x28(%rsp)
  469154:	jb     469690 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x890>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46915a:	vmovd  %r15d,%xmm3
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  46915f:	vmovdqu32 (%rdx),%zmm1
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469165:	vpinsrd $0x1,%r9d,%xmm15,%xmm2
  46916b:	vpinsrd $0x1,%ecx,%xmm3,%xmm5
  469171:	vpunpcklqdq %xmm2,%xmm5,%xmm6
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  469175:	mov    $0x4444,%r9d
  46917b:	kmovw  %r9d,%k6
  469180:	vpexpandd %zmm6,%zmm1{%k6}
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  469186:	vmovdqu64 %zmm1,(%r8,%r13,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:848
  46918d:	and    %rdi,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:776
  469190:	add    $0x40,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:848
  469194:	mov    %r10,%r13
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:776
  469197:	cmp    %rdx,-0x30(%rsp)
  46919c:	je     469250 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x450>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:784
  4691a2:	lea    (%r8,%rax,1),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  4691a6:	lea    0x180(%rax),%rcx
  4691ad:	and    %rdi,%rcx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:739
  4691b0:	mov    0x8(%rbx),%r10d
  4691b4:	andn   0x8(%r8,%rcx,1),%r14d,%r15d
  4691bb:	andn   %r10d,%r14d,%r11d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:786
  4691c0:	mov    %r11d,%ecx
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4691c3:	shl    $0x4,%rcx
  4691c7:	vmovdqa64 (%rsi,%rcx,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:746
  4691ce:	vpbroadcastq (%rbx),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4691d4:	vpcmpequq %zmm9,%zmm8,%k6{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  4691db:	mov    %r15d,%r9d
  4691de:	shl    $0x4,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:785
  4691e2:	add    $0x10,%rax
  4691e6:	and    %rdi,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:783
  4691e9:	prefetcht0 (%rsi,%r9,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:788
  4691ee:	kortestb %k6,%k6
  4691f2:	jne    468f10 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x110>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4691f8:	vpcmpequq %zmm4,%zmm8,%k7{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:797
  4691ff:	kortestb %k7,%k7
  469203:	jne    469a13 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xc13>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469209:	mov    %r12,%r15
  46920c:	crc32  %r10,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:807
  469212:	mov    -0x18(%rsp),%r9d
  469217:	vmovd  %r15d,%xmm10
  46921c:	vpinsrd $0x1,0xc(%rbx),%xmm10,%xmm11
  469223:	and    %r15d,%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:808
  469226:	mov    (%rbx),%rbx
  469229:	lea    (%r8,%r13,1),%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:807
  46922d:	shl    $0x4,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:809
  469231:	lea    0x10(%r13),%r13
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:807
  469235:	prefetcht2 (%rsi,%r9,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:809
  46923a:	and    %rdi,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  46923d:	mov    %rbx,(%r10)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1218
  469240:	vmovq  %xmm11,0x8(%r10)
  469246:	jmp    4691a2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3a2>
  46924b:	nopl   0x0(%rax,%rax,1)
  469250:	mov    -0x60(%rsp),%rcx
  469255:	mov    -0x68(%rsp),%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:853
  46925a:	mov    -0x4c(%rsp),%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:851
  46925e:	vmovq  %r13,%xmm7
  469263:	vpinsrq $0x1,%rax,%xmm7,%xmm12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:853
  469269:	mov    -0x58(%rsp),%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:851
  46926e:	vpsrlq $0x4,%xmm12,%xmm4
  469274:	vpmovqd %xmm4,%xmm15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:853
  46927a:	sar    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:851
  46927e:	vmovq  %xmm15,0xb0(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:853
  469286:	sub    %rdi,%rsi
  469289:	add    %esi,(%r15)
  46928c:	vpextrd $0x1,%xmm15,%eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:855
  469292:	cmp    -0x20(%rsp),%rdx
  469297:	je     469570 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x770>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1660
  46929d:	mov    0x88(%rcx),%rdi
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1201
  4692a4:	mov    0x80(%rcx),%rbx
  4692ab:	mov    0x60(%rcx),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1660
  4692af:	dec    %rdi
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1201
  4692b2:	mov    %rbx,-0x18(%rsp)
  4692b7:	mov    %r8,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1660
  4692bb:	mov    %rdi,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:618
  4692c0:	mov    0x78(%rcx),%r10d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  4692c4:	mov    0x2991d(%rip),%r11        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4692cb:	mov    0xa0(%rcx),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1409
  4692d2:	movzbl 0x29826(%rip),%r13d        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1411
  4692da:	mov    0x29827(%rip),%r12        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4692e1:	mov    $0x55,%r14d
  4692e7:	vpxor  %xmm8,%xmm8,%xmm8
  4692ec:	kmovb  %r14d,%k1
  4692f1:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:618
  4692f8:	lea    0x18(%rax),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  4692fb:	and    %r10d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1206
  4692fe:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  469302:	mov    %ebx,%r8d
  469305:	and    0x8(%r9,%rsi,1),%r8d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:622
  46930a:	mov    %eax,%esi
  46930c:	shl    $0x4,%rsi
  469310:	add    %r9,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  469313:	mov    %r8,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1393
  469316:	mov    (%rsi),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  469319:	shl    $0x4,%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:620
  46931d:	prefetcht0 (%r11,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1393
  469322:	cmp    0x90(%rcx),%r8
  469329:	jne    4693e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5e0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1409
  46932f:	test   %r13b,%r13b
  469332:	je     469352 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x552>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1410
  469334:	mov    (%r15),%r14d
  469337:	mov    0xc(%rsi),%esi
  46933a:	mov    %r14,%r8
  46933d:	shl    $0x4,%r14
  469341:	add    0x8(%r15),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1412
  469345:	inc    %r8d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1410
  469348:	mov    %esi,(%r14)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1411
  46934b:	mov    %r12,0x8(%r14)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1412
  46934f:	mov    %r8d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  469352:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469354:	and    %r10d,%eax
  469357:	mov    %eax,0xb4(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:626
  46935d:	test   %r12,%r12
  469360:	jne    4692f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4f8>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  469362:	cmpq   $0x4,(%rsp)
  469367:	je     4694d5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d5>
  46936d:	nopl   (%rax)
/opt/DRAMHiT/include/hasher.hpp:39
  469370:	cmpq   $0x8,(%rsp)
  469375:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x750>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  46937b:	vmovd  -0x10(%rsp),%xmm0
  469381:	mov    (%rdx),%rdi
  469384:	mov    0xb0(%rcx),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1660
  46938a:	mov    -0x28(%rsp),%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  46938f:	mov    %rsi,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1660
  469392:	and    -0x10(%rsp),%r8
  469397:	vpinsrd $0x1,0xc(%rdx),%xmm0,%xmm3
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1663
  46939e:	and    $0xfffffffffffffffc,%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  4693a2:	shl    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  4693a6:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  4693a8:	add    %r9,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1451
  4693ab:	shl    $0x4,%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1689
  4693af:	and    %r10d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:855
  4693b2:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1451
  4693b6:	prefetcht2 (%r11,%r8,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  4693bb:	mov    %rdi,(%rsi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1218
  4693be:	vmovq  %xmm3,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1689
  4693c3:	mov    %eax,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:855
  4693c9:	cmp    -0x20(%rsp),%rdx
  4693ce:	je     469570 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x770>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:618
  4693d4:	mov    0xb4(%rcx),%eax
  4693da:	jmp    4692f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4f8>
  4693df:	nop
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1206
  4693e0:	mov    0x8(%rsi),%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1256
  4693e4:	mov    %ebx,%edi
  4693e6:	and    %r14d,%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1258
  4693e9:	shl    $0x4,%rdi
  4693ed:	add    %r11,%rdi
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4693f0:	vmovdqa64 (%rdi),%zmm9
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  4693f6:	vpbroadcastq %r8,%zmm10
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4693fc:	vpcmpequq %zmm10,%zmm9,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1262
  469403:	kortestb %k0,%k0
  469407:	jne    469490 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x690>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46940d:	vpcmpequq %zmm8,%zmm9,%k2{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1270
  469414:	kortestb %k2,%k2
  469418:	jne    469500 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  46941e:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1272
  469423:	mov    %r14d,%edi
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  469426:	je     469510 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x710>
/opt/DRAMHiT/include/hasher.hpp:39
  46942c:	cmpq   $0x8,(%rsp)
  469431:	je     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x730>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  469437:	vmovd  -0x8(%rsp),%xmm11
  46943d:	mov    0xb0(%rcx),%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1274
  469443:	mov    -0x18(%rsp),%r14
  469448:	vpinsrd $0x1,0xc(%rsi),%xmm11,%xmm14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  46944f:	mov    %rdi,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1274
  469452:	and    -0x8(%rsp),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  469457:	shl    $0x4,%rdi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1281
  46945b:	inc    %esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  46945d:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  46945f:	add    %r9,%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1451
  469462:	shl    $0x4,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1282
  469466:	and    %r10d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469469:	and    %r10d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1451
  46946c:	prefetcht2 (%r11,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  469471:	mov    %r8,(%rdi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1218
  469474:	vmovq  %xmm14,0x8(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1282
  469479:	mov    %esi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  46947f:	mov    %eax,0xb4(%rcx)
  469485:	jmp    4692f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4f8>
  46948a:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1263
  469490:	mov    (%r15),%r8d
  469493:	mov    0xc(%rsi),%esi
  469496:	mov    %r8,%r14
  469499:	shl    $0x4,%r8
  46949d:	add    0x8(%r15),%r8
  4694a1:	mov    %esi,(%r8)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  4694a4:	kmovb  %k0,%esi
  4694a8:	tzcnt  %esi,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1264
  4694ac:	inc    %esi
  4694ae:	movslq %esi,%rsi
  4694b1:	mov    (%rdi,%rsi,8),%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  4694b5:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1265
  4694b7:	inc    %r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  4694ba:	and    %r10d,%eax
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4694bd:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1264
  4694c2:	mov    %rdi,0x8(%r8)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1265
  4694c6:	mov    %r14d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  4694c9:	mov    %eax,0xb4(%rcx)
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4694cf:	jne    469370 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x570>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4694d5:	mov    $0xffffffff,%r14d
  4694db:	crc32l (%rdx),%r14d
  4694e1:	vmovd  %r14d,%xmm2
  4694e6:	mov    (%rdx),%rdi
  4694e9:	vmovdqa %xmm2,%xmm0
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  4694ed:	vmovq  %xmm2,-0x10(%rsp)
  4694f3:	jmp    469384 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x584>
  4694f8:	nopl   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  469500:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469502:	and    %r10d,%eax
  469505:	mov    %eax,0xb4(%rcx)
  46950b:	jmp    469362 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x562>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469510:	mov    $0xffffffff,%edi
  469515:	crc32  %r14d,%edi
  46951b:	vmovd  %edi,%xmm13
  46951f:	vmovdqa %xmm13,%xmm11
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  469524:	vmovq  %xmm13,-0x8(%rsp)
  46952a:	jmp    46943d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x63d>
  46952f:	nop
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469530:	mov    $0xffffffff,%r14d
  469536:	crc32  %rdi,%r14
  46953c:	mov    %r14,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  469541:	vmovd  %r14d,%xmm11
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  469546:	jmp    46943d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x63d>
  46954b:	nopl   0x0(%rax,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469550:	mov    (%rdx),%rdi
  469553:	mov    $0xffffffff,%eax
  469558:	crc32  %rdi,%rax
  46955e:	mov    %rax,-0x10(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  469563:	vmovd  %eax,%xmm0
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  469567:	jmp    469384 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x584>
  46956c:	nopl   0x0(%rax)
  469570:	vzeroupper 
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:705
  469573:	lea    -0x28(%rbp),%rsp
  469577:	pop    %rbx
  469578:	pop    %r12
  46957a:	pop    %r13
  46957c:	pop    %r14
  46957e:	pop    %r15
  469580:	pop    %rbp
  469581:	ret    
  469582:	nopw   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469588:	vpcmpequq %zmm4,%zmm0,%k7{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:797
  46958f:	kortestb %k7,%k7
  469593:	jne    46971a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x91a>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469599:	mov    %r12,%r9
  46959c:	crc32  %r15,%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:807
  4695a2:	mov    -0x18(%rsp),%r11d
  4695a7:	vmovd  %r9d,%xmm3
  4695ac:	vpinsrd $0x1,0xc(%rbx),%xmm3,%xmm5
  4695b3:	and    %r9d,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:808
  4695b6:	mov    (%rbx),%rbx
  4695b9:	lea    (%r8,%r13,1),%r15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:807
  4695bd:	shl    $0x4,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:809
  4695c1:	add    $0x10,%r13
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:807
  4695c5:	prefetcht2 (%rsi,%r11,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:809
  4695ca:	and    %rdi,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  4695cd:	mov    %rbx,(%r15)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1218
  4695d0:	vmovq  %xmm5,0x8(%r15)
  4695d6:	jmp    46902f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x22f>
  4695db:	nopl   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4695e0:	vpcmpequq %zmm4,%zmm8,%k7{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:797
  4695e7:	kortestb %k7,%k7
  4695eb:	jne    469a28 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xc28>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4695f1:	mov    %r12,%r10
  4695f4:	crc32  %r11,%r10
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:807
  4695fa:	mov    -0x18(%rsp),%r11d
  4695ff:	vmovd  %r10d,%xmm10
  469604:	vpinsrd $0x1,0xc(%rbx),%xmm10,%xmm11
  46960b:	and    %r10d,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:808
  46960e:	mov    (%rbx),%rbx
  469611:	lea    (%r8,%r13,1),%r15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:807
  469615:	shl    $0x4,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:809
  469619:	add    $0x10,%r13
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:807
  46961d:	prefetcht2 (%rsi,%r11,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:809
  469622:	and    %rdi,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  469625:	mov    %rbx,(%r15)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1218
  469628:	vmovq  %xmm11,0x8(%r15)
  46962e:	jmp    468fb3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1b3>
  469633:	nopl   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469638:	vpcmpequq %zmm4,%zmm0,%k7{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:797
  46963f:	kortestb %k7,%k7
  469643:	jne    469a0a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xc0a>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469649:	mov    %r12,%r9
  46964c:	crc32  %r10,%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:807
  469652:	mov    -0x18(%rsp),%r10d
  469657:	vmovd  %r9d,%xmm3
  46965c:	vpinsrd $0x1,0xc(%rbx),%xmm3,%xmm5
  469663:	and    %r9d,%r10d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:808
  469666:	mov    (%rbx),%rbx
  469669:	lea    (%r8,%r13,1),%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:807
  46966d:	shl    $0x4,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:809
  469671:	add    $0x10,%r13
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:807
  469675:	prefetcht2 (%rsi,%r10,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:809
  46967a:	and    %rdi,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  46967d:	mov    %rbx,(%r11)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1218
  469680:	vmovq  %xmm5,0x8(%r11)
  469686:	jmp    468f38 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x138>
  46968b:	nopl   0x0(%rax,%rax,1)
  469690:	vmovd  %r15d,%xmm8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:846
  469695:	mov    %rdi,%r15
  469698:	vpinsrd $0x1,0xc(%rdx),%xmm8,%xmm9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  46969f:	mov    -0x38(%rsp),%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:846
  4696a4:	and    %r13,%r15
  4696a7:	add    %r8,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1218
  4696aa:	vmovq  %xmm9,0x8(%r15)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  4696b0:	mov    %r11,(%r15)
  4696b3:	vmovd  %ecx,%xmm10
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:846
  4696b7:	lea    0x10(%r13),%r15
  4696bb:	vpinsrd $0x1,0x1c(%rdx),%xmm10,%xmm11
  4696c2:	and    %rdi,%r15
  4696c5:	add    %r8,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1218
  4696c8:	vmovq  %xmm11,0x8(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:846
  4696ce:	lea    0x20(%r13),%r11
  4696d2:	vpinsrd $0x1,0x2c(%rdx),%xmm15,%xmm13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  4696d9:	mov    -0x40(%rsp),%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:846
  4696de:	and    %rdi,%r11
  4696e1:	add    %r8,%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  4696e4:	mov    %rcx,(%r15)
  4696e7:	vmovd  %r9d,%xmm14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1218
  4696ec:	vmovq  %xmm13,0x8(%r11)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:846
  4696f2:	lea    0x30(%r13),%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  4696f6:	mov    %rbx,(%r11)
  4696f9:	vpinsrd $0x1,0x3c(%rdx),%xmm14,%xmm0
  469700:	mov    -0x48(%rsp),%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:846
  469705:	and    %rdi,%r13
  469708:	add    %r8,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  46970b:	mov    %rbx,0x0(%r13)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1218
  46970f:	vmovq  %xmm0,0x8(%r13)
  469715:	jmp    46918d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x38d>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:798
  46971a:	incl   -0x4c(%rsp)
  46971e:	xchg   %ax,%ax
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  469720:	mov    (%rsp),%rbx
_Z9_pdep_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmi2intrin.h:48
  469724:	mov    $0x55,%r10d
  46972a:	pdep   %r10d,%ecx,%r9d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:820
  46972f:	popcnt %ecx,%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:819
  469733:	lea    (%r9,%r9,2),%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:820
  469737:	shl    $0x4,%rcx
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  46973b:	kmovb  %r11d,%k7
  469740:	vpcompressq %zmm12,(%rbx){%k7}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:820
  469746:	add    %rcx,%rbx
  469749:	mov    %rbx,(%rsp)
  46974d:	jmp    4690c5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2c5>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1071
  469752:	cmp    -0x20(%rsp),%rdx
  469757:	je     469573 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x773>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1660
  46975d:	mov    0x88(%rcx),%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1409
  469764:	movzbl 0x29394(%rip),%r13d        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1411
  46976c:	mov    0x29395(%rip),%r9        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469773:	mov    0x60(%rcx),%r8
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469777:	mov    $0x55,%ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1660
  46977c:	dec    %r12
  46977f:	kmovb  %r13d,%k2
  469784:	mov    %r8,(%rsp)
  469788:	mov    %r12,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  46978d:	mov    0x29454(%rip),%r14        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469794:	mov    0xa0(%rcx),%r11
  46979b:	mov    %r10d,%esi
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46979e:	vpxor  %xmm2,%xmm2,%xmm2
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1660
  4697a2:	mov    %r9,%r13
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4697a5:	kmovb  %ebx,%k1
  4697a9:	jmp    469813 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa13>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:39
  4697ab:	cmpq   $0x8,(%rsp)
  4697b0:	je     4699b8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbb8>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  4697b6:	vmovd  -0x18(%rsp),%xmm5
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1660
  4697bc:	mov    -0x8(%rsp),%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  4697c1:	mov    %r10d,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1660
  4697c4:	and    -0x18(%rsp),%r12
  4697c9:	vpinsrd $0x1,0xc(%rdx),%xmm5,%xmm7
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  4697d0:	mov    (%rdx),%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1663
  4697d3:	and    $0xfffffffffffffffc,%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  4697d7:	shl    $0x4,%rsi
  4697db:	add    %r11,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1451
  4697de:	shl    $0x4,%r12
  4697e2:	prefetcht2 (%r14,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  4697e7:	mov    %r9,(%rsi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1218
  4697ea:	vmovq  %xmm7,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  4697ef:	lea    0x1(%r10),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1689
  4697f3:	and    %edi,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1071
  4697f5:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1689
  4697f9:	mov    %esi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1071
  4697ff:	cmp    %rdx,-0x20(%rsp)
  469804:	je     469570 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x770>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17get_find_queue_szEv():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:525
  46980a:	mov    0xb4(%rcx),%eax
  469810:	mov    %esi,%r10d
  469813:	sub    %eax,%esi
  469815:	and    %edi,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1072
  469817:	cmp    %esi,%edi
  469819:	jbe    46983c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa3c>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  46981b:	cmpq   $0x4,(%rsp)
  469820:	jne    4697ab <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9ab>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469822:	mov    $0xffffffff,%ebx
  469827:	crc32l (%rdx),%ebx
  46982c:	vmovd  %ebx,%xmm6
  469830:	vmovdqa %xmm6,%xmm5
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  469834:	vmovq  %xmm6,-0x18(%rsp)
  46983a:	jmp    4697bc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9bc>
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1201
  46983c:	mov    0x80(%rcx),%rbx
  469843:	mov    %rbx,-0x10(%rsp)
  469848:	nopl   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:618
  469850:	lea    0x18(%rax),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  469853:	and    %edi,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1206
  469855:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  469859:	mov    %ebx,%r9d
  46985c:	and    0x8(%r11,%rsi,1),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:622
  469861:	mov    %eax,%esi
  469863:	shl    $0x4,%rsi
  469867:	add    %r11,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  46986a:	mov    %r9,%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1393
  46986d:	mov    (%rsi),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:619
  469870:	shl    $0x4,%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:620
  469874:	prefetcht0 (%r14,%r8,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1393
  469879:	cmp    0x90(%rcx),%r9
  469880:	jne    4698c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xac0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1409
  469882:	kortestb %k2,%k2
  469886:	je     4698a9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaa9>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1410
  469888:	mov    (%r15),%r12d
  46988b:	mov    0xc(%rsi),%esi
  46988e:	mov    %r12,%r9
  469891:	shl    $0x4,%r12
  469895:	add    0x8(%r15),%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1412
  469899:	lea    0x1(%r9),%r8d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1410
  46989d:	mov    %esi,(%r12)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1411
  4698a1:	mov    %r13,0x8(%r12)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1412
  4698a6:	mov    %r8d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  4698a9:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  4698ab:	and    %edi,%eax
  4698ad:	mov    %eax,0xb4(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:626
  4698b3:	test   %r13,%r13
  4698b6:	jne    469850 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa50>
  4698b8:	jmp    46981b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa1b>
  4698bd:	nopl   (%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1206
  4698c0:	mov    0x8(%rsi),%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1256
  4698c4:	mov    %ebx,%r8d
  4698c7:	and    %r12d,%r8d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1258
  4698ca:	shl    $0x4,%r8
  4698ce:	add    %r14,%r8
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4698d1:	vmovdqa64 (%r8),%zmm0
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  4698d7:	vpbroadcastq %r9,%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4698dd:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1262
  4698e4:	kortestb %k0,%k0
  4698e8:	jne    469966 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb66>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4698ea:	vpcmpequq %zmm2,%zmm0,%k3{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1270
  4698f1:	kortestb %k3,%k3
  4698f5:	jne    4699a9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xba9>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4698fb:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1272
  469900:	mov    %r12d,%r8d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  469903:	je     4699d1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbd1>
/opt/DRAMHiT/include/hasher.hpp:39
  469909:	cmpq   $0x8,(%rsp)
  46990e:	je     4699f1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbf1>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  469914:	mov    -0x28(%rsp),%r8d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1274
  469919:	mov    -0x10(%rsp),%r12
  46991e:	vmovd  %r8d,%xmm4
  469923:	vpinsrd $0x1,0xc(%rsi),%xmm4,%xmm3
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  46992a:	mov    %r10d,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1274
  46992d:	and    -0x28(%rsp),%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  469932:	shl    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1281
  469936:	inc    %r10d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  469939:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  46993b:	add    %r11,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1451
  46993e:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1282
  469942:	and    %edi,%r10d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469945:	and    %edi,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1451
  469947:	prefetcht2 (%r14,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1217
  46994c:	mov    %r9,(%rsi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1218
  46994f:	vmovq  %xmm3,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1282
  469954:	mov    %r10d,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  46995b:	mov    %eax,0xb4(%rcx)
  469961:	jmp    469850 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa50>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1263
  469966:	mov    (%r15),%r9d
  469969:	mov    0xc(%rsi),%r12d
  46996d:	mov    %r9,%rbx
  469970:	shl    $0x4,%r9
  469974:	add    0x8(%r15),%r9
  469978:	mov    %r12d,(%r9)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  46997b:	xor    %r12d,%r12d
  46997e:	kmovb  %k0,%esi
  469982:	tzcnt  %esi,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1264
  469987:	inc    %r12d
  46998a:	movslq %r12d,%rsi
  46998d:	mov    (%r8,%rsi,8),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  469991:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1265
  469993:	inc    %ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  469995:	and    %edi,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1264
  469997:	mov    %r8,0x8(%r9)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1265
  46999b:	mov    %ebx,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  46999e:	mov    %eax,0xb4(%rcx)
  4699a4:	jmp    46981b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa1b>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:623
  4699a9:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:624
  4699ab:	and    %edi,%eax
  4699ad:	mov    %eax,0xb4(%rcx)
  4699b3:	jmp    46981b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa1b>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4699b8:	mov    $0xffffffff,%eax
  4699bd:	crc32q (%rdx),%rax
  4699c3:	mov    %rax,-0x18(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  4699c8:	vmovd  %eax,%xmm5
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  4699cc:	jmp    4697bc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9bc>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4699d1:	mov    $0xffffffff,%r8d
  4699d7:	crc32  %r12d,%r8d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  4699dd:	mov    %r8d,%r12d
  4699e0:	mov    %r12,-0x28(%rsp)
  4699e5:	jmp    469919 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb19>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:776
  4699ea:	xor    %edi,%edi
  4699ec:	jmp    46925e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x45e>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4699f1:	mov    $0xffffffff,%r12d
  4699f7:	crc32  %r8,%r12
  4699fd:	mov    %r12,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  469a02:	mov    %r12d,%r8d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1280
  469a05:	jmp    469919 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb19>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:798
  469a0a:	incl   -0x4c(%rsp)
  469a0e:	jmp    468fb3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1b3>
  469a13:	incl   -0x4c(%rsp)
  469a17:	vpxor  %xmm15,%xmm15,%xmm15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:779
  469a1c:	xor    %ecx,%ecx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:778
  469a1e:	vpxor  %xmm12,%xmm12,%xmm12
  469a23:	jmp    468f38 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x138>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:798
  469a28:	incl   -0x4c(%rsp)
  469a2c:	jmp    46902f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x22f>
