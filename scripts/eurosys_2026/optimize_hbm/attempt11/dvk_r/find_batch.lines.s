
/opt/DRAMHiT/scripts/eurosys_2026/optimize_hbm/attempt11/dvk_r/dramhit:     file format elf64-x86-64


Disassembly of section .text:

0000000000468d90 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:994
  468d90:	push   %rbp
  468d91:	mov    %rdi,%rcx
  468d94:	mov    %rsp,%rbp
  468d97:	push   %r15
  468d99:	mov    %rdx,%r15
  468d9c:	push   %r14
  468d9e:	push   %r13
  468da0:	push   %r12
  468da2:	push   %rbx
  468da3:	and    $0xffffffffffffffc0,%rsp
  468da7:	sub    $0x8,%rsp
  468dab:	mov    0x8(%rsi),%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1008
  468daf:	mov    0xc0(%rdi),%edi
  468db5:	mov    0xc4(%rcx),%eax
  468dbb:	mov    (%rsi),%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1009
  468dbe:	mov    0x78(%rcx),%r8d
  468dc2:	mov    0x6c(%rcx),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1183
  468dc6:	mov    %r11,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1008
  468dc9:	mov    %edi,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1183
  468dcb:	shl    $0x4,%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1008
  468dcf:	sub    %eax,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1183
  468dd1:	lea    (%rdx,%r10,1),%rbx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1008
  468dd5:	and    %r8d,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1009
  468dd8:	lea    -0x1(%r9),%r12d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1183
  468ddc:	mov    %rbx,-0x20(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1011
  468de1:	cmp    %r12d,%esi
  468de4:	jb     4695af <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x81f>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1070
  468dea:	and    $0xfffffffffffffffc,%r11
  468dee:	shl    $0x4,%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1027
  468df2:	mov    0x80(%rcx),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1018
  468df8:	shl    $0x4,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1020
  468dfc:	shl    $0x4,%rdi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1070
  468e00:	mov    %r11,-0x30(%rsp)
  468e05:	lea    (%rdx,%r11,1),%r11
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1018
  468e09:	mov    %r9,(%rsp)
  468e0d:	lea    -0x1(%r9),%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1020
  468e11:	mov    %rdi,%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1070
  468e14:	mov    %r11,-0x18(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1022
  468e19:	movl   $0x0,-0x28(%rsp)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1017
  468e21:	mov    0xa0(%rcx),%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1023
  468e28:	mov    0x8(%r15),%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1036
  468e2c:	mov    0x2bdbd(%rip),%rdi        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1019
  468e33:	shl    $0x4,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1027
  468e37:	not    %esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1071
  468e39:	cmp    %r11,%rdx
  468e3c:	je     46984a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaba>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468e42:	mov    $0x55,%r13d
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  468e48:	mov    $0x4444,%ebx
  468e4d:	mov    %rcx,-0x38(%rsp)
  468e52:	mov    %r15,-0x40(%rsp)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468e57:	vpxor  %xmm2,%xmm2,%xmm2
  468e5b:	kmovb  %r13d,%k2
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  468e60:	kmovw  %ebx,%k3
  468e64:	jmp    46908d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2fd>
  468e69:	nopl   0x0(%rax)
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468e70:	vmovd  0xc(%r13),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468e76:	kshiftlb $0x1,%k4,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468e7c:	vpcompressq %zmm8,%zmm12{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468e82:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  468e87:	vmovdqu %xmm14,(%r9)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1100
  468e8c:	add    $0x10,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1079
  468e90:	lea    (%r8,%rax,1),%r15
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1038
  468e94:	mov    0x8(%r15),%r11d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468e98:	andn   %r11d,%esi,%ebx
  468e9d:	shl    $0x4,%rbx
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468ea1:	vmovdqa64 (%rdi,%rbx,1),%zmm15
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1043
  468ea8:	vpbroadcastq (%r15),%zmm0
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468eae:	vpcmpequq %zmm0,%zmm15,%k7{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1078
  468eb5:	lea    0x180(%rax),%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1080
  468ebc:	add    $0x10,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1078
  468ec0:	and    %r10,%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1080
  468ec3:	and    %r10,%rax
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468ec6:	andn   0x8(%r8,%r12,1),%esi,%ecx
  468ecd:	shl    $0x4,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1084
  468ed1:	kortestb %k7,%k7
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1078
  468ed5:	prefetcht0 (%rdi,%rcx,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1084
  468ed9:	je     469500 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x770>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468edf:	vmovd  0xc(%r15),%xmm4
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468ee5:	kshiftlb $0x1,%k7,%k4
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468eeb:	vpcompressq %zmm15,%zmm3{%k4}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468ef1:	vpunpcklqdq %xmm3,%xmm4,%xmm6
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  468ef5:	vmovdqu %xmm6,(%r9)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1100
  468efa:	add    $0x10,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1079
  468efe:	lea    (%r8,%rax,1),%r12
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1038
  468f02:	mov    0x8(%r12),%r11d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468f07:	andn   %r11d,%esi,%ebx
  468f0c:	shl    $0x4,%rbx
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468f10:	vmovdqa64 (%rdi,%rbx,1),%zmm5
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1043
  468f17:	vpbroadcastq (%r12),%zmm8
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468f1e:	vpcmpequq %zmm8,%zmm5,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1078
  468f25:	lea    0x180(%rax),%r13
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1080
  468f2c:	add    $0x10,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1078
  468f30:	and    %r10,%r13
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1080
  468f33:	and    %r10,%rax
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468f36:	andn   0x8(%r8,%r13,1),%esi,%ecx
  468f3d:	shl    $0x4,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1084
  468f41:	kortestb %k0,%k0
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1078
  468f45:	prefetcht0 (%rdi,%rcx,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1084
  468f49:	je     4694b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468f4f:	vmovd  0xc(%r12),%xmm12
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468f56:	kshiftlb $0x1,%k0,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468f5c:	vpcompressq %zmm5,%zmm11{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468f62:	vpunpcklqdq %xmm11,%xmm12,%xmm13
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  468f67:	vmovdqu %xmm13,(%r9)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1100
  468f6c:	add    $0x10,%r9
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1079
  468f70:	lea    (%r8,%rax,1),%r11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1038
  468f74:	mov    0x8(%r11),%ebx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468f78:	andn   %ebx,%esi,%r13d
  468f7d:	shl    $0x4,%r13
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468f81:	vmovdqa64 (%rdi,%r13,1),%zmm14
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1043
  468f88:	vpbroadcastq (%r11),%zmm15
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468f8e:	vpcmpequq %zmm15,%zmm14,%k7{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1078
  468f95:	lea    0x180(%rax),%r15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1080
  468f9c:	add    $0x10,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1078
  468fa0:	and    %r10,%r15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1080
  468fa3:	and    %r10,%rax
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468fa6:	andn   0x8(%r8,%r15,1),%esi,%ecx
  468fad:	shl    $0x4,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1084
  468fb1:	kortestb %k7,%k7
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1078
  468fb5:	prefetcht0 (%rdi,%rcx,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1123
  468fb9:	lea    (%r8,%r14,1),%rcx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1084
  468fbd:	je     469468 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d8>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468fc3:	vmovd  0xc(%r11),%xmm3
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468fc9:	kshiftlb $0x1,%k7,%k4
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468fcf:	vpcompressq %zmm14,%zmm7{%k4}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468fd5:	vpunpcklqdq %xmm7,%xmm3,%xmm4
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  468fd9:	vmovdqu %xmm4,(%r9)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1100
  468fde:	add    $0x10,%r9
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468fe2:	mov    $0xffffffff,%r13d
  468fe8:	crc32q (%rdx),%r13
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  468fee:	andn   %r13d,%esi,%r11d
  468ff3:	shl    $0x4,%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1146
  468ff7:	prefetcht2 (%rdi,%r11,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468ffc:	mov    $0xffffffff,%r11d
  469002:	crc32q 0x10(%rdx),%r11
  469009:	mov    $0xffffffff,%r15d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  46900f:	andn   %r11d,%esi,%ebx
  469014:	shl    $0x4,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1146
  469018:	prefetcht2 (%rdi,%rbx,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  46901c:	mov    $0xffffffff,%ebx
  469021:	crc32q 0x20(%rdx),%r15
  469028:	crc32q 0x30(%rdx),%rbx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  46902f:	andn   %r15d,%esi,%r12d
  469034:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1146
  469038:	prefetcht2 (%rdi,%r12,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  46903d:	andn   %ebx,%esi,%r12d
  469042:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1146
  469046:	prefetcht2 (%rdi,%r12,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1158
  46904b:	lea    0x40(%r14),%r12
_Z18_mm512_loadu_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6414
  46904f:	vmovdqu64 (%rdx),%zmm6
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1158
  469055:	cmp    %r12,(%rsp)
  469059:	jb     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7c0>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  46905f:	vmovdqu64 %zmm6,(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1164
  469065:	mov    %r13d,0x8(%rcx)
  469069:	mov    %r11d,0x18(%r8,%r14,1)
  46906e:	mov    %r15d,0x28(%r8,%r14,1)
  469073:	mov    %ebx,0x38(%r8,%r14,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1176
  469078:	mov    %r12,%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1071
  46907b:	add    $0x40,%rdx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1176
  46907f:	and    %r10,%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1071
  469082:	cmp    %rdx,-0x18(%rsp)
  469087:	je     469130 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3a0>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1079
  46908d:	lea    (%r8,%rax,1),%r13
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1038
  469091:	mov    0x8(%r13),%r11d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  469095:	andn   %r11d,%esi,%ebx
  46909a:	shl    $0x4,%rbx
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  46909e:	vmovdqa64 (%rdi,%rbx,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1043
  4690a5:	vpbroadcastq 0x0(%r13),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4690ac:	vpcmpequq %zmm9,%zmm8,%k4{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1078
  4690b3:	lea    0x180(%rax),%rcx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1080
  4690ba:	add    $0x10,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1078
  4690be:	and    %r10,%rcx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1080
  4690c1:	and    %r10,%rax
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  4690c4:	andn   0x8(%r8,%rcx,1),%esi,%r15d
  4690cb:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1084
  4690cf:	kortestb %k4,%k4
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1078
  4690d3:	prefetcht0 (%rdi,%r15,1)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1084
  4690d8:	jne    468e70 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xe0>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4690de:	vpcmpequq %zmm2,%zmm8,%k5{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1110
  4690e5:	kortestb %k5,%k5
  4690e9:	jne    469874 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xae4>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  4690ef:	vmovdqu 0x0(%r13),%xmm10
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690f5:	mov    $0xffffffff,%ecx
  4690fa:	crc32  %r11,%rcx
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  469100:	vpinsrd $0x2,%ecx,%xmm10,%xmm11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  469106:	andn   %ecx,%esi,%r15d
  46910b:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1120
  46910f:	prefetcht2 (%rdi,%r15,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469114:	vmovdqu %xmm11,(%r8,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1125
  46911a:	add    $0x10,%r14
  46911e:	and    %r10,%r14
  469121:	jmp    46908d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2fd>
  469126:	cs nopw 0x0(%rax,%rax,1)
  469130:	mov    -0x38(%rsp),%rcx
  469135:	mov    -0x40(%rsp),%r15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1181
  46913a:	mov    -0x28(%rsp),%r12d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1179
  46913f:	vmovq  %r14,%xmm12
  469144:	vpinsrq $0x1,%rax,%xmm12,%xmm13
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1181
  46914a:	mov    -0x30(%rsp),%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1179
  46914f:	vpsrlq $0x4,%xmm13,%xmm14
  469155:	vpmovqd %xmm14,%xmm15
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1181
  46915b:	sar    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1179
  46915f:	vmovq  %xmm15,0xc0(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1181
  469167:	sub    %r12,%rsi
  46916a:	add    %esi,(%r15)
  46916d:	vpextrd $0x1,%xmm15,%eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1183
  469173:	cmp    -0x20(%rsp),%rdx
  469178:	je     469450 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2001
  46917e:	mov    0x88(%rcx),%r14
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1542
  469185:	mov    0x80(%rcx),%rbx
  46918c:	mov    0x60(%rcx),%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2001
  469190:	dec    %r14
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1542
  469193:	mov    %rbx,-0x18(%rsp)
  469198:	mov    %rdi,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2001
  46919c:	mov    %r14,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:909
  4691a1:	mov    0x78(%rcx),%r10d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:910
  4691a5:	mov    0x2ba44(%rip),%r11        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4691ac:	mov    0xa0(%rcx),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1750
  4691b3:	movzbl 0x2b945(%rip),%r13d        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1752
  4691bb:	mov    0x2b946(%rip),%r12        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4691c2:	mov    $0x55,%r8d
  4691c8:	vpxor  %xmm7,%xmm7,%xmm7
  4691cc:	kmovb  %r8d,%k7
  4691d1:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:909
  4691d8:	lea    0x18(%rax),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:910
  4691db:	and    %r10d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1547
  4691de:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:910
  4691e2:	mov    %ebx,%edi
  4691e4:	and    0x8(%r9,%rsi,1),%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:913
  4691e9:	mov    %eax,%esi
  4691eb:	shl    $0x4,%rsi
  4691ef:	add    %r9,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1734
  4691f2:	mov    (%rsi),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:910
  4691f5:	shl    $0x4,%rdi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:911
  4691f9:	prefetcht0 (%r11,%rdi,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1734
  4691fe:	cmp    0x90(%rcx),%r8
  469205:	jne    4692c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x530>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1750
  46920b:	test   %r13b,%r13b
  46920e:	je     46922e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x49e>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1751
  469210:	mov    (%r15),%r14d
  469213:	mov    0xc(%rsi),%esi
  469216:	mov    %r14,%r8
  469219:	shl    $0x4,%r14
  46921d:	add    0x8(%r15),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1753
  469221:	inc    %r8d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1751
  469224:	mov    %esi,(%r14)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1752
  469227:	mov    %r12,0x8(%r14)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1753
  46922b:	mov    %r8d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:914
  46922e:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:915
  469230:	and    %r10d,%eax
  469233:	mov    %eax,0xc4(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:917
  469239:	test   %r12,%r12
  46923c:	jne    4691d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  46923e:	cmpq   $0x4,(%rsp)
  469243:	je     4693b5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x625>
  469249:	nopl   0x0(%rax)
/opt/DRAMHiT/include/hasher.hpp:39
  469250:	cmpq   $0x8,(%rsp)
  469255:	je     469430 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6a0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2011
  46925b:	vmovd  -0x10(%rsp),%xmm2
  469261:	mov    (%rdx),%rdi
  469264:	mov    0xc0(%rcx),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2001
  46926a:	mov    -0x28(%rsp),%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2011
  46926f:	mov    %rsi,%rax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2001
  469272:	and    -0x10(%rsp),%r8
  469277:	vpinsrd $0x1,0xc(%rdx),%xmm2,%xmm8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2004
  46927e:	and    $0xfffffffffffffffc,%r8
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2011
  469282:	shl    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2029
  469286:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2011
  469288:	add    %r9,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1792
  46928b:	shl    $0x4,%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2030
  46928f:	and    %r10d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1183
  469292:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1792
  469296:	prefetcht2 (%r11,%r8,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1558
  46929b:	mov    %rdi,(%rsi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1559
  46929e:	vmovq  %xmm8,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2030
  4692a3:	mov    %eax,0xc0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1183
  4692a9:	cmp    -0x20(%rsp),%rdx
  4692ae:	je     469450 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:909
  4692b4:	mov    0xc4(%rcx),%eax
  4692ba:	jmp    4691d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
  4692bf:	nop
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1547
  4692c0:	mov    0x8(%rsi),%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1597
  4692c4:	mov    %ebx,%edi
  4692c6:	and    %r14d,%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1599
  4692c9:	shl    $0x4,%rdi
  4692cd:	add    %r11,%rdi
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4692d0:	vmovdqa64 (%rdi),%zmm0
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  4692d6:	vpbroadcastq %r8,%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4692dc:	vpcmpequq %zmm1,%zmm0,%k0{%k7}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1603
  4692e3:	kortestb %k0,%k0
  4692e7:	jne    469370 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5e0>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4692ed:	vpcmpequq %zmm7,%zmm0,%k1{%k7}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1611
  4692f4:	kortestb %k1,%k1
  4692f8:	jne    4693e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x650>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4692fe:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1613
  469303:	mov    %r14d,%edi
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  469306:	je     4693f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x660>
/opt/DRAMHiT/include/hasher.hpp:39
  46930c:	cmpq   $0x8,(%rsp)
  469311:	je     469410 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x680>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1621
  469317:	vmovd  -0x8(%rsp),%xmm3
  46931d:	mov    0xc0(%rcx),%edi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1615
  469323:	mov    -0x18(%rsp),%r14
  469328:	vpinsrd $0x1,0xc(%rsi),%xmm3,%xmm6
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1621
  46932f:	mov    %rdi,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1615
  469332:	and    -0x8(%rsp),%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1621
  469337:	shl    $0x4,%rdi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1622
  46933b:	inc    %esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:914
  46933d:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1621
  46933f:	add    %r9,%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1792
  469342:	shl    $0x4,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1623
  469346:	and    %r10d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:915
  469349:	and    %r10d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1792
  46934c:	prefetcht2 (%r11,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1558
  469351:	mov    %r8,(%rdi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1559
  469354:	vmovq  %xmm6,0x8(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1623
  469359:	mov    %esi,0xc0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:915
  46935f:	mov    %eax,0xc4(%rcx)
  469365:	jmp    4691d8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
  46936a:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1604
  469370:	mov    (%r15),%r8d
  469373:	mov    0xc(%rsi),%esi
  469376:	mov    %r8,%r14
  469379:	shl    $0x4,%r8
  46937d:	add    0x8(%r15),%r8
  469381:	mov    %esi,(%r8)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469384:	kmovb  %k0,%esi
  469388:	tzcnt  %esi,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1605
  46938c:	inc    %esi
  46938e:	movslq %esi,%rsi
  469391:	mov    (%rdi,%rsi,8),%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:914
  469395:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1606
  469397:	inc    %r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:915
  46939a:	and    %r10d,%eax
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  46939d:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1605
  4693a2:	mov    %rdi,0x8(%r8)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1606
  4693a6:	mov    %r14d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:915
  4693a9:	mov    %eax,0xc4(%rcx)
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  4693af:	jne    469250 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4c0>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4693b5:	mov    $0xffffffff,%r14d
  4693bb:	crc32l (%rdx),%r14d
  4693c1:	vmovd  %r14d,%xmm5
  4693c6:	mov    (%rdx),%rdi
  4693c9:	vmovdqa %xmm5,%xmm2
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  4693cd:	vmovq  %xmm5,-0x10(%rsp)
  4693d3:	jmp    469264 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4d4>
  4693d8:	nopl   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:914
  4693e0:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:915
  4693e2:	and    %r10d,%eax
  4693e5:	mov    %eax,0xc4(%rcx)
  4693eb:	jmp    46923e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4ae>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4693f0:	mov    $0xffffffff,%edi
  4693f5:	crc32  %r14d,%edi
  4693fb:	vmovd  %edi,%xmm4
  4693ff:	vmovdqa %xmm4,%xmm3
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  469403:	vmovq  %xmm4,-0x8(%rsp)
  469409:	jmp    46931d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x58d>
  46940e:	xchg   %ax,%ax
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469410:	mov    $0xffffffff,%r14d
  469416:	crc32  %rdi,%r14
  46941c:	mov    %r14,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1621
  469421:	vmovd  %r14d,%xmm3
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1621
  469426:	jmp    46931d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x58d>
  46942b:	nopl   0x0(%rax,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469430:	mov    (%rdx),%rdi
  469433:	mov    $0xffffffff,%eax
  469438:	crc32  %rdi,%rax
  46943e:	mov    %rax,-0x10(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2011
  469443:	vmovd  %eax,%xmm2
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2011
  469447:	jmp    469264 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4d4>
  46944c:	nopl   0x0(%rax)
  469450:	vzeroupper 
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:996
  469453:	lea    -0x28(%rbp),%rsp
  469457:	pop    %rbx
  469458:	pop    %r12
  46945a:	pop    %r13
  46945c:	pop    %r14
  46945e:	pop    %r15
  469460:	pop    %rbp
  469461:	ret    
  469462:	nopw   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469468:	vpcmpequq %zmm2,%zmm14,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1110
  46946f:	kortestb %k1,%k1
  469473:	jne    469886 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaf6>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  469479:	vmovdqu (%r11),%xmm0
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  46947e:	mov    $0xffffffff,%r15d
  469484:	crc32  %rbx,%r15
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  46948a:	vpinsrd $0x2,%r15d,%xmm0,%xmm1
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1125
  469490:	add    $0x10,%r14
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  469494:	andn   %r15d,%esi,%r12d
  469499:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1125
  46949d:	and    %r10,%r14
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1120
  4694a0:	prefetcht2 (%rdi,%r12,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  4694a5:	vmovdqu %xmm1,(%rcx)
  4694a9:	jmp    468f70 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1e0>
  4694ae:	xchg   %ax,%ax
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4694b0:	vpcmpequq %zmm2,%zmm5,%k5{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1110
  4694b7:	kortestb %k5,%k5
  4694bb:	jne    46987d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaed>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  4694c1:	vmovdqu (%r12),%xmm9
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4694c7:	mov    $0xffffffff,%r13d
  4694cd:	crc32  %r11,%r13
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  4694d3:	vpinsrd $0x2,%r13d,%xmm9,%xmm10
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  4694d9:	andn   %r13d,%esi,%ecx
  4694de:	shl    $0x4,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1120
  4694e2:	prefetcht2 (%rdi,%rcx,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  4694e6:	vmovdqu %xmm10,(%r8,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1125
  4694ec:	add    $0x10,%r14
  4694f0:	and    %r10,%r14
  4694f3:	jmp    468efe <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x16e>
  4694f8:	nopl   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469500:	vpcmpequq %zmm2,%zmm15,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1110
  469507:	kortestb %k1,%k1
  46950b:	jne    46986b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xadb>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  469511:	vmovdqu (%r15),%xmm1
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469516:	mov    $0xffffffff,%r12d
  46951c:	crc32  %r11,%r12
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  469522:	vpinsrd $0x2,%r12d,%xmm1,%xmm7
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1033
  469528:	andn   %r12d,%esi,%ecx
  46952d:	shl    $0x4,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1120
  469531:	prefetcht2 (%rdi,%rcx,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469535:	vmovdqu %xmm7,(%r8,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1125
  46953b:	add    $0x10,%r14
  46953f:	and    %r10,%r14
  469542:	jmp    468e90 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x100>
  469547:	nopw   0x0(%rax,%rax,1)
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469550:	vmovd  %r13d,%xmm9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1171
  469555:	mov    (%rsp),%r13
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469559:	vmovd  %r15d,%xmm5
  46955e:	vpinsrd $0x1,%r11d,%xmm9,%xmm10
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1171
  469564:	mov    %r13,%r11
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469567:	vpinsrd $0x1,%ebx,%xmm5,%xmm8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1171
  46956d:	sub    %r14,%r11
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469570:	vpunpcklqdq %xmm8,%xmm10,%xmm11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1172
  469575:	shr    $0x2,%r11
  469579:	mov    $0x1,%r15d
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  46957f:	vpexpandd %zmm11,%zmm6{%k3}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1172
  469585:	shlx   %r11d,%r15d,%r11d
  46958a:	lea    -0x1(%r11),%ebx
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1174
  46958e:	sub    %r13,%r14
  469591:	neg    %r11d
_Z24_mm512_mask_storeu_epi32PvtDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6461
  469594:	kmovw  %ebx,%k5
  469598:	vmovdqu32 %zmm6,(%rcx){%k5}
  46959e:	kmovw  %r11d,%k6
  4695a3:	vmovdqu32 %zmm6,(%r8,%r14,1){%k6}
  4695aa:	jmp    469078 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2e8>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1399
  4695af:	cmp    -0x20(%rsp),%rdx
  4695b4:	je     469453 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c3>
  4695ba:	mov    0x60(%rcx),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2001
  4695be:	mov    0x88(%rcx),%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1750
  4695c5:	movzbl 0x2b533(%rip),%r13d        # 494b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1752
  4695cd:	mov    0x2b534(%rip),%rbx        # 494b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4695d4:	mov    %r9,(%rsp)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4695d8:	mov    $0x55,%r10d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2001
  4695de:	lea    -0x1(%r12),%r9
  4695e3:	kmovb  %r13d,%k2
  4695e8:	mov    %r9,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:910
  4695ed:	mov    0x2b5fc(%rip),%r14        # 494bf0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4695f4:	mov    0xa0(%rcx),%r11
  4695fb:	mov    %edi,%esi
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4695fd:	vpxor  %xmm2,%xmm2,%xmm2
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2001
  469601:	mov    %rbx,%r13
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469604:	kmovb  %r10d,%k1
  469609:	jmp    469671 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8e1>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:39
  46960b:	cmpq   $0x8,(%rsp)
  469610:	je     469818 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa88>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2011
  469616:	vmovd  -0x18(%rsp),%xmm4
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2001
  46961c:	mov    -0x8(%rsp),%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2011
  469621:	mov    %edi,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2001
  469623:	and    -0x18(%rsp),%r12
  469628:	vpinsrd $0x1,0xc(%rdx),%xmm4,%xmm5
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2011
  46962f:	mov    (%rdx),%r10
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2004
  469632:	and    $0xfffffffffffffffc,%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2011
  469636:	shl    $0x4,%rsi
  46963a:	add    %r11,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1792
  46963d:	shl    $0x4,%r12
  469641:	prefetcht2 (%r14,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1558
  469646:	mov    %r10,(%rsi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1559
  469649:	vmovq  %xmm5,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2029
  46964e:	lea    0x1(%rdi),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2030
  469651:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1399
  469654:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2030
  469658:	mov    %esi,0xc0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1399
  46965e:	cmp    %rdx,-0x20(%rsp)
  469663:	je     469450 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17get_find_queue_szEv():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:816
  469669:	mov    0xc4(%rcx),%eax
  46966f:	mov    %esi,%edi
  469671:	sub    %eax,%esi
  469673:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1400
  469676:	cmp    %esi,%r8d
  469679:	jbe    46969c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x90c>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  46967b:	cmpq   $0x4,(%rsp)
  469680:	jne    46960b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x87b>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469682:	mov    $0xffffffff,%ebx
  469687:	crc32l (%rdx),%ebx
  46968c:	vmovd  %ebx,%xmm6
  469690:	vmovdqa %xmm6,%xmm4
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  469694:	vmovq  %xmm6,-0x18(%rsp)
  46969a:	jmp    46961c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x88c>
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1542
  46969c:	mov    0x80(%rcx),%rbx
  4696a3:	mov    %rbx,-0x10(%rsp)
  4696a8:	nopl   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:909
  4696b0:	lea    0x18(%rax),%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:910
  4696b3:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1547
  4696b6:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:910
  4696ba:	mov    %ebx,%r10d
  4696bd:	and    0x8(%r11,%rsi,1),%r10d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:913
  4696c2:	mov    %eax,%esi
  4696c4:	shl    $0x4,%rsi
  4696c8:	add    %r11,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:910
  4696cb:	mov    %r10,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1734
  4696ce:	mov    (%rsi),%r10
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:910
  4696d1:	shl    $0x4,%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:911
  4696d5:	prefetcht0 (%r14,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1734
  4696da:	cmp    0x90(%rcx),%r10
  4696e1:	jne    469720 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x990>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1750
  4696e3:	kortestb %k2,%k2
  4696e7:	je     46970a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x97a>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1751
  4696e9:	mov    (%r15),%r12d
  4696ec:	mov    0xc(%rsi),%esi
  4696ef:	mov    %r12,%r10
  4696f2:	shl    $0x4,%r12
  4696f6:	add    0x8(%r15),%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1753
  4696fa:	lea    0x1(%r10),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1751
  4696fe:	mov    %esi,(%r12)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1752
  469702:	mov    %r13,0x8(%r12)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1753
  469707:	mov    %r9d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:914
  46970a:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:915
  46970c:	and    %r8d,%eax
  46970f:	mov    %eax,0xc4(%rcx)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:917
  469715:	test   %r13,%r13
  469718:	jne    4696b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x920>
  46971a:	jmp    46967b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8eb>
  46971f:	nop
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1547
  469720:	mov    0x8(%rsi),%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1597
  469724:	mov    %ebx,%r9d
  469727:	and    %r12d,%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1599
  46972a:	shl    $0x4,%r9
  46972e:	add    %r14,%r9
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469731:	vmovdqa64 (%r9),%zmm0
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  469737:	vpbroadcastq %r10,%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46973d:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1603
  469744:	kortestb %k0,%k0
  469748:	jne    4697c4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa34>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46974a:	vpcmpequq %zmm2,%zmm0,%k3{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1611
  469751:	kortestb %k3,%k3
  469755:	jne    469808 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa78>
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  46975b:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1613
  469760:	mov    %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:37
  469763:	je     469831 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaa1>
/opt/DRAMHiT/include/hasher.hpp:39
  469769:	cmpq   $0x8,(%rsp)
  46976e:	je     469852 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xac2>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1621
  469774:	mov    -0x28(%rsp),%r9d
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1615
  469779:	mov    -0x10(%rsp),%r12
  46977e:	vmovd  %r9d,%xmm7
  469783:	vpinsrd $0x1,0xc(%rsi),%xmm7,%xmm3
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1621
  46978a:	mov    %edi,%esi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1615
  46978c:	and    -0x28(%rsp),%r12
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1621
  469791:	shl    $0x4,%rsi
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1622
  469795:	inc    %edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:914
  469797:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1621
  469799:	add    %r11,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1792
  46979c:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1623
  4697a0:	and    %r8d,%edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:915
  4697a3:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1792
  4697a6:	prefetcht2 (%r14,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1558
  4697ab:	mov    %r10,(%rsi)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1559
  4697ae:	vmovq  %xmm3,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1623
  4697b3:	mov    %edi,0xc0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:915
  4697b9:	mov    %eax,0xc4(%rcx)
  4697bf:	jmp    4696b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x920>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1604
  4697c4:	mov    (%r15),%r10d
  4697c7:	mov    0xc(%rsi),%r12d
  4697cb:	mov    %r10,%rbx
  4697ce:	shl    $0x4,%r10
  4697d2:	add    0x8(%r15),%r10
  4697d6:	mov    %r12d,(%r10)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  4697d9:	xor    %r12d,%r12d
  4697dc:	kmovb  %k0,%esi
  4697e0:	tzcnt  %esi,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1605
  4697e5:	inc    %r12d
  4697e8:	movslq %r12d,%rsi
  4697eb:	mov    (%r9,%rsi,8),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:914
  4697ef:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1606
  4697f1:	inc    %ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:915
  4697f3:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1605
  4697f6:	mov    %r9,0x8(%r10)
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1606
  4697fa:	mov    %ebx,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:915
  4697fd:	mov    %eax,0xc4(%rcx)
  469803:	jmp    46967b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8eb>
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:914
  469808:	inc    %eax
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:915
  46980a:	and    %r8d,%eax
  46980d:	mov    %eax,0xc4(%rcx)
  469813:	jmp    46967b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8eb>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469818:	mov    $0xffffffff,%eax
  46981d:	crc32q (%rdx),%rax
  469823:	mov    %rax,-0x18(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2011
  469828:	vmovd  %eax,%xmm4
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:2011
  46982c:	jmp    46961c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x88c>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469831:	mov    $0xffffffff,%r9d
  469837:	crc32  %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/hasher.hpp:38
  46983d:	mov    %r9d,%r12d
  469840:	mov    %r12,-0x28(%rsp)
  469845:	jmp    469779 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9e9>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1071
  46984a:	xor    %r12d,%r12d
  46984d:	jmp    46913f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3af>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469852:	mov    $0xffffffff,%r12d
  469858:	crc32  %r9,%r12
  46985e:	mov    %r12,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1621
  469863:	mov    %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1621
  469866:	jmp    469779 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9e9>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/opt/DRAMHiT/include/./hashtables/cas_kht.hpp:1111
  46986b:	incl   -0x28(%rsp)
  46986f:	jmp    468efe <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x16e>
  469874:	incl   -0x28(%rsp)
  469878:	jmp    468e90 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x100>
  46987d:	incl   -0x28(%rsp)
  469881:	jmp    468f70 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1e0>
  469886:	incl   -0x28(%rsp)
  46988a:	jmp    468fe2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x252>
