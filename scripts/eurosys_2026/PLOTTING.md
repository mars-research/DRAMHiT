# Plotting guide — eurosys_2026 figures

Every figure in this tree is drawn through one module, **`paper_style.py`**,
which sits next to this file. Import it and the figure comes out looking like
the rest of the paper: same fonts, same palette, same grid, same legend, and
— the part that is easy to get wrong — the same colour for the same hashtable
across directories.

```python
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))  # eurosys_2026/

import paper_style as ps
```

`macro_uniform/plot_data.py` is the shortest complete example; `collect_join/plot_data.py`
is the one the style was lifted from (it still carries its own copy of the
helpers — treat `paper_style.py` as the source of truth for new work).

---

## 1. The rules that matter

**Build the palette at full size, always.** `ps.configure_palette()` returns
five colours, one per entry in `PALETTE_ORDER`, and a series takes the slot
its canonical name holds in that list:

```python
PALETTE_ORDER = ["cas", "cas23", "dlht", "folklore", "radix"]
```

A figure that plots only three of the five still calls
`configure_palette()` with no argument and looks each series up by name via
`ps.series_style(name, palette)`. Rebuilding the palette at `n=3` would
recolour those three and silently break every cross-figure comparison a
reader makes. Pass an explicit `n` only for a sweep whose series are not
hashtables at all (prefetch distances, thread counts, …).

**Plot with the canonical name, label with the display name.** The code
stores `cas` / `cas23`; the page says `dramblast` / `dramhit`.
`ps.display_name()` does the translation and `ps.add_legend()` calls it for
you, so neither the data files nor the lookups have to change when the paper
renames something. `ps.ALIASES` absorbs whatever a collector happened to
write (`dramhit_2025`, `hash_cas`, `FOLKLORE`, …) so an old json still lands
on the right colour.

**Order series with `ps.order_series()`,** not with `sorted()`. It sorts into
`PALETTE_ORDER` and puts anything unrecognised last, so the legend reads in
the same order in every figure.

**A variant is not a new series.** A run that is the same algorithm under
different conditions (`radix (all cpus)`) reuses its base colour and is told
apart by dash and marker — see `ps.VARIANT_STYLE`. Spending a palette slot on
it makes it look like a sixth competitor.

---

## 2. The shape of a plotter

```python
ps.configure_style()                 # fonts, seaborn context + whitegrid
palette = ps.configure_palette()     # five colours, global default

fig, axes = ps.get_subplots(1, 2)    # 4x4-inch panels

for ax, phase in zip(axes.ravel(), phases):
    for name in ps.order_series(tables):
        sub = df[df.table == name].sort_values("x")
        style = ps.series_style(name, palette)
        ps.draw_band(ax, sub, style)                      # min/max over reps
        sns.lineplot(data=sub, x="x", y="mops", ax=ax, legend=False, **style)
    ax.set_ylim(bottom=0)
    ps.tidy(ax)                                           # dashed grid, round top

ps.add_legend(fig, palette, ps.order_series(tables))      # one legend, above
ps.save(fig, "out.png", legend_top=0.9)                   # tight_layout + 300 dpi
```

Notes on the pieces:

| helper | what it does | when to override |
| --- | --- | --- |
| `configure_style()` | serif (Linux Libertine O), `usetex` if `latex` **and** `dvipng` are on `PATH`, else mathtext with a warning | never |
| `configure_palette(n=None)` | reversed `rocket`, set as seaborn's default and returned | only for non-hashtable series |
| `get_subplots(r, c, plot_w=4, plot_h=4)` | one 4×4-inch panel per cell; a single column fits a two-column page at `\columnwidth` | wider panels for a long x axis |
| `series_style(name, palette)` | `{color, linestyle, marker}` — splat it into `sns.lineplot` | — |
| `draw_band(ax, sub, style)` | shades `lo`..`hi` at 18% alpha under the line; skips silently when a collection has no repeats | column names via `lo=`/`hi=`/`x=` |
| `tidy(ax)` | dashed major grid, extends the top to a whole tick | — |
| `add_legend(fig, palette, names)` | one figure-level legend, `loc="upper center"`, `ncol=len(names)` | `ncol=` when it wraps |
| `axis_labels(param)` | the standard labels for `relation_size`, `skew`, `fill` | add a case rather than inlining a string |
| `save(fig, path, legend_top)` | `tight_layout(rect=[0,0,1,legend_top])`, 300 dpi, close, print the path | `legend_top=0.94` for a lone panel, `0.9` for a grid |

Two conventions the helpers do not enforce, because they are yours to set:

- **`ax.set_ylim(bottom=0)` on every throughput axis.** Mops is a ratio scale;
  a truncated y axis turns a 5% gap into a visual 3×.
- **Keep the x axis spanning the whole sweep even when a series stops early.**
  dlht's uniform sweep ends at 40% fill because its link pool is exhausted
  past that. The short line is the finding; rescaling the axis to the data
  that exists hides it.

---

## 3. What the collectors must hand the plotter

The band is only drawable if the collection kept its repeats, so both
`collect_join/run_join.py` and `macro_uniform/collect_data_amd.py` write a
median **and** the raw samples per point:

```json
{
  "fills":        [10, 20, 30],
  "set_mops":     [1844.0, 1820.0, 1810.0],
  "set_samples":  [[1848, 1836, 1844, 1841, 1844], [...], [...]]
}
```

`plot_data.py` draws the median and shades `min`..`max`. Collections made
before repeats existed carry one sample or none; `ps.draw_band()` notices and
draws nothing rather than a zero-width ribbon.

Two more things worth keeping in the json, both of which the plotters read:
a `plot_order` list so the figure does not depend on dict ordering, and
enough machine context (`ht_size_gib`, `num_threads`) to build the panel
title without a second source of truth.

---

## 4. Reusing this in another project

`paper_style.py` depends only on `matplotlib` and `seaborn` and holds no
paths, so it copies cleanly. When you move it:

1. Replace `PALETTE_ORDER` with your own series, longest-lived first — its
   order *is* the colour assignment, so appending is safe and reordering is
   not.
2. Replace `ALIASES` / `DISPLAY_NAMES` with your internal→published name map,
   and leave the lookups alone.
3. Keep `configure_palette()`'s no-argument default. It is the whole reason
   colours survive across figures.

`intel_hbm/plot_style.py` is a three-line shim that re-exports
`paper_style`; copy that pattern if a subdirectory needs its own module name
for compatibility rather than a second copy of the style.

---

## 5. Fonts

`configure_style()` asks for Linux Libertine O and for LaTeX text rendering.
Neither is required — without `latex` + `dvipng` on `PATH` it prints

```
[!] latex/dvipng not found, rendering without usetex
```

and falls back to matplotlib's mathtext, which is fine for reading the data
but is **not** what should go in the camera-ready. Render the final figures
somewhere with a TeX install so the figure text matches the body text. If you
write an axis label containing a literal `%`, escape it for the usetex path
(`\\%`) — `ps.axis_labels("fill")` shows the pattern.
