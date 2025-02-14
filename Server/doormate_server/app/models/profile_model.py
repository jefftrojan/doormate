from datetime import datetime
from typing import List, Optional, Dict
from pydantic import BaseModel, Field, EmailStr, validator
from bson import ObjectId

class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid ObjectId")
        return ObjectId(v)

    @classmethod
    def __modify_schema__(cls, field_schema):
        field_schema.update(type="string")

class UserPreferences(BaseModel):
    cleanliness: float = Field(..., ge=1, le=5, description="Cleanliness preference scale 1-5")
    noise_tolerance: float = Field(..., ge=1, le=5, description="Noise tolerance scale 1-5")
    social_level: float = Field(..., ge=1, le=5, description="Sociability scale 1-5")
    study_habits: float = Field(..., ge=1, le=5, description="Study frequency scale 1-5")
    wake_up_time: float = Field(..., ge=0, le=24, description="Wake up time in 24h format")
    sleep_time: float = Field(..., ge=0, le=24, description="Sleep time in 24h format")
    budget: float = Field(..., ge=0, description="Monthly budget in local currency")
    smoking: bool = Field(..., description="Smoking preference")
    pets: bool = Field(..., description="Pet preference")

    @validator('wake_up_time', 'sleep_time')
    def validate_time(cls, v):
        if not 0 <= v <= 24:
            raise ValueError("Time must be between 0 and 24")
        return v

class Location(BaseModel):
    type: str = "Point"
    coordinates: List[float]  # [longitude, latitude]
    address: str
    city: str
    country: str = "Rwanda"

class Education(BaseModel):
    university: str
    year_of_study: int = Field(..., ge=1, le=6)
    course: str
    student_id: str

class Profile(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    user_id: PyObjectId = Field(..., description="Reference to User model")
    email: EmailStr
    full_name: str = Field(..., min_length=2, max_length=100)
    age: int = Field(..., ge=16, le=100)
    gender: str = Field(..., description="Gender identity")
    phone_number: Optional[str] = None
    
    # Education details
    education: Education
    
    # Preferences for matching
    preferences: UserPreferences
    
    # Location information
    location: Location
    
    # Profile media
    profile_picture: Optional[str] = None
    gallery_pictures: List[str] = []
    
    # Profile status
    is_verified: bool = False
    verification_documents: List[str] = []
    is_active: bool = True
    
    # Bio and additional info
    bio: Optional[str] = Field(None, max_length=500)
    interests: List[str] = []
    languages: List[str] = ["English"]
    
    # Timestamps
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    last_active: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}