from fastapi import UploadFile
from ..models.user import UserProfile
from bson import ObjectId
from datetime import datetime
import os
from ..database import db
from passlib.context import CryptContext

class ProfileService:
    def __init__(self):
        self.db = db
        self.pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

    async def update_profile(self, user_id: str, profile_data: UserProfile):
        # Convert profile data to dict and prepare update
        profile_dict = profile_data.dict(exclude_unset=True)
        
        # Update user document with profile fields directly
        result = await self.db.users.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": {
                **profile_dict,  # Spread profile fields directly into user document
                "updated_at": datetime.utcnow()
            }}
        )
        
        if result.modified_count == 0:
            raise ValueError("Profile not updated")
        
        # Return updated user document
        updated_user = await self.db.users.find_one({"_id": ObjectId(user_id)})
        if updated_user:
            # Convert ObjectId to string for JSON serialization
            updated_user["_id"] = str(updated_user["_id"])
        return updated_user

    async def upload_photo(self, user_id: str, file: UploadFile):
        try:
            # Create uploads directory if it doesn't exist
            upload_dir = "uploads"
            os.makedirs(upload_dir, exist_ok=True)
            
            # Generate unique filename
            file_extension = os.path.splitext(file.filename)[1]
            unique_filename = f"{user_id}_{datetime.utcnow().timestamp()}{file_extension}"
            file_path = os.path.join(upload_dir, unique_filename)
            
            # Save file
            with open(file_path, "wb") as buffer:
                content = await file.read()
                buffer.write(content)
            
            # Update user's photo URL in database
            await self.db.users.update_one(
                {"_id": ObjectId(user_id)},
                {"$set": {
                    "photo_url": f"/static/uploads/{unique_filename}",
                    "updated_at": datetime.utcnow()
                }}
            )
            
            return {"url": f"/static/uploads/{unique_filename}"}
        except Exception as e:
            raise ValueError(f"Failed to upload photo: {str(e)}")

    async def update_password(self, user_id: str, new_password: str):
        """Update user password"""
        # Hash the new password
        hashed_password = self.pwd_context.hash(new_password)
        
        # Update the password in the database
        result = await self.db.users.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": {
                "password": hashed_password,
                "updated_at": datetime.utcnow()
            }}
        )
        
        if result.modified_count == 0:
            raise ValueError("Password not updated")
        
        return {"success": True}
        
    async def mark_password_set(self, user_id: str):
        """Mark that a user has set their password"""
        result = await self.db.users.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": {
                "password_set": True,
                "updated_at": datetime.utcnow()
            }}
        )
        
        if result.modified_count == 0:
            raise ValueError("Failed to mark password as set")
        
        return {"success": True}