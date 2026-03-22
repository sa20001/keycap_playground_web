from loguru import logger
from ..shapes import poly_keycap, iso_enter_solid
from ..utilities import KeyUnit

# TODO https://www.reddit.com/media?url=https%3A%2F%2Fpreview.redd.it%2Fhelp-looking-to-splurge-on-some-keycaps-learning-about-v0-dz0ngk3ct5d51.jpg%3Fauto%3Dwebp%26s%3Dba3d4702c5388b904b9faeb9a7410d3d67ab40df
# TODO https://keyreative.store/cdn/shop/files/KAT-KAM-CHERRY-01.webp?v=1716530119&width=2000

# CONSTANTS
DEFAULT_THICKNESS = -1.35; # Default wall thickness for keycaps (in mm), negative since used by shell operation
def generate_keycap(
        key_profile: str,
        widthU:KeyUnit,
        heightU:KeyUnit,
        stem_inside_tolerance:float,
        row: int,
        preprocessing: bool,
        height_extra: float = 0,
        wall_thickness: float = DEFAULT_THICKNESS,
        dish_depth: float = .8,
        dish_invert: bool = False,
        top_difference: float = 6.08,
        homing_dot: bool = False
):

    # TODO: revamp (or define new function) so that we can pass a dictionary with all the keys and that is the set that will use a defined profile
    
    # TODO: homing dot should be added at a later stage-> first generate shape then add legends and then add homing dot (if any)

    # Some defaults
    side_fillet:float = 2.0
    upper_fillet: float = 0.5
    stem_inset: float = 0
    dish_thickness: float = 3
    cross_height:float = 4.0



    if wall_thickness >= 0:
        logger.warning(f"Wall thickness illegal value: {wall_thickness}.  Using default thickness {DEFAULT_THICKNESS}.")
        wall_thickness = DEFAULT_THICKNESS

    # TODO Fix profiles using https://keyreative.store/cdn/shop/files/KAT-KAM-CHERRY-01.webp?v=1716530119&width=2000

    match key_profile:
        case "dsa":
            logger.debug("Generating DSA profile keycap")
            # NOTE: Measured dish_depth in multiple DSA keycaps came out to ~.8
            # NOTE: Spec says wall_thickness should be 1mm but the default here is 1.35 since this script will mostly be used in 3D printing.  Make sure to set it to 1mm if making an injection mold.

            # NOTE: The 0-index values are ignored (there's no row 0 in DSA)
            row_height = 7.3914
            key_height = row_height - 1 if dish_invert else row_height; # One less if we're generating a spacebar
            # NOTE: 7.3914 is from the Signature Plastics DSA spec which has .291 inches

            if (row != 1):
                logger.warning("Only row 1 is supported for DSA profile caps.")
            
            # width = 18.41; // 0.725 inches

            dish_z = 0.111; # NOTE: Width of the top dish (at widest) should be ~12.7mm
            keyHeight  = key_height + height_extra
            return (poly_keycap(
                        dish_type = "sphere",
                        heightZ=keyHeight,
                        widthU=widthU,
                        heightU=heightU,
                        wall_thickness=wall_thickness,
                        top_difference=top_difference,
                        # dish_invert=dish_invert,
                        dish_depth=dish_depth+dish_z,
                        dish_thickness=dish_thickness,
                        # TODO side and top fillets
                        # stem_clips=stem_clips,
                        # stem_walls_inset=stem_walls_inset,
                        tapering_curve=4.5,
                        side_fillet=side_fillet,
                        upper_fillet=upper_fillet,
                        stem_inside_tolerance=stem_inside_tolerance,
                        stem_inset=stem_inset,
                        cross_height = cross_height,
                        preprocessing=preprocessing
                        ),
                        keyHeight)
        
        case "dcs":
            logger.debug("Generating DCS profile keycap")
            # NOTE: dish_thickness gets *added* to the default thickness of this profile which is approximately 1mm (depending on the keycap). This is to prevent a low dish_thickness value from making an unusable keycap
            # NOTE: The 0-index values are ignored (there's no row 0 in DCS)
            row_height = [0.0, 9.5, 7.39, 7.39, 9.0, 12.5]
            dish_tilt = [0, -1, 3, 7, 16, -6]
            # Dish needs to cut into the top a unique amount depending on the height and angle
            dish_z = [0.0, -0.11, -0.38, -0.78, 0.6, -0.75]
            dish_thicknesses = [0.0, 1.2, 1.6, 2.0, 3.0, 2.0]

            adjusted_dish_thickness = dish_thicknesses[row] + dish_thickness
            
            if (row < 1):
                logger.warning("We only support rows 1-5 for DCS profile caps!")
        
            row = row if row < 6 else 5 # We only support rows 0-4 (5 total rows)
            dish_type = "cylinder"
            dish_depth = 1
            top_y = -1.75
            logger.debug(f"Generating DCS keycap for row {row} with dish_depth={dish_depth}, dish_tilt={dish_tilt[row]}, dish_z={dish_z[row]}, top_y={top_y}, dish_type={dish_type}, dish_thickness={adjusted_dish_thickness}")
            keyHeight = row_height[row] + height_extra
            return (poly_keycap(
                        heightZ=keyHeight,
                        widthU=widthU,
                        heightU=heightU,
                        wall_thickness=wall_thickness,
                        top_difference=top_difference,
                        tiltCylinder=dish_tilt[row],
                        xy_offset=(0, top_y),
                        dish_depth=dish_depth+dish_z[row],
                        dish_type=dish_type,
                        # stem_clips=stem_clips,
                        # stem_walls_inset=stem_walls_inset,
                        dish_thickness=adjusted_dish_thickness,
                        # dish_invert=dish_invert,
                        side_fillet=side_fillet,
                        upper_fillet=upper_fillet,
                        stem_inside_tolerance=stem_inside_tolerance,
                        cross_height = cross_height,
                        stem_inset=stem_inset,
                        preprocessing=preprocessing
                        ),
                        keyHeight)

        case "dss":
            logger.debug("Generating DSS profile keycap")
            # NOTE: The 0-index values are ignored (there's no row 0 in DSS)
            row_height = [0.0, 10.4, 8.7, 8.5, 10.6]
            adjusted_row_height = row_height[row] - 1 if dish_invert else row_height[row]; # One less if we're generating a spacebar (which is always row 3 with DSS)
            dish_tilt = [0, -1, 3, 8, 16] # TODO Implement
            # Dish needs to cut into the top a unique amount depending on the height and angle
            dish_y = [0.0, 1.2, -2.5, -5.7, -11.4]
            # Dish needs to cut into the top a unique amount depending on the height and angle
            dish_z = [0.0, 0.0, 0.0, 0.0, -1.1]
            dish_thicknesses = [0.0, 2.5, 2.5, 2.5, 3.5]
            if (row < 1):
                logger.warning("We only support rows 1-4 for DSS profile caps!")
            
            row = row if row < 5 else 4; # We only support rows 1-4 (4 total rows)
            dish_type = "sphere"
            dish_depth = 1
            keyHeight = adjusted_row_height + height_extra
            return (poly_keycap(
                        heightZ=keyHeight,
                        widthU=widthU,
                        heightU=heightU,
                        wall_thickness=wall_thickness,
                        top_difference=top_difference,
                        # dish_tilt=dish_tilt[row],
                        # dish_y=dish_y[row],
                        xy_offset=(0, dish_y[row]),
                        dish_depth=dish_depth+dish_z[row],
                        dish_type=dish_type,
                        # stem_clips=stem_clips,
                        # stem_walls_inset=stem_walls_inset,
                        dish_thickness=dish_thicknesses[row],
                        # dish_invert=dish_invert,
                        tapering_curve=4,
                        side_fillet=side_fillet,
                        upper_fillet=upper_fillet,
                        stem_inside_tolerance=stem_inside_tolerance,
                        cross_height = cross_height,
                        stem_inset=stem_inset,
                        preprocessing=preprocessing
                        ),
                        keyHeight)
        
        case "kat":
            logger.debug("Generating KAT profile keycap")
            # NOTE So here's the deal with the KAT profile:  The *dishes* are accurately-placed but the curve that goes up the side of the keycap (front and back) isn't *quite* right because whoever modeled the KAT profile probably started with DSA and then extruded/moved things up/down and forwards/backwards a bit until they had what they wanted.  This makes generating these keycaps via an algorithm difficult.  Having said that the curve is quite close to the original and you'd have to look *very* closely to be able to tell the difference in real life.  As long as the dishes are in the right place that's what matters most.
            
            # FYI: I know that the curve up the side of the keycap is a little off...  If anyone knows how to calculate the correct curve for KAT profile let me know and I'll fix it!
            if (row < 1 or row > 5):
                logger.warning("We only support rows 1-5 for KAT profile caps!")

            # NOTE: KAT profile actually mandates 1.658mm wall thickness but I'm not going to force the user to use that
            # NOTE: The 0-index values are ignored (there's no row 0 in KAT)
            row_height = [0.0, 10.95, 9.15, 10.9, 11.9, 13.8]; #  R1     R2    R3    R4    R5
            dish_tilt = [0.0, -5.0, -0.5, 4.5, 1.95, 7.5]
            dish_y = [0.0, 4.0, 0.25, -3.75, -1.65, -6.0]
            top_y = [0.0, 0.75, 0.75, 0.75, 0.65, 0.0]
            dish_z = [0.0, -0.25, 0.0, -0.25, -0.25, -0.5]

            # Official KAT keycaps have a cylindrical dish when inverted:
            dish_type = "cylinder" if dish_invert else "sphere"
            keyHeight = row_height[row] + height_extra
            return (poly_keycap(
                        heightZ=keyHeight,
                        widthU=widthU,
                        heightU=heightU,
                        wall_thickness=wall_thickness,
                        top_difference=top_difference,
                        tiltCylinder=dish_tilt[row],
                        # dish_y=dish_y[row],
                        # dish_invert=dish_invert,
                        xy_offset=(0, top_y[row]),
                        dish_depth=dish_depth+dish_z[row],
                        dish_type=dish_type,
                        dish_thickness=dish_thickness,
                        # stem_clips=stem_clips,
                        # stem_walls_inset=stem_walls_inset,
                        tapering_curve=7,
                        side_fillet=side_fillet,
                        upper_fillet=upper_fillet,
                        stem_inside_tolerance=stem_inside_tolerance,
                        cross_height = cross_height,
                        stem_inset=stem_inset,
                        preprocessing=preprocessing
                        ),
                        keyHeight)

        case "kam":
            logger.debug("Generating KAM profile keycap")
            row_height = 8.05 if dish_invert else 9.05; # One less if we're generating a spacebar
            if (row != 1):
                logger.warning("Only row 1 is supported for KAM profile caps.")
            
            dish_type = "cylinder" if dish_invert else "sphere" # KAM spacebars actually use cylindrical tops
            keyHeight = row_height + height_extra
            return (poly_keycap(
                        heightZ=keyHeight,
                        widthU=widthU,
                        heightU=heightU,
                        wall_thickness=wall_thickness,
                        top_difference=top_difference,
                        # dish_invert=dish_invert,
                        dish_depth=dish_depth,
                        dish_type=dish_type,
                        dish_thickness=dish_thickness,
                        # stem_clips=stem_clips,
                        # stem_walls_inset=stem_walls_inset,
                        tapering_curve=4.5,
                        side_fillet=side_fillet,
                        upper_fillet=upper_fillet,
                        stem_inside_tolerance=stem_inside_tolerance,
                        cross_height = cross_height,
                        stem_inset=stem_inset,
                        preprocessing=preprocessing
                        ),
                        keyHeight)


        case "xda":
            logger.debug("Generating XDA profile keycap")
            # NOTE: The 0-index values are ignored (there's no row 0 in XDA)
            row_height = 8.1 if dish_invert else 9.1; # One less if we're generating a spacebar
            if (row != 1):
                logger.warning("Only row 1 is supported for XDA profile caps.")

            dish_type = "sphere"
            keyHeight = row_height + height_extra
            return (poly_keycap(
                        heightZ=keyHeight,
                        widthU=widthU,
                        heightU=heightU,
                        wall_thickness=wall_thickness,
                        top_difference=top_difference,
                        # dish_invert=dish_invert,
                        dish_depth=dish_depth,
                        dish_type=dish_type,
                        dish_thickness=dish_thickness,
                        # stem_clips=stem_clips, stem_walls_inset=stem_walls_inset,
                        tapering_curve=5,
                        side_fillet=side_fillet,
                        upper_fillet=upper_fillet,
                        stem_inside_tolerance=stem_inside_tolerance,
                        cross_height = cross_height,
                        stem_inset=stem_inset,
                        preprocessing=preprocessing
                        ),
                        keyHeight)

        case "think":
            logger.debug("Generating Think profile keycap")
            # NOTE: The 0-index values are ignored (there's no row 0 in XDA)
            row_height = 6.5
            if (row != 1):
                logger.warning("Only row 1 is supported for think profile caps.")

            dish_type = None
            side_fillet = 2
            upper_fillet = 1.5
            dish_thickness = 1.0
            stem_inset= 1
            keyHeight = row_height + height_extra
            cross_height = 4.5
            xy_offset = (0, 1.5)
            if widthU == KeyUnit.ISO_ENTER:
                return (iso_enter_solid(
                    top_difference=top_difference,
                    heightZ=keyHeight,
                    side_fillet=side_fillet,
                    xy_offset=xy_offset,
                    upper_fillet=upper_fillet,
                    wall_thickness=wall_thickness,
                    dish_thickness=dish_thickness,
                    stem_inside_tolerance=stem_inside_tolerance,
                    cross_height=cross_height,
                    stem_inset=stem_inset,
                    preprocessing=preprocessing
                ),
                keyHeight)

            else:
                return (poly_keycap(
                        heightZ=keyHeight,
                        widthU=widthU,
                        heightU=heightU,
                        wall_thickness=wall_thickness,
                        top_difference=top_difference,
                        dish_type=dish_type,
                        dish_thickness=dish_thickness,
                        side_fillet=side_fillet,
                        xy_offset=xy_offset,
                        upper_fillet=upper_fillet,
                        stem_inset=stem_inset,
                        cross_height = cross_height,
                        stem_inside_tolerance=stem_inside_tolerance,
                        preprocessing=preprocessing
                        ),
                        keyHeight)
            
        # case "":
        #     logger.debug("Using user defined parameters")
        #     # TODO: add support for user defined geometry
        case _:
            raise ValueError(f"Key profile not recognized: {key_profile}")


