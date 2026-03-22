from typing import Any, cast
from loguru import logger
import cadquery as cq
from ..utilities import KeyUnit, KEY_UNIT
from ..shapes import ISO_ENTER_UP_DOWN_DIFF

def layoutOrdering(constructionList: list[list[dict[str, Any]]]):

    # Transpose the list
    logger.debug(f"Transposing the construction list for layout ordering.")
    logger.debug(f"Original construction list: {constructionList}")
    constructionList = [list(column) for column in zip(*constructionList)]
    logger.debug(f"Transposed construction list: {constructionList}")

    retList:list[dict[str, Any]] = []
    for keycapTaskJobs in constructionList:
        # Order Keycaps by row and row_index to ensure ordered visualization
        logger.trace("Keycap jobs before sorting:")
        logger.trace(keycapTaskJobs)
        keycapTaskJobs.sort(key=lambda job: (job["row"], job["row_index"]))
        logger.trace("Keycap jobs after sorting:")
        logger.trace(keycapTaskJobs)

        rowOffset = 0 # how much the keys in one row are shifted right since previous keys in the row were not 1U wide
        lastRow = 1
        spillRowDict:dict[str, Any] = {}
        for job in keycapTaskJobs:
            row = job["row"]
            del job["row"]

            row_index = job["row_index"]
            del job["row_index"]

            key_unit = job["unit"]
            del job["unit"]

            if row != lastRow and row_index == 0:
                rowOffset = 0

            keyUnit = abs(KeyUnit[key_unit].value) # use abs to handle negative values for ISO_ENTER and ISO_SKINNY
            keyUnit = KeyUnit[key_unit].value
            isoOffset = 0
            if keyUnit == KeyUnit.ISO_ENTER or keyUnit == KeyUnit.ISO_ENTER_SKINNY:
                keyUnit = abs(keyUnit) # use abs to handle negative values 
                isoOffset = ISO_ENTER_UP_DOWN_DIFF


            # Adjust the spacing between keycaps on same row
            base_pos = (row_index * KEY_UNIT) + (keyUnit - 1) * KEY_UNIT/2
            offset_pos = (rowOffset + isoOffset) * KEY_UNIT
            spillRowOffeset = spillRowDict.get(f"{row-1}_{row_index-1}", KeyUnit.U1)- KeyUnit.U1
            x_pos = base_pos + offset_pos + spillRowOffeset * KEY_UNIT

            # Adjust the spacing between keycaps on different rows
            spillRowList = job["spillRow"]
            spillRow = spillRowList[0]
            adjustedRow = row -(row - spillRow)/2
            y_pos = -(adjustedRow-1) * KEY_UNIT

            # Save in spillRowDict for later use
            if row != spillRow:
                spillRowDict[f"{row}_{spillRowList[1]}"] = keyUnit

            logger.debug(f"Keycap Job:")
            logger.debug(f"\t row: {row}, row_index: {row_index}, key_unit: {key_unit}, x_pos: {x_pos},")
            logger.debug(f"\t keycapShape: {job['keycapShape']},")
            logger.debug(f"\t legend_list: {job['legend_list']}")
            translationTuple = (x_pos, y_pos, 0)
            job["translationTuple"] = translationTuple

            rowOffset += keyUnit + isoOffset + spillRowOffeset - KeyUnit.U1
            lastRow = row

        retList.extend(keycapTaskJobs)

    return retList

def layoutCreate(keycapShapeAssembly:cq.Assembly, translationTuple:tuple[float, float, float], zOffset:float):
    for _, object in keycapShapeAssembly.objects.items():
                    if object.obj is not None:
                        objectX = cast(cq.Workplane, object.obj)
                        object.obj = (objectX
                                      .translate(translationTuple)
                                      .translate((0, 0, zOffset))
                                      )