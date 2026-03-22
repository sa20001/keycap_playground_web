from enum import Enum
from matplotlib import font_manager
from pathlib import Path
from loguru import logger
from typing import Any
import cadquery as cq
from copy import deepcopy
import time

class KeyUnit(float, Enum):
    U1 = 1.0
    U125 = 1.25
    U15 = 1.5
    U175 = 1.75
    U2 = 2.0
    U225 = 2.25
    U275 = 2.75
    U6 = 6.0
    U625 = 6.25
    U7 = 7.0
    # For iso enter use negative value to avoid confusion with other key units
    ISO_ENTER = -1.25
    ISO_ENTER_SKINNY = -1.0

SPECIAL_CHARS = {
    "\\": "BACKSLASH",
    "|": "PIPE",
    "/": "SLASH",
    ":": "COLON",
    "*": "ASTERISK",
    "?": "QUESTION_MARK",
    '"': "QUOTE",
    "<": "LESS_THAN",
    ">": "GREATER_THAN",
    " ": "SPACE",
    "_": "UNDERSCORE",
    "\n" : "",
    "\r" : "",
    "\t" : "",
}

def keyToFilename(key: list[str]) -> str:
    parts:list[str] = []

    if len(key) == 0:
        return "blank"

    for string in key:
        string = string[1] if isinstance(string, tuple) else string

        for char in string:
            parts.append(SPECIAL_CHARS.get(char, char))

    return "".join(parts)

class Tasks(str, Enum):
    """
    Different keycap generation tasks.

    - CARVED: Generate keycaps with recessed (engraved) legends.
    - MULTI: Generate keycaps with legends in a different color for multicolor printing.
    - EMBOSSED: Generate keycaps with raised legends.
    """

    CARVED = "carved"
    MULTI = "multi"
    EMBOSSED = "embossed"

def checkForFont(templatePath:str, font:str) -> str | None:
    # Check if font is a path, if yes load it, if not check if font is installed in the system, if not raise an error 
    try:

        # Check if the font is a valid path
        fontPathCheck = Path(templatePath).joinpath(font)
        fontPath = str(fontPathCheck)
        exists = fontPathCheck.exists()

        if not exists:
            fontPath = str(font_manager.findfont(font, fallback_to_default=False)) #type: ignore

        logger.debug(f"Font available at: {fontPath}")
    except ValueError:
        logger.error(f"Font '{font}' not found. Please ensure the font is installed and available in the system.")
        return None

    return fontPath

def fontLayerManipulation(layer:dict[str, Any] | None, rowFontSize:float ):
    font_size = rowFontSize
    defTuple = (0.0, 0.0, 0.0)
    defHalign = "center"
    defValign = "center"
    font_translation = defTuple
    font_rotation = defTuple
    halign = defHalign
    valign = defValign
    
    if layer is not None:
        font_size = layer.get('font_size', rowFontSize)

        halign:str = layer.get('halign', defHalign)
        valign:str = layer.get('valign', defValign)

        trans:dict[str, Any] | tuple[float, float, float] = layer.get('translation', defTuple)
        if isinstance(trans, dict):
            font_translation = (
                float(trans.get("x", 0.0)),
                float(trans.get("y", 0.0)),
                float(trans.get("z", 0.0))
            )

        rot:dict[str, Any] | tuple[float, float, float] = layer.get('rotation', defTuple)
        if isinstance(rot, dict):
            font_rotation = (
                rot.get("x", 0.0),
                rot.get("y", 0.0),
                rot.get("z", 0.0)
            )
    return font_size, font_translation, font_rotation, halign, valign


def getKeycapsToExport(
    keycapJobsGeneratedCached:list[tuple[cq.Assembly, dict[str, Any]]] | None,
    keycapTasks:list[Tasks],
    result:tuple[list[tuple[cq.Assembly, dict[str, Any]]], list[dict[str, Any]]]
):
    '''
    This function retrieves the keycaps to be exported based on the provided tasks and the generated results.
    It checks the cached generated keycap jobs and filters them based on the specified tasks.
    If there are no cached jobs, it returns the newly generated keycaps from the result.

    Returns:
    - (deepcopy) a list of tuples containing the keycap assembly and its associated metadata for export.

    '''
    
    newlyGenerated = result[0]
    exportResult = newlyGenerated.copy()
    keycapsAlreadyGeneratedJobs = result[1]
    start = time.perf_counter()

    if keycapJobsGeneratedCached is not None:

        # Get from cache all they keys that match the tasks required
        for task in keycapTasks:
            # Filter by task
            taskValue = task.value
            filteredCache = [x for x in keycapJobsGeneratedCached if x[1]["task"] == taskValue]

            # Get generated keycaps that are already cached, by matching primaryKey and hash
            cached = {
                job[1]["primaryKey"]: job[1]["hash"]
                for job in filteredCache
            }

            # Get the jobs that are already generated and cached, by matching primaryKey and hash
            keyCapsFromCacheJobs = [
                job
                for job in keycapsAlreadyGeneratedJobs
                if cached.get(job["primaryKey"]) == job["hash"]
            ]

            # Add the cached jobs to the visualizeResult
            for job in keyCapsFromCacheJobs:
                primaryKey = job["primaryKey"]  
                hash = job["hash"]

                for filtered in filteredCache:
                    assy = filtered[0]
                    metadata = filtered[1]

                    if metadata["primaryKey"] == primaryKey and metadata["hash"] == hash:
                        exportResult.append((assy, metadata))
                        break

    logger.info(f"Retrieved cache in {time.perf_counter() - start:.4f} seconds. Total keycaps to export: {len(exportResult)}")
    exportResult = deepcopy(exportResult) # deepcopy to avoid modifying the original list from now on
    logger.info(f"Retrieved cache in {time.perf_counter() - start:.4f} seconds. Total keycaps to export: {len(exportResult)}")

    for single in exportResult:
        assy = single[0]
        metadata = single[1]
        logger.debug(f"Visualizing keycap with metadata: {metadata}")

    return exportResult