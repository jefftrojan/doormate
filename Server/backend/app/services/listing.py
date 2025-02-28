from bson import ObjectId
from ..models.listing import Listing, ListingCreate, ListingUpdate
from datetime import datetime
from fastapi import UploadFile, HTTPException
import os
import aiofiles
from motor.motor_asyncio import AsyncIOMotorDatabase

class ListingService:
    def __init__(self):
        self.db: AsyncIOMotorDatabase = None

    def initialize(self, db: AsyncIOMotorDatabase):
        self.db = db

    async def get_listing_by_id(self, listing_id: str):
        try:
            listing = await self.db.listings.find_one(
                {"_id": ObjectId(listing_id)}
            )
            if listing:
                user = await self.db.users.find_one({"_id": listing["user_id"]})
                if user:
                    listing["user"] = {
                        "id": str(user["_id"]),
                        "name": user.get("fullName"),
                        "email": user["email"],
                        "profilePhoto": user.get("profile", {}).get("profilePhoto")
                    }
                    listing["_id"] = str(listing["_id"])
                    listing["user_id"] = str(listing["user_id"])
            return listing
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error fetching listing: {str(e)}")

    async def create_listing(self, listing_data: ListingCreate):
        try:
            listing_dict = listing_data.dict()
            listing_dict["user_id"] = ObjectId(listing_data.user_id)
            listing_dict["created_at"] = datetime.utcnow()
            listing_dict["images"] = listing_dict.get("images", [])
            
            result = await self.db.listings.insert_one(listing_dict)
            return await self.get_listing_by_id(str(result.inserted_id))
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error creating listing: {str(e)}")

    async def update_listing(self, listing_id: str, listing_data: ListingUpdate):
        update_data = listing_data.dict(exclude_unset=True)
        update_data["updated_at"] = datetime.utcnow()
        
        result = await self.db.listings.update_one(
            {"_id": ObjectId(listing_id)},
            {"$set": update_data}
        )
        if result.modified_count:
            return await self.get_listing_by_id(listing_id)
        return None

    async def delete_listing(self, listing_id: str):
        result = await self.db.listings.delete_one(
            {"_id": ObjectId(listing_id)}
        )
        return result.deleted_count > 0

    async def get_all_listings(self, skip: int = 0, limit: int = 10):
        try:
            cursor = self.db.listings.find().sort("created_at", -1).skip(skip).limit(limit)
            listings = await cursor.to_list(length=limit)
            
            for listing in listings:
                user = await self.db.users.find_one({"_id": listing["user_id"]})
                if user:
                    listing["user"] = {
                        "id": str(user["_id"]),
                        "name": user.get("fullName"),
                        "email": user["email"],
                        "profilePhoto": user.get("profile", {}).get("profilePhoto")
                    }
                listing["_id"] = str(listing["_id"])
                listing["user_id"] = str(listing["user_id"])
            
            return listings
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error fetching listings: {str(e)}")

    async def get_user_listings(self, user_id: str):
        cursor = self.db.listings.find({"user_id": ObjectId(user_id)})
        listings = await cursor.to_list(length=None)
        
        for listing in listings:
            user = await self.db.users.find_one({"_id": listing["user_id"]})
            listing["user"] = {
                "id": str(user["_id"]),
                "name": user.get("fullName"),
                "email": user["email"]
            }
        return listings

    async def get_listings_by_university(self, university: str, skip: int = 0, limit: int = 10):
        cursor = self.db.listings.find(
            {"university": {"$regex": university, "$options": "i"}}
        ).skip(skip).limit(limit)
        
        listings = await cursor.to_list(length=limit)
        
        for listing in listings:
            user = await self.db.users.find_one({"_id": listing["user_id"]})
            listing["user"] = {
                "id": str(user["_id"]),
                "name": user.get("fullName"),
                "email": user["email"]
            }
        return listings

    async def upload_listing_image(self, listing_id: str, image: UploadFile) -> str:
        upload_dir = "uploads/listings"
        os.makedirs(upload_dir, exist_ok=True)
        
        file_extension = image.filename.split(".")[-1]
        file_name = f"{listing_id}_{datetime.utcnow().timestamp()}.{file_extension}"
        file_path = os.path.join(upload_dir, file_name)
        
        async with aiofiles.open(file_path, 'wb') as out_file:
            content = await image.read()
            await out_file.write(content)
            
        return f"/static/listings/{file_name}"