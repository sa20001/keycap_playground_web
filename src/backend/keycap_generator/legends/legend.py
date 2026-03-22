import cadquery as cq
from typing import Any, cast, Literal
from loguru import logger

def _draw_legend(legend:str, font_size:float, fontPath:str, height:float, halign:Literal['center', 'left', 'right'], valign:Literal['center', 'top', 'bottom']):
    """
    Create an extruded legend.
    """

    logger.debug(f"Drawing legend: {legend} with font path: {fontPath}, font_size: {font_size}, height: {height}")

    return (
        cq.Workplane("XY")
        .text(
            legend,
            fontsize=font_size,
            fontPath=fontPath,
            halign=halign,
            valign=valign,
            distance=height
        )
    )

def generate_legends(height:float, legend_list:list[dict[str, Any]]
):
    """
    Generate all the legends for a keycap based on the provided legend_list.

    legend_list format:
    [
        [
            legend-> can be str or tuple[cadquery.Workplane, str] (for custom shapes)
            fontPath,
            font_size,
            trans,
            rotation,
        ],
        ...
    ]
    """

    result = None
    for l in legend_list:
        legend = l["legend"]
        fontPath = l["fontPath"]
        font_size = l["font_size"]
        halign = l["halign"]
        valign = l["valign"]

        trans = l["trans"]
        rotation = l["rotation"]
        
        if type(legend) is str:

            if legend == "":
                continue

            obj = _draw_legend(
                legend,
                font_size,
                fontPath,
                height,
                halign,
                valign
            )
            
        elif isinstance(legend, tuple) and len(legend) == 2 and isinstance(legend[0], cq.Workplane) and isinstance(legend[1], str): # type:ignore
            shapes = legend[0].vals()
            shapes = cast(list[cq.Shape], shapes)
            bbox = cq.Compound.makeCompound(shapes).BoundingBox()
            cx = (bbox.xmin + bbox.xmax) / 2
            cy = (bbox.ymin + bbox.ymax) / 2
            scaled_shape:list[cq.Shape] = []
            for shape in shapes:
                shape = shape.translate((-cx, -cy, 0))
                shape = shape.scale(font_size)
                scaled_shape.append(shape)

            obj = (
                cq.Workplane("XY")
                .newObject(scaled_shape)
                .wires()
                .toPending()
                .extrude(height)
            )
        else:
            raise ValueError(f"Invalid legend type: {type(legend)}. Expected str or tuple[cadquery.Workplane, str].") # type:ignore

        obj = obj.rotate( # x axis
            (0, 0, 0),
            (1, 0, 0),
            rotation[0]
        )
        obj = obj.rotate( # y axis
            (0, 0, 0),
            (0, 1, 0),
            rotation[1]
        )
        obj = obj.rotate( # z axis
            (0, 0, 0),
            (0, 0, 1),
            rotation[2]
        )

        obj = obj.translate(trans)

        if result is None:
            result = obj
        else:
            result = result.union(obj)

    return result

# Usage example:
# res = generate_legends(
#     0.5,
#     [
#         {
#             "legend": "1",
#             "font": "Arial",
#             "font_size": 3,
#             "trans": (0, 0, 0),
#             "rotation": (0, 0, 0),
#         },
#         {
#             "legend": "!",
#             "font": "Arial",
#             "font_size": 3,
#             "trans": (0, 2.5, 0),
#             "rotation": (0, 0, 0),
#         }
#     ]
# )
