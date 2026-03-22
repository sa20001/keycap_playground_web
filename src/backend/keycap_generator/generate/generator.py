import cadquery as cq
from loguru import logger
from ..utilities import Tasks, MP_CONTEXT
from ..profiles import shapeGenerator
from .worker import fullGenerator
from .jobs import create_jobs
import time
from functools import partial
from pathlib import Path
from typing import Any

# TODO implement tqdm for multiprocessing

def generate(
        stemInsideTolerance:float,
        templatePath:str,
        keycapTasks:list[Tasks],
        outputFolder:str,
        legendHeight:float,
        visualization:bool = False,
        preprocessing:bool = False,
        keycapJobsCached:list[dict[str, Any]] | None = None,
        keycapShapeCached:dict[str, tuple[cq.Assembly, float]] | None = None
        ):

    '''
    Generate the keycaps using a template.

    Parameters:
    - stemInsideTolerance: The tolerance for the stem inside the keycap.
    - templatePath: The path to the template directory.
    - keycapTasks: A list of tasks to perform on the keycaps (e.g., CARVED, MULTI, EMBOSSED).
    - outputFolder: The folder where the generated keycaps will be saved.
    - legendHeight: The height of the legend in mm
    - visualization: If True, will visualize the generated keycaps in CQ-editor.
    - preprocessing: If True, will add support blockers
    - keycapJobsCached: A list of cached keycap jobs to avoid regenerating them.
    '''

    start = time.perf_counter()
    logger.info("Generating keycaps...")

    (
        keycapShapesJobs,
        keycapsAlreadyGeneratedJobs,
        keycapToGenerateJobs,
        profile,
        layout
        ) = create_jobs(
            templatePath,
            keycapTasks,
            visualization,
            keycapJobsCached,
            stemInsideTolerance=stemInsideTolerance,
            legendHeight=legendHeight,
            )

    with MP_CONTEXT.Pool() as pool:
        # Generate the keycap shapes for each job
        shape_start = time.perf_counter()
        worker = partial(
                    shapeGenerator,
                    profile=profile,
                    stemInsideTolerance=stemInsideTolerance,
                    preprocessing=preprocessing,
                    keycapShapeCached = keycapShapeCached
                    )

        logger.debug(f"Keycap shape cache before {keycapShapeCached}")

        visResult = pool.map(worker, keycapShapesJobs)
        visResultTuple = [(item[0], item[1]) for item in visResult]
        if keycapShapeCached is not None:
            cacheShapeList = ([item[2] for item in visResult if item[2] is not None])
            for d in cacheShapeList:
                keycapShapeCached.update(d)
        logger.debug(f"Keycap shape cache after {keycapShapeCached}")

        shape_end = time.perf_counter()
        logger.debug(f"Keycap shape generation completed in {(shape_end-shape_start):.4f} seconds.")

        keycapShapes:dict[str, tuple[cq.Assembly, float]] = {}
        keycapShapes = dict(visResultTuple)
        
        logger.debug(f"Generated keycap shapes: {list(keycapShapes.keys())}")

        # Generate the keycaps
        full_start = time.perf_counter()
        worker = partial(
                    fullGenerator,
                    templateName=Path(templatePath).name,
                    layout=layout,
                    profile=profile,
                    legendHeight=legendHeight,
                    keycapShapes=keycapShapes,
                    keycapTasks=keycapTasks,
                    outputFolder=outputFolder
                    )
        
        results = pool.map(worker, keycapToGenerateJobs)
        full_end = time.perf_counter()
        logger.debug(f"Keycap+legend generation completed in {(full_end-full_start):.4f} seconds.")
        resultsFlattened = [item for sublist in results for item in sublist] # Flatten the list

        stop = time.perf_counter()
        logger.info(f"Keycap generation completed successfully in {(stop-start):.2f}.\n")

        return resultsFlattened, keycapsAlreadyGeneratedJobs

