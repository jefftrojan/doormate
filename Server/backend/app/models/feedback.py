from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class MatchFeedback(BaseModel):
    match_id: str
    user_id: str
    rating: float  # 1-5 rating
    comment: Optional[str] = None
    created_at: datetime = datetime.utcnow()