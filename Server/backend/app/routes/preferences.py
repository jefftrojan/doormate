from fastapi import APIRouter, HTTPException, Depends
from ..models.user import UserPreferences
from ..services.matching import MatchingService
from ..models.matching_data import MatchingData
from typing import List

router = APIRouter()
matching_service = MatchingService()

@router.post("/update")
async def update_preferences(
    preferences: UserPreferences,
    current_user = Depends(get_current_user)
):
    try:
        # Update user preferences
        await db.users.update_one(
            {"_id": current_user["_id"]},
            {"$set": {"preferences": preferences.dict()}}
        )

        # Find potential matches
        other_users = await db.users.find(
            {"_id": {"$ne": current_user["_id"]}}
        ).to_list(length=100)

        # Calculate compatibility scores with detailed breakdown
        matches = []
        for other in other_users:
            if "preferences" in other:
                compatibility = matching_service.calculate_compatibility(
                    preferences.dict(),
                    other["preferences"]
                )
                
                # Store matching data for model training
                matching_data = MatchingData(
                    user1_preferences=preferences.dict(),
                    user2_preferences=other["preferences"],
                    compatibility_score=compatibility["total_score"]
                )
                await db.matching_data.insert_one(matching_data.dict())

                matches.append({
                    "user_id": str(other["_id"]),
                    "email": other["email"],
                    "compatibility": compatibility["total_score"],
                    "breakdown": compatibility["breakdown"]
                })

        # Sort by compatibility
        matches.sort(key=lambda x: x["compatibility"], reverse=True)

        return {
            "success": True,
            "potential_matches": matches[:5],  # Return top 5 matches
            "match_details": {
                "total_matches": len(matches),
                "average_score": sum(m["compatibility"] for m in matches) / len(matches) if matches else 0
            }
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))