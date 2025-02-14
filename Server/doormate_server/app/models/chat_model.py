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


class MessageContent(BaseModel):
    text: Optional[str] = None
    media_url: Optional[str] = None
    media_type: Optional[str] = None  # image, video, document
    room_share: Optional[PyObjectId] = None  # Reference to a room listing

class MessageStatus(BaseModel):
    is_delivered: bool = False
    is_read: bool = False
    delivered_at: Optional[datetime] = None
    read_at: Optional[datetime] = None

class Message(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    chat_id: PyObjectId
    sender_id: PyObjectId
    content: MessageContent
    status: Dict[str, MessageStatus] = {}  # Map of user_id to MessageStatus
    is_system_message: bool = False
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    updated_at: Optional[datetime] = None
    deleted_for: List[PyObjectId] = []  # List of users who deleted this message

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}

class ChatMember(BaseModel):
    user_id: PyObjectId
    joined_at: datetime = Field(default_factory=datetime.utcnow)
    last_read: datetime = Field(default_factory=datetime.utcnow)
    is_admin: bool = False
    muted_until: Optional[datetime] = None

class Chat(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    chat_type: str = "direct"  # direct, group
    members: Dict[str, ChatMember]  # Map of user_id to ChatMember
    match_id: Optional[PyObjectId] = None  # Reference to Match model if exists
    last_message: Optional[Message] = None
    
    # Group chat specific fields
    title: Optional[str] = None
    description: Optional[str] = None
    picture: Optional[str] = None
    
    # Metadata
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    is_active: bool = True

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}

# Helper Enums for Chat System
from enum import Enum

class ChatType(str, Enum):
    DIRECT = "direct"
    GROUP = "group"

class MessageType(str, Enum):
    TEXT = "text"
    IMAGE = "image"
    VIDEO = "video"
    DOCUMENT = "document"
    ROOM_SHARE = "room_share"
    SYSTEM = "system"