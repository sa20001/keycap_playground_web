from __future__ import annotations
import sys
from loguru import logger
from pathlib import Path
from contextlib import contextmanager
from tqdm import tqdm
from typing import List, Any, Tuple

# Remove default logger configuration
logger.remove()
logsPath = "./logs"
verbose = False

LOGGER_LIST:List[Tuple[Any, Any]] = []
consoleLoggerList:List[int]= []

def add_logger(*args:Any, **kwargs:Any) -> int:
    LOGGER_LIST.append((args, kwargs))
    return logger.add(*args, **kwargs)

def restore_logger(*args:Any, **kwargs:Any):
    logger.add(*args, **kwargs)

def logger_init():
    # ─────────────────────────────
    # Console loggers
    # ─────────────────────────────
    if verbose:
        # 1 Console: TRACE and up (e.g., for full debug mode)
        consoleLoggerList.append(add_logger(
            sys.stdout,
            level="TRACE",
            colorize=True,
            format="<cyan>{time:HH:mm:ss}</cyan> | <level>{level: <8}</level> | "
                "<magenta>{file}:{function}:{line}</magenta> | <level>{message}</level>"
        ))
    else:
        # 2 Console: INFO and up (for higher-level messages, could have a cleaner format)
        consoleLoggerList.append(add_logger(sink=sys.stdout, level="INFO", colorize=True,
                format="<green>{time:HH:mm:ss}</green> | <level>{message}</level>"))

    logger.success("Console logger successfully initialized.")

    # ─────────────────────────────
    # File loggers
    # ─────────────────────────────
    # Enable file logging only if logs directory exists, otherwise skip to console logging
    if Path(logsPath).exists(): 
        # 1 TRACE and up
        add_logger(f"{logsPath}/trace.log", level="TRACE", rotation="10 MB", compression="zip")

        # 2 INFO and up
        add_logger(f"{logsPath}/info.log", level="INFO", rotation="10 MB", compression="zip")

        logger.success("File logger successfully initialized.")
    else:
        logger.warning(f"Logs directory '{logsPath}' not mapped. File logging is disabled.")

logger_init() # Initialize the logger when the module is imported


@contextmanager
def tqdm_logging():

    global logger

    for id in consoleLoggerList:
        logger.remove(id) # Remove the console logger to prevent duplicate outputs during tqdm context
        tqdmLogger = LOGGER_LIST[id-1] # Get the original logger configuration for this console logger
        tqdmLogger[1]["sink"] = lambda msg: tqdm.write(msg, end="") # type: ignore # Change the sink to use tqdm.write
        restore_logger(*tqdmLogger[0], **tqdmLogger[1]) # Re-add the logger with the updated sink for tqdm context

    try:
        yield
    finally:
        logger.remove() # Remove all loggers

        # Restore loggers
        for x in LOGGER_LIST:
            restore_logger(*x[0], **x[1])
        
        logger.trace("Restored logger after tqdm logging context.")


# # Example logs
# logger.trace("This is a trace message")
# logger.debug("This is a debug message")
# logger.info("This is an info message")
# logger.warning("This is a warning message")
# logger.error("This is an error message")