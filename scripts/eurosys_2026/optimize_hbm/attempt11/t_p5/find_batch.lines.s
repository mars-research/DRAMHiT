
/opt/DRAMHiT/scripts/eurosys_2026/optimize_hbm/attempt11/t_p5/dramhit:     file format elf64-x86-64


Disassembly of section .text:

0000000000468cc0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0>:
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:703
  468cc0:	push   %rbp
  468cc1:	mov    %rsp,%rbp
  468cc4:	push   %r15
  468cc6:	push   %r14
  468cc8:	push   %r13
  468cca:	push   %r12
  468ccc:	mov    %rdx,%r12
  468ccf:	push   %rbx
  468cd0:	and    $0xffffffffffffffc0,%rsp
  468cd4:	mov    0x8(%rsi),%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468cd8:	mov    0xb0(%rdi),%ecx
  468cde:	mov    0xb4(%rdi),%eax
  468ce4:	mov    (%rsi),%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:718
  468ce7:	mov    0x6c(%rdi),%r9d
  468ceb:	mov    0x78(%rdi),%esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:858
  468cee:	mov    %rbx,%r8
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468cf1:	mov    %ecx,%edx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:858
  468cf3:	shl    $0x4,%r8
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468cf7:	sub    %eax,%edx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:858
  468cf9:	lea    (%r11,%r8,1),%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:717
  468cfd:	and    %esi,%edx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:718
  468cff:	lea    -0x1(%r9),%r13d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:858
  468d03:	mov    %r10,-0x28(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:720
  468d08:	cmp    %r13d,%edx
  468d0b:	jb     4694af <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7ef>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:779
  468d11:	and    $0xfffffffffffffffc,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:729
  468d15:	mov    %ecx,%r10d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:779
  468d18:	shl    $0x4,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:736
  468d1c:	mov    0x80(%rdi),%ecx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468d22:	shl    $0x4,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:779
  468d26:	mov    %rbx,-0x38(%rsp)
  468d2b:	add    %r11,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468d2e:	mov    %r9,-0x8(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:779
  468d33:	mov    %rbx,-0x20(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:731
  468d38:	movl   $0x0,-0x30(%rsp)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:726
  468d40:	mov    0xa0(%rdi),%r8
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:732
  468d47:	mov    0x8(%r12),%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:745
  468d4c:	mov    0x29e95(%rip),%rsi        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:727
  468d53:	dec    %r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:728
  468d56:	shl    $0x4,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:729
  468d5a:	shl    $0x4,%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:736
  468d5e:	not    %ecx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:780
  468d60:	cmp    %rbx,%r11
  468d63:	je     46974b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa8b>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468d69:	mov    $0x55,%r15d
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  468d6f:	mov    $0x4444,%r14d
  468d75:	mov    %rdi,-0x40(%rsp)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468d7a:	vpxor  %xmm2,%xmm2,%xmm2
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468d7e:	mov    $0xffffffff,%r13d
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468d84:	kmovb  %r15d,%k1
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  468d89:	kmovw  %r14d,%k2
  468d8e:	jmp    468fce <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x30e>
  468d93:	nopl   0x0(%rax,%rax,1)
_Z10_tzcnt_u32j():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmiintrin.h:106
  468d98:	xor    %r15d,%r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  468d9b:	mov    0xc(%r14),%r14d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468d9f:	kmovb  %k4,%edi
_Z10_tzcnt_u32j():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmiintrin.h:106
  468da3:	tzcnt  %edi,%r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468da8:	inc    %r15d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  468dab:	mov    %r14d,(%rdx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468dae:	movslq %r15d,%r14
  468db1:	mov    (%rbx,%r14,8),%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:796
  468db5:	add    $0x10,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468db9:	mov    %rbx,-0x8(%rdx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  468dbd:	lea    0x180(%rax),%rdi
  468dc4:	and    %r9,%rdi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  468dc7:	andn   0x8(%r8,%rdi,1),%ecx,%r15d
  468dce:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  468dd2:	prefetcht0 (%rsi,%r15,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:786
  468dd7:	lea    (%r8,%rax,1),%r15
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:747
  468ddb:	mov    0x8(%r15),%edi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  468ddf:	andn   %edi,%ecx,%ebx
  468de4:	shl    $0x4,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:788
  468de8:	add    %rsi,%rbx
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468deb:	vmovdqa64 (%rbx),%zmm12
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:752
  468df1:	vpbroadcastq (%r15),%zmm13
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468df7:	vpcmpequq %zmm13,%zmm12,%k6{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:787
  468dfe:	add    $0x10,%rax
  468e02:	and    %r9,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:791
  468e05:	kortestb %k6,%k6
  468e09:	je     469428 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x768>
_Z10_tzcnt_u32j():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmiintrin.h:106
  468e0f:	xor    %edi,%edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  468e11:	mov    0xc(%r15),%r15d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468e15:	kmovb  %k6,%r14d
_Z10_tzcnt_u32j():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmiintrin.h:106
  468e19:	tzcnt  %r14d,%edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468e1e:	inc    %edi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  468e20:	mov    %r15d,(%rdx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468e23:	movslq %edi,%r15
  468e26:	mov    (%rbx,%r15,8),%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:796
  468e2a:	add    $0x10,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468e2e:	mov    %rbx,-0x8(%rdx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  468e32:	lea    0x180(%rax),%r14
  468e39:	and    %r9,%r14
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  468e3c:	andn   0x8(%r8,%r14,1),%ecx,%edi
  468e43:	shl    $0x4,%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:786
  468e47:	lea    (%r8,%rax,1),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  468e4b:	prefetcht0 (%rsi,%rdi,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:747
  468e4f:	mov    0x8(%r14),%edi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  468e53:	andn   %edi,%ecx,%ebx
  468e58:	shl    $0x4,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:788
  468e5c:	add    %rsi,%rbx
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468e5f:	vmovdqa64 (%rbx),%zmm0
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:752
  468e65:	vpbroadcastq (%r14),%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468e6b:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:787
  468e72:	add    $0x10,%rax
  468e76:	and    %r9,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:791
  468e79:	kortestb %k0,%k0
  468e7d:	je     4693e0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x720>
_Z10_tzcnt_u32j():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmiintrin.h:106
  468e83:	xor    %edi,%edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  468e85:	mov    0xc(%r14),%r14d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468e89:	kmovb  %k0,%r15d
_Z10_tzcnt_u32j():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmiintrin.h:106
  468e8d:	tzcnt  %r15d,%edi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468e92:	inc    %edi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  468e94:	mov    %r14d,(%rdx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468e97:	movslq %edi,%r14
  468e9a:	mov    (%rbx,%r14,8),%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:796
  468e9e:	add    $0x10,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468ea2:	mov    %rbx,-0x8(%rdx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:786
  468ea6:	lea    (%r8,%rax,1),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  468eaa:	lea    0x180(%rax),%r15
  468eb1:	and    %r9,%r15
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  468eb4:	andn   0x8(%r8,%r15,1),%ecx,%edi
  468ebb:	shl    $0x4,%rdi
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:747
  468ebf:	mov    0x8(%r14),%r15d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  468ec3:	andn   %r15d,%ecx,%ebx
  468ec8:	shl    $0x4,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:788
  468ecc:	add    %rsi,%rbx
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468ecf:	vmovdqa64 (%rbx),%zmm4
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:752
  468ed5:	vpbroadcastq (%r14),%zmm7
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  468edb:	vpcmpequq %zmm7,%zmm4,%k4{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:787
  468ee2:	add    $0x10,%rax
  468ee6:	and    %r9,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  468ee9:	prefetcht0 (%rsi,%rdi,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:791
  468eed:	kortestb %k4,%k4
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:812
  468ef1:	lea    (%r8,%r10,1),%rdi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:791
  468ef5:	je     469398 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6d8>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  468efb:	mov    0xc(%r14),%r14d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468eff:	kmovb  %k4,%r15d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:794
  468f03:	mov    %r14d,(%rdx)
_Z10_tzcnt_u32j():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/bmiintrin.h:106
  468f06:	xor    %r14d,%r14d
  468f09:	tzcnt  %r15d,%r14d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468f0e:	inc    %r14d
  468f11:	movslq %r14d,%r15
  468f14:	mov    (%rbx,%r15,8),%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:796
  468f18:	add    $0x10,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:795
  468f1c:	mov    %rbx,-0x8(%rdx)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468f20:	mov    %r13,%r14
  468f23:	crc32q (%r11),%r14
  468f29:	vmovq  %r14,%xmm9
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  468f2e:	andn   %r14d,%ecx,%ebx
  468f33:	shl    $0x4,%rbx
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468f37:	mov    %r13,%r14
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:826
  468f3a:	prefetcht2 (%rsi,%rbx,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468f3e:	mov    %r13,%rbx
  468f41:	crc32q 0x20(%r11),%rbx
  468f48:	crc32q 0x10(%r11),%r14
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  468f4f:	andn   %r14d,%ecx,%r15d
  468f54:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:826
  468f58:	prefetcht2 (%rsi,%r15,1)
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  468f5d:	andn   %ebx,%ecx,%r15d
  468f62:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:826
  468f66:	prefetcht2 (%rsi,%r15,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  468f6b:	mov    %r13,%r15
  468f6e:	vmovq  %rbx,%xmm10
  468f73:	crc32q 0x30(%r11),%r15
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  468f7a:	vmovdqu32 (%r11),%zmm14
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468f80:	vpinsrd $0x1,%r15d,%xmm10,%xmm11
  468f86:	vpinsrd $0x1,%r14d,%xmm9,%xmm12
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  468f8c:	andn   %r15d,%ecx,%ebx
  468f91:	shl    $0x4,%rbx
_Z13_mm_set_epi32iiii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:604
  468f95:	vpunpcklqdq %xmm11,%xmm12,%xmm13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:826
  468f9a:	prefetcht2 (%rsi,%rbx,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:840
  468f9e:	lea    0x40(%r10),%rbx
_Z24_mm512_mask_expand_epi32Dv8_xtS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:10974
  468fa2:	vpexpandd %zmm13,%zmm14{%k2}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:840
  468fa8:	cmp    %rbx,-0x8(%rsp)
  468fad:	jb     469470 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x7b0>
_Z19_mm512_storeu_si512PvDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6447
  468fb3:	vmovdqu64 %zmm14,(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:851
  468fb9:	and    %r9,%rbx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:780
  468fbc:	add    $0x40,%r11
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:851
  468fc0:	mov    %rbx,%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:780
  468fc3:	cmp    %r11,-0x20(%rsp)
  468fc8:	je     469068 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3a8>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:786
  468fce:	lea    (%r8,%rax,1),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  468fd2:	lea    0x180(%rax),%rbx
  468fd9:	and    %r9,%rbx
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE0_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:747
  468fdc:	mov    0x8(%r14),%r15d
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  468fe0:	andn   0x8(%r8,%rbx,1),%ecx,%edi
  468fe7:	shl    $0x4,%rdi
  468feb:	andn   %r15d,%ecx,%ebx
  468ff0:	shl    $0x4,%rbx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:788
  468ff4:	add    %rsi,%rbx
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  468ff7:	vmovdqa64 (%rbx),%zmm8
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUlPKNS3_7FindQ16EE1_clESJ_():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:752
  468ffd:	vpbroadcastq (%r14),%zmm9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469003:	vpcmpequq %zmm9,%zmm8,%k4{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:787
  46900a:	add    $0x10,%rax
  46900e:	and    %r9,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:785
  469011:	prefetcht0 (%rsi,%rdi,1)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:791
  469015:	kortestb %k4,%k4
  469019:	jne    468d98 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xd8>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46901f:	vpcmpequq %zmm2,%zmm8,%k5{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:799
  469026:	kortestb %k5,%k5
  46902a:	jne    469774 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xab4>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  469030:	vmovdqu (%r14),%xmm10
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469035:	mov    %r13,%rdi
  469038:	crc32  %r15,%rdi
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  46903e:	vpinsrd $0x2,%edi,%xmm10,%xmm11
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  469044:	andn   %edi,%ecx,%r15d
  469049:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:809
  46904d:	prefetcht2 (%rsi,%r15,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469052:	vmovdqu %xmm11,(%r8,%r10,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:814
  469058:	add    $0x10,%r10
  46905c:	and    %r9,%r10
  46905f:	jmp    468fce <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x30e>
  469064:	nopl   0x0(%rax)
  469068:	mov    -0x40(%rsp),%rdi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:856
  46906d:	mov    -0x30(%rsp),%ebx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:854
  469071:	vmovq  %r10,%xmm15
  469076:	vpinsrq $0x1,%rax,%xmm15,%xmm0
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:856
  46907c:	mov    -0x38(%rsp),%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:854
  469081:	vpsrlq $0x4,%xmm0,%xmm1
  469086:	vpmovqd %xmm1,%xmm6
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:856
  46908c:	sar    $0x4,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:854
  469090:	vmovq  %xmm6,0xb0(%rdi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:856
  469098:	sub    %rbx,%rdx
  46909b:	add    %edx,(%r12)
  46909f:	vpextrd $0x1,%xmm6,%eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:858
  4690a5:	cmp    -0x28(%rsp),%r11
  4690aa:	je     469380 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1663
  4690b0:	mov    0x88(%rdi),%r15
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1204
  4690b7:	mov    0x80(%rdi),%rbx
  4690be:	mov    0x60(%rdi),%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1663
  4690c2:	dec    %r15
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1204
  4690c5:	mov    %rbx,-0x20(%rsp)
  4690ca:	mov    %rcx,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1663
  4690cf:	mov    %r15,-0x30(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  4690d4:	mov    0x78(%rdi),%r9d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4690d8:	mov    0x29b09(%rip),%r10        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
  4690df:	mov    0xa0(%rdi),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1412
  4690e6:	movzbl 0x29a12(%rip),%r14d        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1414
  4690ee:	mov    0x29a13(%rip),%r13        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4690f5:	mov    $0x55,%esi
  4690fa:	vpxor  %xmm7,%xmm7,%xmm7
  4690fe:	kmovb  %esi,%k3
  469102:	nopw   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  469108:	lea    0x18(%rax),%edx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  46910b:	and    %r9d,%edx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1209
  46910e:	shl    $0x4,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  469112:	mov    %ebx,%ecx
  469114:	and    0x8(%r8,%rdx,1),%ecx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  469119:	mov    %eax,%edx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  46911b:	mov    %rcx,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  46911e:	shl    $0x4,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  469122:	shl    $0x4,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  469126:	add    %r8,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:620
  469129:	prefetcht0 (%r10,%rsi,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1396
  46912e:	mov    (%rdx),%rsi
  469131:	cmp    0x90(%rdi),%rsi
  469138:	jne    4691f0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x530>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1412
  46913e:	test   %r14b,%r14b
  469141:	je     469163 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4a3>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1413
  469143:	mov    (%r12),%r15d
  469147:	mov    0xc(%rdx),%edx
  46914a:	mov    %r15,%rsi
  46914d:	shl    $0x4,%r15
  469151:	add    0x8(%r12),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1415
  469156:	inc    %esi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1413
  469158:	mov    %edx,(%r15)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1414
  46915b:	mov    %r13,0x8(%r15)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1415
  46915f:	mov    %esi,(%r12)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469163:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469165:	and    %r9d,%eax
  469168:	mov    %eax,0xb4(%rdi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:626
  46916e:	test   %r13,%r13
  469171:	jne    469108 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  469173:	cmpq   $0x4,-0x8(%rsp)
  469179:	je     4692e8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x628>
  46917f:	nop
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  469180:	cmpq   $0x8,-0x8(%rsp)
  469186:	je     469360 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6a0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1673
  46918c:	vmovd  -0x18(%rsp),%xmm10
  469192:	mov    (%r11),%rcx
  469195:	mov    0xb0(%rdi),%edx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1663
  46919b:	mov    -0x30(%rsp),%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1673
  4691a0:	mov    %rdx,%rax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1663
  4691a3:	and    -0x18(%rsp),%rsi
  4691a8:	vpinsrd $0x1,0xc(%r11),%xmm10,%xmm12
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1666
  4691af:	and    $0xfffffffffffffffc,%rsi
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1673
  4691b3:	shl    $0x4,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1691
  4691b7:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1673
  4691b9:	add    %r8,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1454
  4691bc:	shl    $0x4,%rsi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1692
  4691c0:	and    %r9d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:858
  4691c3:	add    $0x10,%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1454
  4691c7:	prefetcht2 (%r10,%rsi,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1220
  4691cc:	mov    %rcx,(%rdx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1221
  4691cf:	vmovq  %xmm12,0x8(%rdx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1692
  4691d4:	mov    %eax,0xb0(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:858
  4691da:	cmp    -0x28(%rsp),%r11
  4691df:	je     469380 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  4691e5:	mov    0xb4(%rdi),%eax
  4691eb:	jmp    469108 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1209
  4691f0:	mov    0x8(%rdx),%r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1259
  4691f4:	mov    %ebx,%ecx
  4691f6:	and    %r15d,%ecx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1261
  4691f9:	shl    $0x4,%rcx
  4691fd:	add    %r10,%rcx
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469200:	vmovdqa64 (%rcx),%zmm3
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  469206:	vpbroadcastq %rsi,%zmm4
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46920c:	vpcmpequq %zmm4,%zmm3,%k0{%k3}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1265
  469213:	kortestb %k0,%k0
  469217:	jne    4692a0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x5e0>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46921d:	vpcmpequq %zmm7,%zmm3,%k4{%k3}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1273
  469224:	kortestb %k4,%k4
  469228:	jne    469310 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x650>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46922e:	cmpq   $0x4,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1275
  469234:	mov    %r15d,%ecx
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  469237:	je     469320 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x660>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  46923d:	cmpq   $0x8,-0x8(%rsp)
  469243:	je     469340 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x680>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  469249:	vmovd  -0x10(%rsp),%xmm5
  46924f:	mov    0xb0(%rdi),%ecx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1277
  469255:	mov    -0x20(%rsp),%r15
  46925a:	vpinsrd $0x1,0xc(%rdx),%xmm5,%xmm9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  469261:	mov    %rcx,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1277
  469264:	and    -0x10(%rsp),%r15
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  469269:	shl    $0x4,%rcx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1284
  46926d:	inc    %edx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46926f:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  469271:	add    %r8,%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1454
  469274:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  469278:	and    %r9d,%edx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46927b:	and    %r9d,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1454
  46927e:	prefetcht2 (%r10,%r15,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1220
  469283:	mov    %rsi,(%rcx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1221
  469286:	vmovq  %xmm9,0x8(%rcx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  46928b:	mov    %edx,0xb0(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469291:	mov    %eax,0xb4(%rdi)
  469297:	jmp    469108 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x448>
  46929c:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1266
  4692a0:	mov    (%r12),%esi
  4692a4:	mov    0xc(%rdx),%edx
  4692a7:	mov    %rsi,%r15
  4692aa:	shl    $0x4,%rsi
  4692ae:	add    0x8(%r12),%rsi
  4692b3:	mov    %edx,(%rsi)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  4692b5:	kmovb  %k0,%edx
  4692b9:	tzcnt  %edx,%edx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1267
  4692bd:	inc    %edx
  4692bf:	movslq %edx,%rdx
  4692c2:	mov    (%rcx,%rdx,8),%rcx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  4692c6:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1268
  4692c8:	inc    %r15d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4692cb:	and    %r9d,%eax
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4692ce:	cmpq   $0x4,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1267
  4692d4:	mov    %rcx,0x8(%rsi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1268
  4692d8:	mov    %r15d,(%r12)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4692dc:	mov    %eax,0xb4(%rdi)
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  4692e2:	jne    469180 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4c0>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  4692e8:	mov    $0xffffffff,%r15d
  4692ee:	crc32l (%r11),%r15d
  4692f4:	vmovd  %r15d,%xmm11
  4692f9:	mov    (%r11),%rcx
  4692fc:	vmovdqa %xmm11,%xmm10
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  469301:	vmovq  %xmm11,-0x18(%rsp)
  469307:	jmp    469195 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4d5>
  46930c:	nopl   0x0(%rax)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469310:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  469312:	and    %r9d,%eax
  469315:	mov    %eax,0xb4(%rdi)
  46931b:	jmp    469173 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4b3>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469320:	mov    $0xffffffff,%ecx
  469325:	crc32  %r15d,%ecx
  46932b:	vmovd  %ecx,%xmm8
  46932f:	vmovdqa %xmm8,%xmm5
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  469333:	vmovq  %xmm8,-0x10(%rsp)
  469339:	jmp    46924f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x58f>
  46933e:	xchg   %ax,%ax
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469340:	mov    $0xffffffff,%r15d
  469346:	crc32  %rcx,%r15
  46934c:	mov    %r15,-0x10(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  469351:	vmovd  %r15d,%xmm5
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  469356:	jmp    46924f <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x58f>
  46935b:	nopl   0x0(%rax,%rax,1)
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469360:	mov    (%r11),%rcx
  469363:	mov    $0xffffffff,%eax
  469368:	crc32  %rcx,%rax
  46936e:	mov    %rax,-0x18(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1673
  469373:	vmovd  %eax,%xmm10
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1673
  469377:	jmp    469195 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x4d5>
  46937c:	nopl   0x0(%rax)
  469380:	vzeroupper 
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:705
  469383:	lea    -0x28(%rbp),%rsp
  469387:	pop    %rbx
  469388:	pop    %r12
  46938a:	pop    %r13
  46938c:	pop    %r14
  46938e:	pop    %r15
  469390:	pop    %rbp
  469391:	ret    
  469392:	nopw   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469398:	vpcmpequq %zmm2,%zmm4,%k5{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:799
  46939f:	kortestb %k5,%k5
  4693a3:	jne    469786 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xac6>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  4693a9:	vmovdqu (%r14),%xmm5
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4693ae:	mov    %r13,%rbx
  4693b1:	crc32  %r15,%rbx
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  4693b7:	vpinsrd $0x2,%ebx,%xmm5,%xmm8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:814
  4693bd:	add    $0x10,%r10
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  4693c1:	andn   %ebx,%ecx,%r15d
  4693c6:	shl    $0x4,%r15
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:814
  4693ca:	and    %r9,%r10
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:809
  4693cd:	prefetcht2 (%rsi,%r15,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  4693d2:	vmovdqu %xmm8,(%rdi)
  4693d6:	jmp    468ea6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1e6>
  4693db:	nopl   0x0(%rax,%rax,1)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4693e0:	vpcmpequq %zmm2,%zmm0,%k3{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:799
  4693e7:	kortestb %k3,%k3
  4693eb:	jne    46977d <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xabd>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  4693f1:	vmovdqu (%r14),%xmm6
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  4693f6:	mov    %r13,%r15
  4693f9:	crc32  %rdi,%r15
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  4693ff:	vpinsrd $0x2,%r15d,%xmm6,%xmm3
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  469405:	andn   %r15d,%ecx,%edi
  46940a:	shl    $0x4,%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:809
  46940e:	prefetcht2 (%rsi,%rdi,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  469412:	vmovdqu %xmm3,(%r8,%r10,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:814
  469418:	add    $0x10,%r10
  46941c:	and    %r9,%r10
  46941f:	jmp    468e32 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x172>
  469424:	nopl   0x0(%rax)
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  469428:	vpcmpequq %zmm2,%zmm12,%k7{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:799
  46942f:	kortestb %k7,%k7
  469433:	jne    46976b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xaab>
_Z15_mm_loadu_si128PKDv2_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:703
  469439:	vmovdqu (%r15),%xmm14
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  46943e:	mov    %r13,%r14
  469441:	crc32  %rdi,%r14
_Z16_mm_insert_epi32Dv2_xii():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:408
  469447:	vpinsrd $0x2,%r14d,%xmm14,%xmm15
_ZZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEEENKUljE_clEj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:742
  46944d:	andn   %r14d,%ecx,%edi
  469452:	shl    $0x4,%rdi
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:809
  469456:	prefetcht2 (%rsi,%rdi,1)
_Z16_mm_storeu_si128PDv2_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/emmintrin.h:739
  46945a:	vmovdqu %xmm15,(%r8,%r10,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:814
  469460:	add    $0x10,%r10
  469464:	and    %r9,%r10
  469467:	jmp    468dbd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xfd>
  46946c:	nopl   0x0(%rax)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:846
  469470:	mov    -0x8(%rsp),%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:847
  469475:	mov    $0x1,%r15d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:846
  46947b:	sub    %r10,%r14
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:847
  46947e:	shr    $0x2,%r14
  469482:	shlx   %r14d,%r15d,%r14d
  469487:	lea    -0x1(%r14),%r15d
_Z24_mm512_mask_storeu_epi32PvtDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6461
  46948b:	kmovw  %r15d,%k6
  469490:	vmovdqu32 %zmm14,(%rdi){%k6}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:849
  469496:	sub    -0x8(%rsp),%r10
  46949b:	neg    %r14d
_Z24_mm512_mask_storeu_epi32PvtDv8_x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:6461
  46949e:	kmovw  %r14d,%k7
  4694a3:	vmovdqu32 %zmm14,(%r8,%r10,1){%k7}
  4694aa:	jmp    468fb9 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x2f9>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1074
  4694af:	cmp    -0x28(%rsp),%r11
  4694b4:	je     469383 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c3>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1663
  4694ba:	mov    0x88(%rdi),%r8
  4694c1:	mov    0x60(%rdi),%r9
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4694c5:	mov    $0x55,%ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1663
  4694ca:	dec    %r8
  4694cd:	mov    %r9,-0x8(%rsp)
  4694d2:	mov    %r8,-0x10(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4694d7:	mov    0x2970a(%rip),%r15        # 492be8 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE9hashtableE>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1414
  4694de:	mov    0x29623(%rip),%r14        # 492b08 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11empty_slot_E>
  4694e5:	mov    0xa0(%rdi),%r10
  4694ec:	mov    %ecx,%r13d
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4694ef:	vpxor  %xmm2,%xmm2,%xmm2
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1412
  4694f3:	kmovb  0x29605(%rip),%k2        # 492b00 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE18empty_slot_exists_E>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  4694fb:	kmovb  %ebx,%k1
  4694ff:	jmp    46956b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8ab>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  469501:	cmpq   $0x8,-0x8(%rsp)
  469507:	je     469719 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa59>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1673
  46950d:	vmovd  -0x20(%rsp),%xmm4
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1663
  469513:	mov    -0x10(%rsp),%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1673
  469518:	mov    %ecx,%edx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1663
  46951a:	and    -0x20(%rsp),%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1666
  46951f:	and    $0xfffffffffffffffc,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1454
  469523:	shl    $0x4,%r13
  469527:	vpinsrd $0x1,0xc(%r11),%xmm4,%xmm5
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1673
  46952e:	mov    (%r11),%r9
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1454
  469531:	prefetcht2 (%r15,%r13,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1673
  469536:	shl    $0x4,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1691
  46953a:	lea    0x1(%rcx),%r13d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1673
  46953e:	add    %r10,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1692
  469541:	and    %esi,%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1074
  469544:	add    $0x10,%r11
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1220
  469548:	mov    %r9,(%rdx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1221
  46954b:	vmovq  %xmm5,0x8(%rdx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1692
  469550:	mov    %r13d,0xb0(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1074
  469557:	cmp    %r11,-0x28(%rsp)
  46955c:	je     469380 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x6c0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE17get_find_queue_szEv():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:525
  469562:	mov    0xb4(%rdi),%eax
  469568:	mov    %r13d,%ecx
  46956b:	sub    %eax,%r13d
  46956e:	and    %esi,%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1075
  469571:	cmp    %r13d,%esi
  469574:	jbe    46959c <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8dc>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  469576:	cmpq   $0x4,-0x8(%rsp)
  46957c:	jne    469501 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x841>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  46957e:	mov    $0xffffffff,%ebx
  469583:	crc32l (%r11),%ebx
  469589:	vmovd  %ebx,%xmm7
  46958d:	vmovdqa %xmm7,%xmm4
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  469591:	vmovq  %xmm7,-0x20(%rsp)
  469597:	jmp    469513 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x853>
_ZNK11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16E():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1204
  46959c:	mov    0x80(%rdi),%rbx
  4695a3:	mov    %rbx,-0x18(%rsp)
  4695a8:	nopl   0x0(%rax,%rax,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:618
  4695b0:	lea    0x18(%rax),%edx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4695b3:	and    %esi,%edx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1209
  4695b5:	shl    $0x4,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4695b9:	mov    %ebx,%r13d
  4695bc:	and    0x8(%r10,%rdx,1),%r13d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  4695c1:	mov    %eax,%edx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4695c3:	mov    %r13,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  4695c6:	shl    $0x4,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:619
  4695ca:	shl    $0x4,%r9
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:622
  4695ce:	add    %r10,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:620
  4695d1:	prefetcht0 (%r15,%r9,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10__find_oneEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1396
  4695d6:	mov    (%rdx),%r9
  4695d9:	cmp    0x90(%rdi),%r9
  4695e0:	jne    469620 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x960>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12__find_emptyEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1412
  4695e2:	kortestb %k2,%k2
  4695e6:	je     46960b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x94b>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1413
  4695e8:	mov    (%r12),%r13d
  4695ec:	mov    0xc(%rdx),%edx
  4695ef:	mov    %r13,%r9
  4695f2:	shl    $0x4,%r13
  4695f6:	add    0x8(%r12),%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1415
  4695fb:	lea    0x1(%r9),%r8d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1413
  4695ff:	mov    %edx,0x0(%r13)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1414
  469603:	mov    %r14,0x8(%r13)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1415
  469607:	mov    %r8d,(%r12)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46960b:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46960d:	and    %esi,%eax
  46960f:	mov    %eax,0xb4(%rdi)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:626
  469615:	test   %r14,%r14
  469618:	jne    4695b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8f0>
  46961a:	jmp    469576 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8b6>
  46961f:	nop
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_idxEPKNS3_7FindQ16Ej():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1209
  469620:	mov    0x8(%rdx),%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1259
  469624:	mov    %ebx,%r8d
  469627:	and    %r13d,%r8d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1261
  46962a:	shl    $0x4,%r8
  46962e:	add    %r15,%r8
_Z17_mm512_load_si512PKv():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:542
  469631:	vmovdqa64 (%r8),%zmm0
_Z17_mm512_set1_epi64x():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:4149
  469637:	vpbroadcastq %r9,%zmm1
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46963d:	vpcmpequq %zmm1,%zmm0,%k0{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1265
  469644:	kortestb %k0,%k0
  469648:	jne    4696c4 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa04>
_Z28_mm512_mask_cmpeq_epu64_maskhDv8_xS_():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/avx512fintrin.h:15880
  46964a:	vpcmpequq %zmm2,%zmm0,%k3{%k1}
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1273
  469651:	kortestb %k3,%k3
  469655:	jne    46970a <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa4a>
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  46965b:	cmpq   $0x4,-0x8(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1275
  469661:	mov    %r13d,%r8d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:37
  469664:	je     469732 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa72>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:39
  46966a:	cmpq   $0x8,-0x8(%rsp)
  469670:	je     469752 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xa92>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  469676:	mov    -0x30(%rsp),%r8d
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1277
  46967b:	mov    -0x18(%rsp),%r13
  469680:	vmovd  %r8d,%xmm6
  469685:	vpinsrd $0x1,0xc(%rdx),%xmm6,%xmm3
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  46968c:	mov    %ecx,%edx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1277
  46968e:	and    -0x30(%rsp),%r13
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  469693:	shl    $0x4,%rdx
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1284
  469697:	inc    %ecx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  469699:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  46969b:	add    %r10,%rdx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1454
  46969e:	shl    $0x4,%r13
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  4696a2:	and    %esi,%ecx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4696a4:	and    %esi,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE13prefetch_readEm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1454
  4696a6:	prefetcht2 (%r15,%r13,1)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE6fq_putEPNS3_7FindQ16Emjj():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1220
  4696ab:	mov    %r9,(%rdx)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1221
  4696ae:	vmovq  %xmm3,0x8(%rdx)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1285
  4696b3:	mov    %ecx,0xb0(%rdi)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4696b9:	mov    %eax,0xb4(%rdi)
  4696bf:	jmp    4695b0 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8f0>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1266
  4696c4:	mov    (%r12),%r9d
  4696c8:	mov    0xc(%rdx),%r13d
  4696cc:	mov    %r9,%rbx
  4696cf:	shl    $0x4,%r9
  4696d3:	add    0x8(%r12),%r9
  4696d8:	mov    %r13d,(%r9)
_Z6__bsfdi():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/ia32intrin.h:33
  4696db:	xor    %r13d,%r13d
  4696de:	kmovb  %k0,%edx
  4696e2:	tzcnt  %edx,%r13d
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1267
  4696e7:	inc    %r13d
  4696ea:	movslq %r13d,%rdx
  4696ed:	mov    (%r8,%rdx,8),%r8
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  4696f1:	inc    %eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1268
  4696f3:	inc    %ebx
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4696f5:	and    %esi,%eax
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1267
  4696f7:	mov    %r8,0x8(%r9)
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1268
  4696fb:	mov    %ebx,(%r12)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE14pop_find_queueERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  4696ff:	mov    %eax,0xb4(%rdi)
  469705:	jmp    469576 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8b6>
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:623
  46970a:	inc    %eax
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:624
  46970c:	and    %esi,%eax
  46970e:	mov    %eax,0xb4(%rdi)
  469714:	jmp    469576 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x8b6>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469719:	mov    $0xffffffff,%eax
  46971e:	crc32q (%r11),%rax
  469724:	mov    %rax,-0x20(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE19add_to_find_queue_tINS_12FindArgumentEEEvPKT_PNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1673
  469729:	vmovd  %eax,%xmm4
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1673
  46972d:	jmp    469513 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x853>
_Z13_mm_crc32_u32jj():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:841
  469732:	mov    $0xffffffff,%r8d
  469738:	crc32  %r13d,%r8d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/hasher.hpp:38
  46973e:	mov    %r8d,%r13d
  469741:	mov    %r13,-0x30(%rsp)
  469746:	jmp    46967b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9bb>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:780
  46974b:	xor    %ebx,%ebx
  46974d:	jmp    469071 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x3b1>
_Z13_mm_crc32_u64yy():
/nix/store/bqfdbk52z5ym3sfhaf4yvi7l1fq27bky-gcc-11.3.0/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include/smmintrin.h:848
  469752:	mov    $0xffffffff,%r13d
  469758:	crc32  %r8,%r13
  46975e:	mov    %r13,-0x30(%rsp)
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE11__find_simdEPNS3_7FindQ16ERSt4pairIjPNS_10FindResultEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  469763:	mov    %r13d,%r8d
_ZN11kmercounter6HasherclEPKvm():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:1283
  469766:	jmp    46967b <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x9bb>
_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE15find_batch_implINS_12FindArgumentEEEvSt4spanIT_Lm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE():
/tmp/nix-shell.cK9059/claude-20023/-opt-DRAMHiT-scripts-eurosys-2026-optimize-hbm/704870cb-14ae-4b8a-a7d0-7aabcf2572db/scratchpad/src/include/./hashtables/cas_kht.hpp:800
  46976b:	incl   -0x30(%rsp)
  46976f:	jmp    468e32 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x172>
  469774:	incl   -0x30(%rsp)
  469778:	jmp    468dbd <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0xfd>
  46977d:	incl   -0x30(%rsp)
  469781:	jmp    468ea6 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x1e6>
  469786:	incl   -0x30(%rsp)
  46978a:	jmp    468f20 <_ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE10find_batchERKSt4spanINS_12FindArgumentELm18446744073709551615EERSt4pairIjPNS_10FindResultEEPNS_16LatencyCollectorILm2048EEE.constprop.0+0x260>
