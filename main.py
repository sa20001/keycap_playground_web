from loguru import logger
from src.backend.keycap_generator import Tasks, generate, exportToDisk, visualizeCQEditor, getKeycapsToExport
from src.backend.logger import logger_init
logger_init()  # Initialize the logger
logger.info("Loading libraries...")

STEM_INSIDE_TOLERANCE = 0.18
LEGEND_HEIGHT = -0.1 #  height of the legend in mm
OUTPUT_FOLDER = "generated" # Folder where the generated keycaps will be saved.
# KEYCAP_TASKS:list[Tasks] = [Tasks.CARVED, Tasks.MULTI, Tasks.EMBOSSED]
KEYCAP_TASKS:list[Tasks] = [Tasks.MULTI]
TEMPLATE_PATH = "templates/think"
PREPROCESSING = True # If True, will preprocess the generated files with PrusaSlicer to add support blockers and a custom variable layer height
ADAPTIVE_LAYER_HEIGHT_CONFIG: dict[str, float] = {
    "first_layer_height": 0.2,
    "layer_height": 0.05,
    "min_layer_height": 0.05,
    "max_layer_height": 0.3,
    "quality_speed_factor": 0.5
}
SAVE = True

def main():
    
    logger.info("Starting keycap generation...")

    result = generate(
        stemInsideTolerance=STEM_INSIDE_TOLERANCE,
        legendHeight=LEGEND_HEIGHT,
        visualization=False,
        outputFolder=OUTPUT_FOLDER,
        keycapTasks=KEYCAP_TASKS,
        templatePath=TEMPLATE_PATH,
        preprocessing=PREPROCESSING
        )

    exportResult = getKeycapsToExport(None, KEYCAP_TASKS, result) 
    if SAVE:
        exportToDisk(
            keycapShapeAssemblyList=exportResult,
            preprocessing=PREPROCESSING,
            adaptiveLayerHeightConfig=ADAPTIVE_LAYER_HEIGHT_CONFIG
            )


if __name__ == "__main__":
    main()


# CQ-editor execution
if "show_object" in globals():
    logger.info("CQ-editor detected. Visualizing generated keycaps...")
    result = generate(
        stemInsideTolerance=STEM_INSIDE_TOLERANCE,
        legendHeight=LEGEND_HEIGHT,
        visualization=True,
        outputFolder=OUTPUT_FOLDER,
        keycapTasks=KEYCAP_TASKS,
        templatePath=TEMPLATE_PATH,
        preprocessing=PREPROCESSING
        )

    exportResult = getKeycapsToExport(None, KEYCAP_TASKS, result) 
    x = visualizeCQEditor(exportResult)
    
    if SAVE:
        exportToDisk(
            keycapShapeAssemblyList=exportResult,
            preprocessing=PREPROCESSING,
            adaptiveLayerHeightConfig=ADAPTIVE_LAYER_HEIGHT_CONFIG
            )
        
    logger.info("Visualizing layout in cq-editor, it will take some time...")
    
