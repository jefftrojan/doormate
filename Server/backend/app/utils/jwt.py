from datetime import datetime, timedelta
from jose import jwt
import os
from dotenv import load_dotenv

load_dotenv()

def create_access_token(data: dict) -> str:
    """
    Create a JWT access token with the given data
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "1440")))
    to_encode.update({"exp": expire})
    
    return jwt.encode(
        to_encode, 
        os.getenv("JWT_SECRET"), 
        algorithm=os.getenv("JWT_ALGORITHM", "HS256")
    )

def verify_token(token: str) -> dict:
    """
    Verify a JWT token and return its payload
    """
    try:
        payload = jwt.decode(
            token, 
            os.getenv("JWT_SECRET"), 
            algorithms=[os.getenv("JWT_ALGORITHM", "HS256")]
        )
        return payload
    except Exception as e:
        raise ValueError(f"Invalid token: {str(e)}")