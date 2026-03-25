// Profiles -- Modules that generate keycaps and stems for various profile types (KAT, DSA, SA, etc).

use <keycaps.scad>
use <stems.scad>
use <utils.scad>

// CONSTANTS
KEY_UNIT = 19.05; // Standard spacing between keys

/* NOTES
    * These profile-specific modules allow you to override *most* values via arguments.  So if you want say, "DCS but with skinnier tops" you could override that via the top_difference argument.
    * The row numbering comes from historical values.  So don't assume "row 1" is the Fkeys or the spacebar.  In a lot of profiles it's all screwed up (e.g. DCS).
    * DSA Spec taken from https://pimpmykeyboard.com/template/images/DSAFamily.pdf
    * Neat little FYI:
        SA = Spherical All-rows
        SS = Spherical Sculptured
        DSA = DIN-compliant Spherical All-rows
        DSS = DIN-compliant Spherical Sculptured
        DCS = DIN-compliant Cylindrical Sculptured
    * Riskeycap profile is one I developed specifically for ease of 3D printing.  It's similar to DSA but has flat sides that make it easier to print on keycaps on their side (so the layer lines run like this: |||) and come off the printer nice and smooth with no sanding required (except maybe to get rid of first layer squish/elephant's foot on the top right and bottom right corners).
*/

module generate_keycap(
  row = 1,
  length = 18.41,
  width = 18.41,
  height_extra = 0,
  wall_thickness = 1.35,
  dish_thickness = 1,
  dish_fn = 128,
  dish_corner_fn = 64,
  dish_depth = .8,
  dish_invert = false,
  stem_clips = false,
  stem_walls_inset = 0,
  top_difference = 6.08,
  corner_radius = 0.5,
  corner_radius_curve = 2,
  legend_list = [""],
  legend_carved = false,
  homing_dot_length = 0,
  homing_dot_width = 0,
  homing_dot_x = 0,
  homing_dot_y = 0,
  homing_dot_z = 0,
  polygon_layers = 10,
  visualize_legends = false,
  uniform_wall_thickness = false,
  key_profile = ""
) {

  assert(key_profile != "", "A key profile is needed");

  if (key_profile == "dsa") {
    // NOTE: Measured dish_depth in multiple DSA keycaps came out to ~.8
    // NOTE: Spec says wall_thickness should be 1mm but the default here is 1.35 since this script will mostly be used in 3D printing.  Make sure to set it to 1mm if making an injection mold.

    // NOTE: The 0-index values are ignored (there's no row 0 in DSA)
    row_height = dish_invert ? 6.3914 + height_extra : 7.3914 + height_extra; // One less if we're generating a spacebar
    // NOTE: 7.3914 is from the Signature Plastics DSA spec which has .291 inches
    if (row != 1) {
      warning("Only row 1 is supported for DSA profile caps.");
    }
    //    width = 18.41; // 0.725 inches
    dish_type = "sphere";
    dish_z = 0.111; // NOTE: Width of the top dish (at widest) should be ~12.7mm
    top_y = 0;
    poly_keycap(
      height=row_height, length=length, width=width, wall_thickness=wall_thickness,
      top_difference=top_difference, dish_tilt=0, dish_z=dish_z, dish_fn=dish_fn,
      dish_corner_fn=dish_corner_fn,
      dish_invert=dish_invert, top_y=top_y, dish_depth=dish_depth, dish_type=dish_type,
      dish_thickness=dish_thickness, corner_radius=corner_radius,
      corner_radius_curve=corner_radius_curve,
      stem_clips=stem_clips, stem_walls_inset=stem_walls_inset,
      legend_list=legend_list,
      legend_carved=legend_carved,
      polygon_layers=polygon_layers, polygon_layer_rotation=0,
      polygon_edges=4, polygon_curve=4.5,
      homing_dot_length=homing_dot_length, homing_dot_width=homing_dot_width,
      homing_dot_x=homing_dot_x, homing_dot_y=homing_dot_y, homing_dot_z=homing_dot_z,
      uniform_wall_thickness=uniform_wall_thickness,
      visualize_legends=visualize_legends
    );
  }
  //
  else if (key_profile == "dcs") {
    // NOTE: dish_thickness gets *added* to the default thickness of this profile which is approximately 1mm (depending on the keycap). This is to prevent a low dish_thickness value from making an unusable keycap
    // NOTE: The 0-index values are ignored (there's no row 0 in DCS)
    row_height = [0, 9.5, 7.39, 7.39, 9, 12.5];
    dish_tilt = [0, -1, 3, 7, 16, -6];
    // Dish needs to cut into the top a unique amount depending on the height and angle
    dish_z = [0, -0.11, -0.38, -0.78, 0.6, -0.75];
    dish_thicknesses = [0, 1.2, 1.6, 2, 3, 2];
    adjusted_dish_thickness = dish_thicknesses[row] + dish_thickness;
    if (row < 1) {
      warning("We only support rows 1-5 for DCS profile caps!");
    }
    row = row < 6 ? row : 5; // We only support rows 0-4 (5 total rows)
    dish_type = "cylinder";
    dish_depth = 1;
    top_y = -1.75;
    poly_keycap(
      height=row_height[row] + height_extra,
      length=length,
      width=width,
      wall_thickness=wall_thickness,
      top_difference=top_difference,
      dish_tilt=dish_tilt[row],
      dish_z=dish_z[row],
      top_y=top_y,
      dish_depth=dish_depth,
      dish_type=dish_type,
      stem_clips=stem_clips,
      stem_walls_inset=stem_walls_inset,
      dish_thickness=adjusted_dish_thickness,
      dish_fn=dish_fn,
      dish_corner_fn=dish_corner_fn,
      dish_invert=dish_invert,
      legend_list=legend_list,
      legend_carved=legend_carved,
      corner_radius=corner_radius,
      corner_radius_curve=corner_radius_curve,
      polygon_layers=polygon_layers,
      polygon_layer_rotation=0,
      polygon_edges=4,
      homing_dot_length=homing_dot_length,
      homing_dot_width=homing_dot_width,
      homing_dot_x=homing_dot_x,
      homing_dot_y=homing_dot_y,
      homing_dot_z=homing_dot_z,
      uniform_wall_thickness=uniform_wall_thickness,
      visualize_legends=visualize_legends
    );
  } //
  else if (key_profile == "dss") {
    // NOTE: The 0-index values are ignored (there's no row 0 in DSS)
    row_height = [0, 10.4, 8.7, 8.5, 10.6];
    adjusted_row_height = dish_invert ? row_height[row] + height_extra - 1 : row_height[row] + height_extra; // One less if we're generating a spacebar (which is always row 3 with DSS)
    dish_tilt = [0, -1, 3, 8, 16];
    // Dish needs to cut into the top a unique amount depending on the height and angle
    dish_y = [0, 1.2, -2.5, -5.7, -11.4];
    // Dish needs to cut into the top a unique amount depending on the height and angle
    dish_z = [0, 0, 0, 0, -1.1];
    dish_thicknesses = [0, 2.5, 2.5, 2.5, 3.5];
    if (row < 1) {
      warning("We only support rows 1-4 for DSS profile caps!");
    }
    row = row < 5 ? row : 4; // We only support rows 1-4 (4 total rows)
    dish_type = "sphere";
    dish_depth = 1;
    top_y = 0;
    poly_keycap(
      height=adjusted_row_height, length=length, width=width,
      wall_thickness=wall_thickness,
      top_difference=top_difference, dish_tilt=dish_tilt[row],
      dish_z=dish_z[row], dish_y=dish_y[row],
      top_y=top_y, dish_depth=dish_depth, dish_type=dish_type,
      stem_clips=stem_clips, stem_walls_inset=stem_walls_inset,
      dish_thickness=dish_thicknesses[row], dish_fn=dish_fn, dish_corner_fn=dish_corner_fn,
      dish_invert=dish_invert,
      legend_list=legend_list,
      legend_carved=legend_carved,
      corner_radius=corner_radius, corner_radius_curve=corner_radius_curve,
      polygon_layers=polygon_layers, polygon_layer_rotation=0, polygon_edges=4,
      polygon_curve=4,
      homing_dot_length=homing_dot_length, homing_dot_width=homing_dot_width,
      homing_dot_x=homing_dot_x, homing_dot_y=homing_dot_y, homing_dot_z=homing_dot_z,
      uniform_wall_thickness=uniform_wall_thickness,
      visualize_legends=visualize_legends
    );
  } //
  else if (key_profile == "kat") {
    /* NOTES
    So here's the deal with the KAT profile:  The *dishes* are accurately-placed but the curve that goes up the side of the keycap (front and back) isn't *quite* right because whoever modeled the KAT profile probably started with DSA and then extruded/moved things up/down and forwards/backwards a bit until they had what they wanted.  This makes generating these keycaps via an algorithm difficult.  Having said that the curve is quite close to the original and you'd have to look *very* closely to be able to tell the difference in real life.  As long as the dishes are in the right place that's what matters most.
    */

    // FYI: I know that the curve up the side of the keycap is a little off...  If anyone knows how to calculate the correct curve for KAT profile let me know and I'll fix it!
    if (row < 1 || row > 5) {
      warning("We only support rows 1-5 for KAT profile caps!");
    }
    // NOTE: KAT profile actually mandates 1.658mm wall thickness but I'm not going to force the user to use that
    // NOTE: The 0-index values are ignored (there's no row 0 in KAT)
    row_height = [0, 10.95, 9.15, 10.9, 11.9, 13.8]; //  R1     R2    R3    R4    R5
    dish_tilt = [0, -5, -0.5, 4.5, 1.95, 7.5];
    dish_y = [0, 4, 0.25, -3.75, -1.65, -6];
    top_y = [0, 0.75, 0.75, 0.75, 0.65, 0];
    dish_z = [0, -0.25, 0, -0.25, -0.25, -0.5];
    // Official KAT keycaps have a cylindrical dish when inverted:
    dish_type = dish_invert ? "cylinder" : "sphere";
    poly_keycap(
      height=row_height[row] + height_extra, length=length, width=width,
      wall_thickness=wall_thickness,
      top_difference=top_difference, dish_tilt=dish_tilt[row],
      dish_y=dish_y[row], dish_z=dish_z[row], dish_fn=dish_fn,
      dish_corner_fn=dish_corner_fn,
      dish_invert=dish_invert, top_y=top_y[row], dish_depth=dish_depth, dish_type=dish_type,
      dish_thickness=dish_thickness, corner_radius=corner_radius,
      corner_radius_curve=corner_radius_curve,
      stem_clips=stem_clips, stem_walls_inset=stem_walls_inset,
      legend_list=legend_list,
      legend_carved=legend_carved,
      polygon_layers=polygon_layers, polygon_layer_rotation=0,
      polygon_edges=4, polygon_curve=7,
      homing_dot_length=homing_dot_length, homing_dot_width=homing_dot_width,
      homing_dot_x=homing_dot_x, homing_dot_y=homing_dot_y, homing_dot_z=homing_dot_z,
      uniform_wall_thickness=uniform_wall_thickness,
      visualize_legends=visualize_legends
    );
  } //
  else if (key_profile == "kam") {
    row_height = dish_invert ? 8.05 : 9.05; // One less if we're generating a spacebar
    if (row != 1) {
      warning("Only row 1 is supported for KAM profile caps.");
    }
    dish_type = dish_invert ? "cylinder" : "sphere"; // KAM spacebars actually use cylindrical tops
    dish_z = 0;
    top_y = 0;
    poly_keycap(
      height=row_height + height_extra, length=length, width=width,
      wall_thickness=wall_thickness,
      top_difference=top_difference, dish_tilt=0, dish_z=dish_z, dish_fn=dish_fn,
      dish_corner_fn=dish_corner_fn,
      dish_invert=dish_invert, top_y=top_y, dish_depth=dish_depth, dish_type=dish_type,
      dish_thickness=dish_thickness, corner_radius=corner_radius,
      corner_radius_curve=corner_radius_curve,
      stem_clips=stem_clips, stem_walls_inset=stem_walls_inset,
      legend_list=legend_list,
      legend_carved=legend_carved,
      polygon_layers=polygon_layers, polygon_layer_rotation=0,
      polygon_edges=4, polygon_curve=4.5,
      homing_dot_length=homing_dot_length, homing_dot_width=homing_dot_width,
      homing_dot_x=homing_dot_x, homing_dot_y=homing_dot_y, homing_dot_z=homing_dot_z,
      uniform_wall_thickness=uniform_wall_thickness,
      visualize_legends=visualize_legends
    );
  } //
  else if (key_profile == "riskeycap") {
    // Riskable's keycap profile specifically made for 3D printing, the Riskeycap!
    /* NOTES about the Riskeycap:
    * It's a non-sculpted (aka "all the same height") profile with a 8.2mm height (similar to DSA).
    * 1.5mm spherical dish (because that's my favorite in terms of feel--like your finger is getting kissed with every keypress).
    * Sides are flat so that it can be easily printed on its side.  This ensures that stems end up strong and the top will feel smooth right off the printer (no sanding required).
    * Stem is not inset so it can be printed flat if needed.
    */

    // The height needs a smidge of adjustment based on the length of the keycap
    adjusted_height_extra = length < KEY_UNIT * 1.25 ? height_extra : height_extra + 0.35;
    adjusted_height = dish_invert ? 6.5 + adjusted_height_extra : 8.2 + adjusted_height_extra; // A bit less if we're generating a spacebar because the dish_depth is bigger than is typical
    adjusted_dish_depth = dish_invert ? 1 : dish_depth; // Make it a smaller for inverted dishes
    if (row != 1) {
      warning("Only row 1 is supported for Riskeycap profile caps.");
    }
    dish_type = "sphere";
    dish_z = 0;
    top_y = 0;
    //    echo(riskeycap_dish_depth=adjusted_dish_depth);
    //    echo(riskeycap_height=adjusted_height);
    poly_keycap(
      height=adjusted_height, length=length, width=width, wall_thickness=wall_thickness,
      top_difference=top_difference, dish_tilt=0, dish_x=0, dish_z=dish_z,
      dish_fn=dish_fn, dish_corner_fn=dish_corner_fn, dish_invert=dish_invert,
      top_y=top_y, dish_depth=adjusted_dish_depth, dish_type=dish_type,
      dish_thickness=dish_thickness, corner_radius=corner_radius,
      corner_radius_curve=corner_radius_curve,
      stem_clips=stem_clips, stem_walls_inset=stem_walls_inset,
      legend_list=legend_list,
      polygon_layers=polygon_layers, polygon_layer_rotation=0,
      polygon_edges=4, polygon_curve=0,
      legend_carved=legend_carved,
      homing_dot_length=homing_dot_length, homing_dot_width=homing_dot_width,
      homing_dot_x=homing_dot_x, homing_dot_y=homing_dot_y, homing_dot_z=homing_dot_z,
      visualize_legends=visualize_legends,
      uniform_wall_thickness=uniform_wall_thickness
    );
  } //
  else if (key_profile == "gem") {
    // Similar to Riskeycap but with a "gem cut" (like Asscher) =)

    // The height needs a smidge of adjustment based on the length of the keycap
    adjusted_height_extra = length < KEY_UNIT * 1.25 ? height_extra : height_extra + 0.35;
    adjusted_height = dish_invert ? 6.5 + adjusted_height_extra : 8.2 + adjusted_height_extra; // A bit less if we're generating a spacebar because the dish_depth is bigger than is typical
    adjusted_dish_depth = dish_invert ? 1 : dish_depth; // Make it a smaller for inverted dishes
    if (row != 1) {
      warning("Only row 1 is supported for GEM profile caps.");
    }
    dish_type = "sphere";
    dish_z = 0;
    top_y = 0;
    adjusted_dish_corner_fn = 4; // We ignore the parameter
    //    echo(gem_dish_depth=adjusted_dish_depth);
    //    echo(gem_height=adjusted_height);
    poly_keycap(
      height=adjusted_height, length=length, width=width, wall_thickness=wall_thickness,
      top_difference=top_difference, dish_tilt=0, dish_x=0, dish_z=dish_z,
      dish_fn=dish_fn, dish_corner_fn=adjusted_dish_corner_fn, dish_invert=dish_invert,
      top_y=top_y, dish_depth=adjusted_dish_depth, dish_type=dish_type,
      dish_thickness=dish_thickness, corner_radius=corner_radius,
      corner_radius_curve=corner_radius_curve,
      stem_clips=stem_clips, stem_walls_inset=stem_walls_inset,
      legend_list=legend_list,
      legend_carved=legend_carved,
      polygon_layers=polygon_layers, polygon_layer_rotation=0,
      polygon_edges=4, polygon_curve=0,
      homing_dot_length=homing_dot_length, homing_dot_width=homing_dot_width,
      homing_dot_x=homing_dot_x, homing_dot_y=homing_dot_y, homing_dot_z=homing_dot_z,
      visualize_legends=visualize_legends,
      uniform_wall_thickness=uniform_wall_thickness
    );
  } //
  else if (key_profile == "xda") {
    // NOTE: The 0-index values are ignored (there's no row 0 in XDA)
    row_height = dish_invert ? 8.1 + height_extra : 9.1 + height_extra; // One less if we're generating a spacebar
    if (row != 1) {
      warning("Only row 1 is supported for XDA profile caps.");
    }
    dish_type = "sphere";
    dish_z = 0;
    top_y = 0;
    poly_keycap(
      height=row_height, length=length, width=width, wall_thickness=wall_thickness,
      top_difference=top_difference, dish_tilt=0, dish_x=0, dish_z=dish_z,
      dish_fn=dish_fn, dish_corner_fn=dish_corner_fn, dish_invert=dish_invert,
      top_y=top_y, dish_depth=dish_depth, dish_type=dish_type,
      dish_thickness=dish_thickness, corner_radius=corner_radius,
      corner_radius_curve=corner_radius_curve,
      stem_clips=stem_clips, stem_walls_inset=stem_walls_inset,
      legend_list=legend_list,
      legend_carved=legend_carved,
      polygon_layers=polygon_layers, polygon_layer_rotation=0,
      polygon_edges=4, polygon_curve=5,
      homing_dot_length=homing_dot_length, homing_dot_width=homing_dot_width,
      homing_dot_x=homing_dot_x, homing_dot_y=homing_dot_y, homing_dot_z=homing_dot_z,
      visualize_legends=visualize_legends,
      uniform_wall_thickness=uniform_wall_thickness
    );
  } //
  else {
    warning(str("Key profile not recognized: ", key_profile));
  }
}

// Renders a stem
module generate_stem(
  stem_type = undef,
  stem_corner_radius = undef,
  stem_height = undef,
  stem_outside_tolerance_x = undef,
  stem_outside_tolerance_y,
  stem_inside_tolerance,
  stem_inset = 0,
  stem_flat_support = false,
  stem_support_distance = 0,
) {

  assert(stem_type != undef, "stem_type parameter is required");
  assert(stem_corner_radius != undef, "stem_corner_radius parameter is required");
  assert(stem_height != undef, "depth parameter is required");
  assert(stem_outside_tolerance_x != undef, "outside_tolerance_x parameter is required");

  if (stem_type == "box_cherry") {
    stem_box_cherry(
      stem_corner_radius=stem_corner_radius,
      stem_height=stem_height,
      outside_tolerance_x=stem_outside_tolerance_x,
      outside_tolerance_y=stem_outside_tolerance_y,
      inside_tolerance=stem_inside_tolerance,
      stem_inset=stem_inset,
      stem_flat_support=stem_flat_support,
      support_distance=stem_support_distance
    );
  } else if (stem_type == "round_cherry") {
    stem_round_cherry(
      corner_radius=stem_corner_radius,
      stem_height=stem_height,
      outside_tolerance=stem_outside_tolerance_x,
      inside_tolerance=stem_inside_tolerance,
      stem_inset=stem_inset,
      stem_flat_support=stem_flat_support,
      support_distance=stem_support_distance
    );
  } else if (stem_type == "alps") {
    stem_alps(
      stem_corner_radius=stem_corner_radius,
      stem_height=stem_height,
      outside_tolerance_x=stem_outside_tolerance_x,
      outside_tolerance_y=stem_outside_tolerance_y,
      stem_inset=stem_inset,
      stem_flat_support=stem_flat_support,
      support_distance=stem_support_distance
    );
  } else {
    warning(str("Stem type not recognized: ", stem_type));
  }
}
