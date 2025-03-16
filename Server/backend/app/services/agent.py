import os
import json
import logging
from typing import Dict, List, Optional, Any
# from vapi import Vapi  # Commented out due to unavailability
from ..database import db
from ..models.listing import Listing
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Mock Vapi implementation
class MockVapi:
    class Assistants:
        def create(self, **kwargs):
            class Assistant:
                def __init__(self, id):
                    self.id = id
            return Assistant("mock-assistant-id")
    
    class Conversations:
        def create(self, **kwargs):
            class Conversation:
                def __init__(self, id):
                    self.id = id
            return Conversation("mock-conversation-id")
    
    class Messages:
        def create(self, **kwargs):
            return None
        
        def list(self, **kwargs):
            class MessageResponse:
                def __init__(self):
                    class Message:
                        def __init__(self):
                            self.id = "mock-message-id"
                            self.content = "This is a mock response from the AI assistant. I'm here to help you find housing in Kigali!"
                            self.role = "assistant"
                            self.created_at = "2023-06-01T12:00:00Z"
                    self.data = [Message()]
            return MessageResponse()
    
    def __init__(self, api_key=None):
        self.assistants = self.Assistants()
        self.conversations = self.Conversations()
        self.messages = self.Messages()

class AgentService:
    """Service for handling AI agent interactions using vapi."""
    
    def __init__(self):
        """Initialize the agent service with vapi client."""
        self.vapi_api_key = os.getenv("VAPI_API_KEY")
        if not self.vapi_api_key:
            logger.warning("VAPI_API_KEY not found in environment variables")
        
        # Use MockVapi instead of real Vapi
        self.vapi_client = MockVapi(api_key=self.vapi_api_key)
        self.assistant_id = os.getenv("VAPI_ASSISTANT_ID")
        
        # Knowledge base for the agent
        self.knowledge_base = {
            "locations": ["Kigali", "Nyamirambo", "Kimihurura", "Kacyiru", "Gikondo", "Remera"],
            "universities": ["African Leadership University", "University of Rwanda", "Mount Kenya University Rwanda", "Carnegie Mellon University Africa"],
            "housing_types": ["Shared apartment", "Studio", "Single room", "Entire house", "University dormitory"]
        }
    
    async def initialize(self, db_instance):
        """Initialize the service with database connection."""
        self.db = db_instance
        
        # Create assistant if it doesn't exist
        if not self.assistant_id and self.vapi_client:
            await self.create_assistant()
    
    async def create_assistant(self):
        """Create a new assistant in vapi."""
        try:
            # Define the assistant
            assistant = self.vapi_client.assistants.create(
                name="DoorMate Housing Assistant",
                model="gpt-4o",
                instructions="""You are DoorMate's AI housing assistant specializing in helping students find shared housing in Kigali, Rwanda.
                Your primary goal is to assist students in finding suitable accommodation based on their preferences, budget, and location.
                You should be friendly, helpful, and knowledgeable about the housing market in Kigali.
                When users ask about listings, use the database to provide accurate information.
                Always maintain a conversational tone and ask clarifying questions when needed.""",
                tools=[{"type": "retrieval"}]
            )
            
            self.assistant_id = assistant.id
            logger.info(f"Created new assistant with ID: {self.assistant_id}")
            
            # Save the assistant ID to environment variables
            # Note: This doesn't actually modify the .env file, just the runtime environment
            os.environ["VAPI_ASSISTANT_ID"] = self.assistant_id
            
            return self.assistant_id
        except Exception as e:
            logger.error(f"Error creating assistant: {str(e)}")
            return None
    
    async def get_housing_data(self) -> List[Dict[str, Any]]:
        """Get housing data from the database to provide to the agent."""
        try:
            # Get all active listings from the database
            listings = await self.db.listings.find({"status": "active"}).to_list(length=100)
            
            # Convert ObjectId to string for JSON serialization
            for listing in listings:
                listing["_id"] = str(listing["_id"])
                if "owner_id" in listing:
                    listing["owner_id"] = str(listing["owner_id"])
            
            return listings
        except Exception as e:
            logger.error(f"Error fetching housing data: {str(e)}")
            return []
    
    async def create_conversation(self, user_id: str) -> Optional[str]:
        """Create a new conversation for a user."""
        if not self.vapi_client or not self.assistant_id:
            logger.error("Vapi client or assistant ID not available")
            return None
        
        try:
            # Create a new conversation
            conversation = self.vapi_client.conversations.create(
                assistant_id=self.assistant_id,
                user_id=user_id
            )
            
            return conversation.id
        except Exception as e:
            logger.error(f"Error creating conversation: {str(e)}")
            return None
    
    async def send_message(self, conversation_id: str, message: str) -> Optional[Dict[str, Any]]:
        """Send a message to the assistant and get a response."""
        if not self.vapi_client:
            logger.error("Vapi client not available")
            return None
        
        try:
            # Get housing data to provide context
            housing_data = await self.get_housing_data()
            
            # Send message with housing data as context
            message_with_context = f"{message}\n\nAvailable listings: {json.dumps(housing_data)}"
            
            # Send the message to the conversation
            response = self.vapi_client.messages.create(
                conversation_id=conversation_id,
                role="user",
                content=message_with_context
            )
            
            # Wait for the assistant to respond
            response = self.vapi_client.messages.list(conversation_id=conversation_id, order="desc", limit=1)
            
            if response.data and len(response.data) > 0:
                return {
                    "id": response.data[0].id,
                    "content": response.data[0].content,
                    "role": response.data[0].role
                }
            return None
        except Exception as e:
            logger.error(f"Error sending message: {str(e)}")
            return None
    
    async def get_conversation_history(self, conversation_id: str) -> List[Dict[str, Any]]:
        """Get the conversation history."""
        if not self.vapi_client:
            logger.error("Vapi client not available")
            return []
        
        try:
            # Get all messages in the conversation
            messages = self.vapi_client.messages.list(conversation_id=conversation_id)
            
            # Format the messages
            formatted_messages = []
            for message in messages.data:
                formatted_messages.append({
                    "id": message.id,
                    "content": message.content,
                    "role": message.role,
                    "created_at": message.created_at
                })
            
            return formatted_messages
        except Exception as e:
            logger.error(f"Error getting conversation history: {str(e)}")
            return [] 