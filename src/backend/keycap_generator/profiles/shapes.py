from .profiles import generate_keycap
from loguru import logger
from ..utilities import KeyUnit
from typing import Any
import time
import cadquery as cq
from copy import deepcopy

def shapeGenerator(
        job:dict[str, Any],
        profile:str,
        stemInsideTolerance:float,
        preprocessing:bool,
        keycapShapeCached:dict[str, tuple[cq.Assembly, float]] | None = None
        ):
    widthU: KeyUnit = job["widthU"]
    heightU: KeyUnit = job["heightU"]
    row = job["row"]

    logger.debug(f"Generating keycap shape for widthU: {widthU}, heightU; {heightU}, row: {row}")

    start = time.perf_counter()
    obj = None
    key = f"{profile}_{row}_{widthU.name}x{heightU.name}_{stemInsideTolerance}_{preprocessing}"

    obj = keycapShapeCached.get(key) if keycapShapeCached is not None else None

    if obj is None:
        logger.debug(f"Keycap shape not found in cache for key: {key}. Generating new shape.")
        obj = generate_keycap(
            key_profile=profile,
            row=row,
            widthU=widthU,
            heightU=heightU,
            stem_inside_tolerance=stemInsideTolerance,
            preprocessing=preprocessing
        )

        if keycapShapeCached is not None:
            keycapShapeCached[key] = deepcopy(obj)

    end = time.perf_counter()
    logger.debug(f"Generation completed in {(end-start):.4f} seconds.")

    key = f"{row}_{widthU.name}x{heightU.name}"
    return key, obj, keycapShapeCached