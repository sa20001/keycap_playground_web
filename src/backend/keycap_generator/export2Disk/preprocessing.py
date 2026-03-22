import subprocess
from pathlib import Path
from loguru import logger
from tempfile import TemporaryDirectory
import shutil
from .zip import edit_zip_entry, addFileToZip
from .variable_height import generate_adaptive_layer_heights
import cadquery as cq
from typing import cast
from ..utilities import KEYCAP_ID, LEGEND_ID

def convert(f: Path, assy: cq.Assembly, adaptiveLayerHeightConfig: dict[str, float] | None):
    file = f.with_suffix(".3mf")
    fileName = file.name
    logger.debug(f"Converting {f} -> {file}")

    with TemporaryDirectory() as tmpDir:
        tmp3mfFile = Path(tmpDir) / fileName

        result = subprocess.run(
            ["prusa-slicer", "--export-3mf", "--output", str(tmp3mfFile), str(f)],
            capture_output=True,
            text=True,
        )

        if result.returncode != 0:
            logger.error(f"Failed: {f}")
            logger.error(result.stderr)
            raise RuntimeError(f"Failed to convert {f} to 3MF: {result.stderr}")

        logger.debug(f"tmp file exists: {tmp3mfFile.exists()}")
        edit_zip_entry(tmp3mfFile)

        if adaptiveLayerHeightConfig is not None:
            # Get parts that will be printed and generate adaptive layer heights profile
            keycap_obj = cast(cq.Workplane, assy.objects[KEYCAP_ID].obj)
            legend_obj = assy.objects.get(LEGEND_ID, None)
            if legend_obj is not None:
                legend_obj = cast(cq.Workplane, legend_obj.obj)
                keycap_obj = keycap_obj.union(legend_obj)

            profile = generate_adaptive_layer_heights(
                        obj=keycap_obj,
                        first_layer_height=adaptiveLayerHeightConfig["first_layer_height"],
                        layer_height=adaptiveLayerHeightConfig["layer_height"],
                        min_layer_height=adaptiveLayerHeightConfig["min_layer_height"],
                        max_layer_height=adaptiveLayerHeightConfig["max_layer_height"],
                        quality_speed_factor=adaptiveLayerHeightConfig["quality_speed_factor"],
                    )

            addLayerFilename = "Slic3r_PE_layer_heights_profile.txt"
            adaptiveLayerFile = Path(tmpDir) / addLayerFilename
            adaptiveLayerFile.write_text(
                "object_id=1|" + ";".join(f"{h:.6f}" for h in profile),
                encoding="utf-8",
            )

            addFileToZip(tmp3mfFile, Path(adaptiveLayerFile), f"Metadata/{addLayerFilename}")

        shutil.move(tmp3mfFile, file)
        f.unlink()  # Remove the original .step file        

    logger.debug(f"Finished: {f}")