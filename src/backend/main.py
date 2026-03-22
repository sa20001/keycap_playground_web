import uvicorn
import os

reload = os.getenv("DEV", "true").lower() == "true"

if __name__ == "__main__":
    
    # Launch FastAPI app
    uvicorn.run("app.server:app", reload=reload, host="0.0.0.0", port=5000) # TODO Disable reload for production
