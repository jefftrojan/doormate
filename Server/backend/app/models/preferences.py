from pydantic import BaseModel, Field
from typing import Optional

class LifestylePreferences(BaseModel):
    cleanliness: Optional[int] = Field(None, ge=1, le=5, description="Cleanliness level from 1 (relaxed) to 5 (very clean)")
    noiseLevel: Optional[float] = Field(None, ge=0, le=100, description="Noise tolerance as percentage (0=quiet, 100=loud)")
    studyHabits: Optional[str] = None
    socialLevel: Optional[str] = None
    wakeUpTime: Optional[str] = None
    sleepTime: Optional[str] = None
    
    class Config:
        extra = "allow"  # Allow extra fields that aren't in the model

class LocationPreferences(BaseModel):
    preferredArea: Optional[str] = None
    maxDistance: Optional[float] = Field(None, ge=0)
    budget: Optional[float] = Field(None, ge=0)
    hasTransportation: Optional[bool] = False
    
    class Config:
        extra = "allow"  # Allow extra fields that aren't in the model

class UserPreferences(BaseModel):
    lifestyle: Optional[LifestylePreferences] = None
    location: Optional[LocationPreferences] = None
    
    class Config:
        extra = "allow"  # Allow extra fields that aren't in the model