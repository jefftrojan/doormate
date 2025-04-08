from typing import List, Optional
from datetime import datetime
from .database import DBModelBase, PyObjectId
from pydantic import Field

class ListingBase(DBModelBase):
    title: str
    description: str
    price: float
    location: str
    images: List[str] = []
    amenities: List[str] = []
    university: str
    room_type: str
    available_from: datetime
    available_until: Optional[datetime] = None
    user_id: PyObjectId

class ListingCreate(ListingBase):
    title: str 
    description: str
    price: float 
    location: str 
    images: List[str] = []
    amenities: List[str] = []
    university: str 
    room_type: str 
    available_from: datetime
    available_until: datetime
    user_id: PyObjectId

class ListingUpdate(ListingBase):
    title: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    location: Optional[str] = None
    images: Optional[List[str]] = None
    amenities: Optional[List[str]] = None
    university: Optional[str] = None
    room_type: Optional[str] = None
    available_from: Optional[datetime] = None
    available_until: Optional[datetime] = None

class Listing(ListingBase):
    user: dict = {}