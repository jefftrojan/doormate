from fastapi import APIRouter, HTTPException, Depends
from ..models.feedback import MatchFeedback
from ..utils.auth import get_current_user
from bson import ObjectId

router = APIRouter()

@router.post("/match-feedback")
async def submit_match_feedback(
    feedback: MatchFeedback,
    current_user = Depends(get_current_user)
):
    try:
        # Store feedback
        feedback_data = feedback.dict()
        feedback_data["user_id"] = current_user["_id"]
        await db.feedback.insert_one(feedback_data)

        # Update matching data with feedback
        await db.matching_data.update_one(
            {"_id": ObjectId(feedback.match_id)},
            {
                "$set": {
                    "feedback_rating": feedback.rating,
                    "match_success": feedback.rating >= 4.0
                }
            }
        )

        return {"success": True, "message": "Feedback submitted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/match-stats/{match_id}")
async def get_match_stats(
    match_id: str,
    current_user = Depends(get_current_user)
):
    try:
        match_data = await db.matching_data.find_one({"_id": ObjectId(match_id)})
        if not match_data:
            raise HTTPException(status_code=404, detail="Match not found")

        feedback = await db.feedback.find_one({
            "match_id": match_id,
            "user_id": current_user["_id"]
        })

        return {
            "compatibility_score": match_data["compatibility_score"],
            "user_feedback": feedback["rating"] if feedback else None,
            "match_success": match_data.get("match_success", False)
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))