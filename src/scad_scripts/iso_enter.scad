include <BOSL2/std.scad>
use <legends.scad>
use <utils.scad>
/*
* This function returns the iso enter path
* 
                                w_up                          
              ---------------------------------------      
          |   +-------------------------------------+    | 
          |   |D                                   C|    | 
          |   |                                     |    | 
          |   |                                     |    | 
    h_up  |   |                                     |    | 
          |   |                                     |    | 
          |   |                                     |    | 
          |   |E         F                          |    | 
          |   +---------+                           |    | 
                        |                           |    | 
                        |                           |    |  h_tot
                        |                           |    | 
                        |                           |    | 
                        |                           |    | 
                        |                           |    | 
                        |                           |    | 
                        |                           |    | 
                        |                           |    | 
                        |                           |    | 
                        |                           |    | 
                        |A                         B|    | 
                        +---------------------------+    | 

                        +----------------------------
                                  w_down
For standard enter:
w_up = 1.5 u ≈ 28.6 mm
w_down = 1.25 u ≈ 23.8 mm
h_up = 1 u ≈ 19.05 mm
h_tot = 2 u ≈ 38.1 mm

For skinny enter:
w_up = 1.25 u ≈ 23.8 mm
w_down = 1 u ≈ 19.05 mm
h_up = 1 u ≈ 19.05 mm
h_tot = 2 u ≈ 38.1 mm

*/
function iso_enter_path(unit, f_radius, skinny = false) =
  round_corners(
    skinny ?
      [
        [0, 0], // A
        [unit, 0], // B
        [unit, 2 * unit], // C
        [-(0.25 * unit), 2 * unit], // D
        [-(0.25 * unit), unit], // E
        [0, unit], // F
      ]
    : [
      [0, 0], // A
      [1.25 * unit, 0], // B
      [1.25 * unit, 2 * unit], // C
      [-(0.25 * unit), 2 * unit], // D
      [-(0.25 * unit), unit], // E
      [0, unit], // F
    ], method="circle", radius=[
      f_radius,
      f_radius,
      f_radius,
      f_radius,
      f_radius > 1 ? 1 : f_radius,
      f_radius > 1 ? 1 : f_radius,
    ] // Do not round E,F more than 1 since the fillet will clash
  );

/* Module to create the iso enter solid
Parameters:
- unit1: base layer value of u(nit) in mm (required)
- unit2: top layer value of u(nit) in mm if different from base layer (optional; if not provided, it will be the same as unit1)
- height: solid height (z offset of top layer) (required)
- skinny: whether to use the skinny enter dimensions (optional; default: false)
- xy_offset: xy offset of top layer (optional; default: [0, 0])
- fillet_radius_base: fillet radius of base (required)
- fillet_radius_top: fillet radius of top
- n_layers: number of layers for the loft (higher = smoother but slower) (required)
- $fn: Number of fragments for rounded corners (high = smoother) (optional; default: 64)
*/
module iso_enter_solid(
  unit1 = undef, // base layer value of u(nit) in mm 
  unit2 = undef, // top layer value of u(nit) in mm if different from base layer
  height = undef, // inter layer height (z offset of top layer) 
  skinny = false, // whether to use the skinny enter dimensions
  xy_offset = [0, 0], // xy offset of top layer 
  fillet_radius_base = undef, // fillet radius base
  fillet_radius_top = 0, // fillet radius top
  n_layers = undef, // number of layers for the loft (higher = smoother but slower)
  $fn = 64 // Number of fragments for rounded corners (high = smoother)
) {

  assert(unit1 != undef, "unit1 is required");
  assert(height != undef, "height is required");
  assert(fillet_radius_base != undef, "fillet_radius is required");
  assert(n_layers != undef, "n_layers is required");

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

  fil_top = fillet_radius_top != 0 ? fillet_radius_top : fillet_radius_base;

  if (unit2 != undef) {
    // get the paths as points
    bottom_path = iso_enter_path(unit1, fillet_radius_base, skinny);
    top_path = move(xy_offset, iso_enter_path(unit2, fil_top, skinny));
    skin_path(bottom_path, top_path, height, n_layers);
  } else {
    // get the paths as points
    bottom_path = iso_enter_path(unit1, fillet_radius_base, skinny);
    top_path = move(xy_offset, iso_enter_path(unit1, fil_top, skinny));
    skin_path(bottom_path, top_path, height, n_layers);
  }
}

/*
Module to create the full iso enter keycap (with dishes and everything)
Parameters:
- height: height of the keycap (required)
- base_u: u(nit) value of the bottom layer (required)
- skinny_enter: whether to use the skinny enter dimensions (optional; default: false)
- top_difference: how much smaller the top of the keycap u is compared to the bottom (optional; default: 6mm)
- skew_top_x: skew the top of the keycap left(negative)/right(positive) on x axis from center (optional; default: 0)
- skew_top_y: skew the top of the keycap down(negative)/up(positive) on y axis from center (optional; default: 0)
- dish_type: "inv_pyramid", "cylinder", "sphere", anything else: flat top (optional; default: "cylinder")
- dish_tilt: how to rotate() the dish of the key (on the Y axis), ignored if "inv_pyramid" (optional; default: 4)
- dish_tilt_curve: if you want a more organic ("tentacle"!) shape set this to true (optional; default: false)
- dish_depth: distance between the top sides and the bottommost point in the dish (set to 0 for flat top) (optional; default: 1)
- dish_x: move the dish left/right (optional; default: 0)
- dish_y: move the dish forward/backward (optional; default: 0)
- dish_z: controls how deep into the top of the keycap the dish goes (e.g. -0.25) (optional; default: -0.75)
- dish_fn: if you want to increase or decrease the resolution of the shapes used to make the dish (Tip: Don't go <64 for "cylinder" dish types and don't go <128 for "sphere") (optional; default: $preview ? 28 : 256)
- corner_fn: number of fragments for rounded corners (high = smoother) (optional; default: $preview ? 16 : 64)
- polygon_layers: number of layers for the loft when creating the keycap shape (higher = smoother but slower) (optional; default: 5)
- corner_radius_base: radius of the outside corners of the keycap at the base (required)
- corner_radius_top: radius of the outside corners of the keycap at the top (optional; default: 0)
*/
module _poly_keycap_iso_enter(
  height = 9.0,
  base_u = 18,
  skinny_enter = false,
  top_difference = 6, // How much smaller the top of the keycap u is compared to the bottom
  skew_top_x = 0, // Skew the top of the keycap left(negative)/right(positive) on x axis from center
  skew_top_y = 0, // Skew the top of the keycap down(negative)/up(positive) on y axis from center
  dish_type = "cylinder",
  dish_tilt = -4,
  dish_tilt_curve = false,
  dish_depth = 1,
  dish_x = 0, // Move the dish left/right
  dish_y = 0, // Move the dish forward/backward
  dish_z = -0.75, // Controls how deep into the top of the keycap the dish goes
  dish_fn = 32,
  corner_fn = 64,
  polygon_layers = 5,
  corner_radius_base = 0.5,
  corner_radius_top = 0,
) {

  difference() {

    assert(top_difference < base_u, "top_difference must be less than or equal to base_u to prevent negative top_u");
    top_u = base_u - top_difference;
    center_top = [top_difference / 2, top_difference];
    topLayerOffset = [skew_top_x, skew_top_y] + center_top;

    iso_enter_solid(
      unit1=base_u,
      unit2=top_u,
      xy_offset=topLayerOffset,
      height=height,
      fillet_radius_base=corner_radius_base,
      fillet_radius_top=corner_radius_top,
      skinny=skinny_enter,
      n_layers=polygon_layers,
      $fn=corner_fn
    );

    // Do the dishes!

    // Calculate dish tilt parameters:
    layer_tilt_adjust = dish_tilt / polygon_layers;
    tilt_above_curved = dish_tilt_curve ? layer_tilt_adjust * polygon_layers : 0;
    tilt_above_straight = dish_tilt_curve ? 0 : layer_tilt_adjust * polygon_layers;

    // Calculate adjustment parameters:
    adjusted_base_u = base_u * (skinny_enter ? 1.25 : 1.5);
    reduction_factor = dish_tilt_curve ? 2.25 : 2.35; // This (reduction_factor and height_adjust) attempts to make up for the fact that when you rotate a rectangle the corner goes *up* (not perfect but damned close!):
    height_adjust = ( (abs(adjusted_base_u * sin(dish_tilt)) + abs(height * cos(dish_tilt))) - height) / polygon_layers / reduction_factor;
    z_adjust = height_adjust * (polygon_layers + 2);
    adjusted_dimension = (adjusted_base_u - top_difference);
    echo("red factor: ", reduction_factor, "height_adjust: ", height_adjust, " z_adjust: ", z_adjust, "adjusted_dimension: ", adjusted_dimension);

    // Dish position parameters:
    centroid_base = centroid(iso_enter_path(base_u, corner_radius_base, skinny_enter)); // Calculate the centroid to calculate where to put the sphere correctly (iso enter is not a simple rectangle)
    transl_x = dish_x + skew_top_x - (centroid_base[0] - adjusted_base_u / 2 + 0.25 * base_u) / 2; // If skinny w_up = 1.25u, if not 1.5u
    transl_y = dish_y + skew_top_y - (centroid_base[1] - base_u) / 2;

    // Finally calculate the dish based on type:
    if (dish_type == "inv_pyramid") {

      transl_z = height - dish_depth + dish_z - z_adjust - 0.1;
      // rotate([tilt_above_curved, 0, 0]) // rotation if enabled creates weird artifacts in the keycap
      //   rotate([tilt_above_straight, 0, 0])
      difference() {
        // Get the inverted pyramid and cut is the top by intersecting it with a cube
        bottom_path = iso_enter_path(base_u, corner_radius_base, skinny_enter);
        centroidBase = centroid(bottom_path);
        top_path = move(topLayerOffset, iso_enter_path(top_u + 1, corner_radius_top, skinny_enter));
        translate([-centroidBase[0], -centroidBase[1], 0]) {
          skin(
            [
              // Apex stays at original centroid (no offset!)
              move([0, 0, transl_z], path3d([for (p = top_path) centroidBase], 0)),
              // Top is offset
              move([dish_x + skew_top_x, dish_y + skew_top_y], path3d(top_path, height)),
            ],
            slices=polygon_layers
          );
        }
        translate([0, 0, height / 2 - dish_depth])
          cube([base_u * 2, adjusted_base_u * 2, height], center=true);
      }
    } //
    else if (dish_type == "cylinder") {
      chord_base_u = dish_depth > 0 ? (pow(adjusted_dimension, 2) - 4 * pow(dish_depth, 2)) / (8 * dish_depth) : 0;
      rad = (pow(adjusted_dimension, 2) + 4 * pow(dish_depth, 2)) / (8 * dish_depth);

      // Calculate cylinder z coordinate
      transl_z = chord_base_u + height + dish_z - z_adjust;

      rotate([tilt_above_curved, 0, 0])
        translate([transl_x, transl_y, transl_z])
          rotate([tilt_above_straight, 0, 0])
            rotate([90, 0, 0])
              cylinder(h=base_u * 3, r=rad, center=true, $fn=dish_fn * 2);
    } //
    else if (dish_type == "sphere") {
      rad = dish_depth > 0 ? (pow(adjusted_dimension, 2) + 4 * pow(dish_depth, 2)) / (8 * dish_depth) : 0;

      // Calculate sphere z coordinate
      transl_z = rad * 2 + height - dish_depth + dish_z - z_adjust - 0.5;

      rotate([tilt_above_curved, 0, 0])
        translate([transl_x, transl_y, transl_z])
          rotate([tilt_above_straight, 0, 0])
            sphere(r=rad * 2, $fn=dish_fn * 2);
    }
  }
}

// TODO: add documentation
module poly_keycap_iso_enter(
  height = 9.0,
  length = 18,
  wall_thickness = 1.25,
  top_difference = 6,
  skew_top_x = 0,
  skew_top_y = 0,
  dish_tilt = -4,
  dish_tilt_curve = false,
  dish_depth = 1,
  dish_x = 0,
  dish_y = 0,
  dish_z = -0.75,
  dish_thickness = 2, // TODO: keep/remove? understand how carved works on final keycap
  dish_fn = 32,
  corner_fn = 64,
  legend_list = [""],
  polygon_layers = 5,
  dish_type = "cylinder",
  corner_radius_base = 0.5,
  corner_radius_top = 0,
  visualize_legends = false,
  skinny_enter = false,
) {
  layer_tilt_adjust = dish_tilt / polygon_layers;

  module easy_iso_enter_shape(pol_lay = polygon_layers) {
    // A lightweight version of the iso enter
    _poly_keycap_iso_enter(
      height=height,
      base_u=length,
      top_difference=top_difference,
      dish_tilt=dish_tilt,
      dish_tilt_curve=dish_tilt_curve,
      skew_top_x=skew_top_x,
      skew_top_y=skew_top_y,
      dish_depth=dish_depth,
      dish_x=dish_x,
      dish_y=dish_y,
      dish_z=dish_z,
      dish_fn=dish_fn / 2,
      corner_fn=1,
      polygon_layers=pol_lay,
      dish_type=dish_type,
      corner_radius_base=0,
      corner_radius_top=0,
      skinny_enter=skinny_enter
    );
  }

  // TODO use dish thickness to add material under the dish where carving has been made?

  module legend_transformations(underset, trans2, rot2, trans, rot, l_scale, tilt_above_curved) {
    translate(underset)
      translate(trans2) rotate(rot2)
          translate(trans) rotate(rot)
              scale(l_scale)
                rotate([tilt_above_curved, 0, 0])
                  children();
  }
  difference() {
    //(i.e. shell operation)

    _poly_keycap_iso_enter(
      // Generate main shape
      height=height,
      base_u=length,
      top_difference=top_difference,
      dish_tilt=dish_tilt,
      dish_tilt_curve=dish_tilt_curve,
      skew_top_x=skew_top_x,
      skew_top_y=skew_top_y,
      dish_depth=dish_depth,
      dish_x=dish_x,
      dish_y=dish_y,
      dish_z=dish_z,
      dish_fn=dish_fn,
      corner_fn=corner_fn,
      polygon_layers=polygon_layers,
      dish_type=dish_type,
      corner_radius_base=corner_radius_base,
      corner_radius_top=corner_radius_top,
      skinny_enter=skinny_enter
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
          %legend_transformations(underset, trans2, rotation2, trans, rotation, l_scale, tilt_above_curved) {
            color([0.5, 0.5, 0.5, 0.75])
              draw_legend(legend, font_size, font, height);
          }
        } else {
          // NOTE: This translate([0,0,1]) call is just to fix preview rendering
          translate(underset) translate([0, 0, 1]) intersection() {
                legend_transformations(underset, trans2, rotation2, trans, rotation, l_scale, tilt_above_curved) {
                  draw_legend(legend, font_size, font, height);
                }
                easy_iso_enter_shape();
              }
        }
      }
    }

    // Interior cutout
    translate([0, 0, -wall_thickness])
      offset3d(r=-wall_thickness, size=2.5 * length) {
        // Generate interior shape that will be later subtracted from main shape
        easy_iso_enter_shape(polygon_layers / 2); // low layer, we need the general shape only
      }
  }
}

// // Example usage:
// {
//   // Width of a standard "key unit" (how much space a "key" takes up in total). Probably don't want to change this.
//   KEY_UNIT = 19.05; // Square that makes up the entire space of a key
//   // How much space (air) between keycaps
//   BETWEENSPACE = 0.8; // The Betweenspace:  The void between realms...  And keycaps (for an 18.25mm keycap)

//   // BASIC KEYCAP PARAMETERS
//   KEY_HEIGHT = 9; // The Z (NOTE: Dish values may reduce this a bit as they carve themselves out)
//   // NOTE: You *can* just set KEY_LENGTH/KEY_WIDTH to something simple e.g. 18
//   KEY_LENGTH = (KEY_UNIT * 1 - BETWEENSPACE); // The X (NOTE: Increase DISH_FN if you make this >1U!)
//   // NOTE: If using a profile make sure KEY_LENGTH matches the profile's KEY_WIDTH for 1U keycaps!
//   // NOTE: If you rotate a keycap to print on its side don't forget to add a built-in support via STEM_SIDE_SUPPORTS! [0,1,0,0] is what you want if you rotated to print on the right side.
//   KEY_TOP_DIFFERENCE = 5; // How much skinnier the key is at the top VS the bottom [x,y]
//   KEY_TOP_X = 0; // Move the keycap's top on the X axis (controls skew left/right)
//   KEY_TOP_Y = 0; // Move the keycap's top on the Y axis (controls skew forward/backward)
//   WALL_THICKNESS = 0.45 * 2.25; // Default: 0.45 extrusion width * 2.25 (nice and thick; feels/sounds good). NOTE: STEM_SIDES_WALL_THICKNESS gets added to this.

//   // DO THE DISHES!
//   DISH_X = 0; // Move the dish left/right
//   DISH_Y = 0; // Move the dish forward/backward
//   DISH_Z = 0; // Controls how deep into the top of the keycap the dish goes (e.g. -0.25)
//   DISH_TYPE = "cylinder"; // "inv_pyramid", "cylinder", "sphere" (aka "domed"), anything else: flat top
//   DISH_DEPTH = 1; // Distance between the top sides and the bottommost point in the dish (set to 0 for flat top)
//   // NOTE: When DISH_INVERT is true DISH_DEPTH becomes more like, "how far dish protrudes upwards"
//   DISH_THICKNESS = 1; // Amount of material that will be placed under the bottommost part of the dish (Note: only used if UNIFORM_WALL_THICKNESS is false)
//   // NOTE: If you make DISH_THICKNESS too small legends might not print properly--even with a tiny nozzle.  In other words, a thick keycap top makes for nice clean (3D printed) legends.
//   // NOTE: Also, if you're printing white keycaps with transparent legends you want a thick dish (1.2+) to darken the non-transparent parts of the keycap
//   DISH_TILT = 4; // How to rotate() the dish of the key (on the Y axis), ignored if "inv_pyramid"
//   DISH_TILT_CURVE = true; // If you want a more organic ("tentacle"!) shape set this to true

//   // TIP: If you're making a 1U keycap and want a truly rounded (spherical) top set DISH_INVERT_DIVISION_X to 1 
//   // NOTE: Don't forget to increase DISH_FN if you make a longer/wider keycap!
//   DISH_FN = $preview ? 28 : 256; // If you want to increase or decrease the resolution of the shapes used to make the dish (Tip: Don't go <64 for "cylinder" dish types and don't go <128 for "sphere")
//   // NOTE: DISH_FN does not apply if DISH_INVERT==true (because it would be too much; inverted dish doesn't need as much resolution)
//   DISH_CORNER_FN = $preview ? 16 : 64;
//   // COOL TRICK: Set DISH_CORNER_FN to 4 to get flattened/chamfered corners (low-poly look!)

//   // POLYGON/SHAPE MANIPULATION
//   POLYGON_LAYERS = 10; // Number of layers we're going to extrude (set to 1 to get a boring keycap)
//   CORNER_RADIUS = 1; // Radius of the outside corners of the keycap (the base of the keycap)
//   CORNER_RADIUS_CURVE = 3; // If you want the corner radius to get bigger as it goes up (WARNING: Set this too high and you'll end up with missing bits of your keycap! Check the height when messing with this)

//   // LEGENDS
//   LEGEND_LIST = [
//     make_legend(
//       symbol="A",
//       font="Overpass Nerd Font",
//       size=5.5,
//       trans=[-0.1, 0, 0],
//       rot=[0, 0, 0],
//       trans2=[0, 0, 0],
//       rot2=[0, 0, 0],
//       legend_scale=[1, 1, 1],
//       underset=[0, 0, 0]
//     ),

//     make_legend(
//       symbol="!",
//       font="Overpass Nerd Font",
//       size=4,
//       trans=[4.15, 3, 1],
//       rot=[0, 0, 0],
//       trans2=[0, 0, 0],
//       rot2=[0, 0, 0],
//       legend_scale=[1, 1, 1],
//       underset=[0, 0, 0]
//     ),
//   ];

//   // DEBUGGING FEATURES
//   VISUALIZE_LEGENDS = false; // Set to true to have the legends appear via %

//   // Render a basic 1U keycap.
//   poly_keycap_iso_enter(
//     height=KEY_HEIGHT,
//     length=KEY_LENGTH,
//     wall_thickness=WALL_THICKNESS,
//     top_difference=KEY_TOP_DIFFERENCE,
//     dish_tilt=DISH_TILT,
//     dish_tilt_curve=DISH_TILT_CURVE,
//     skew_top_x=KEY_TOP_X,
//     skew_top_y=KEY_TOP_Y,
//     dish_depth=DISH_DEPTH,
//     dish_x=DISH_X,
//     dish_y=DISH_Y,
//     dish_z=DISH_Z,
//     dish_thickness=DISH_THICKNESS,
//     dish_fn=DISH_FN,
//     corner_fn=DISH_CORNER_FN,
//     legend_list=LEGEND_LIST,
//     polygon_layers=POLYGON_LAYERS,
//     dish_type=DISH_TYPE,
//     corner_radius_base=CORNER_RADIUS,
//     corner_radius_top=CORNER_RADIUS_CURVE,
//     visualize_legends=VISUALIZE_LEGENDS,
//     skinny_enter=true
//   );
// }
