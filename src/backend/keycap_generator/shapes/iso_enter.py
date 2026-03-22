from ..utilities import KEY_UNIT, KEY_OFFSET, KEYCAP_ID, SUPPORT_BLOCKER_ID
from ..stems import stabilizers_iso, stem_box_cherry, upper_edge_fillet_selector
import cadquery as cq
from loguru import logger
from typing import cast
from .red_calculator import reduction_calculation

DEFAULT_BOTTOM_WIDTH = 1.25
SKINNY_BOTTOM_WIDTH = 1
ISO_ENTER_UP_DOWN_DIFF = 0.25

def _iso_enter_path(unit:float, skinny:bool = False):
    '''  * This function returns the iso enter path
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
    '''

    bottom_width = SKINNY_BOTTOM_WIDTH if skinny else DEFAULT_BOTTOM_WIDTH

    sketch = cq.Sketch().polygon([
        (0+KEY_OFFSET, 0+KEY_OFFSET), # A
        (bottom_width*unit-KEY_OFFSET, 0+KEY_OFFSET), # B
        (bottom_width*unit-KEY_OFFSET, 2 * unit-KEY_OFFSET), # C
        (-(ISO_ENTER_UP_DOWN_DIFF * unit)+KEY_OFFSET, 2 * unit-KEY_OFFSET), # D
        (-(ISO_ENTER_UP_DOWN_DIFF * unit)+KEY_OFFSET, unit+KEY_OFFSET), # E
        (0+KEY_OFFSET, unit+KEY_OFFSET), # F
    ])
    return sketch


def iso_enter_solid(
    top_difference:float, # How much smaller the top of the keycap is compared to the bottom
    cross_height:float, # Height of the cross to accommodate the switch stem
    heightZ:float, # key height
    wall_thickness:float, # thickness of the keycap walls
    dish_thickness:float, # How much material under dish
    stem_inside_tolerance:float, # Tolerance for the stem inside the keycap
    preprocessing:bool, # If True, will add support blockers
    tapering_curve:float|None = None, # if None no tapering will be applied
    skinny:bool = False, # whether to use the skinny enter dimensions
    xy_offset:tuple[float, float] = (0, 0), # xy offset of top layer 
    upper_fillet:float = 0, # fillet radius of top edges
    side_fillet:float = 0, # fillet radius of side edges
    stem_inset:float = 0,
    stem_type:str = "box_cherry",
):
    '''
    Module to create the iso enter solid
    Parameters:
    - base_unit: base layer value of u(nit) in mm (required)
    - top_unit: top layer value of u(nit) in mm if different from base layer (optional; if not provided, it will be the same as base_unit)
    - height: solid height (z offset of top layer) (required)
    - skinny: whether to use the skinny enter dimensions (optional; default: false)
    - xy_offset: xy offset of top layer (optional; default: [0, 0])
    - fillet_radius_base: fillet radius of base (required)
    - fillet_radius_top: fillet radius of top
    - n_layers: number of layers for the loft (higher = smoother but slower) (required)
    - $fn: Number of fragments for rounded corners (high = smoother) (optional; default: 64)
    '''
    top_x = xy_offset[0]
    top_y = xy_offset[1]
    baseU = KEY_UNIT
    top_difference = top_difference / 2
    topU = baseU - top_difference

    center_top = (top_difference / 2, top_difference)
    topLayerOffset = (top_x + center_top[0], top_y + center_top[1])


    result = cq.Workplane("XY")
    assy = cq.Assembly() # Returned assembly

    if tapering_curve is None:
        s1 = _iso_enter_path(baseU, skinny)
        s2 = _iso_enter_path(topU, skinny)

        result = (
            result
            .placeSketch(s1, s2.moved(x=topLayerOffset[0], y=topLayerOffset[1], z=heightZ))
            .loft()
        )
    else:
        pass
        # TODO fix code to implement xy_offset for tapering_curve and final layer

        sketchList:list[cq.Sketch] = []
        iterations = int(heightZ) + 1
        logger.debug(f"height: {heightZ}, iterations: {iterations}, tapering_curve: {tapering_curve}")

        for i in range(0, iterations):
            reduction = reduction_calculation(i, tapering_curve, iterations)
            logger.debug(f"i: {i}, reduction: {reduction}")
            curve_val = (top_difference - reduction) * (i/iterations)
            sizeX = baseU - curve_val
            logger.debug(f"i: {i}, sizeX: {sizeX}")

            layerX = curve_val/2
            layerY = curve_val/2
            sketch = _iso_enter_path(sizeX, skinny).moved(x=layerX, y=layerY, z=i)
            sketchList.append(sketch)

        # Place the final sketch
        if not heightZ.is_integer(): # If heightZ is not an integer, we need to add the final sketch
            finalSketch = _iso_enter_path(topU, skinny).moved(x=topLayerOffset[0], y=topLayerOffset[1], z=heightZ)
            sketchList.append(finalSketch)

        logger.debug(sketchList)

        result = result.placeSketch(*sketchList)
        result = result.loft()


    # TODO port dish code from OpenSCAD script

    # Translate key center to origin
    x_offset = (SKINNY_BOTTOM_WIDTH * baseU) / 2 if skinny else (DEFAULT_BOTTOM_WIDTH * baseU) / 2
    y_offset = baseU
    result = result.translate((- x_offset, - y_offset, 0))    

    stem = None
    stem_height = heightZ - dish_thickness - stem_inset
    logger.debug(f"stem_height: {stem_height}, heightZ: {heightZ}, dish_thickness: {dish_thickness}, stem_inset: {stem_inset}")
    if stem_height < 4:
        raise ValueError(f"Stem height is too small ({stem_height}). Consider increasing the keycap height or reducing the dish thickness.")
    
    match stem_type:
        case "box_cherry":
            stem = stem_box_cherry(
                    stem_inset=stem_inset,
                    cross_height=cross_height,
                    stem_height= stem_height,
                    inside_tolerance=stem_inside_tolerance,
                    )
        
        case "round_cherry":
            # TODO implement
            logger.warning("Round cherry stem not implemented yet.")

        case "alps":
            # TODO implement
            logger.warning("Alps stem not implemented yet.")

        case _:
            raise ValueError(f"Invalid stem_type: {stem_type}")



    # Dish thickness
    boxHeight = dish_thickness
    boxPositionZ = stem_height + stem_inset + boxHeight/2
    box  = cq.Workplane("XY").box(
                baseU*2,
                baseU*2,
                boxHeight,
                centered=True
            ).translate((0, 0, boxPositionZ))

    if stem is not None:
        res = box.union(stem)

        # Create the outer box used for the negative
        outerBox  = cq.Workplane("XY").box(
            baseU*4,
            baseU*4,
            heightZ*2,
            centered=True
        )

        # Create the negative shape to remove excess material from the stem
        negativeShape = outerBox.cut(result)

        # Apply fillet to the edges of the stem cut that are nearest to the top of the keycap
        selector = upper_edge_fillet_selector(stem)
        res = (res.edges(selector).fillet(1))

        # Create stabilizer stems
        stabilizersPosList:list[tuple[float, float]] = stabilizers_iso()
        for pos in stabilizersPosList:
            res = res.union(stem.translate(pos))
            selector = upper_edge_fillet_selector(stem.translate(pos))
            # Apply fillet
            res = (res.edges(selector).fillet(1))

        stem_cut = res.cut(negativeShape)

        # Create the internal cut
        result = result.faces("<Z").shell(wall_thickness, kind="intersection")

        # Combine the keycap with the stem and box
        result = result.union(stem_cut)

        if side_fillet > 0:
            edges = result.edges().vals()
            logger.debug(f"Number of edges: {len(edges)}")
            edgeList:list[cq.Edge] = []
            for edge in edges:
                edge = cast(cq.Edge, edge) # because pylance otherwise is annoying...
                bb = edge.BoundingBox()
                length = cast(float, edge.Length()) # type:ignore

                condition1 = bb.zmin == 0 # start from base
                condition2 = bb.zmax != bb.zmin # not on plane xy
                conditions = condition1 and condition2
                if conditions:
                    logger.debug(f"Edge: {edge}, Length: {length}")
                    logger.debug(f"{bb.xmin}, {bb.xmax}")
                    logger.debug(f"{bb.ymin}, {bb.ymax}")
                    logger.debug(f"{bb.zmin}, {bb.zmax}")

                    edgeList.append(edge)

            logger.trace(f"Number of edges to fillet: {len(edgeList)}")
            result.newObject(edgeList).edges(">Y").tag("D_C_edges")
            result.newObject(edgeList).edges("<Y").tag("A_B_edges")
            edges_DE_plane = result.newObject(edgeList).edges("<X").vals()

            logger.debug(f"Number of edges on DE plane: {len(edges_DE_plane)}")
            E_edge = min(edges_DE_plane, key=lambda edge: cast(cq.Edge, edge).BoundingBox().ymin)
            E_edge_bb = cast(cq.Edge, E_edge).BoundingBox()
            E_y_pos = E_edge_bb.ymin
            E_x_pos = E_edge_bb.xmax
            logger.debug(f"E_edge: {E_edge}, E_y_pos: {E_y_pos}")

            for edge in edges_DE_plane:
                edge = cast(cq.Edge, edge) # because pylance otherwise is annoying...
                bb = edge.BoundingBox()
                length = edge.Length()
                logger.debug(f"Edge: {edge}, Length: {length}")
                logger.debug(f"{bb.xmin}, {bb.xmax}")
                logger.debug(f"{bb.ymin}, {bb.ymax}")
                logger.debug(f"{bb.zmin}, {bb.zmax}")


            result = result.edges(tag="A_B_edges").fillet(side_fillet)
            result = result.edges(tag="D_C_edges").fillet(side_fillet)
            result = result.newObject([E_edge]).fillet(side_fillet)
            F_edge_selector = cq.selectors.NearestToPointSelector(cq.Vector(E_x_pos + top_difference, E_y_pos, heightZ / 2))
            edgeF_fillet = side_fillet if side_fillet <= 1 else 1
            result = result.edges(F_edge_selector).fillet(edgeF_fillet)

        if upper_fillet > 0:
            result = result.edges(">Z").fillet(upper_fillet)

        # Add to result assembly
        assy.add(result, name=KEYCAP_ID, color=cq.Color("yellow"))

        if preprocessing:
            stabilizersPosList.append((0, 0)) # Add the center stem position for the main stem
            # Add support blockers to the assembly
            bbox = cast(cq.Shape, stem.val()).BoundingBox()
            blocker = (
                cq.Workplane("XY")
                .box(
                    bbox.xmax - bbox.xmin,
                    bbox.ymax - bbox.ymin,
                    stem_height,
                )
                .translate((0, 0, stem_height /2 + stem_inset + 0.1))
            )
            for i, pos in enumerate(stabilizersPosList):
                assy.add(
                    blocker.translate((pos[0], pos[1], 0)),
                    name=f"{SUPPORT_BLOCKER_ID}{i}",
                    color=cq.Color(1.0, 0.0, 0.0, 0.4), # Transparent red color
                    )

    return assy