# Stem-related modules
import cadquery as cq
from loguru import logger
from typing import cast
from cadquery.occ_impl.shapes import Edge

# NOTES
    # Some of the stem arguments are unused.  They're there in case we need to use them in the future (e.g. dish_tilt might be taken into account in the future if we need to make the underside of keycaps tilted).
    # Alps stabilizer stem notes:
    #     4.15 x 5.15 outer edges of the rectangle insert
    #     about 1.01 thick rim
    #     insert can go in about 4mm i think

# Cherry constants (not all used; many are here "just in case")
CHERRY_SWITCH_LENGTH = 15.6
CHERRY_SWITCH_WIDTH = 15.6
CHERRY_CYLINDER_DIAMETER = 5.47
CHERRY_STEM_HEIGHT = 4.5 # How far the underside of the keycap extends into the stem()
CHERRY_CROSS_X_THICKNESS = 1.3 # Width of the - in the +
CHERRY_CROSS_Y_THICKNESS = 1.1 # Width of the - in the |
CHERRY_CROSS_LENGTH = 4 # Length of the - and the | in the +
CHERRY_BOX_STEM_WIDTH = 6.5 # Outside dimensions of a box-style stem
CHERRY_BOX_STEM_LENGTH = 6.5

# Alps constants
ALPS_STEM_LENGTH = 4.5
ALPS_STEM_WIDTH = 2.3
ALPS_STEM_DEPTH = 3.5 # How far it goes into the switch
ALPS_STEM_OUTSIDE_LENGTH = 6.5 # Part that stops the stem from going any further into the switch
ALPS_STEM_OUTSIDE_WIDTH = 5 # Ditto
ALPS_STEM_INSIDE_LENGTH = 2.6 # Only for SKFL
ALPS_STEM_INSIDE_WIDTH = 0.9 # Ditto


def cherry_cross(cross_height:float, tolerance:float = 0.1):
    '''
    This makes the + bit that slides *in* to a Cherry MX style keycap
    * extra_tolerance: How much *thicker* the cross will be rendered
    '''
    depth:float = cross_height
    logger.debug(f"Generating cherry cross with depth {depth} and tolerance {tolerance}")

    cross = (
        cq.Workplane("XY")
        .box(
            CHERRY_CROSS_Y_THICKNESS + tolerance * 2,
            CHERRY_CROSS_LENGTH + tolerance / 4,
            depth
        )
        .union(
            cq.Workplane("XY")
            .box(
                CHERRY_CROSS_LENGTH + tolerance,
                CHERRY_CROSS_X_THICKNESS + tolerance,
                depth
            )
        ).translate((0,0, depth/2))
    )
    return cross

def upper_edge_fillet_selector(stem:cq.Workplane) -> cq.selectors.Selector:
    shape = cast(cq.Shape, stem.val())
    bb = shape.BoundingBox()
    logger.debug(f"{bb.xmin}, {bb.xmax}")
    logger.debug(f"{bb.ymin}, {bb.ymax}")
    logger.debug(f"{bb.zmin}, {bb.zmax}")

    logger.debug(f"{bb.xlen}, {bb.ylen}, {bb.zlen}")

    # Selector is A-B=C
    boxOffset = 0.01
    selectorA = cq.selectors.BoxSelector(
        (bb.xmin-boxOffset, bb.ymin - boxOffset, bb.zmax -boxOffset),
        (bb.xmax+boxOffset, bb.ymax + boxOffset, bb.zmax +boxOffset)
        )

    selectorB = cq.selectors.BoxSelector(
        (bb.xmin+boxOffset, bb.ymin + boxOffset, bb.zmax -boxOffset),
        (bb.xmax-boxOffset, bb.ymax - boxOffset, bb.zmax +boxOffset)
        )

    selector = cq.selectors.SubtractSelector(selectorA, selectorB)

    return selector

def stem_box_cherry(
    cross_height: float, # Height of the cross to accommodate the switch stem
    stem_height: float,
    stem_inset: float,
    outside_tolerance_x: float = 0.2,
    outside_tolerance_y: float = 0.2,
    inside_tolerance: float = 0.25,
    stem_corner_radius: float = 0.5,
) -> cq.Workplane:
    """
    Generates a Cherry MX-style box stem.

    Args:
        cross_height (float): Height of the cross to accommodate the switch stem.
        stem_height (float): Total height of the stem.
        stem_inset (float): How far the stem is inset into the keycap.
        outside_tolerance_x (float, optional): Tolerance for the outside width of the stem. Defaults to 0.2.
        outside_tolerance_y (float, optional): Tolerance for the outside length of the stem. Defaults to 0.2.
        inside_tolerance (float, optional): Tolerance for the inside dimensions of the cross. Defaults to 0.25.
        stem_corner_radius (float, optional): Radius for filleting the corners of the stem. Defaults to 0.5.

    Returns:
        CadQuery Workplane containing the stem solid.
    """

    length = CHERRY_CYLINDER_DIAMETER - outside_tolerance_x * 2
    width = CHERRY_CYLINDER_DIAMETER - outside_tolerance_y * 2

    logger.debug(f"Stem height: {stem_height}")

    stem = (
        cq.Workplane("XY")
        .box(
            length,
            width,
            stem_height,
            centered=(True, True, False)
        )
        .edges("|Z")
        .fillet(stem_corner_radius)
    )

    cross = cherry_cross(
        tolerance=inside_tolerance,
        cross_height=cross_height
    )

    # Remove the cross from the stem to create the final shape
    stem = stem.cut(cross)

    # Fillet cross entrance
    xy_plane_edges:list[Edge] = []
    target_length = CHERRY_CROSS_LENGTH/2
    edges = cast(list[Edge], stem.edges().vals())
    logger.debug(f"target_length: {target_length}")
    for edge in edges:
        center = edge.Center()
        tangent = cast(cq.Vector, edge.tangentAt(0.5)) #type:ignore
        length = edge.Length()

        if (
            abs(tangent.z) < 0.01      # parallel to XY
            and abs(center.z) < 0.01   # lying on XY plane
            and length - target_length < 0.01  # matching edge length
            and (tangent.x == -1.0 or tangent.y == 1.0)
        ):
            logger.debug(f"edge: {edge}, tangent: {tangent}, center: {center}, length: {length}")   
            xy_plane_edges.append(edge)

    logger.debug(len(xy_plane_edges))

    stem = stem.newObject(xy_plane_edges).fillet(0.3)

    # Translate the stem along z axis
    stem = stem.translate((0, 0, stem_inset))
    return stem


# stem = stem_box_cherry(stem_inset=1)

# TODO port the other stem types (alps, etc.)
