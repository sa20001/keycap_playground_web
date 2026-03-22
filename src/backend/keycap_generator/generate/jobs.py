from typing import Any, cast
from ..utilities import KeyUnit, checkForFont, fontLayerManipulation, Tasks, JSON_TEMPLATE_KEYS
from ..legends import legendListGenerator
from loguru import logger
import json
import hashlib
import cadquery as cq
from pathlib import Path
from copy import deepcopy # TODO probablly list.copy() is enough, check
from ..visualize import layoutOrdering

def validateDictionary(dictInput:dict[str, Any]):
    dictKeys = list(dictInput.keys())
    for key in dictKeys:
        if key not in JSON_TEMPLATE_KEYS:
            errorStr = f"Unexpected key '{key}' found in dictionary. Expected keys are: {JSON_TEMPLATE_KEYS}"
            logger.error(errorStr)
            raise ValueError(errorStr)

        if isinstance(dictInput[key], dict):
            validateDictionary(dictInput[key])  # Recursive call for nested dictionaries

        elif isinstance(dictInput[key], list):
            for item in dictInput[key]:
                if isinstance(item, dict):
                    item = cast(dict[str, Any], item)  # for pylance
                    validateDictionary(item)  # Recursive call for dictionaries within lists
                else:
                    continue  # If the item is not a dictionary, we skip it

        else:
            continue

def create_jobs(
        templatePath:str,
        keycapTasks:list[Tasks],
        visualization:bool,
        keycapJobsCached:list[dict[str, Any]] | None,
        stemInsideTolerance:float,
        legendHeight:float
        ):

    try:
        with open(f"{templatePath}/template.json", "r", encoding="utf-8") as f:
            templateJSON = json.load(f)
    except Exception as e:
        logger.error(f"Failed to load template JSON from {templatePath}: {e}")
        raise
    logger.trace(f"Loaded template JSON: {templateJSON}")

    templateJSON = cast(dict[str, Any], templateJSON)

    # Validate the template
    validateDictionary(templateJSON)

    profile = templateJSON["profile"]
    layout = templateJSON["layout"]
    font:str = templateJSON["font"]
    fontPath:str = font
    res = checkForFont(templatePath, font)  # Check if the font is available
    if res is None: #Ff font not available raise an error
        raise ValueError(f"Font '{font}' not found. Please ensure the font is installed and available in the system.")
    else:
        fontPath = res

    font_size = templateJSON["font_size"]
    rows = templateJSON["rows"]

    keycapShapesJobs:list[dict[str, Any]] = []
    keycapJobsAll:list[dict[str, Any]] = [] # All jobs requested to be generated
    constructionList:list[list[dict[str, Any]]] = []

    # Generate the keycap jobs for every row
    for row in rows:
        logger.debug(f"Row: {row['row']}")
        row = cast(dict[str, Any], row)  # Type hinting for better clarity
        rowFont:str = row.get("font", font)
        rowFontSize:float = row.get("font_size", font_size)
        job_row = row['row']
        rowFontPath = fontPath

        res = checkForFont(templatePath, rowFont)  # Check if the font is available
        if res is None: #Ff font not available raise an error
            logger.warning(f"Font '{rowFont}' not found. Using default font '{font}' instead.")
        else:
            logger.info(f"Font '{rowFont}' found. Using it for row {row['row']}.")
            rowFontPath = res

        for unit in row["units"]:

            unit = cast(dict[str, Any], unit)  # Type hinting for better clarity

            # Generate the keycap shape job
            job_w_unit = unit['widthUnit']
            job_h_unit = unit.get('heightUnit', KeyUnit.U1.name)
            logger.debug(f"Width unit: {job_w_unit}, Height unit: {job_h_unit}, Row: {job_row}")
            job:dict[str, Any] = {
                "widthU": KeyUnit[job_w_unit],
                "heightU": KeyUnit[job_h_unit],
                "row": job_row
            }
            keycapShapesJobs.append(job)
            
            # Generate the keycap legend job
            base_layer:dict[str, Any] | None = unit.get('base_layer', None)
            (
                base_layer_font_size,
                base_layer_font_translation,
                base_layer_font_rotation,
                base_layer_halign,
                base_layer_valign
                ) = fontLayerManipulation(base_layer, rowFontSize)
        

            shift_layer:dict[str, Any] | None = unit.get('shift_layer', None)
            (
                shift_layer_font_size,
                shift_layer_font_translation,
                shift_layer_font_rotation,
                shift_layer_halign,
                shift_layer_valign
                ) = fontLayerManipulation(shift_layer, rowFontSize)

            altgr_layer:dict[str, Any] | None = unit.get('altgr_layer', None)
            (
                altgr_layer_font_size,
                altgr_layer_font_translation,
                altgr_layer_font_rotation,
                altgr_layer_halign,
                altgr_layer_valign
                ) = fontLayerManipulation(altgr_layer, rowFontSize)

            shift_altrgr_layer:dict[str, Any] | None = unit.get('shift_altgr_layer', None)
            (
                shift_altrgr_layer_font_size,
                shift_altrgr_layer_font_translation,
                shift_altrgr_layer_font_rotation,
                shift_altrgr_layer_halign,
                shift_altrgr_layer_valign
                ) = fontLayerManipulation(shift_altrgr_layer, rowFontSize)
            
            for key in unit["keys"]:
                key = cast(dict[str, Any], key)

                legendList:list[dict[str, Any]] = []
                base = key.get("base", None)
                logger.trace(f"Base legend: {base}")
                if base is not None:
                    legendList.append(legendListGenerator(
                        legend=base,
                        fontPath=rowFontPath,
                        font_size=base_layer_font_size,
                        trans=base_layer_font_translation,
                        rot=base_layer_font_rotation,
                        templatePath=templatePath,
                        halign=base_layer_halign,
                        valign=base_layer_valign
                        )
                    )

                shift = key.get("shift", None)
                logger.trace(f"Shift legend: {shift}")
                if shift is not None:
                    legendList.append(legendListGenerator(
                        legend=shift,
                        fontPath=rowFontPath,
                        font_size=shift_layer_font_size,
                        trans=shift_layer_font_translation,
                        rot=shift_layer_font_rotation,
                        templatePath=templatePath,
                        halign=shift_layer_halign,
                        valign=shift_layer_valign
                        )
                    )

                altgr = key.get("altgr", None)
                logger.trace(f"AltGr legend: {altgr}")
                if altgr is not None:
                    legendList.append(legendListGenerator(
                        legend=altgr,
                        fontPath=rowFontPath,
                        font_size=altgr_layer_font_size,
                        trans=altgr_layer_font_translation,
                        rot=altgr_layer_font_rotation,
                        templatePath=templatePath,
                        halign=altgr_layer_halign,
                        valign=altgr_layer_valign
                        )
                    )

                shift_altgr = key.get("shift_altgr", None)
                logger.trace(f"Shift+AltGr legend: {shift_altgr}")
                if shift_altgr is not None:
                    legendList.append(legendListGenerator(
                        legend=shift_altgr,
                        fontPath=rowFontPath,
                        font_size=shift_altrgr_layer_font_size,
                        trans=shift_altrgr_layer_font_translation,
                        rot=shift_altrgr_layer_font_rotation,
                        templatePath=templatePath,
                        halign=shift_altrgr_layer_halign,
                        valign=shift_altrgr_layer_valign
                        )
                    )

                row_index:int = key["row_index"]
                spillRow: int = key.get("spillRow", [job_row])
                # spillRow[0] optional row occupied by the key in addition to its starting row.
                # For example, ISO Enter starts in row 3 but extends into row 4;
                # numpad + starts in row 3 but extends into row 4;
                # numpad Enter starts in row 6 but extends into row 5.
                # spillRow[1] position of the key in the extended row.

                # Create the hash
                logger.debug(f"Retrieving elements for hashing")
                keycapShape = f"{job_row}_{job_w_unit}x{job_h_unit}"

                legendListToHash:list[dict[str, Any]] = []
                for legendDict in legendList:
                    legend = legendDict["legend"]
                    if isinstance(legend, str):
                        legendListToHash.append(legendDict)
                    else:
                        legend, filePath = cast(tuple[cq.Workplane, str], legend)  # Type hinting for better clarity
                        filePath = Path(templatePath) / filePath
                        with open(filePath, "rb") as f:
                            geometry_hash = hashlib.md5(f.read()).hexdigest()
                            legendDictTemp = deepcopy(legendDict)
                            legendDictTemp["legend"] = (geometry_hash, filePath.name)
                            legendListToHash.append(legendDictTemp)

                x:list[dict[str, Any]] = []
                for task in keycapTasks:
                    taskValue = task.value
                    primaryKey = f"{job_row}_{row_index}_{taskValue}"
                    toHash = f"{primaryKey}_{spillRow}_{keycapShape}_{legendListToHash}_{stemInsideTolerance}_{legendHeight}"
                    hash = hashlib.md5(toHash.encode()).hexdigest()

                    logger.debug(f"PrimaryKey: {primaryKey}")
                    logger.debug(f"Generated hash for keycap job: {hash} from string: {toHash}")


                    keycapJob:dict[str, Any] = {
                        "keycapShape" : keycapShape,
                        "legend_list" : legendList,
                        "row" : job_row,
                        "unit": job_w_unit,
                        "row_index" : row_index,
                        "spillRow" : spillRow,
                        "hash" : hash,
                        "primaryKey" : primaryKey,
                        "taskValue" : taskValue
                    }
                    x.append(keycapJob)

                constructionList.append(x)


    if visualization:
        keycapJobsAll = layoutOrdering(constructionList) # Order the layout
    else:
        keycapJobsAll = [job for sublist in constructionList for job in sublist] # We don't care about layout ordering

    # Use cache for final jobs if provided
    keycapToGenerateJobs = keycapJobsAll
    keycapsAlreadyGeneratedJobs:list[dict[str, Any]] = []
    if keycapJobsCached is not None:
        logger.info("Trying to use cache")

        try:
            cached = {
                job["primaryKey"]: job["hash"]
                for job in keycapJobsCached
            }

            keycapToGenerateJobs = [ # The actual keycap jobs that need to be generated, since not cached
                job
                for job in keycapJobsAll
                if cached.get(job["primaryKey"]) != job["hash"]
            ]

            keycapsAlreadyGeneratedJobs = [ # The cached keycaps
                job
                for job in keycapJobsAll
                if cached.get(job["primaryKey"]) == job["hash"]
            ]               

            initialJobs = len(keycapJobsAll)
            notCachedJobs = len(keycapToGenerateJobs)
            cacheHitRatio = (initialJobs - notCachedJobs) / initialJobs * 100
            logger.info(f"Not cached jobs {notCachedJobs}/{initialJobs}. Cache hit ratio: {cacheHitRatio:.2f}%")

            # Cache the keycap jobs for future use
            if notCachedJobs > 0:
                logger.debug(f"Caching {len(keycapToGenerateJobs)} keycap jobs for future use.")
                keycapJobsCached.extend(deepcopy(keycapToGenerateJobs))

        except Exception as e:
            logger.warning(f"Error while filtering cached jobs: {e}")
            raise
            # TODO handle the situation if implemented variable cleaning (look at shared.py comments)
        

    return keycapShapesJobs, keycapsAlreadyGeneratedJobs, keycapToGenerateJobs, profile, layout