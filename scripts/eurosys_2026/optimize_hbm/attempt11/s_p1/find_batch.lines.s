
/opt/DRAMHiT/scripts/eurosys_2026/optimize_hbm/attempt11/s_p1/dramhit:     file format elf64-x86-64


Disassembly of section .text:

0000000000468df0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:703
  468df0:	push   %rbp
  468df1:	mov    %rdi,%rcx
  468df4:	mov    %rdx,%rdi
  468df7:	mov    %rsp,%rbp
  468dfa:	push   %r15
  468dfc:	push   %r14
  468dfe:	push   %r13
  468e00:	push   %r12
  468e02:	push   %rbx
  468e03:	and    $0xffffffffffffffc0,%rsp
  468e07:	sub    $0x8,%rsp
  468e0b:	mov    0x8(%rsi),%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e0f:	mov    0xb0(%rcx),%r10d
  468e16:	mov    0xb4(%rcx),%eax
  468e1c:	mov    (%rsi),%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:718
  468e1f:	mov    0x78(%rcx),%r8d
  468e23:	mov    0x6c(%rcx),%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:860
  468e27:	mov    %r11,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e2a:	mov    %r10d,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:860
  468e2d:	shl    $0x4,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e31:	sub    %eax,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:860
  468e33:	add    %rdx,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e36:	and    %r8d,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:718
  468e39:	lea    -0x1(%r9),%r12d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:860
  468e3d:	mov    %rbx,-0x28(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:720
  468e42:	cmp    %r12d,%esi
  468e45:	jb     469705 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x915>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:775
  468e4b:	and    $0xfffffffffffffffc,%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:729
  468e4f:	mov    %r10d,%ebx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:775
  468e52:	shl    $0x4,%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:733
  468e56:	mov    0x80(%rcx),%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:732
  468e5d:	mov    0x8(%rdi),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468e61:	shl    $0x4,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:775
  468e65:	lea    (%rdx,%r11,1),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468e69:	mov    %r9,-0x30(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:733
  468e6e:	mov    %r10d,(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:732
  468e72:	mov    %r15,-0x10(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:775
  468e77:	mov    %r11,-0x48(%rsp)
  468e7c:	mov    %r14,-0x38(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:731
  468e81:	movl   $0x0,-0x3c(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:726
  468e89:	mov    0xa0(%rcx),%r8
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:765
  468e90:	mov    0x29d51(%rip),%rsi        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468e97:	dec    %r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:728
  468e9a:	shl    $0x4,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:729
  468e9e:	shl    $0x4,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:736
  468ea2:	not    %r10d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:776
  468ea5:	cmp    %r14,%rdx
  468ea8:	je     46999e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbae>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468eae:	mov    $0x55,%r13d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468eb4:	mov    $0xf,%r11d
  468eba:	mov    $0xf0,%r12d
  468ec0:	mov    $0xf00,%r15d
  468ec6:	mov    $0xfffff000,%r14d
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468ecc:	kmovb  %r13d,%k1
  468ed1:	vpxor  %xmm4,%xmm4,%xmm4
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468ed5:	mov    $0xffffffff,%r13d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468edb:	kmovw  %r11d,%k5
  468ee0:	kmovw  %r12d,%k4
  468ee5:	kmovw  %r15d,%k3
  468eea:	kmovw  %r14d,%k2
  468eef:	jmp    469189 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x399>
  468ef4:	nopl   0x0(%rax)
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468ef8:	vmovd  0xc(%r12),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468eff:	kshiftlb $0x1,%k6,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468f05:	vpcompressq %zmm8,%zmm12{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468f0b:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468f10:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k5}{z}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468f17:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  468f1d:	mov    $0x1,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:783
  468f23:	lea    0x180(%rax),%r15
  468f2a:	and    %r9,%r15
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  468f2d:	andn   0x8(%r8,%r15,1),%r10d,%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:783
  468f34:	mov    %r14d,%r12d
  468f37:	shl    $0x4,%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:784
  468f3b:	lea    (%r8,%rax,1),%r14
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  468f3f:	mov    0x8(%r14),%r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:783
  468f43:	prefetcht0 (%rsi,%r12,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  468f48:	andn   %r15d,%r10d,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:786
  468f4d:	mov    %r12d,%r12d
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468f50:	shl    $0x4,%r12
  468f54:	vmovdqa64 (%rsi,%r12,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:746
  468f5b:	vpbroadcastq (%r14),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468f61:	vpcmpequq %zmm2,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  468f68:	add    $0x10,%rax
  468f6c:	and    %r9,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:788
  468f6f:	kortestb %k0,%k0
  468f73:	je     469620 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x830>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468f79:	vmovd  0xc(%r14),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468f7f:	kshiftlb $0x1,%k0,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468f85:	vpcompressq %zmm0,%zmm5{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468f8b:	vpunpcklqdq %xmm5,%xmm1,%xmm6
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468f8f:	vshufi32x4 $0x0,%zmm6,%zmm6,%zmm15{%k4}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468f96:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  468f9c:	or     $0x2,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:783
  468fa0:	lea    0x180(%rax),%r14
  468fa7:	and    %r9,%r14
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  468faa:	andn   0x8(%r8,%r14,1),%r10d,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:783
  468fb1:	mov    %r12d,%r15d
  468fb4:	shl    $0x4,%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:784
  468fb8:	lea    (%r8,%rax,1),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:783
  468fbc:	prefetcht0 (%rsi,%r15,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  468fc1:	mov    0x8(%r14),%r15d
  468fc5:	andn   %r15d,%r10d,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:786
  468fca:	mov    %r12d,%r12d
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468fcd:	shl    $0x4,%r12
  468fd1:	vmovdqa64 (%rsi,%r12,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:746
  468fd8:	vpbroadcastq (%r14),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468fde:	vpcmpequq %zmm9,%zmm8,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  468fe5:	add    $0x10,%rax
  468fe9:	and    %r9,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:788
  468fec:	kortestb %k0,%k0
  468ff0:	je     4695c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468ff6:	vmovd  0xc(%r14),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468ffc:	kshiftlb $0x1,%k0,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  469002:	vpcompressq %zmm8,%zmm12{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  469008:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  46900d:	mov    %rdx,-0x18(%rsp)
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  469012:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k3}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  469019:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  46901f:	or     $0x4,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:783
  469023:	lea    0x180(%rax),%rdx
  46902a:	and    %r9,%rdx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  46902d:	andn   0x8(%r8,%rdx,1),%r10d,%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:783
  469034:	mov    %r14d,%r12d
  469037:	shl    $0x4,%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:784
  46903b:	lea    (%r8,%rax,1),%r14
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  46903f:	mov    0x8(%r14),%r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:783
  469043:	prefetcht0 (%rsi,%r12,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  469048:	andn   %r15d,%r10d,%edx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:786
  46904d:	mov    %edx,%r12d
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469050:	shl    $0x4,%r12
  469054:	vmovdqa64 (%rsi,%r12,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:746
  46905b:	vpbroadcastq (%r14),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469061:	vpcmpequq %zmm2,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  469068:	add    $0x10,%rax
  46906c:	and    %r9,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:843
  46906f:	lea    (%r8,%rbx,1),%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:788
  469073:	kortestb %k0,%k0
  469077:	je     469568 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x778>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46907d:	vmovd  0xc(%r14),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  469083:	kshiftlb $0x1,%k0,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  469089:	vpcompressq %zmm0,%zmm5{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  46908f:	vpunpcklqdq %xmm5,%xmm1,%xmm6
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  469093:	vshufi32x4 $0x0,%zmm6,%zmm6,%zmm15{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  46909a:	or     $0x8,%r11d
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  46909e:	mov    -0x18(%rsp),%rdx
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  4690a3:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:815
  4690a9:	cmp    $0xf,%r11d
  4690ad:	jne    4696d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8e0>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  4690b3:	mov    -0x10(%rsp),%r14
  4690b8:	vmovdqu64 %zmm15,(%r14)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:817
  4690be:	add    $0x40,%r14
  4690c2:	mov    %r14,-0x10(%rsp)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690c7:	mov    %r13,%r15
  4690ca:	crc32q (%rdx),%r15
  4690d0:	vmovq  %r15,%xmm15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:828
  4690d5:	mov    %r15d,%r11d
  4690d8:	mov    (%rsp),%r15d
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690dc:	mov    %r13,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:828
  4690df:	and    %r15d,%r11d
  4690e2:	shl    $0x4,%r11
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690e6:	crc32q 0x10(%rdx),%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:828
  4690ed:	prefetcht2 (%rsi,%r11,1)
  4690f2:	mov    %r15d,%r11d
  4690f5:	and    %r14d,%r11d
  4690f8:	shl    $0x4,%r11
  4690fc:	prefetcht2 (%rsi,%r11,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469101:	mov    %r13,%r11
  469104:	crc32q 0x20(%rdx),%r11
  46910b:	vmovq  %r11,%xmm8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:828
  469110:	and    %r15d,%r11d
  469113:	shl    $0x4,%r11
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469117:	mov    %r13,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:828
  46911a:	prefetcht2 (%rsi,%r11,1)
  46911f:	mov    (%rsp),%r11d
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469123:	crc32q 0x30(%rdx),%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:828
  46912a:	and    %r15d,%r11d
  46912d:	shl    $0x4,%r11
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469131:	vpinsrd $0x1,%r14d,%xmm15,%xmm10
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  469137:	vmovdqu32 (%rdx),%zmm13
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46913d:	vpinsrd $0x1,%r15d,%xmm8,%xmm9
  469143:	vpunpcklqdq %xmm9,%xmm10,%xmm11
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  469148:	mov    $0x4444,%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:828
  46914e:	prefetcht2 (%rsi,%r11,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:842
  469153:	lea    0x40(%rbx),%r11
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  469157:	kmovw  %r14d,%k6
  46915c:	vpexpandd %zmm11,%zmm13{%k6}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:842
  469162:	cmp    %r11,-0x30(%rsp)
  469167:	jb     469680 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x890>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  46916d:	vmovdqu64 %zmm13,(%r12)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:853
  469174:	mov    %r11,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:776
  469177:	add    $0x40,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:853
  46917b:	and    %r9,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:776
  46917e:	cmp    %rdx,-0x38(%rsp)
  469183:	je     469238 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:783
  469189:	lea    0x180(%rax),%r11
  469190:	and    %r9,%r11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  469193:	andn   0x8(%r8,%r11,1),%r10d,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:783
  46919a:	mov    %r12d,%r15d
  46919d:	shl    $0x4,%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:784
  4691a1:	lea    (%r8,%rax,1),%r12
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  4691a5:	mov    0x8(%r12),%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:783
  4691aa:	prefetcht0 (%rsi,%r15,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  4691af:	andn   %r14d,%r10d,%r11d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:786
  4691b4:	mov    %r11d,%r15d
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4691b7:	shl    $0x4,%r15
  4691bb:	vmovdqa64 (%rsi,%r15,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:746
  4691c2:	vpbroadcastq (%r12),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4691c9:	vpcmpequq %zmm9,%zmm8,%k6{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  4691d0:	add    $0x10,%rax
  4691d4:	and    %r9,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:788
  4691d7:	kortestb %k6,%k6
  4691db:	jne    468ef8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4691e1:	vpcmpequq %zmm4,%zmm8,%k7{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:797
  4691e8:	kortestb %k7,%k7
  4691ec:	jne    4699c8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbd8>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4691f2:	mov    %r13,%r15
  4691f5:	crc32  %r14,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  4691fb:	mov    (%rsp),%r14d
  4691ff:	vmovd  %r15d,%xmm10
  469204:	vpinsrd $0x1,0xc(%r12),%xmm10,%xmm11
  46920c:	and    %r15d,%r14d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:808
  46920f:	mov    (%r12),%r12
  469213:	lea    (%r8,%rbx,1),%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  469217:	shl    $0x4,%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:809
  46921b:	add    $0x10,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  46921f:	prefetcht2 (%rsi,%r14,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:809
  469224:	and    %r9,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1222
  469227:	mov    %r12,(%r11)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1223
  46922a:	vmovq  %xmm11,0x8(%r11)
  469230:	jmp    469189 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x399>
  469235:	nopl   (%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:858
  469238:	mov    -0x3c(%rsp),%r12d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:856
  46923d:	vmovq  %rbx,%xmm14
  469242:	vpinsrq $0x1,%rax,%xmm14,%xmm0
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:858
  469248:	mov    -0x48(%rsp),%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:856
  46924d:	vpsrlq $0x4,%xmm0,%xmm2
  469252:	vpmovqd %xmm2,%xmm7
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:858
  469258:	sar    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:856
  46925c:	vmovq  %xmm7,0xb0(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:858
  469264:	sub    %r12,%rsi
  469267:	add    %esi,(%rdi)
  469269:	vpextrd $0x1,%xmm7,%eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:860
  46926f:	cmp    -0x28(%rsp),%rdx
  469274:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x760>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1665
  46927a:	mov    0x88(%rcx),%r15
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1206
  469281:	mov    0x80(%rcx),%r12
  469288:	mov    0x60(%rcx),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1665
  46928c:	dec    %r15
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1206
  46928f:	mov    %r12,-0x10(%rsp)
  469294:	mov    %r8,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1665
  469298:	mov    %r15,-0x18(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  46929d:	mov    0x78(%rcx),%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692a1:	mov    0x29940(%rip),%rbx        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4692a8:	mov    0xa0(%rcx),%r10
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1414
  4692af:	movzbl 0x29849(%rip),%r14d        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1416
  4692b7:	mov    0x2984a(%rip),%r13        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4692be:	mov    $0x55,%r9d
  4692c4:	vpxor  %xmm3,%xmm3,%xmm3
  4692c8:	kmovb  %r9d,%k1
  4692cd:	nopl   (%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  4692d0:	lea    0x18(%rax),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692d3:	and    %r11d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1211
  4692d6:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692da:	mov    %r12d,%r8d
  4692dd:	and    0x8(%r10,%rsi,1),%r8d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  4692e2:	mov    %eax,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692e4:	mov    %r8,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  4692e7:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692eb:	shl    $0x4,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  4692ef:	add    %r10,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:620
  4692f2:	prefetcht0 (%rbx,%r9,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1398
  4692f7:	mov    (%rsi),%r9
  4692fa:	cmp    0x90(%rcx),%r9
  469301:	jne    4693c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5d0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1414
  469307:	test   %r14b,%r14b
  46930a:	je     46932a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x53a>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1415
  46930c:	mov    (%rdi),%r15d
  46930f:	mov    0xc(%rsi),%esi
  469312:	mov    %r15,%r9
  469315:	shl    $0x4,%r15
  469319:	add    0x8(%rdi),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1417
  46931d:	inc    %r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1415
  469320:	mov    %esi,(%r15)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1416
  469323:	mov    %r13,0x8(%r15)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1417
  469327:	mov    %r9d,(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46932a:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46932c:	and    %r11d,%eax
  46932f:	mov    %eax,0xb4(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:626
  469335:	test   %r13,%r13
  469338:	jne    4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4e0>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46933a:	cmpq   $0x4,(%rsp)
  46933f:	je     4694b5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c5>
  469345:	nopl   (%rax)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  469348:	cmpq   $0x8,(%rsp)
  46934d:	je     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x740>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1675
  469353:	vmovd  -0x20(%rsp),%xmm15
  469359:	mov    (%rdx),%r8
  46935c:	mov    0xb0(%rcx),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1665
  469362:	mov    -0x18(%rsp),%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1675
  469367:	mov    %rsi,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1665
  46936a:	and    -0x20(%rsp),%r9
  46936f:	vpinsrd $0x1,0xc(%rdx),%xmm15,%xmm9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1668
  469376:	and    $0xfffffffffffffffc,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1675
  46937a:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1693
  46937e:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1675
  469380:	add    %r10,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1456
  469383:	shl    $0x4,%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1694
  469387:	and    %r11d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:860
  46938a:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1456
  46938e:	prefetcht2 (%rbx,%r9,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1222
  469393:	mov    %r8,(%rsi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1223
  469396:	vmovq  %xmm9,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1694
  46939b:	mov    %eax,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:860
  4693a1:	cmp    -0x28(%rsp),%rdx
  4693a6:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x760>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  4693ac:	mov    0xb4(%rcx),%eax
  4693b2:	jmp    4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4e0>
  4693b7:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1211
  4693c0:	mov    0x8(%rsi),%r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1261
  4693c4:	mov    %r12d,%r8d
  4693c7:	and    %r15d,%r8d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1263
  4693ca:	shl    $0x4,%r8
  4693ce:	add    %rbx,%r8
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4693d1:	vmovdqa64 (%r8),%zmm5
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  4693d7:	vpbroadcastq %r9,%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4693dd:	vpcmpequq %zmm1,%zmm5,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1267
  4693e4:	kortestb %k0,%k0
  4693e8:	jne    469470 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x680>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4693ee:	vpcmpequq %zmm3,%zmm5,%k2{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1275
  4693f5:	kortestb %k2,%k2
  4693f9:	jne    4694e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6f0>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4693ff:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1277
  469404:	mov    %r15d,%r8d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  469407:	je     4694f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  46940d:	cmpq   $0x8,(%rsp)
  469412:	je     469510 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  469418:	vmovd  -0x8(%rsp),%xmm6
  46941e:	mov    0xb0(%rcx),%r8d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1279
  469425:	mov    -0x10(%rsp),%r15
  46942a:	vpinsrd $0x1,0xc(%rsi),%xmm6,%xmm4
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  469431:	mov    %r8,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1279
  469434:	and    -0x8(%rsp),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  469439:	shl    $0x4,%r8
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1286
  46943d:	inc    %esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46943f:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  469441:	add    %r10,%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1456
  469444:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1287
  469448:	and    %r11d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46944b:	and    %r11d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1456
  46944e:	prefetcht2 (%rbx,%r15,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1222
  469453:	mov    %r9,(%r8)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1223
  469456:	vmovq  %xmm4,0x8(%r8)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1287
  46945c:	mov    %esi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469462:	mov    %eax,0xb4(%rcx)
  469468:	jmp    4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4e0>
  46946d:	nopl   (%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1268
  469470:	mov    (%rdi),%r9d
  469473:	mov    0xc(%rsi),%esi
  469476:	mov    %r9,%r15
  469479:	shl    $0x4,%r9
  46947d:	add    0x8(%rdi),%r9
  469481:	mov    %esi,(%r9)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469484:	kmovb  %k0,%esi
  469488:	tzcnt  %esi,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1269
  46948c:	inc    %esi
  46948e:	movslq %esi,%rsi
  469491:	mov    (%r8,%rsi,8),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469495:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1270
  469497:	inc    %r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46949a:	and    %r11d,%eax
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46949d:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1269
  4694a2:	mov    %r8,0x8(%r9)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1270
  4694a6:	mov    %r15d,(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4694a9:	mov    %eax,0xb4(%rcx)
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4694af:	jne    469348 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x558>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4694b5:	mov    $0xffffffff,%r15d
  4694bb:	crc32l (%rdx),%r15d
  4694c1:	vmovd  %r15d,%xmm8
  4694c6:	mov    (%rdx),%r8
  4694c9:	vmovdqa %xmm8,%xmm15
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  4694ce:	vmovq  %xmm8,-0x20(%rsp)
  4694d4:	jmp    46935c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x56c>
  4694d9:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  4694e0:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4694e2:	and    %r11d,%eax
  4694e5:	mov    %eax,0xb4(%rcx)
  4694eb:	jmp    46933a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x54a>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4694f0:	mov    $0xffffffff,%r8d
  4694f6:	crc32  %r15d,%r8d
  4694fc:	vmovd  %r8d,%xmm12
  469501:	vmovdqa %xmm12,%xmm6
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  469505:	vmovq  %xmm12,-0x8(%rsp)
  46950b:	jmp    46941e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x62e>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469510:	mov    $0xffffffff,%r15d
  469516:	crc32  %r8,%r15
  46951c:	mov    %r15,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  469521:	vmovd  %r15d,%xmm6
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  469526:	jmp    46941e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x62e>
  46952b:	nopl   0x0(%rax,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469530:	mov    (%rdx),%r8
  469533:	mov    $0xffffffff,%eax
  469538:	crc32  %r8,%rax
  46953e:	mov    %rax,-0x20(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1675
  469543:	vmovd  %eax,%xmm15
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1675
  469547:	jmp    46935c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x56c>
  46954c:	nopl   0x0(%rax)
  469550:	vzeroupper 
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:705
  469553:	lea    -0x28(%rbp),%rsp
  469557:	pop    %rbx
  469558:	pop    %r12
  46955a:	pop    %r13
  46955c:	pop    %r14
  46955e:	pop    %r15
  469560:	pop    %rbp
  469561:	ret    
  469562:	nopw   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469568:	vpcmpequq %zmm4,%zmm0,%k7{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:797
  46956f:	kortestb %k7,%k7
  469573:	jne    4696c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8d0>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469579:	mov    %r13,%rdx
  46957c:	crc32  %r15,%rdx
  469582:	vmovq  %rdx,%xmm7
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  469587:	mov    %edx,%r15d
  46958a:	vpinsrd $0x1,0xc(%r14),%xmm7,%xmm3
  469591:	and    (%rsp),%r15d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:808
  469595:	mov    (%r14),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  469598:	shl    $0x4,%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:809
  46959c:	add    $0x10,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  4695a0:	prefetcht2 (%rsi,%r15,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:809
  4695a5:	and    %r9,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1222
  4695a8:	mov    %r14,(%r12)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1223
  4695ac:	vmovq  %xmm3,0x8(%r12)
  4695b3:	jmp    469023 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x233>
  4695b8:	nopl   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4695c0:	vpcmpequq %zmm4,%zmm8,%k7{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:797
  4695c7:	kortestb %k7,%k7
  4695cb:	jne    4699de <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbee>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:808
  4695d1:	lea    (%r8,%rbx,1),%r12
  4695d5:	mov    %r12,-0x18(%rsp)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4695da:	mov    %r13,%r12
  4695dd:	crc32  %r15,%r12
  4695e3:	vmovq  %r12,%xmm10
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  4695e8:	mov    %r12d,%r15d
  4695eb:	vpinsrd $0x1,0xc(%r14),%xmm10,%xmm11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1222
  4695f2:	mov    -0x18(%rsp),%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:808
  4695f7:	mov    (%r14),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  4695fa:	and    (%rsp),%r15d
  4695fe:	shl    $0x4,%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:809
  469602:	add    $0x10,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  469606:	prefetcht2 (%rsi,%r15,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:809
  46960b:	and    %r9,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1222
  46960e:	mov    %r14,(%r12)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1223
  469612:	vmovq  %xmm11,0x8(%r12)
  469619:	jmp    468fa0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1b0>
  46961e:	xchg   %ax,%ax
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469620:	vpcmpequq %zmm4,%zmm0,%k7{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:797
  469627:	kortestb %k7,%k7
  46962b:	jne    4699bf <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbcf>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:808
  469631:	lea    (%r8,%rbx,1),%r12
  469635:	mov    %r12,-0x18(%rsp)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  46963a:	mov    %r13,%r12
  46963d:	crc32  %r15,%r12
  469643:	vmovq  %r12,%xmm7
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  469648:	mov    %r12d,%r15d
  46964b:	vpinsrd $0x1,0xc(%r14),%xmm7,%xmm3
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1222
  469652:	mov    -0x18(%rsp),%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:808
  469657:	mov    (%r14),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  46965a:	and    (%rsp),%r15d
  46965e:	shl    $0x4,%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:809
  469662:	add    $0x10,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  469666:	prefetcht2 (%rsi,%r15,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:809
  46966b:	and    %r9,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1222
  46966e:	mov    %r14,(%r12)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1223
  469672:	vmovq  %xmm3,0x8(%r12)
  469679:	jmp    468f23 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
  46967e:	xchg   %ax,%ax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:848
  469680:	mov    -0x30(%rsp),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:849
  469685:	mov    $0x1,%r15d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:848
  46968b:	sub    %rbx,%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:849
  46968e:	shr    $0x2,%r14
  469692:	shlx   %r14d,%r15d,%r14d
  469697:	lea    -0x1(%r14),%r15d
_Z24_mm512_mask_storeu_epi32PvtDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6461
  46969b:	kmovw  %r15d,%k7
  4696a0:	vmovdqu32 %zmm13,(%r12){%k7}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:851
  4696a7:	sub    -0x30(%rsp),%rbx
  4696ac:	neg    %r14d
_Z24_mm512_mask_storeu_epi32PvtDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6461
  4696af:	kmovw  %r14d,%k6
  4696b4:	vmovdqu32 %zmm13,(%r8,%rbx,1){%k6}
  4696bb:	jmp    469174 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x384>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:798
  4696c0:	incl   -0x3c(%rsp)
  4696c4:	mov    -0x18(%rsp),%rdx
  4696c9:	nopl   0x0(%rax)
_Z9_pdep_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmi2intrin.h:48
  4696d0:	mov    $0x55,%r15d
  4696d6:	pdep   %r15d,%r11d,%r14d
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  4696db:	mov    -0x10(%rsp),%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:819
  4696e0:	lea    (%r14,%r14,2),%r14d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:820
  4696e4:	popcnt %r11d,%r11d
  4696e9:	shl    $0x4,%r11
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  4696ed:	kmovb  %r14d,%k7
  4696f2:	vpcompressq %zmm12,(%r15){%k7}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:820
  4696f8:	add    %r11,%r15
  4696fb:	mov    %r15,-0x10(%rsp)
  469700:	jmp    4690c7 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2d7>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1076
  469705:	cmp    -0x28(%rsp),%rdx
  46970a:	je     469553 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x763>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1665
  469710:	mov    0x88(%rcx),%r11
  469717:	mov    0x60(%rcx),%r9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46971b:	mov    $0x55,%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1665
  469721:	dec    %r11
  469724:	mov    %r9,(%rsp)
  469728:	mov    %r11,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  46972d:	mov    0x294b4(%rip),%r15        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1416
  469734:	mov    0x293cd(%rip),%r14        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  46973b:	mov    0xa0(%rcx),%rbx
  469742:	mov    %r10d,%r12d
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469745:	vpxor  %xmm2,%xmm2,%xmm2
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1414
  469749:	kmovb  0x293af(%rip),%k2        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469751:	kmovb  %r13d,%k1
  469756:	jmp    4697c2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9d2>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  469758:	cmpq   $0x8,(%rsp)
  46975d:	je     46996c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb7c>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1675
  469763:	vmovd  -0x10(%rsp),%xmm4
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1665
  469769:	mov    -0x8(%rsp),%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1675
  46976e:	mov    %r10d,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1665
  469771:	and    -0x10(%rsp),%r13
  469776:	vpinsrd $0x1,0xc(%rdx),%xmm4,%xmm6
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1675
  46977d:	mov    (%rdx),%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1668
  469780:	and    $0xfffffffffffffffc,%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1675
  469784:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1693
  469788:	lea    0x1(%r10),%r12d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1675
  46978c:	add    %rbx,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1456
  46978f:	shl    $0x4,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1694
  469793:	and    %r8d,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1076
  469796:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1456
  46979a:	prefetcht2 (%r15,%r13,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1222
  46979f:	mov    %r11,(%rsi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1223
  4697a2:	vmovq  %xmm6,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1694
  4697a7:	mov    %r12d,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1076
  4697ae:	cmp    %rdx,-0x28(%rsp)
  4697b3:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x760>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17get_find_queue_szEv():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:525
  4697b9:	mov    0xb4(%rcx),%eax
  4697bf:	mov    %r12d,%r10d
  4697c2:	sub    %eax,%r12d
  4697c5:	and    %r8d,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1077
  4697c8:	cmp    %r12d,%r8d
  4697cb:	jbe    4697f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa04>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4697cd:	cmpq   $0x4,(%rsp)
  4697d2:	jne    469758 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x968>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4697d4:	mov    $0xffffffff,%r12d
  4697da:	crc32l (%rdx),%r12d
  4697e0:	vmovd  %r12d,%xmm5
  4697e5:	vmovdqa %xmm5,%xmm4
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  4697e9:	vmovq  %xmm5,-0x10(%rsp)
  4697ef:	jmp    469769 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x979>
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1206
  4697f4:	mov    0x80(%rcx),%r12
  4697fb:	mov    %r12,-0x20(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  469800:	lea    0x18(%rax),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  469803:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1211
  469806:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  46980a:	mov    %r12d,%r9d
  46980d:	and    0x8(%rbx,%rsi,1),%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  469812:	mov    %eax,%esi
  469814:	shl    $0x4,%rsi
  469818:	add    %rbx,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1398
  46981b:	mov    (%rsi),%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  46981e:	shl    $0x4,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:620
  469822:	prefetcht0 (%r15,%r9,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1398
  469827:	cmp    0x90(%rcx),%r11
  46982e:	jne    469870 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa80>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1414
  469830:	kortestb %k2,%k2
  469834:	je     469856 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa66>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1415
  469836:	mov    (%rdi),%r13d
  469839:	mov    0xc(%rsi),%esi
  46983c:	mov    %r13,%r11
  46983f:	shl    $0x4,%r13
  469843:	add    0x8(%rdi),%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1417
  469847:	lea    0x1(%r11),%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1415
  46984b:	mov    %esi,0x0(%r13)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1416
  46984f:	mov    %r14,0x8(%r13)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1417
  469853:	mov    %r9d,(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469856:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469858:	and    %r8d,%eax
  46985b:	mov    %eax,0xb4(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:626
  469861:	test   %r14,%r14
  469864:	jne    469800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa10>
  469866:	jmp    4697cd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9dd>
  46986b:	nopl   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1211
  469870:	mov    0x8(%rsi),%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1261
  469874:	mov    %r12d,%r9d
  469877:	and    %r13d,%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1263
  46987a:	shl    $0x4,%r9
  46987e:	add    %r15,%r9
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469881:	vmovdqa64 (%r9),%zmm0
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  469887:	vpbroadcastq %r11,%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46988d:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1267
  469894:	kortestb %k0,%k0
  469898:	jne    469917 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb27>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46989a:	vpcmpequq %zmm2,%zmm0,%k3{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1275
  4698a1:	kortestb %k3,%k3
  4698a5:	jne    46995c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb6c>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4698ab:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1277
  4698b0:	mov    %r13d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4698b3:	je     469985 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb95>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  4698b9:	cmpq   $0x8,(%rsp)
  4698be:	je     4699a6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbb6>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  4698c4:	mov    -0x18(%rsp),%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1279
  4698c9:	mov    -0x20(%rsp),%r13
  4698ce:	vmovd  %r9d,%xmm7
  4698d3:	vpinsrd $0x1,0xc(%rsi),%xmm7,%xmm3
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  4698da:	mov    %r10d,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1279
  4698dd:	and    -0x18(%rsp),%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  4698e2:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1286
  4698e6:	inc    %r10d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  4698e9:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  4698eb:	add    %rbx,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1456
  4698ee:	shl    $0x4,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1287
  4698f2:	and    %r8d,%r10d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4698f5:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1456
  4698f8:	prefetcht2 (%r15,%r13,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1222
  4698fd:	mov    %r11,(%rsi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1223
  469900:	vmovq  %xmm3,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1287
  469905:	mov    %r10d,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46990c:	mov    %eax,0xb4(%rcx)
  469912:	jmp    469800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa10>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1268
  469917:	mov    (%rdi),%r11d
  46991a:	mov    0xc(%rsi),%r13d
  46991e:	mov    %r11,%r12
  469921:	shl    $0x4,%r11
  469925:	add    0x8(%rdi),%r11
  469929:	mov    %r13d,(%r11)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  46992c:	xor    %r13d,%r13d
  46992f:	kmovb  %k0,%esi
  469933:	tzcnt  %esi,%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1269
  469938:	inc    %r13d
  46993b:	movslq %r13d,%rsi
  46993e:	mov    (%r9,%rsi,8),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469942:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1270
  469944:	inc    %r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469947:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1269
  46994a:	mov    %r9,0x8(%r11)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1270
  46994e:	mov    %r12d,(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469951:	mov    %eax,0xb4(%rcx)
  469957:	jmp    4697cd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9dd>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46995c:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46995e:	and    %r8d,%eax
  469961:	mov    %eax,0xb4(%rcx)
  469967:	jmp    4697cd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9dd>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  46996c:	mov    $0xffffffff,%eax
  469971:	crc32q (%rdx),%rax
  469977:	mov    %rax,-0x10(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1675
  46997c:	vmovd  %eax,%xmm4
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1675
  469980:	jmp    469769 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x979>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469985:	mov    $0xffffffff,%r9d
  46998b:	crc32  %r13d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  469991:	mov    %r9d,%r13d
  469994:	mov    %r13,-0x18(%rsp)
  469999:	jmp    4698c9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad9>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:776
  46999e:	xor    %r12d,%r12d
  4699a1:	jmp    46923d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x44d>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4699a6:	mov    $0xffffffff,%r13d
  4699ac:	crc32  %r9,%r13
  4699b2:	mov    %r13,-0x18(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  4699b7:	mov    %r13d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  4699ba:	jmp    4698c9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad9>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:798
  4699bf:	incl   -0x3c(%rsp)
  4699c3:	jmp    468fa0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1b0>
  4699c8:	incl   -0x3c(%rsp)
  4699cc:	vpxor  %xmm15,%xmm15,%xmm15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:779
  4699d1:	xor    %r11d,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:778
  4699d4:	vpxor  %xmm12,%xmm12,%xmm12
  4699d9:	jmp    468f23 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x133>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:798
  4699de:	incl   -0x3c(%rsp)
  4699e2:	mov    %rdx,-0x18(%rsp)
  4699e7:	jmp    469023 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x233>
