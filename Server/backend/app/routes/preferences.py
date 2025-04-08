# File: app/routes/preferences.py
from fastapi import APIRouter, HTTPException, Depends
from ..models.preferences import LifestylePreferences, LocationPreferences, UserPreferences
from ..utils.auth import get_current_user
from bson import ObjectId
from ..database import db

router = APIRouter()

@router.get("/")
async def get_preferences(
    current_user = Depends(get_current_user)
):
    """
    Get user's preferences for roommate matching
    """
    try:
        user_id = current_user["_id"]
        
        # Get the user with preferences
        user = await db.users.find_one({"_id": user_id})
        
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # Return preferences or empty object if not set
        preferences = user.get("preferences", {})
        
        return preferences
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error fetching preferences: {str(e)}")

@router.post("/lifestyle")
async def update_lifestyle_preferences(
    preferences: LifestylePreferences,
    current_user = Depends(get_current_user)
):
    """
    Update user's lifestyle preferences for roommate matching
    """
    try:
        user_id = current_user["_id"]
        
        # Ensure preferences object exists
        await db.users.update_one(
            {"_id": user_id},
            {"$setOnInsert": {"preferences": {}}}
        )
        
        # Update the user document with new preferences
        result = await db.users.update_one(
            {"_id": user_id},
            {"$set": {"preferences.lifestyle": preferences.dict()}}
        )
        
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="User not found")
        
        return {"success": True, "message": "Lifestyle preferences updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error updating preferences: {str(e)}")

@router.post("/location")
async def update_location_preferences(
    preferences: LocationPreferences,
    current_user = Depends(get_current_user)
):
    """
    Update user's location preferences for roommate matching
    """
    try:
        user_id = current_user["_id"]
        
        # Ensure preferences object exists
        await db.users.update_one(
            {"_id": user_id},
            {"$setOnInsert": {"preferences": {}}}
        )
        
        # Update the user document with new preferences
        result = await db.users.update_one(
            {"_id": user_id},
            {"$set": {"preferences.location": preferences.dict()}}
        )
        
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="User not found")
        
        return {"success": True, "message": "Location preferences updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error updating preferences: {str(e)}")

@router.post("/")
async def update_all_preferences(
    preferences: UserPreferences,
    current_user = Depends(get_current_user)
):
    """
    Update all user preferences at once
    """
    try:
        user_id = current_user["_id"]
        
        # Update the user document with all preferences
        result = await db.users.update_one(
            {"_id": user_id},
            {"$set": {"preferences": preferences.dict()}}
        )
        
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="User not found")
        
        return {"success": True, "message": "Preferences updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error updating preferences: {str(e)}")