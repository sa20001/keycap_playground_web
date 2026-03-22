import cadquery as cq
from loguru import logger
from ..stems import stem_box_cherry, upper_edge_fillet_selector, stabilizer_stems_coords
from .red_calculator import reduction_calculation
from ..utilities import KEY_UNIT, KeyUnit, KEY_OFFSET, KEYCAP_ID, SUPPORT_BLOCKER_ID
from typing import cast

#       Z+
#       |
#       |
#       +------ X+
#      /
#     /
#   Y-

def poly_keycap(
        heightZ:float,
        widthU:KeyUnit, # in x direction
        heightU:KeyUnit, # in y direction
        dish_thickness:float, # How much material under dish
        top_difference:float, # Difference between top and bottom length/width,
        stem_inside_tolerance:float, # Tolerance for the stem inside the keycap
        cross_height:float, # Height of the cross to accommodate the switch stem
        preprocessing:bool, # If True, will add support blockers
        xy_offset:tuple[float, float] = (0, 0), # Offset of the top rectangle in XY plane
        tapering_curve:float|None = None,
        dish_type:str|None = None, # if None no dish will be created
        dish_depth:float = 0, # The greater the value, the more pronounced the dish will be.
        # Cylinder only pars
        tiltCylinder:float = 0.0,

        # Other pars
        side_fillet:float = 2,
        upper_fillet:float = 0.5,
        wall_thickness:float = 1.5,
        stem_type:str = "box_cherry",
        stem_inset:float = 0,
):
    '''
    Pars:
        dish_type: str|None
            Type of dish to create. Options are "sphere", "cylinder", "inv_pyramid", or None. If None, no dish will be created.
    '''
    # TODO do function documentation

    widthX = (widthU * KEY_UNIT) - 2*KEY_OFFSET
    heightY = (heightU * KEY_UNIT) - 2*KEY_OFFSET

    top_x = xy_offset[0]
    top_y = xy_offset[1]
    top_lengthX = widthX - top_difference
    top_widthY = heightY - top_difference
    result:cq.Workplane = cq.Workplane("XY")
    assy = cq.Assembly() # Returned assembly

    if tapering_curve is None:
        s1 = cq.Sketch().rect(widthX, heightY)
        s2 = cq.Sketch().rect(top_lengthX, top_widthY)

        if side_fillet > 0:
            s1 = s1.vertices().fillet(side_fillet)
            s2 = s2.vertices().fillet(side_fillet)

        result = (
            result
            .placeSketch(s1, s2.moved(x=top_x, y=top_y, z=heightZ))
            .loft()
        )
    else:
        # TODO implement xy_offset for tapering_curve and final layer

        sketchList:list[cq.Sketch] = []
        iterations = int(heightZ) + 1
        logger.debug(f"height: {heightZ}, iterations: {iterations}, tapering_curve: {tapering_curve}")

        for i in range(0, iterations):
            reduction = reduction_calculation(i, tapering_curve, iterations)
            logger.debug(f"i: {i}, reduction: {reduction}")
            curve_val = (top_difference - reduction) * (i/iterations)
            sizeX = widthX - curve_val
            sizeY = heightY - curve_val
            sketch = cq.Sketch().rect(sizeX, sizeY).moved(z=i)
            if side_fillet > 0:
                sketch = sketch.vertices().fillet(side_fillet)
            sketchList.append(sketch)

        if not heightZ.is_integer(): # If heightZ is not an integer, we need to add the final sketch
            finalSketch = cq.Sketch().rect(top_lengthX, top_widthY).moved(z=heightZ)
            if side_fillet > 0:
                finalSketch = finalSketch.vertices().fillet(side_fillet)
            sketchList.append(finalSketch)

        logger.debug(sketchList)

        result = result.placeSketch(*sketchList)
        result = result.loft()

    # Create the dish cutter based on the dish_type    
    cutter = None
    adjusted_dimension = top_lengthX if widthX > heightY else top_widthY
    match dish_type:
        case "sphere":
            rad = (pow(adjusted_dimension, 2) + 4 * pow(dish_depth, 2)) / (8 * dish_depth) if dish_depth > 0 else 0
            cutter = (
                cq.Workplane("XY")
                .transformed(
                    offset=(top_x, top_y, rad * 2 + heightZ - dish_depth)
                )
                .sphere(rad*2)
            )

        case "cylinder":
            chord_length = (pow(adjusted_dimension, 2) - 4 * pow(dish_depth, 2)) / (8 * dish_depth) if dish_depth > 0 else 0
            rad = (pow(adjusted_dimension, 2) + 4 * pow(dish_depth, 2)) / (8 * dish_depth)
            cutter = (
                cq.Workplane("XY")
                .transformed(
                    rotate=(90+tiltCylinder, 0, 0),
                    offset=(top_x, top_y, chord_length + heightZ-0.5)
                )
                .cylinder(height=heightY *2 , radius=rad)
            )
        case "inv_pyramid":
            # TODO implement
            pass
        case None:
            pass
        case _:
            raise ValueError(f"Invalid dish_type: {dish_type}")


    stem = None
    stem_height = heightZ - dish_thickness - stem_inset
    logger.debug(f"stem_height: {stem_height}, heightZ: {heightZ}, dish_thickness: {dish_thickness}, stem_inset: {stem_inset}")
    if stem_height < cross_height:
        raise ValueError(f"Stem height is too small ({stem_height}) for the cross height desired. Consider increasing the keycap height or reducing the dish thickness.")
    
    match stem_type:
        case "box_cherry":
            stem = stem_box_cherry(
                    stem_inset=stem_inset,
                    stem_height= stem_height,
                    cross_height= cross_height,
                    inside_tolerance=stem_inside_tolerance
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
                widthX,
                heightY,
                boxHeight,
                centered=True
            ).translate((0, 0, boxPositionZ))

    if stem is not None:
        res = box.union(stem)

        # Create the outer box used for the negative
        outerBox  = cq.Workplane("XY").box(
            widthX*2,
            heightY*2,
            heightZ*2,
            centered=True
        )

        # Create the negative shape to remove excess material from the stem
        negativeShape = outerBox.cut(result)

        selector = upper_edge_fillet_selector(stem)
        # Apply fillet to the edges of the stem cut that are nearest to the top of the keycap
        res = (res.edges(selector).fillet(1))

        # Create stabilizer stems
        stabilizersPosList:list[tuple[float, float]] = []
        if widthU >= KeyUnit.U2 or heightU >= KeyUnit.U2:
            stabilizersPosList = stabilizer_stems_coords(widthU=widthU, heightU=heightU)
            for pos in stabilizersPosList:
                res = res.union(stem.translate(pos))
                selector = upper_edge_fillet_selector(stem.translate(pos))
                # Apply fillet
                res = (res.edges(selector).fillet(1))

        stem_cut = res.cut(negativeShape)

        # Create the internal cut
        result = result.faces("<Z").shell(wall_thickness, kind="arc")

        # Combine the keycap with the stem and box
        result = result.union(stem_cut)

        # Create the final result by cutting the dish from the keycap if a cutter was created
        result = result.cut(cutter) if cutter is not None else result

        # Apply the upper fillet to the upper edges of the keycap
        if upper_fillet > 0:
            result = result.edges(">Z").fillet(upper_fillet)
            stem_cut = stem_cut.edges(">Z").fillet(upper_fillet) # Also need here otherwise the top edges of the stem cut will protrude through the keycap

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