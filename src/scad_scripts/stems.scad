// Stem-related modules

use <keycaps.scad>
use <utils.scad>

/* NOTES
    * Some of the stem arguments are unused.  They're there in case we need to use them in the future (e.g. dish_tilt might be taken into account in the future if we need to make the underside of keycaps tilted).
    Alps stabilizer stem notes:
        4.15 x 5.15 outer edges of the rectangle insert
        about 1.01 thick rim
        insert can go in about 4mm i think
*/

// Cherry constants (not all used; many are here "just in case")
CHERRY_SWITCH_LENGTH = 15.6;
CHERRY_SWITCH_WIDTH = 15.6;
CHERRY_CYLINDER_DIAMETER = 5.47;
CHERRY_STEM_HEIGHT = 4.5; // How far the underside of the keycap extends into the stem()
CHERRY_CROSS_X_THICKNESS = 1.3; // Width of the - in the +
CHERRY_CROSS_Y_THICKNESS = 1.1; // Width of the - in the |
CHERRY_CROSS_LENGTH = 4; // Length of the - and the | in the +
CHERRY_BOX_STEM_WIDTH = 6.5; // Outside dimensions of a box-style stem
CHERRY_BOX_STEM_LENGTH = 6.5;
// Alps constants
ALPS_STEM_LENGTH = 4.5;
ALPS_STEM_WIDTH = 2.3;
ALPS_STEM_DEPTH = 3.5; // How far it goes into the switch
ALPS_STEM_OUTSIDE_LENGTH = 6.5; // Part that stops the stem from going any further into the switch
ALPS_STEM_OUTSIDE_WIDTH = 5; // Ditto
ALPS_STEM_INSIDE_LENGTH = 2.6; // Only for SKFL
ALPS_STEM_INSIDE_WIDTH = 0.9; // Ditto

/* This makes the + bit that slides *in* to a Cherry MX style keycap
    * depth: How long/tall the rendered cross stem will be (normally 4mm)
    * extra_tolerance: How much *thicker* the cross will be rendered (assuming use with difference())
    * flare_base: Whether or not the base of the cross should be flared outward (45° angle, 0.6mm outward) to make keycap insertion easier and also prevent any issues with first layer squish (aka elephant's foot)
*/
module cherry_cross(depth = 4, tolerance = 0.1, flare_base = true) {
  flare_height = 0.4;
  flare_width = 0.6;
  // NOTE: The 0.001 values sprinkled throughout (and translate() calls) are just to prevent rendering artifacts when previewing
  translate([0, 0, -0.001]) linear_extrude(height=depth + 0.002) {
      square([CHERRY_CROSS_Y_THICKNESS + tolerance * 2, CHERRY_CROSS_LENGTH + tolerance / 4], center=true);
      square([CHERRY_CROSS_LENGTH + tolerance, CHERRY_CROSS_X_THICKNESS + tolerance], center=true);
    }
  if (flare_base) {
    translate([0, 0, -0.001]) linear_extrude(height=flare_height, scale=[0.5, 0.825]) {
        square([CHERRY_CROSS_Y_THICKNESS + tolerance * 2 + flare_width, CHERRY_CROSS_LENGTH + tolerance + flare_width], center=true);
      }
    translate([0, 0, -0.001]) linear_extrude(height=flare_height, scale=[0.825, 0.5]) {
        square([CHERRY_CROSS_LENGTH + tolerance / 4 + flare_width, CHERRY_CROSS_X_THICKNESS + tolerance + flare_width], center=true);
      }
  }
}

// TODO stem_support can be used for as upper part for stems? see if it makes sense to reuse this code
// Generates *just* the top part of the stem that goes under the keycap (mostly for making underset legends)
// NOTE: corner_radius is ignored (but key_corner_radius is used)
module stem_top(
  key_height,
  key_length,
  key_width,
  dish_thickness,
  top_difference,
  wall_thickness = 1.35,
  key_corner_radius = 0.5,
  top_x = 0,
  top_y = 0,
  top_thickness = 0.6,
  wall_extra = 0.65,
  wall_inset = 0,
  wall_tolerance = 0.25,
  polygon_layers = 5,
  polygon_layer_rotation = 0,
  polygon_curve = 0,
  dish_tilt = 0,
  dish_depth = 1,
  dish_x = 0,
  dish_y = 0,
  dish_z = 0,
  dish_fn = 32,
  dish_corner_fn = 64,
  dish_tilt_curve = false,
  dish_division_x = 4,
  dish_division_y = 1,
  polygon_edges = 4,
  dish_type = "cylinder",
  corner_radius = 0.5,
  corner_radius_curve = 0,
  polygon_rotation = false,
  dish_invert = false,
  uniform_wall_thickness = false
) {
  // Generate a top layer that spans the entire width of the keycap so we have something legends can print on
  // NOTE: We generate it similarly to poly_keycap()'s trapezoidal interior cutout so we have a precise fit
  // Give the "undershelf" a distinct color so you know it's there and not the same as the keycap:
  //    color("#620093") // Purple
  if (uniform_wall_thickness) {
    // Inverted dish needs to go up a bit
    inverted_dish_adjustment = dish_invert ? wall_thickness * 0.85 : 0;
    translate([0, 0, -wall_thickness]) difference() {
        _poly_keycap(
          // Since this is an interior cutout sort of thing we need to cut the height down slightly so there's some overlap
          height=key_height - wall_thickness / 2 + inverted_dish_adjustment,
          length=key_length - wall_thickness * 2,
          width=key_width - wall_thickness * 2,
          top_difference=top_difference, dish_tilt=dish_tilt,
          dish_tilt_curve=dish_tilt_curve,
          top_x=top_x, top_y=top_y, dish_depth=dish_depth,
          dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
          dish_fn=dish_fn,
          dish_corner_fn=dish_corner_fn,
          polygon_layers=polygon_layers,
          polygon_layer_rotation=polygon_layer_rotation,
          polygon_edges=polygon_edges, polygon_curve=polygon_curve,
          dish_type=dish_type,
          dish_division_x=dish_division_x, dish_division_y=dish_division_y,
          corner_radius=key_corner_radius / 2,
          corner_radius_curve=corner_radius_curve,
          polygon_rotation=polygon_rotation,
          dish_invert=dish_invert
        );
        if (wall_extra != 0) {
          // Stem will get its own walls
          translate([0, 0, -0.001]) _poly_keycap(
              height=key_height - wall_thickness / 2 - wall_extra + inverted_dish_adjustment,
              length=key_length - wall_thickness * 2 - wall_extra * 2,
              width=key_width - wall_thickness * 2 - wall_extra * 2,
              top_difference=top_difference, dish_tilt=dish_tilt,
              dish_tilt_curve=dish_tilt_curve,
              top_x=top_x, top_y=top_y, dish_depth=dish_depth,
              dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
              dish_fn=dish_fn,
              dish_corner_fn=dish_corner_fn,
              polygon_layers=polygon_layers,
              polygon_layer_rotation=polygon_layer_rotation,
              polygon_edges=polygon_edges, polygon_curve=polygon_curve,
              dish_type=dish_type,
              dish_division_x=dish_division_x, dish_division_y=dish_division_y,
              corner_radius=key_corner_radius / 2,
              corner_radius_curve=corner_radius_curve,
              polygon_rotation=polygon_rotation,
              dish_invert=dish_invert
            );
        } else {
          // Cancel out the operation by removing the top/sides entirely
          translate([0, 0, 0]) _poly_keycap(
              height=key_height - wall_thickness,
              length=key_length,
              width=key_width,
              top_difference=top_difference, dish_tilt=dish_tilt,
              dish_tilt_curve=dish_tilt_curve,
              top_x=top_x, top_y=top_y, dish_depth=dish_depth,
              dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
              dish_fn=dish_fn,
              dish_corner_fn=dish_corner_fn,
              polygon_layers=polygon_layers,
              polygon_layer_rotation=polygon_layer_rotation,
              polygon_edges=polygon_edges, polygon_curve=polygon_curve,
              dish_type=dish_type,
              dish_division_x=dish_division_x, dish_division_y=dish_division_y,
              corner_radius=key_corner_radius / 2,
              corner_radius_curve=corner_radius_curve,
              polygon_rotation=polygon_rotation,
              dish_invert=dish_invert
            );
        }
        translate([0, 0, -key_height / 2]) // Cut off bottom
          cube([key_length * 2, key_width * 2, key_height], center=true);
        if (wall_inset) {
          translate([0, 0, -key_height / 2 + wall_inset]) // Cut off the bottom of the walls
            difference() {
              cube([key_length * 2, key_width * 2, key_height], center=true);
              // Cut out a space in the middle for the stem so we don't end up cutting it off along with the walls
              cube(
                [
                  CHERRY_BOX_STEM_LENGTH,
                  CHERRY_BOX_STEM_WIDTH,
                  key_height * 4,
                ], center=true
              );
            }
        }
      }
  } else {
    // Non-uniform wall thickness
    difference() {
      squarish_rpoly(
        xy1=[key_length - wall_thickness * 2, key_width - wall_thickness * 2],
        xy2=[
          key_length - wall_thickness * 2 - top_difference,
          key_width - wall_thickness * 2 - top_difference,
        ],
        xy2_offset=[top_x, top_y],
        h=key_height, r=key_corner_radius / 2, center=false
      );
      translate([0, 0, key_height / 2 + key_height - dish_depth - dish_thickness]) // Cut off top
        cube([key_length * 2, key_width * 2, key_height], center=true);
      translate([0, 0, key_height / 2 - dish_depth - dish_thickness - top_thickness]) // Cut off bottom
        cube([key_length * 2, key_width * 2, key_height], center=true);
    }
  }
}

module stem_box_cherry(
  depth = 4,
  outside_tolerance_x = 0.2,
  outside_tolerance_y = 0.2,
  inside_tolerance = 0.25,
  inset = 0,
  flat_support = true,
  support_distance = 0.2,
  corner_radius = 0.5,
  // // Stem lateral support parameters
  // // TODO: side support must be added when the whole keycap is assembled, when generating the stem-> it makes the code so less maintainable to do it here
  // key_height,
  // key_length,
  // key_width,
  // dish_depth = 1,
  // dish_thickness,
  // top_difference,
  // polygon_layers = 5,
  // polygon_layer_rotation = 0,
  // dish_tilt = 0,
  // wall_thickness = 1.35,
  // key_corner_radius = 0.5,
  // top_thickness = 0.6,
  // wall_extra = 0.65,
  // wall_inset = 0,
  // wall_tolerance = 0.25,
  // top_x = 0,
  // top_y = 0,
  // side_support_thickness = 0.8,
  // side_supports = [0, 0, 0, 0],
  // stem_support_locations = [[0, 0, 0]],
  // polygon_curve = 0,
  // dish_tilt_curve = false,
  // dish_x = 0,
  // dish_y = 0,
  // dish_z = -0.75,
  // dish_fn = 32,
  // dish_corner_fn = 64,
  // dish_division_x = 4,
  // dish_division_y = 1,
  // polygon_edges = 4,
  // dish_type = "cylinder",
  // corner_radius_curve = 0,
  // polygon_rotation = false,
  // dish_invert = false
) {
  extrusion_width = 0.45; // TODO TEMP (for now)
  length = CHERRY_CYLINDER_DIAMETER - outside_tolerance_x * 2;
  width = CHERRY_CYLINDER_DIAMETER - outside_tolerance_y * 2;

  // Generate the top part of the stem that connects to the underside of the keycap
  difference() {
    translate([0, 0, depth / 2 + inset])
      squarish_rpoly(xy=[length, width], h=depth, r=corner_radius, center=true);
    translate([0, 0, inset])
      cherry_cross(tolerance=inside_tolerance, flare_base=true);
  }

  stem_topper_height = depth;
  translate([0, 0, stem_topper_height / 2 + inset + depth]) {
    squarish_rpoly(
      xy1=[length, width],
      xy2=[length, width],
      h=stem_topper_height,
      r=corner_radius, center=true
    );
  }

  color("#005500") // Green
  if (flat_support && inset > 0) {
    support_dia = 7; // Size of the removable "flat thing" (bigger == easier to grab/remove with a tool)
    // Generate the support bits that go under the stem
    translate([0, 0, -support_distance]) difference() {
        // Generate the little corner bits
        translate([0, 0, inset / 2 + support_distance / 2])
          squarish_rpoly(xy=[length, width], h=inset - support_distance, r=corner_radius, center=true);
        translate([0, 0, inset / 2])
          squarish_rpoly(xy=[length - extrusion_width * 2, width - extrusion_width * 2], h=inset + 1, r=corner_radius, center=true);
        translate([0, 0, inset / 2])
          cube([3, 20, inset + 1], center=true);
        translate([0, 0, inset / 2])
          cube([20, 3, inset + 1], center=true);
      }
    difference() {
      // Generate the center bit
      cylinder(d=3.5, h=inset - support_distance, $fn=32);
      cylinder(d=1.85, h=inset * 4, center=true, $fn=32);
    }
    // Add a flat thing at the bottom that makes it easy to pull the supports off
    translate([0, 0, (inset / 2 + 0.01) / 2]) difference() {
        // 0.01 is to work around a bug
        cube([support_dia, support_dia, inset / 2 + 0.01], center=true);
        cylinder(d=3, h=inset / 2, $fn=32, center=true); // Cut a hole out of the middle to ensure perimeters (strength)
      }
  }

  /* TODO: side support must be added when the whole keycap is assembled, not here
             module stem_box_cherry() must generate only the stem, not the support based on keycap         
    */
  // // Add side supports so you can print the keycap on its left or right sides
  // left_support = side_supports[0];
  // right_support = side_supports[1];
  // front_support = side_supports[2];
  // back_support = side_supports[3];
  // color("#005500") // Green
  // if (left_support || right_support || front_support || back_support) {
  //   for (loc = [0:1:len(stem_support_locations) - 1]) {
  //     if (stem_support_locations[loc][1] != 0) {
  //       // Only need to move them if they're Y (left/right) stems
  //       translate([stem_support_locations[loc][0], stem_support_locations[loc][1], 0])
  //         stem_support(
  //           key_height,
  //           key_length,
  //           key_width,
  //           dish_depth,
  //           dish_thickness,
  //           top_difference,
  //           key_corner_radius=key_corner_radius,
  //           stem_type="box_cherry",
  //           stem_depth=depth,
  //           wall_thickness=wall_thickness,
  //           wall_extra=wall_extra,
  //           wall_inset=wall_inset,
  //           wall_tolerance=wall_tolerance,
  //           top_x=top_x,
  //           top_y=top_y,
  //           outside_tolerance_x=outside_tolerance_x,
  //           outside_tolerance_y=outside_tolerance_y,
  //           inset=inset,
  //           top_thickness=top_thickness,
  //           side_support_thickness=side_support_thickness,
  //           side_supports=side_supports,
  //           support_distance=support_distance,
  //           location=stem_support_locations[loc],
  //           stem_support_locations=stem_support_locations,
  //            
  //           polygon_layers=polygon_layers,
  //           polygon_layer_rotation=polygon_layer_rotation,
  //           polygon_curve=polygon_curve,
  //           dish_tilt=dish_tilt,
  //           dish_tilt_curve=dish_tilt_curve,
  //           dish_x=dish_x,
  //           dish_y=dish_y,
  //           dish_z=dish_z,
  //           dish_fn=dish_fn,
  //           dish_corner_fn=dish_corner_fn,
  //           polygon_edges=polygon_edges,
  //           dish_type=dish_type,
  //           dish_division_x=dish_division_x,
  //           dish_division_y=dish_division_y,
  //           corner_radius=key_corner_radius,
  //           corner_radius_curve=corner_radius_curve,
  //           polygon_rotation=polygon_rotation,
  //           dish_invert=dish_invert,
  //           uniform_wall_thickness=uniform_wall_thickness
  //         );
  //     } else {
  //       stem_support(
  //         key_height,
  //         key_length,
  //         key_width,
  //         dish_depth,
  //         dish_thickness,
  //         top_difference,
  //         key_corner_radius=key_corner_radius,
  //         stem_type="box_cherry",
  //         stem_depth=depth,
  //         wall_thickness=wall_thickness,
  //         wall_extra=wall_extra,
  //         wall_inset=wall_inset,
  //         top_x=top_x,
  //         top_y=top_y,
  //         outside_tolerance_x=outside_tolerance_x,
  //         outside_tolerance_y=outside_tolerance_y,
  //         inset=inset,
  //         top_thickness=top_thickness,
  //         side_support_thickness=side_support_thickness,
  //         side_supports=side_supports,
  //         support_distance=support_distance,
  //         location=stem_support_locations[loc],
  //         stem_support_locations=stem_support_locations,
  //          
  //         polygon_layers=polygon_layers,
  //         polygon_layer_rotation=polygon_layer_rotation,
  //         polygon_curve=polygon_curve,
  //         dish_tilt=dish_tilt,
  //         dish_x=dish_x,
  //         dish_y=dish_y,
  //         dish_z=dish_z,
  //         dish_fn=dish_fn,
  //         dish_corner_fn=dish_corner_fn,
  //         dish_tilt_curve=dish_tilt_curve,
  //         polygon_edges=polygon_edges,
  //         dish_type=dish_type,
  //         dish_division_x=dish_division_x,
  //         dish_division_y=dish_division_y,
  //         corner_radius=key_corner_radius,
  //         corner_radius_curve=corner_radius_curve,
  //         polygon_rotation=polygon_rotation,
  //         dish_invert=dish_invert,
  //         uniform_wall_thickness=uniform_wall_thickness
  //       );
  //     }
  //   }
  // }
}

module stem_round_cherry(
  depth = 4,
  outside_tolerance = 0.2,
  inside_tolerance = 0.25,
  inset = 0,
  flat_support = true,
  support_distance = 0.2,
  corner_radius = 0.5,
  // // Stem lateral support parameters
  // // TODO: side support must be added when the whole keycap is assembled, when generating the stem-> it makes the code so less maintainable to do it here
  // key_height,
  // uniform_wall_thickness = false,
  // dish_invert = false,
  // polygon_rotation = false,
  // corner_radius_curve = 0,
  // key_length,
  // key_width,
  // dish_depth = 1,
  // dish_thickness,
  // top_difference,
  // dish_tilt = 0,
  // wall_thickness = 1.35,
  // wall_extra = 0.65,
  // wall_inset = 0,
  // wall_tolerance = 0.25,
  // key_corner_radius = 0.5,
  // top_x = 0,
  // top_y = 0,
  // top_thickness = 0.6,
  // side_support_thickness = 0.8,
  // side_supports = [0, 0, 0, 0],
  // stem_support_locations = [[0, 0, 0]],
  // polygon_layers = 5,
  // polygon_layer_rotation = 0,
  // polygon_curve = 0,
  // dish_tilt_curve = false,
  // dish_x = 0,
  // dish_y = 0,
  // dish_z = -0.75,
  // dish_fn = 32,
  // dish_corner_fn = 64,
  // dish_division_x = 4,
  // dish_division_y = 1,
  // polygon_edges = 4,
  // dish_type = "cylinder"
) {
  extrusion_width = 0.45; // TODO TEMP (for now)
  length = CHERRY_CYLINDER_DIAMETER - outside_tolerance;
  width = CHERRY_CYLINDER_DIAMETER - outside_tolerance;
  support_dia = 7; // Size of the removable "flat thing" (bigger == easier to grab/remove with a tool)
  $fn = 64;

  // Generate the top part of the stem that connects to the underside of the keycap
  difference() {
    translate([0, 0, depth / 2 + inset])
      cylinder(d=CHERRY_CYLINDER_DIAMETER - outside_tolerance, h=depth, center=true);
    translate([0, 0, inset])
      cherry_cross(tolerance=inside_tolerance, flare_base=true);
  }

  stem_topper_height = depth;
  translate([0, 0, stem_topper_height / 2 + inset + depth]) {
    cylinder(
      d=CHERRY_CYLINDER_DIAMETER - outside_tolerance,
      h=stem_topper_height,
      center=true
    );
  }

  color("#005500") // Green
  if (flat_support && inset > 0) {
    translate([0, 0, -support_distance]) difference() {
        // Generate the little corner bits
        translate([0, 0, inset / 2 + support_distance / 2])
          squarish_rpoly(xy=[length, width], h=inset - support_distance, r=corner_radius, center=true);
        translate([0, 0, inset / 2])
          squarish_rpoly(xy=[length - extrusion_width * 3, width - extrusion_width * 3], h=inset + 1, r=corner_radius, center=true);
        translate([0, 0, inset / 2])
          cube([1, 20, inset + 1], center=true);
        translate([0, 0, inset / 2])
          cube([20, 1, inset + 1], center=true);
        translate([0, 0, inset / 2])
          rotate([0, 0, 45])
            cube([20, 1, inset + 1], center=true);
        translate([0, 0, inset / 2])
          rotate([0, 0, -45])
            cube([20, 1, inset + 1], center=true);
      }
    difference() {
      // Generate the center bit
      cylinder(d=3.5, h=inset - support_distance, $fn=32);
      cylinder(d=1.85, h=inset * 4, center=true, $fn=32);
    }
    // Add a flat thing at the bottom that makes it easy to pull the supports off
    translate([0, 0, inset / 4]) difference() {
        cube([support_dia, support_dia, inset / 2], center=true);
        cylinder(d=3, h=inset / 2, $fn=32, center=true); // Cut a hole out of the middle to ensure perimeters (strength)
      }
  }

  // /* TODO: side support must be added when the whole keycap is assembled, not here
  //            module stem_round_cherry() must generate only the stem, not the support based on keycap         
  // */
  // // Add side supports so you can print the keycap on its left or right sides
  // left_support = side_supports[0];
  // right_support = side_supports[1];
  // front_support = side_supports[2];
  // back_support = side_supports[3];
  // //        color("#005500") // Green
  // if (left_support || right_support || front_support || back_support) {
  //   for (loc = [0:1:len(stem_support_locations) - 1]) {
  //     if (stem_support_locations[loc][1] != 0) {
  //       // Only need to move them if they're Y (left/right) stems
  //       translate([stem_support_locations[loc][0], stem_support_locations[loc][1], 0])
  //         stem_support(
  //           key_height,
  //           key_length,
  //           key_width,
  //           dish_depth,
  //           dish_thickness,
  //           top_difference,
  //           key_corner_radius=key_corner_radius,
  //           stem_type="round_cherry",
  //           stem_depth=depth,
  //           wall_thickness=wall_thickness,
  //           wall_extra=wall_extra,
  //           wall_inset=wall_inset,
  //           wall_tolerance=wall_tolerance,
  //           top_x=top_x,
  //           top_y=top_y,
  //           outside_tolerance=outside_tolerance,
  //           inset=inset,
  //           top_thickness=top_thickness,
  //           side_support_thickness=side_support_thickness,
  //           side_supports=side_supports,
  //           support_distance=support_distance,
  //           location=stem_support_locations[loc],
  //           stem_support_locations=stem_support_locations,
  //           polygon_layers=polygon_layers,
  //           polygon_layer_rotation=polygon_layer_rotation,
  //           polygon_curve=polygon_curve,
  //           dish_tilt=dish_tilt,
  //           dish_tilt_curve=dish_tilt_curve,
  //           dish_x=dish_x,
  //           dish_y=dish_y,
  //           dish_z=dish_z,
  //           dish_fn=dish_fn,
  //           dish_corner_fn=dish_corner_fn,
  //           polygon_edges=polygon_edges,
  //           dish_type=dish_type,
  //           dish_division_x=dish_division_x,
  //           dish_division_y=dish_division_y,
  //           corner_radius=key_corner_radius,
  //           corner_radius_curve=corner_radius_curve,
  //           polygon_rotation=polygon_rotation,
  //           dish_invert=dish_invert,
  //           uniform_wall_thickness=uniform_wall_thickness
  //         );
  //     } else {
  //       stem_support(
  //         key_height,
  //         key_length,
  //         key_width,
  //         dish_depth,
  //         dish_thickness,
  //         top_difference,
  //         key_corner_radius=key_corner_radius,
  //         stem_type="round_cherry",
  //         stem_depth=depth,
  //         wall_thickness=wall_thickness,
  //         wall_extra=wall_extra,
  //         wall_inset=wall_inset,
  //         top_x=top_x,
  //         top_y=top_y,
  //         outside_tolerance=outside_tolerance,
  //         inset=inset,
  //         top_thickness=top_thickness,
  //         side_support_thickness=side_support_thickness,
  //         side_supports=side_supports,
  //         support_distance=support_distance,
  //         location=stem_support_locations[loc],
  //         stem_support_locations=stem_support_locations,
  //         polygon_layers=polygon_layers,
  //         polygon_layer_rotation=polygon_layer_rotation,
  //         polygon_curve=polygon_curve,
  //         dish_tilt=dish_tilt,
  //         dish_x=dish_x,
  //         dish_y=dish_y,
  //         dish_z=dish_z,
  //         dish_fn=dish_fn,
  //         dish_tilt_curve=dish_tilt_curve,
  //         polygon_edges=polygon_edges,
  //         dish_type=dish_type,
  //         dish_division_x=dish_division_x,
  //         dish_division_y=dish_division_y,
  //         corner_radius=key_corner_radius,
  //         corner_radius_curve=corner_radius_curve,
  //         polygon_rotation=polygon_rotation,
  //         dish_invert=dish_invert,
  //         uniform_wall_thickness=uniform_wall_thickness
  //       );
  //     }
  //   }
  // }
}

module stem_alps(
  depth = 3.5,
  corner_radius = 0.25,
  outside_tolerance_x = 0.2,
  outside_tolerance_y = 0.2,
  inset = 0,
  flat_support = true,
  support_distance = 0.2,
  // // Stem lateral support parameters
  // // TODO: side support must be added when the whole keycap is assembled, when generating the stem-> it makes the code so less maintainable to do it here
  // key_height,
  // key_length,
  // key_width,
  // dish_thickness,
  // top_difference,
  // dish_type = "cylinder",
  // wall_thickness = 1.35,
  // wall_extra = 0.65,
  // wall_inset = 0,
  // wall_tolerance = 0.25,
  // top_x = 0,
  // top_y = 0,
  // top_thickness = 0.6,
  // side_support_thickness = 0.8,
  // side_supports = [0, 0, 0, 0],
  // locations = [[0, 0, 0]],
  // polygon_layers = 5,
  // polygon_layer_rotation = 0,
  // polygon_curve = 0,
  // dish_tilt = 0,
  // dish_depth = 1,
  // dish_x = 0,
  // dish_y = 0,
  // dish_z = -0.75,
  // dish_fn = 32,
  // dish_corner_fn = 64,
  // dish_tilt_curve = false,
  // dish_division_x = 4,
  // dish_division_y = 1,
  // polygon_edges = 4,
  // key_corner_radius = 0.5,
  // corner_radius_curve = 0,
  // polygon_rotation = false,
  // dish_invert = false,
  // uniform_wall_thickness = false
) {
  extrusion_width = 0.45; // TODO TEMP (for now)
  length = ALPS_STEM_LENGTH - outside_tolerance_x * 2;
  width = ALPS_STEM_WIDTH - outside_tolerance_y * 2;

  // Generate the top part of the stem that connects to the underside of the keycap
  difference() {
    // Alps stem
    translate([0, 0, depth / 2 + inset])
      squarish_rpoly(
        xy1=[length, width],
        xy2=[length, width],
        h=depth,
        r=corner_radius, center=true
      );
  }

  stem_topper_height = depth;
  // Alps stem topper
  translate(
    [
      0,
      0,
      stem_topper_height / 2 + inset + depth,
    ]
  )
    squarish_rpoly(
      xy1=[length, width],
      xy2=[length, width],
      h=stem_topper_height,
      r=corner_radius, center=true
    );

  color("#005500") // Green
  if (flat_support && inset > 0) {
    // Generate the support bits that go under the stem
    translate([0, 0, -support_distance]) difference() {
        // Generate the little corner bits
        translate([0, 0, inset / 2 + support_distance / 2])
          squarish_rpoly(xy=[length, width], h=inset - support_distance, r=corner_radius, center=true);
        translate([0, 0, inset / 2])
          squarish_rpoly(xy=[length - extrusion_width * 2, width - extrusion_width * 2], h=inset + 1, r=corner_radius, center=true);
        translate([0, 0, inset / 2])
          cube([3, 20, inset + 1], center=true);
        translate([0, 0, inset / 2])
          cube([20, 3, inset + 1], center=true);
      }
    difference() {
      // Generate the center bit
      cylinder(d=3.5, h=inset - support_distance, $fn=32);
      cylinder(d=1.85, h=inset * 4, center=true, $fn=32);
    }
    // Add a flat thing at the bottom that makes it easy to pull the supports off
    translate([0, 0, inset / 4]) difference() {
        cube([support_dia, support_dia, inset / 2], center=true);
        cylinder(d=3, h=inset / 2, $fn=32, center=true); // Cut a hole out of the middle to ensure perimeters (strength)
      }
  }

  // // Add side supports so you can print the keycap on its left or right sides
  // support_dia = 7; // Size of the removable "flat thing" (bigger == easier to grab/remove with a tool)
  // left_support = side_supports[0];
  // right_support = side_supports[1];
  // front_support = side_supports[2];
  // back_support = side_supports[3];
  // color("#005500") // Green
  // if (left_support || right_support || front_support || back_support) {

  //   for (loc = [0:1:len(locations) - 1]) {
  //     if (locations[loc][1] != 0) {
  //       // Only need to move them if they're Y (left/right) stems
  //       translate([locations[loc][0], locations[loc][1], 0])
  //         stem_support(
  //           key_height,
  //           key_length,
  //           key_width,
  //           dish_depth,
  //           dish_thickness,
  //           top_difference,
  //           key_corner_radius=key_corner_radius,
  //           stem_type="alps",
  //           stem_depth=depth,
  //           wall_thickness=wall_thickness,
  //           wall_extra=wall_extra,
  //           wall_inset=wall_inset,
  //           wall_tolerance=wall_tolerance,
  //           top_x=top_x, top_y=top_y,
  //           outside_tolerance_x=outside_tolerance_x,
  //           outside_tolerance_y=outside_tolerance_y,
  //           inset=inset, top_thickness=top_thickness,
  //           side_support_thickness=side_support_thickness,
  //           side_supports=side_supports,
  //           support_distance=support_distance,
  //           location=locations[loc],
  //           locations=locations,
  //           polygon_layers=polygon_layers,
  //           polygon_layer_rotation=polygon_layer_rotation,
  //           polygon_curve=polygon_curve,
  //           dish_type=dish_type,
  //           dish_tilt=dish_tilt,
  //           dish_tilt_curve=dish_tilt_curve,
  //           dish_x=dish_x,
  //           dish_y=dish_y,
  //           dish_z=dish_z,
  //           dish_fn=dish_fn,
  //           dish_corner_fn=dish_corner_fn,
  //           dish_division_x=dish_division_x,
  //           dish_division_y=dish_division_y,
  //           polygon_edges=polygon_edges,
  //           corner_radius=key_corner_radius,
  //           corner_radius_curve=corner_radius_curve,
  //           polygon_rotation=polygon_rotation,
  //           dish_invert=dish_invert,
  //           uniform_wall_thickness=uniform_wall_thickness
  //         );
  //     } else {
  //       stem_support(
  //         key_height,
  //         key_length,
  //         key_width,
  //         dish_depth,
  //         dish_thickness,
  //         top_difference,
  //         key_corner_radius=key_corner_radius,
  //         stem_type="alps",
  //         stem_depth=depth,
  //         wall_thickness=wall_thickness,
  //         wall_extra=wall_extra,
  //         wall_inset=wall_inset,
  //         wall_tolerance=wall_tolerance,
  //         top_x=top_x, top_y=top_y,
  //         outside_tolerance_x=outside_tolerance_x,
  //         outside_tolerance_y=outside_tolerance_y,
  //         inset=inset, top_thickness=top_thickness,
  //         side_support_thickness=side_support_thickness,
  //         side_supports=side_supports,
  //         support_distance=support_distance,
  //         location=locations[loc],
  //         locations=locations,
  //         polygon_layers=polygon_layers,
  //         polygon_layer_rotation=polygon_layer_rotation,
  //         polygon_curve=polygon_curve,
  //         dish_type=dish_type,
  //         dish_tilt=dish_tilt,
  //         dish_tilt_curve=dish_tilt_curve,
  //         dish_x=dish_x,
  //         dish_y=dish_y,
  //         dish_z=dish_z,
  //         dish_fn=dish_fn,
  //         dish_corner_fn=dish_corner_fn,
  //         dish_division_x=dish_division_x,
  //         dish_division_y=dish_division_y,
  //         polygon_edges=polygon_edges,
  //         corner_radius=key_corner_radius,
  //         corner_radius_curve=corner_radius_curve,
  //         polygon_rotation=polygon_rotation,
  //         dish_invert=dish_invert,
  //         uniform_wall_thickness=uniform_wall_thickness
  //       );
  //     }
  //   }
  // }
}

// Makes a single center support that we can duplicate under other stems:
module stem_support(
  key_height,
  key_length,
  key_width,
  dish_depth,
  dish_thickness,
  top_difference,
  key_corner_radius = 0.5,
  stem_type = "box_cherry",
  stem_depth = 4,
  wall_thickness = 1.35,
  wall_extra = 0.65,
  wall_inset = 0,
  wall_tolerance = 0.25,
  top_x = 0,
  top_y = 0,
  outside_tolerance = 0,
  outside_tolerance_x = 0,
  outside_tolerance_y = 0,
  inset = 0,
  top_thickness = 0.6,
  side_support_thickness = 0.8,
  side_supports = [0, 0, 0, 0],
  support_distance = 0.2,
  location = [0, 0, 0],
  locations = [[0, 0, 0]],
  polygon_layers = 5,
  polygon_layer_rotation = 0,
  polygon_curve = 0,
  dish_tilt = 0,
  dish_tilt_curve = false,
  dish_depth = 1,
  dish_x = 0,
  dish_y = 0,
  dish_z = -0.75,
  dish_fn = 32,
  dish_corner_fn = 64,
  dish_tilt_curve = false,
  dish_division_x = 4,
  dish_division_y = 1,
  polygon_edges = 4,
  dish_type = "cylinder",
  corner_radius = 0.5,
  corner_radius_curve = 0,
  polygon_rotation = false,
  dish_invert = false,
  uniform_wall_thickness = false
) {
  extrusion_width = 0.45;
  box_cherry_length = CHERRY_CYLINDER_DIAMETER - outside_tolerance_x * 2;
  box_cherry_width = CHERRY_CYLINDER_DIAMETER - outside_tolerance_y * 2;
  alps_length = ALPS_STEM_LENGTH - outside_tolerance_x * 2;
  alps_width = ALPS_STEM_WIDTH - outside_tolerance_y * 2;
  stem_corner_radius = 1; // Of the stem's exterior "box"
  left_support = side_supports[0];
  right_support = side_supports[1];
  front_support = side_supports[2];
  back_support = side_supports[3];
  // If the side support is too close to the underside of the keycap the slicer
  // will connect it.  Since we don't want that we add a little extra space
  // between the side support and the underside of the keycap:
  support_distance_extra = 0.5; // Only used with uniform_wall_thickness
  // Inverted dish needs to go up a bit
  inverted_dish_adjustment = dish_invert ? wall_thickness : 0;
  // When not using uniform_wall_thickness, this is used to figure out how much extra space the corner radius takes up at the top of the keycap so the stem doesn't stick out the sides:
  corner_radius_factor = ( (corner_radius * corner_radius_curve / polygon_layers) * polygon_layers) / 1.5;
  difference() {
    // NOTE: The side supports are actually attached to the sides so they stay firm while printing... They're easy enough to cut off afterwards with flush cutters.
    translate([0, 0, -0.001])
    // This fills in the entire area under the keycap:
    if (uniform_wall_thickness) {
      _poly_keycap(
        // Since this is an interior cutout sort of thing we need to cut the height down slightly so there's some overlap
        height=key_height + inverted_dish_adjustment,
        length=key_length - wall_thickness * 2 - wall_extra * 2,
        width=key_width - wall_thickness * 2 - wall_extra * 2,
        top_difference=top_difference, dish_tilt=dish_tilt,
        dish_tilt_curve=dish_tilt_curve,
        top_x=top_x, top_y=top_y, dish_depth=dish_depth,
        dish_x=dish_x, dish_y=dish_y, dish_z=dish_z,
        dish_fn=dish_fn,
        dish_corner_fn=dish_corner_fn,
        polygon_layers=polygon_layers,
        polygon_layer_rotation=polygon_layer_rotation,
        polygon_edges=polygon_edges, polygon_curve=polygon_curve,
        dish_type=dish_type,
        dish_division_x=dish_division_x, dish_division_y=dish_division_y,
        corner_radius=key_corner_radius / 2,
        corner_radius_curve=corner_radius_curve,
        polygon_rotation=polygon_rotation,
        dish_invert=dish_invert
      );
    } else {
      // NOTE: Using the interior stem cutout sizing with wall_extra*2 below because it works with both regular stems and snap-fit stems
      squarish_rpoly(
        xy1=[
          key_length - wall_thickness - wall_tolerance * 2 - wall_extra * 2,
          key_width - wall_thickness - wall_tolerance * 2 - wall_extra * 2,
        ],
        xy2=[
          key_length - wall_thickness - wall_tolerance * 2 - top_difference - wall_extra * 2 - corner_radius_factor,
          key_width - wall_thickness - wall_tolerance * 2 - top_difference - wall_extra * 2 - corner_radius_factor,
        ],
        xy2_offset=[top_x, top_y],
        h=key_height, r=key_corner_radius / 2, center=false
      );
    }
    // Cut off the top (area just below the dish)
    if (uniform_wall_thickness) {
      // Inverted dish needs to go up a bit
      inverted_dish_adjustment = dish_invert ? (dish_depth + wall_thickness) / 1.5 : 0;
      // This is more accurate but MAN does it increase rending times!  Disabled until I figure out a more efficient way to handle this:
      //            translate([
      //                0,
      //                0,
      //                wall_thickness-inverted_dish_adjustment-support_distance])
      //                    stem_top(
      //                        key_height+inverted_dish_adjustment,
      //                        key_length-wall_thickness,
      //                        key_width-wall_thickness,
      //                        dish_depth=dish_depth,
      //                        dish_thickness=dish_thickness,
      //                        top_difference=top_difference,
      //                        dish_tilt=dish_tilt,
      //                        top_thickness=top_thickness,
      //                        key_corner_radius=key_corner_radius,
      //                        wall_thickness=wall_thickness,
      //                        wall_extra=wall_extra,
      //                        wall_inset=wall_inset,
      //                        wall_tolerance=wall_tolerance,
      //                        top_x=top_x, top_y=top_y,
      //                        dish_invert=dish_invert,
      //                        dish_type=dish_type,
      //                        dish_x=dish_x,
      //                        dish_y=dish_y,
      //                        dish_z=dish_z,
      //                        dish_fn=dish_fn,
      //                        dish_corner_fn=dish_corner_fn,
      //                        dish_tilt_curve=dish_tilt_curve,
      //                        corner_radius_curve=corner_radius_curve,
      //                        polygon_layers=polygon_layers,
      //                        polygon_layer_rotation=polygon_layer_rotation,
      //                        polygon_edges=polygon_edges,
      //                        polygon_curve=polygon_curve,
      //                        polygon_rotation=polygon_rotation,
      //                        uniform_wall_thickness=uniform_wall_thickness);
      translate(
        [
          0,
          0,
          key_height * 1.5 - wall_thickness - dish_depth + dish_z + inverted_dish_adjustment - support_distance - support_distance_extra,
        ]
      )
        cube([key_length * 2, key_width * 2, key_height], center=true);
    } else {
      // Inverted dish needs to go up a bit
      inverted_dish_adjustment = dish_invert ? top_thickness : 0;
      translate(
        [
          0,
          0,
          key_height * 1.5 - dish_depth - dish_thickness - top_thickness + dish_z - support_distance + inverted_dish_adjustment,
        ]
      )
        cube([key_length * 2, key_width * 2, key_height], center=true);
    }
    // Cut off the bottom so the support will match the inset (if any)
    translate([0, 0, -key_height / 2 + inset + wall_inset])
      cube([key_length * 2, key_width * 2, key_height], center=true);
    // Cut out holes around the stem locations
    if (stem_type == "box_cherry") {
      // This is a box_cherry stem
      for (loc = [0:1:len(locations) - 1]) {
        translate([locations[loc][0], locations[loc][1], key_height / 2 + locations[loc][2] - 0.01])
          squarish_rpoly(
            xy=[
              box_cherry_length + support_distance * 2,
              box_cherry_width + support_distance * 2,
            ],
            h=key_height, r=stem_corner_radius, center=true
          );
      }
    } else if (stem_type == "round_cherry") {
      // This is a round_cherry stem
      for (loc = [0:1:len(locations) - 1]) {
        // Cut out the stem locations
        translate([locations[loc][0], locations[loc][1], key_height / 2 + locations[loc][2] - 0.01])
          cylinder(d=CHERRY_CYLINDER_DIAMETER + support_distance * 2, h=key_height, center=true);
      }
    } else if (stem_type == "alps") {
      // This is an alps stem
      for (loc = [0:1:len(locations) - 1]) {
        // Cut out the stem locations
        translate([locations[loc][0], locations[loc][1], key_height / 2 + locations[loc][2] - 0.01]) union() {
            squarish_rpoly(
              xy=[
                alps_length + support_distance * 2,
                alps_width + support_distance * 2,
              ],
              h=key_height, r=stem_corner_radius / 4, center=true
            );
            translate([0, 0, -support_distance / 2]) squarish_rpoly(
                xy1=[alps_length, alps_width],
                xy2=[
                  alps_length * 1.5 + support_distance * 2,
                  alps_width * 2.5 + support_distance * 2,
                ],
                h=key_height - ALPS_STEM_DEPTH - stem_depth + top_thickness, r=key_corner_radius / 2, center=true
              );
            // This cuts off some of the excess:
            translate([0, 0, key_height / 2 + support_distance * 2]) squarish_rpoly(
                xy=[
                  key_length,
                  key_width,
                ],
                h=key_height, r=stem_corner_radius / 4, center=true
              );
          }
      }
    }
    // Cut out any side supports we don't want
    if (!left_support) {
      translate(
        [
          -key_length - side_support_thickness / 2 + location[0],
          location[1],
          key_height / 2 - 0.01,
        ]
      )
        cube([key_length * 2, key_width * 2, key_height], center=true);
    }
    if (!right_support) {
      translate(
        [
          key_length + side_support_thickness / 2 + location[0],
          location[1],
          key_height / 2 - 0.01,
        ]
      )
        cube([key_length * 2, key_width * 2, key_height], center=true);
    }
    if (!front_support) {
      translate(
        [
          0,
          -key_width - side_support_thickness / 2,
          key_height / 2 - 0.01,
        ]
      )
        cube([key_length * 2, key_width * 2, key_height], center=true);
    }
    if (!back_support) {
      translate(
        [
          0,
          key_width + side_support_thickness / 2,
          key_height / 2 - 0.01,
        ]
      )
        cube([key_length * 2, key_width * 2, key_height], center=true);
    }
  }
}

// // For testing:
// key_height = 8;
// key_length = 18;
// key_width = 18;
// dish_depth = 1;
// dish_thickness = 1;
// top_difference = 0.8;
// depth = 4;
// dish_tilt = 0;
// wall_thickness = 1.8;
// key_corner_radius = 0.5;
// outside_tolerance_x = 0.15;
// outside_tolerance_y = 0.15;
// inside_tolerance = 0.2;
// inset = 0;
// top_thickness = -0.1;
// flat_support = false;

// stem_box_cherry(
//   // Generate the normal stem
//   depth=depth,
//   outside_tolerance_x=outside_tolerance_x,
//   outside_tolerance_y=outside_tolerance_y,
//   inside_tolerance=inside_tolerance,
//   inset=inset,
//   flat_support=flat_support
// );

// translate(v=[10, 0, 0])
// stem_round_cherry(
//   // Generate the normal stem
//   key_height=key_height,
//   key_length=key_length,
//   key_width=key_width,
//   dish_depth=dish_depth,
//   dish_thickness=dish_thickness,
//   top_difference=top_difference,
//   depth=depth, dish_tilt=dish_tilt,
//   wall_thickness=wall_thickness,
//   key_corner_radius=key_corner_radius,
//   outside_tolerance_x=outside_tolerance_x,
//   outside_tolerance_y=outside_tolerance_y,
//   inside_tolerance=inside_tolerance,
//   inset=inset,
//   flat_support=flat_support,
//   top_thickness=top_thickness
// );

// stem_alps(
//   // Generate the normal stem
//   depth=depth, 
//   outside_tolerance_x=outside_tolerance_x,
//   outside_tolerance_y=outside_tolerance_y,
//   inset=inset,
//   flat_support=flat_support,
// );

// TODO: find a way to reintegrate supports
// TODO: stem_top used by playground file-> do not delete
