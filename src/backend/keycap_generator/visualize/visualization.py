from loguru import logger
import cadquery as cq
from ..visualize import layoutCreate
from ..utilities import CACHE_DIR, MP_CONTEXT
import time
from typing import Any
from copy import deepcopy
from functools import partial
from pathlib import Path
import subprocess
import hashlib

def _visualize(generatedKeycapsList:list[tuple[cq.Assembly, dict[str, Any]]]):
    resAssemblyList:list[tuple[cq.Assembly, str]] = []
    for objTuple in generatedKeycapsList:
        obj, metadata = objTuple

        translationTuple = metadata["translationTuple"]
        hash:str = metadata["hash"]
        visualizationZOffset = metadata["visualizationZOffset"]

        layoutCreate(obj, translationTuple, visualizationZOffset)
        resAssemblyList.append((obj, hash))
        
    return resAssemblyList


def _encodeGLB(x:tuple[cq.Assembly, str], encodedFolder:Path):
    assy, hash = x

    encodedFile = encodedFolder.joinpath(hash + ".glb")
    exists = encodedFile.exists()

    logger.debug(f"Encoding file path {encodedFile} for hash {hash}. Exists: {exists}")

    if exists:
        logger.debug(f"GLB file for hash {hash} already exists. Skipping encoding.")

    else:
        start = time.perf_counter()
        assy.export(  # type: ignore
            path= str(encodedFile),
            exportType="GLTF",
        )   
        end = time.perf_counter()
        logger.debug(f"Exported GLB file in {(end-start):.4f}")

    return encodedFile


def visualizeCQEditor(exportResult:list[tuple[cq.Assembly, dict[str, Any]]]):
    logger.info("Creating layout visualization...")
    exportResult = deepcopy(exportResult) # deepcopy to avoid modifying the original list from now on
    start = time.perf_counter()
    resAssemblyList = _visualize(exportResult)
    resAssembly = cq.Assembly()
    for i, obj in enumerate(resAssemblyList):
        obj, _ = obj
        resAssembly = resAssembly.add(obj, name=f"keycap_{i}")

    logger.debug(f"Layout visualization created successfully in {(time.perf_counter()-start):.4f}.")
    return resAssembly


def visualizeWeb(exportResult:list[tuple[cq.Assembly, dict[str, Any]]]):

    exportResult = deepcopy(exportResult) # deepcopy to avoid modifying the original list from now on
    xList = _visualize(exportResult)

    start = time.perf_counter()
    exportedGLB = CACHE_DIR.joinpath("exportedGLB")
    exportedGLB.mkdir(exist_ok=True)

    with MP_CONTEXT.Pool() as pool:

        worker = partial(
            _encodeGLB,
            encodedFolder= exportedGLB
            )
        
        logger.info(f"Encoding {len(xList)} GLB files...")
        results = pool.map(worker, xList)
        end = time.perf_counter()
        logger.debug(f"Exported {len(results)} GLB files in {(end-start):.4f} seconds.")

    totSize = sum([x.stat().st_size for x in results])
    logger.debug(f"Total size of {len(results)} GLB files: {totSize/1048576:.2f} MB")

    # Compute all file hash
    hashMain = hashlib.md5()
    for file in results:
        with open(file, "rb") as f:
            hashMain.update(f.read())
    hashMain = hashMain.hexdigest()

    # Compress to 7z file
    saveZipPath = exportedGLB.joinpath(hashMain + ".7z")
    if saveZipPath.exists():
        logger.debug(f"Compressed file {saveZipPath} already exists. Skipping compression.")

    else:
        startCompression = time.perf_counter()
        subprocess.run([
            "7z",
            "a",
            "-t7z",
            "-m0=lzma2",
            "-mx=9",
            "-mmt=on",
            "-ms=on",
            "-md=256m",
            saveZipPath,
            *results,
        ], check=True)

        endCompression = time.perf_counter()

        compressedSize = saveZipPath.stat().st_size
        compressionRatio = (1 - compressedSize / totSize) * 100
        logger.info(
            f"Compressed {len(results)} GLB files in {(endCompression - startCompression):.2f}s: "
            f"{totSize / 1048576:.2f} MiB -> "
            f"{compressedSize / 1048576:.2f} MiB "
            f"({compressionRatio:.2f}% reduction)"
            )

    logger.info(f"VisualizeWeb operation completed in {(time.perf_counter()-start):.4f} seconds.")

    return saveZipPath