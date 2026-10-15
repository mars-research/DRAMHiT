
/opt/DRAMHiT/scripts/eurosys_2026/optimize_hbm/attempt11/s_p3/dramhit:     file format elf64-x86-64


Disassembly of section .text:

0000000000468e20 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:703
  468e20:	push   %rbp
  468e21:	mov    %rdi,%rcx
  468e24:	mov    %rsp,%rbp
  468e27:	push   %r15
  468e29:	mov    %rdx,%r15
  468e2c:	push   %r14
  468e2e:	push   %r13
  468e30:	push   %r12
  468e32:	push   %rbx
  468e33:	and    $0xffffffffffffffc0,%rsp
  468e37:	sub    $0x8,%rsp
  468e3b:	mov    0x8(%rsi),%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e3f:	mov    0xb0(%rdi),%edi
  468e45:	mov    0xb4(%rcx),%eax
  468e4b:	mov    (%rsi),%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:718
  468e4e:	mov    0x78(%rcx),%r8d
  468e52:	mov    0x6c(%rcx),%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:874
  468e56:	mov    %r11,%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e59:	mov    %edi,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:874
  468e5b:	shl    $0x4,%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e5f:	sub    %eax,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:874
  468e61:	lea    (%rdx,%r10,1),%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468e65:	and    %r8d,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:718
  468e68:	lea    -0x1(%r9),%r12d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:874
  468e6c:	mov    %rbx,-0x20(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:720
  468e71:	cmp    %r12d,%esi
  468e74:	jb     469703 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8e3>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:784
  468e7a:	and    $0xfffffffffffffffc,%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468e7e:	shl    $0x4,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:784
  468e82:	shl    $0x4,%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:732
  468e86:	mov    0x8(%r15),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:736
  468e8a:	mov    0x80(%rcx),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468e90:	mov    %r9,-0x18(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:784
  468e95:	mov    %r11,-0x38(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468e9a:	lea    -0x1(%r9),%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:784
  468e9e:	lea    (%rdx,%r11,1),%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:729
  468ea2:	mov    %edi,%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:732
  468ea5:	mov    %r14,(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:784
  468ea9:	mov    %r11,-0x28(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:731
  468eae:	movl   $0x0,-0x2c(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:726
  468eb6:	mov    0xa0(%rcx),%r8
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:752
  468ebd:	mov    0x29d24(%rip),%rdi        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:728
  468ec4:	shl    $0x4,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:729
  468ec8:	shl    $0x4,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:736
  468ecc:	not    %esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  468ece:	cmp    %r11,%rdx
  468ed1:	je     46999a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb7a>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468ed7:	mov    $0x55,%r13d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468edd:	mov    $0xf,%ebx
  468ee2:	mov    $0xf0,%r12d
  468ee8:	mov    $0xf00,%r11d
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468eee:	kmovb  %r13d,%k2
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468ef3:	mov    $0xfffff000,%r13d
  468ef9:	mov    %rcx,-0x40(%rsp)
  468efe:	mov    %r15,-0x48(%rsp)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468f03:	vpxor  %xmm4,%xmm4,%xmm4
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468f07:	mov    $0xffffffff,%r14d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468f0d:	kmovw  %ebx,%k6
  468f11:	kmovw  %r12d,%k5
  468f16:	kmovw  %r11d,%k4
  468f1b:	kmovw  %r13d,%k3
  468f20:	jmp    469188 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x368>
  468f25:	nopl   (%rax)
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468f28:	vmovd  0xc(%r11),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468f2e:	kshiftlb $0x1,%k7,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468f34:	vpcompressq %zmm8,%zmm12{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468f3a:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468f3f:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k6}{z}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468f46:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:803
  468f4c:	mov    $0x1,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:793
  468f52:	lea    (%r8,%rax,1),%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  468f56:	lea    0x180(%rax),%r13
  468f5d:	and    %r10,%r13
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  468f60:	mov    0x8(%rbx),%r12d
  468f64:	andn   0x8(%r8,%r13,1),%esi,%ecx
  468f6b:	andn   %r12d,%esi,%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  468f70:	mov    %ecx,%r15d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468f73:	mov    %r13d,%ecx
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468f76:	shl    $0x4,%rcx
  468f7a:	vmovdqa64 (%rdi,%rcx,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:755
  468f81:	vpbroadcastq (%rbx),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468f87:	vpcmpequq %zmm2,%zmm0,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  468f8e:	shl    $0x4,%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  468f92:	add    $0x10,%rax
  468f96:	and    %r10,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  468f99:	prefetcht0 (%rdi,%r15,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:797
  468f9e:	kortestb %k0,%k0
  468fa2:	je     469610 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7f0>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468fa8:	vmovd  0xc(%rbx),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  468fad:	kshiftlb $0x1,%k0,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  468fb3:	vpcompressq %zmm0,%zmm6{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  468fb9:	vpunpcklqdq %xmm6,%xmm1,%xmm7
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  468fbd:	vshufi32x4 $0x0,%zmm7,%zmm7,%zmm15{%k5}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  468fc4:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:803
  468fca:	or     $0x2,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:793
  468fce:	lea    (%r8,%rax,1),%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  468fd2:	lea    0x180(%rax),%rcx
  468fd9:	and    %r10,%rcx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  468fdc:	mov    0x8(%rbx),%r12d
  468fe0:	andn   0x8(%r8,%rcx,1),%esi,%r15d
  468fe7:	andn   %r12d,%esi,%ecx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  468fec:	mov    %r15d,%r13d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468fef:	mov    %ecx,%r15d
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468ff2:	shl    $0x4,%r15
  468ff6:	vmovdqa64 (%rdi,%r15,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:755
  468ffd:	vpbroadcastq (%rbx),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469003:	vpcmpequq %zmm9,%zmm8,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  46900a:	shl    $0x4,%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  46900e:	add    $0x10,%rax
  469012:	and    %r10,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  469015:	prefetcht0 (%rdi,%r13,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:797
  46901a:	kortestb %k0,%k0
  46901e:	je     4695b8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x798>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469024:	vmovd  0xc(%rbx),%xmm13
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  469029:	kshiftlb $0x1,%k0,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  46902f:	vpcompressq %zmm8,%zmm12{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  469035:	vpunpcklqdq %xmm12,%xmm13,%xmm14
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  46903a:	vshufi32x4 $0x0,%zmm14,%zmm14,%zmm15{%k4}
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  469041:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:803
  469047:	or     $0x4,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:793
  46904b:	lea    (%r8,%rax,1),%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  46904f:	lea    0x180(%rax),%r15
  469056:	and    %r10,%r15
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  469059:	mov    0x8(%rbx),%r12d
  46905d:	andn   0x8(%r8,%r15,1),%esi,%r13d
  469064:	andn   %r12d,%esi,%r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  469069:	mov    %r13d,%ecx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  46906c:	mov    %r15d,%r13d
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  46906f:	shl    $0x4,%r13
  469073:	vmovdqa64 (%rdi,%r13,1),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:755
  46907a:	vpbroadcastq (%rbx),%zmm2
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469080:	vpcmpequq %zmm2,%zmm0,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  469087:	shl    $0x4,%rcx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  46908b:	add    $0x10,%rax
  46908f:	and    %r10,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  469092:	prefetcht0 (%rdi,%rcx,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:797
  469096:	kortestb %k0,%k0
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:853
  46909a:	lea    (%r8,%r9,1),%rcx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:797
  46909e:	je     469568 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x748>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  4690a4:	vmovd  0xc(%rbx),%xmm1
_Z15_kshiftli_mask8hj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512dqintrin.h:1077
  4690a9:	kshiftlb $0x1,%k0,%k7
_Z27_mm512_maskz_compress_epi64hDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10814
  4690af:	vpcompressq %zmm0,%zmm6{%k7}{z}
_Z18_mm_unpacklo_epi64Dv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:1048
  4690b5:	vpunpcklqdq %xmm6,%xmm1,%xmm7
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4213
  4690b9:	vshufi32x4 $0x0,%zmm7,%zmm7,%zmm15{%k3}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:803
  4690c0:	or     $0x8,%r11d
_Z27_mm512_mask_broadcast_i32x4Dv8_xtDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4215
  4690c4:	vmovdqa64 %zmm15,%zmm12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:824
  4690ca:	cmp    $0xf,%r11d
  4690ce:	jne    4696d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8b0>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  4690d4:	mov    (%rsp),%r13
  4690d8:	vmovdqu64 %zmm15,0x0(%r13)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:826
  4690df:	add    $0x40,%r13
  4690e3:	mov    %r13,(%rsp)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690e7:	mov    %r14,%rbx
  4690ea:	mov    %r14,%r11
  4690ed:	crc32q (%rdx),%rbx
  4690f3:	mov    %r14,%r13
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  4690f6:	andn   %ebx,%esi,%r15d
  4690fb:	shl    $0x4,%r15
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4690ff:	crc32q 0x20(%rdx),%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:837
  469106:	prefetcht2 (%rdi,%r15,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  46910b:	andn   %r11d,%esi,%r15d
  469110:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:837
  469114:	prefetcht2 (%rdi,%r15,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469119:	mov    %r14,%r15
  46911c:	crc32q 0x10(%rdx),%r13
  469123:	crc32q 0x30(%rdx),%r15
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  46912a:	andn   %r13d,%esi,%r12d
  46912f:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:837
  469133:	prefetcht2 (%rdi,%r12,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  469138:	andn   %r15d,%esi,%r12d
  46913d:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:837
  469141:	prefetcht2 (%rdi,%r12,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:849
  469146:	lea    0x40(%r9),%r12
_Z18_mm512_loadu_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6414
  46914a:	vmovdqu64 (%rdx),%zmm15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:849
  469150:	cmp    %r12,-0x18(%rsp)
  469155:	jb     469660 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x840>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  46915b:	vmovdqu64 %zmm15,(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:855
  469161:	mov    %ebx,0x8(%rcx)
  469164:	mov    %r13d,0x18(%r8,%r9,1)
  469169:	mov    %r11d,0x28(%r8,%r9,1)
  46916e:	mov    %r15d,0x38(%r8,%r9,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:867
  469173:	mov    %r12,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  469176:	add    $0x40,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:867
  46917a:	and    %r10,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  46917d:	cmp    %rdx,-0x28(%rsp)
  469182:	je     469230 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x410>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:793
  469188:	lea    (%r8,%rax,1),%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  46918c:	lea    0x180(%rax),%rcx
  469193:	and    %r10,%rcx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:739
  469196:	mov    0x8(%r11),%r13d
  46919a:	andn   0x8(%r8,%rcx,1),%esi,%r15d
  4691a1:	andn   %r13d,%esi,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  4691a6:	mov    %r12d,%ecx
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4691a9:	shl    $0x4,%rcx
  4691ad:	vmovdqa64 (%rdi,%rcx,1),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:755
  4691b4:	vpbroadcastq (%r11),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4691ba:	vpcmpequq %zmm9,%zmm8,%k7{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  4691c1:	mov    %r15d,%ebx
  4691c4:	shl    $0x4,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  4691c8:	add    $0x10,%rax
  4691cc:	and    %r10,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:792
  4691cf:	prefetcht0 (%rdi,%rbx,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:797
  4691d3:	kortestb %k7,%k7
  4691d7:	jne    468f28 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x108>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4691dd:	vpcmpequq %zmm4,%zmm8,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:806
  4691e4:	kortestb %k1,%k1
  4691e8:	jne    4699c3 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xba3>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4691ee:	mov    %r14,%r12
  4691f1:	crc32  %r13,%r12
  4691f7:	vmovd  %r12d,%xmm10
  4691fc:	vpinsrd $0x1,0xc(%r11),%xmm10,%xmm11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:817
  469203:	mov    (%r11),%r11
  469206:	lea    (%r8,%r9,1),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  46920a:	add    $0x10,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  46920e:	andn   %r12d,%esi,%ebx
  469213:	shl    $0x4,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  469217:	and    %r10,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  46921a:	prefetcht2 (%rdi,%rbx,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1236
  46921e:	mov    %r11,(%r15)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1237
  469221:	vmovq  %xmm11,0x8(%r15)
  469227:	jmp    469188 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x368>
  46922c:	nopl   0x0(%rax)
  469230:	mov    -0x40(%rsp),%rcx
  469235:	mov    -0x48(%rsp),%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:872
  46923a:	mov    -0x2c(%rsp),%edi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:870
  46923e:	vmovq  %r9,%xmm14
  469243:	vpinsrq $0x1,%rax,%xmm14,%xmm0
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:872
  469249:	mov    -0x38(%rsp),%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:870
  46924e:	vpsrlq $0x4,%xmm0,%xmm2
  469253:	vpmovqd %xmm2,%xmm3
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:872
  469259:	sar    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:870
  46925d:	vmovq  %xmm3,0xb0(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:872
  469265:	sub    %rdi,%rsi
  469268:	add    %esi,(%r15)
  46926b:	vpextrd $0x1,%xmm3,%eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:874
  469271:	cmp    -0x20(%rsp),%rdx
  469276:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x730>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1679
  46927c:	mov    0x88(%rcx),%rdi
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1220
  469283:	mov    0x80(%rcx),%rbx
  46928a:	mov    0x60(%rcx),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1679
  46928e:	dec    %rdi
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1220
  469291:	mov    %rbx,-0x18(%rsp)
  469296:	mov    %r8,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1679
  46929a:	mov    %rdi,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  46929f:	mov    0x78(%rcx),%r10d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692a3:	mov    0x2993e(%rip),%r11        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4692aa:	mov    0xa0(%rcx),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1428
  4692b1:	movzbl 0x29847(%rip),%r13d        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1430
  4692b9:	mov    0x29848(%rip),%r12        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4692c0:	mov    $0x55,%r14d
  4692c6:	vpxor  %xmm7,%xmm7,%xmm7
  4692ca:	kmovb  %r14d,%k2
  4692cf:	nop
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  4692d0:	lea    0x18(%rax),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692d3:	and    %r10d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1225
  4692d6:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692da:	mov    %ebx,%r8d
  4692dd:	and    0x8(%r9,%rsi,1),%r8d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  4692e2:	mov    %eax,%esi
  4692e4:	shl    $0x4,%rsi
  4692e8:	add    %r9,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692eb:	mov    %r8,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1412
  4692ee:	mov    (%rsi),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4692f1:	shl    $0x4,%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:620
  4692f5:	prefetcht0 (%r11,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1412
  4692fa:	cmp    0x90(%rcx),%r8
  469301:	jne    4693c0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5a0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1428
  469307:	test   %r13b,%r13b
  46930a:	je     46932a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x50a>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1429
  46930c:	mov    (%r15),%r14d
  46930f:	mov    0xc(%rsi),%esi
  469312:	mov    %r14,%r8
  469315:	shl    $0x4,%r14
  469319:	add    0x8(%r15),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1431
  46931d:	inc    %r8d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1429
  469320:	mov    %esi,(%r14)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1430
  469323:	mov    %r12,0x8(%r14)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1431
  469327:	mov    %r8d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46932a:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46932c:	and    %r10d,%eax
  46932f:	mov    %eax,0xb4(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:626
  469335:	test   %r12,%r12
  469338:	jne    4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4b0>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46933a:	cmpq   $0x4,(%rsp)
  46933f:	je     4694b5 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x695>
  469345:	nopl   (%rax)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  469348:	cmpq   $0x8,(%rsp)
  46934d:	je     469530 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x710>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1689
  469353:	vmovd  -0x10(%rsp),%xmm15
  469359:	mov    (%rdx),%rdi
  46935c:	mov    0xb0(%rcx),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1679
  469362:	mov    -0x28(%rsp),%r8
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1689
  469367:	mov    %rsi,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1679
  46936a:	and    -0x10(%rsp),%r8
  46936f:	vpinsrd $0x1,0xc(%rdx),%xmm15,%xmm9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1682
  469376:	and    $0xfffffffffffffffc,%r8
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1689
  46937a:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1707
  46937e:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1689
  469380:	add    %r9,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1470
  469383:	shl    $0x4,%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1708
  469387:	and    %r10d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:874
  46938a:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1470
  46938e:	prefetcht2 (%r11,%r8,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1236
  469393:	mov    %rdi,(%rsi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1237
  469396:	vmovq  %xmm9,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1708
  46939b:	mov    %eax,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:874
  4693a1:	cmp    -0x20(%rsp),%rdx
  4693a6:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x730>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  4693ac:	mov    0xb4(%rcx),%eax
  4693b2:	jmp    4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4b0>
  4693b7:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1225
  4693c0:	mov    0x8(%rsi),%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1275
  4693c4:	mov    %ebx,%edi
  4693c6:	and    %r14d,%edi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1277
  4693c9:	shl    $0x4,%rdi
  4693cd:	add    %r11,%rdi
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  4693d0:	vmovdqa64 (%rdi),%zmm5
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  4693d6:	vpbroadcastq %r8,%zmm6
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4693dc:	vpcmpequq %zmm6,%zmm5,%k0{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1281
  4693e3:	kortestb %k0,%k0
  4693e7:	jne    469470 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x650>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4693ed:	vpcmpequq %zmm7,%zmm5,%k3{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1289
  4693f4:	kortestb %k3,%k3
  4693f8:	jne    4694e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4693fe:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1291
  469403:	mov    %r14d,%edi
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  469406:	je     4694f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d0>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  46940c:	cmpq   $0x8,(%rsp)
  469411:	je     469510 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6f0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  469417:	vmovd  -0x8(%rsp),%xmm1
  46941d:	mov    0xb0(%rcx),%edi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1293
  469423:	mov    -0x18(%rsp),%r14
  469428:	vpinsrd $0x1,0xc(%rsi),%xmm1,%xmm4
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  46942f:	mov    %rdi,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1293
  469432:	and    -0x8(%rsp),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  469437:	shl    $0x4,%rdi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1300
  46943b:	inc    %esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46943d:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  46943f:	add    %r9,%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1470
  469442:	shl    $0x4,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1301
  469446:	and    %r10d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469449:	and    %r10d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1470
  46944c:	prefetcht2 (%r11,%r14,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1236
  469451:	mov    %r8,(%rdi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1237
  469454:	vmovq  %xmm4,0x8(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1301
  469459:	mov    %esi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46945f:	mov    %eax,0xb4(%rcx)
  469465:	jmp    4692d0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4b0>
  46946a:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1282
  469470:	mov    (%r15),%r8d
  469473:	mov    0xc(%rsi),%esi
  469476:	mov    %r8,%r14
  469479:	shl    $0x4,%r8
  46947d:	add    0x8(%r15),%r8
  469481:	mov    %esi,(%r8)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469484:	kmovb  %k0,%esi
  469488:	tzcnt  %esi,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  46948c:	inc    %esi
  46948e:	movslq %esi,%rsi
  469491:	mov    (%rdi,%rsi,8),%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469495:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1284
  469497:	inc    %r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46949a:	and    %r10d,%eax
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46949d:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  4694a2:	mov    %rdi,0x8(%r8)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1284
  4694a6:	mov    %r14d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4694a9:	mov    %eax,0xb4(%rcx)
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4694af:	jne    469348 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x528>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4694b5:	mov    $0xffffffff,%r14d
  4694bb:	crc32l (%rdx),%r14d
  4694c1:	vmovd  %r14d,%xmm8
  4694c6:	mov    (%rdx),%rdi
  4694c9:	vmovdqa %xmm8,%xmm15
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  4694ce:	vmovq  %xmm8,-0x10(%rsp)
  4694d4:	jmp    46935c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x53c>
  4694d9:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  4694e0:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4694e2:	and    %r10d,%eax
  4694e5:	mov    %eax,0xb4(%rcx)
  4694eb:	jmp    46933a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x51a>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4694f0:	mov    $0xffffffff,%edi
  4694f5:	crc32  %r14d,%edi
  4694fb:	vmovd  %edi,%xmm12
  4694ff:	vmovdqa %xmm12,%xmm1
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  469503:	vmovq  %xmm12,-0x8(%rsp)
  469509:	jmp    46941d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5fd>
  46950e:	xchg   %ax,%ax
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469510:	mov    $0xffffffff,%r14d
  469516:	crc32  %rdi,%r14
  46951c:	mov    %r14,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  469521:	vmovd  %r14d,%xmm1
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  469526:	jmp    46941d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5fd>
  46952b:	nopl   0x0(%rax,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469530:	mov    (%rdx),%rdi
  469533:	mov    $0xffffffff,%eax
  469538:	crc32  %rdi,%rax
  46953e:	mov    %rax,-0x10(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1689
  469543:	vmovd  %eax,%xmm15
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1689
  469547:	jmp    46935c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x53c>
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
  469568:	vpcmpequq %zmm4,%zmm0,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:806
  46956f:	kortestb %k1,%k1
  469573:	jne    4696c8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8a8>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469579:	mov    %r14,%r15
  46957c:	crc32  %r12,%r15
  469582:	vmovd  %r15d,%xmm3
  469587:	vpinsrd $0x1,0xc(%rbx),%xmm3,%xmm5
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:817
  46958e:	mov    (%rbx),%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  469591:	add    $0x10,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  469595:	andn   %r15d,%esi,%r12d
  46959a:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  46959e:	and    %r10,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  4695a1:	prefetcht2 (%rdi,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1236
  4695a6:	mov    %rbx,(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1237
  4695a9:	vmovq  %xmm5,0x8(%rcx)
  4695ae:	jmp    46904b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x22b>
  4695b3:	nopl   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4695b8:	vpcmpequq %zmm4,%zmm8,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:806
  4695bf:	kortestb %k1,%k1
  4695c3:	jne    4699d9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xbb9>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4695c9:	mov    %r14,%rcx
  4695cc:	crc32  %r12,%rcx
  4695d2:	vmovd  %ecx,%xmm10
  4695d6:	vpinsrd $0x1,0xc(%rbx),%xmm10,%xmm11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:817
  4695dd:	mov    (%rbx),%rbx
  4695e0:	lea    (%r8,%r9,1),%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  4695e4:	add    $0x10,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  4695e8:	andn   %ecx,%esi,%r12d
  4695ed:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  4695f1:	and    %r10,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  4695f4:	prefetcht2 (%rdi,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1236
  4695f9:	mov    %rbx,0x0(%r13)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1237
  4695fd:	vmovq  %xmm11,0x8(%r13)
  469603:	jmp    468fce <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1ae>
  469608:	nopl   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469610:	vpcmpequq %zmm4,%zmm0,%k1{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:806
  469617:	kortestb %k1,%k1
  46961b:	jne    4699ba <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb9a>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469621:	mov    %r14,%r13
  469624:	crc32  %r12,%r13
  46962a:	vmovd  %r13d,%xmm3
  46962f:	vpinsrd $0x1,0xc(%rbx),%xmm3,%xmm5
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:817
  469636:	mov    (%rbx),%rbx
  469639:	lea    (%r8,%r9,1),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  46963d:	add    $0x10,%r9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE0_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:749
  469641:	andn   %r13d,%esi,%r12d
  469646:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:818
  46964a:	and    %r10,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:816
  46964d:	prefetcht2 (%rdi,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1236
  469652:	mov    %rbx,(%r15)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1237
  469655:	vmovq  %xmm5,0x8(%r15)
  46965b:	jmp    468f52 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x132>
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469660:	vmovd  %ebx,%xmm10
  469664:	vpinsrd $0x1,%r13d,%xmm10,%xmm11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:862
  46966a:	mov    -0x18(%rsp),%r13
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  46966f:	vmovd  %r11d,%xmm8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:862
  469674:	mov    %r13,%r11
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469677:	vpinsrd $0x1,%r15d,%xmm8,%xmm9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:862
  46967d:	sub    %r9,%r11
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  469680:	mov    $0x4444,%ebx
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  469685:	vpunpcklqdq %xmm9,%xmm11,%xmm13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:863
  46968a:	shr    $0x2,%r11
  46968e:	mov    $0x1,%r15d
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  469694:	kmovw  %ebx,%k7
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:863
  469698:	shlx   %r11d,%r15d,%r11d
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  46969d:	vpexpandd %zmm13,%zmm15{%k7}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:863
  4696a3:	lea    -0x1(%r11),%ebx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:865
  4696a7:	sub    %r13,%r9
  4696aa:	neg    %r11d
_Z24_mm512_mask_storeu_epi32PvtDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6461
  4696ad:	kmovw  %ebx,%k1
  4696b1:	vmovdqu32 %zmm15,(%rcx){%k1}
  4696b7:	kmovw  %r11d,%k7
  4696bc:	vmovdqu32 %zmm15,(%r8,%r9,1){%k7}
  4696c3:	jmp    469173 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x353>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  4696c8:	incl   -0x2c(%rsp)
  4696cc:	nopl   0x0(%rax)
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  4696d0:	mov    (%rsp),%rbx
_Z9_pdep_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmi2intrin.h:48
  4696d4:	mov    $0x55,%r13d
  4696da:	pdep   %r13d,%r11d,%r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:829
  4696df:	popcnt %r11d,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:828
  4696e4:	lea    (%r15,%r15,2),%r12d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:829
  4696e8:	shl    $0x4,%r11
_Z32_mm512_mask_compressstoreu_epi64PvhDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10824
  4696ec:	kmovb  %r12d,%k1
  4696f1:	vpcompressq %zmm12,(%rbx){%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:829
  4696f7:	add    %r11,%rbx
  4696fa:	mov    %rbx,(%rsp)
  4696fe:	jmp    4690e7 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2c7>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1090
  469703:	cmp    -0x20(%rsp),%rdx
  469708:	je     469553 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x733>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1679
  46970e:	mov    0x88(%rcx),%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1428
  469715:	movzbl 0x293e3(%rip),%r13d        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1430
  46971d:	mov    0x293e4(%rip),%r9        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  469724:	mov    0x60(%rcx),%r10
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469728:	mov    $0x55,%ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1679
  46972d:	dec    %r12
  469730:	kmovb  %r13d,%k2
  469735:	mov    %r10,(%rsp)
  469739:	mov    %r12,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  46973e:	mov    0x294a3(%rip),%r14        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  469745:	mov    0xa0(%rcx),%r11
  46974c:	mov    %edi,%esi
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46974e:	vpxor  %xmm2,%xmm2,%xmm2
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1679
  469752:	mov    %r9,%r13
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469755:	kmovb  %ebx,%k1
  469759:	jmp    4697c1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9a1>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  46975b:	cmpq   $0x8,(%rsp)
  469760:	je     469968 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb48>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1689
  469766:	vmovd  -0x18(%rsp),%xmm5
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1679
  46976c:	mov    -0x8(%rsp),%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1689
  469771:	mov    %edi,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1679
  469773:	and    -0x18(%rsp),%r12
  469778:	vpinsrd $0x1,0xc(%rdx),%xmm5,%xmm7
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1689
  46977f:	mov    (%rdx),%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1682
  469782:	and    $0xfffffffffffffffc,%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1689
  469786:	shl    $0x4,%rsi
  46978a:	add    %r11,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1470
  46978d:	shl    $0x4,%r12
  469791:	prefetcht2 (%r14,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1236
  469796:	mov    %r10,(%rsi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1237
  469799:	vmovq  %xmm7,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1707
  46979e:	lea    0x1(%rdi),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1708
  4697a1:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1090
  4697a4:	add    $0x10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1708
  4697a8:	mov    %esi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1090
  4697ae:	cmp    %rdx,-0x20(%rsp)
  4697b3:	je     469550 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x730>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17get_find_queue_szEv():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:525
  4697b9:	mov    0xb4(%rcx),%eax
  4697bf:	mov    %esi,%edi
  4697c1:	sub    %eax,%esi
  4697c3:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1091
  4697c6:	cmp    %esi,%r8d
  4697c9:	jbe    4697ec <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9cc>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4697cb:	cmpq   $0x4,(%rsp)
  4697d0:	jne    46975b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x93b>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4697d2:	mov    $0xffffffff,%ebx
  4697d7:	crc32l (%rdx),%ebx
  4697dc:	vmovd  %ebx,%xmm6
  4697e0:	vmovdqa %xmm6,%xmm5
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  4697e4:	vmovq  %xmm6,-0x18(%rsp)
  4697ea:	jmp    46976c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x94c>
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1220
  4697ec:	mov    0x80(%rcx),%rbx
  4697f3:	mov    %rbx,-0x10(%rsp)
  4697f8:	nopl   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  469800:	lea    0x18(%rax),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  469803:	and    %r8d,%esi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1225
  469806:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  46980a:	mov    %ebx,%r9d
  46980d:	and    0x8(%r11,%rsi,1),%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  469812:	mov    %eax,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  469814:	mov    %r9,%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  469817:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  46981b:	shl    $0x4,%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  46981f:	add    %r11,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:620
  469822:	prefetcht0 (%r14,%r10,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1412
  469827:	mov    (%rsi),%r10
  46982a:	cmp    0x90(%rcx),%r10
  469831:	jne    469870 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa50>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1428
  469833:	kortestb %k2,%k2
  469837:	je     46985a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa3a>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1429
  469839:	mov    (%r15),%r12d
  46983c:	mov    0xc(%rsi),%esi
  46983f:	mov    %r12,%r10
  469842:	shl    $0x4,%r12
  469846:	add    0x8(%r15),%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1431
  46984a:	lea    0x1(%r10),%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1429
  46984e:	mov    %esi,(%r12)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1430
  469852:	mov    %r13,0x8(%r12)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1431
  469857:	mov    %r9d,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46985a:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46985c:	and    %r8d,%eax
  46985f:	mov    %eax,0xb4(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:626
  469865:	test   %r13,%r13
  469868:	jne    469800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9e0>
  46986a:	jmp    4697cb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9ab>
  46986f:	nop
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1225
  469870:	mov    0x8(%rsi),%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1275
  469874:	mov    %ebx,%r9d
  469877:	and    %r12d,%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1277
  46987a:	shl    $0x4,%r9
  46987e:	add    %r14,%r9
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469881:	vmovdqa64 (%r9),%zmm0
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  469887:	vpbroadcastq %r10,%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46988d:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1281
  469894:	kortestb %k0,%k0
  469898:	jne    469914 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaf4>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46989a:	vpcmpequq %zmm2,%zmm0,%k3{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1289
  4698a1:	kortestb %k3,%k3
  4698a5:	jne    469958 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb38>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4698ab:	cmpq   $0x4,(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1291
  4698b0:	mov    %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4698b3:	je     469981 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb61>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  4698b9:	cmpq   $0x8,(%rsp)
  4698be:	je     4699a1 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xb81>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  4698c4:	mov    -0x28(%rsp),%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1293
  4698c9:	mov    -0x10(%rsp),%r12
  4698ce:	vmovd  %r9d,%xmm4
  4698d3:	vpinsrd $0x1,0xc(%rsi),%xmm4,%xmm3
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  4698da:	mov    %edi,%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1293
  4698dc:	and    -0x28(%rsp),%r12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  4698e1:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1300
  4698e5:	inc    %edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  4698e7:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  4698e9:	add    %r11,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1470
  4698ec:	shl    $0x4,%r12
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1301
  4698f0:	and    %r8d,%edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4698f3:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1470
  4698f6:	prefetcht2 (%r14,%r12,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1236
  4698fb:	mov    %r10,(%rsi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1237
  4698fe:	vmovq  %xmm3,0x8(%rsi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1301
  469903:	mov    %edi,0xb0(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469909:	mov    %eax,0xb4(%rcx)
  46990f:	jmp    469800 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9e0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1282
  469914:	mov    (%r15),%r10d
  469917:	mov    0xc(%rsi),%r12d
  46991b:	mov    %r10,%rbx
  46991e:	shl    $0x4,%r10
  469922:	add    0x8(%r15),%r10
  469926:	mov    %r12d,(%r10)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  469929:	xor    %r12d,%r12d
  46992c:	kmovb  %k0,%esi
  469930:	tzcnt  %esi,%r12d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  469935:	inc    %r12d
  469938:	movslq %r12d,%rsi
  46993b:	mov    (%r9,%rsi,8),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46993f:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1284
  469941:	inc    %ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469943:	and    %r8d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  469946:	mov    %r9,0x8(%r10)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1284
  46994a:	mov    %ebx,(%r15)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46994d:	mov    %eax,0xb4(%rcx)
  469953:	jmp    4697cb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9ab>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469958:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46995a:	and    %r8d,%eax
  46995d:	mov    %eax,0xb4(%rcx)
  469963:	jmp    4697cb <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9ab>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469968:	mov    $0xffffffff,%eax
  46996d:	crc32q (%rdx),%rax
  469973:	mov    %rax,-0x18(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1689
  469978:	vmovd  %eax,%xmm5
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1689
  46997c:	jmp    46976c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x94c>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469981:	mov    $0xffffffff,%r9d
  469987:	crc32  %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  46998d:	mov    %r9d,%r12d
  469990:	mov    %r12,-0x28(%rsp)
  469995:	jmp    4698c9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaa9>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  46999a:	xor    %edi,%edi
  46999c:	jmp    46923e <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x41e>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4699a1:	mov    $0xffffffff,%r12d
  4699a7:	crc32  %r9,%r12
  4699ad:	mov    %r12,-0x28(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  4699b2:	mov    %r12d,%r9d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1299
  4699b5:	jmp    4698c9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaa9>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  4699ba:	incl   -0x2c(%rsp)
  4699be:	jmp    468fce <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1ae>
  4699c3:	incl   -0x2c(%rsp)
  4699c7:	vpxor  %xmm15,%xmm15,%xmm15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:788
  4699cc:	xor    %r11d,%r11d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:787
  4699cf:	vpxor  %xmm12,%xmm12,%xmm12
  4699d4:	jmp    468f52 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x132>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:807
  4699d9:	incl   -0x2c(%rsp)
  4699dd:	jmp    46904b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x22b>
