1. Implement the plot_merge.py file in this directory.
2. we will run it using: python plot_merge.py intel-paper.json intel-hbm.json amd-r6615.json test.pdf
3. Edit it so that it adheres to styles described in: /opt/DRAMHiT/scripts/eurosys_2026/PLOTTING.md
4. It should follow something similar to: /opt/DRAMHiT/scripts/eurosys_2026/collect_prefetches/plot_merge.py -- where we only plot the mops, we should also have the reprobes plotted, but only once, you can look at plot_data.py to see what is expected to be plotted for that. However, it's probably best to start the y-axis for reprobe plot at 1? since 1 means no reprobes?
5. keep progress in a new progress.md in this directory. 
6. append performance overview to progress, which lists performance numbers for all graphs at 70% fill. keep it brief.
