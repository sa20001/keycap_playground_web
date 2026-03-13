import shutil
from .libraries import logger_init
from loguru import logger

class OpenSCADException(Exception):
    """
    Raised when OpenSCAD can't be found or it's not working correctly.
    """
    pass

class ColorscadException(Exception):
    """
    Raised when colorscad and 3mfmerge can't be found or are not working correctly.
    """
    pass

class mfMergeException(Exception):
    """
    Raised when colorscad and 3mfmerge can't be found or are not working correctly.
    """
    pass


def init_proj():
    """
    Initializes the project by checking for necessary executables and setting up logging.
    """
    logger_init() # Initialize the logger

    # Check for OpenSCAD and ColorSCAD executables
    if shutil.which("openscad") is None:
        raise OpenSCADException("OpenSCAD executable not found in PATH.")

    if shutil.which("colorscad") is None:
        raise ColorscadException("ColorSCAD executable not found in PATH.")
    
    if shutil.which("3mfmerge") is None:
        raise mfMergeException("3mfmerge executable not found in PATH.")
    
    logger.success("Project initialized successfully.")