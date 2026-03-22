from zipfile import ZipFile, ZIP_DEFLATED
from pathlib import Path
import shutil
from .edit_xml import edit_xml

def edit_zip_entry(zip_path: Path):
    entry_name: str = "Metadata/Slic3r_PE_model.config"
    zipParent = zip_path.parent / "extracted"
    zipParent.mkdir(parents=True, exist_ok=True)

    # 1. Extract the entry
    with ZipFile(zip_path, "r") as zin:
        zin.extract(entry_name, zipParent)

    # 2. The extracted file
    entry_path = zipParent / entry_name

    # 3. Edit the file
    edit_xml(entry_path)

    # 4. Replace the entry in the ZIP
    tmp_zip = zipParent / "modified.zip"

    with ZipFile(zip_path, "r") as zin, \
         ZipFile(tmp_zip, "w", ZIP_DEFLATED) as zout:

        for item in zin.infolist():
            if item.filename == entry_name:
                # Write our modified file instead
                zout.write(entry_path, item.filename)
            else:
                # Copy everything else unchanged
                zout.writestr(item, zin.read(item.filename))

    # Replace original ZIP
    shutil.move(tmp_zip, zip_path)

def addFileToZip(zip_path: Path, file_path: Path, arcname: str):
    with ZipFile(zip_path, "a", ZIP_DEFLATED) as zip_file:
        zip_file.write(file_path, arcname)