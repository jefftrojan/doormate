from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# MongoDB connection
mongodb_url = os.getenv("MONGODB_URL", "mongodb+srv://admin:admin123@cluster0.d0ili.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
client = AsyncIOMotorClient(mongodb_url)
db = client[os.getenv("DATABASE_NAME", "doormate")] 