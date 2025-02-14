from pydantic import BaseModel, Field
from datetime import datetime
from bson import ObjectId

class MatchModel(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    user1_id: PyObjectId
    user2_id: PyObjectId
    compatibility_score: float
    compatibility_breakdown: dict
    status: str = "pending"  # pending, accepted, rejected
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}