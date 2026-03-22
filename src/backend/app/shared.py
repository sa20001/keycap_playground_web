from fastapi import FastAPI
from contextlib import asynccontextmanager
from fastapi import FastAPI
import time
from logger.custom_logger import CONSOLE_LOGGER_LIST, logger, logger_init
import os
VERBOSE = os.getenv("VERBOSE", "true").lower() == "true"

# ------------------------
# Define lifespan startup logic
# ------------------------
@asynccontextmanager
async def lifespan(app: FastAPI):

    logger_init(VERBOSE)  # Initialize the logger

    logger.info("Starting app thread...", flush=True)  
    yield  # app runs here
    logger.info("Shutting down app...")

    time.sleep(1)  # Give some time to clean up
    
    # Clean up logger handlers to prevent semaphore leaks
    for log_id in CONSOLE_LOGGER_LIST:
        try:
            logger.remove(log_id)
        except:
            pass


# ------------------------
# Create app with lifespan
# ------------------------
app = FastAPI(lifespan=lifespan)

# App state for shared variables
# TODO check if the following vars get bigger than a threshold, if yes clear rarely used entries, can add a last used metadata
# can create a class to automatize this at the layer level, without adding metadata to entries manually at user level, can use a LRU cache or similar
# like every time you access an entry, update its last used timestamp, and then periodically check for entries that haven't been used in a while and remove them.
app.state.keycapJobsCache = [] # Initialize keycapJobs cache
app.state.keycapJobsGeneratedCache = None # Initialize keycapJobs cache
app.state.keycapShapeCache = {} # Initialize keycapShape cache

app.state.lastGenKeycaps = None # Initialize keycapShape cache
