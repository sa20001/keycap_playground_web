from __future__ import annotations

from dataclasses import dataclass
from math import inf, sqrt
from typing import Sequence, cast
from loguru import logger

import cadquery as cq

'''
This code is a Python translation (LLM based) of the adaptive layer-height algorithm used by PrusaSlicer.
The original C++ implementation can be found in the PrusaSlicer source code, specifically in
* **`SlicingAdaptive.cpp`** — adaptive/variable layer-height algorithm:
  [SlicingAdaptive.cpp](https://github.com/prusa3d/PrusaSlicer/blob/master/src/libslic3r/SlicingAdaptive.cpp)

* **`Slicing.cpp`** — surrounding layer-height profile generation and slicing logic:
  [Slicing.cpp](https://github.com/prusa3d/PrusaSlicer/blob/master/src/libslic3r/Slicing.cpp)

* **`SlicingAdaptive.hpp`** — declarations for the adaptive slicing implementation:
  [SlicingAdaptive.hpp](https://github.com/prusa3d/PrusaSlicer/blob/master/src/libslic3r/SlicingAdaptive.hpp)
'''

# This is the EPSILON used by PrusaSlicer in Slicing.cpp /
# SlicingAdaptive.cpp for the relevant comparisons.
EPSILON = 1e-6

# Same threshold used by PrusaSlicer in layer_height_from_slope().
NORMAL_Z_EPSILON = 1e-5


@dataclass(slots=True)
class FaceZ:
    """
    Information about one tessellated triangle.

    zmin/zmax:
        Vertical extent of the triangle.

    n_cos:
        abs(normal.z), i.e. cosine of the angle to the Z axis.

    n_sin:
        sqrt(normal.x^2 + normal.y^2), i.e. sine of the angle
        to the Z axis.
    """

    zmin: float
    zmax: float
    n_cos: float
    n_sin: float


def layer_height_from_slope(
    face: FaceZ,
    max_surface_deviation: float,
) -> float:
    """
    Python equivalent of PrusaSlicer's:

        SlicingAdaptive::layer_height_from_slope()

    from SlicingAdaptive.cpp.

    Active PrusaSlicer formula:

        min(
            max_surface_deviation / 0.184,
            1.44 * max_surface_deviation
                * sqrt(n_sin / n_cos)
        )

    with FLT_MAX used for a nearly vertical facet.
    """

    if face.n_cos > NORMAL_Z_EPSILON:
        slope_height = (
            1.44
            * max_surface_deviation
            * sqrt(face.n_sin / face.n_cos)
        )
    else:
        slope_height = inf

    return min(
        max_surface_deviation / 0.184,
        slope_height,
    )


def prepare_faces_from_mesh(
    vertices:list[cq.Vector],
    indices:list[tuple[int, int, int]],
) -> list[FaceZ]:
    """
    Equivalent to SlicingAdaptive::prepare() for an already
    tessellated mesh.

    PrusaSlicer:

        1. Calculates the normalized triangle normal.
        2. Stores the triangle's Z span.
        3. Stores abs(normal.z).
        4. Stores sqrt(nx^2 + ny^2).
        5. Sorts faces lexicographically by Z span.
    """

    faces: list[FaceZ] = []

    for i0, i1, i2 in indices:
        a = vertices[i0]
        b = vertices[i1]
        c = vertices[i2]

        ux = b.x - a.x
        uy = b.y - a.y
        uz = b.z - a.z

        vx = c.x - a.x
        vy = c.y - a.y
        vz = c.z - a.z

        # Cross product.
        nx = uy * vz - uz * vy
        ny = uz * vx - ux * vz
        nz = ux * vy - uy * vx

        length = sqrt(nx * nx + ny * ny + nz * nz)

        # Degenerate tessellation triangle.
        if length == 0.0:
            continue

        nx /= length
        ny /= length
        nz /= length

        faces.append(
            FaceZ(
                zmin=min(a.z, b.z, c.z),
                zmax=max(a.z, b.z, c.z),
                n_cos=abs(nz),
                n_sin=sqrt(nx * nx + ny * ny),
            )
        )

    # Equivalent to:
    #
    # std::sort(m_faces.begin(), m_faces.end(),
    #     [](const FaceZ &f1, const FaceZ &f2) {
    #         return f1.z_span < f2.z_span;
    #     });
    #
    # std::pair<float,float> compares lexicographically.
    faces.sort(key=lambda f: (f.zmin, f.zmax))

    return faces


def cq_to_faces(
    obj: cq.Workplane,
    tessellation_tolerance: float = 0.05,
) -> list[FaceZ]:
    """
    Tessellate a CadQuery Workplane and convert its triangles into
    the representation used by the adaptive layer-height algorithm.

    The CadQuery shape is assumed to already be in the coordinate
    system in which it will be sliced.
    """

    shape = cast(cq.Shape, obj.val())

    vertices, indices = shape.tessellate(
        tessellation_tolerance
    )

    return prepare_faces_from_mesh(vertices, indices)


def _lerp(
    a: float,
    b: float,
    t: float,
) -> float:
    return a + (b - a) * t


def _max_surface_deviation(
    quality_factor: float,
    min_layer_height: float,
    layer_height: float,
    max_layer_height: float,
) -> float:
    """
    Exact active quality interpolation from SlicingAdaptive.cpp.

    quality_factor:
        0.0 -> minimum layer height
        0.5 -> configured layer height
        1.0 -> maximum layer height
    """

    delta_min = min_layer_height
    delta_mid = layer_height
    delta_max = max_layer_height

    if quality_factor < 0.5:
        return _lerp(
            delta_min,
            delta_mid,
            2.0 * quality_factor,
        )

    return _lerp(
        delta_max,
        delta_mid,
        2.0 * (1.0 - quality_factor),
    )


def next_layer_height(
    faces: Sequence[FaceZ],
    print_z: float,
    quality_factor: float,
    min_layer_height: float,
    layer_height: float,
    max_layer_height: float,
    current_facet: int,
) -> tuple[float, int]:
    """
    Python translation of:

        SlicingAdaptive::next_layer_height()

    Returns:

        (height, current_facet)

    current_facet is in/out parameter, remembers the index of the last
    face of m_faces visited, where this function will start from.
    """

    # ------------------------------------------------------------
    # Initial candidate.
    #
    # C++:
    #
    # float height = m_slicing_params.max_layer_height;
    # ------------------------------------------------------------

    height = max_layer_height

    max_surface_deviation = _max_surface_deviation(
        quality_factor=quality_factor,
        min_layer_height=min_layer_height,
        layer_height=layer_height,
        max_layer_height=max_layer_height,
    )

    # ------------------------------------------------------------
    # Find facets intersecting the current slice plane.
    #
    # This intentionally follows the C++ cursor logic.
    # ------------------------------------------------------------

    ordered_id = current_facet
    first_hit = False

    while ordered_id < len(faces):
        face = faces[ordered_id]

        # Facet's minimum is higher than the slice Z.
        #
        # Faces are sorted by zmin, therefore nothing after this
        # can intersect print_z.
        if face.zmin >= print_z:
            break

        # Facet intersects the slice plane.
        if face.zmax > print_z:

            # Remember the first intersecting facet so the next
            # invocation can start here.
            if not first_hit:
                first_hit = True
                current_facet = ordered_id

            # Skip a facet that only touches the plane within
            # EPSILON.
            #
            # This is intentionally '<', not '<='.
            if face.zmax < print_z + EPSILON:
                ordered_id += 1
                continue

            reduced_height = layer_height_from_slope(
                face,
                max_surface_deviation,
            )

            height = min(
                height,
                reduced_height,
            )

        ordered_id += 1

    # ------------------------------------------------------------
    # Enforce minimum printer layer height.
    #
    # C++ does this even if the surface calculation produced a
    # smaller value.
    # ------------------------------------------------------------

    height = max(
        height,
        min_layer_height,
    )

    # ------------------------------------------------------------
    # Examine facets beginning inside the proposed layer.
    #
    # This is the second pass in SlicingAdaptive.cpp.
    # ------------------------------------------------------------

    if height > min_layer_height:

        while ordered_id < len(faces):
            face = faces[ordered_id]

            # Facet begins at/above the proposed layer top.
            #
            # Because faces are sorted by zmin, we can stop.
            if face.zmin >= print_z + height:
                break

            # Skip facets which end before/at the current plane,
            # subject to the same EPSILON behavior as C++.
            if face.zmax < print_z + EPSILON:
                ordered_id += 1
                continue

            reduced_height = layer_height_from_slope(
                face,
                max_surface_deviation,
            )

            z_diff = face.zmin - print_z

            if reduced_height < z_diff:
                # The triangle starts above the proposed layer
                # and its cusp restriction is smaller than the
                # distance to that triangle.
                #
                # PrusaSlicer asserts that:
                #
                #     z_diff < height + EPSILON
                #
                # under normal operation.
                height = z_diff

            elif reduced_height < height:
                height = reduced_height

            ordered_id += 1

        # Apply minimum layer height again.
        height = max(
            height,
            min_layer_height,
        )

    return height, current_facet

def add_layer(profile: list[float], layer_height: float, processed_height: float) -> None:
    profile.extend((processed_height, layer_height))


def generate_adaptive_layer_heights_from_faces(
    faces: Sequence[FaceZ],
    *,
    object_height: float,
    first_layer_height: float,
    min_layer_height: float,
    layer_height: float,
    max_layer_height: float,
    quality_factor: float,
) -> list[float]:
    """
    Generate the actual successive layer thicknesses.

    This follows the active PrusaSlicer adaptive profile algorithm,
    while returning the result as a simple list of layer thicknesses
    rather than PrusaSlicer's internal [Z, height, Z, height, ...]
    profile representation.

    The object is assumed to have its slicing Z origin at 0.

    The first layer is fixed at first_layer_height.
    """

    if object_height <= 0.0:
        return []

    if first_layer_height <= 0.0:
        raise ValueError(
            "first_layer_height must be > 0"
        )

    if min_layer_height <= 0.0:
        raise ValueError(
            "min_layer_height must be > 0"
        )

    if min_layer_height > layer_height:
        raise ValueError(
            "min_layer_height must be <= layer_height"
        )

    if layer_height > max_layer_height:
        raise ValueError(
            "layer_height must be <= max_layer_height"
        )

    if not 0.0 <= quality_factor <= 1.0:
        raise ValueError(
            "quality_factor must be between 0 and 1"
        )

    if not faces:
        # There is no surface information from which to adapt.
        #
        # Use the normal layer height, with the final layer handled
        # exactly like the adaptive profile generator.
        result: list[float] = []

        if object_height <= first_layer_height + EPSILON:
            return [object_height]

        result.append(first_layer_height)

        z = first_layer_height

        while z + EPSILON < object_height:
            height = min(
                layer_height,
                object_height - z,
            )

            if height <= 0.0:
                break

            result.append(height)
            z += height

        return result


    # ------------------------------------------------------------
    # PrusaSlicer initializes its profile with:
    #
    #   0
    #   first_object_layer_height
    #
    # Since this API returns heights rather than the internal
    # [Z, height, ...] representation, this becomes simply:
    # ------------------------------------------------------------

    if object_height <= first_layer_height + EPSILON:
        # The object is shorter than the requested first layer.
        #
        # The actual printable interval is the object height.
        return [object_height]

    logger.debug("========== ADAPTIVE DEBUG ==========")
    logger.debug("object_height:", object_height)
    logger.debug("first_layer_height:", first_layer_height)
    logger.debug("min_layer_height:", min_layer_height)
    logger.debug("layer_height:", layer_height)
    logger.debug("max_layer_height:", max_layer_height)
    logger.debug("quality_factor:", quality_factor)
    logger.debug("====================================")

    # Append some layer specifics

    profile: list[float] = []
    profile.append(0.0)
    profile.append(first_layer_height)
    profile.append(first_layer_height)
    profile.append(first_layer_height)

    print_z = first_layer_height
    current_facet = 0

    # ------------------------------------------------------------
    # Main adaptive loop.
    #
    # This corresponds to:
    #
    # while (print_z + EPSILON <
    #        object_print_z_uncompensated_height())
    #
    # in Slicing.cpp.
    # ------------------------------------------------------------
    processed_height:float = first_layer_height
    while print_z + EPSILON < object_height:

        cusp_height, current_facet = next_layer_height(
            faces=faces,
            print_z=print_z,
            quality_factor=quality_factor,
            min_layer_height=min_layer_height,
            layer_height=layer_height,
            max_layer_height=max_layer_height,
            current_facet=current_facet,
        )

        height = min(
            cusp_height,
            max_layer_height,
        )

        if height <= 0.0:
            break

        if height <= EPSILON:
            break

        add_layer(profile, height, processed_height)
        print_z += height
        processed_height += height


    # ------------------------------------------------------------
    # PrusaSlicer final-gap handling.
    #
    # C++:
    #
    # double z_gap =
    #     object_height - *(layer_height_profile.end() - 2);
    #
    # if (z_gap > 0.0) {
    #     layer_height_profile.push_back(object_height);
    #     layer_height_profile.push_back(
    #         std::clamp(
    #             z_gap,
    #             min_layer_height,
    #             max_layer_height
    #         )
    #     );
    # }
    # ------------------------------------------------------------

    last_z = profile[-2]
    z_gap = object_height - last_z

    if z_gap > 0.0:
        final_height = max(
            min_layer_height,
            min(z_gap, max_layer_height),
        )

        add_layer(profile, final_height, object_height)

    # Round to 6 decimal places
    profile = [round(h, 6) for h in profile]

    return profile

def generate_adaptive_layer_heights(
    obj: cq.Workplane,
    *,
    first_layer_height: float = 0.2,
    min_layer_height: float = 0.08,
    layer_height: float = 0.2,
    max_layer_height: float = 0.3,
    quality_speed_factor: float = 0.5,
    tessellation_tolerance: float = 0.05,
) -> list[float]:
    """
    Public CadQuery API.

    Example:

        profile = generate_adaptive_layer_heights(
            obj=my_workplane,
            first_layer_height=0.2,
            min_layer_height=0.08,
            layer_height=0.2,
            max_layer_height=0.3,
            quality_speed_factor=0.5,
        )

    Returns:

        [height0, height1, height2, ...]

    where each entry is the thickness of one successive layer.
    """

    shape = cast(cq.Shape, obj.val())

    bbox = shape.BoundingBox()

    # PrusaSlicer normally works with object_print_z_min = 0
    # for the object coordinate system. This API follows that
    # convention. If the CadQuery object is not based at Z=0,
    # normalize it before calling this function.
    zmin = bbox.zmin
    zmax = bbox.zmax

    if abs(zmin) > EPSILON:
        logger.warning(f"Object must start at Z=0 for this API; "
                    f"bounding-box zmin is {zmin:g}")
        logger.warning("Normalizing object to Z=0 for adaptive layer-height calculation.")
        obj = obj.translate((0, 0, -zmin))

    object_height = zmax - zmin

    logger.debug("========== ADAPTIVE DEBUG ==========")
    logger.debug("zmin:", zmin)
    logger.debug("zmax:", zmax)
    logger.debug("object_height:", object_height)
    logger.debug("====================================")

    faces = cq_to_faces(
        obj,
        tessellation_tolerance=tessellation_tolerance,
    )

    return generate_adaptive_layer_heights_from_faces(
        faces,
        object_height=object_height,
        first_layer_height=first_layer_height,
        min_layer_height=min_layer_height,
        layer_height=layer_height,
        max_layer_height=max_layer_height,
        quality_factor=quality_speed_factor,
    )