from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from typing import Dict, List, Optional, Any
from ..services.agent import AgentService
from ..services.auth import AuthService
from ..database import db
from pydantic import BaseModel

router = APIRouter()
agent_service = AgentService()
auth_service = AuthService()

# Initialize services
@router.on_event("startup")
async def startup_db_client():
    await agent_service.initialize(db)

# OAuth2 scheme for token authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/token")

# Pydantic models for request and response
class MessageRequest(BaseModel):
    message: str

class MessageResponse(BaseModel):
    id: str
    content: str
    role: str

class ConversationResponse(BaseModel):
    id: str
    messages: List[Dict[str, Any]]

# Dependency to get current user
async def get_current_user(token: str = Depends(oauth2_scheme)):
    user = await auth_service.get_current_user(token)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user

@router.post("/conversation", response_model=Dict[str, str])
async def create_conversation(user = Depends(get_current_user)):
    """Create a new conversation with the AI agent."""
    conversation_id = await agent_service.create_conversation(str(user["_id"]))
    if not conversation_id:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create conversation"
        )
    return {"conversation_id": conversation_id}

@router.post("/conversation/{conversation_id}/message", response_model=MessageResponse)
async def send_message(
    conversation_id: str,
    request: MessageRequest,
    user = Depends(get_current_user)
):
    """Send a message to the AI agent and get a response."""
    response = await agent_service.send_message(conversation_id, request.message)
    if not response:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get response from agent"
        )
    return response

@router.get("/conversation/{conversation_id}", response_model=List[Dict[str, Any]])
async def get_conversation_history(
    conversation_id: str,
    user = Depends(get_current_user)
):
    """Get the conversation history."""
    messages = await agent_service.get_conversation_history(conversation_id)
    return messages 