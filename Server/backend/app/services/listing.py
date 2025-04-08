from bson import ObjectId
from ..models.listing import Listing, ListingCreate, ListingUpdate
from datetime import datetime
from fastapi import UploadFile, HTTPException
import os
import aiofiles
from ..database import db
from motor.motor_asyncio import AsyncIOMotorDatabase
from bson import ObjectId

class ListingService:
    def __init__(self):
        # self.db: AsyncIOMotorDatabase = None
        self.db = db
    def initialize(self, db: AsyncIOMotorDatabase):
        # if not db:
        #     raise ValueError("Database connection cannot be None")
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
        print(f"Creating listing with data: {listing_data}")

        listing_dict = listing_data.dict()

        try:
            listing_dict["user_id"] = ObjectId(listing_data.user_id)

        except Exception as user_id_error:
            print(f"Invalid user_id format: {str(user_id_error)}")
            raise ValueError(f"Invalid user)id format: {str(user_id_error)}")

        listing_dict["created_at"] = datetime.utcnow()
        listing_dict["images"] = listing_dict.get("images", [])

        result = await self.db.listings.insert_one(listing_dict)
        return await self.get_listing_by_id(str(result.inserted_id))
      except Exception as e:
          import traceback
          traceback.print_exc()
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

    async def get_all_listings(self, skip: int = 0, limit: int = 10, search: str = None, min_price: str = None, max_price: str = None, location: str = None, sort_by: str = None):
        try:
            filter_query = {}

            if search:
                filter_query = {
                "$or": [
                    {"title": {"$regex": search, "$options": "i"}},
                    {"description": {"$regex": search, "$options": "i"}},
                    {"location": {"$regex": search, "$options": "i"}},
                    {"university": {"$regex": search, "$options": "i"}},
                ]
            }
            cursor = self.db.listings.find(filter_query).sort("created_at", -1).skip(skip).limit(limit)
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
            if user:
                listing["user"] = {
                    "id": str(user["_id"]),
                    "name": user.get("fullName"),
                    "email": user["email"]
                }
            # Convert ObjectIds to strings for JSON serialization
            listing["_id"] = str(listing["_id"])
            listing["user_id"] = str(listing["user_id"])
        return listings

    async def get_listings_by_university(self, university: str, skip: int = 0, limit: int = 10):
        cursor = self.db.listings.find(
            {"university": {"$regex": university, "$options": "i"}}
        ).skip(skip).limit(limit)
        
        listings = await cursor.to_list(length=limit)
        
        for listing in listings:
            user = await self.db.users.find_one({"_id": listing["user_id"]})
            if user:
                listing["user"] = {
                    "id": str(user["_id"]),
                    "name": user.get("fullName"),
                    "email": user["email"]
                }
            # Convert ObjectIds to strings for JSON serialization
            listing["_id"] = str(listing["_id"])
            listing["user_id"] = str(listing["user_id"])
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
        
    # New methods for saved listings functionality
    
    async def get_saved_listings(self, user_id: str):
        """
        Get all listings saved by a specific user
        """
        try:
            # Get user document to find saved listings
            user = await self.db.users.find_one({"_id": ObjectId(user_id)})
            
            if not user or "saved_listings" not in user or not user.get("saved_listings"):
                # If user has no saved listings, return empty list
                return []
            
            # Convert saved_listings strings to ObjectIds
            saved_listing_ids = [ObjectId(listing_id) for listing_id in user.get("saved_listings", [])]
            
            # Fetch the actual listing documents
            cursor = self.db.listings.find({"_id": {"$in": saved_listing_ids}})
            listings = await cursor.to_list(length=None)
            
            # Add user info and format listings
            for listing in listings:
                owner = await self.db.users.find_one({"_id": listing["user_id"]})
                if owner:
                    listing["user"] = {
                        "id": str(owner["_id"]),
                        "name": owner.get("fullName"),
                        "email": owner["email"],
                        "profilePhoto": owner.get("profile", {}).get("profilePhoto")
                    }
                
                # Add is_saved flag for frontend
                listing["is_saved"] = True
                
                # Convert ObjectIds to strings for JSON serialization
                listing["_id"] = str(listing["_id"])
                listing["user_id"] = str(listing["user_id"])
            
            return listings
        except Exception as e:
            print(f"Error in get_saved_listings: {str(e)}")
            raise HTTPException(status_code=500, detail=f"Error fetching saved listings: {str(e)}")

    async def save_listing(self, listing_id: str, user_id: str):
        """
        Save a listing for a user
        """
        try:
            # Check if listing exists
            listing = await self.db.listings.find_one({"_id": ObjectId(listing_id)})
            if not listing:
                return False
            
            # Add listing to user's saved_listings
            result = await self.db.users.update_one(
                {"_id": ObjectId(user_id)},
                {"$addToSet": {"saved_listings": listing_id}}
            )
            
            return result.modified_count > 0 or result.matched_count > 0
        except Exception as e:
            print(f"Error in save_listing: {str(e)}")
            raise HTTPException(status_code=500, detail=f"Error saving listing: {str(e)}")

    async def unsave_listing(self, listing_id: str, user_id: str):
        """
        Remove a listing from a user's saved listings
        """
        try:
            # Remove listing from user's saved_listings
            result = await self.db.users.update_one(
                {"_id": ObjectId(user_id)},
                {"$pull": {"saved_listings": listing_id}}
            )
            
            return result.modified_count > 0 or result.matched_count > 0
        except Exception as e:
            print(f"Error in unsave_listing: {str(e)}")
            raise HTTPException(status_code=500, detail=f"Error unsaving listing: {str(e)}")