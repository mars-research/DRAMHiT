
/opt/DRAMHiT/scripts/eurosys_2026/optimize_hbm/attempt11/s_p2/dramhit:     file format elf64-x86-64


Disassembly of section .text:

0000000000468dd0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:703
  468dd0:	push   %rbp
  468dd1:	mov    %rdi,%rcx
  468dd4:	mov    %rdx,%r8
  468dd7:	mov    %rsp,%rbp
  468dda:	push   %r15
  468ddc:	push   %r14
  468dde:	push   %r13
  468de0:	push   %r12
  468de2:	push   %rbx
  468de3:	and    $0xffffffffffffffc0,%rsp
  468de7:	sub    $0x8,%rsp
  468deb:	mov    0x8(%rsi),%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468def:	mov    0xb0(%rdi),%edi
  468df5:	mov    0xb4(%rcx),%eax
  468dfb:	mov    (%rsi),%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:718
  468dfe:	mov    0x78(%rcx),%r9d
  468e02:	mov    0x6c(%rcx),%r10d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:869
  468e06:	mov    %r11,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e09:	mov    %edi,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:869
  468e0b:	shl    $0x4,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e0f:	sub    %eax,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:869
  468e11:	add    %rdx,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e14:	and    %r9d,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:718
  468e17:	lea    -0x1(%r10),%r12d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:869
  468e1b:	mov    %rbx,-0x20(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:720
  468e20:	cmp    %r12d,%esi
  468e23:	jb     4696e3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x913>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:784
  468e29:	and    $0xfffffffffffffffc,%r11
  468e2d:	shl    $0x4,%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:732
  468e31:	mov    0x8(%r8),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:736
  468e35:	mov    0x80(%rcx),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468e3b:	shl    $0x4,%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:729
  468e3f:	mov    %edi,%ebx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:784
  468e41:	lea    (%rdx,%r11,1),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468e45:	mov    %r10,-0x28(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:732
  468e4a:	mov    %r15,(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:784
  468e4e:	mov    %r11,-0x40(%rsp)
  468e53:	mov    %r14,-0x30(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:731
  468e58:	movl   $0x0,-0x34(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:726
  468e60:	mov    0xa0(%rcx),%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:752
  468e67:	mov    0x29d7a(%rip),%rdi        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468e6e:	dec    %r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:728
  468e71:	shl    $0x4,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:729
  468e75:	shl    $0x4,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:736
  468e79:	not    %esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  468e7b:	cmp    %r14,%rdx
  468e7e:	je     46997b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbab>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468e84:	mov    $0x55,%r13d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468e8a:	mov    $0xf,%r11d
  468e90:	mov    $0xf0,%r12d
  468e96:	mov    $0xf00,%r15d
  468e9c:	mov    $0xfffff000,%r14d
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468ea2:	kmovb  %r13d,%k1
  468ea7:	vpxor  %xmm4,%xmm4,%xmm4
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468eab:	mov    $0xffffffff,%r13d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468eb1:	kmovw  %r11d,%k5
  468eb6:	kmovw  %r12d,%k4
  468ebb:	kmovw  %r15d,%k3
  468ec0:	kmovw  %r14d,%k2
  468ec5:	jmp    46915c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x38c>
  468eca:	nopw   0x0(%rax,%rax,1)
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468ed0:	vmovd  0xc(%r12),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468ed7:	kshiftlb $0x1,%k6,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468edd:	vpcompressq %zmm8,%zmm12{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468ee3:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468ee8:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k5}{z}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468eef:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:803
  468ef5:	mov    $0x1,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  468efb:	lea    0x180(%rax),%r15
  468f02:	and    %r10,%r15
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  468f05:	andn   0x8(%r9,%r15,1),%esi,%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  468f0c:	mov    %r14d,%r12d
  468f0f:	shl    $0x4,%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:793
  468f13:	lea    (%r9,%rax,1),%r14
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  468f17:	mov    0x8(%r14),%r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  468f1b:	prefetcht0 (%rdi,%r12,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  468f20:	andn   %r15d,%esi,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468f25:	mov    %r12d,%r12d
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468f28:	shl    $0x4,%r12
  468f2c:	vmovdqa64 (%rdi,%r12,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:755
  468f33:	vpbroadcastq (%r14),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468f39:	vpcmpequq %zmm2,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  468f40:	add    $0x10,%rax
  468f44:	and    %r10,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:797
  468f47:	kortestb %k0,%k0
  468f4b:	je     469600 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x830>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468f51:	vmovd  0xc(%r14),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468f57:	kshiftlb $0x1,%k0,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468f5d:	vpcompressq %zmm0,%zmm5{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468f63:	vpunpcklqdq %xmm5,%xmm1,%xmm6
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468f67:	vshufi32x4 $0x0,%zmm6,%zmm6,%zmm15{%k4}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468f6e:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:803
  468f74:	or     $0x2,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  468f78:	lea    0x180(%rax),%r14
  468f7f:	and    %r10,%r14
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  468f82:	andn   0x8(%r9,%r14,1),%esi,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  468f89:	mov    %r12d,%r15d
  468f8c:	shl    $0x4,%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:793
  468f90:	lea    (%r9,%rax,1),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  468f94:	prefetcht0 (%rdi,%r15,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  468f99:	mov    0x8(%r14),%r15d
  468f9d:	andn   %r15d,%esi,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468fa2:	mov    %r12d,%r12d
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468fa5:	shl    $0x4,%r12
  468fa9:	vmovdqa64 (%rdi,%r12,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:755
  468fb0:	vpbroadcastq (%r14),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468fb6:	vpcmpequq %zmm9,%zmm8,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  468fbd:	add    $0x10,%rax
  468fc1:	and    %r10,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:797
  468fc4:	kortestb %k0,%k0
  468fc8:	je     4695a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7d0>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468fce:	vmovd  0xc(%r14),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468fd4:	kshiftlb $0x1,%k0,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468fda:	vpcompressq %zmm8,%zmm12{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468fe0:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:803
  468fe5:	mov    %rdx,-0x10(%rsp)
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468fea:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k3}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468ff1:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:803
  468ff7:	or     $0x4,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  468ffb:	lea    0x180(%rax),%rdx
  469002:	and    %r10,%rdx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  469005:	andn   0x8(%r9,%rdx,1),%esi,%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  46900c:	mov    %r14d,%r12d
  46900f:	shl    $0x4,%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:793
  469013:	lea    (%r9,%rax,1),%r14
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  469017:	mov    0x8(%r14),%r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  46901b:	prefetcht0 (%rdi,%r12,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  469020:	andn   %r15d,%esi,%edx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  469025:	mov    %edx,%r12d
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469028:	shl    $0x4,%r12
  46902c:	vmovdqa64 (%rdi,%r12,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:755
  469033:	vpbroadcastq (%r14),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469039:	vpcmpequq %zmm2,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  469040:	add    $0x10,%rax
  469044:	and    %r10,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:852
  469047:	lea    (%r9,%rbx,1),%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:797
  46904b:	kortestb %k0,%k0
  46904f:	je     469548 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x778>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469055:	vmovd  0xc(%r14),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  46905b:	kshiftlb $0x1,%k0,%k6
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  469061:	vpcompressq %zmm0,%zmm5{%k6}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  469067:	vpunpcklqdq %xmm5,%xmm1,%xmm6
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  46906b:	vshufi32x4 $0x0,%zmm6,%zmm6,%zmm15{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:803
  469072:	or     $0x8,%r11d
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  469076:	mov    -0x10(%rsp),%rdx
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  46907b:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:824
  469081:	cmp    $0xf,%r11d
  469085:	jne    4696b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8e0>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  46908b:	mov    (%rsp),%r14
  46908f:	vmovdqu64 %zmm15,(%r14)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:826
  469095:	add    $0x40,%r14
  469099:	mov    %r14,(%rsp)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  46909d:	mov    %r13,%r15
  4690a0:	mov    %r13,%r14
  4690a3:	crc32q (%rdx),%r15
  4690a9:	crc32q 0x20(%rdx),%r14
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  4690b0:	andn   %r15d,%esi,%r11d
  4690b5:	shl    $0x4,%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:837
  4690b9:	prefetcht2 (%rdi,%r11,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690be:	mov    %r13,%r11
  4690c1:	crc32q 0x10(%rdx),%r11
  4690c8:	vmovq  %r15,%xmm15
  4690cd:	vmovq  %r14,%xmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  4690d2:	andn   %r11d,%esi,%r15d
  4690d7:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:837
  4690db:	prefetcht2 (%rdi,%r15,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  4690e0:	mov    %r14d,%r15d
  4690e3:	andn   %r15d,%esi,%r14d
  4690e8:	shl    $0x4,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:837
  4690ec:	prefetcht2 (%rdi,%r14,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690f1:	mov    %r13,%r14
  4690f4:	crc32q 0x30(%rdx),%r14
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  4690fb:	vpinsrd $0x1,%r11d,%xmm15,%xmm10
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  469101:	vmovdqu32 (%rdx),%zmm13
  469107:	mov    $0x4444,%r11d
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46910d:	vpinsrd $0x1,%r14d,%xmm8,%xmm9
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  469113:	kmovw  %r11d,%k6
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469118:	vpunpcklqdq %xmm9,%xmm10,%xmm11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:851
  46911d:	lea    0x40(%rbx),%r11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  469121:	andn   %r14d,%esi,%r15d
  469126:	shl    $0x4,%r15
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  46912a:	vpexpandd %zmm11,%zmm13{%k6}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:837
  469130:	prefetcht2 (%rdi,%r15,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:851
  469135:	cmp    %r11,-0x28(%rsp)
  46913a:	jb     469660 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x890>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  469140:	vmovdqu64 %zmm13,(%r12)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:862
  469147:	mov    %r11,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  46914a:	add    $0x40,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:862
  46914e:	and    %r10,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  469151:	cmp    %rdx,-0x30(%rsp)
  469156:	je     469210 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x440>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  46915c:	lea    0x180(%rax),%r11
  469163:	and    %r10,%r11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  469166:	andn   0x8(%r9,%r11,1),%esi,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  46916d:	mov    %r12d,%r15d
  469170:	shl    $0x4,%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:793
  469174:	lea    (%r9,%rax,1),%r12
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  469178:	mov    0x8(%r12),%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  46917d:	prefetcht0 (%rdi,%r15,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  469182:	andn   %r14d,%esi,%r11d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  469187:	mov    %r11d,%r15d
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  46918a:	shl    $0x4,%r15
  46918e:	vmovdqa64 (%rdi,%r15,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:755
  469195:	vpbroadcastq (%r12),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46919c:	vpcmpequq %zmm9,%zmm8,%k6{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  4691a3:	add    $0x10,%rax
  4691a7:	and    %r10,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:797
  4691aa:	kortestb %k6,%k6
  4691ae:	jne    468ed0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x100>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4691b4:	vpcmpequq %zmm4,%zmm8,%k7{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:806
  4691bb:	kortestb %k7,%k7
  4691bf:	jne    4699a5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbd5>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4691c5:	mov    %r13,%r15
  4691c8:	crc32  %r14,%r15
  4691ce:	vmovd  %r15d,%xmm10
  4691d3:	vpinsrd $0x1,0xc(%r12),%xmm10,%xmm11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:817
  4691db:	mov    (%r12),%r12
  4691df:	lea    (%r9,%rbx,1),%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  4691e3:	add    $0x10,%rbx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  4691e7:	andn   %r15d,%esi,%r14d
  4691ec:	shl    $0x4,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  4691f0:	and    %r10,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  4691f3:	prefetcht2 (%rdi,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1231
  4691f8:	mov    %r12,(%r11)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1232
  4691fb:	vmovq  %xmm11,0x8(%r11)
  469201:	jmp    46915c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x38c>
  469206:	cs nopw 0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:867
  469210:	mov    -0x34(%rsp),%r12d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:865
  469215:	vmovq  %rbx,%xmm14
  46921a:	vpinsrq $0x1,%rax,%xmm14,%xmm0
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:867
  469220:	mov    -0x40(%rsp),%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:865
  469225:	vpsrlq $0x4,%xmm0,%xmm2
  46922a:	vpmovqd %xmm2,%xmm7
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:867
  469230:	sar    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:865
  469234:	vmovq  %xmm7,0xb0(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:867
  46923c:	sub    %r12,%rsi
  46923f:	add    %esi,(%r8)
  469242:	vpextrd $0x1,%xmm7,%eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:869
  469248:	cmp    -0x20(%rsp),%rdx
  46924d:	je     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x760>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1674
  469253:	mov    0x88(%rcx),%r15
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1215
  46925a:	mov    0x80(%rcx),%r12
  469261:	mov    0x60(%rcx),%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1674
  469265:	dec    %r15
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1215
  469268:	mov    %r12,-0x10(%rsp)
  46926d:	mov    %rdi,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1674
  469271:	mov    %r15,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  469276:	mov    0x78(%rcx),%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  46927a:	mov    0x29967(%rip),%rbx        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469281:	mov    0xa0(%rcx),%r10
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1423
  469288:	movzbl 0x29870(%rip),%r14d        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1425
  469290:	mov    0x29871(%rip),%r13        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469297:	mov    $0x55,%r9d
  46929d:	vpxor  %xmm3,%xmm3,%xmm3
  4692a1:	kmovb  %r9d,%k1
  4692a6:	cs nopw 0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  4692b0:	lea    0x18(%rax),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692b3:	and    %r11d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1220
  4692b6:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692ba:	mov    %r12d,%edi
  4692bd:	and    0x8(%r10,%rsi,1),%edi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  4692c2:	mov    %eax,%esi
  4692c4:	shl    $0x4,%rsi
  4692c8:	add    %r10,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1407
  4692cb:	mov    (%rsi),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692ce:	shl    $0x4,%rdi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:620
  4692d2:	prefetcht0 (%rbx,%rdi,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1407
  4692d6:	cmp    0x90(%rcx),%r9
  4692dd:	jne    4693a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5d0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1423
  4692e3:	test   %r14b,%r14b
  4692e6:	je     469306 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x536>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1424
  4692e8:	mov    (%r8),%r15d
  4692eb:	mov    0xc(%rsi),%esi
  4692ee:	mov    %r15,%r9
  4692f1:	shl    $0x4,%r15
  4692f5:	add    0x8(%r8),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1426
  4692f9:	inc    %r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1424
  4692fc:	mov    %esi,(%r15)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1425
  4692ff:	mov    %r13,0x8(%r15)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1426
  469303:	mov    %r9d,(%r8)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469306:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469308:	and    %r11d,%eax
  46930b:	mov    %eax,0xb4(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:626
  469311:	test   %r13,%r13
  469314:	jne    4692b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4e0>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  469316:	cmpq   $0x4,(%rsp)
  46931b:	je     469495 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c5>
  469321:	nopl   0x0(%rax)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  469328:	cmpq   $0x8,(%rsp)
  46932d:	je     469510 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x740>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1684
  469333:	vmovd  -0x18(%rsp),%xmm15
  469339:	mov    (%rdx),%rdi
  46933c:	mov    0xb0(%rcx),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1674
  469342:	mov    -0x28(%rsp),%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1684
  469347:	mov    %rsi,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1674
  46934a:	and    -0x18(%rsp),%r9
  46934f:	vpinsrd $0x1,0xc(%rdx),%xmm15,%xmm9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1677
  469356:	and    $0xfffffffffffffffc,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1684
  46935a:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1702
  46935e:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1684
  469360:	add    %r10,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1465
  469363:	shl    $0x4,%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1703
  469367:	and    %r11d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:869
  46936a:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1465
  46936e:	prefetcht2 (%rbx,%r9,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1231
  469373:	mov    %rdi,(%rsi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1232
  469376:	vmovq  %xmm9,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1703
  46937b:	mov    %eax,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:869
  469381:	cmp    -0x20(%rsp),%rdx
  469386:	je     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x760>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  46938c:	mov    0xb4(%rcx),%eax
  469392:	jmp    4692b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4e0>
  469397:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1220
  4693a0:	mov    0x8(%rsi),%r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1270
  4693a4:	mov    %r12d,%edi
  4693a7:	and    %r15d,%edi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1272
  4693aa:	shl    $0x4,%rdi
  4693ae:	add    %rbx,%rdi
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4693b1:	vmovdqa64 (%rdi),%zmm5
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  4693b7:	vpbroadcastq %r9,%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4693bd:	vpcmpequq %zmm1,%zmm5,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1276
  4693c4:	kortestb %k0,%k0
  4693c8:	jne    469450 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x680>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4693ce:	vpcmpequq %zmm3,%zmm5,%k2{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1284
  4693d5:	kortestb %k2,%k2
  4693d9:	jne    4694c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6f0>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4693df:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1286
  4693e4:	mov    %r15d,%edi
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4693e7:	je     4694d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  4693ed:	cmpq   $0x8,(%rsp)
  4693f2:	je     4694f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1294
  4693f8:	vmovd  -0x8(%rsp),%xmm6
  4693fe:	mov    0xb0(%rcx),%edi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1288
  469404:	mov    -0x10(%rsp),%r15
  469409:	vpinsrd $0x1,0xc(%rsi),%xmm6,%xmm4
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1294
  469410:	mov    %rdi,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1288
  469413:	and    -0x8(%rsp),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1294
  469418:	shl    $0x4,%rdi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1295
  46941c:	inc    %esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46941e:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1294
  469420:	add    %r10,%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1465
  469423:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1296
  469427:	and    %r11d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46942a:	and    %r11d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1465
  46942d:	prefetcht2 (%rbx,%r15,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1231
  469432:	mov    %r9,(%rdi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1232
  469435:	vmovq  %xmm4,0x8(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1296
  46943a:	mov    %esi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469440:	mov    %eax,0xb4(%rcx)
  469446:	jmp    4692b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4e0>
  46944b:	nopl   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1277
  469450:	mov    (%r8),%r9d
  469453:	mov    0xc(%rsi),%esi
  469456:	mov    %r9,%r15
  469459:	shl    $0x4,%r9
  46945d:	add    0x8(%r8),%r9
  469461:	mov    %esi,(%r9)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469464:	kmovb  %k0,%esi
  469468:	tzcnt  %esi,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1278
  46946c:	inc    %esi
  46946e:	movslq %esi,%rsi
  469471:	mov    (%rdi,%rsi,8),%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469475:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1279
  469477:	inc    %r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46947a:	and    %r11d,%eax
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46947d:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1278
  469482:	mov    %rdi,0x8(%r9)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1279
  469486:	mov    %r15d,(%r8)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469489:	mov    %eax,0xb4(%rcx)
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46948f:	jne    469328 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x558>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469495:	mov    $0xffffffff,%r15d
  46949b:	crc32l (%rdx),%r15d
  4694a1:	vmovd  %r15d,%xmm8
  4694a6:	mov    (%rdx),%rdi
  4694a9:	vmovdqa %xmm8,%xmm15
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  4694ae:	vmovq  %xmm8,-0x18(%rsp)
  4694b4:	jmp    46933c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x56c>
  4694b9:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  4694c0:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4694c2:	and    %r11d,%eax
  4694c5:	mov    %eax,0xb4(%rcx)
  4694cb:	jmp    469316 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x546>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4694d0:	mov    $0xffffffff,%edi
  4694d5:	crc32  %r15d,%edi
  4694db:	vmovd  %edi,%xmm12
  4694df:	vmovdqa %xmm12,%xmm6
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  4694e3:	vmovq  %xmm12,-0x8(%rsp)
  4694e9:	jmp    4693fe <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x62e>
  4694ee:	xchg   %ax,%ax
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4694f0:	mov    $0xffffffff,%r15d
  4694f6:	crc32  %rdi,%r15
  4694fc:	mov    %r15,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1294
  469501:	vmovd  %r15d,%xmm6
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1294
  469506:	jmp    4693fe <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x62e>
  46950b:	nopl   0x0(%rax,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469510:	mov    (%rdx),%rdi
  469513:	mov    $0xffffffff,%eax
  469518:	crc32  %rdi,%rax
  46951e:	mov    %rax,-0x18(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1684
  469523:	vmovd  %eax,%xmm15
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1684
  469527:	jmp    46933c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x56c>
  46952c:	nopl   0x0(%rax)
  469530:	vzeroupper 
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:705
  469533:	lea    -0x28(%rbp),%rsp
  469537:	pop    %rbx
  469538:	pop    %r12
  46953a:	pop    %r13
  46953c:	pop    %r14
  46953e:	pop    %r15
  469540:	pop    %rbp
  469541:	ret    
  469542:	nopw   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469548:	vpcmpequq %zmm4,%zmm0,%k7{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:806
  46954f:	kortestb %k7,%k7
  469553:	jne    4696a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8d0>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469559:	mov    %r13,%rdx
  46955c:	crc32  %r15,%rdx
  469562:	vmovq  %rdx,%xmm7
  469567:	vpinsrd $0x1,0xc(%r14),%xmm7,%xmm3
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:817
  46956e:	mov    (%r14),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  469571:	add    $0x10,%rbx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  469575:	andn   %edx,%esi,%r15d
  46957a:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  46957e:	and    %r10,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  469581:	prefetcht2 (%rdi,%r15,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1231
  469586:	mov    %r14,(%r12)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1232
  46958a:	vmovq  %xmm3,0x8(%r12)
  469591:	jmp    468ffb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x22b>
  469596:	cs nopw 0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4695a0:	vpcmpequq %zmm4,%zmm8,%k7{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:806
  4695a7:	kortestb %k7,%k7
  4695ab:	jne    4699bb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbeb>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:817
  4695b1:	lea    (%r9,%rbx,1),%r12
  4695b5:	mov    %r12,-0x10(%rsp)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4695ba:	mov    %r13,%r12
  4695bd:	crc32  %r15,%r12
  4695c3:	vmovq  %r12,%xmm10
  4695c8:	vpinsrd $0x1,0xc(%r14),%xmm10,%xmm11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  4695cf:	andn   %r12d,%esi,%r15d
  4695d4:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:817
  4695d8:	mov    (%r14),%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1231
  4695db:	mov    -0x10(%rsp),%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  4695e0:	add    $0x10,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  4695e4:	prefetcht2 (%rdi,%r15,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  4695e9:	and    %r10,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1231
  4695ec:	mov    %r14,(%r12)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1232
  4695f0:	vmovq  %xmm11,0x8(%r12)
  4695f7:	jmp    468f78 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a8>
  4695fc:	nopl   0x0(%rax)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469600:	vpcmpequq %zmm4,%zmm0,%k7{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:806
  469607:	kortestb %k7,%k7
  46960b:	jne    46999c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbcc>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:817
  469611:	lea    (%r9,%rbx,1),%r12
  469615:	mov    %r12,-0x10(%rsp)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  46961a:	mov    %r13,%r12
  46961d:	crc32  %r15,%r12
  469623:	vmovq  %r12,%xmm7
  469628:	vpinsrd $0x1,0xc(%r14),%xmm7,%xmm3
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  46962f:	andn   %r12d,%esi,%r15d
  469634:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:817
  469638:	mov    (%r14),%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1231
  46963b:	mov    -0x10(%rsp),%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  469640:	add    $0x10,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  469644:	prefetcht2 (%rdi,%r15,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  469649:	and    %r10,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1231
  46964c:	mov    %r14,(%r12)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1232
  469650:	vmovq  %xmm3,0x8(%r12)
  469657:	jmp    468efb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x12b>
  46965c:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:857
  469660:	mov    -0x28(%rsp),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:858
  469665:	mov    $0x1,%r15d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:857
  46966b:	sub    %rbx,%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:858
  46966e:	shr    $0x2,%r14
  469672:	shlx   %r14d,%r15d,%r14d
  469677:	lea    -0x1(%r14),%r15d
_Z24_mm512_mask_storeu_epi32PvtDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6461
  46967b:	kmovw  %r15d,%k7
  469680:	vmovdqu32 %zmm13,(%r12){%k7}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:860
  469687:	sub    -0x28(%rsp),%rbx
  46968c:	neg    %r14d
_Z24_mm512_mask_storeu_epi32PvtDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6461
  46968f:	kmovw  %r14d,%k6
  469694:	vmovdqu32 %zmm13,(%r9,%rbx,1){%k6}
  46969b:	jmp    469147 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x377>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  4696a0:	incl   -0x34(%rsp)
  4696a4:	mov    -0x10(%rsp),%rdx
  4696a9:	nopl   0x0(%rax)
_Z9_pdep_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmi2intrin.h:48
  4696b0:	mov    $0x55,%r15d
  4696b6:	pdep   %r15d,%r11d,%r14d
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  4696bb:	mov    (%rsp),%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:828
  4696bf:	lea    (%r14,%r14,2),%r14d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:829
  4696c3:	popcnt %r11d,%r11d
  4696c8:	shl    $0x4,%r11
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  4696cc:	kmovb  %r14d,%k7
  4696d1:	vpcompressq %zmm12,(%r15){%k7}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:829
  4696d7:	add    %r11,%r15
  4696da:	mov    %r15,(%rsp)
  4696de:	jmp    46909d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2cd>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1085
  4696e3:	cmp    -0x20(%rsp),%rdx
  4696e8:	je     469533 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x763>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1674
  4696ee:	mov    0x88(%rcx),%r11
  4696f5:	mov    0x60(%rcx),%r10
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4696f9:	mov    $0x55,%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1674
  4696ff:	dec    %r11
  469702:	mov    %r10,(%rsp)
  469706:	mov    %r11,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  46970b:	mov    0x294d6(%rip),%r15        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1425
  469712:	mov    0x293ef(%rip),%r14        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469719:	mov    0xa0(%rcx),%rbx
  469720:	mov    %edi,%r12d
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469723:	vpxor  %xmm2,%xmm2,%xmm2
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1423
  469727:	kmovb  0x293d1(%rip),%k2        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46972f:	kmovb  %r13d,%k1
  469734:	jmp    46979f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9cf>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  469736:	cmpq   $0x8,(%rsp)
  46973b:	je     469949 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb79>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1684
  469741:	vmovd  -0x10(%rsp),%xmm4
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1674
  469747:	mov    -0x8(%rsp),%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1684
  46974c:	mov    %edi,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1674
  46974e:	and    -0x10(%rsp),%r13
  469753:	vpinsrd $0x1,0xc(%rdx),%xmm4,%xmm6
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1684
  46975a:	mov    (%rdx),%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1677
  46975d:	and    $0xfffffffffffffffc,%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1684
  469761:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1702
  469765:	lea    0x1(%rdi),%r12d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1684
  469769:	add    %rbx,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1465
  46976c:	shl    $0x4,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1703
  469770:	and    %r9d,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1085
  469773:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1465
  469777:	prefetcht2 (%r15,%r13,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1231
  46977c:	mov    %r11,(%rsi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1232
  46977f:	vmovq  %xmm6,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1703
  469784:	mov    %r12d,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1085
  46978b:	cmp    %rdx,-0x20(%rsp)
  469790:	je     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x760>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17get_find_queue_szEv():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:525
  469796:	mov    0xb4(%rcx),%eax
  46979c:	mov    %r12d,%edi
  46979f:	sub    %eax,%r12d
  4697a2:	and    %r9d,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1086
  4697a5:	cmp    %r12d,%r9d
  4697a8:	jbe    4697d1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa01>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4697aa:	cmpq   $0x4,(%rsp)
  4697af:	jne    469736 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x966>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4697b1:	mov    $0xffffffff,%r12d
  4697b7:	crc32l (%rdx),%r12d
  4697bd:	vmovd  %r12d,%xmm5
  4697c2:	vmovdqa %xmm5,%xmm4
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  4697c6:	vmovq  %xmm5,-0x10(%rsp)
  4697cc:	jmp    469747 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x977>
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1215
  4697d1:	mov    0x80(%rcx),%r12
  4697d8:	mov    %r12,-0x18(%rsp)
  4697dd:	nopl   (%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  4697e0:	lea    0x18(%rax),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4697e3:	and    %r9d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1220
  4697e6:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4697ea:	mov    %r12d,%r10d
  4697ed:	and    0x8(%rbx,%rsi,1),%r10d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  4697f2:	mov    %eax,%esi
  4697f4:	shl    $0x4,%rsi
  4697f8:	add    %rbx,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1407
  4697fb:	mov    (%rsi),%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4697fe:	shl    $0x4,%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:620
  469802:	prefetcht0 (%r15,%r10,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1407
  469807:	cmp    0x90(%rcx),%r11
  46980e:	jne    469850 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa80>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1423
  469810:	kortestb %k2,%k2
  469814:	je     469836 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa66>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1424
  469816:	mov    (%r8),%r13d
  469819:	mov    0xc(%rsi),%esi
  46981c:	mov    %r13,%r11
  46981f:	shl    $0x4,%r13
  469823:	add    0x8(%r8),%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1426
  469827:	lea    0x1(%r11),%r10d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1424
  46982b:	mov    %esi,0x0(%r13)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1425
  46982f:	mov    %r14,0x8(%r13)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1426
  469833:	mov    %r10d,(%r8)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469836:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469838:	and    %r9d,%eax
  46983b:	mov    %eax,0xb4(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:626
  469841:	test   %r14,%r14
  469844:	jne    4697e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa10>
  469846:	jmp    4697aa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9da>
  46984b:	nopl   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1220
  469850:	mov    0x8(%rsi),%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1270
  469854:	mov    %r12d,%r10d
  469857:	and    %r13d,%r10d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1272
  46985a:	shl    $0x4,%r10
  46985e:	add    %r15,%r10
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469861:	vmovdqa64 (%r10),%zmm0
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  469867:	vpbroadcastq %r11,%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46986d:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1276
  469874:	kortestb %k0,%k0
  469878:	jne    4698f4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb24>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46987a:	vpcmpequq %zmm2,%zmm0,%k3{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1284
  469881:	kortestb %k3,%k3
  469885:	jne    469939 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb69>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46988b:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1286
  469890:	mov    %r13d,%r10d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  469893:	je     469962 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb92>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  469899:	cmpq   $0x8,(%rsp)
  46989e:	je     469983 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbb3>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1294
  4698a4:	mov    -0x28(%rsp),%r10d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1288
  4698a9:	mov    -0x18(%rsp),%r13
  4698ae:	vmovd  %r10d,%xmm7
  4698b3:	vpinsrd $0x1,0xc(%rsi),%xmm7,%xmm3
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1294
  4698ba:	mov    %edi,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1288
  4698bc:	and    -0x28(%rsp),%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1294
  4698c1:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1295
  4698c5:	inc    %edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  4698c7:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1294
  4698c9:	add    %rbx,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1465
  4698cc:	shl    $0x4,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1296
  4698d0:	and    %r9d,%edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4698d3:	and    %r9d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1465
  4698d6:	prefetcht2 (%r15,%r13,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1231
  4698db:	mov    %r11,(%rsi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1232
  4698de:	vmovq  %xmm3,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1296
  4698e3:	mov    %edi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4698e9:	mov    %eax,0xb4(%rcx)
  4698ef:	jmp    4697e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa10>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1277
  4698f4:	mov    (%r8),%r11d
  4698f7:	mov    0xc(%rsi),%r13d
  4698fb:	mov    %r11,%r12
  4698fe:	shl    $0x4,%r11
  469902:	add    0x8(%r8),%r11
  469906:	mov    %r13d,(%r11)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469909:	xor    %r13d,%r13d
  46990c:	kmovb  %k0,%esi
  469910:	tzcnt  %esi,%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1278
  469915:	inc    %r13d
  469918:	movslq %r13d,%rsi
  46991b:	mov    (%r10,%rsi,8),%r10
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46991f:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1279
  469921:	inc    %r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469924:	and    %r9d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1278
  469927:	mov    %r10,0x8(%r11)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1279
  46992b:	mov    %r12d,(%r8)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46992e:	mov    %eax,0xb4(%rcx)
  469934:	jmp    4697aa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9da>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469939:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46993b:	and    %r9d,%eax
  46993e:	mov    %eax,0xb4(%rcx)
  469944:	jmp    4697aa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9da>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469949:	mov    $0xffffffff,%eax
  46994e:	crc32q (%rdx),%rax
  469954:	mov    %rax,-0x10(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1684
  469959:	vmovd  %eax,%xmm4
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1684
  46995d:	jmp    469747 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x977>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469962:	mov    $0xffffffff,%r10d
  469968:	crc32  %r13d,%r10d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  46996e:	mov    %r10d,%r13d
  469971:	mov    %r13,-0x28(%rsp)
  469976:	jmp    4698a9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad9>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  46997b:	xor    %r12d,%r12d
  46997e:	jmp    469215 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x445>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469983:	mov    $0xffffffff,%r13d
  469989:	crc32  %r10,%r13
  46998f:	mov    %r13,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1294
  469994:	mov    %r13d,%r10d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1294
  469997:	jmp    4698a9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xad9>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  46999c:	incl   -0x34(%rsp)
  4699a0:	jmp    468f78 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a8>
  4699a5:	incl   -0x34(%rsp)
  4699a9:	vpxor  %xmm15,%xmm15,%xmm15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:788
  4699ae:	xor    %r11d,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:787
  4699b1:	vpxor  %xmm12,%xmm12,%xmm12
  4699b6:	jmp    468efb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x12b>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  4699bb:	incl   -0x34(%rsp)
  4699bf:	mov    %rdx,-0x10(%rsp)
  4699c4:	jmp    468ffb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x22b>
