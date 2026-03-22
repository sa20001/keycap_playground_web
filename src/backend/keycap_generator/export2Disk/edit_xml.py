import re
import xml.etree.ElementTree as ET
from pathlib import Path
from ..utilities import SUPPORT_BLOCKER_ID, LEGEND_ID

def edit_xml(xml_path: Path):
    tree = ET.parse(xml_path)
    root = tree.getroot()

    for volume in root.findall(".//volume"):
        name = None
        volume_type = None

        for metadata in volume.findall("metadata"):
            key = metadata.get("key")

            if key == "name":
                name = metadata.get("value")

            elif key == "volume_type":
                volume_type = metadata

        if name and re.fullmatch(rf"{re.escape(SUPPORT_BLOCKER_ID)}\d+", name):
            if volume_type is not None:
                volume_type.set("value", "SupportBlocker")

        if name and re.fullmatch(rf"{re.escape(LEGEND_ID)}", name):
            ET.SubElement(
                volume,
                "metadata",
                {
                    "type": "volume",
                    "key": "extruder",
                    "value": "2", # Key 0 is default, key 1 is the first extruder (the default one), key 2 is the second extruder, etc
                },
            )

    tree.write(
        xml_path,
        encoding="UTF-8",
        xml_declaration=True,
    )