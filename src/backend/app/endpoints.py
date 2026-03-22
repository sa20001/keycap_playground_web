from fastapi import APIRouter, Request, status
from pydantic import BaseModel, Field
from fastapi.responses import JSONResponse, Response
from keycap_generator import Tasks, generate, visualizeWeb, getKeycapsToExport, exportToDisk
import time
from loguru import logger
from typing import Any, cast
import cadquery as cq

command_router = APIRouter()

class GenerateRequest(BaseModel):
    stemInsideTolerance: float = 0.18
    legendHeight: float = 0.5
    outputFolder: str = "generated"
    keycapToGenerateTasks: list[Tasks] = Field(default_factory=lambda: list(Tasks))
    templatePath: str = "templates/think"
    preprocessing: bool = True


def _generate_model(config: GenerateRequest, request: Request):

    start = time.perf_counter()

    logger.debug(f"Received generate request with config: {config}")

    logger.debug(f"Cached keycap jobs: {len(request.app.state.keycapJobsCache)} jobs available.")

    keycapTasks = config.keycapToGenerateTasks
    logger.debug(f"Keycap tasks to generate: {[task.value for task in keycapTasks]}")

    result = generate(
        stemInsideTolerance=config.stemInsideTolerance,
        legendHeight=config.legendHeight,
        visualization=True,
        outputFolder=config.outputFolder,
        keycapTasks=keycapTasks,
        templatePath=config.templatePath,
        preprocessing=config.preprocessing,
        keycapJobsCached=request.app.state.keycapJobsCache,
        keycapShapeCached=request.app.state.keycapShapeCache
    )

    logger.debug(f"Cached keycap jobs: {len(request.app.state.keycapJobsCache)} jobs available.")


    keycapJobsGeneratedCached = request.app.state.keycapJobsGeneratedCache
    keycapJobsGeneratedCached = cast(list[tuple[cq.Assembly, dict[str, Any]]] | None, keycapJobsGeneratedCached)

    if keycapJobsGeneratedCached is None:
        logger.info("No generated cached jobs found. Initializing cache.")
        start = time.perf_counter()
        request.app.state.keycapJobsGeneratedCache = result[0]
        logger.info(f"Initialized generated cache with {len(result[0])} jobs in {time.perf_counter() - start:.4f} seconds.")

    else:
        logger.info(f"Found {len(keycapJobsGeneratedCached)} generated cached jobs. Updating cache with new jobs.")
        # Update the cached jobs with the newly generated jobs
        request.app.state.keycapJobsGeneratedCache.extend(result[0])
        logger.debug(f"Added {len(result[0])} new jobs to the generated cache. Total cached jobs: {len(request.app.state.keycapJobsGeneratedCache)}")


    exportResult = getKeycapsToExport(keycapJobsGeneratedCached, keycapTasks, result)
    request.app.state.keycapJobsGeneratedCache = exportResult
    compressedDataPath = visualizeWeb(exportResult)
    with open(compressedDataPath, "rb") as f:
        data = f.read()
        logger.debug(f"Compressed data size: {len(data)/1024:.2f} KB")

        end = time.perf_counter()
        logger.info(f"Api request completed in {(end-start):.4f} seconds.")

        return Response(
            content=data,
            media_type="application/x-7z-compressed",
            headers={
                "Content-Disposition": 'attachment; filename="model.7z"',
            },
        )


class AdaptiveLayerHeightConfig(BaseModel):
    first_layer_height: float = 0.2
    layer_height: float = 0.05
    min_layer_height: float = 0.05
    max_layer_height: float = 0.3
    quality_speed_factor: float = 0.5

class ExportRequest(BaseModel):
    filename: str = "keycaps-export"
    adaptiveLayerHeightConfig: AdaptiveLayerHeightConfig = Field(default_factory=AdaptiveLayerHeightConfig)

def _export_model(config:ExportRequest, request: Request):

    logger.debug(f"Received export request with config: {config}")

    if request.app.state.keycapJobsGeneratedCache is None:
        logger.warning("No generated cached jobs found. Cannot export model.")
        return JSONResponse(
            content={"error": "No generated cached jobs found. Cannot export model."},
            status_code=status.HTTP_400_BAD_REQUEST
            )    

    # Export the cached generated jobs to disk
    # TODO create temp folder and export to that folder, then zip the folder and return the zip file to the user
    exportToDisk(
        keycapShapeAssemblyList=request.app.state.keycapJobsGeneratedCache,
        preprocessing=True,
        adaptiveLayerHeightConfig=config.adaptiveLayerHeightConfig.model_dump()
    )
    return JSONResponse(content={"message": "Model exported successfully."}, status_code=status.HTTP_200_OK)

    # TODO implement export model function


# ------------------------
# HTTP commands
# ------------------------
@command_router.post("/generate")
async def generate_from_config(config: GenerateRequest, request: Request):
    return _generate_model(config, request)

@command_router.post("/export")
async def export_2_disk(config:ExportRequest, request: Request):
    return _export_model(config, request)