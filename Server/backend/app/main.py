from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
from fastapi.staticfiles import StaticFiles
from .routes import auth, profile
from .routes import feedback
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI()

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB connection
mongodb_url = "mongodb://localhost:27017"
client = AsyncIOMotorClient(mongodb_url)
db = client.doormate

@app.get("/")
async def read_root():
    return {"message": "Welcome to DoorMate API"}

# Mount static files
os.makedirs("uploads", exist_ok=True)
app.mount("/static", StaticFiles(directory="uploads"), name="static")

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(profile.router, prefix="/api/profile", tags=["profile"])
app.include_router(feedback.router, prefix="/api/feedback", tags=["feedback"])