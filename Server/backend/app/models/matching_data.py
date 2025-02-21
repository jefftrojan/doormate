from datetime import datetime
from pydantic import BaseModel
from typing import Dict

class MatchingData(BaseModel):
    user1_preferences: Dict
    user2_preferences: Dict
    match_success: bool = False
    compatibility_score: float
    feedback_rating: float = 0.0
    created_at: datetime = datetime.utcnow()