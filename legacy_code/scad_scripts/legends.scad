// Legend-related modules

use <keycaps.scad>
use <stems.scad>
use <utils.scad>

// NOTE: Named 'draw_legend' and not just 'legend' to avoid confusion in variable naming

// Extrudes the legend characters the full height of the keycap so an intersection() and difference() can be performed)
module draw_legend(chars, size, font, height) {
  linear_extrude(height=height)
    text(chars, size=size, font=font, valign="center", halign="center");
}

// For multi-material prints you can generate *just* the legends in their proper locations:
module just_legends(
  height = 9.0,
  legend_list = [""],
) {
  // Take care of the legends (if any)
  if (legend_list[0]) {
    union() {
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

        translate(underset) translate(trans2) rotate(rotation2) translate(trans) rotate(rotation)
                  scale(l_scale)
                    draw_legend(legend, font_size, font, height);
      }
    }
  } else {
    note("This keycap has no legends.");
  }
}
