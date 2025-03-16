from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# MongoDB connection
mongodb_url = os.getenv("MONGODB_URL", "mongodb://localhost:27017/doormate")
client = AsyncIOMotorClient(mongodb_url)
db = client[os.getenv("DATABASE_NAME", "doormate")] 