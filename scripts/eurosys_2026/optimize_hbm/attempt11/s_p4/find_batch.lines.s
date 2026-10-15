
/opt/DRAMHiT/scripts/eurosys_2026/optimize_hbm/attempt11/s_p4/dramhit:     file format elf64-x86-64


Disassembly of section .text:

0000000000468e00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:703
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
  468e1b:	mov    0x8(%rsi),%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e1f:	mov    0xb0(%rdi),%edi
  468e25:	mov    0xb4(%rcx),%eax
  468e2b:	mov    (%rsi),%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:718
  468e2e:	mov    0x78(%rcx),%r8d
  468e32:	mov    0x6c(%rcx),%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:872
  468e36:	mov    %r11,%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e39:	mov    %edi,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:872
  468e3b:	shl    $0x4,%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e3f:	sub    %eax,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:872
  468e41:	lea    (%rdx,%r10,1),%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e45:	and    %r8d,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:718
  468e48:	lea    -0x1(%r9),%r12d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:872
  468e4c:	mov    %rbx,-0x20(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:720
  468e51:	cmp    %r12d,%esi
  468e54:	jb     4696d3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8d3>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:781
  468e5a:	and    $0xfffffffffffffffc,%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468e5e:	shl    $0x4,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:781
  468e62:	shl    $0x4,%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:732
  468e66:	mov    0x8(%r15),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:736
  468e6a:	mov    0x80(%rcx),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468e70:	mov    %r9,-0x18(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:781
  468e75:	mov    %r11,-0x38(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468e7a:	lea    -0x1(%r9),%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:781
  468e7e:	lea    (%rdx,%r11,1),%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:729
  468e82:	mov    %edi,%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:732
  468e85:	mov    %r14,(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:781
  468e89:	mov    %r11,-0x28(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:731
  468e8e:	movl   $0x0,-0x2c(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:726
  468e96:	mov    0xa0(%rcx),%r8
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:747
  468e9d:	mov    0x29d44(%rip),%rdi        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:728
  468ea4:	shl    $0x4,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:729
  468ea8:	shl    $0x4,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:736
  468eac:	not    %esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:782
  468eae:	cmp    %r11,%rdx
  468eb1:	je     46996a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb6a>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468eb7:	mov    $0x55,%r13d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468ebd:	mov    $0xf,%ebx
  468ec2:	mov    $0xf0,%r12d
  468ec8:	mov    $0xf00,%r11d
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468ece:	kmovb  %r13d,%k2
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468ed3:	mov    $0xfffff000,%r13d
  468ed9:	mov    %rcx,-0x40(%rsp)
  468ede:	mov    %r15,-0x48(%rsp)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468ee3:	vpxor  %xmm4,%xmm4,%xmm4
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468ee7:	mov    $0xffffffff,%r14d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468eed:	kmovw  %ebx,%k6
  468ef1:	kmovw  %r12d,%k5
  468ef6:	kmovw  %r11d,%k4
  468efb:	kmovw  %r13d,%k3
  468f00:	jmp    469153 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x353>
  468f05:	nopl   (%rax)
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468f08:	vmovd  0xc(%r13),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468f0e:	kshiftlb $0x1,%k7,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468f14:	vpcompressq %zmm8,%zmm12{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468f1a:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468f1f:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k6}{z}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468f26:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:801
  468f2c:	mov    $0x1,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:789
  468f32:	lea    0x180(%rax),%r12
  468f39:	and    %r10,%r12
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  468f3c:	andn   0x8(%r8,%r12,1),%esi,%ecx
  468f43:	shl    $0x4,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:789
  468f47:	prefetcht0 (%rdi,%rcx,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:790
  468f4b:	lea    (%r8,%rax,1),%rcx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  468f4f:	mov    0x8(%rcx),%ebx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  468f52:	andn   %ebx,%esi,%r13d
  468f57:	shl    $0x4,%r13
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468f5b:	vmovdqa64 (%rdi,%r13,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:752
  468f62:	vpbroadcastq (%rcx),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468f68:	vpcmpequq %zmm2,%zmm0,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:791
  468f6f:	add    $0x10,%rax
  468f73:	and    %r10,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468f76:	kortestb %k0,%k0
  468f7a:	je     4695e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7e0>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468f80:	vmovd  0xc(%rcx),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468f85:	kshiftlb $0x1,%k0,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468f8b:	vpcompressq %zmm0,%zmm6{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468f91:	vpunpcklqdq %xmm6,%xmm1,%xmm7
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468f95:	vshufi32x4 $0x0,%zmm7,%zmm7,%zmm15{%k5}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468f9c:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:801
  468fa2:	or     $0x2,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:789
  468fa6:	lea    0x180(%rax),%r13
  468fad:	and    %r10,%r13
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  468fb0:	andn   0x8(%r8,%r13,1),%esi,%ecx
  468fb7:	shl    $0x4,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:789
  468fbb:	prefetcht0 (%rdi,%rcx,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:790
  468fbf:	lea    (%r8,%rax,1),%rcx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  468fc3:	mov    0x8(%rcx),%ebx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  468fc6:	andn   %ebx,%esi,%r12d
  468fcb:	shl    $0x4,%r12
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468fcf:	vmovdqa64 (%rdi,%r12,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:752
  468fd6:	vpbroadcastq (%rcx),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468fdc:	vpcmpequq %zmm9,%zmm8,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:791
  468fe3:	add    $0x10,%rax
  468fe7:	and    %r10,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468fea:	kortestb %k0,%k0
  468fee:	je     469588 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x788>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468ff4:	vmovd  0xc(%rcx),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468ff9:	kshiftlb $0x1,%k0,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468fff:	vpcompressq %zmm8,%zmm12{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  469005:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  46900a:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k4}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  469011:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:801
  469017:	or     $0x4,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:790
  46901b:	lea    (%r8,%rax,1),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:789
  46901f:	lea    0x180(%rax),%r12
  469026:	and    %r10,%r12
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  469029:	mov    0x8(%r15),%ebx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  46902d:	andn   0x8(%r8,%r12,1),%esi,%ecx
  469034:	shl    $0x4,%rcx
  469038:	andn   %ebx,%esi,%r12d
  46903d:	shl    $0x4,%r12
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469041:	vmovdqa64 (%rdi,%r12,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:752
  469048:	vpbroadcastq (%r15),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46904e:	vpcmpequq %zmm2,%zmm0,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:791
  469055:	add    $0x10,%rax
  469059:	and    %r10,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:789
  46905c:	prefetcht0 (%rdi,%rcx,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  469060:	kortestb %k0,%k0
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:851
  469064:	lea    (%r8,%r9,1),%rcx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  469068:	je     469538 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x738>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46906e:	vmovd  0xc(%r15),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  469074:	kshiftlb $0x1,%k0,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  46907a:	vpcompressq %zmm0,%zmm6{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  469080:	vpunpcklqdq %xmm6,%xmm1,%xmm7
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  469084:	vshufi32x4 $0x0,%zmm7,%zmm7,%zmm15{%k3}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:801
  46908b:	or     $0x8,%r11d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  46908f:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:822
  469095:	cmp    $0xf,%r11d
  469099:	jne    4696a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8a0>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  46909f:	mov    (%rsp),%r12
  4690a3:	vmovdqu64 %zmm15,(%r12)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:824
  4690aa:	add    $0x40,%r12
  4690ae:	mov    %r12,(%rsp)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690b2:	mov    %r14,%rbx
  4690b5:	crc32q (%rdx),%rbx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  4690bb:	andn   %ebx,%esi,%r13d
  4690c0:	shl    $0x4,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:835
  4690c4:	prefetcht2 (%rdi,%r13,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690c9:	mov    %r14,%r13
  4690cc:	crc32q 0x10(%rdx),%r13
  4690d3:	mov    %r14,%r11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  4690d6:	andn   %r13d,%esi,%r15d
  4690db:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:835
  4690df:	prefetcht2 (%rdi,%r15,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690e4:	mov    %r14,%r15
  4690e7:	crc32q 0x20(%rdx),%r11
  4690ee:	crc32q 0x30(%rdx),%r15
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  4690f5:	andn   %r11d,%esi,%r12d
  4690fa:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:835
  4690fe:	prefetcht2 (%rdi,%r12,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  469103:	andn   %r15d,%esi,%r12d
  469108:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:835
  46910c:	prefetcht2 (%rdi,%r12,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:847
  469111:	lea    0x40(%r9),%r12
_Z18_mm512_loadu_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6414
  469115:	vmovdqu64 (%rdx),%zmm15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:847
  46911b:	cmp    %r12,-0x18(%rsp)
  469120:	jb     469630 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x830>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  469126:	vmovdqu64 %zmm15,(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:853
  46912c:	mov    %ebx,0x8(%rcx)
  46912f:	mov    %r13d,0x18(%r8,%r9,1)
  469134:	mov    %r11d,0x28(%r8,%r9,1)
  469139:	mov    %r15d,0x38(%r8,%r9,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:865
  46913e:	mov    %r12,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:782
  469141:	add    $0x40,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:865
  469145:	and    %r10,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:782
  469148:	cmp    %rdx,-0x28(%rsp)
  46914d:	je     4691f8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3f8>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:790
  469153:	lea    (%r8,%rax,1),%r13
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  469157:	mov    0x8(%r13),%r11d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  46915b:	andn   %r11d,%esi,%r12d
  469160:	shl    $0x4,%r12
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469164:	vmovdqa64 (%rdi,%r12,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:752
  46916b:	vpbroadcastq 0x0(%r13),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469172:	vpcmpequq %zmm9,%zmm8,%k7{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:789
  469179:	lea    0x180(%rax),%rcx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:791
  469180:	add    $0x10,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:789
  469184:	and    %r10,%rcx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:791
  469187:	and    %r10,%rax
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  46918a:	andn   0x8(%r8,%rcx,1),%esi,%r15d
  469191:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  469195:	kortestb %k7,%k7
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:789
  469199:	prefetcht0 (%rdi,%r15,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  46919e:	jne    468f08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4691a4:	vpcmpequq %zmm4,%zmm8,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:804
  4691ab:	kortestb %k1,%k1
  4691af:	jne    469993 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb93>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4691b5:	mov    %r14,%rcx
  4691b8:	crc32  %r11,%rcx
  4691be:	vmovd  %ecx,%xmm10
  4691c2:	vpinsrd $0x1,0xc(%r13),%xmm10,%xmm11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:815
  4691c9:	mov    0x0(%r13),%r13
  4691cd:	lea    (%r8,%r9,1),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  4691d1:	add    $0x10,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  4691d5:	andn   %ecx,%esi,%ebx
  4691da:	shl    $0x4,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  4691de:	and    %r10,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:814
  4691e1:	prefetcht2 (%rdi,%rbx,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1234
  4691e5:	mov    %r13,(%r15)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1235
  4691e8:	vmovq  %xmm11,0x8(%r15)
  4691ee:	jmp    469153 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x353>
  4691f3:	nopl   0x0(%rax,%rax,1)
  4691f8:	mov    -0x40(%rsp),%rcx
  4691fd:	mov    -0x48(%rsp),%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:870
  469202:	mov    -0x2c(%rsp),%edi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:868
  469206:	vmovq  %r9,%xmm14
  46920b:	vpinsrq $0x1,%rax,%xmm14,%xmm0
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:870
  469211:	mov    -0x38(%rsp),%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:868
  469216:	vpsrlq $0x4,%xmm0,%xmm2
  46921b:	vpmovqd %xmm2,%xmm3
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:870
  469221:	sar    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:868
  469225:	vmovq  %xmm3,0xb0(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:870
  46922d:	sub    %rdi,%rsi
  469230:	add    %esi,(%r15)
  469233:	vpextrd $0x1,%xmm3,%eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:872
  469239:	cmp    -0x20(%rsp),%rdx
  46923e:	je     469520 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1677
  469244:	mov    0x88(%rcx),%rdi
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1218
  46924b:	mov    0x80(%rcx),%rbx
  469252:	mov    0x60(%rcx),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1677
  469256:	dec    %rdi
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1218
  469259:	mov    %rbx,-0x18(%rsp)
  46925e:	mov    %r8,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1677
  469262:	mov    %rdi,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  469267:	mov    0x78(%rcx),%r10d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  46926b:	mov    0x29976(%rip),%r11        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469272:	mov    0xa0(%rcx),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1426
  469279:	movzbl 0x2987f(%rip),%r13d        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1428
  469281:	mov    0x29880(%rip),%r12        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469288:	mov    $0x55,%r14d
  46928e:	vpxor  %xmm7,%xmm7,%xmm7
  469292:	kmovb  %r14d,%k2
  469297:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  4692a0:	lea    0x18(%rax),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692a3:	and    %r10d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1223
  4692a6:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692aa:	mov    %ebx,%r8d
  4692ad:	and    0x8(%r9,%rsi,1),%r8d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  4692b2:	mov    %eax,%esi
  4692b4:	shl    $0x4,%rsi
  4692b8:	add    %r9,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692bb:	mov    %r8,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1410
  4692be:	mov    (%rsi),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692c1:	shl    $0x4,%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:620
  4692c5:	prefetcht0 (%r11,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1410
  4692ca:	cmp    0x90(%rcx),%r8
  4692d1:	jne    469390 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x590>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1426
  4692d7:	test   %r13b,%r13b
  4692da:	je     4692fa <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4fa>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1427
  4692dc:	mov    (%r15),%r14d
  4692df:	mov    0xc(%rsi),%esi
  4692e2:	mov    %r14,%r8
  4692e5:	shl    $0x4,%r14
  4692e9:	add    0x8(%r15),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1429
  4692ed:	inc    %r8d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1427
  4692f0:	mov    %esi,(%r14)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1428
  4692f3:	mov    %r12,0x8(%r14)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1429
  4692f7:	mov    %r8d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  4692fa:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4692fc:	and    %r10d,%eax
  4692ff:	mov    %eax,0xb4(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:626
  469305:	test   %r12,%r12
  469308:	jne    4692a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46930a:	cmpq   $0x4,(%rsp)
  46930f:	je     469485 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x685>
  469315:	nopl   (%rax)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  469318:	cmpq   $0x8,(%rsp)
  46931d:	je     469500 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x700>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1687
  469323:	vmovd  -0x10(%rsp),%xmm15
  469329:	mov    (%rdx),%rdi
  46932c:	mov    0xb0(%rcx),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1677
  469332:	mov    -0x28(%rsp),%r8
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1687
  469337:	mov    %rsi,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1677
  46933a:	and    -0x10(%rsp),%r8
  46933f:	vpinsrd $0x1,0xc(%rdx),%xmm15,%xmm9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1680
  469346:	and    $0xfffffffffffffffc,%r8
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1687
  46934a:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1705
  46934e:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1687
  469350:	add    %r9,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1468
  469353:	shl    $0x4,%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1706
  469357:	and    %r10d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:872
  46935a:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1468
  46935e:	prefetcht2 (%r11,%r8,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1234
  469363:	mov    %rdi,(%rsi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1235
  469366:	vmovq  %xmm9,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1706
  46936b:	mov    %eax,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:872
  469371:	cmp    -0x20(%rsp),%rdx
  469376:	je     469520 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  46937c:	mov    0xb4(%rcx),%eax
  469382:	jmp    4692a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  469387:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1223
  469390:	mov    0x8(%rsi),%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1273
  469394:	mov    %ebx,%edi
  469396:	and    %r14d,%edi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1275
  469399:	shl    $0x4,%rdi
  46939d:	add    %r11,%rdi
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4693a0:	vmovdqa64 (%rdi),%zmm5
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  4693a6:	vpbroadcastq %r8,%zmm6
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4693ac:	vpcmpequq %zmm6,%zmm5,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1279
  4693b3:	kortestb %k0,%k0
  4693b7:	jne    469440 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x640>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4693bd:	vpcmpequq %zmm7,%zmm5,%k3{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1287
  4693c4:	kortestb %k3,%k3
  4693c8:	jne    4694b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6b0>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4693ce:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1289
  4693d3:	mov    %r14d,%edi
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4693d6:	je     4694c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  4693dc:	cmpq   $0x8,(%rsp)
  4693e1:	je     4694e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6e0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1297
  4693e7:	vmovd  -0x8(%rsp),%xmm1
  4693ed:	mov    0xb0(%rcx),%edi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1291
  4693f3:	mov    -0x18(%rsp),%r14
  4693f8:	vpinsrd $0x1,0xc(%rsi),%xmm1,%xmm4
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1297
  4693ff:	mov    %rdi,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1291
  469402:	and    -0x8(%rsp),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1297
  469407:	shl    $0x4,%rdi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1298
  46940b:	inc    %esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46940d:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1297
  46940f:	add    %r9,%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1468
  469412:	shl    $0x4,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  469416:	and    %r10d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469419:	and    %r10d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1468
  46941c:	prefetcht2 (%r11,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1234
  469421:	mov    %r8,(%rdi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1235
  469424:	vmovq  %xmm4,0x8(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  469429:	mov    %esi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46942f:	mov    %eax,0xb4(%rcx)
  469435:	jmp    4692a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a0>
  46943a:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1280
  469440:	mov    (%r15),%r8d
  469443:	mov    0xc(%rsi),%esi
  469446:	mov    %r8,%r14
  469449:	shl    $0x4,%r8
  46944d:	add    0x8(%r15),%r8
  469451:	mov    %esi,(%r8)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469454:	kmovb  %k0,%esi
  469458:	tzcnt  %esi,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1281
  46945c:	inc    %esi
  46945e:	movslq %esi,%rsi
  469461:	mov    (%rdi,%rsi,8),%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469465:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1282
  469467:	inc    %r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46946a:	and    %r10d,%eax
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46946d:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1281
  469472:	mov    %rdi,0x8(%r8)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1282
  469476:	mov    %r14d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469479:	mov    %eax,0xb4(%rcx)
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46947f:	jne    469318 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x518>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469485:	mov    $0xffffffff,%r14d
  46948b:	crc32l (%rdx),%r14d
  469491:	vmovd  %r14d,%xmm8
  469496:	mov    (%rdx),%rdi
  469499:	vmovdqa %xmm8,%xmm15
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  46949e:	vmovq  %xmm8,-0x10(%rsp)
  4694a4:	jmp    46932c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  4694a9:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  4694b0:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4694b2:	and    %r10d,%eax
  4694b5:	mov    %eax,0xb4(%rcx)
  4694bb:	jmp    46930a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4694c0:	mov    $0xffffffff,%edi
  4694c5:	crc32  %r14d,%edi
  4694cb:	vmovd  %edi,%xmm12
  4694cf:	vmovdqa %xmm12,%xmm1
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  4694d3:	vmovq  %xmm12,-0x8(%rsp)
  4694d9:	jmp    4693ed <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  4694de:	xchg   %ax,%ax
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4694e0:	mov    $0xffffffff,%r14d
  4694e6:	crc32  %rdi,%r14
  4694ec:	mov    %r14,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1297
  4694f1:	vmovd  %r14d,%xmm1
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1297
  4694f6:	jmp    4693ed <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5ed>
  4694fb:	nopl   0x0(%rax,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469500:	mov    (%rdx),%rdi
  469503:	mov    $0xffffffff,%eax
  469508:	crc32  %rdi,%rax
  46950e:	mov    %rax,-0x10(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1687
  469513:	vmovd  %eax,%xmm15
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1687
  469517:	jmp    46932c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x52c>
  46951c:	nopl   0x0(%rax)
  469520:	vzeroupper 
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:705
  469523:	lea    -0x28(%rbp),%rsp
  469527:	pop    %rbx
  469528:	pop    %r12
  46952a:	pop    %r13
  46952c:	pop    %r14
  46952e:	pop    %r15
  469530:	pop    %rbp
  469531:	ret    
  469532:	nopw   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469538:	vpcmpequq %zmm4,%zmm0,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:804
  46953f:	kortestb %k1,%k1
  469543:	jne    469698 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x898>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469549:	mov    %r14,%r13
  46954c:	crc32  %rbx,%r13
  469552:	vmovd  %r13d,%xmm3
  469557:	vpinsrd $0x1,0xc(%r15),%xmm3,%xmm5
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:815
  46955e:	mov    (%r15),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  469561:	add    $0x10,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  469565:	andn   %r13d,%esi,%ebx
  46956a:	shl    $0x4,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  46956e:	and    %r10,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:814
  469571:	prefetcht2 (%rdi,%rbx,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1234
  469575:	mov    %r15,(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1235
  469578:	vmovq  %xmm5,0x8(%rcx)
  46957d:	jmp    46901b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x21b>
  469582:	nopw   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469588:	vpcmpequq %zmm4,%zmm8,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:804
  46958f:	kortestb %k1,%k1
  469593:	jne    4699a9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xba9>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469599:	mov    %r14,%r15
  46959c:	crc32  %rbx,%r15
  4695a2:	vmovd  %r15d,%xmm10
  4695a7:	vpinsrd $0x1,0xc(%rcx),%xmm10,%xmm11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:815
  4695ae:	mov    (%rcx),%rcx
  4695b1:	lea    (%r8,%r9,1),%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  4695b5:	add    $0x10,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  4695b9:	andn   %r15d,%esi,%ebx
  4695be:	shl    $0x4,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  4695c2:	and    %r10,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:814
  4695c5:	prefetcht2 (%rdi,%rbx,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1234
  4695c9:	mov    %rcx,0x0(%r13)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1235
  4695cd:	vmovq  %xmm11,0x8(%r13)
  4695d3:	jmp    468fa6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a6>
  4695d8:	nopl   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4695e0:	vpcmpequq %zmm4,%zmm0,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:804
  4695e7:	kortestb %k1,%k1
  4695eb:	jne    46998a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb8a>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4695f1:	mov    %r14,%r12
  4695f4:	crc32  %rbx,%r12
  4695fa:	vmovd  %r12d,%xmm3
  4695ff:	vpinsrd $0x1,0xc(%rcx),%xmm3,%xmm5
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:815
  469606:	mov    (%rcx),%rcx
  469609:	lea    (%r8,%r9,1),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  46960d:	add    $0x10,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:744
  469611:	andn   %r12d,%esi,%ebx
  469616:	shl    $0x4,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  46961a:	and    %r10,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:814
  46961d:	prefetcht2 (%rdi,%rbx,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1234
  469621:	mov    %rcx,(%r15)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1235
  469624:	vmovq  %xmm5,0x8(%r15)
  46962a:	jmp    468f32 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x132>
  46962f:	nop
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469630:	vmovd  %ebx,%xmm10
  469634:	vpinsrd $0x1,%r13d,%xmm10,%xmm11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:860
  46963a:	mov    -0x18(%rsp),%r13
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46963f:	vmovd  %r11d,%xmm8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:860
  469644:	mov    %r13,%r11
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469647:	vpinsrd $0x1,%r15d,%xmm8,%xmm9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:860
  46964d:	sub    %r9,%r11
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  469650:	mov    $0x4444,%ebx
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469655:	vpunpcklqdq %xmm9,%xmm11,%xmm13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:861
  46965a:	shr    $0x2,%r11
  46965e:	mov    $0x1,%r15d
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  469664:	kmovw  %ebx,%k7
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:861
  469668:	shlx   %r11d,%r15d,%r11d
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  46966d:	vpexpandd %zmm13,%zmm15{%k7}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:861
  469673:	lea    -0x1(%r11),%ebx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:863
  469677:	sub    %r13,%r9
  46967a:	neg    %r11d
_Z24_mm512_mask_storeu_epi32PvtDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6461
  46967d:	kmovw  %ebx,%k1
  469681:	vmovdqu32 %zmm15,(%rcx){%k1}
  469687:	kmovw  %r11d,%k7
  46968c:	vmovdqu32 %zmm15,(%r8,%r9,1){%k7}
  469693:	jmp    46913e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x33e>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:805
  469698:	incl   -0x2c(%rsp)
  46969c:	nopl   0x0(%rax)
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  4696a0:	mov    (%rsp),%r15
_Z9_pdep_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmi2intrin.h:48
  4696a4:	mov    $0x55,%r12d
  4696aa:	pdep   %r12d,%r11d,%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:827
  4696af:	popcnt %r11d,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:826
  4696b4:	lea    0x0(%r13,%r13,2),%ebx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:827
  4696b9:	shl    $0x4,%r11
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  4696bd:	kmovb  %ebx,%k1
  4696c1:	vpcompressq %zmm12,(%r15){%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:827
  4696c7:	add    %r11,%r15
  4696ca:	mov    %r15,(%rsp)
  4696ce:	jmp    4690b2 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2b2>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1088
  4696d3:	cmp    -0x20(%rsp),%rdx
  4696d8:	je     469523 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x723>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1677
  4696de:	mov    0x88(%rcx),%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1426
  4696e5:	movzbl 0x29413(%rip),%r13d        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1428
  4696ed:	mov    0x29414(%rip),%r9        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4696f4:	mov    0x60(%rcx),%r10
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4696f8:	mov    $0x55,%ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1677
  4696fd:	dec    %r12
  469700:	kmovb  %r13d,%k2
  469705:	mov    %r10,(%rsp)
  469709:	mov    %r12,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  46970e:	mov    0x294d3(%rip),%r14        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469715:	mov    0xa0(%rcx),%r11
  46971c:	mov    %edi,%esi
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46971e:	vpxor  %xmm2,%xmm2,%xmm2
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1677
  469722:	mov    %r9,%r13
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469725:	kmovb  %ebx,%k1
  469729:	jmp    469791 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x991>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  46972b:	cmpq   $0x8,(%rsp)
  469730:	je     469938 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb38>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1687
  469736:	vmovd  -0x18(%rsp),%xmm5
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1677
  46973c:	mov    -0x8(%rsp),%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1687
  469741:	mov    %edi,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1677
  469743:	and    -0x18(%rsp),%r12
  469748:	vpinsrd $0x1,0xc(%rdx),%xmm5,%xmm7
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1687
  46974f:	mov    (%rdx),%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1680
  469752:	and    $0xfffffffffffffffc,%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1687
  469756:	shl    $0x4,%rsi
  46975a:	add    %r11,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1468
  46975d:	shl    $0x4,%r12
  469761:	prefetcht2 (%r14,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1234
  469766:	mov    %r10,(%rsi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1235
  469769:	vmovq  %xmm7,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1705
  46976e:	lea    0x1(%rdi),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1706
  469771:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1088
  469774:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1706
  469778:	mov    %esi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1088
  46977e:	cmp    %rdx,-0x20(%rsp)
  469783:	je     469520 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17get_find_queue_szEv():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:525
  469789:	mov    0xb4(%rcx),%eax
  46978f:	mov    %esi,%edi
  469791:	sub    %eax,%esi
  469793:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1089
  469796:	cmp    %esi,%r8d
  469799:	jbe    4697bc <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9bc>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46979b:	cmpq   $0x4,(%rsp)
  4697a0:	jne    46972b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x92b>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4697a2:	mov    $0xffffffff,%ebx
  4697a7:	crc32l (%rdx),%ebx
  4697ac:	vmovd  %ebx,%xmm6
  4697b0:	vmovdqa %xmm6,%xmm5
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  4697b4:	vmovq  %xmm6,-0x18(%rsp)
  4697ba:	jmp    46973c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x93c>
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1218
  4697bc:	mov    0x80(%rcx),%rbx
  4697c3:	mov    %rbx,-0x10(%rsp)
  4697c8:	nopl   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  4697d0:	lea    0x18(%rax),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4697d3:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1223
  4697d6:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4697da:	mov    %ebx,%r9d
  4697dd:	and    0x8(%r11,%rsi,1),%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  4697e2:	mov    %eax,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4697e4:	mov    %r9,%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  4697e7:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4697eb:	shl    $0x4,%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  4697ef:	add    %r11,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:620
  4697f2:	prefetcht0 (%r14,%r10,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1410
  4697f7:	mov    (%rsi),%r10
  4697fa:	cmp    0x90(%rcx),%r10
  469801:	jne    469840 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa40>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1426
  469803:	kortestb %k2,%k2
  469807:	je     46982a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa2a>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1427
  469809:	mov    (%r15),%r12d
  46980c:	mov    0xc(%rsi),%esi
  46980f:	mov    %r12,%r10
  469812:	shl    $0x4,%r12
  469816:	add    0x8(%r15),%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1429
  46981a:	lea    0x1(%r10),%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1427
  46981e:	mov    %esi,(%r12)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1428
  469822:	mov    %r13,0x8(%r12)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1429
  469827:	mov    %r9d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46982a:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46982c:	and    %r8d,%eax
  46982f:	mov    %eax,0xb4(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:626
  469835:	test   %r13,%r13
  469838:	jne    4697d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9d0>
  46983a:	jmp    46979b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x99b>
  46983f:	nop
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1223
  469840:	mov    0x8(%rsi),%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1273
  469844:	mov    %ebx,%r9d
  469847:	and    %r12d,%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1275
  46984a:	shl    $0x4,%r9
  46984e:	add    %r14,%r9
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469851:	vmovdqa64 (%r9),%zmm0
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  469857:	vpbroadcastq %r10,%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46985d:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1279
  469864:	kortestb %k0,%k0
  469868:	jne    4698e4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xae4>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46986a:	vpcmpequq %zmm2,%zmm0,%k3{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1287
  469871:	kortestb %k3,%k3
  469875:	jne    469928 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb28>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46987b:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1289
  469880:	mov    %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  469883:	je     469951 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb51>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  469889:	cmpq   $0x8,(%rsp)
  46988e:	je     469971 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb71>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1297
  469894:	mov    -0x28(%rsp),%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1291
  469899:	mov    -0x10(%rsp),%r12
  46989e:	vmovd  %r9d,%xmm4
  4698a3:	vpinsrd $0x1,0xc(%rsi),%xmm4,%xmm3
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1297
  4698aa:	mov    %edi,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1291
  4698ac:	and    -0x28(%rsp),%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1297
  4698b1:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1298
  4698b5:	inc    %edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  4698b7:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1297
  4698b9:	add    %r11,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1468
  4698bc:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  4698c0:	and    %r8d,%edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4698c3:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1468
  4698c6:	prefetcht2 (%r14,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1234
  4698cb:	mov    %r10,(%rsi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1235
  4698ce:	vmovq  %xmm3,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  4698d3:	mov    %edi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4698d9:	mov    %eax,0xb4(%rcx)
  4698df:	jmp    4697d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9d0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1280
  4698e4:	mov    (%r15),%r10d
  4698e7:	mov    0xc(%rsi),%r12d
  4698eb:	mov    %r10,%rbx
  4698ee:	shl    $0x4,%r10
  4698f2:	add    0x8(%r15),%r10
  4698f6:	mov    %r12d,(%r10)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  4698f9:	xor    %r12d,%r12d
  4698fc:	kmovb  %k0,%esi
  469900:	tzcnt  %esi,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1281
  469905:	inc    %r12d
  469908:	movslq %r12d,%rsi
  46990b:	mov    (%r9,%rsi,8),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46990f:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1282
  469911:	inc    %ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469913:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1281
  469916:	mov    %r9,0x8(%r10)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1282
  46991a:	mov    %ebx,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46991d:	mov    %eax,0xb4(%rcx)
  469923:	jmp    46979b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x99b>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469928:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46992a:	and    %r8d,%eax
  46992d:	mov    %eax,0xb4(%rcx)
  469933:	jmp    46979b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x99b>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469938:	mov    $0xffffffff,%eax
  46993d:	crc32q (%rdx),%rax
  469943:	mov    %rax,-0x18(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1687
  469948:	vmovd  %eax,%xmm5
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1687
  46994c:	jmp    46973c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x93c>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469951:	mov    $0xffffffff,%r9d
  469957:	crc32  %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  46995d:	mov    %r9d,%r12d
  469960:	mov    %r12,-0x28(%rsp)
  469965:	jmp    469899 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa99>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:782
  46996a:	xor    %edi,%edi
  46996c:	jmp    469206 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x406>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469971:	mov    $0xffffffff,%r12d
  469977:	crc32  %r9,%r12
  46997d:	mov    %r12,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1297
  469982:	mov    %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1297
  469985:	jmp    469899 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa99>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:805
  46998a:	incl   -0x2c(%rsp)
  46998e:	jmp    468fa6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1a6>
  469993:	incl   -0x2c(%rsp)
  469997:	vpxor  %xmm15,%xmm15,%xmm15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  46999c:	xor    %r11d,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:784
  46999f:	vpxor  %xmm12,%xmm12,%xmm12
  4699a4:	jmp    468f32 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x132>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:805
  4699a9:	incl   -0x2c(%rsp)
  4699ad:	jmp    46901b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x21b>
