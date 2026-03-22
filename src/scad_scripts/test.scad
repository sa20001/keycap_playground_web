// Riskable's Keycap Playground -- Use this tool to try out all your cool keycap ideas.

/* NOTES
    * Want to understand how to use this file? See: https://youtu.be/WDlRZMvisA4
    * TIP: If preview is slow/laggy try setting VISUALIZE_LEGENDS=1
    * TIP: PRINT KEYCAPS ON THEIR SIDE!  They'll turn out nice and smooth right off the printer!  Use the KEY_ROTATION feature to take care of it BUT DON'T FORGET the STEM_SIDE_SUPPORTS feature to enable built-in supports for the stem(s).  BUILT-IN SUPPORTS MUST BE CUT OFF AFTER PRINTING.  Cut off the support where it meets the interior wall of the keycap (with flush cutters) and it should easily break away from the side that supports the stem.
    * TIP: If you're making changes but nothing's happening when you hit F5: Did you forget to change the KEY_PROFILE to "" (an empty string)?
    * The default rendering mode (["keycap", "stem"]) will include inset (non-multi-material) legends automatically.  Adding "legends" to RENDER is something you only want to do if you're making multi-material keycaps...
    * To make a multi-material print just render and export "keycap", "stem", and "legends" as separate .stl files.  To save time you can render ["keycap", "stem"] and then just ["legends"].
    * TIP: Want to make a keycap that works great (looks cool) with backlit/RGB LED keyboards?  Print the stem and legends in a transparent material (clear PETG is a very effective light pipe!).  You can also render the stem and legends as a single file: ["stem", "legends"] which will save time importing into your slicer later.  Alternatively, just make the dish kinda thick, use UNIFORM_WALL_THICKNESS, and print in white PETG (most white PETGs seem to be transparent enough for it to look pretty good!).
    * Have a lot of different legends/keycaps to render?  You can add all your legends to the ROW variable and then render ["row", "row_stems"] and ["row_legends"].
    * Having trouble lining up your legends?  Try setting VISUALIZE_LEGENDS=1!  It'll show you where they all are, their angles, etc.
    * The part of the stem that goes under the top (STEM_TOP_THICKNESS) is colored purple so you can easily see where the keycap ends and the stem begins.
    * Removable supports are colored GREEN (in preview mode).
    * TIP: To make a spacebar just modify KEY_LENGTH to something like:
           KEY_LENGTH = (KEY_UNIT*6.25-BETWEENSPACE);
       ...and set DISH_INVERT = true;
*/

// TODO: Fix stems on keycaps with steep dish angles.
// TODO: Make presets for things like, "spacebar6.25", "shift2.25", "tab1.5" etc
// TODO: Add support for adding a bevel/rounded edge to the top of keycaps.
// TODO: Finish whole-keyboard generation support.

use <keycaps.scad>
use <stems.scad>
use <legends.scad>
use <utils.scad>
use <profiles.scad>
use <iso_enter.scad>

// Rendering resolution (32 is usually good enough)
$fn = 32; // Mostly only applies to legends/fonts but increase as needed for greater resolution

// Pick what you want to render. For more advanced options edit the RENDER variable directly (don't use the customizer).
WHAT_TO_RENDER = "keycap+stem"; // [keycap, keycap+stem, legends]

RENDER =
  WHAT_TO_RENDER == "keycap" ? ["keycap"]
  : (
    WHAT_TO_RENDER == "keycap+stem" ? ["keycap", "stem"]
    : (
      WHAT_TO_RENDER == "legends" ? ["legends"] : []
    )
  );
// NOTE: I *hate* that OpenSCAD forces conditional assignment like that.  I can't stand the ternary operator!

//RENDER = ["keycap", "stem"];
// Supported values: keycap, stem, legends, row, row_stems, row_legends, custom
//RENDER = ["%keycap", "stem"]; // Can be useful for visualizing the stem inside the keycap
//RENDER = ["keycap"];
//RENDER = ["legends"];
//RENDER = ["legends", "stem"];
//RENDER = ["stem"];
//RENDER = ["keycap", "stem", "legends"]; // For generating multi-material keycaps (using colorscad.sh)
//RENDER = ["underset_mask"]; // A thin layer under the top of they keycap meant to be darkened for underset legends
// Want to render a whole row of keycaps/stems/legends at a time?  You can do that here:
//RENDER = ["row", "row_stems"]; // For making whole keyboards at a time (with whole-keyboard inlaid art!)
//RENDER = ["row"];
//RENDER = ["row_legends"];
//RENDER = ["row_stems"];
//RENDER = ["row_underset_masks"];

// Lets you see the legends as a transparent object but also GREATLY improves preview rendering speed.
VISUALIZE_LEGENDS = false; // Set to true to have the legends appear via %

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
POLYGON_EDGES = 4; // How many sides the keycap will have (normal keycap is 4). Try messing with this too!
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

LEGEND_LIST = [
  make_legend(
    symbol="A",
    font="Overpass Nerd Font",
    size=5.5,
    trans=[-0.1, 0, 0],
    rot=[0, 0, 0],
    trans2=[0, 0, 0],
    rot2=[0, 0, 0],
    legend_scale=[1, 1, 1],
    underset=[0, 0, 0]
  ),

  make_legend(
    symbol="!",
    font="Overpass Nerd Font",
    size=4,
    trans=[4.15, 3, 1],
    rot=[0, 0, 0],
    trans2=[0, 0, 0],
    rot2=[0, 0, 0],
    legend_scale=[1, 1, 1],
    underset=[0, 0, 0]
  ),
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

// YOU CAN IGNORE EVERYTHING BELOW THIS POINT (unless you're curious how it works)

// Generates a keycap using global variables but you can override the legends (for generating whole rows at a time)
module key_using_globals(legends) {
  _legends = legends ? legends : LEGENDS;
  poly_keycap(
    height=KEY_HEIGHT, length=KEY_LENGTH, width=KEY_WIDTH,
    wall_thickness=WALL_THICKNESS, top_difference=KEY_TOP_DIFFERENCE,
    dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
    stem_clips=STEM_SNAP_FIT, stem_walls_inset=STEM_WALLS_INSET,
    stem_walls_tolerance=STEM_WALLS_TOLERANCE,
    top_x=KEY_TOP_X, top_y=KEY_TOP_Y, dish_depth=DISH_DEPTH,
    dish_x=DISH_X, dish_y=DISH_Y, dish_z=DISH_Z,
    dish_thickness=DISH_THICKNESS, dish_fn=DISH_FN,
    dish_corner_fn=DISH_CORNER_FN,
    legends=_legends, legend_font_sizes=LEGEND_FONT_SIZES,
    legend_carved=LEGEND_CARVED,
    legend_fonts=LEGEND_FONTS, legend_trans=LEGEND_TRANS,
    legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
    legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
    legend_underset=LEGEND_UNDERSET,
    polygon_layers=POLYGON_LAYERS, polygon_layer_rotation=POLYGON_LAYER_ROTATION,
    polygon_edges=POLYGON_EDGES, polygon_curve=POLYGON_CURVE,
    dish_type=DISH_TYPE,
    dish_division_x=DISH_INVERT_DIVISION_X, dish_division_y=DISH_INVERT_DIVISION_Y,
    corner_radius=CORNER_RADIUS, corner_radius_curve=CORNER_RADIUS_CURVE,
    visualize_legends=VISUALIZE_LEGENDS, polygon_rotation=POLYGON_ROTATION,
    homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
    homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
    key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
    debug=DEBUG, uniform_wall_thickness=UNIFORM_WALL_THICKNESS
  );
}

// Generates a keycap using global variables without legends so we can do an intersection() that generates the legends as an independent object
module key_without_legends() {
  // NOTE: Removed a few arguments that won't impact this module's purpose (just to save space)
  poly_keycap(
    height=KEY_HEIGHT, length=KEY_LENGTH, width=KEY_WIDTH,
    wall_thickness=WALL_THICKNESS, top_difference=KEY_TOP_DIFFERENCE,
    dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
    stem_clips=STEM_SNAP_FIT, stem_walls_inset=STEM_WALLS_INSET,
    stem_walls_tolerance=STEM_WALLS_TOLERANCE,
    top_x=KEY_TOP_X, top_y=KEY_TOP_Y, dish_depth=DISH_DEPTH,
    dish_x=DISH_X, dish_y=DISH_Y, dish_z=DISH_Z,
    dish_thickness=DISH_THICKNESS, dish_fn=DISH_FN,
    dish_corner_fn=DISH_CORNER_FN,
    polygon_layers=POLYGON_LAYERS, polygon_layer_rotation=POLYGON_LAYER_ROTATION,
    polygon_edges=POLYGON_EDGES, polygon_curve=POLYGON_CURVE,
    dish_type=DISH_TYPE,
    dish_division_x=DISH_INVERT_DIVISION_X, dish_division_y=DISH_INVERT_DIVISION_Y,
    corner_radius=CORNER_RADIUS,
    corner_radius_curve=CORNER_RADIUS_CURVE,
    homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
    homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
    visualize_legends=VISUALIZE_LEGENDS, polygon_rotation=POLYGON_ROTATION,
    key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
    debug=DEBUG, uniform_wall_thickness=UNIFORM_WALL_THICKNESS
  );
}

// Renders a stem and stabilizers using global values
module stem_using_globals() {
  // TODO: Support more stem types
  if (STEM_TYPE == "box_cherry") {
    stem_box_cherry(
      key_height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
      key_length=KEY_LENGTH,
      key_width=KEY_WIDTH,
      dish_depth=DISH_DEPTH,
      dish_thickness=DISH_THICKNESS,
      top_difference=KEY_TOP_DIFFERENCE,
      depth=STEM_HEIGHT, dish_tilt=DISH_TILT,
      top_thickness=STEM_TOP_THICKNESS,
      wall_thickness=WALL_THICKNESS,
      wall_extra=STEM_SIDES_WALL_THICKNESS,
      wall_inset=STEM_WALLS_INSET,
      wall_tolerance=STEM_WALLS_TOLERANCE,
      top_x=KEY_TOP_X, top_y=KEY_TOP_Y,
      outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
      outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
      inside_tolerance=STEM_INSIDE_TOLERANCE,
      inset=STEM_INSET,
      flat_support=STEM_FLAT_SUPPORT,
      side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
      side_supports=STEM_SIDE_SUPPORTS,
      support_distance=STEM_SUPPORT_DISTANCE,
      locations=STEM_LOCATIONS,
      key_rotation=KEY_ROTATION,
      dish_invert=DISH_INVERT,
      dish_x=DISH_X,
      dish_y=DISH_Y,
      dish_z=DISH_Z,
      dish_fn=DISH_FN,
      dish_type=DISH_TYPE,
      dish_corner_fn=DISH_CORNER_FN,
      dish_tilt_curve=DISH_TILT_CURVE,
      dish_division_x=DISH_INVERT_DIVISION_X,
      dish_division_y=DISH_INVERT_DIVISION_Y,
      corner_radius=BOX_CHERRY_STEM_CORNER_RADIUS,
      key_corner_radius=CORNER_RADIUS,
      corner_radius_curve=CORNER_RADIUS_CURVE,
      polygon_layers=POLYGON_LAYERS,
      polygon_layer_rotation=POLYGON_LAYER_ROTATION,
      polygon_edges=POLYGON_EDGES,
      polygon_curve=POLYGON_CURVE,
      polygon_rotation=POLYGON_ROTATION,
      uniform_wall_thickness=UNIFORM_WALL_THICKNESS
    );
  } else if (STEM_TYPE == "round_cherry") {
    stem_round_cherry(
      key_height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
      key_length=KEY_LENGTH,
      key_width=KEY_WIDTH,
      dish_depth=DISH_DEPTH,
      dish_thickness=DISH_THICKNESS,
      top_difference=KEY_TOP_DIFFERENCE,
      depth=STEM_HEIGHT, dish_tilt=DISH_TILT,
      top_thickness=STEM_TOP_THICKNESS,
      key_corner_radius=CORNER_RADIUS,
      wall_thickness=WALL_THICKNESS,
      wall_extra=STEM_SIDES_WALL_THICKNESS,
      wall_inset=STEM_WALLS_INSET,
      wall_tolerance=STEM_WALLS_TOLERANCE,
      top_x=KEY_TOP_X, top_y=KEY_TOP_Y,
      outside_tolerance=STEM_OUTSIDE_TOLERANCE_X,
      inside_tolerance=STEM_INSIDE_TOLERANCE,
      inset=STEM_INSET,
      flat_support=STEM_FLAT_SUPPORT,
      side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
      side_supports=STEM_SIDE_SUPPORTS,
      support_distance=STEM_SUPPORT_DISTANCE,
      locations=STEM_LOCATIONS,
      key_rotation=KEY_ROTATION,
      dish_invert=DISH_INVERT,
      dish_x=DISH_X,
      dish_y=DISH_Y,
      dish_z=DISH_Z,
      dish_fn=DISH_FN,
      dish_type=DISH_TYPE,
      dish_corner_fn=DISH_CORNER_FN,
      dish_tilt_curve=DISH_TILT_CURVE,
      corner_radius=CORNER_RADIUS,
      corner_radius_curve=CORNER_RADIUS_CURVE,
      polygon_layers=POLYGON_LAYERS,
      polygon_layer_rotation=POLYGON_LAYER_ROTATION,
      polygon_edges=POLYGON_EDGES,
      polygon_curve=POLYGON_CURVE,
      polygon_rotation=POLYGON_ROTATION,
      uniform_wall_thickness=UNIFORM_WALL_THICKNESS
    );
  } else if (STEM_TYPE == "alps") {
    stem_alps(
      key_height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
      key_length=KEY_LENGTH,
      key_width=KEY_WIDTH,
      dish_depth=DISH_DEPTH,
      dish_thickness=DISH_THICKNESS,
      top_difference=KEY_TOP_DIFFERENCE,
      depth=STEM_HEIGHT, dish_tilt=DISH_TILT,
      top_thickness=STEM_TOP_THICKNESS,
      wall_thickness=WALL_THICKNESS,
      wall_extra=STEM_SIDES_WALL_THICKNESS,
      wall_inset=STEM_WALLS_INSET,
      wall_tolerance=STEM_WALLS_TOLERANCE,
      top_x=KEY_TOP_X, top_y=KEY_TOP_Y,
      outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
      outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
      inside_tolerance=STEM_INSIDE_TOLERANCE,
      inset=STEM_INSET,
      flat_support=STEM_FLAT_SUPPORT,
      side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
      side_supports=STEM_SIDE_SUPPORTS,
      support_distance=STEM_SUPPORT_DISTANCE,
      locations=STEM_LOCATIONS,
      key_rotation=KEY_ROTATION,
      dish_invert=DISH_INVERT,
      dish_x=DISH_X,
      dish_y=DISH_Y,
      dish_z=DISH_Z,
      dish_fn=DISH_FN,
      dish_type=DISH_TYPE,
      dish_corner_fn=DISH_CORNER_FN,
      dish_tilt_curve=DISH_TILT_CURVE,
      corner_radius=ALPS_STEM_CORNER_RADIUS,
      key_corner_radius=CORNER_RADIUS,
      corner_radius_curve=CORNER_RADIUS_CURVE,
      polygon_layers=POLYGON_LAYERS,
      polygon_layer_rotation=POLYGON_LAYER_ROTATION,
      polygon_edges=POLYGON_EDGES,
      polygon_curve=POLYGON_CURVE,
      polygon_rotation=POLYGON_ROTATION,
      hollow=STEM_HOLLOW,
      uniform_wall_thickness=UNIFORM_WALL_THICKNESS
    );
  }
}

module stem_top_using_globals() {
  stem_top(
    KEY_HEIGHT + KEY_HEIGHT_EXTRA,
    KEY_LENGTH,
    KEY_WIDTH,
    DISH_DEPTH,
    DISH_THICKNESS,
    KEY_TOP_DIFFERENCE,
    dish_tilt=DISH_TILT,
    top_thickness=STEM_TOP_THICKNESS,
    key_corner_radius=CORNER_RADIUS,
    wall_thickness=WALL_THICKNESS,
    wall_extra=STEM_SIDES_WALL_THICKNESS,
    wall_inset=STEM_WALLS_INSET,
    wall_tolerance=STEM_WALLS_TOLERANCE,
    top_x=KEY_TOP_X, top_y=KEY_TOP_Y,
    key_rotation=KEY_ROTATION,
    dish_invert=DISH_INVERT,
    dish_type=DISH_TYPE,
    dish_x=DISH_X,
    dish_y=DISH_Y,
    dish_z=DISH_Z,
    dish_fn=DISH_FN,
    dish_type=DISH_TYPE,
    dish_corner_fn=DISH_CORNER_FN,
    dish_tilt_curve=DISH_TILT_CURVE,
    corner_radius_curve=CORNER_RADIUS_CURVE,
    polygon_layers=POLYGON_LAYERS,
    polygon_layer_rotation=POLYGON_LAYER_ROTATION,
    polygon_edges=POLYGON_EDGES,
    polygon_curve=POLYGON_CURVE,
    polygon_rotation=POLYGON_ROTATION,
    uniform_wall_thickness=UNIFORM_WALL_THICKNESS
  );
}

// This takes care of rendering whatever's configured via RENDER:
module handle_render(what, legends) {

  module keycapRenderType(renderType) {
    if (renderType == "keycap") {
      color("white") {
        render() {
          children();
        }
      }
    } else {
      color("red", alpha=0.1)
        %render() {
          children();
        }
    }
  }

  if (what == "legends") {
    // NOTE: just_legends() uses children() which is why there's no semicolon after it
    color("#505050")
      render() if (KEY_PROFILE == "dsa") {
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          legends=legends, polygon_layers=POLYGON_LAYERS,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        ) {
          DSA_keycap(
            row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
            height_extra=KEY_HEIGHT_EXTRA,
            wall_thickness=WALL_THICKNESS,
            polygon_layers=POLYGON_LAYERS,
            dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
            dish_corner_fn=DISH_CORNER_FN,
            visualize_legends=VISUALIZE_LEGENDS,
            homing_dot_length=HOMING_DOT_LENGTH,
            homing_dot_width=HOMING_DOT_WIDTH,
            homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
            homing_dot_z=HOMING_DOT_Z,
            key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
            uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
          );
        }
      } else if (KEY_PROFILE == "dcs") {
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=false,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        ) {
          DCS_keycap(
            row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
            height_extra=KEY_HEIGHT_EXTRA,
            wall_thickness=WALL_THICKNESS,
            polygon_layers=POLYGON_LAYERS,
            dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
            dish_corner_fn=DISH_CORNER_FN,
            visualize_legends=VISUALIZE_LEGENDS,
            homing_dot_length=HOMING_DOT_LENGTH,
            homing_dot_width=HOMING_DOT_WIDTH,
            homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
            homing_dot_z=HOMING_DOT_Z,
            key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
            uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
          );
        }
      } else if (KEY_PROFILE == "kat") {
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=false,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        ) {
          KAT_keycap(
            row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
            height_extra=KEY_HEIGHT_EXTRA,
            wall_thickness=WALL_THICKNESS,
            polygon_layers=POLYGON_LAYERS,
            dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
            dish_corner_fn=DISH_CORNER_FN,
            visualize_legends=VISUALIZE_LEGENDS,
            homing_dot_length=HOMING_DOT_LENGTH,
            homing_dot_width=HOMING_DOT_WIDTH,
            homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
            homing_dot_z=HOMING_DOT_Z,
            key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
            uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
          );
        }
      } else if (KEY_PROFILE == "kam") {
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=false,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        ) {
          KAM_keycap(
            row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
            height_extra=KEY_HEIGHT_EXTRA,
            wall_thickness=WALL_THICKNESS,
            polygon_layers=POLYGON_LAYERS,
            dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
            dish_corner_fn=DISH_CORNER_FN,
            visualize_legends=VISUALIZE_LEGENDS,
            homing_dot_length=HOMING_DOT_LENGTH,
            homing_dot_width=HOMING_DOT_WIDTH,
            homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
            homing_dot_z=HOMING_DOT_Z,
            key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
            uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
          );
        }
      } else if (KEY_PROFILE == "riskeycap") {
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=false,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        ) {
          riskeycap(
            row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
            height_extra=KEY_HEIGHT_EXTRA,
            wall_thickness=WALL_THICKNESS,
            polygon_layers=POLYGON_LAYERS,
            dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
            dish_corner_fn=DISH_CORNER_FN,
            visualize_legends=VISUALIZE_LEGENDS,
            homing_dot_length=HOMING_DOT_LENGTH,
            homing_dot_width=HOMING_DOT_WIDTH,
            homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
            homing_dot_z=HOMING_DOT_Z,
            key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
            uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
          );
        }
      } else if (KEY_PROFILE == "gem") {
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=false,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        ) {
          GEM_keycap(
            row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
            height_extra=KEY_HEIGHT_EXTRA,
            wall_thickness=WALL_THICKNESS,
            polygon_layers=POLYGON_LAYERS,
            dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
            dish_corner_fn=DISH_CORNER_FN,
            visualize_legends=VISUALIZE_LEGENDS,
            homing_dot_length=HOMING_DOT_LENGTH,
            homing_dot_width=HOMING_DOT_WIDTH,
            homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
            homing_dot_z=HOMING_DOT_Z,
            key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
            uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
          );
        }
      } else if (KEY_PROFILE == "xda") {
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=false,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        ) {
          XDA_keycap(
            row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
            height_extra=KEY_HEIGHT_EXTRA,
            wall_thickness=WALL_THICKNESS,
            polygon_layers=POLYGON_LAYERS,
            dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
            dish_corner_fn=DISH_CORNER_FN,
            visualize_legends=VISUALIZE_LEGENDS,
            homing_dot_length=HOMING_DOT_LENGTH,
            homing_dot_width=HOMING_DOT_WIDTH,
            homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
            homing_dot_z=HOMING_DOT_Z,
            key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
            uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
          );
        }
      } else {
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        ) {
          key_without_legends();
        }
      }
  } else if (what == "underset_mask") {
    if (KEY_PROFILE == "dsa") {
      difference() {
        DSA_stem(
          stem_type="stem_top",
          wall_thickness=WALL_THICKNESS,
          wall_extra=STEM_SIDES_WALL_THICKNESS,
          wall_inset=STEM_WALLS_INSET,
          wall_tolerance=STEM_WALLS_TOLERANCE,
          key_length=KEY_LENGTH,
          key_width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA,
          dish_depth=DISH_DEPTH,
          inset=STEM_INSET,
          depth=STEM_HEIGHT,
          dish_fn=DISH_FN,
          dish_corner_fn=DISH_CORNER_FN,
          dish_thickness=DISH_THICKNESS,
          dish_invert=DISH_INVERT,
          flat_support=STEM_FLAT_SUPPORT,
          support_distance=STEM_SUPPORT_DISTANCE,
          side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
          side_supports=STEM_SIDE_SUPPORTS,
          outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
          outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
          inside_tolerance=STEM_INSIDE_TOLERANCE,
          locations=STEM_LOCATIONS,
          key_rotation=KEY_ROTATION,
          hollow=STEM_HOLLOW,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS
        );
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        );
      }
    } else if (KEY_PROFILE == "dcs") {
      difference() {
        DCS_stem(
          row=KEY_ROW,
          stem_type="stem_top",
          wall_thickness=WALL_THICKNESS,
          wall_extra=STEM_SIDES_WALL_THICKNESS,
          wall_inset=STEM_WALLS_INSET,
          wall_tolerance=STEM_WALLS_TOLERANCE,
          key_length=KEY_LENGTH,
          key_width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA,
          dish_depth=DISH_DEPTH,
          inset=0, // Not enough room for insets on DCS
          depth=STEM_HEIGHT,
          dish_thickness=DISH_THICKNESS,
          dish_invert=DISH_INVERT,
          dish_fn=DISH_FN,
          dish_corner_fn=DISH_CORNER_FN,
          flat_support=STEM_FLAT_SUPPORT,
          support_distance=STEM_SUPPORT_DISTANCE,
          side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
          side_supports=STEM_SIDE_SUPPORTS,
          outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
          outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
          inside_tolerance=STEM_INSIDE_TOLERANCE,
          locations=STEM_LOCATIONS,
          key_rotation=KEY_ROTATION,
          hollow=STEM_HOLLOW,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS
        );
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        );
      }
    } else if (KEY_PROFILE == "dss") {
      difference() {
        DSS_stem(
          row=KEY_ROW,
          stem_type="stem_top",
          wall_thickness=WALL_THICKNESS,
          wall_extra=STEM_SIDES_WALL_THICKNESS,
          wall_inset=STEM_WALLS_INSET,
          wall_tolerance=STEM_WALLS_TOLERANCE,
          key_length=KEY_LENGTH,
          key_width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA,
          dish_depth=DISH_DEPTH,
          inset=0, // Not enough room for insets on DCS
          depth=STEM_HEIGHT,
          dish_thickness=DISH_THICKNESS,
          dish_invert=DISH_INVERT,
          dish_fn=DISH_FN,
          dish_corner_fn=DISH_CORNER_FN,
          flat_support=STEM_FLAT_SUPPORT,
          support_distance=STEM_SUPPORT_DISTANCE,
          side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
          side_supports=STEM_SIDE_SUPPORTS,
          outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
          outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
          inside_tolerance=STEM_INSIDE_TOLERANCE,
          locations=STEM_LOCATIONS,
          key_rotation=KEY_ROTATION,
          hollow=STEM_HOLLOW,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS
        );
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        );
      }
    } else if (KEY_PROFILE == "kat") {
      difference() {
        KAT_stem(
          row=KEY_ROW,
          stem_type="stem_top",
          wall_thickness=WALL_THICKNESS,
          wall_extra=STEM_SIDES_WALL_THICKNESS,
          wall_inset=STEM_WALLS_INSET,
          wall_tolerance=STEM_WALLS_TOLERANCE,
          key_length=KEY_LENGTH,
          key_width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA,
          dish_depth=DISH_DEPTH,
          inset=STEM_INSET,
          depth=STEM_HEIGHT,
          dish_thickness=DISH_THICKNESS,
          dish_invert=DISH_INVERT,
          dish_fn=DISH_FN,
          dish_corner_fn=DISH_CORNER_FN,
          flat_support=STEM_FLAT_SUPPORT,
          support_distance=STEM_SUPPORT_DISTANCE,
          side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
          side_supports=STEM_SIDE_SUPPORTS,
          outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
          outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
          inside_tolerance=STEM_INSIDE_TOLERANCE,
          locations=STEM_LOCATIONS,
          key_rotation=KEY_ROTATION,
          hollow=STEM_HOLLOW,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS
        );
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        );
      }
    } else if (KEY_PROFILE == "kam") {
      difference() {
        KAM_stem(
          stem_type="stem_top",
          wall_thickness=WALL_THICKNESS,
          wall_extra=STEM_SIDES_WALL_THICKNESS,
          wall_inset=STEM_WALLS_INSET,
          wall_tolerance=STEM_WALLS_TOLERANCE,
          key_length=KEY_LENGTH,
          key_width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA,
          inset=STEM_INSET,
          depth=STEM_HEIGHT,
          dish_thickness=DISH_THICKNESS,
          dish_invert=DISH_INVERT,
          dish_fn=DISH_FN,
          dish_corner_fn=DISH_CORNER_FN,
          flat_support=STEM_FLAT_SUPPORT,
          support_distance=STEM_SUPPORT_DISTANCE,
          side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
          side_supports=STEM_SIDE_SUPPORTS,
          outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
          outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
          inside_tolerance=STEM_INSIDE_TOLERANCE,
          locations=STEM_LOCATIONS,
          key_rotation=KEY_ROTATION,
          hollow=STEM_HOLLOW,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS
        );
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        );
      }
    } else if (KEY_PROFILE == "riskeycap") {
      difference() {
        riskeystem(
          stem_type="stem_top",
          wall_thickness=WALL_THICKNESS,
          wall_extra=STEM_SIDES_WALL_THICKNESS,
          wall_inset=STEM_WALLS_INSET,
          wall_tolerance=STEM_WALLS_TOLERANCE,
          key_length=KEY_LENGTH,
          key_width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA,
          dish_depth=DISH_DEPTH,
          inset=STEM_INSET,
          depth=STEM_HEIGHT,
          dish_thickness=DISH_THICKNESS,
          dish_invert=DISH_INVERT,
          dish_fn=DISH_FN,
          dish_corner_fn=DISH_CORNER_FN,
          flat_support=STEM_FLAT_SUPPORT,
          support_distance=STEM_SUPPORT_DISTANCE,
          side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
          side_supports=STEM_SIDE_SUPPORTS,
          outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
          outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
          inside_tolerance=STEM_INSIDE_TOLERANCE,
          locations=STEM_LOCATIONS,
          key_rotation=KEY_ROTATION,
          hollow=STEM_HOLLOW,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS
        );
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        );
      }
    } else if (KEY_PROFILE == "gem") {
      difference() {
        GEM_stem(
          stem_type="stem_top",
          wall_thickness=WALL_THICKNESS,
          wall_extra=STEM_SIDES_WALL_THICKNESS,
          wall_inset=STEM_WALLS_INSET,
          wall_tolerance=STEM_WALLS_TOLERANCE,
          key_length=KEY_LENGTH,
          key_width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA,
          dish_depth=DISH_DEPTH,
          inset=STEM_INSET,
          depth=STEM_HEIGHT,
          dish_thickness=DISH_THICKNESS,
          dish_invert=DISH_INVERT,
          dish_fn=DISH_FN,
          dish_corner_fn=DISH_CORNER_FN,
          flat_support=STEM_FLAT_SUPPORT,
          support_distance=STEM_SUPPORT_DISTANCE,
          side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
          side_supports=STEM_SIDE_SUPPORTS,
          outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
          outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
          inside_tolerance=STEM_INSIDE_TOLERANCE,
          locations=STEM_LOCATIONS,
          key_rotation=KEY_ROTATION,
          hollow=STEM_HOLLOW,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS
        );
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        );
      }
    } else if (KEY_PROFILE == "xda") {
      difference() {
        XDA_stem(
          stem_type="stem_top",
          wall_thickness=WALL_THICKNESS,
          wall_extra=STEM_SIDES_WALL_THICKNESS,
          wall_inset=STEM_WALLS_INSET,
          wall_tolerance=STEM_WALLS_TOLERANCE,
          key_length=KEY_LENGTH,
          key_width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA,
          dish_depth=DISH_DEPTH,
          inset=STEM_INSET,
          depth=STEM_HEIGHT,
          dish_thickness=DISH_THICKNESS,
          dish_invert=DISH_INVERT,
          dish_fn=DISH_FN,
          dish_corner_fn=DISH_CORNER_FN,
          flat_support=STEM_FLAT_SUPPORT,
          support_distance=STEM_SUPPORT_DISTANCE,
          side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
          side_supports=STEM_SIDE_SUPPORTS,
          outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
          outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
          inside_tolerance=STEM_INSIDE_TOLERANCE,
          locations=STEM_LOCATIONS,
          key_rotation=KEY_ROTATION,
          hollow=STEM_HOLLOW,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS
        );
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        );
      }
    } else {
      difference() {
        stem_top_using_globals();
        just_legends(
          height=KEY_HEIGHT + KEY_HEIGHT_EXTRA,
          dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
          polygon_layers=POLYGON_LAYERS, legends=legends,
          legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION
        );
      }
    }
  } else if (what == "keycap" || what == "%keycap") {

    keycapRenderType(renderType=what) {
      if (KEY_PROFILE == "dsa") {
        gen_DSA_keycap();
      } else if (KEY_PROFILE == "dcs") {
        DCS_keycap(
          row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA, wall_thickness=WALL_THICKNESS,
          stem_clips=STEM_SNAP_FIT, stem_walls_inset=STEM_WALLS_INSET,
          stem_walls_tolerance=STEM_WALLS_TOLERANCE,
          legends=legends, legend_font_sizes=LEGEND_FONT_SIZES,
          legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE, legend_carved=LEGEND_CARVED,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          corner_radius=CORNER_RADIUS, polygon_layers=POLYGON_LAYERS,
          dish_fn=DISH_FN, dish_corner_fn=DISH_CORNER_FN,
          dish_thickness=DISH_THICKNESS,
          visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
          homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
          homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
          homing_dot_z=HOMING_DOT_Z,
          key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
        );
      } else if (KEY_PROFILE == "dss") {
        DSS_keycap(
          row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA, wall_thickness=WALL_THICKNESS,
          stem_clips=STEM_SNAP_FIT, stem_walls_inset=STEM_WALLS_INSET,
          stem_walls_tolerance=STEM_WALLS_TOLERANCE,
          legends=legends, legend_font_sizes=LEGEND_FONT_SIZES,
          legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE, legend_carved=LEGEND_CARVED,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          corner_radius=CORNER_RADIUS, polygon_layers=POLYGON_LAYERS,
          dish_fn=DISH_FN, dish_corner_fn=DISH_CORNER_FN,
          dish_thickness=DISH_THICKNESS,
          visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
          homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
          homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
          homing_dot_z=HOMING_DOT_Z,
          key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
        );
      } else if (KEY_PROFILE == "kat") {
        KAT_keycap(
          row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA, wall_thickness=WALL_THICKNESS,
          stem_clips=STEM_SNAP_FIT, stem_walls_inset=STEM_WALLS_INSET,
          stem_walls_tolerance=STEM_WALLS_TOLERANCE,
          legends=legends, legend_font_sizes=LEGEND_FONT_SIZES,
          legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE, legend_carved=LEGEND_CARVED,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          polygon_layers=POLYGON_LAYERS,
          dish_fn=DISH_FN, dish_corner_fn=DISH_CORNER_FN,
          dish_thickness=DISH_THICKNESS,
          visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
          homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
          homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
          homing_dot_z=HOMING_DOT_Z,
          key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
        );
      } else if (KEY_PROFILE == "kam") {
        KAM_keycap(
          row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA, wall_thickness=WALL_THICKNESS,
          stem_clips=STEM_SNAP_FIT, stem_walls_inset=STEM_WALLS_INSET,
          stem_walls_tolerance=STEM_WALLS_TOLERANCE,
          legends=legends, legend_font_sizes=LEGEND_FONT_SIZES,
          legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE, legend_carved=LEGEND_CARVED,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          polygon_layers=POLYGON_LAYERS,
          dish_fn=DISH_FN, dish_corner_fn=DISH_CORNER_FN,
          dish_thickness=DISH_THICKNESS,
          visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
          homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
          homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
          homing_dot_z=HOMING_DOT_Z,
          key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
        );
      } else if (KEY_PROFILE == "riskeycap") {
        riskeycap(
          row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA, wall_thickness=WALL_THICKNESS,
          stem_clips=STEM_SNAP_FIT, stem_walls_inset=STEM_WALLS_INSET,
          stem_walls_tolerance=STEM_WALLS_TOLERANCE,
          legends=legends, legend_font_sizes=LEGEND_FONT_SIZES,
          legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE, legend_carved=LEGEND_CARVED,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          polygon_layers=POLYGON_LAYERS,
          dish_fn=DISH_FN, dish_corner_fn=DISH_CORNER_FN,
          dish_thickness=DISH_THICKNESS,
          visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
          homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
          homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
          homing_dot_z=HOMING_DOT_Z,
          key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
        );
      } else if (KEY_PROFILE == "gem") {
        GEM_keycap(
          row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA, wall_thickness=WALL_THICKNESS,
          stem_clips=STEM_SNAP_FIT, stem_walls_inset=STEM_WALLS_INSET,
          stem_walls_tolerance=STEM_WALLS_TOLERANCE,
          legends=legends, legend_font_sizes=LEGEND_FONT_SIZES,
          legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE, legend_carved=LEGEND_CARVED,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          polygon_layers=POLYGON_LAYERS,
          dish_fn=DISH_FN, dish_corner_fn=DISH_CORNER_FN,
          dish_thickness=DISH_THICKNESS,
          visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
          homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
          homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
          homing_dot_z=HOMING_DOT_Z,
          key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
        );
      } else if (KEY_PROFILE == "xda") {
        XDA_keycap(
          row=KEY_ROW, length=KEY_LENGTH, width=KEY_WIDTH,
          height_extra=KEY_HEIGHT_EXTRA, wall_thickness=WALL_THICKNESS,
          stem_clips=STEM_SNAP_FIT, stem_walls_inset=STEM_WALLS_INSET,
          stem_walls_tolerance=STEM_WALLS_TOLERANCE,
          legends=legends, legend_font_sizes=LEGEND_FONT_SIZES,
          legend_fonts=LEGEND_FONTS,
          legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2,
          legend_scale=LEGEND_SCALE, legend_carved=LEGEND_CARVED,
          legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
          polygon_layers=POLYGON_LAYERS,
          dish_fn=DISH_FN, dish_corner_fn=DISH_CORNER_FN,
          dish_thickness=DISH_THICKNESS,
          visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
          homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
          homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y,
          homing_dot_z=HOMING_DOT_Z,
          key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT,
          uniform_wall_thickness=UNIFORM_WALL_THICKNESS, debug=DEBUG
        );
      } else {
        // If no built-in profile is selected
        key_using_globals(legends=legends);
      }
    }
  } else if (what == "stem") {
    color("white") if (KEY_PROFILE == "dsa") {
      DSA_stem(
        stem_type=STEM_TYPE,
        wall_thickness=WALL_THICKNESS,
        wall_extra=STEM_SIDES_WALL_THICKNESS,
        wall_inset=STEM_WALLS_INSET,
        wall_tolerance=STEM_WALLS_TOLERANCE,
        key_length=KEY_LENGTH,
        key_width=KEY_WIDTH,
        height_extra=KEY_HEIGHT_EXTRA,
        inset=STEM_INSET,
        depth=STEM_HEIGHT,
        dish_thickness=DISH_THICKNESS,
        dish_invert=DISH_INVERT,
        dish_fn=DISH_FN,
        dish_corner_fn=DISH_CORNER_FN,
        corner_radius=STEM_CORNER_RADIUS, // Of the stem; not the keycap
        flat_support=STEM_FLAT_SUPPORT,
        support_distance=STEM_SUPPORT_DISTANCE,
        side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
        side_supports=STEM_SIDE_SUPPORTS,
        outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
        outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
        inside_tolerance=STEM_INSIDE_TOLERANCE,
        locations=STEM_LOCATIONS,
        key_rotation=KEY_ROTATION,
        hollow=STEM_HOLLOW,
        uniform_wall_thickness=UNIFORM_WALL_THICKNESS
      );
    } else if (KEY_PROFILE == "dcs") {
      DCS_stem(
        row=KEY_ROW,
        stem_type=STEM_TYPE,
        key_length=KEY_LENGTH,
        key_width=KEY_WIDTH,
        height_extra=KEY_HEIGHT_EXTRA,
        wall_thickness=WALL_THICKNESS,
        wall_extra=STEM_SIDES_WALL_THICKNESS,
        wall_inset=STEM_WALLS_INSET,
        wall_tolerance=STEM_WALLS_TOLERANCE,
        inset=0, // Not enough room for inset with DCS
        depth=STEM_HEIGHT,
        dish_thickness=DISH_THICKNESS,
        dish_invert=DISH_INVERT,
        dish_fn=DISH_FN,
        dish_corner_fn=DISH_CORNER_FN,
        corner_radius=STEM_CORNER_RADIUS, // Of the stem; not the keycap
        flat_support=STEM_FLAT_SUPPORT,
        support_distance=STEM_SUPPORT_DISTANCE,
        side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
        side_supports=STEM_SIDE_SUPPORTS,
        outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
        outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
        inside_tolerance=STEM_INSIDE_TOLERANCE,
        locations=STEM_LOCATIONS,
        key_rotation=KEY_ROTATION,
        hollow=STEM_HOLLOW,
        uniform_wall_thickness=UNIFORM_WALL_THICKNESS
      );
    } else if (KEY_PROFILE == "dss") {
      DSS_stem(
        row=KEY_ROW,
        stem_type=STEM_TYPE,
        key_length=KEY_LENGTH,
        key_width=KEY_WIDTH,
        height_extra=KEY_HEIGHT_EXTRA,
        wall_thickness=WALL_THICKNESS,
        wall_extra=STEM_SIDES_WALL_THICKNESS,
        wall_inset=STEM_WALLS_INSET,
        wall_tolerance=STEM_WALLS_TOLERANCE,
        inset=STEM_INSET,
        depth=STEM_HEIGHT,
        dish_thickness=DISH_THICKNESS,
        dish_invert=DISH_INVERT,
        dish_fn=DISH_FN,
        dish_corner_fn=DISH_CORNER_FN,
        corner_radius=STEM_CORNER_RADIUS, // Of the stem; not the keycap
        flat_support=STEM_FLAT_SUPPORT,
        support_distance=STEM_SUPPORT_DISTANCE,
        side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
        side_supports=STEM_SIDE_SUPPORTS,
        outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
        outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
        inside_tolerance=STEM_INSIDE_TOLERANCE,
        locations=STEM_LOCATIONS,
        key_rotation=KEY_ROTATION,
        hollow=STEM_HOLLOW,
        uniform_wall_thickness=UNIFORM_WALL_THICKNESS
      );
    } else if (KEY_PROFILE == "kat") {
      KAT_stem(
        row=KEY_ROW,
        stem_type=STEM_TYPE,
        key_length=KEY_LENGTH,
        key_width=KEY_WIDTH,
        height_extra=KEY_HEIGHT_EXTRA,
        wall_thickness=WALL_THICKNESS,
        wall_extra=STEM_SIDES_WALL_THICKNESS,
        wall_inset=STEM_WALLS_INSET,
        wall_tolerance=STEM_WALLS_TOLERANCE,
        inset=STEM_INSET,
        depth=STEM_HEIGHT,
        dish_thickness=DISH_THICKNESS,
        dish_invert=DISH_INVERT,
        dish_fn=DISH_FN,
        dish_corner_fn=DISH_CORNER_FN,
        corner_radius=STEM_CORNER_RADIUS, // Of the stem; not the keycap
        flat_support=STEM_FLAT_SUPPORT,
        support_distance=STEM_SUPPORT_DISTANCE,
        side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
        side_supports=STEM_SIDE_SUPPORTS,
        outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
        outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
        inside_tolerance=STEM_INSIDE_TOLERANCE,
        locations=STEM_LOCATIONS,
        key_rotation=KEY_ROTATION,
        hollow=STEM_HOLLOW,
        uniform_wall_thickness=UNIFORM_WALL_THICKNESS
      );
    } else if (KEY_PROFILE == "kam") {
      KAM_stem(
        stem_type=STEM_TYPE,
        wall_thickness=WALL_THICKNESS,
        wall_extra=STEM_SIDES_WALL_THICKNESS,
        wall_inset=STEM_WALLS_INSET,
        wall_tolerance=STEM_WALLS_TOLERANCE,
        key_length=KEY_LENGTH,
        key_width=KEY_WIDTH,
        height_extra=KEY_HEIGHT_EXTRA,
        inset=STEM_INSET,
        depth=STEM_HEIGHT,
        dish_thickness=DISH_THICKNESS,
        dish_invert=DISH_INVERT,
        dish_fn=DISH_FN,
        dish_corner_fn=DISH_CORNER_FN,
        corner_radius=STEM_CORNER_RADIUS, // Of the stem; not the keycap
        flat_support=STEM_FLAT_SUPPORT,
        support_distance=STEM_SUPPORT_DISTANCE,
        side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
        side_supports=STEM_SIDE_SUPPORTS,
        outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
        outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
        inside_tolerance=STEM_INSIDE_TOLERANCE,
        locations=STEM_LOCATIONS,
        key_rotation=KEY_ROTATION,
        hollow=STEM_HOLLOW,
        uniform_wall_thickness=UNIFORM_WALL_THICKNESS
      );
    } else if (KEY_PROFILE == "riskeycap") {
      riskeystem(
        stem_type=STEM_TYPE,
        wall_thickness=WALL_THICKNESS,
        wall_extra=STEM_SIDES_WALL_THICKNESS,
        wall_inset=STEM_WALLS_INSET,
        wall_tolerance=STEM_WALLS_TOLERANCE,
        key_length=KEY_LENGTH,
        key_width=KEY_WIDTH,
        height_extra=KEY_HEIGHT_EXTRA,
        inset=STEM_INSET,
        depth=STEM_HEIGHT,
        dish_thickness=DISH_THICKNESS,
        dish_invert=DISH_INVERT,
        dish_fn=DISH_FN,
        dish_corner_fn=DISH_CORNER_FN,
        corner_radius=STEM_CORNER_RADIUS, // Of the stem; not the keycap
        flat_support=STEM_FLAT_SUPPORT,
        support_distance=STEM_SUPPORT_DISTANCE,
        side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
        side_supports=STEM_SIDE_SUPPORTS,
        outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
        outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
        inside_tolerance=STEM_INSIDE_TOLERANCE,
        locations=STEM_LOCATIONS,
        key_rotation=KEY_ROTATION,
        hollow=STEM_HOLLOW,
        uniform_wall_thickness=UNIFORM_WALL_THICKNESS
      );
    } else if (KEY_PROFILE == "gem") {
      GEM_stem(
        stem_type=STEM_TYPE,
        wall_thickness=WALL_THICKNESS,
        wall_extra=STEM_SIDES_WALL_THICKNESS,
        wall_inset=STEM_WALLS_INSET,
        wall_tolerance=STEM_WALLS_TOLERANCE,
        key_length=KEY_LENGTH,
        key_width=KEY_WIDTH,
        height_extra=KEY_HEIGHT_EXTRA,
        inset=STEM_INSET,
        depth=STEM_HEIGHT,
        dish_thickness=DISH_THICKNESS,
        dish_invert=DISH_INVERT,
        dish_fn=DISH_FN,
        dish_corner_fn=DISH_CORNER_FN, // Ignored (always 4)
        corner_radius=STEM_CORNER_RADIUS, // Of the stem; not the keycap
        flat_support=STEM_FLAT_SUPPORT,
        support_distance=STEM_SUPPORT_DISTANCE,
        side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
        side_supports=STEM_SIDE_SUPPORTS,
        outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
        outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
        inside_tolerance=STEM_INSIDE_TOLERANCE,
        locations=STEM_LOCATIONS,
        key_rotation=KEY_ROTATION,
        hollow=STEM_HOLLOW,
        uniform_wall_thickness=UNIFORM_WALL_THICKNESS
      );
    } else if (KEY_PROFILE == "xda") {
      XDA_stem(
        stem_type=STEM_TYPE,
        wall_thickness=WALL_THICKNESS,
        wall_extra=STEM_SIDES_WALL_THICKNESS,
        wall_inset=STEM_WALLS_INSET,
        wall_tolerance=STEM_WALLS_TOLERANCE,
        key_length=KEY_LENGTH,
        key_width=KEY_WIDTH,
        height_extra=KEY_HEIGHT_EXTRA,
        inset=STEM_INSET,
        depth=STEM_HEIGHT,
        dish_thickness=DISH_THICKNESS,
        dish_invert=DISH_INVERT,
        dish_fn=DISH_FN,
        dish_corner_fn=DISH_CORNER_FN, // Ignored (always 4)
        corner_radius=STEM_CORNER_RADIUS, // Of the stem; not the keycap
        flat_support=STEM_FLAT_SUPPORT,
        support_distance=STEM_SUPPORT_DISTANCE,
        side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
        side_supports=STEM_SIDE_SUPPORTS,
        outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
        outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
        inside_tolerance=STEM_INSIDE_TOLERANCE,
        locations=STEM_LOCATIONS,
        key_rotation=KEY_ROTATION,
        hollow=STEM_HOLLOW,
        uniform_wall_thickness=UNIFORM_WALL_THICKNESS
      );
    } else {
      // Use globals
      stem_using_globals();
    }
  }
}

// RENDER = ["custom"];
// RENDER = ["%keycap", "stem"];
// RENDER = ["legends"];
// RENDER = ["keycap"];
RENDER = ["%keycap"];

module render_keycap(stuff_to_render) {
  for (what_to_render = stuff_to_render) {
    if (what_to_render == "row") {
      // For rendering a whole row of keys (use ROW variable)
      note("HAVE PATIENCE! Rendering all keycaps in ROW variable...");
      for (i = [0:1:len(ROW) - 1]) {
        translate([ROW_SPACING * i, 0, 0]) handle_render("keycap", legends=ROW[i]);
      }
    } else if (what_to_render == "row_stems") {
      // For rendering a whole row of stems
      note("HAVE PATIENCE! Rendering all stems in ROW variable...");
      for (i = [0:1:len(ROW) - 1]) {
        translate([ROW_SPACING * i, 0, 0]) handle_render("stem", legends=ROW[i]);
      }
    } else if (what_to_render == "row_legends") {
      // For rendering a whole row of legends
      note("HAVE PATIENCE! Rendering all legends in ROW variable...");
      for (i = [0:1:len(ROW) - 1]) {
        translate([ROW_SPACING * i, 0, 0]) handle_render("legends", legends=ROW[i]);
      }
    } else if (what_to_render == "row_underset_masks") {
      // For rendering a whole row of underset masks
      note("HAVE PATIENCE! Rendering all underset masks in ROW variable...");
      for (i = [0:1:len(ROW) - 1]) {
        translate([ROW_SPACING * i, 0, 0]) handle_render("underset_mask", legends=ROW[i]);
      }
    } else if (what_to_render == "custom") {
    } else {
      handle_render(what_to_render, legends=LEGENDS); // Normal rendering of a single keycap
    }
  }
}

render_keycap(RENDER);
