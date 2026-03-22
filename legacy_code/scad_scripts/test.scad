include <utils.scad>
$fn = 256;

diameter = 30;

difference() {
  // Keycap body
  cube(size=[diameter, diameter, diameter], center=false);

  translate([diameter / 2, diameter / 2, diameter]) {
    sphere(r=diameter);
  }
}

cubeLenX = 30;
cubeLenY = 30;
cubeLenZ = 30;

resolution = 0.1;

function generate_path(
  cubeLenX,
  cubeLenY,
  cubeLenZ,
  resolution
) =
  let (
    sphereCenter = [
      cubeLenX / 2,
      cubeLenY,
      cubeLenZ / 2,
    ],
    sphereRadius = cubeLenY
  ) deduplicate(
    // Remove duplicate points, closed=true treats the first and last point as the same point
    concat(
      [
        // Find the 4 sides of the cube that intersect with the sphere
        for (i = [0:resolution:cubeLenX]) let (
          j = find_first_j(
            i,
            0,
            cubeLenX,
            sphereCenter,
            sphereRadius,
            resolution
          )
        ) if (j != undef) [i, 0, j],
      ],

      [
        for (y = [0:resolution:cubeLenY]) let (
          j = find_first_j(
            y,
            0,
            cubeLenX,
            sphereCenter,
            sphereRadius,
            resolution
          )
        ) if (j != undef) [cubeLenX, y, j],
      ],

      [
        for (i = [cubeLenX:-resolution:0]) let (
          j = find_first_j(
            i,
            0,
            cubeLenX,
            sphereCenter,
            sphereRadius,
            resolution
          )
        ) if (j != undef) [i, cubeLenY, j],
      ],

      [
        for (y = [cubeLenY:-resolution:0]) let (
          j = find_first_j(
            y,
            0,
            cubeLenX,
            sphereCenter,
            sphereRadius,
            resolution
          )
        ) if (j != undef) [0, y, j],
      ]
    ), closed=true
  );

function inside_sphere(point, center, radius) =
  let (
    x = point[0],
    y = point[1],
    z = point[2],
    cx = center[0],
    cy = center[1],
    cz = center[2],
    distance_sq = pow(x - cx, 2) + pow(y - cy, 2) + pow(z - cz, 2)
  ) distance_sq <= pow(radius, 2);

function find_first_j(
  i,
  j,
  maxJ,
  sphereCenter,
  sphereRadius,
  resolution
) =
  j >= maxJ ? undef
  : inside_sphere(
    [i, j, 0],
    sphereCenter,
    sphereRadius
  ) ? j
  : find_first_j(
    i,
    j + resolution,
    maxJ,
    sphereCenter,
    sphereRadius,
    resolution
  );

path = generate_path(
  cubeLenX,
  cubeLenY,
  cubeLenZ,
  resolution
);

color("red")
  stem_fillet_3D(
    fillet_radius=2,
    path_points=path,
    path_fillet_radius=0,
    flip=[0, 0, 0],
    internal=true
  );
