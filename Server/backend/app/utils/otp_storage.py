from motor.motor_asyncio import AsyncIOMotorClient
import os
from datetime import datetime, timedelta
from dotenv import load_dotenv

load_dotenv()

client = AsyncIOMotorClient(os.getenv("MONGODB_URL"))
db = client[os.getenv("DATABASE_NAME")]

async def store_otp_in_db(email: str, otp: str) -> bool:
    try:
        # Set OTP expiration time (10 minutes from now)
        expiration_time = datetime.utcnow() + timedelta(minutes=10)
        
        # Update or insert OTP document
        result = await db.otps.update_one(
            {"email": email},
            {
                "$set": {
                    "otp": otp,
                    "expires_at": expiration_time,
                    "created_at": datetime.utcnow(),
                    "verified": False
                }
            },
            upsert=True
        )
        
        return result.acknowledged
    except Exception as e:
        print(f"Error storing OTP: {str(e)}")
        return False

async def verify_stored_otp(email: str, otp: str) -> bool:
    try:
        stored_otp = await db.otps.find_one({
            "email": email,
            "otp": otp,
            "expires_at": {"$gt": datetime.utcnow()},
            "verified": False
        })
        
        if stored_otp:
            # Mark OTP as verified
            await db.otps.update_one(
                {"_id": stored_otp["_id"]},
                {"$set": {"verified": True}}
            )
            return True
            
        return False
    except Exception as e:
        print(f"Error verifying OTP: {str(e)}")
        return False