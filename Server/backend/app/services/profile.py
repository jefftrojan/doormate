from fastapi import UploadFile
from ..models.user import UserProfile
from bson import ObjectId
from datetime import datetime
import os

class ProfileService:
    def __init__(self):
        self.db = None  # Will be initialized with MongoDB connection

    async def update_profile(self, user_id: str, profile_data: UserProfile):
        result = await self.db.users.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": {
                "profile": profile_data.dict(),
                "updated_at": datetime.utcnow()
            }}
        )
        if result.modified_count == 0:
            raise ValueError("Profile not updated")
        
        return await self.db.users.find_one({"_id": ObjectId(user_id)})

    async def upload_photo(self, user_id: str, file: UploadFile):
        try:
            # For now, just return a mock URL
            return {"url": f"https://example.com/photos/{user_id}"}
        except Exception as e:
            raise ValueError(f"Failed to upload photo: {str(e)}")
        # TODO: Implement file upload to cloud storage
        # For now, save to local storage
        file_path = f"uploads/{user_id}_{file.filename}"
        with open(file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        
        return f"/static/{file_path}"