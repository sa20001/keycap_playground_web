from __future__ import annotations
import sys
from loguru import logger
from pathlib import Path
from contextlib import contextmanager
from tqdm import tqdm
from typing import Any
import time

# Remove default logger configuration
logger.remove()
logsPath = "./logs"
verbose = False

LOGGER_LIST:dict[int, tuple[Any, Any]] = {}
CONSOLE_LOGGER_LIST:list[int]= []

def add_logger(*args:Any, **kwargs:Any) -> int:
    logID = logger.add(*args, **kwargs)
    LOGGER_LIST.update({logID:(args, kwargs)})
    return logID

def logger_init():
    # ─────────────────────────────
    # Console loggers
    # ─────────────────────────────
    if verbose:
        # 1 Console: TRACE and up (e.g., for full debug mode)
        CONSOLE_LOGGER_LIST.append(add_logger(
            sink=sys.stdout,
            level="TRACE",
            colorize=True,
            format="<cyan>{time:HH:mm:ss}</cyan> | <level>{level: <8}</level> | "
                "<magenta>{file}:{function}:{line}</magenta> | <level>{message}</level>"
        ))
    else:
        # 2 Console: INFO and up (for higher-level messages, could have a cleaner format)
        CONSOLE_LOGGER_LIST.append(add_logger(sink=sys.stdout, level="INFO", colorize=True,
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


def _update_sink(sink:Any):
    '''Helper function to update the sink of all console loggers'''
    consList = list(CONSOLE_LOGGER_LIST) # shallow copy of console logger IDs to iterate over
    CONSOLE_LOGGER_LIST.clear()
    for id in consList:
        logger.remove(id) # Remove the console logger to prevent duplicate outputs during tqdm context
        tqdmLogger = LOGGER_LIST[id] # Get the original logger configuration for this console logger
        tqdmLogger[1]["sink"] = sink # Change the sink to use tqdm.write
        CONSOLE_LOGGER_LIST.append(add_logger(*tqdmLogger[0], **tqdmLogger[1])) # Re-add the logger with the updated sink for tqdm context


@contextmanager
def tqdm_logging():

    _update_sink(lambda msg: tqdm.write(msg, end="")) # type: ignore
    try:
        yield
    finally:
        time.sleep(1) # Small delay to ensure all tqdm outputs are flushed before restoring loggers
        _update_sink(sys.stdout)  
        logger.trace("Restored logger after tqdm logging context.")

# # Example logs
# logger.trace("This is a trace message")
# logger.debug("This is a debug message")
# logger.info("This is an info message")
# logger.warning("This is a warning message")
# logger.error("This is an error message")