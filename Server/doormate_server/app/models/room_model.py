from typing import List
from pydantic import BaseModel, Field
from datetime import datetime
from bson import ObjectId

class RoomModel(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    owner_id: PyObjectId
    location: dict = {
        "type": "Point",
        "coordinates": List[float],
        "address": str
    }
    price: float
    room_type: str  # private, shared
    amenities: List[str]
    photos: List[str]  # URLs to photos
    current_residents: List[PyObjectId]
    available_from: datetime
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}