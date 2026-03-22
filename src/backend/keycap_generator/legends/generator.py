from loguru import logger
from pathlib import Path
import subprocess
import cadquery as cq
from typing import Any, cast
from ..utilities import KEY_UNIT, checkForFont

def convert_svg_to_dxf(svg_path: Path) -> Path:
    dxf_path = svg_path.with_suffix(".dxf")
    eps_path = svg_path.with_suffix(".eps")

    if (
        dxf_path.exists()
    ):
        return dxf_path

    logger.debug(f"Converting SVG to DXF: {svg_path} -> {dxf_path}")
    # The process is SVG -> EPS and then EPS -> DXF. Credits to https://github.com/winder/svgToDxf/blob/master/svgToDxf.sh
    
    # SVG -> EPS
    subprocess.run(
        [
            "inkscape",
            "--export-ps-level=3",
            "--export-filename",
            str(eps_path),
            str(svg_path),
        ],
        check=True,
    )

    try:
        # EPS -> DXF
        subprocess.run(
            [
                "pstoedit",
                "-dt",
                "-f",
                "dxf:-polyaslines -mm",
                str(eps_path),
                str(dxf_path),
            ],
            check=True,
        )
    finally:
        eps_path.unlink(missing_ok=True)

    return dxf_path

def load_vector_legend(
    legend_path:Path
) -> cq.Workplane | None:

    suffix = legend_path.suffix.lower()

    match suffix:
        case ".dxf":
            pass

        case ".svg":
            legend_path = convert_svg_to_dxf(legend_path)

        case _:
            # If other file, ignore
            return None

    legend =  cq.importers.importDXF(str(legend_path))

    shapes = legend.vals()
    shapes = cast(list[cq.Shape], shapes)
    bbox = cq.Compound.makeCompound(shapes).BoundingBox()
    cx = (bbox.xmin + bbox.xmax) / 2
    cy = (bbox.ymin + bbox.ymax) / 2
    logger.debug(f"Center cx: {cx}, cy: {cy}")
    sx = bbox.xmax - bbox.xmin
    sy = bbox.ymax - bbox.ymin
    logger.debug(f"Size sx: {sx}, sy: {sy}")
    scaled_shape:list[cq.Shape] = []
    for shape in shapes:
        shape = shape.translate((-cx, -cy, 0))
        biggerSide = max(sx, sy)
        scaleFactor = (KEY_UNIT/2) / biggerSide
        logger.debug(f"Scaling shape {legend_path.name} by factor {scaleFactor}")
        shape = shape.scale(scaleFactor)
        scaled_shape.append(shape)

    legend = (
        cq.Workplane("XY")
        .newObject(scaled_shape)
    )

    return legend

def legendListGenerator(
        legend:str | dict[str, Any],
        fontPath:str,
        font_size:float,
        trans:tuple[float, float, float],
        rot:tuple[float, float, float],
        halign:str,
        valign:str,
        templatePath:str
        ):

    retLegend:str | tuple[cq.Workplane, str]
    if isinstance(legend, str):
        logger.debug(f"Legend is a string: {legend}")
        retLegend = legend

    else: # we have override
        logger.debug(f"Legend is a dict with override: {legend}")
        retLegend = cast(str, legend["value"])
        override:dict[str, Any] = legend["override"]
        transOverride:dict[str, Any] | None = override.get("translation", None)
        if transOverride is not None:
            trans = (
                transOverride.get("x", trans[0]),
                transOverride.get("y", trans[1]),
                transOverride.get("z", trans[2])
                )
        rotOverride:dict[str, Any] | None = override.get("rotation", None)
        if rotOverride is not None:
            rot = (
                rotOverride.get("x", rot[0]),
                rotOverride.get("y", rot[1]),
                rotOverride.get("z", rot[2])
            )
        halignOverride:str | None = override.get("halign", None)
        if halignOverride is not None:
            halign = halignOverride
        valignOverride:str | None = override.get("valign", None)
        if valignOverride is not None:
            valign = valignOverride
        fontOverride = override.get("font", None)
        if fontOverride is not None:
            res = checkForFont(templatePath, fontOverride)  # Check if the font is available
            if res is None: # font not available raise an error
                logger.warning(f"Font override'{fontOverride}' not found. Using default font '{fontPath}' instead.")
            else:
                logger.info(f"Font override'{fontOverride}' found.")
                fontPath = res

        fontSizeOverride = override.get("font_size", None)
        if fontSizeOverride is not None:
            font_size = fontSizeOverride

    vectorLegendPathString = f"{templatePath}/{retLegend}"
    vectorLegendPath = Path(vectorLegendPathString)
    exists = Path(vectorLegendPath).exists()
    if exists:
        loadedVectorLegend = load_vector_legend(vectorLegendPath)
        if loadedVectorLegend is not None:
            logger.debug(f"Legend file {vectorLegendPath} exists.")
            retLegend = loadedVectorLegend, retLegend
 
    x:dict[str, Any]  = {
                "legend": retLegend,
                "fontPath": fontPath,
                "font_size": font_size,
                "trans": trans,
                "rotation": rot,
                "halign": halign,
                "valign": valign
            }
    return x