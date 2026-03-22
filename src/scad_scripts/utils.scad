// Keycap utility modules and functions

// MODULES

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

module squarish_rpoly(xy = [0, 0], h = 0, xy1 = [0, 0], xy2 = [0, 0], r = 1, xy2_offset = [0, 0], center = false, $fn = 64) {
  module square_rpoly_proper(xy1, xy2, h, r, xy2_offset) {
    // Need to correct for the corner radius since we're using offset() and square()
    corrected_x1 = xy1[0] > r ? xy1[0] - r * 2 : r / 10;
    corrected_y1 = xy1[1] > r ? xy1[1] - r * 2 : r / 10;
    corrected_x2 = xy2[0] > r ? xy2[0] - r * 2 : r / 10;
    corrected_y2 = xy2[1] > r ? xy2[1] - r * 2 : r / 10;
    if (corrected_x1 <= 0 || corrected_x2 <= 0 || corrected_y1 <= 0 || corrected_y2 <= 0) {
      warning("Corner Radius (x2) is larger than this rpoly! Won't render properly.");
    }
    corrected_xy1 = [corrected_x1, corrected_y1];
    corrected_xy2 = [corrected_x2, corrected_y2];
    hull() {
      linear_extrude(height=0.0001)
        offset(r=r) square(corrected_xy1, center=true);
      translate([xy2_offset[0], xy2_offset[1], h])
        linear_extrude(height=0.0001)
          offset(r=r) square(corrected_xy2, center=true);
    }
  }
  if (xy1[0]) {
    if (center) {
      translate([0, 0, -h / 2])
        square_rpoly_proper(xy1, xy2, h, r, xy2_offset);
    } else {
      square_rpoly_proper(xy1, xy2, h, r, xy2_offset);
    }
  } else {
    if (center) {
      translate([0, 0, -h / 2])
        square_rpoly_proper(xy, xy, h, r, xy2_offset);
    } else {
      square_rpoly_proper(xy, xy, h, r, xy2_offset);
    }
  }
}

module note(text) echo(str("<span style='color:yellow'><b>NOTE: </b>", text, "</span>"));
module warning(text) echo(str("<span style='color:orange'><b>WARNING: </b>", text, "</span>"));

// FUNCTIONS
function is_odd(x) = (x % 2) == 1;
// This function is used to generate curves given a total number of steps, step we're currently calculating, and the amplitude of the curve:
function polygon_slice(step, amplitude, total_steps = 10) = (1 - step / total_steps) * amplitude;
function polygon_slice_reverse(step, amplitude, total_steps = 10) = (1 - (total_steps - step) / total_steps) * amplitude;

// Examples:
//squarish_rpoly(xy1=[0.1,0.1], xy2=[40,40], h=10, r=0.2, center=true);
// Flat sides example:
//squarish_rpoly(xy1=[10,10], xy2=[18,18], h=10, r=1, center=true, $fn=4);

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
