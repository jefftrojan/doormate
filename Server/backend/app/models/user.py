from pydantic import BaseModel, EmailStr, Field, ConfigDict
from datetime import datetime
from typing import Optional
from bson import ObjectId


class PyObjectId(str):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if isinstance(v, ObjectId):
            return str(v)
        return v

class UserBase(BaseModel):
    email: EmailStr

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)
    fullName: str
    university: str
    yearOfStudy: str
    studentId: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserProfile(BaseModel):
    fullName: Optional[str] = None
    dateOfBirth: Optional[str] = None
    gender: Optional[str] = None
    university: Optional[str] = None
    yearOfStudy: Optional[str] = None
    profilePhoto: Optional[str] = None
    studentId: Optional[str] = None

class User(UserBase):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    profile: Optional[UserProfile] = None
    verified: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)

    model_config = ConfigDict(
        populate_by_name=True,
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str}
    )

class UserResponse(UserBase):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    verified: bool = False
    created_at: datetime

    model_config = ConfigDict(
        populate_by_name=True,
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str}
    )

class LifestylePreferences(BaseModel):
    cleanliness: int = Field(..., ge=1, le=5, description="Cleanliness level from 1 (relaxed) to 5 (very clean)")
    noiseLevel: float = Field(..., ge=0, le=100, description="Noise tolerance as percentage (0=quiet, 100=loud)")
    studyHabits: str = Field(..., description="Study habits (e.g., 'Early morning', 'Late night', 'Afternoon')")
    socialLevel: str = Field(..., description="Social preferences (e.g., 'Very private', 'Balanced', 'Very social')")
    wakeUpTime: str = Field(..., description="Typical wake-up time (e.g., '7:00 AM')")
    sleepTime: str = Field(..., description="Typical sleep time (e.g., '11:00 PM')")

class LocationPreferences(BaseModel):
    preferredArea: str = Field(..., description="Preferred housing area")
    maxDistance: float = Field(..., ge=0, description="Maximum distance from campus in km")
    budget: float = Field(..., ge=0, description="Monthly budget (USD)")
    hasTransportation: bool = Field(False, description="Whether the user has their own transportation")

class UserPreferences(BaseModel):
    lifestyle: Optional[LifestylePreferences] = None
    location: Optional[LocationPreferences] = None

class OTPVerify(BaseModel):
    email: EmailStr
    otp: str

class PasswordUpdate(BaseModel):
    current_password: str
    new_password: str = Field(..., min_length=8)

class InitialPasswordSet(BaseModel):
    new_password: str = Field(..., min_length=8)
    