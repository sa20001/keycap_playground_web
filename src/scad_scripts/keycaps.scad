// Keycaps -- Contains the poly_keycap() module which can generate pretty much any kind of keycap.

use <utils.scad>
use <legends.scad>

// Draws the keycap without legends (because we need to do an intersection() of the keycap+legends to make sure legends conform to the correct shape)
module _poly_keycap(
  height = 9.0,
  length = 18,
  width = 18,
  top_difference = 6,
  top_x = 0,
  top_y = 0,
  dish_type = "cylinder",
  dish_tilt = -4,
  dish_depth = 1,
  dish_x = 0,
  dish_y = 0,
  dish_z = -0.75,
  dish_fn = 32,
  dish_corner_fn = 64,
  dish_tilt_curve = false,
  polygon_layers = 5,
  polygon_layer_rotation = 10,
  polygon_curve = 0,
  polygon_edges = 4,
  corner_radius = 0.5,
  corner_radius_curve = 0,
  polygon_rotation = false,
  dish_division_x = 4,
  dish_division_y = 1, // Fancy schmancy control over spherical inverted dishes
  dish_invert = false,
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
                if (polygon_edges == 4) {
                  // Normal key
                  xy = [length - curve_val_below, width - curve_val_below];
                  squarish_rpoly(xy=xy, h=0.01, r=corner_radius_below, center=false, $fn=dish_corner_fn);
                } else {
                  // We're doing something funky!
                  rpoly(
                    d=length - curve_val_below,
                    h=0.01, r=corner_radius_below,
                    edges=polygon_edges, center=false,
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
                if (polygon_edges == 4) {
                  // Normal key
                  xy = [length - curve_val_above, width - curve_val_above];
                  squarish_rpoly(
                    xy=xy, h=0.01, r=corner_radius_above,
                    center=false, $fn=dish_corner_fn
                  );
                } else {
                  // We're doing something funky!
                  rpoly(
                    d=length - curve_val_above,
                    h=0.01, r=corner_radius_above,
                    edges=polygon_edges, center=false,
                    $fn=dish_corner_fn
                  );
                }
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
                  if (polygon_edges == 4) {
                    // Normal key
                    xy = [length - curve_val_below, width - curve_val_below];
                    squarish_rpoly(
                      xy=xy, h=0.01,
                      r=corner_radius_below, center=false,
                      $fn=dish_corner_fn
                    );
                  } else {
                    // We're doing something funky!
                    rpoly(
                      d=length - curve_val_below,
                      h=0.01, r=corner_radius_below,
                      edges=polygon_edges, center=false,
                      $fn=dish_corner_fn
                    );
                  }
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
                  if (polygon_edges == 4) {
                    // Normal key
                    xy = [length - curve_val_above, width - curve_val_above];
                    squarish_rpoly(
                      xy=xy, h=0.01,
                      r=corner_radius_above, center=false,
                      $fn=dish_corner_fn
                    );
                  } else {
                    // We're doing something funky!
                    rpoly(
                      d=length - curve_val_above,
                      h=0.01, r=corner_radius_above,
                      edges=polygon_edges, center=false,
                      $fn=dish_corner_fn
                    );
                  }
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
                    if (polygon_edges == 4) {
                      // Normal key
                      xy = [length - curve_val_below, width - curve_val_below];
                      squarish_rpoly(
                        xy=xy, h=0.01,
                        r=corner_radius_below, center=false,
                        $fn=dish_corner_fn
                      );
                    } else {
                      // We're doing something funky!
                      rpoly(
                        d=length - curve_val_below,
                        h=0.01, r=corner_radius_below,
                        edges=polygon_edges, center=false,
                        $fn=dish_corner_fn
                      );
                    }
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
                    if (polygon_edges == 4) {
                      // Normal key
                      xy = [length - curve_val_below, width - curve_val_below];
                      squarish_rpoly(
                        xy=xy, h=0.01,
                        r=corner_radius_below, center=false,
                        $fn=dish_corner_fn
                      );
                    } else {
                      // We're doing something funky!
                      rpoly(
                        d=length - curve_val_below,
                        h=0.01, r=corner_radius_below,
                        edges=polygon_edges, center=false,
                        $fn=dish_corner_fn
                      );
                    }
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
                  if (polygon_edges == 4) {
                    // Normal key
                    xy = [length - curve_val_above, width - curve_val_above];
                    squarish_rpoly(
                      xy=xy, h=0.01,
                      r=corner_radius_above, center=false,
                      $fn=dish_corner_fn
                    );
                  } else {
                    // We're doing something funky!
                    rpoly(
                      d=length - curve_val_above,
                      h=0.01, r=corner_radius_above,
                      edges=polygon_edges, center=false,
                      $fn=dish_corner_fn
                    );
                  }
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
                  if (polygon_edges == 4) {
                    // Normal key
                    xy = [
                      length - curve_val_above - top_difference,
                      width - curve_val_above - top_difference,
                    ];
                    squarish_rpoly(
                      xy=xy, h=0.1,
                      r=corner_radius_above, center=false,
                      $fn=dish_corner_fn
                    );
                  } else {
                    // We're doing something funky!
                    rpoly(
                      d=length - curve_val_above - top_difference,
                      h=0.05, r=corner_radius_above,
                      edges=polygon_edges, center=false,
                      $fn=dish_corner_fn
                    );
                  }
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
                      if (polygon_edges == 4) {
                        // Normal key
                        xy = [layer_length, layer_width];
                        squarish_rpoly(
                          xy=xy, h=0.01,
                          r=corner_radius_above * (1 - ratio), center=false,
                          $fn=dish_corner_fn
                        );
                      } else {
                        // We're doing something funky!
                        rpoly(
                          d=layer_length, h=0.01,
                          r=corner_radius_above,
                          edges=polygon_edges, center=false,
                          $fn=dish_corner_fn
                        );
                      }
                    }
                  }
                }
              } else if (dish_type == "cylinder") {
                hull() {
                  if (polygon_edges == 4) {
                    // Normal key
                    xy = [length - curve_val_above - top_difference, width - curve_val_above - top_difference];
                    squarish_rpoly(
                      xy=xy, h=0.1,
                      r=corner_radius_above, center=false,
                      $fn=dish_corner_fn
                    );
                  } else {
                    // We're doing something funky!
                    rpoly(
                      d=length - curve_val_above - top_difference, h=0.1,
                      r=corner_radius_above, edges=polygon_edges,
                      center=false, $fn=dish_corner_fn
                    );
                  }
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
                      if (polygon_edges == 4) {
                        // Normal key
                        xy = [layer_length, layer_width];
                        squarish_rpoly(
                          xy=xy, h=0.01,
                          r=corner_radius_above * (1 - ratio), center=false,
                          $fn=dish_corner_fn
                        );
                      } else {
                        // We're doing something funky!
                        rpoly(
                          d=layer_length, h=0.01,
                          r=corner_radius_above,
                          edges=polygon_edges, center=false,
                          $fn=dish_corner_fn
                        );
                      }
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
              squarish_rpoly(
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
  poly_keycap()

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
module poly_keycap(
  height = 9.0,
  length = 18,
  width = 18,
  wall_thickness = 1.25,
  top_difference = 6,
  top_x = 0,
  top_y = 0,
  dish_tilt = -4,
  dish_tilt_curve = false,
  stem_clips = false,
  stem_walls_inset = 0,
  dish_depth = 1,
  dish_x = 0,
  dish_y = 0,
  dish_z = -0.75,
  dish_thickness = 2,
  dish_fn = 32,
  dish_corner_fn = 64,
  dish_division_x = 4,
  dish_division_y = 1, // Fancy schmancy control over spherical inverted dishes
  legend_list = [""],
  legend_carved = false,
  polygon_layers = 5,
  polygon_layer_rotation = 10,
  polygon_curve = 0,
  polygon_edges = 4,
  dish_type = "cylinder",
  corner_radius = 0.5,
  corner_radius_curve = 0,
  homing_dot_length = 0,
  homing_dot_width = 0,
  homing_dot_x = 0,
  homing_dot_y = 0,
  homing_dot_z = 0,
  visualize_legends = false,
  polygon_rotation = false,
  key_rotation = [0, 0, 0],
  dish_invert = false,
  uniform_wall_thickness = true
) {
  layer_tilt_adjust = dish_tilt / polygon_layers;
  // Inverted dish means we need to make the legend a little taller
  legend_inverted_dish_adjustment = dish_invert ? dish_depth * 1.25 : 0;
  inverted_dish_adjustment = dish_invert ? dish_depth : 0;

  rotate(key_rotation) {
    difference() {
      _poly_keycap(
        height=height, length=length, width=width,
        top_difference=top_difference, dish_tilt=dish_tilt,
        dish_tilt_curve=dish_tilt_curve,
        top_x=top_x, top_y=top_y, dish_depth=dish_depth,
        dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
        dish_fn=dish_fn,
        dish_corner_fn=dish_corner_fn,
        polygon_layers=polygon_layers, polygon_layer_rotation=polygon_layer_rotation,
        polygon_edges=polygon_edges, polygon_curve=polygon_curve,
        dish_type=dish_type, corner_radius=corner_radius,
        dish_division_x=dish_division_x, dish_division_y=dish_division_y,
        corner_radius_curve=corner_radius_curve, polygon_rotation=polygon_rotation,
        dish_invert=dish_invert
      );
      tilt_above_curved = dish_tilt_curve ? layer_tilt_adjust * polygon_layers : 0;

      // Take care of the legends (if any)
      if (legend_list[0]) {
        for (l = legend_list) {
          legend = l[0];
          font = l[1];
          font_size = l[2];
          trans = l[3];
          rotation = l[4];
          trans2 = l[5];
          rotation2 = l[6];
          l_scale = l[7];
          underset = l[8];

          if (visualize_legends) {
            %translate(underset) {
              translate(trans2) rotate(rotation2)
                  translate(trans) rotate(rotation)
                      scale(l_scale)
                        rotate([tilt_above_curved, 0, 0])
                          color([0.5, 0.5, 0.5, 0.75]) difference() {
                              draw_legend(legend, font_size, font, height + legend_inverted_dish_adjustment);
                              // Make sure the preview matches the curve of the dish on the bottom
                              if (legend_carved) {
                                translate([0, 0, -height + dish_depth - dish_z])
                                  _poly_keycap(
                                    height=height, length=length, width=width,
                                    top_difference=top_difference, dish_tilt=dish_tilt,
                                    dish_tilt_curve=dish_tilt_curve,
                                    top_x=top_x, top_y=top_y, dish_depth=dish_depth,
                                    dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
                                    dish_division_x=dish_division_x,
                                    dish_division_y=dish_division_y,
                                    dish_fn=dish_fn,
                                    dish_corner_fn=dish_corner_fn,
                                    polygon_layers=polygon_layers,
                                    polygon_layer_rotation=polygon_layer_rotation,
                                    polygon_edges=polygon_edges, polygon_curve=polygon_curve,
                                    dish_type=dish_type, corner_radius=corner_radius,
                                    corner_radius_curve=corner_radius_curve,
                                    polygon_rotation=polygon_rotation,
                                    dish_invert=dish_invert
                                  );
                              }
                            }
            }
          } else {
            // NOTE: This translate([0,0,0.1]) call is just to fix preview rendering
            translate(underset) translate([0, 0, 0.1]) intersection() {
                  translate(trans2) rotate(rotation2)
                      translate(trans) rotate(rotation)
                          scale(l_scale)
                            rotate([tilt_above_curved, 0, 0])
                              difference() {
                                draw_legend(legend, font_size, font, height + legend_inverted_dish_adjustment);
                                if (legend_carved) {
                                  translate([0, 0, -height + dish_depth - dish_z])
                                    _poly_keycap(
                                      height=height, length=length, width=width,
                                      top_difference=top_difference, dish_tilt=dish_tilt,
                                      dish_tilt_curve=dish_tilt_curve,
                                      top_x=top_x, top_y=top_y, dish_depth=dish_depth,
                                      dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
                                      dish_division_x=dish_division_x,
                                      dish_division_y=dish_division_y,
                                      dish_fn=dish_fn,
                                      dish_corner_fn=dish_corner_fn,
                                      polygon_layers=polygon_layers,
                                      polygon_layer_rotation=polygon_layer_rotation,
                                      polygon_edges=polygon_edges, polygon_curve=polygon_curve,
                                      dish_type=dish_type, corner_radius=corner_radius,
                                      corner_radius_curve=corner_radius_curve,
                                      polygon_rotation=polygon_rotation,
                                      dish_invert=dish_invert
                                    );
                                }
                              }
                  _poly_keycap(
                    height=height, length=length, width=width,
                    top_difference=top_difference,
                    dish_tilt=dish_tilt,
                    dish_tilt_curve=dish_tilt_curve,
                    top_x=top_x, top_y=top_y, dish_depth=dish_depth,
                    dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
                    dish_division_x=dish_division_x,
                    dish_division_y=dish_division_y,
                    dish_fn=dish_fn,
                    dish_corner_fn=dish_corner_fn,
                    polygon_layers=polygon_layers,
                    polygon_layer_rotation=polygon_layer_rotation,
                    polygon_edges=polygon_edges, polygon_curve=polygon_curve,
                    dish_type=dish_type, corner_radius=corner_radius,
                    corner_radius_curve=corner_radius_curve,
                    polygon_rotation=polygon_rotation,
                    dish_invert=dish_invert
                  );
                }
          }
        }
      }
      // Interior cutout (i.e. make room inside the keycap)
      // TODO: Add support for snap-fit stems with uniform_wall_thickness
      if (uniform_wall_thickness) {
        // Make the interior match the shape of the dish
        translate([0, 0, -0.001]) {
          _poly_keycap(
            height=height - wall_thickness, length=length - wall_thickness * 2,
            width=width - wall_thickness * 2,
            top_difference=top_difference,
            dish_tilt=dish_tilt,
            dish_tilt_curve=dish_tilt_curve,
            top_x=top_x, top_y=top_y, dish_depth=dish_depth,
            dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
            dish_fn=dish_fn,
            dish_corner_fn=dish_corner_fn,
            polygon_layers=polygon_layers,
            polygon_layer_rotation=polygon_layer_rotation,
            polygon_edges=polygon_edges, polygon_curve=polygon_curve,
            dish_type=dish_type, corner_radius=corner_radius / 1.25,
            dish_division_x=dish_division_x, dish_division_y=dish_division_y,
            corner_radius_curve=corner_radius_curve,
            polygon_rotation=polygon_rotation,
            dish_invert=dish_invert
          );
        }
        if (stem_clips) {
          warning("STEM_SNAP_FIT/stem_clips does not currently wortk with UNIFORM_WALL_THICKNESS");
        }
      } else {
        // Trapezoidal interior cutout (keeps things simple)
        difference() {
          corner_radius_factor = ( (corner_radius * corner_radius_curve / polygon_layers) * polygon_layers) / 1.5;
          translate([0, 0, -0.001]) difference() {
              squarish_rpoly(
                xy1=[length - wall_thickness * 2, width - wall_thickness * 2],
                xy2=[
                  length - wall_thickness * 2 - top_difference - corner_radius_factor,
                  width - wall_thickness * 2 - top_difference - corner_radius_factor,
                ],
                xy2_offset=[top_x, top_y],
                h=height, r=corner_radius, center=false,
                $fn=dish_corner_fn
              );
              // TEMPORARILY DISABLED NORTHEAST INDICATOR SINCE IT WAS CAUSING PROBLEMS:
              // This adds a northeast (back right) indicator so you can tell which side is which with symmetrical keycaps
              //                        if (wall_thickness > 0) {
              //                            translate([
              //                              length-wall_thickness*2-0.925,
              //                              width-wall_thickness*2-1.125,
              //                              0]) squarish_rpoly(
              //                                xy1=[length-wall_thickness*2,width-wall_thickness*2],
              //                                xy2=[length-wall_thickness*2-top_difference,width-wall_thickness*2-top_difference],
              //                                xy2_offset=[top_x,top_y],
              //                                h=height, r=corner_radius/2, center=false);
              //                        }
              clip_width = wall_thickness * 2;
              clip_height = 2;
              clip_tolerance = 0.05; // Just the tiniest smidge is all that's necessary
              height_factor = top_difference * (stem_walls_inset / height);
              // NOTE: The top half of the clip gets cut off so the clip_height is really 1 (when set to 2)
              if (stem_clips) {
                translate(
                  [
                    length / 6,
                    -width / 2 + clip_width / 2 + height_factor,
                    stem_walls_inset - clip_height / 2 - clip_tolerance,
                  ]
                )
                  difference() {
                    cube([length / 5, clip_width, clip_height], center=true);
                    translate([0, 0, -clip_height / 1.333])
                      rotate([45, 0, 0])
                        cube([length, 10, clip_height], center=true);
                    // Cut off a bit of an angle at the side so there's no printing in mid-air when printing a keycap on its side:
                    translate([clip_width, 0, clip_width / 2])
                      rotate([0, -key_rotation[1], 0])
                        cube([clip_height, clip_height * 2, clip_width], center=true);
                  }
                translate(
                  [
                    -length / 6,
                    -width / 2 + clip_width / 2 + height_factor,
                    stem_walls_inset - clip_height / 2 - clip_tolerance,
                  ]
                )
                  difference() {
                    cube([length / 5, clip_width, clip_height], center=true);
                    translate([0, 0, -clip_height / 1.333])
                      rotate([45, 0, 0])
                        cube([length, 10, clip_height], center=true);
                    translate([clip_width, 0, clip_width / 2])
                      rotate([0, -key_rotation[1], 0])
                        cube([clip_height, clip_height * 2, clip_width], center=true);
                  }
                // Mirror the clips on the other side
                mirror([0, 1, 0]) {
                  translate(
                    [
                      length / 6,
                      -width / 2 + clip_width / 2 + height_factor,
                      stem_walls_inset - clip_height / 2 - clip_tolerance,
                    ]
                  )
                    difference() {
                      cube([length / 5, clip_width, clip_height], center=true);
                      translate([0, 0, -clip_height / 1.333])
                        rotate([45, 0, 0])
                          cube([length, 10, clip_height], center=true);
                      translate([clip_width, 0, clip_width / 2])
                        rotate([0, -key_rotation[1], 0])
                          cube(
                            [
                              clip_height,
                              clip_height * 2,
                              clip_width,
                            ], center=true
                          );
                    }
                  translate(
                    [
                      -length / 6,
                      -width / 2 + clip_width / 2 + height_factor,
                      stem_walls_inset - clip_height / 2 - clip_tolerance,
                    ]
                  )
                    difference() {
                      cube([length / 5, clip_width, clip_height], center=true);
                      translate([0, 0, -clip_height / 1.333])
                        rotate([45, 0, 0])
                          cube([length, 10, clip_height], center=true);
                      translate([clip_width, 0, clip_width / 2])
                        rotate([0, -key_rotation[1], 0])
                          cube(
                            [
                              clip_height,
                              clip_height * 2,
                              clip_width,
                            ], center=true
                          );
                    }
                }
              }
            }
          // Cut off the top (of the interior--to make it the right height)
          translate([0, 0, height / 2 + height - dish_depth - dish_thickness + inverted_dish_adjustment])
            cube([length * 2, width * 2, height], center=true);
        }
      }
    }
    // NOTE: ADA compliance calls for ~0.5mm-tall braille dots so that's why there's a -0.5mm below
    if (homing_dot_length && homing_dot_width) {
      // Add "homing dots"
      dot_corner_radius = homing_dot_length > homing_dot_width ? homing_dot_width / 2.05 : homing_dot_length / 2.05;
      translate([homing_dot_x, homing_dot_y, height - dish_depth + homing_dot_z - 0.5])
        squarish_rpoly(
          xy=[homing_dot_length, homing_dot_width],
          h=dish_depth, r=dot_corner_radius, center=false
        );
    }
  }
}
