include <BOSL2/std.scad>

// Keycap utility modules and functions

include <BOSL2/std.scad>

// MODULES

// TODO: BUG rpoly should not work anymore since now all the logic is built from z=0 and not centre
// Riskable's polygon: Kind of like a combo roundedCube()+cylinder() except you get also offset one of the diameters
module rpoly(d = 0, h = 0, d1 = 0, d2 = 0, r = 1, edges = 4, d2_offset = [0, 0], center = true, $fn = 64) {
  // Because we use a cylinder diameter instead of a cube for the length/width we need to correct for the fact that it will be undersized (fudge factor):
  fudge = 1 / cos(180 / edges);
  module rpoly_proper(d1, d2, h, r, edges, d2_offset) {
    fudged_d1 = d1 * fudge - r * 2.82845; // Corner radius magic fix everything number! 2.82845
    fudged_d2 = d2 * fudge - r * 2.82845; // Ditto!
    if (edges > 3) {
      hull() {
        linear_extrude(height=0.0001)
          offset(r=r) rotate([0, 0, 45]) circle(d=fudged_d1, $fn=edges);
        translate([d2_offset[0], d2_offset[1], h])
          linear_extrude(height=0.0001)
            offset(r=r) rotate([0, 0, 45]) circle(d=fudged_d2, $fn=edges);
      }
    } else {
      // Triangles need a little special attention
      hull() {
        linear_extrude(height=0.0001)
          offset(r=r) rotate([0, 0, 30]) circle(d=d1, $fn=edges);
        translate([d2_offset[0], d2_offset[1], h])
          linear_extrude(height=0.0001)
            offset(r=r) rotate([0, 0, 30]) circle(d=d2, $fn=edges);
      }
    }
  }
  if (d1) {
    if (center) {
      translate([0, 0, -h / 2])
        rpoly_proper(d1, d2, h, r, edges, d2_offset);
    } else {
      rpoly_proper(d1, d2, h, r, edges, d2_offset);
    }
  } else {
    fudged_diameter = d * fudge - r * 2.82845; // Corner radius magic fix everything number! 2.82845
    if (center) {
      translate([0, 0, -h / 2])
        rpoly_proper(d, d, h, r, edges, d2_offset);
    } else {
      rpoly_proper(d, d, h, r, edges, d2_offset);
    }
  }
}

/*
Helper module to create a solid between two paths.
It uses the BOSL2 skin() module to create a loft between the two paths.

Parameters:
- b_path: bottom path as list of points (e.g. [[0, 0], [10, 0], [10, 10], [0, 10]])
- t_path: top path as list of points (e.g. [[0, 0], [10, 0], [10, 10], [0, 10]])
- h: height of the loft (e.g. 10)
- layers: number of layers for the loft (higher = smoother but slower; e.g. 5)
*/
module skin_path(
  // helper module to create a solid between two paths
  b_path, // bottom path as list of points
  t_path, // top path as list of points
  h, // height of the loft
  layers // number of layers for the loft (higher = smoother but slower)
) {
  // loft between them
  c = centroid(b_path);
  translate([-c[0], -c[1], 0]) {
    // center on the origin, plane xy
    skin(
      [
        path3d(b_path, 0),
        path3d(t_path, h),
      ],
      slices=layers // number of interpolated layers between bottom and top
    );
  }
}

/*
Helper module to create a squarish rounded polygon between two paths.

Parameters:
- base_dimension: [x, y] dimensions of the base path (required)
- top_dimension: [x, y] dimensions of the top path (optional; if not
  provided, it will be the same as base_dimension)
- h: height of the loft (required)
- r: corner radius (optional; default: 1)
- xy_offset: [x, y] offset of the top path relative to the base path (optional; default: [0, 0])
- $fn: number of fragments for rounded corners (optional; default: 64)
*/
module squarish_poly(
  base_dimension = undef,
  top_dimension = undef,
  h = undef,
  r = 1,
  xy_offset = [0, 0],
  $fn = 64
) {

  assert(base_dimension != undef, "base_dimension is required");
  assert(h != undef, "h is required");

  function poly_path(xy_vector, f_radius) =
    round_corners(
      [
        [0, 0],
        [xy_vector[0], 0],
        [xy_vector[0], xy_vector[1]],
        [0, xy_vector[1]],
      ], method="circle", radius=r
    );

  if (top_dimension != undef) {
    // get the paths as points
    bottom_path = poly_path(base_dimension, r);
    top_path = move(xy_offset, poly_path(top_dimension, r));
    skin_path(bottom_path, top_path, h, 5);
  } else {
    // get the paths as points
    bottom_path = poly_path(base_dimension, r);
    top_path = move(xy_offset, poly_path(base_dimension, r));
    skin_path(bottom_path, top_path, h, 5);
  }
}

module note(text) echo(str("<span style='color:yellow'><b>NOTE: </b>", text, "</span>"));
module warning(text) echo(str("<span style='color:orange'><b>WARNING: </b>", text, "</span>"));

// FUNCTIONS
function is_odd(x) = (x % 2) == 1;
// This function is used to generate curves given a total number of steps, step we're currently calculating, and the amplitude of the curve:
function polygon_slice(step, amplitude, total_steps = 10) = (1 - step / total_steps) * amplitude;
function polygon_slice_reverse(step, amplitude, total_steps = 10) = (1 - (total_steps - step) / total_steps) * amplitude;

/*
LEGEND_DATA
Each entry defines a single legend and its properties.

Format:
[text, font, size, trans, rot, trans2, rot2, scale, underset]

Parameters:
0: symbol (string)
   The character(s) to render (e.g. "A", "!", "⏎").

1: font (string)
   Font name used for the legend.
   Example: "Overpass Nerd Font", "Roboto", "Noto".
  "Arial Black:style=Regular", // Position/index must match the index in LEGENDS
  "Franklin Gothic Medium:style=Regular" // Normal-ish keycap legend font
  "Gotham Rounded:style=Bold", // Looks similar to the SA Dasher font
  Favorite fonts for legends: Roboto, Aharoni, Ubuntu, Cabin, Noto, Code2000, Franklin Gothic Medium
  Tip: "Noto" and "Code2000" have nearly every emoji/special/funky unicode chars

2: size (number)
   Font size of the legend.

3: trans (vec3)
   Primary translation [x, y, z] in mm.
   Controls main positioning on the keycap surface.

4: rot (vec3)
   Primary rotation [x, y, z] in degrees.
   Usually used for simple orientation.

5: trans2 (vec3)
   Secondary translation used for positioning legends on key sides.

6: rot2 (vec3)
   Secondary rotation used orienting legends on key sides.

7: legend_scale (vec3)
   Scaling factor [x, y, z].
   Allows stretching or shrinking the legend on a particular axis.

8: underset (vec3)
   Used to make legends partially or completely *invisible* until backlit.
   
   Usage notes:
   - For backlit legends, the offset moves the legend down while 
     keeping it perfectly shaped to the keycap dish.
   - The legend and stem should be printed in transparent material
     so light can pass through.
   - Consider to apply a modifier mesh (or similar) in your slicer to make sure that at
     least one layer underneath the keycap gets printed in a *very* opaque material 
     (e.g. black) so as to maximize the amount of contrast for your legend.
   - Setting DISH_THICKNESS as thin as possible reduces the amount
     of plastic the light must pass through, improving legend visibility.

Notes:
Transform order is:
  1. scale(legend_scale)
  2. rotate(rot)
  3. translate(trans)
  4. rotate(rot2)
  5. translate(trans2)
  6. translate(underset)
*/
function make_legend(
  symbol = "",
  font = "Roboto",
  size = 5,
  trans = [0, 0, 0],
  rot = [0, 0, 0],
  trans2 = [0, 0, 0],
  rot2 = [0, 0, 0],
  legend_scale = [1, 1, 1],
  underset = [0, 0, 0]
) =
  [symbol, font, size, trans, rot, trans2, rot2, legend_scale, underset];

module stem_fillet(
  fillet_radius = 2,
  path_points = undef,
  path_fillet_radius = 0,
  flip = [0, 0, 0],
  internal = false
) {
  module fillet_profile(
    path_points
  ) {

    module build_fillet(profile = undef) {
      assert(profile != undef, "profile is required");
      // 3. THE SWEEP: Use 'normal=UP' to fix the "skewed" end caps.
      // This forces the profile to stay oriented perfectly along the Z-axis.
      mirror(flip)
        path_sweep(profile, path_points, normal=UP, closed=true);
    }

    arcProfile = arc(r=fillet_radius, angle=[0, 90], wedge=true);
    squareProfile = square([fillet_radius, fillet_radius]);

    if (internal) {
      difference() {
        build_fillet(profile=squareProfile);
        build_fillet(profile=arcProfile);
      }
    } else {
      build_fillet(profile=arcProfile);
    }
  }

  translate(-centroid(path_points)) {
    // Center in origin
    if (path_fillet_radius > 0) {
      path = round_corners(path_points, method="circle", radius=path_fillet_radius);
      fillet_profile(path_points=path);
    } else {
      fillet_profile(path_points=path_points);
    }
  }
}

module stem_fillet_3D(
  fillet_radius = 2,
  path_points = undef,
  path_fillet_radius = 0,
  flip = [0, 0, 0],
  internal = false
) {
  module fillet_profile(
    path_points
  ) {

    module build_fillet(profile = undef) {
      assert(profile != undef, "profile is required");
      // 3. THE SWEEP: Use 'normal=UP' to fix the "skewed" end caps.
      // This forces the profile to stay oriented perfectly along the Z-axis.
      mirror(flip)
        path_sweep(profile, path_points, normal=UP, closed=true);
    }

    arcProfile = arc(r=fillet_radius, angle=[0, 90], wedge=true);
    squareProfile = square([fillet_radius, fillet_radius]);

    if (internal) {
      difference() {
        build_fillet(profile=squareProfile);
        build_fillet(profile=arcProfile);
      }
    } else {
      build_fillet(profile=arcProfile);
    }
  }
  //  translate(-[0,0,1]) { // TODO the path position is ok, only problem is z offset
    // Center in origin
    if (path_fillet_radius > 0) {
      path = round_corners(path_points, method="circle", radius=path_fillet_radius);
      fillet_profile(path_points=path);
    } else {
      fillet_profile(path_points=path_points);
    }
  // }
}
