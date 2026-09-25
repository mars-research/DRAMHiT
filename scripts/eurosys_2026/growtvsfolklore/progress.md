# merge_plot.py → PLOTTING.md conformance

Task: bring `merge_plot.py` in line with `../PLOTTING.md` / `../paper_style.py`,
then replot `combined_perf.pdf`.

## Audit (what was off)

- [x] `growt` is not in `PALETTE_ORDER`; it got an ad-hoc `'gray'` from a
      rotating fallback list, so its colour depended on file order.
- [x] Styles built per series by hand instead of `ps.styles_for()`.
- [x] `linewidth=2` override — no other paper figure thickens its lines.
- [x] Bandwidth lines hard-code `--` + `^`, which is the spelling
      `VARIANT_STYLE` uses for `*_nopref` / `dlht_batch16`.
- [x] Legend hand-rolled with `frameon=False` and its own kwargs, diverging from
      `ps.add_legend()`.
- [x] Baselines coloured from `palette[i]`, i.e. with hashtable colours.
- [x] Fill factors hard-coded `range(10,100,10)` rather than read from the log.
- [x] No `set_xlim` padding like the other fill sweeps; titles/labels in Title
      Case ("Insert Performance", "Bandwidth (GB/s)", "MOPS") vs the paper's
      lower case ("insertion", "throughput (Mops)").
- [x] Twin bandwidth axis draws a second whitegrid that doesn't line up with
      the throughput grid.

## Log

- Rewrote the plotting half of `merge_plot.py`; parsers untouched apart from a
  new `parse_fills()` that reads `--ht-fill N` from the echoed command lines.
- Colours: `ps.configure_palette()` at full size + `ps.styles_for()`. `growt`
  (outside `PALETTE_ORDER`) gets a fixed grey via `OUTSIDE_PALETTE` rather than
  being appended to `PALETTE_ORDER`, since that would resize the palette and
  recolour every other figure.
- Bandwidth curves: same colour, `--` + hollow `D` marker (`BW_STYLE`); `D` is
  not claimed by any `VARIANT_STYLE` entry.
- Baselines (all commented out) now draw in neutral greys, not palette slots.
- Legend uses `ps.add_legend()`'s kwargs + `ps.display_name()`, plus two black
  keys for throughput vs bandwidth.
- Titles `insertion` / `lookup`, lower-case axis labels, `set_xlim(±5)`,
  `set_ylim(bottom=0)` on both axes, `ps.tidy()` on the Mops axis, twin grid off.
- Replotted: `python3 merge_plot.py folklore.txt growt.txt dramblast.txt`
  → `combined_perf.pdf` (usetex on). Numbers printed match the old run.

## Open / not done

- No band: each fill point is a single run (PLOTTING.md §3 wants repeats +
  samples). Would need `collect.sh` to repeat each point.
- Output stays `.pdf` (the existing artifact name), not `.png` like the guide examples.
- If growt ends up in several figures, it should get a proper entry in
  `paper_style.py` (e.g. a fixed colour map for tables outside the palette).
