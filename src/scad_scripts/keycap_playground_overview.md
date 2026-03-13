# keycap_playground.scad — Overview

This file is a **configurable OpenSCAD playground** for designing and rendering custom keycaps (including stems and legends). It is intended to be used as a personal “sandbox” for experimenting with keycap profiles, dish shapes, legend placement, and multi-material exports.

---

## ✅ Main Purpose

- Provides **one place to configure everything** about a keycap (size, shape, stem, legends, etc.).
- Supports **multiple keycap profiles** (e.g., `riskeycap`, `gem`, `dsa`, etc.).
- Supports **multi-material export workflows** by rendering separate objects for:
  - `keycap`
  - `stem`
  - `legends`
- Includes **whole-row generation** support via the `ROW` variable.

---

## 🔧 High-Level Structure

### 1) Imports

The file begins by importing helper modules:
- `keycaps.scad` (keycap profiles / generator)
- `stems.scad` (stem geometry)
- `legends.scad` (text/legend generation)
- `utils.scad` (utility functions)
- `profiles.scad` (predefined profile presets)

### 2) Rendering Configuration

- `$fn` controls curve resolution.
- `WHAT_TO_RENDER` and `RENDER` determine what objects are output.
  - Typical options: `"keycap"`, `"stem"`, `"legends"`, `"keycap+stem"`, etc.
  - The default in this file is `"keycap+stem"`.

### 3) Core Keycap Settings

These are the main parameters you can edit to change the shape/size of the keycap.

#### Dimensions
- `KEY_UNIT` — base size of a key unit (default: 19.05 mm)
- `BETWEENSPACE` — gap between keycaps (default: 0.8 mm)
- `KEY_LENGTH`, `KEY_WIDTH`, `KEY_HEIGHT` — overall keycap size
- `KEY_ROW` — used for profile-based keycaps (row-based shaping)

#### Shape / Profile
- `KEY_PROFILE` — selects a built-in profile (`riskeycap`, `gem`, `dsa`, `dcs`, `dss`, `kat`, `kam`, etc.)
- `KEY_TOP_DIFFERENCE` / `KEY_TOP_X` / `KEY_TOP_Y` — adjusts top taper/offset
- `POLYGON_*` parameters — control polygon shape (for low-poly or special looks)
- `CORNER_RADIUS` and `CORNER_RADIUS_CURVE` — round the corners

#### Dish (Top) Settings
- `DISH_TYPE` — `sphere`, `cylinder`, `inv_pyramid`, or flat
- `DISH_DEPTH` — depth of the dish
- `DISH_THICKNESS` — thickness under the dish (important for legend quality)
- `DISH_INVERT` — flip dish for spacebars / special caps
- `DISH_TILT` / `DISH_TILT_CURVE` — tilt and curve behavior

### 4) Stem Settings

Controls the geometry of the stem that mates with switches.

- `STEM_TYPE` — `box_cherry`, `round_cherry`, `alps` (supports others via profile logic)
- `STEM_HEIGHT` — how deep the stem goes
- `STEM_INSET` — inset stem from build plate (for printing on side)
- `STEM_SIDE_SUPPORTS` / `STEM_SIDE_SUPPORT_THICKNESS` — built-in supports for printing sideways
- `STEM_SNAP_FIT` — makes the stem detachable (snap-fit stem system)
- `STEM_SIDES_WALL_THICKNESS` — adds internal thickness to support side legends

### 5) Legend Settings

Provides full control for placing and rendering legends (text/emoji) on the keycap.

- `LEGENDS` — array of legend strings (e.g. `["A"]`, `["1","!"]`)
- `LEGEND_FONTS` — font selection for each legend (supports specifying multiple)
- `LEGEND_FONT_SIZES` — per-legend font sizing
- `LEGEND_TRANS`, `LEGEND_ROTATION`, `LEGEND_SCALE` — positioning/rotation/scale per legend
- `LEGEND_CARVED` — carve legend to match dish surface
- `LEGEND_UNDERSET` — special “underset legend” mode for backlit/transparent keycaps

### 6) Whole-Row / Batch Export

- `ROW` — array of legend arrays (e.g. `ROW=[ ["Q"], ["W"], ... ]`)
- `ROW_SPACING` — spacing used when rendering a row
- `RENDER` can be set to `"row"` / `"row_stems"` / `"row_legends"` / `"row_underset_masks"` for batch output.

### 7) Render Driver Functionality

The bottom of the script defines helper modules:
- `key_using_globals()` — builds a keycap with current global vars (including legends)
- `stem_using_globals()` — builds stems using current global vars
- `handle_render(what, legends)` — dispatches rendering for each object type
- `render_keycap(RENDER)` — loops over requested render targets and exports them

---

## 📝 Notes / Tips Embedded in the File

The file contains many useful tips, including:
- Printing keycaps on their side (using `KEY_ROTATION` and `STEM_SIDE_SUPPORTS`)
- Suggested legend fonts and font sizing behavior
- How to make multi-material exports (separate STL for keycap, stem, legends)
- How to use `LEGEND_UNDERSET` for backlit legends
- How to make a spacebar (set `DISH_INVERT=true` and adjust `KEY_LENGTH`)

---

## 🧩 Where to Edit for Common Use Cases

### Quickly change the keycap profile
- Update `KEY_PROFILE` (e.g. `KEY_PROFILE = "dsa"`) and adjust `KEY_ROW` as needed.

### Generate a different render output
- Modify `WHAT_TO_RENDER` / `RENDER` (e.g. `RENDER = ["legends"]` for just legends)

### Add more legends or swap fonts
- Update the `LEGENDS` array and `LEGEND_FONTS` list.

---

## 🔍 Where to Look for Underlying Logic

- `keycaps.scad` — keycap math + profile implementations
- `stems.scad` — stem geometry generation
- `legends.scad` — legend text generation & extrusion
- `profiles.scad` — stores preset profile values

---

## 🚀 Quick Start Example
If you want a simple 1U keycap with a single legend and a Cherry stem:

1. Set `KEY_PROFILE = "riskeycap"` (or `"dsa"`, etc.)
2. Set `LEGENDS = ["A"]` and `LEGEND_FONT_SIZES = [5.5]`
3. Set `RENDER = ["keycap", "stem", "legends"]`
4. Press **F6** (render) in OpenSCAD and export the STLs.
