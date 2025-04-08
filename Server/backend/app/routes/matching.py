from fastapi import APIRouter, HTTPException, Depends, Query
from ..models.matching_data import MatchingData
from ..services.matching import MatchingService
from ..utils.auth import get_current_user
from typing import List, Dict
from bson import ObjectId
from ..database import db

router = APIRouter()
matching_service = MatchingService()

@router.get("/matches", response_model=List[Dict])
async def get_potential_matches(current_user = Depends(get_current_user)):
    """Get potential roommate matches for the current user based on preferences"""
    try:
        # Get current user's preferences
        user_id = str(current_user["_id"])
        user_preferences = current_user.get("preferences", {})
        
        print(f"Current user ID: {user_id}")
        print(f"User preferences: {user_preferences}")
        
        # Log how many users exist in total
        total_users = await db.users.count_documents({})
        print(f"Total users in database: {total_users}")
        
        # Find other users with preferences
        other_users = []
        users_cursor = db.users.find(
            {"_id": {"$ne": ObjectId(user_id)}},
            {"_id": 1, "fullName": 1, "email": 1, "preferences": 1, "profile": 1}
        )
        
        async for user in users_cursor:
            other_users.append(user)
        
        print(f"Found {len(other_users)} other users")
        
        # Calculate compatibility and sort by match score
        matches = []
        for other_user in other_users:
            other_preferences = other_user.get("preferences", {})
            
            if not other_preferences:
                print(f"User {other_user.get('_id')} has no preferences")
                continue
            
            compatibility = matching_service.calculate_compatibility(
                user_preferences, other_preferences
            )
            
            print(f"Compatibility with user {other_user.get('_id')}: {compatibility['total_score']}")
            
            # Only include matches with compatibility above 0.3 (for testing)
            if compatibility["total_score"] > 0.3:
                matches.append({
                    "user": {
                        "id": str(other_user["_id"]),
                        "name": other_user.get("profile", {}).get("fullName", ""),
                        "email": other_user.get("email", ""),
                        "profile_photo": other_user.get("profile", {}).get("profilePhoto")
                    },
                    "compatibility_score": compatibility["total_score"],
                    "compatibility_breakdown": compatibility["breakdown"]
                })
        
        print(f"Returning {len(matches)} potential matches")
        
        # Sort by highest compatibility score
        matches.sort(key=lambda x: x["compatibility_score"], reverse=True)
        
        return matches
    except Exception as e:
        print(f"Error in get_potential_matches: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error finding matches: {str(e)}")

@router.post("/matches/{match_user_id}/confirm")
async def confirm_match(
    match_user_id: str,
    current_user = Depends(get_current_user)
):
    """
    Confirm interest in a potential match
    """
    try:
        user_id = str(current_user["_id"])
        
        # Add to user's confirmed matches
        user_result = await db.users.update_one(
            {"_id": ObjectId(user_id)},
            {"$addToSet": {"confirmed_matches": match_user_id}}
        )
        
        # Check if match has already confirmed this user
        match_user = await db.users.find_one(
            {"_id": ObjectId(match_user_id)}
        )
        
        mutual_match = False
        if match_user and "confirmed_matches" in match_user:
            if user_id in match_user["confirmed_matches"]:
                # It's a mutual match!
                mutual_match = True
                
                # Create a match record
                match_data = MatchingData(
                    user1_preferences=current_user.get("preferences", {}),
                    user2_preferences=match_user.get("preferences", {}),
                    match_success=True,
                    compatibility_score=0.0  # Calculate this properly
                )
                
                # Save to database
                await db.matches.insert_one(match_data.dict())
        
        return {
            "success": True,
            "mutual_match": mutual_match,
            "message": "Match confirmed" if not mutual_match else "It's a match!"
        }
                
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error confirming match: {str(e)}")

@router.delete("/matches/{match_user_id}")
async def reject_match(
    match_user_id: str,
    current_user = Depends(get_current_user)
):
    """
    Reject a potential match or remove a confirmed match
    """
    try:
        user_id = str(current_user["_id"])
        
        # Remove from user's confirmed matches (if present)
        user_result = await db.users.update_one(
            {"_id": ObjectId(user_id)},
            {"$pull": {"confirmed_matches": match_user_id}}
        )
        
        # Add to rejected matches
        await db.users.update_one(
            {"_id": ObjectId(user_id)},
            {"$addToSet": {"rejected_matches": match_user_id}}
        )
        
        return {"success": True, "message": "Match rejected"}
                
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error rejecting match: {str(e)}")

@router.get("/matches/mutual", response_model=List[Dict])
async def get_mutual_matches(
    current_user = Depends(get_current_user)
):
    """
    Get all mutual matches (where both users have confirmed each other)
    """
    try:
        user_id = str(current_user["_id"])
        
        # Get user's confirmed matches
        user = await db.users.find_one({"_id": ObjectId(user_id)})
        confirmed_matches = user.get("confirmed_matches", [])
        
        if not confirmed_matches:
            return []
        
        # Find users who have also confirmed this user
        mutual_matches = []
        
        for match_id in confirmed_matches:
            match_user = await db.users.find_one({
                "_id": ObjectId(match_id),
                "confirmed_matches": user_id
            })
            
            if match_user:
                mutual_matches.append({
                    "user": {
                        "id": str(match_user["_id"]),
                        "name": match_user.get("fullName", ""),
                        "email": match_user.get("email", ""),
                        "profile_photo": match_user.get("profile", {}).get("profilePhoto")
                    }
                })
        
        return mutual_matches
                
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting mutual matches: {str(e)}")