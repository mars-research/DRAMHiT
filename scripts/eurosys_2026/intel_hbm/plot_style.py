#!/usr/bin/env python3
"""Shim: the style this directory used to define now lives in one place.

Everything below is re-exported from ../paper_style.py verbatim -- same
palette order, same helpers, same behaviour -- so the intel_hbm plotters keep
working unchanged while new directories import paper_style directly. See
../PLOTTING.md.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from paper_style import (  # noqa: F401, E402
    DISPLAY_NAMES,
    JOIN_ORDER,
    TUPLE_BYTES,
    VARIANT_STYLE,
    add_legend,
    axis_labels,
    configure_palette,
    configure_style,
    display_name,
    draw_band,
    get_subplots,
    series_style,
    tidy,
)
