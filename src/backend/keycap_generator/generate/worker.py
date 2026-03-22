from ..utilities import keyToFilename, Tasks, KEYCAP_ID, LEGEND_ID
from ..legends import generate_legends
from typing import Any, cast
import cadquery as cq
from loguru import logger
import copy

def fullGenerator(
        job:dict[str, Any],
        templateName:str,
        layout:str,
        profile:str,
        legendHeight:float,
        keycapShapes:dict[str, tuple[cq.Assembly, float]],
        keycapTasks:list[Tasks],
        outputFolder:str
        ):

    '''
    Generates a keycap based on the provided job dictionary, layout, profile, legend height, keycap shapes, tasks, output folder, and visualization flag.
    '''

    translationTuple:tuple[float, float, float] = job.get("translationTuple", (0.0, 0.0, 0.0))
    generatedKeycapsList:list[tuple[cq.Assembly, dict[str, Any]]] = [] # list used for saving the generated keycaps to disk

    legend = generate_legends(height=legendHeight, legend_list=job["legend_list"])
    keycapShapeKey = job["keycapShape"]
    primaryKey = job["primaryKey"]
    hash = job["hash"]
    taskValue = job["taskValue"]
    logger.debug(f"Generating keycap for job with primary key: {primaryKey}, hash: {hash}")

    keyHeight = keycapShapes[keycapShapeKey][1]

    taskHeightDiff = 30
    mapDict = {
        task.value: index
        for index, task in enumerate(keycapTasks)
    }
    visualizationZOffset = mapDict[taskValue] * taskHeightDiff

    keycapShapeAssembly = copy.deepcopy(keycapShapes[keycapShapeKey][0])
    basePath = f"{outputFolder}/{templateName}/{layout}/{profile}/{taskValue}"

    legendStringList = [x["legend"] for x in job["legend_list"]]
    legendStringNormalized = keyToFilename(legendStringList)
    fileName = f"{keycapShapeKey}-{primaryKey}-{legendStringNormalized}"
    filePath = f"{basePath}/{fileName}.step"

    metadata:dict[str, Any] = {
        "filePath": filePath,
        "translationTuple" : translationTuple,
        "visualizationZOffset" : visualizationZOffset,
        "primaryKey" : primaryKey,
        "hash" : hash,
        "task" : taskValue
    }

    match taskValue:
        case Tasks.CARVED:
            legendPosZ = keyHeight - legendHeight
            logger.debug(f"{taskValue}: adding legend to keycap shape {keycapShapeKey} at Z position {legendPosZ}")
            keycapShape = cast(cq.Workplane, keycapShapeAssembly.objects[KEYCAP_ID].obj)

            if legend is not None:
                object = keycapShape.cut(legend.translate((0,0, legendPosZ)))
            else:
                object = keycapShape

            keycapShapeAssembly.objects[KEYCAP_ID].obj = object
            keycapShapeAssembly.objects[KEYCAP_ID].color = cq.Color("green")

            # Add to save list
            generatedKeycapsList.append((keycapShapeAssembly, metadata))        

        case Tasks.MULTI:
            legendPosZ = keyHeight - legendHeight
            logger.debug(f"{taskValue}: adding legend to keycap shape {keycapShapeKey} at Z position {legendPosZ}")
            keycapShape = cast(cq.Workplane, keycapShapeAssembly.objects[KEYCAP_ID].obj)

            if legend is not None:
                assyLegend = legend.translate((0,0, legendPosZ))
                object = keycapShape.cut(assyLegend)
                keycapShapeAssembly.add(assyLegend, name=LEGEND_ID, color=cq.Color("red"))
            else:
                object = keycapShape

            keycapShapeAssembly.objects[KEYCAP_ID].obj = object

            # Add to save list
            generatedKeycapsList.append((keycapShapeAssembly, metadata))    
            
        case Tasks.EMBOSSED:
            legendPosZ = keyHeight
            logger.debug(f"{taskValue}: adding legend to keycap shape {keycapShapeKey} at Z position {legendPosZ}")
            keycapShape = cast(cq.Workplane, keycapShapeAssembly.objects[KEYCAP_ID].obj)

            if legend is not None:
                object = keycapShape.union(legend.translate((0,0, legendPosZ)))
            else:
                object = keycapShape
                
            keycapShapeAssembly.objects[KEYCAP_ID].obj = object
            keycapShapeAssembly.objects[KEYCAP_ID].color = cq.Color("royalblue")

            # Add to save list
            generatedKeycapsList.append((keycapShapeAssembly, metadata))        

        case _:
            logger.error(f"Unknown task: {taskValue}")
            raise ValueError(f"Unknown task: {taskValue}")

    return generatedKeycapsList 