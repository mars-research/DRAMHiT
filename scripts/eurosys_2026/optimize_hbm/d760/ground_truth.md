# dramblast deep build (dvk_rka) ground truth, d760 socket 0

| metric | fill 10 | fill 70 |
|---|---|---|
| thread_cycles_per_find | 47.32 | 55.31 |
| core_cycles_per_find | 23.66 | 27.65 |
| finds_mops | 3381.00 | 2892.00 |
| thread_cycles_per_find_batch_call | 3028.56 | 3539.65 |
| find_batch_cycle_share | 0.798 | 0.819 |
| find_batch_thread_cycles_per_find | 37.76 | 45.31 |
| find_batch_thread_cycles_per_call | 2416.49 | 2899.68 |
| instructions_per_find | 43.18 | 47.65 |
| ipc_thread | 0.912 | 0.861 |
| dram_rd_lines_per_find | 1.12 | 1.28 |
| dram_wr_lines_per_find | 0.00 | 0.00 |
| dram_rd_GBps | 241.45 | 237.24 |
| llc_miss_drd_per_find | 1.12 | 1.28 |
| llc_miss_drd_latency_ns | 160.55 | 150.48 |
| offcore_data_rd_per_find | 1.14 | 1.30 |
| offcore_data_rd_latency_cycles | 1059.15 | 1103.37 |
| l1_pending_misses_avg | 0.21 | 0.17 |
| fb_full_frac_cycles | 0.765 | 0.765 |
| stalls_total_frac | 0.623 | 0.591 |
| stalls_l1d_miss_frac | 0.151 | 0.121 |

## all events, per find (median over runs; core events summed over socket 0's 64 threads)

| event | fill 10 | fill 70 |
|---|---|---|
| br_inst_retired.all_branches | 3.6286 | 4.0846 |
| br_misp_retired.all_branches | 0.0044 | 0.1821 |
| cycle_activity.stalls_l1d_miss | 7.1488 | 6.6727 |
| cycle_activity.stalls_total | 29.4909 | 32.6844 |
| cycles | 47.3569 | 55.3119 |
| instructions | 43.1849 | 47.6500 |
| int_misc.mba_stalls | 0.0000 | 0.0000 |
| int_misc.recovery_cycles | 0.0229 | 0.8754 |
| l1d.replacement | 1.1694 | 1.3238 |
| l1d_pend_miss.fb_full | 36.2231 | 42.3355 |
| l1d_pend_miss.l2_stalls | 3.2386 | 3.6526 |
| l1d_pend_miss.pending | 9.9791 | 9.5423 |
| l1d_pend_miss.pending_cycles | 9.0624 | 8.6794 |
| l2_lines_in.all | 1.1454 | 1.2998 |
| l2_rqsts.swpf_hit | 0.9572 | 1.1041 |
| l2_rqsts.swpf_miss | 0.4060 | 0.4673 |
| load_hit_prefetch.swpf | 0.0146 | 0.0144 |
| mem_load_retired.fb_hit | 0.7295 | 0.7304 |
| mem_load_retired.l1_hit | 9.9749 | 10.9998 |
| mem_load_retired.l1_miss | 0.1441 | 0.1461 |
| mem_load_retired.l2_miss | 0.0082 | 0.0080 |
| mem_load_retired.l3_miss | 0.0057 | 0.0053 |
| offcore_requests.data_rd | 1.1422 | 1.2999 |
| offcore_requests_outstanding.cycles_with_data_rd | 47.3169 | 55.4609 |
| offcore_requests_outstanding.data_rd | 1209.7507 | 1434.2457 |
| ref-cycles | 47.4601 | 55.4342 |
| resource_stalls.sb | 3.7989 | 3.6892 |
| resource_stalls.scoreboard | 0.1634 | 0.3442 |
| sw_prefetch_access.t0 | 1.0119 | 1.1798 |
| sw_prefetch_access.t1_t2 | 1.1385 | 1.3138 |
| topdown.backend_bound_slots | 90.1424 | 89.6783 |
| topdown.bad_spec_slots | 0.3492 | 16.6516 |
| topdown.memory_bound_slots | 33.6387 | 31.1127 |
| unc_cha_tor_inserts.ia_miss_drd | 1.1156 | 1.2815 |
| unc_cha_tor_inserts.ia_miss_drd_pref | 0.0000 | 0.0000 |
| unc_cha_tor_occupancy.ia_miss_drd | 447.7729 | 482.1042 |
| unc_m_cas_count.rd | 1.1159 | 1.2818 |
| unc_m_cas_count.wr | 0.0007 | 0.0007 |
| uops_dispatched.port_0 | 4.2030 | 5.3244 |
| uops_dispatched.port_1 | 4.1300 | 5.4456 |
| uops_dispatched.port_2_3_10 | 10.8873 | 14.0439 |
| uops_dispatched.port_4_9 | 5.9321 | 6.4117 |
| uops_dispatched.port_5_11 | 9.9474 | 12.7818 |
| uops_dispatched.port_6 | 5.2499 | 6.6081 |
| uops_dispatched.port_7_8 | 4.6575 | 5.4898 |
| uops_issued.any | 44.8952 | 62.8303 |
| uops_retired.slots | 42.9014 | 47.8445 |
