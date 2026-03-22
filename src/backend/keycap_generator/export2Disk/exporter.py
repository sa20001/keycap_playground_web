import cadquery as cq
from .preprocessing import convert
from ..utilities import MP_CONTEXT
from pathlib import Path
from loguru import logger
from functools import partial
import time
from typing import Any

def _exporter(keycapShapeAssemblyTuple:tuple[cq.Assembly, dict[str, Any]], preprocessing:bool, adaptiveLayerHeightConfig: dict[str, float] | None):
    keycapShapeAssembly, metadata = keycapShapeAssemblyTuple
    filePath = metadata["filePath"]
    path = Path(filePath).parent
    path.mkdir(parents=True, exist_ok=True)
    logger.debug(f"Save path: {filePath}")
    keycapShapeAssembly.export(f"{filePath}", exportType=cq.exporters.ExportTypes.STEP) # type:ignore

    if preprocessing:
        filePathObj = Path(filePath)
        convert(filePathObj, keycapShapeAssembly, adaptiveLayerHeightConfig)

    logger.debug(f"Exported keycap shape with legend to {filePath}")


def exportToDisk(keycapShapeAssemblyList:list[tuple[cq.Assembly, dict[str, Any]]], preprocessing:bool, adaptiveLayerHeightConfig: dict[str, float] | None):
     with MP_CONTEXT.Pool() as pool:
        export_start = time.perf_counter()
        worker = partial(
                    _exporter,
                    preprocessing=preprocessing,
                    adaptiveLayerHeightConfig=adaptiveLayerHeightConfig
                    )

        pool.map(worker, keycapShapeAssemblyList)
        export_end = time.perf_counter()
        logger.info(f"Keycap export completed in {(export_end-export_start):.4f} seconds.")
