
1. We are having too much noise in our collect_data.py.
2. Rewrite it and rerun it so that it follows a similar structure to ../macro_uniform/collect_data_intel.py
3. we should also adjust plot_merge.py so that it plots variance if available such as ../macro_uniform/plot_data_bw.py
4. In general the idea is to collect multiple runs, and takes a median, or avg. and record that data into json, then replot.
5. do not overwrite any .json file, save the intel DDR run as a different .json file, we will still use intel-hbm.json and amd-r6615.json for this, we will re-run those later. 
6. Keep progress of this in a new progress_replot.md