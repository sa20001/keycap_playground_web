KEY_UNIT = 19.05; # Standard spacing between keys
STAB_SPACING = 23.01 # Standard spacing between stabilizer stems for 2u keys
KEY_OFFSET = 0.32 # Reduce each side by this much to account for the gap between keys.

KEYCAP_ID = "keycap"
LEGEND_ID = "legend"
SUPPORT_BLOCKER_ID = "support_blocker_"

from  tempfile import TemporaryDirectory
from pathlib import Path

# Keep this object alive for the entire program.
_cache_tmp = TemporaryDirectory(prefix="keycap-cache-")
CACHE_DIR = Path(_cache_tmp.name)

import multiprocessing as mp
import os
if os.name == 'nt': # For Windows support
    from multiprocessing import freeze_support
    freeze_support()
    MP_CONTEXT = mp.get_context("spawn")
else:
    MP_CONTEXT = mp.get_context("fork")


JSON_TEMPLATE_KEYS = [
    "profile",
    "layout",
    "font",
    "font_size",
    "rows",
    "row",
    "units",
    "widthUnit",
    "heightUnit",
    "base_layer",
    "shift_layer",
    "altgr_layer",
    "shift_altrgr_layer",
    "translation",
    "rotation",
    "x",
    "y",
    "z",
    "halign",
    "valign",
    "keys",
    "base",
    "shift",
    "altgr",
    "shift_altgr",
    "row_index",
    "value",
    "override",
    "spillRow"
]