from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from .routes import auth, profile
from .routes import feedback
from .routes import listing
from .routes import agent
from .services.listing import ListingService
import os
from dotenv import load_dotenv
from .database import db

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

# Initialize services
listing_service = ListingService()
listing_service.initialize(db)

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
app.include_router(listing.router, prefix="/api/listings", tags=["listings"])
app.include_router(agent.router, prefix="/api/agent", tags=["agent"])

# Add users router that includes profile endpoints for mobile client compatibility
app.include_router(profile.router, prefix="/users", tags=["users"])