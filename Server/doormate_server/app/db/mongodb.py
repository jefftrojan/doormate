from motor.motor_asyncio import AsyncIOMotorClient
from app.core.config import settings

class MongoDB:
    client: AsyncIOMotorClient = None

async def get_database() -> AsyncIOMotorClient:
    return MongoDB.client["doormate"]

async def connect_to_mongo():
    MongoDB.client = AsyncIOMotorClient(settings.MONGODB_URL)

async def close_mongo_connection():
    MongoDB.client.close()