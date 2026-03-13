// Minimal keycap test file
// Creates only a keycap (no stem, no legends) using the default poly_keycap() module.

// Keycaps -- Contains the poly_keycap() module which can generate pretty much any kind of keycap.

use <utils.scad>
use <legends.scad>

// CONSTANTS
KEY_UNIT = 19.05; // Square that makes up the entire space of a key

module _poly_keycap_iso_enter(
  height = 9.0,
  length = 18,
  width = 18,
  wall_thickness = 1.25,
  top_difference = 6,
  top_x = 0,
  top_y = 0,
  dish_type = "cylinder",
  dish_tilt = -4,
  dish_tilt_curve = false,
  dish_depth = 1,
  dish_x = 0,
  dish_y = 0,
  dish_z = -0.75,
  dish_thickness = 2,
  dish_fn = 32,
  dish_corner_fn = 64,
  stem_clips = false,
  stem_walls_inset = 0,
  stem_walls_tolerance = 0.25,
  polygon_layers = 5,
  polygon_layer_rotation = 10,
  polygon_curve = 0,
  corner_radius = 0.5,
  corner_radius_curve = 0,
  polygon_rotation = false,
  dish_division_x = 4,
  dish_division_y = 1, // Fancy schmancy control over spherical inverted dishes
  dish_invert = false,
  debug = false
) {
  layer_x_adjust = top_x / polygon_layers;
  layer_y_adjust = top_y / polygon_layers;
  layer_tilt_adjust = dish_tilt / polygon_layers;
  l_height = height / polygon_layers;
  l_difference = (top_difference / polygon_layers);
  // This (reduction_factor and height_adjust) attempts to make up for the fact that when you rotate a rectangle the corner goes *up* (not perfect but damned close!):
  reduction_factor = dish_tilt_curve ? 2.25 : 2.35;
  height_adjust = ( (abs(width * sin(dish_tilt)) + abs(height * cos(dish_tilt))) - height) / polygon_layers / reduction_factor;
  difference() {
    for (l = [0:polygon_layers - 1]) {
      layer_height_adjust_below = (height_adjust * l);
      layer_height_adjust_above = (height_adjust * (l + 1));
      tilt_below_curved = dish_tilt_curve ? layer_tilt_adjust * l : 0;
      tilt_below_straight = dish_tilt_curve ? 0 : layer_tilt_adjust * l;
      tilt_above_curved = dish_tilt_curve ? layer_tilt_adjust * (l + 1) : 0;
      tilt_above_straight = dish_tilt_curve ? 0 : layer_tilt_adjust * (l + 1);
      tilt_below = layer_tilt_adjust * l;
      tilt_above = layer_tilt_adjust * (l + 1);
      extra_corner_radius_below = (corner_radius * corner_radius_curve / polygon_layers) * l;
      extra_corner_radius_above = (corner_radius * corner_radius_curve / polygon_layers) * (l + 1);
      corner_radius_below = corner_radius + extra_corner_radius_below;
      corner_radius_above = corner_radius + extra_corner_radius_above;
      reduction_factor_below = polygon_slice(l, polygon_curve, total_steps=polygon_layers);
      reduction_factor_above = polygon_slice(l + 1, polygon_curve, total_steps=polygon_layers);
      curve_val_below = (top_difference - reduction_factor_below) * (l / polygon_layers);
      curve_val_above = (top_difference - reduction_factor_above) * ( (l + 1) / polygon_layers);
      if (polygon_rotation) {
        hull() {
          rotate([tilt_below_curved, 0, polygon_layer_rotation * l]) {
            translate(
              [
                layer_x_adjust * l,
                layer_y_adjust * l,
                l_height * l - layer_height_adjust_below,
              ]
            )
              rotate([tilt_below_straight, 0, 0]) {
                // TODO override for iso enter
                xy = [length - curve_val_below, width - curve_val_below];
                squarish_rpoly_iso_enter(xy=xy, h=0.01, r=corner_radius_below, center=false, $fn=dish_corner_fn);
              }
          }
          rotate([tilt_above_curved, 0, polygon_layer_rotation * (l + 1)]) {
            translate(
              [
                layer_x_adjust * (l + 1),
                layer_y_adjust * (l + 1),
                l_height * (l + 1) - layer_height_adjust_above,
              ]
            )
              rotate([tilt_above_straight, 0, 0]) {
                // TODO override for iso enter
                xy = [length - curve_val_above, width - curve_val_above];
                squarish_rpoly_iso_enter(
                  xy=xy, h=0.01, r=corner_radius_above,
                  center=false, $fn=dish_corner_fn
                );
              }
          }
        }
      } else {
        if (is_odd(l)) {
          hull() {
            rotate([tilt_below_curved, 0, polygon_layer_rotation * l]) {
              translate(
                [
                  layer_x_adjust * l,
                  layer_y_adjust * l,
                  l_height * l - layer_height_adjust_below,
                ]
              )
                rotate([tilt_below_straight, 0, 0]) {
                  // TODO override for iso enter
                  xy = [length - curve_val_below, width - curve_val_below];
                  squarish_rpoly_iso_enter(
                    xy=xy, h=0.01,
                    r=corner_radius_below, center=false,
                    $fn=dish_corner_fn
                  );
                }
            }
            rotate([tilt_above_curved, 0, -polygon_layer_rotation * (l + 1)]) {
              translate(
                [
                  layer_x_adjust * (l + 1),
                  layer_y_adjust * (l + 1),
                  l_height * (l + 1) - layer_height_adjust_above,
                ]
              )
                rotate([tilt_above_straight, 0, 0]) {
                  // TODO override for iso enter
                  xy = [length - curve_val_above, width - curve_val_above];
                  squarish_rpoly_iso_enter(
                    xy=xy, h=0.01,
                    r=corner_radius_above, center=false,
                    $fn=dish_corner_fn
                  );
                }
            }
          }
        } else {
          // Even-numbered polygon layer
          hull() {
            if (l == 0) {
              // First layer
              rotate(
                [
                  tilt_below_curved,
                  0,
                  -polygon_layer_rotation * l - layer_height_adjust_below,
                ]
              ) {
                translate([0, 0, l_height * l])
                  rotate([tilt_below_straight, 0, 0]) {
                    // TODO override for iso enter
                    xy = [length - curve_val_below, width - curve_val_below];
                    squarish_rpoly_iso_enter(
                      xy=xy, h=0.01,
                      r=corner_radius_below, center=false,
                      $fn=dish_corner_fn
                    );
                  }
              }
            } else {
              rotate([tilt_below_curved, 0, -polygon_layer_rotation * l]) {
                translate(
                  [
                    layer_x_adjust * l,
                    layer_y_adjust * l,
                    l_height * l - layer_height_adjust_below,
                  ]
                )
                  rotate([tilt_below_straight, 0, 0]) {
                    // TODO override for iso enter
                    xy = [length - curve_val_below, width - curve_val_below];
                    squarish_rpoly_iso_enter(
                      xy=xy, h=0.01,
                      r=corner_radius_below, center=false,
                      $fn=dish_corner_fn
                    );
                  }
              }
            }
            rotate([tilt_above_curved, 0, polygon_layer_rotation * (l + 1)]) {
              translate(
                [
                  layer_x_adjust * (l + 1),
                  layer_y_adjust * (l + 1),
                  l_height * (l + 1) - layer_height_adjust_above,
                ]
              )
                rotate([tilt_above_straight, 0, 0]) {
                  // TODO override for iso enter
                  xy = [length - curve_val_above, width - curve_val_above];
                  squarish_rpoly_iso_enter(
                    xy=xy, h=0.01,
                    r=corner_radius_above, center=false,
                    $fn=dish_corner_fn
                  );
                }
            }
          }
        }
      }
      if (dish_depth != 0 && l == polygon_layers - 1 && dish_invert) {
        // Last layer; do the inverted dish if needed
        rotate([tilt_above_curved, 0, polygon_layer_rotation * (l + 1)])
          translate([top_x, top_y, height - layer_height_adjust_above])
            rotate([tilt_above_straight, 0, 0]) {
              if (dish_type == "sphere") {
                hull() {
                  // TODO override for iso enter
                  xy = [
                    length - curve_val_above - top_difference,
                    width - curve_val_above - top_difference,
                  ];
                  squarish_rpoly_iso_enter(
                    xy=xy, h=0.1,
                    r=corner_radius_above, center=false,
                    $fn=dish_corner_fn
                  );

                  depth_step = dish_depth / polygon_layers;
                  depth_curve_factor = -dish_depth * 4; // For this we use a fixed curve
                  amplitude = 1; // Sine wave amplitude
                  // To keep things simple we'll use the same number of polygon_layers from the main keycap:
                  for (bend_layer = [0:polygon_layers - 1]) {
                    ratio = sin(bend_layer / (polygon_layers * 2) * 180) * amplitude;
                    depth_reduction_factor = polygon_slice(
                      bend_layer, depth_curve_factor, total_steps=polygon_layers
                    );
                    depth_curve_val = (depth_step - depth_reduction_factor) * (bend_layer / polygon_layers);
                    adjusted_length = length - top_difference;
                    adjusted_width = width - top_difference;
                    layer_length = adjusted_length - (adjusted_length * ratio / dish_division_x);
                    layer_width = adjusted_width - (adjusted_width * ratio / dish_division_y);
                    layer_height = dish_depth * ratio;
                    translate(
                      [
                        0,
                        0,
                        depth_curve_val,
                      ]
                    ) {
                      // TODO override for iso enter
                      xy = [layer_length, layer_width];
                      squarish_rpoly_iso_enter(
                        xy=xy, h=0.01,
                        r=corner_radius_above * (1 - ratio), center=false,
                        $fn=dish_corner_fn
                      );
                    }
                  }
                }
              } else if (dish_type == "cylinder") {
                hull() {
                  // TODO override for iso enter
                  xy = [length - curve_val_above - top_difference, width - curve_val_above - top_difference];
                  squarish_rpoly_iso_enter(
                    xy=xy, h=0.1,
                    r=corner_radius_above, center=false,
                    $fn=dish_corner_fn
                  );
                  depth_step = dish_depth / polygon_layers;
                  depth_curve_factor = -dish_depth * 4; // For this we use a fixed curve
                  amplitude = 1; // Sine wave amplitude
                  // To keep things simple we'll use the same number of polygon_layers from the main keycap:
                  for (bend_layer = [0:polygon_layers - 1]) {
                    ratio = sin(bend_layer / (polygon_layers * 1.5) * 180) * amplitude;
                    depth_reduction_factor = polygon_slice(
                      bend_layer, depth_curve_factor, total_steps=polygon_layers
                    );
                    depth_curve_val = (depth_step - depth_reduction_factor) * (bend_layer / polygon_layers);
                    adjusted_length = length - top_difference;
                    adjusted_width = width - top_difference;
                    layer_length = adjusted_length - (adjusted_length * ratio / 30);
                    layer_width = adjusted_width - (adjusted_width * ratio);
                    layer_height = dish_depth * ratio;
                    translate(
                      [
                        0,
                        0,
                        depth_curve_val,
                      ]
                    ) {
                      // TODO override for iso enter
                      // Normal key
                      xy = [layer_length, layer_width];
                      squarish_rpoly_iso_enter(
                        xy=xy, h=0.01,
                        r=corner_radius_above * (1 - ratio), center=false,
                        $fn=dish_corner_fn
                      );
                    }
                  }
                }
              } else {
                warning("inv_pyramid not supported for DISH_INVERT (dish_invert) yet");
              }
            }
      }
    }
    // TODO: Instead of using cylinder() and sphere() to make these use 2D primitives like we do with the inverted dishes (so we don't have to crank up the $fn so high; to improve rendering speed)
    // Do the dishes!
    tilt_above_curved = dish_tilt_curve ? layer_tilt_adjust * polygon_layers : 0;
    tilt_above_straight = dish_tilt_curve ? 0 : layer_tilt_adjust * polygon_layers;
    z_adjust = height_adjust * (polygon_layers + 2);
    extra_corner_radius = (corner_radius * corner_radius_curve / polygon_layers) * polygon_layers;
    corner_radius_up_top = corner_radius + extra_corner_radius;
    if (!dish_invert) {
      // Inverted dishes aren't subtracted like this
      if (dish_type == "inv_pyramid") {
        rotate([tilt_above_curved, 0, 0])
          translate([dish_x + top_x, dish_y + top_y, height - dish_depth + dish_z - z_adjust - 0.1])
            rotate([tilt_above_straight, 0, 0])
              squarish_rpoly_iso_enter(
                xy1=[0.01, 0.01],
                xy2=[length - top_difference + 0.5, width - top_difference + 0.5],
                h=dish_depth + 0.1, r=corner_radius_up_top,
                center=false, $fn=dish_fn
              );
        // Cut off everything above the pyramid
        translate([0, 0, height / 2 + height + dish_z - 0.02])
          cube([length * 2, width * 2, height], center=true);
      } else if (dish_type == "cylinder") {
        // Cylindrical cutout option:
        adjusted_key_length = length - top_difference;
        adjusted_key_width = width - top_difference;
        adjusted_dimension = length > width ? adjusted_key_length : adjusted_key_width;
        chord_length = dish_depth > 0 ? (pow(adjusted_dimension, 2) - 4 * pow(dish_depth, 2)) / (8 * dish_depth) : 0;
        rad = (pow(adjusted_dimension, 2) + 4 * pow(dish_depth, 2)) / (8 * dish_depth);
        rotate([tilt_above_curved, 0, 0])
          translate([dish_x + top_x, dish_y + top_y, chord_length + height + dish_z - z_adjust])
            rotate([tilt_above_straight, 0, 0])
              rotate([90, 0, 0])
                cylinder(h=length * 3, r=rad, center=true, $fn=dish_fn);
      } else if (dish_type == "sphere") {
        adjusted_key_length = length - top_difference;
        adjusted_key_width = width - top_difference;
        adjusted_dimension = length > width ? adjusted_key_length : adjusted_key_width;
        rad = dish_depth > 0 ? (pow(adjusted_dimension, 2) + 4 * pow(dish_depth, 2)) / (8 * dish_depth) : 0;
        rotate([tilt_above_curved, 0, 0])
          translate([dish_x + top_x, dish_y + top_y, rad * 2 + height - dish_depth + dish_z - z_adjust])
            rotate([tilt_above_straight, 0, 0])
              sphere(r=rad * 2, $fn=dish_fn);
      }
    }
  }
}

/*
  poly_keycap_iso_enter()

  Generates a complete keycap mesh (including the internal cavity and legend cutouts).
  This is the primary user-facing API used by `keycap_playground.scad` and other scripts.

  Parameters (most have sensible defaults):

    height            - total height of the keycap (Z dimension)
    length            - overall X dimension (usually KEY_UNIT * keywidth)
    width             - overall Y dimension (usually KEY_UNIT * keywidth)
    wall_thickness    - thickness of the outer walls (also affects internal cavity)

    top_difference    - amount the top surface is inset relative to the bottom (creates taper)
    top_x/top_y       - shifts the top inset on X/Y (used for skewed profiles)

    dish_tilt         - tilt angle for the keycap dish (degrees)
    dish_tilt_curve   - if true, applies tilt as a curve rather than linear
    dish_depth        - depth of the dish (measured from the top surface)
    dish_x/dish_y     - offset the dish center on X/Y
    dish_z            - vertical offset of dish relative to the top surface
    dish_thickness    - thickness of material under the deepest part of the dish
    dish_type         - one of "cylinder", "sphere", "inv_pyramid" (or any other for flat)
    dish_fn           - $fn used for the dish cylinder/sphere
    dish_corner_fn    - $fn used for the corner rounding of the keycap roof
    dish_division_x/y - controls X/Y curve spread when dish_invert is true
    dish_invert       - when true, creates an inverted (convex) dish suitable for spacebars

    legends           - array of strings to render (e.g. ["A"], ["1","!"])
    legend_font_sizes - per-legend font size array
    legend_fonts      - per-legend font names (supports font:style syntax)
    legend_carved     - if true, legends are carved to match the dish curvature
    legend_trans      - per-legend translate
    legend_trans2     - second translate applied after rotation (useful for side legends)
    legend_scale      - per-legend scale [x,y,z]
    legend_rotation   - per-legend rotation before translate2
    legend_rotation2  - second rotation applied after translate2
    legend_underset   - per-legend [x,y,z] offset which is applied *after* legend placement
                        (useful for underset/backlit legends)

    polygon_layers    - how many stacked hull layers to build the keycap shell
    polygon_layer_rotation - rotation applied between layers (for twist effects)
    polygon_curve     - controls how inset the top layers are (0 disables)
    polygon_edges     - number of sides for the keycap outline (4=standard square)
    polygon_rotation  - if false, layers alternate rotation direction (low-poly style)

    corner_radius     - radius for rounding outside corners
    corner_radius_curve - extra rounding added per layer (0 disables)

    homing_dot_length/width/X/Y/Z - optional homing dot at the top surface

    visualize_legends  - if true, renders legends as transparent preview objects
    key_rotation      - rotates the entire keycap (useful for printing on the side)
    uniform_wall_thickness - if true, interior cavity matches outer shape (slower)
    debug             - prints internal parameter values to the console
*/
// NOTE: If polygon_curve or corner_radius_curve are 0 they will be ignored (respectively)
// module poly_keycap_iso_enter(
//   height = 9.0,
//   length = 18,
//   width = 18,
//   wall_thickness = 1.25,
//   top_difference = 6,
//   top_x = 0,
//   top_y = 0,
//   dish_tilt = -4,
//   dish_tilt_curve = false,
//   stem_clips = false,
//   stem_walls_inset = 0,
//   stem_walls_tolerance = 0.25,
//   dish_depth = 1,
//   dish_x = 0,
//   dish_y = 0,
//   dish_z = -0.75,
//   dish_thickness = 2,
//   dish_fn = 32,
//   dish_corner_fn = 64,
//   dish_division_x = 4,
//   dish_division_y = 1, // Fancy schmancy control over spherical inverted dishes
//   legends = [""],
//   legend_font_sizes = [6],
//   legend_fonts = ["Roboto"],
//   legend_carved = false,
//   legend_trans = [[0, 0, 0]],
//   legend_trans2 = [[0, 0, 0]],
//   legend_scale = [[1, 1, 1]],
//   legend_rotation = [[0, 0, 0]],
//   legend_rotation2 = [[0, 0, 0]],
//   legend_underset = [[0, 0, 0]],
//   polygon_layers = 5,
//   polygon_layer_rotation = 10,
//   polygon_curve = 0,
//   polygon_edges = 4,
//   dish_type = "cylinder",
//   corner_radius = 0.5,
//   corner_radius_curve = 0,
//   homing_dot_length = 0,
//   homing_dot_width = 0,
//   homing_dot_x = 0,
//   homing_dot_y = 0,
//   homing_dot_z = 0,
//   visualize_legends = false,
//   polygon_rotation = false,
//   key_rotation = [0, 0, 0],
//   dish_invert = false,
//   uniform_wall_thickness = true,
//   debug = false
// ) {
//   layer_tilt_adjust = dish_tilt / polygon_layers;
//   // Inverted dish means we need to make the legend a little taller
//   legend_inverted_dish_adjustment = dish_invert ? dish_depth * 1.25 : 0;
//   inverted_dish_adjustment = dish_invert ? dish_depth : 0;
//   if (debug) {
//     // NOTE: Tried to divide these up into logical sections; all related elements should be on one line
//     echo(height=height, length=length, width=width);
//     echo(wall_thickness=wall_thickness, top_difference=top_difference, top_x=top_x, top_y=top_y);
//     echo(dish_tilt=dish_tilt, dish_depth=dish_depth, dish_x=dish_x, dish_y=dish_y, dish_z=dish_z, dish_thickness=dish_thickness, dish_fn=dish_fn, dish_type=dish_type, dish_invert=dish_invert);
//     // Really don't need to have this spit out 90% of the time...  Just uncomment if you really need to see loads and loads and LOADS of debug:
//     //        echo(legends=legends, legend_font_sizes=legend_font_sizes, legend_fonts=legend_fonts);
//     //        echo(legend_trans=legend_trans, legend_trans2=legend_trans2);
//     //        echo(legend_rotation=legend_rotation, legend_rotation2=legend_rotation2);
//     echo(polygon_layers=polygon_layers, polygon_layer_rotation=polygon_layer_rotation, polygon_rotation=polygon_rotation, polygon_curve=polygon_curve, polygon_edges=polygon_edges, corner_radius=corner_radius, corner_radius_curve=corner_radius_curve);
//     // These should be obvious enough that you don't need to see their values spit out in the console:
//     //        echo(visualize_legends=visualize_legends, key_rotation=key_rotation);
//     echo(stem_clips=stem_clips, stem_walls_inset=stem_walls_inset);
//   }
//   rotate(key_rotation) {
//     difference() {
//       _poly_keycap_iso_enter(
//         height=height, length=length, width=width, wall_thickness=wall_thickness,
//         top_difference=top_difference, dish_tilt=dish_tilt,
//         dish_tilt_curve=dish_tilt_curve, stem_clips=stem_clips,
//         stem_walls_inset=stem_walls_inset,
//         top_x=top_x, top_y=top_y, dish_depth=dish_depth,
//         dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
//         dish_thickness=dish_thickness, dish_fn=dish_fn,
//         dish_corner_fn=dish_corner_fn,
//         polygon_layers=polygon_layers, polygon_layer_rotation=polygon_layer_rotation,
//         polygon_edges=polygon_edges, polygon_curve=polygon_curve,
//         dish_type=dish_type, corner_radius=corner_radius,
//         dish_division_x=dish_division_x, dish_division_y=dish_division_y,
//         corner_radius_curve=corner_radius_curve, polygon_rotation=polygon_rotation,
//         dish_invert=dish_invert
//       );
//       tilt_above_curved = dish_tilt_curve ? layer_tilt_adjust * polygon_layers : 0;
//       // Take care of the legends
//       for (i = [0:1:len(legends) - 1]) {
//         legend = legends[i] ? legends[i] : "";
//         rotation = legend_rotation[i] ? legend_rotation[i] : (legend_rotation[0] ? legend_rotation[0] : [0, 0, 0]);
//         rotation2 = legend_rotation2[i] ? legend_rotation2[i] : (legend_rotation2[0] ? legend_rotation2[0] : [0, 0, 0]);
//         trans = legend_trans[i] ? legend_trans[i] : (legend_trans[0] ? legend_trans[0] : [0, 0, 0]);
//         trans2 = legend_trans2[i] ? legend_trans2[i] : (legend_trans2[0] ? legend_trans2[0] : [0, 0, 0]);
//         font_size = legend_font_sizes[i] ? legend_font_sizes[i] : legend_font_sizes[0];
//         font = legend_fonts[i] ? legend_fonts[i] : (legend_fonts[0] ? legend_fonts[0] : "Roboto");
//         l_scale = legend_scale[i] ? legend_scale[i] : legend_scale[0];
//         underset =
//           legend_underset[i] ? legend_underset[i]
//           : (
//             legend_underset[0] ? legend_underset[0] : [0, 0, 0]
//           );
//         if (visualize_legends) {
//           %translate(underset) {
//             translate(trans2) rotate(rotation2)
//                 translate(trans) rotate(rotation)
//                     scale(l_scale)
//                       rotate([tilt_above_curved, 0, 0])
//                         color([0.5, 0.5, 0.5, 0.75]) difference() {
//                             draw_legend(legend, font_size, font, height + legend_inverted_dish_adjustment);
//                             // Make sure the preview matches the curve of the dish on the bottom
//                             if (legend_carved) {
//                               translate([0, 0, -height + dish_depth - dish_z])
//                                 _poly_keycap_iso_enter(
//                                   height=height, length=length, width=width,
//                                   wall_thickness=wall_thickness,
//                                   top_difference=top_difference, dish_tilt=dish_tilt,
//                                   dish_tilt_curve=dish_tilt_curve, stem_clips=stem_clips,
//                                   stem_walls_inset=stem_walls_inset,
//                                   top_x=top_x, top_y=top_y, dish_depth=dish_depth,
//                                   dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
//                                   dish_division_x=dish_division_x,
//                                   dish_division_y=dish_division_y,
//                                   dish_thickness=dish_thickness + 0.1, dish_fn=dish_fn,
//                                   dish_corner_fn=dish_corner_fn,
//                                   polygon_layers=polygon_layers,
//                                   polygon_layer_rotation=polygon_layer_rotation,
//                                   polygon_edges=polygon_edges, polygon_curve=polygon_curve,
//                                   dish_type=dish_type, corner_radius=corner_radius,
//                                   corner_radius_curve=corner_radius_curve,
//                                   polygon_rotation=polygon_rotation,
//                                   dish_invert=dish_invert
//                                 );
//                             }
//                           }
//           }
//         } else {
//           // NOTE: This translate([0,0,0.001]) call is just to fix preview rendering
//           translate(underset) translate([0, 0, 0.001]) intersection() {
//                 translate(trans2) rotate(rotation2)
//                     translate(trans) rotate(rotation)
//                         scale(l_scale)
//                           rotate([tilt_above_curved, 0, 0])
//                             difference() {
//                               draw_legend(legend, font_size, font, height + legend_inverted_dish_adjustment);
//                               if (legend_carved) {
//                                 translate([0, 0, -height + dish_depth - dish_z])
//                                   _poly_keycap_iso_enter(
//                                     height=height, length=length, width=width,
//                                     wall_thickness=wall_thickness,
//                                     top_difference=top_difference, dish_tilt=dish_tilt,
//                                     dish_tilt_curve=dish_tilt_curve, stem_clips=stem_clips,
//                                     stem_walls_inset=stem_walls_inset,
//                                     top_x=top_x, top_y=top_y, dish_depth=dish_depth,
//                                     dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
//                                     dish_division_x=dish_division_x,
//                                     dish_division_y=dish_division_y,
//                                     dish_thickness=dish_thickness + 0.1, dish_fn=dish_fn,
//                                     dish_corner_fn=dish_corner_fn,
//                                     polygon_layers=polygon_layers,
//                                     polygon_layer_rotation=polygon_layer_rotation,
//                                     polygon_edges=polygon_edges, polygon_curve=polygon_curve,
//                                     dish_type=dish_type, corner_radius=corner_radius,
//                                     corner_radius_curve=corner_radius_curve,
//                                     polygon_rotation=polygon_rotation,
//                                     dish_invert=dish_invert
//                                   );
//                               }
//                             }
//                 _poly_keycap_(
//                   height=height, length=length, width=width,
//                   wall_thickness=wall_thickness,
//                   top_difference=top_difference,
//                   dish_tilt=dish_tilt,
//                   dish_tilt_curve=dish_tilt_curve, stem_clips=stem_clips,
//                   stem_walls_inset=stem_walls_inset,
//                   top_x=top_x, top_y=top_y, dish_depth=dish_depth,
//                   dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
//                   dish_division_x=dish_division_x,
//                   dish_division_y=dish_division_y,
//                   dish_thickness=dish_thickness + 0.1, dish_fn=dish_fn,
//                   dish_corner_fn=dish_corner_fn,
//                   polygon_layers=polygon_layers,
//                   polygon_layer_rotation=polygon_layer_rotation,
//                   polygon_edges=polygon_edges, polygon_curve=polygon_curve,
//                   dish_type=dish_type, corner_radius=corner_radius,
//                   corner_radius_curve=corner_radius_curve,
//                   polygon_rotation=polygon_rotation,
//                   dish_invert=dish_invert
//                 );
//               }
//         }
//       }
//       // Interior cutout (i.e. make room inside the keycap)
//       // TODO: Add support for snap-fit stems with uniform_wall_thickness
//       if (uniform_wall_thickness) {
//         // Make the interior match the shape of the dish
//         translate([0, 0, -0.001]) {
//           _poly_keycap_(
//             height=height - wall_thickness, length=length - wall_thickness * 2,
//             width=width - wall_thickness * 2, wall_thickness=wall_thickness,
//             top_difference=top_difference,
//             dish_tilt=dish_tilt,
//             dish_tilt_curve=dish_tilt_curve, stem_clips=stem_clips,
//             stem_walls_inset=stem_walls_inset,
//             top_x=top_x, top_y=top_y, dish_depth=dish_depth,
//             dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
//             dish_thickness=dish_thickness, dish_fn=dish_fn,
//             dish_corner_fn=dish_corner_fn,
//             polygon_layers=polygon_layers,
//             polygon_layer_rotation=polygon_layer_rotation,
//             polygon_edges=polygon_edges, polygon_curve=polygon_curve,
//             dish_type=dish_type, corner_radius=corner_radius / 1.25,
//             dish_division_x=dish_division_x, dish_division_y=dish_division_y,
//             corner_radius_curve=corner_radius_curve,
//             polygon_rotation=polygon_rotation,
//             dish_invert=dish_invert
//           );
//         }
//         if (stem_clips) {
//           warning("STEM_SNAP_FIT/stem_clips does not currently wortk with UNIFORM_WALL_THICKNESS");
//         }
//       } else {
//         // Trapezoidal interior cutout (keeps things simple)
//         difference() {
//           corner_radius_factor = ( (corner_radius * corner_radius_curve / polygon_layers) * polygon_layers) / 1.5;
//           translate([0, 0, -0.001]) difference() {
//              // TODO: use squarish_rpoly_iso_enter
//               squarish_rpoly(
//                 xy1=[length - wall_thickness * 2, width - wall_thickness * 2],
//                 xy2=[
//                   length - wall_thickness * 2 - top_difference - corner_radius_factor,
//                   width - wall_thickness * 2 - top_difference - corner_radius_factor,
//                 ],
//                 xy2_offset=[top_x, top_y],
//                 h=height, r=corner_radius, center=false,
//                 $fn=dish_corner_fn
//               );
//               // TEMPORARILY DISABLED NORTHEAST INDICATOR SINCE IT WAS CAUSING PROBLEMS:
//               // This adds a northeast (back right) indicator so you can tell which side is which with symmetrical keycaps
//              // TODO: use squarish_rpoly_iso_enter
//               //                        if (wall_thickness > 0) {
//               //                            translate([
//               //                              length-wall_thickness*2-0.925,
//               //                              width-wall_thickness*2-1.125,
//               //                              0]) squarish_rpoly(
//               //                                xy1=[length-wall_thickness*2,width-wall_thickness*2],
//               //                                xy2=[length-wall_thickness*2-top_difference,width-wall_thickness*2-top_difference],
//               //                                xy2_offset=[top_x,top_y],
//               //                                h=height, r=corner_radius/2, center=false);
//               //                        }
//               clip_width = wall_thickness * 2;
//               clip_height = 2;
//               clip_tolerance = 0.05; // Just the tiniest smidge is all that's necessary
//               height_factor = top_difference * (stem_walls_inset / height);
//               // NOTE: The top half of the clip gets cut off so the clip_height is really 1 (when set to 2)
//               if (stem_clips) {
//                 translate(
//                   [
//                     length / 6,
//                     -width / 2 + clip_width / 2 + height_factor,
//                     stem_walls_inset - clip_height / 2 - clip_tolerance,
//                   ]
//                 )
//                   difference() {
//                     cube([length / 5, clip_width, clip_height], center=true);
//                     translate([0, 0, -clip_height / 1.333])
//                       rotate([45, 0, 0])
//                         cube([length, 10, clip_height], center=true);
//                     // Cut off a bit of an angle at the side so there's no printing in mid-air when printing a keycap on its side:
//                     translate([clip_width, 0, clip_width / 2])
//                       rotate([0, -key_rotation[1], 0])
//                         cube([clip_height, clip_height * 2, clip_width], center=true);
//                   }
//                 translate(
//                   [
//                     -length / 6,
//                     -width / 2 + clip_width / 2 + height_factor,
//                     stem_walls_inset - clip_height / 2 - clip_tolerance,
//                   ]
//                 )
//                   difference() {
//                     cube([length / 5, clip_width, clip_height], center=true);
//                     translate([0, 0, -clip_height / 1.333])
//                       rotate([45, 0, 0])
//                         cube([length, 10, clip_height], center=true);
//                     translate([clip_width, 0, clip_width / 2])
//                       rotate([0, -key_rotation[1], 0])
//                         cube([clip_height, clip_height * 2, clip_width], center=true);
//                   }
//                 // Mirror the clips on the other side
//                 mirror([0, 1, 0]) {
//                   translate(
//                     [
//                       length / 6,
//                       -width / 2 + clip_width / 2 + height_factor,
//                       stem_walls_inset - clip_height / 2 - clip_tolerance,
//                     ]
//                   )
//                     difference() {
//                       cube([length / 5, clip_width, clip_height], center=true);
//                       translate([0, 0, -clip_height / 1.333])
//                         rotate([45, 0, 0])
//                           cube([length, 10, clip_height], center=true);
//                       translate([clip_width, 0, clip_width / 2])
//                         rotate([0, -key_rotation[1], 0])
//                           cube(
//                             [
//                               clip_height,
//                               clip_height * 2,
//                               clip_width,
//                             ], center=true
//                           );
//                     }
//                   translate(
//                     [
//                       -length / 6,
//                       -width / 2 + clip_width / 2 + height_factor,
//                       stem_walls_inset - clip_height / 2 - clip_tolerance,
//                     ]
//                   )
//                     difference() {
//                       cube([length / 5, clip_width, clip_height], center=true);
//                       translate([0, 0, -clip_height / 1.333])
//                         rotate([45, 0, 0])
//                           cube([length, 10, clip_height], center=true);
//                       translate([clip_width, 0, clip_width / 2])
//                         rotate([0, -key_rotation[1], 0])
//                           cube(
//                             [
//                               clip_height,
//                               clip_height * 2,
//                               clip_width,
//                             ], center=true
//                           );
//                     }
//                 }
//               }
//             }
//           // Cut off the top (of the interior--to make it the right height)
//           translate([0, 0, height / 2 + height - dish_depth - dish_thickness + inverted_dish_adjustment])
//             cube([length * 2, width * 2, height], center=true);
//         }
//       }
//     }
//     // NOTE: ADA compliance calls for ~0.5mm-tall braille dots so that's why there's a -0.5mm below
//     if (homing_dot_length && homing_dot_width) {
//       // Add "homing dots"
//       dot_corner_radius = homing_dot_length > homing_dot_width ? homing_dot_width / 2.05 : homing_dot_length / 2.05;
//       translate([homing_dot_x, homing_dot_y, height - dish_depth + homing_dot_z - 0.5])
//              // TODO: use squarish_rpoly_iso_enter
//         squarish_rpoly(
//           xy=[homing_dot_length, homing_dot_width],
//           h=dish_depth, r=dot_corner_radius, center=false
//         );
//     }
//   }
// }

// Width of a standard "key unit" (how much space a "key" takes up in total). Probably don't want to change this.
KEY_UNIT = 19.05; // Square that makes up the entire space of a key
// How much space (air) between keycaps
BETWEENSPACE = 0.8; // The Betweenspace:  The void between realms...  And keycaps (for an 18.25mm keycap)

// BASIC KEYCAP PARAMETERS
// If you want to make a keycap using a common profile set this to one of: dcs, dss, dsa, kat, kam, riskeycap, gem:
KEY_PROFILE = "riskeycap"; // [riskeycap, gem, dsa, dcs, dss, kat, kam]
// Any value other than a supported profile (e.g. "dsa") will use the globals specified below.  In other words, an empty KEY_PROFILE means "just use the values specified here in this file."
KEY_ROW = 1; // NOTE: For a spacebar make sure you also set DISH_INVERT=true
// Some settings override profile settings but most will be ignored (if using a profile)
KEY_HEIGHT = 9; // The Z (NOTE: Dish values may reduce this a bit as they carve themselves out)
KEY_HEIGHT_EXTRA = 0.0; // If you're planning on sanding the keycap you can use this to make up for lost material (normally this is only useful when using a profile e.g. DSA)
// NOTE: You *can* just set KEY_LENGTH/KEY_WIDTH to something simple e.g. 18
KEY_LENGTH = (KEY_UNIT * 1 - BETWEENSPACE); // The X (NOTE: Increase DISH_FN if you make this >1U!)
// NOTE: If using a profile make sure KEY_LENGTH matches the profile's KEY_WIDTH for 1U keycaps!
KEY_WIDTH = (KEY_UNIT * 1 - BETWEENSPACE); // The Y (NOTE: If using POLYGON_EGDES>4 this will be ignored)
// NOTE: Spacebars don't seem to use BETWEENSPACE (for whatever reason).  So to make a spacebar just use "KEY_UNIT*<spacebar unit length>" and omit the "-BETWEENSPACE" part.  Or just be precise and give it a value like 119.0625 (19.05*6.25)
// NOTE: When making longer keycaps you may need to increase KEY_HEIGHT slightly in order for the height to be accurate.  I recommend giving it an extra 0.3mm per extra unit of length so 2U would be +0.3, 3U would be +0.6, etc BUT DOUBLE CHECK IT.  Do a side profile view and look at the ruler or render it and double-check the height in your slicer.
//KEY_ROTATION = [0,0,0]; // I *highly* recommend 3D printing keycaps on their front/back/sides! Try this:
KEY_ROTATION = [0, 110.1, 90]; // An example of how you'd rotate a keycap on its side.  Make sure to zoom in on the bottom to make sure it's *actually* going to print flat! This should be the correct rotation for riskeycap profile.  For GEM use:
//KEY_ROTATION = [0,108.6,90];
// NOTE: If you rotate a keycap to print on its side don't forget to add a built-in support via STEM_SIDE_SUPPORTS! [0,1,0,0] is what you want if you rotated to print on the right side.
KEY_TOP_DIFFERENCE = 5; // How much skinnier the key is at the top VS the bottom [x,y]
KEY_TOP_X = 0; // Move the keycap's top on the X axis (controls skew left/right)
KEY_TOP_Y = 0; // Move the keycap's top on the Y axis (controls skew forward/backward)
WALL_THICKNESS = 0.45 * 2.25; // Default: 0.45 extrusion width * 2.25 (nice and thick; feels/sounds good). NOTE: STEM_SIDES_WALL_THICKNESS gets added to this.
UNIFORM_WALL_THICKNESS = true; // Much more expensive rendering but the material under the dish will match the sides (even the shape of the dish will be matched)
// NOTE: UNIFORM_WALL_THICKNESS uses WALL_THICKNESS instead of DISH_THICKNESS. So DISH_THICKNESS will be ignored if you enable this option.

// DO THE DISHES!
DISH_X = 0; // Move the dish left/right
DISH_Y = 0; // Move the dish forward/backward
DISH_Z = 0; // Controls how deep into the top of the keycap the dish goes (e.g. -0.25)
DISH_TYPE = "sphere"; // "inv_pyramid", "cylinder", "sphere" (aka "domed"), anything else: flat top
// NOTE: inv_pyramid doesn't work for making spacbars (kinda, "duh")
DISH_DEPTH = 1; // Distance between the top sides and the bottommost point in the dish (set to 0 for flat top)
// NOTE: When DISH_INVERT is true DISH_DEPTH becomes more like, "how far dish protrudes upwards"
DISH_THICKNESS = 1; // Amount of material that will be placed under the bottommost part of the dish (Note: only used if UNIFORM_WALL_THICKNESS is false)
// NOTE: If you make DISH_THICKNESS too small legends might not print properly--even with a tiny nozzle.  In other words, a thick keycap top makes for nice clean (3D printed) legends.
// NOTE: Also, if you're printing white keycaps with transparent legends you want a thick dish (1.2+) to darken the non-transparent parts of the keycap
DISH_TILT = 0; // How to rotate() the dish of the key (on the Y axis)
DISH_TILT_CURVE = true; // If you want a more organic ("tentacle"!) shape set this to true
DISH_INVERT = false; // Set to true for things like spacebars
// These two settings only apply to inverted spherical dishes and let you control how wide the X and Y curves will be (you'll have to play around with them to figure out what they do--it's too hard to describe here haha)
DISH_INVERT_DIVISION_X = 4;
DISH_INVERT_DIVISION_Y = 1;
// TIP: If you're making a 1U keycap and want a truly rounded (spherical) top set DISH_INVERT_DIVISION_X to 1 
// NOTE: Don't forget to increase DISH_FN if you make a longer/wider keycap!
DISH_FN = $preview ? 28 : 256; // If you want to increase or decrease the resolution of the shapes used to make the dish (Tip: Don't go <64 for "cylinder" dish types and don't go <128 for "sphere")
// NOTE: DISH_FN does not apply if DISH_INVERT==true (because it would be too much; inverted dish doesn't need as much resolution)
DISH_CORNER_FN = $preview ? 16 : 64;
// COOL TRICK: Set DISH_CORNER_FN to 4 to get flattened/chamfered corners (low-poly look!)

// POLYGON/SHAPE MANIPULATION
POLYGON_LAYERS = 10; // Number of layers we're going to extrude (set to 1 to get a boring keycap)
POLYGON_LAYER_ROTATION = 0; // How much to rotate per layer (set to 0 for boring keycap). Try messing with this!  It's fun!
POLYGON_ROTATION = true; // If false, each layer will ALTERNATE it's rotation CW/CCW (for a low-poly effect).  If true the keycap will gently rotate the given rotation amount until it reaches the final rotated destination (as it were).
// NOTE: If you're using POLYGON_ROTATION and you end up with holes in your keycap walls you may just need to increase WALL_THICKNESS
POLYGON_CURVE = 0; // If you want a "bowed" keycap (e.g. like DSA), increase this value
CORNER_RADIUS = 1; // Radius of the outside corners of the keycap
CORNER_RADIUS_CURVE = 3; // If you want the corner radius to get bigger as it goes up (WARNING: Set this too high and you'll end up with missing bits of your keycap! Check the height when messing with this)

// STEM STUFF
STEM_TYPE = "box_cherry"; // "box_cherry" (default), "round_cherry" (harder to print and not as strong), "alps"
STEM_HOLLOW = false; // Only applies to Alps: Whether or not the inside is hollow
STEM_HEIGHT = 4; // How far into the keycap's stem the switch's stem can go (4 is "normal keycap")
// NOTE: For Alps you typically want STEM_HEIGHT=3.5 (slightly shorter)
STEM_TOP_THICKNESS = 0.65; // The part that resides under the keycap, connecting stems and keycap together (Note: Only used if UNIFORM_WALL_THICKNESS is false)
// TIP: Increase STEM_TOP_THICKNESS when generating underset masks; makes them easier to use as a modifier in your slicer.
STEM_INSIDE_TOLERANCE = 0.2; // Increases the size of the empty space(s) in the stem
// NOTE: For Alps stems I recommend reducing these two values to something like 0.1 or 0.05:
STEM_OUTSIDE_TOLERANCE_X = 0.05; // Shrinks the stem a bit on the X axis (both axis for round_cherry)
STEM_OUTSIDE_TOLERANCE_Y = 0.05; // Shrinks the stem a bit on th Y axix (unused with round_cherry)
// For box stems (e.g. Kailh box) you want outside tolerances to be equal.  For Cherry stems you (usually) want the Y tolerance to be greater (since there's plenty of room on the sides).  In fact, you can go *negative* with STEM_OUTSIDE_TOLERANCE_X (e.g. -0.5) for extra strength!
// Probably leave these two alone but they're here if you really love to mess with things:
ALPS_STEM_CORNER_RADIUS = 0.25;
BOX_CHERRY_STEM_CORNER_RADIUS = 0.5;
// Convert to one variable to rule them all (down below):
STEM_CORNER_RADIUS = STEM_TYPE == "alps" ? ALPS_STEM_CORNER_RADIUS : BOX_CHERRY_STEM_CORNER_RADIUS;
// NOTE ABOUT STEM STRENGTH AND ACCURACY: Printing stems upright/flat with a 0.4mm nozzle is troublesome.  They work OK but they're usually quite tight.  It's better to print keys on their side (front or left/right) so that the layer lines run at an angle to the switch stem; they end up more accurate *and* much, much stronger.
STEM_INSET = 1; // How far to inset the stem (set to 0 to have the stem rest on the build plate which means you won't need supports when printing flat)
STEM_FLAT_SUPPORT = false; // Add built-in support for the stem when printing flat (if inset)
STEM_SIDE_SUPPORT_THICKNESS = 1; // 1 works well for most things
// This controls which sides get (internal, under-the-top) stem supports (for printing on the side):
STEM_SIDE_SUPPORTS = [0, 1, 0, 0]; // Left, right, front, back
// NOTE: You can only enable left/right supports *or* front/back supports.  Not both at the same time. (TODO: Fix that...  Maybe?  Why would you ever need *both* say, a left support *and* a top support at the same time?)
STEM_SUPPORT_DISTANCE = 0.2; // Controls the air gap between the stem and its support
// NOTE: If printing with a small nozzle like 0.25mm you might want to set the support distance to 0 to prevent "misses".
STEM_LOCATIONS = [
  // Where to place stems/stabilizers
  [0, 0, 0], // Dead center (don't comment this out when uncommenting below)
  // Standard examples (uncomment to use them):
  //    [12,0,0], [-12,0,0], // Standard 2U, 2.25U, and 2.5U shift key
  //    [0,12,0], [0,-12,0], // Standard 2U Numpad + or Enter
  //    [50,0,0], [-50,0,0], // Cherry style 6.25U spacebar (most common)
  //    [57,0,0], [-57,0,0], // Cherry style 7U spacebar
];
// SNAP-FIT STEM STUFF (see snap_fit.scad for more details)
STEM_SNAP_FIT = false; // If you want to print the stem as a separate part
STEM_SIDES_WALL_THICKNESS = 0.8; // This will add additional thickness to the interior walls of the keycap that's rendered/exported with the "stem".  If you have legends on the front/back/sides of your keycap setting this to something like 0.65 will give those legends something to "sit" on when printing (so there's no mid-air printing or drooping).
STEM_WALLS_INSET = 0; // Makes it so the stem walls don't go all the way to the bottom of the keycap; works just like STEM_INSET but for the walls (1.05 is good for snap-fit stems)
STEM_WALLS_TOLERANCE = 0.0; // How much wiggle room the stem sides will get inside the keycap (0.2 is good for snap-fit stems)

// If you want "homing dots" for home row keys:
HOMING_DOT_LENGTH = 0; // Set to something like "3" for a good, easy-to-feel "dot"
HOMING_DOT_WIDTH = 1; // Default: 1
HOMING_DOT_X = 0; // 0 == Center
HOMING_DOT_Y = -KEY_WIDTH / 4; // Default: Move it down towards the front a bit
HOMING_DOT_Z = -0.35; // 0 == Right at KEY_HEIGHT (dish type makes a big difference here)
// NOTE: ADA specifies 0.5mm as the ideal braille dot height so that's what I recommend for homing dots too!  Though, 0.3mm seems to be reasonably "feelable" in my testing.  Experiment!

// LEGENDARY!
LEGENDS = [
  // As many legends as you want
  //    "A",
  //    "1", "!", // Just an example of multiple legends (uncomment to try it!)
  //    "☺", // Unicode characters work too!
];
// NOTE: Legends might not look quite right until final render (F6)
LEGEND_FONTS = [
  // Each legend can use its own font. If not specified the first font definition will be used
  "Overpass Nerd Font",
  //    "Arial Black:style=Regular", // Position/index must match the index in LEGENDS
  //    "Franklin Gothic Medium:style=Regular" // Normal-ish keycap legend font
  //    "Gotham Rounded:style=Bold", // Looks similar to the SA Dasher font
  // Favorite fonts for legends: Roboto, Aharoni, Ubuntu, Cabin, Noto, Code2000, Franklin Gothic Medium
]; // Tip: "Noto" and "Code2000" have nearly every emoji/special/funky unicode chars
LEGEND_FONT_SIZES = [
  // Each legend can have its own font size
  5.5, // Position/index must match the index in LEGENDS (this is the first legend)
  4, // Second legend...  etc
];
LEGEND_CARVED = false; // Makes it so the bottom of the legend matches the shape of the dish (in case you want to translate() it up to the top of the keycap to finely control its depth).  Slows down rendering quite a bit so unless you have a specific need you'd best keep it set to false.
/* NOTES ABOUT LEGEND TRANSLATION AND ROTATION
    * Legends are translated and rotated in the following order:
        translate(trans2) rotate(rotation2) translate(trans) rotate(rotation)
    * Normally you only need LEGEND_TRANS and LEGEND_ROTATION but if you want to put legends on the sides you need to rotate them twice (once for position and once for making them rightside up).
    * LEGEND_TRANS2 is probably unnecessary but may make a few folks lives easier by not having to think as much :)
*/
LEGEND_TRANS = [
  // You can translate() legends around however you like.
  [-0.1, 0, 0], // A good default (FYI: -0.1-0.15mm works around OpenSCAD's often-broken font centering)
  [4.15, 3, 1],
  [4.40, KEY_TOP_Y + 2.25, 0], // Top right (mostly)
];
LEGEND_ROTATION = [
  // How to rotate each legend. If not specified defaults to [0,0,0]
  [0, 0, 0],
  //    [60,0,0], // Example of how you'd put a legend on the front (try it!)
];
LEGEND_TRANS2 = [
  // Second translate() call (see note above)
  [0, 0, 0],
];
LEGEND_ROTATION2 = [
  // Sometimes you want to rotate again after translate(); that's what this is for
  [0, 0, 0],
];
LEGEND_SCALE = [
  // Want to shrink/stretch your legends on a particular axis?  Do that here:
  [1, 1, 1],
];
LEGEND_UNDERSET = [
  // This is a *very* special thing; see long note about it below...
  [0, 0, 0], // Normally only want to adjust the Z axis (3rd item) if you're using this feature
];
/* All about underset legends:

    So say you want your legend to be *completely invisible* unless your keycap is lit up (from underneath).  You can do that with LEGEND_UNDERSET!  It's kind of like a LEGEND_TRANS3 that gets applied *after* the legend has been put into place by LEGEND_TRANS, LEGEND_TRANS2, LEGEND_ROTATION, LEGEND_ROTATION2, and LEGEND_SCALE then interesction()'d but *before* it gets difference()'d against the keycap.  So if you set LEGEND_UNDERSET to something like [0,0,-0.5] your legend will be moved down (on the z axis) 0.5mm *while still retaining the exact shape of the keycap/dish*.
    
    In order for that to work properly though you'll need to make your legend and stem in a transparent material (so the light can make it all the way through).  You'll also probably want to apply a modifier mesh (or similar) in your slicer to make sure that at least one layer underneath the keycap gets printed in a *very* opaque material (e.g. black) so as to maximize the amount of contrast for your legend.
    
    Lastly, you'll want to set your DISH_THICKNESS to as thin as you can bear in order to minimize the amount of plastic that the light needs to pass through before it reaches the underside of the top of the keycap.
*/

// TODO: This injection molding thing...
// If you want an internal support structure under the keycap (between stems) you can add them here:
RIBS = [
  // Useful for injection molding
  // Not supported yet!
];

// When generating a whole row of keys at a time (e.g. on the command line) use this ROW variable:
//ROW = [];
/* Example: ROW=[["Q"],["W"],["E"],["R"],["T"],["Y"],["U"],["I"],["O"],["P"]];
   (It's an array of legend arrays like ROW=[LEGENDS1,LEGENDS2,LEGENDS3,...])
*/
ROW = [["`", "~"], ["1", "!"], ["2", "@"], ["3", "#"], ["4", "$"], ["5", "%"], ["6", "^"], ["7", "&"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"]];
ROW_SPACING = KEY_UNIT; // You can change this to something like "KEY_HEIGHT+3" if printing keycaps on their side...
//ROW_SPACING = KEY_HEIGHT+3;

/* NOTES ABOUT SCRIPTING/GENERATING KEYCAPS ON THE COMMAND LINE:
    * Here's an example (bash) where I generate the whole top row of regular keys (QWERTY):
        ROW='[["Q"],["W"],["E"],["R"],["T"],["Y"],["U"],["I"],["O"],["P"]];'; openscad -o qwertyuiop.stl -D "ROW=${ROW}" keycap_playground.scad
      That would generate all those keys and save them in a single .stl named qwertyiop.stl
*/

// DEBUGGING FEATURES
DEBUG = false; // Set this to true if you want poly_keycap() to spit out all it's variables in the console

// Render a basic 1U keycap.
// poly_keycap_iso_enter(
//   height = KEY_HEIGHT,
//   length = KEY_LENGTH,
//   width = KEY_WIDTH,
//   wall_thickness = WALL_THICKNESS,
//   top_difference = KEY_TOP_DIFFERENCE,
//   dish_tilt = DISH_TILT,
//   dish_tilt_curve = DISH_TILT_CURVE,
//   stem_clips = STEM_SNAP_FIT,
//   stem_walls_inset = STEM_WALLS_INSET,
//   stem_walls_tolerance = STEM_WALLS_TOLERANCE,
//   top_x = KEY_TOP_X,
//   top_y = KEY_TOP_Y,
//   dish_depth = DISH_DEPTH,
//   dish_x = DISH_X,
//   dish_y = DISH_Y,
//   dish_z = DISH_Z,
//   dish_thickness = DISH_THICKNESS,
//   dish_fn = DISH_FN,
//   dish_corner_fn = DISH_CORNER_FN,
//   legends = _legends,
//   legend_font_sizes = LEGEND_FONT_SIZES,
//   legend_carved = LEGEND_CARVED,
//   legend_fonts = LEGEND_FONTS,
//   legend_trans = LEGEND_TRANS,
//   legend_trans2 = LEGEND_TRANS2,
//   legend_scale = LEGEND_SCALE,
//   legend_rotation = LEGEND_ROTATION,
//   legend_rotation2 = LEGEND_ROTATION2,
//   legend_underset = LEGEND_UNDERSET,
//   polygon_layers = POLYGON_LAYERS,
//   polygon_layer_rotation = POLYGON_LAYER_ROTATION,
//   polygon_edges = POLYGON_EDGES,
//   polygon_curve = POLYGON_CURVE,
//   dish_type = DISH_TYPE,
//   dish_division_x = DISH_INVERT_DIVISION_X,
//   dish_division_y = DISH_INVERT_DIVISION_Y,
//   corner_radius = CORNER_RADIUS,
//   corner_radius_curve = CORNER_RADIUS_CURVE,
//   visualize_legends = VISUALIZE_LEGENDS,
//   polygon_rotation = POLYGON_ROTATION,
//   homing_dot_length = HOMING_DOT_LENGTH,
//   homing_dot_width = HOMING_DOT_WIDTH,
//   homing_dot_x = HOMING_DOT_X,
//   homing_dot_y = HOMING_DOT_Y,
//   homing_dot_z = HOMING_DOT_Z,
//   key_rotation = KEY_ROTATION,
//   dish_invert = DISH_INVERT,
//   debug = DEBUG,
//   uniform_wall_thickness = UNIFORM_WALL_THICKNESS
// );

// _poly_keycap_iso_enter(
//   height=KEY_HEIGHT,
//   length=KEY_LENGTH,
//   width=KEY_WIDTH,
//   wall_thickness=WALL_THICKNESS,
//   top_difference=KEY_TOP_DIFFERENCE,
//   top_x=KEY_TOP_X,
//   top_y=KEY_TOP_Y,
//   dish_type=DISH_TYPE,
//   dish_tilt=DISH_TILT,
//   dish_tilt_curve=DISH_TILT_CURVE,
//   dish_depth=DISH_DEPTH,
//   dish_x=DISH_X,
//   dish_y=DISH_Y,
//   dish_z=DISH_Z,
//   dish_thickness=DISH_THICKNESS,
//   dish_fn=DISH_FN,
//   dish_corner_fn=DISH_CORNER_FN,
//   stem_clips=STEM_SNAP_FIT,
//   stem_walls_inset=STEM_WALLS_INSET,
//   stem_walls_tolerance=STEM_WALLS_TOLERANCE,
//   polygon_layers=POLYGON_LAYERS,
//   polygon_layer_rotation=POLYGON_LAYER_ROTATION,
//   polygon_curve=POLYGON_CURVE,
//   corner_radius=CORNER_RADIUS,
//   corner_radius_curve=CORNER_RADIUS_CURVE,
//   polygon_rotation=POLYGON_ROTATION,
//   dish_division_x=DISH_INVERT_DIVISION_X,
//   dish_division_y=DISH_INVERT_DIVISION_Y,
//   dish_invert=DISH_INVERT,
//   debug=DEBUG,
// );

module squarish_rpoly_iso_enter(
  xy = [0, 0],          // Default size of the square/rpoly if no xy1/xy2 provided
  h = 0,                // Height of the extruded 3D shape
  xy1 = [0, 0],         // First XY dimensions (width, depth) for the base square/polygon
  xy2 = [0, 0],         // Second XY dimensions for the top square/polygon (could be different to make a frustum)
  r = 1,                // Corner radius for rounded corners
  xy2_offset = [0, 0],  // Offset of the top shape relative to the bottom (for slanted/extruded shapes)
  center = false,       // Whether to center the extrusion vertically on Z-axis
  $fn = 64              // Number of fragments for rounded corners (high = smoother)
) {
  module square_rpoly_proper(
    xy1,
    xy2,
    h,
    r,
    xy2_offset
  ) {
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
