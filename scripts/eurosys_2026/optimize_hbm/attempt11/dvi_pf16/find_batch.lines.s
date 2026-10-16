
/opt/DRAMHiT/scripts/eurosys_2026/optimize_hbm/attempt11/dvi_pf16/dramhit:     file format elf64-x86-64


Disassembly of section .text:

0000000000468a90 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:949
  468a90:	push   %rbp
  468a91:	mov    %rdi,%rcx
  468a94:	mov    %rsp,%rbp
  468a97:	push   %r15
  468a99:	mov    %rdx,%r15
  468a9c:	push   %r14
  468a9e:	push   %r13
  468aa0:	push   %r12
  468aa2:	push   %rbx
  468aa3:	and    $0xffffffffffffffc0,%rsp
  468aa7:	sub    $0x8,%rsp
  468aab:	mov    0x8(%rsi),%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:963
  468aaf:	mov    0xc0(%rdi),%edi
  468ab5:	mov    0xc4(%rcx),%eax
  468abb:	mov    (%rsi),%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:964
  468abe:	mov    0x78(%rcx),%r8d
  468ac2:	mov    0x6c(%rcx),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1119
  468ac6:	mov    %r11,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:963
  468ac9:	mov    %edi,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1119
  468acb:	shl    $0x4,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:963
  468acf:	sub    %eax,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1119
  468ad1:	lea    (%rdx,%r10,1),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:963
  468ad5:	and    %r8d,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:964
  468ad8:	lea    -0x1(%r9),%r12d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1119
  468adc:	mov    %rbx,-0x20(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:966
  468ae1:	cmp    %r12d,%esi
  468ae4:	jb     46934c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8bc>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1025
  468aea:	and    $0xfffffffffffffffc,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:973
  468aee:	shl    $0x4,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1025
  468af2:	shl    $0x4,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:978
  468af6:	mov    0x8(%r15),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:982
  468afa:	mov    0x80(%rcx),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:973
  468b00:	mov    %r9,-0x18(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1025
  468b05:	mov    %r11,-0x38(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:973
  468b0a:	lea    -0x1(%r9),%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1025
  468b0e:	lea    (%rdx,%r11,1),%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:975
  468b12:	mov    %edi,%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:978
  468b15:	mov    %r14,(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1025
  468b19:	mov    %r11,-0x28(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:977
  468b1e:	movl   $0x0,-0x2c(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:972
  468b26:	mov    0xa0(%rcx),%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:991
  468b2d:	mov    0x2b0bc(%rip),%rdi        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:974
  468b34:	shl    $0x4,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:975
  468b38:	shl    $0x4,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:982
  468b3c:	not    %esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1026
  468b3e:	cmp    %r11,%rdx
  468b41:	je     4695ea <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb5a>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468b47:	mov    $0x55,%r13d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468b4d:	mov    $0xf,%ebx
  468b52:	mov    $0xf0,%r12d
  468b58:	mov    $0xf00,%r11d
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468b5e:	kmovb  %r13d,%k2
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468b63:	mov    $0xfffff000,%r13d
  468b69:	mov    %rcx,-0x40(%rsp)
  468b6e:	mov    %r15,-0x48(%rsp)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468b73:	vpxor  %xmm4,%xmm4,%xmm4
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468b77:	mov    $0xffffffff,%r14d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468b7d:	kmovw  %ebx,%k6
  468b81:	kmovw  %r12d,%k5
  468b86:	kmovw  %r11d,%k4
  468b8b:	kmovw  %r13d,%k3
  468b90:	jmp    468de9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  468b95:	nopl   (%rax)
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468b98:	vmovd  0xc(%r12),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468b9f:	kshiftlb $0x1,%k7,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468ba5:	vpcompressq %zmm8,%zmm12{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468bab:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468bb0:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k6}{z}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468bb7:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1045
  468bbd:	mov    $0x1,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1034
  468bc3:	lea    (%r8,%rax,1),%r13
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468bc7:	lea    0x180(%rax),%r12
  468bce:	and    %r10,%r12
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:993
  468bd1:	mov    0x8(%r13),%r15d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:988
  468bd5:	andn   0x8(%r8,%r12,1),%esi,%ecx
  468bdc:	shl    $0x4,%rcx
  468be0:	andn   %r15d,%esi,%r12d
  468be5:	shl    $0x4,%r12
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468be9:	vmovdqa64 (%rdi,%r12,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:998
  468bf0:	vpbroadcastq 0x0(%r13),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468bf7:	vpcmpequq %zmm2,%zmm0,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1035
  468bfe:	add    $0x10,%rax
  468c02:	and    %r10,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468c05:	prefetcht0 (%rdi,%rcx,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1039
  468c09:	kortestb %k0,%k0
  468c0d:	je     469260 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468c13:	vmovd  0xc(%r13),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468c19:	kshiftlb $0x1,%k0,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468c1f:	vpcompressq %zmm0,%zmm6{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468c25:	vpunpcklqdq %xmm6,%xmm1,%xmm7
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468c29:	vshufi32x4 $0x0,%zmm7,%zmm7,%zmm15{%k5}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468c30:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1045
  468c36:	or     $0x2,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468c3a:	lea    0x180(%rax),%r13
  468c41:	and    %r10,%r13
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:988
  468c44:	andn   0x8(%r8,%r13,1),%esi,%ecx
  468c4b:	shl    $0x4,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1034
  468c4f:	lea    (%r8,%rax,1),%r13
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:993
  468c53:	mov    0x8(%r13),%ebx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:988
  468c57:	andn   %ebx,%esi,%r12d
  468c5c:	shl    $0x4,%r12
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468c60:	vmovdqa64 (%rdi,%r12,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:998
  468c67:	vpbroadcastq 0x0(%r13),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468c6e:	vpcmpequq %zmm9,%zmm8,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1035
  468c75:	add    $0x10,%rax
  468c79:	and    %r10,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468c7c:	prefetcht0 (%rdi,%rcx,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1039
  468c80:	kortestb %k0,%k0
  468c84:	je     469210 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x780>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468c8a:	vmovd  0xc(%r13),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468c90:	kshiftlb $0x1,%k0,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468c96:	vpcompressq %zmm8,%zmm12{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468c9c:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468ca1:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k4}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468ca8:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1045
  468cae:	or     $0x4,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1034
  468cb2:	lea    (%r8,%rax,1),%r15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468cb6:	lea    0x180(%rax),%r13
  468cbd:	and    %r10,%r13
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:993
  468cc0:	mov    0x8(%r15),%r12d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:988
  468cc4:	andn   0x8(%r8,%r13,1),%esi,%ecx
  468ccb:	shl    $0x4,%rcx
  468ccf:	andn   %r12d,%esi,%r13d
  468cd4:	shl    $0x4,%r13
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468cd8:	vmovdqa64 (%rdi,%r13,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:998
  468cdf:	vpbroadcastq (%r15),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468ce5:	vpcmpequq %zmm2,%zmm0,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1035
  468cec:	add    $0x10,%rax
  468cf0:	and    %r10,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468cf3:	prefetcht0 (%rdi,%rcx,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1039
  468cf7:	kortestb %k0,%k0
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1098
  468cfb:	lea    (%r8,%r9,1),%rcx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1039
  468cff:	je     4691c8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468d05:	vmovd  0xc(%r15),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468d0b:	kshiftlb $0x1,%k0,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468d11:	vpcompressq %zmm0,%zmm6{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468d17:	vpunpcklqdq %xmm6,%xmm1,%xmm7
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468d1b:	vshufi32x4 $0x0,%zmm7,%zmm7,%zmm15{%k3}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1045
  468d22:	or     $0x8,%r11d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468d26:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1069
  468d2c:	cmp    $0xf,%r11d
  468d30:	jne    469318 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x888>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  468d36:	mov    (%rsp),%r15
  468d3a:	vmovdqu64 %zmm15,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1071
  468d40:	add    $0x40,%r15
  468d44:	mov    %r15,(%rsp)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468d48:	mov    %r14,%rbx
  468d4b:	mov    %r14,%r11
  468d4e:	crc32q (%rdx),%rbx
  468d54:	crc32q 0x20(%rdx),%r11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:988
  468d5b:	andn   %ebx,%esi,%r13d
  468d60:	shl    $0x4,%r13
  468d64:	andn   %r11d,%esi,%r15d
  468d69:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1082
  468d6d:	prefetcht2 (%rdi,%r13,1)
  468d72:	prefetcht2 (%rdi,%r15,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468d77:	mov    %r14,%r13
  468d7a:	mov    %r14,%r15
  468d7d:	crc32q 0x10(%rdx),%r13
  468d84:	crc32q 0x30(%rdx),%r15
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:988
  468d8b:	andn   %r13d,%esi,%r12d
  468d90:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1082
  468d94:	prefetcht2 (%rdi,%r12,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:988
  468d99:	andn   %r15d,%esi,%r12d
  468d9e:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1082
  468da2:	prefetcht2 (%rdi,%r12,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1094
  468da7:	lea    0x40(%r9),%r12
_Z18_mm512_loadu_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6414
  468dab:	vmovdqu64 (%rdx),%zmm15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1094
  468db1:	cmp    %r12,-0x18(%rsp)
  468db6:	jb     4692a8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x818>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  468dbc:	vmovdqu64 %zmm15,(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1100
  468dc2:	mov    %ebx,0x8(%rcx)
  468dc5:	mov    %r13d,0x18(%r8,%r9,1)
  468dca:	mov    %r11d,0x28(%r8,%r9,1)
  468dcf:	mov    %r15d,0x38(%r8,%r9,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1112
  468dd4:	mov    %r12,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1026
  468dd7:	add    $0x40,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1112
  468ddb:	and    %r10,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1026
  468dde:	cmp    %rdx,-0x28(%rsp)
  468de3:	je     468e88 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3f8>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1034
  468de9:	lea    (%r8,%rax,1),%r12
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:993
  468ded:	mov    0x8(%r12),%r11d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:988
  468df2:	andn   %r11d,%esi,%r13d
  468df7:	shl    $0x4,%r13
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468dfb:	vmovdqa64 (%rdi,%r13,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:998
  468e02:	vpbroadcastq (%r12),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468e09:	vpcmpequq %zmm9,%zmm8,%k7{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468e10:	lea    0x180(%rax),%rcx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1035
  468e17:	add    $0x10,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468e1b:	and    %r10,%rcx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1035
  468e1e:	and    %r10,%rax
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:988
  468e21:	andn   0x8(%r8,%rcx,1),%esi,%r15d
  468e28:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1039
  468e2c:	kortestb %k7,%k7
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468e30:	prefetcht0 (%rdi,%r15,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1039
  468e35:	jne    468b98 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468e3b:	vpcmpequq %zmm4,%zmm8,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1048
  468e42:	kortestb %k1,%k1
  468e46:	jne    469613 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb83>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  468e4c:	vmovdqu (%r12),%xmm10
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468e52:	mov    %r14,%rcx
  468e55:	crc32  %r11,%rcx
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  468e5b:	vpinsrd $0x2,%ecx,%xmm10,%xmm11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:988
  468e61:	andn   %ecx,%esi,%r15d
  468e66:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1058
  468e6a:	prefetcht2 (%rdi,%r15,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  468e6f:	vmovdqu %xmm11,(%r8,%r9,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1063
  468e75:	add    $0x10,%r9
  468e79:	and    %r10,%r9
  468e7c:	jmp    468de9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x359>
  468e81:	nopl   0x0(%rax)
  468e88:	mov    -0x40(%rsp),%rcx
  468e8d:	mov    -0x48(%rsp),%r15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1117
  468e92:	mov    -0x2c(%rsp),%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1115
  468e96:	vmovq  %r9,%xmm14
  468e9b:	vpinsrq $0x1,%rax,%xmm14,%xmm0
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1117
  468ea1:	mov    -0x38(%rsp),%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1115
  468ea6:	vpsrlq $0x4,%xmm0,%xmm2
  468eab:	vpmovqd %xmm2,%xmm3
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1117
  468eb1:	sar    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1115
  468eb5:	vmovq  %xmm3,0xc0(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1117
  468ebd:	sub    %rdi,%rsi
  468ec0:	add    %esi,(%r15)
  468ec3:	vpextrd $0x1,%xmm3,%eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1119
  468ec9:	cmp    -0x20(%rsp),%rdx
  468ece:	je     4691b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1937
  468ed4:	mov    0x88(%rcx),%rdi
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1478
  468edb:	mov    0x80(%rcx),%rbx
  468ee2:	mov    0x60(%rcx),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1937
  468ee6:	dec    %rdi
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1478
  468ee9:	mov    %rbx,-0x18(%rsp)
  468eee:	mov    %r8,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1937
  468ef2:	mov    %rdi,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:864
  468ef7:	mov    0x78(%rcx),%r10d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:865
  468efb:	mov    0x2acee(%rip),%r11        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  468f02:	mov    0xa0(%rcx),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1686
  468f09:	movzbl 0x2abef(%rip),%r13d        # 493b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  468f11:	mov    0x2abf0(%rip),%r12        # 493b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468f18:	mov    $0x55,%r14d
  468f1e:	vpxor  %xmm7,%xmm7,%xmm7
  468f22:	kmovb  %r14d,%k2
  468f27:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:864
  468f30:	lea    0x18(%rax),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:865
  468f33:	and    %r10d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1483
  468f36:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:865
  468f3a:	mov    %ebx,%r8d
  468f3d:	and    0x8(%r9,%rsi,1),%r8d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:868
  468f42:	mov    %eax,%esi
  468f44:	shl    $0x4,%rsi
  468f48:	add    %r9,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:865
  468f4b:	mov    %r8,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  468f4e:	mov    (%rsi),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:865
  468f51:	shl    $0x4,%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:866
  468f55:	prefetcht0 (%r11,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  468f5a:	cmp    0x90(%rcx),%r8
  468f61:	jne    469020 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x590>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1686
  468f67:	test   %r13b,%r13b
  468f6a:	je     468f8a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fa>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1687
  468f6c:	mov    (%r15),%r14d
  468f6f:	mov    0xc(%rsi),%esi
  468f72:	mov    %r14,%r8
  468f75:	shl    $0x4,%r14
  468f79:	add    0x8(%r15),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1689
  468f7d:	inc    %r8d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1687
  468f80:	mov    %esi,(%r14)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  468f83:	mov    %r12,0x8(%r14)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1689
  468f87:	mov    %r8d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:869
  468f8a:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:870
  468f8c:	and    %r10d,%eax
  468f8f:	mov    %eax,0xc4(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:872
  468f95:	test   %r12,%r12
  468f98:	jne    468f30 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  468f9a:	cmpq   $0x4,(%rsp)
  468f9f:	je     469115 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x685>
  468fa5:	nopl   (%rax)
/opt/DRAMHiT/include/hasher.hpp:39
  468fa8:	cmpq   $0x8,(%rsp)
  468fad:	je     469190 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1947
  468fb3:	vmovd  -0x10(%rsp),%xmm15
  468fb9:	mov    (%rdx),%rdi
  468fbc:	mov    0xc0(%rcx),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1937
  468fc2:	mov    -0x28(%rsp),%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1947
  468fc7:	mov    %rsi,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1937
  468fca:	and    -0x10(%rsp),%r8
  468fcf:	vpinsrd $0x1,0xc(%rdx),%xmm15,%xmm9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1940
  468fd6:	and    $0xfffffffffffffffc,%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1947
  468fda:	shl    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1965
  468fde:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1947
  468fe0:	add    %r9,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1728
  468fe3:	shl    $0x4,%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1966
  468fe7:	and    %r10d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1119
  468fea:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1728
  468fee:	prefetcht2 (%r11,%r8,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1494
  468ff3:	mov    %rdi,(%rsi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1495
  468ff6:	vmovq  %xmm9,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1966
  468ffb:	mov    %eax,0xc0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1119
  469001:	cmp    -0x20(%rsp),%rdx
  469006:	je     4691b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:864
  46900c:	mov    0xc4(%rcx),%eax
  469012:	jmp    468f30 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  469017:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1483
  469020:	mov    0x8(%rsi),%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1533
  469024:	mov    %ebx,%edi
  469026:	and    %r14d,%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1535
  469029:	shl    $0x4,%rdi
  46902d:	add    %r11,%rdi
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469030:	vmovdqa64 (%rdi),%zmm5
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  469036:	vpbroadcastq %r8,%zmm6
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46903c:	vpcmpequq %zmm6,%zmm5,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1539
  469043:	kortestb %k0,%k0
  469047:	jne    4690d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x640>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46904d:	vpcmpequq %zmm7,%zmm5,%k3{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1547
  469054:	kortestb %k3,%k3
  469058:	jne    469140 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  46905e:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1549
  469063:	mov    %r14d,%edi
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  469066:	je     469150 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
/opt/DRAMHiT/include/hasher.hpp:39
  46906c:	cmpq   $0x8,(%rsp)
  469071:	je     469170 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1557
  469077:	vmovd  -0x8(%rsp),%xmm1
  46907d:	mov    0xc0(%rcx),%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1551
  469083:	mov    -0x18(%rsp),%r14
  469088:	vpinsrd $0x1,0xc(%rsi),%xmm1,%xmm4
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1557
  46908f:	mov    %rdi,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1551
  469092:	and    -0x8(%rsp),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1557
  469097:	shl    $0x4,%rdi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1558
  46909b:	inc    %esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:869
  46909d:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1557
  46909f:	add    %r9,%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1728
  4690a2:	shl    $0x4,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1559
  4690a6:	and    %r10d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:870
  4690a9:	and    %r10d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1728
  4690ac:	prefetcht2 (%r11,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1494
  4690b1:	mov    %r8,(%rdi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1495
  4690b4:	vmovq  %xmm4,0x8(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1559
  4690b9:	mov    %esi,0xc0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:870
  4690bf:	mov    %eax,0xc4(%rcx)
  4690c5:	jmp    468f30 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  4690ca:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1540
  4690d0:	mov    (%r15),%r8d
  4690d3:	mov    0xc(%rsi),%esi
  4690d6:	mov    %r8,%r14
  4690d9:	shl    $0x4,%r8
  4690dd:	add    0x8(%r15),%r8
  4690e1:	mov    %esi,(%r8)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  4690e4:	kmovb  %k0,%esi
  4690e8:	tzcnt  %esi,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1541
  4690ec:	inc    %esi
  4690ee:	movslq %esi,%rsi
  4690f1:	mov    (%rdi,%rsi,8),%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:869
  4690f5:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1542
  4690f7:	inc    %r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:870
  4690fa:	and    %r10d,%eax
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4690fd:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1541
  469102:	mov    %rdi,0x8(%r8)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1542
  469106:	mov    %r14d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:870
  469109:	mov    %eax,0xc4(%rcx)
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  46910f:	jne    468fa8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x518>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469115:	mov    $0xffffffff,%r14d
  46911b:	crc32l (%rdx),%r14d
  469121:	vmovd  %r14d,%xmm8
  469126:	mov    (%rdx),%rdi
  469129:	vmovdqa %xmm8,%xmm15
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  46912e:	vmovq  %xmm8,-0x10(%rsp)
  469134:	jmp    468fbc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  469139:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:869
  469140:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:870
  469142:	and    %r10d,%eax
  469145:	mov    %eax,0xc4(%rcx)
  46914b:	jmp    468f9a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469150:	mov    $0xffffffff,%edi
  469155:	crc32  %r14d,%edi
  46915b:	vmovd  %edi,%xmm12
  46915f:	vmovdqa %xmm12,%xmm1
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  469163:	vmovq  %xmm12,-0x8(%rsp)
  469169:	jmp    46907d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  46916e:	xchg   %ax,%ax
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469170:	mov    $0xffffffff,%r14d
  469176:	crc32  %rdi,%r14
  46917c:	mov    %r14,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1557
  469181:	vmovd  %r14d,%xmm1
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1557
  469186:	jmp    46907d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  46918b:	nopl   0x0(%rax,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469190:	mov    (%rdx),%rdi
  469193:	mov    $0xffffffff,%eax
  469198:	crc32  %rdi,%rax
  46919e:	mov    %rax,-0x10(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1947
  4691a3:	vmovd  %eax,%xmm15
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1947
  4691a7:	jmp    468fbc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  4691ac:	nopl   0x0(%rax)
  4691b0:	vzeroupper 
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:951
  4691b3:	lea    -0x28(%rbp),%rsp
  4691b7:	pop    %rbx
  4691b8:	pop    %r12
  4691ba:	pop    %r13
  4691bc:	pop    %r14
  4691be:	pop    %r15
  4691c0:	pop    %rbp
  4691c1:	ret    
  4691c2:	nopw   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4691c8:	vpcmpequq %zmm4,%zmm0,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1048
  4691cf:	kortestb %k1,%k1
  4691d3:	jne    469310 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x880>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  4691d9:	vmovdqu (%r15),%xmm3
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4691de:	mov    %r14,%rbx
  4691e1:	crc32  %r12,%rbx
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  4691e7:	vpinsrd $0x2,%ebx,%xmm3,%xmm5
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1063
  4691ed:	add    $0x10,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:988
  4691f1:	andn   %ebx,%esi,%r12d
  4691f6:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1063
  4691fa:	and    %r10,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1058
  4691fd:	prefetcht2 (%rdi,%r12,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469202:	vmovdqu %xmm5,(%rcx)
  469206:	jmp    468cb2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
  46920b:	nopl   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469210:	vpcmpequq %zmm4,%zmm8,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1048
  469217:	kortestb %k1,%k1
  46921b:	jne    469629 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb99>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  469221:	vmovdqu 0x0(%r13),%xmm10
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469227:	mov    %r14,%rcx
  46922a:	crc32  %rbx,%rcx
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  469230:	vpinsrd $0x2,%ecx,%xmm10,%xmm11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:988
  469236:	andn   %ecx,%esi,%r15d
  46923b:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1058
  46923f:	prefetcht2 (%rdi,%r15,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469244:	vmovdqu %xmm11,(%r8,%r9,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1063
  46924a:	add    $0x10,%r9
  46924e:	and    %r10,%r9
  469251:	jmp    468c3a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469256:	cs nopw 0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469260:	vpcmpequq %zmm4,%zmm0,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1048
  469267:	kortestb %k1,%k1
  46926b:	jne    46960a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb7a>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  469271:	vmovdqu 0x0(%r13),%xmm3
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469277:	mov    %r14,%rcx
  46927a:	crc32  %r15,%rcx
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  469280:	vpinsrd $0x2,%ecx,%xmm3,%xmm5
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:988
  469286:	andn   %ecx,%esi,%ebx
  46928b:	shl    $0x4,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1058
  46928f:	prefetcht2 (%rdi,%rbx,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469293:	vmovdqu %xmm5,(%r8,%r9,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1063
  469299:	add    $0x10,%r9
  46929d:	and    %r10,%r9
  4692a0:	jmp    468bc3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  4692a5:	nopl   (%rax)
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  4692a8:	vmovd  %ebx,%xmm10
  4692ac:	vpinsrd $0x1,%r13d,%xmm10,%xmm11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1107
  4692b2:	mov    -0x18(%rsp),%r13
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  4692b7:	vmovd  %r11d,%xmm8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1107
  4692bc:	mov    %r13,%r11
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  4692bf:	vpinsrd $0x1,%r15d,%xmm8,%xmm9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1107
  4692c5:	sub    %r9,%r11
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  4692c8:	mov    $0x4444,%ebx
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  4692cd:	vpunpcklqdq %xmm9,%xmm11,%xmm13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1108
  4692d2:	shr    $0x2,%r11
  4692d6:	mov    $0x1,%r15d
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  4692dc:	kmovw  %ebx,%k7
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1108
  4692e0:	shlx   %r11d,%r15d,%r11d
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  4692e5:	vpexpandd %zmm13,%zmm15{%k7}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1108
  4692eb:	lea    -0x1(%r11),%ebx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1110
  4692ef:	sub    %r13,%r9
  4692f2:	neg    %r11d
_Z24_mm512_mask_storeu_epi32PvtDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6461
  4692f5:	kmovw  %ebx,%k1
  4692f9:	vmovdqu32 %zmm15,(%rcx){%k1}
  4692ff:	kmovw  %r11d,%k7
  469304:	vmovdqu32 %zmm15,(%r8,%r9,1){%k7}
  46930b:	jmp    468dd4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x344>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1049
  469310:	incl   -0x2c(%rsp)
  469314:	nopl   0x0(%rax)
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  469318:	mov    (%rsp),%r12
_Z9_pdep_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmi2intrin.h:48
  46931c:	mov    $0x55,%r15d
  469322:	pdep   %r15d,%r11d,%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1074
  469327:	popcnt %r11d,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1073
  46932c:	lea    0x0(%r13,%r13,2),%ebx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1074
  469331:	shl    $0x4,%r11
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  469335:	kmovb  %ebx,%k1
  469339:	vpcompressq %zmm12,(%r12){%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1074
  469340:	add    %r11,%r12
  469343:	mov    %r12,(%rsp)
  469347:	jmp    468d48 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b8>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1335
  46934c:	cmp    -0x20(%rsp),%rdx
  469351:	je     4691b3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x723>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1937
  469357:	mov    0x88(%rcx),%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1686
  46935e:	movzbl 0x2a79a(%rip),%r13d        # 493b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  469366:	mov    0x2a79b(%rip),%r9        # 493b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46936d:	mov    0x60(%rcx),%r10
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469371:	mov    $0x55,%ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1937
  469376:	dec    %r12
  469379:	kmovb  %r13d,%k2
  46937e:	mov    %r10,(%rsp)
  469382:	mov    %r12,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:865
  469387:	mov    0x2a862(%rip),%r14        # 493bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  46938e:	mov    0xa0(%rcx),%r11
  469395:	mov    %edi,%esi
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469397:	vpxor  %xmm2,%xmm2,%xmm2
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1937
  46939b:	mov    %r9,%r13
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46939e:	kmovb  %ebx,%k1
  4693a2:	jmp    46940a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x97a>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:39
  4693a4:	cmpq   $0x8,(%rsp)
  4693a9:	je     4695b8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb28>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1947
  4693af:	vmovd  -0x18(%rsp),%xmm5
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1937
  4693b5:	mov    -0x8(%rsp),%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1947
  4693ba:	mov    %edi,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1937
  4693bc:	and    -0x18(%rsp),%r12
  4693c1:	vpinsrd $0x1,0xc(%rdx),%xmm5,%xmm7
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1947
  4693c8:	mov    (%rdx),%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1940
  4693cb:	and    $0xfffffffffffffffc,%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1947
  4693cf:	shl    $0x4,%rsi
  4693d3:	add    %r11,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1728
  4693d6:	shl    $0x4,%r12
  4693da:	prefetcht2 (%r14,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1494
  4693df:	mov    %r10,(%rsi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1495
  4693e2:	vmovq  %xmm7,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1965
  4693e7:	lea    0x1(%rdi),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1966
  4693ea:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1335
  4693ed:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1966
  4693f1:	mov    %esi,0xc0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1335
  4693f7:	cmp    %rdx,-0x20(%rsp)
  4693fc:	je     4691b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17get_find_queue_szEv():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:771
  469402:	mov    0xc4(%rcx),%eax
  469408:	mov    %esi,%edi
  46940a:	sub    %eax,%esi
  46940c:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1336
  46940f:	cmp    %esi,%r8d
  469412:	jbe    469435 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a5>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  469414:	cmpq   $0x4,(%rsp)
  469419:	jne    4693a4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x914>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  46941b:	mov    $0xffffffff,%ebx
  469420:	crc32l (%rdx),%ebx
  469425:	vmovd  %ebx,%xmm6
  469429:	vmovdqa %xmm6,%xmm5
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  46942d:	vmovq  %xmm6,-0x18(%rsp)
  469433:	jmp    4693b5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1478
  469435:	mov    0x80(%rcx),%rbx
  46943c:	mov    %rbx,-0x10(%rsp)
  469441:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:864
  469448:	lea    0x18(%rax),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:865
  46944b:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1483
  46944e:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:865
  469452:	mov    %ebx,%r9d
  469455:	and    0x8(%r11,%rsi,1),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:868
  46945a:	mov    %eax,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:865
  46945c:	mov    %r9,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:868
  46945f:	shl    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:865
  469463:	shl    $0x4,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:868
  469467:	add    %r11,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:866
  46946a:	prefetcht0 (%r14,%r10,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1670
  46946f:	mov    (%rsi),%r10
  469472:	cmp    0x90(%rcx),%r10
  469479:	jne    4694c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa30>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1686
  46947b:	kortestb %k2,%k2
  46947f:	je     4694a2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa12>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1687
  469481:	mov    (%r15),%r12d
  469484:	mov    0xc(%rsi),%esi
  469487:	mov    %r12,%r10
  46948a:	shl    $0x4,%r12
  46948e:	add    0x8(%r15),%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1689
  469492:	lea    0x1(%r10),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1687
  469496:	mov    %esi,(%r12)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1688
  46949a:	mov    %r13,0x8(%r12)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1689
  46949f:	mov    %r9d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:869
  4694a2:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:870
  4694a4:	and    %r8d,%eax
  4694a7:	mov    %eax,0xc4(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:872
  4694ad:	test   %r13,%r13
  4694b0:	jne    469448 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
  4694b2:	jmp    469414 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
  4694b7:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1483
  4694c0:	mov    0x8(%rsi),%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1533
  4694c4:	mov    %ebx,%r9d
  4694c7:	and    %r12d,%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1535
  4694ca:	shl    $0x4,%r9
  4694ce:	add    %r14,%r9
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4694d1:	vmovdqa64 (%r9),%zmm0
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  4694d7:	vpbroadcastq %r10,%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4694dd:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1539
  4694e4:	kortestb %k0,%k0
  4694e8:	jne    469564 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad4>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4694ea:	vpcmpequq %zmm2,%zmm0,%k3{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1547
  4694f1:	kortestb %k3,%k3
  4694f5:	jne    4695a8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb18>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4694fb:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1549
  469500:	mov    %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  469503:	je     4695d1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb41>
/opt/DRAMHiT/include/hasher.hpp:39
  469509:	cmpq   $0x8,(%rsp)
  46950e:	je     4695f1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb61>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1557
  469514:	mov    -0x28(%rsp),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1551
  469519:	mov    -0x10(%rsp),%r12
  46951e:	vmovd  %r9d,%xmm4
  469523:	vpinsrd $0x1,0xc(%rsi),%xmm4,%xmm3
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1557
  46952a:	mov    %edi,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1551
  46952c:	and    -0x28(%rsp),%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1557
  469531:	shl    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1558
  469535:	inc    %edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:869
  469537:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1557
  469539:	add    %r11,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1728
  46953c:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1559
  469540:	and    %r8d,%edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:870
  469543:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1728
  469546:	prefetcht2 (%r14,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1494
  46954b:	mov    %r10,(%rsi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1495
  46954e:	vmovq  %xmm3,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1559
  469553:	mov    %edi,0xc0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:870
  469559:	mov    %eax,0xc4(%rcx)
  46955f:	jmp    469448 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9b8>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1540
  469564:	mov    (%r15),%r10d
  469567:	mov    0xc(%rsi),%r12d
  46956b:	mov    %r10,%rbx
  46956e:	shl    $0x4,%r10
  469572:	add    0x8(%r15),%r10
  469576:	mov    %r12d,(%r10)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469579:	xor    %r12d,%r12d
  46957c:	kmovb  %k0,%esi
  469580:	tzcnt  %esi,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1541
  469585:	inc    %r12d
  469588:	movslq %r12d,%rsi
  46958b:	mov    (%r9,%rsi,8),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:869
  46958f:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1542
  469591:	inc    %ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:870
  469593:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1541
  469596:	mov    %r9,0x8(%r10)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1542
  46959a:	mov    %ebx,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:870
  46959d:	mov    %eax,0xc4(%rcx)
  4695a3:	jmp    469414 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:869
  4695a8:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:870
  4695aa:	and    %r8d,%eax
  4695ad:	mov    %eax,0xc4(%rcx)
  4695b3:	jmp    469414 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x984>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4695b8:	mov    $0xffffffff,%eax
  4695bd:	crc32q (%rdx),%rax
  4695c3:	mov    %rax,-0x18(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1947
  4695c8:	vmovd  %eax,%xmm5
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1947
  4695cc:	jmp    4693b5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x925>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4695d1:	mov    $0xffffffff,%r9d
  4695d7:	crc32  %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  4695dd:	mov    %r9d,%r12d
  4695e0:	mov    %r12,-0x28(%rsp)
  4695e5:	jmp    469519 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1026
  4695ea:	xor    %edi,%edi
  4695ec:	jmp    468e96 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x406>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4695f1:	mov    $0xffffffff,%r12d
  4695f7:	crc32  %r9,%r12
  4695fd:	mov    %r12,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1557
  469602:	mov    %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1557
  469605:	jmp    469519 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa89>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1049
  46960a:	incl   -0x2c(%rsp)
  46960e:	jmp    468c3a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1aa>
  469613:	incl   -0x2c(%rsp)
  469617:	vpxor  %xmm15,%xmm15,%xmm15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1029
  46961c:	xor    %r11d,%r11d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1028
  46961f:	vpxor  %xmm12,%xmm12,%xmm12
  469624:	jmp    468bc3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1049
  469629:	incl   -0x2c(%rsp)
  46962d:	jmp    468cb2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x222>
