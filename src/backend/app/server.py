from fastapi.middleware.cors import CORSMiddleware
from .endpoints import command_router
from loguru import logger
from .shared import app

logger.debug("Importing server module...")

# Allow frontend dev server origin
origins = [
    "http://localhost:5173",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,      # or ["*"] for any origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include endpoints and websockets
app.include_router(command_router)