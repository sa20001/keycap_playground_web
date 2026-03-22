# Author
  - Riskable <riskable@youknowwhat.com> till 1.10.1
  - sa20001 <https://github.com/sa20001> from 2.0

# Changelog

## 2.0.0-alpha
- Removed incomplete features
- Added iso enter
- Streamlined parameters for keycap modules
- Single parameter for legends
- Streamlined stem generation
- removed key_rotation parameter and put as final transformation

## 1.10.1
- Improved corner wall thickness accuracy when `UNIFORM_WALL_THICKNESS=true`.
- Fixed a bug where `STEM_SUPPORT_DISTANCE` wasn't being passed through when specifying a keycap profile (e.g., "riskeycap").
- Fixed a bug where stem supports weren't always attaching to the full length of the wall when `UNIFORM_WALL_THICKNESS=false`.
- Snap-fit clips on the interior walls of the keycaps now take `KEYCAP_ROTATION` into account to prevent printing bits of them in mid-air.
- Added a preliminary `legend_backing` feature to the box cherry stem type to prevent holes in legends like "8" or "A". Configuration coming in a future release.
- Disabled various preview colors as they interfered with visualization; these are commented out for now.
- Adjusted the default `KEYCAP_ROTATION` to better keep the riskeycap profile flat on its side.
- Minor formatting changes (mostly one argument per line).
- Improved `scripts/keycap.py` and added `scripts/riskeycap.py` with more sanity checks.
- Started modifying variables/comments to enable customizer support.

## 1.10.0
- Added XDA profile.
- Fixed missing `polygon_curve` values in keycap profiles when generating stems, preventing hollow interiors with `UNIFORM_WALL_THICKNESS`.
- Added missing arguments/parameters and support for `--enable=fast-csg` in `scripts/keycap.py` (speeds up rendering ~100x).

## 1.9.4
- Fixed console warnings when `DISH_DEPTH=0`.

## 1.9.3
- Added `STEM_LOCATIONS` to `snap_fit.scad` for simplified testing.
- Added a taper to the box_cherry stem type with `UNIFORM_WALL_THICKNESS` enabled.

## 1.9.2
- Fixed `adjusted_height` mismatch between `*keycap()` and `*stem()` in GEM and riskeycap profiles.
- Fixed issues with stem toppers; tapered them again.

## 1.9.1
- More fixes to stems with `UNIFORM_WALL_THICKNESS`.

## 1.9
- Further fixes to stems with `UNIFORM_WALL_THICKNESS`.
- Corrected approximation of `CORNER_RADIUS`/`CORNER_RADIUS_CURVE` for keycaps and stems when `UNIFORM_WALL_THICKNESS` is disabled.
- Round_cherry stem type now supports `UNIFORM_WALL_THICKNESS` and interior wall snap-fit features.
- Changed `DISH_FN` from 24 → 28 for proper stem tops.
- Updated `snap_fit.scad` to include `UNIFORM_WALL_THICKNESS`.
- Moved stem generation modules to bottom of `stems.scad` for clarity.
- Improved underset masks placement and thickness.
- Fixed legend rendering with inverted dishes.
- Fixed interior keycap carving issues when `UNIFORM_WALL_THICKNESS=false`.

## 1.8.2
- Additional fixes to stems with `UNIFORM_WALL_THICKNESS`.

## 1.8.1
- Minor bugfixes to stems with `UNIFORM_WALL_THICKNESS`.

## 1.8
- **New Feature:** `LEGEND_CARVED` controls whether the underside of legends matches the dish shape; disabled by default.
- Fixed `DISH_INVERT_DIVISION_X/Y` arguments.
- Adjusted `STEM_INSIDE_TOLERANCE` from 0.25 → 0.2.
- Modified `DISH_FN` for faster preview rendering (24 vs 64).
- GEM profile adjusted for slightly wider corners.
- Minor fixes to `render_keycap()` module and stem supports.
- Interior trapezoidal cutouts now respect `CORNER_RADIUS_CURVE`.
- Increased `STEM_SIDE_SUPPORT_THICKNESS` from 0.8 → 1.
- Fixed bug with '%keycap' matching.

## 1.7
- **New Feature:** `DISH_CORNER_FN` for polygon count in corner radius.
- Riskeycap profile updated to version 6.1 with improved corner radius and overhang handling.
- Fixed various bugs in stems and underset mask generation.
- Control outside corner radius of box_cherry and alps stems.
- Moved `VISUALIZE_LEGENDS` near `RENDER` variable for performance.

## 1.6
- `UNIFORM_WALL_THICKNESS` improvements for polygon rotation.
- Legends now match the dish curve; ensures correct depth with `LEGEND_TRANS`.
- Fixed flat stem support issues in PrusaSlicer.
- Riskeycap profile adjusted to reduce overhangs.
- Underset masks improved and row rendering added.
- Minor improvements to `poly_keycap()` and `stem_top()` modules.
- Minor code cleanup/formatting.

## 1.5.1
- Added flared base to box_cherry stem type.

## 1.5
- Preliminary `UNIFORM_WALL_THICKNESS` support.
- Added interior wall support in stems (`STEM_SIDES_WALL_THICKNESS`).
- Alps stem support.
- Improved stem base flaring.
- Better sizing for flat stem supports.
- Added `DISH_INVERT_DIVISION_X/Y` controls.
- Default `KEY_ROTATION` updated for better printing.
- `DISH_FN` adjusts intelligently for preview vs final renders.

## 1.4
- Default keycap length/width now 18.25.
- Fixed issues with `KEY_WIDTH` and legends rendering.
- Fixed DSA profile stem sizing.
- `just_legends()` now logs instead of rendering when no legends present.
- Dish invert parameter passed to all stem modules.

## 1.3
- Fixed underset legends for keycap profiles.

## 1.2
- Fixed legend rotation with DISH_TILT_CURVE.
- Added DSS keycap profile.
- Default: riskeycap profile rotated on its side.
- Modified helpful comments and default values.

## 1.1
- Built-in supports for extra stems on vertically-long keycaps (e.g., numpad enter).
- Added helpful comments.
- Riskeycap profile updated to version 5.0.

## 1.0
- Initial release of the Keycap Playground.