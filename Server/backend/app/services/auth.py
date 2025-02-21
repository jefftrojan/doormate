from datetime import datetime, timedelta
from jose import jwt
import os
from dotenv import load_dotenv
import random
import string
from bson import ObjectId
from motor.motor_asyncio import AsyncIOMotorClient
from ..utils.dev_email import DevEmailService
from ..models.user import UserCreate  

from passlib.context import CryptContext
from ..utils.email_service import EmailService

# Load environment variables
load_dotenv()

class AuthService:
    def __init__(self):
        self.secret_key = os.getenv("JWT_SECRET")
        self.algorithm = os.getenv("JWT_ALGORITHM")
        mongodb_url = os.getenv("MONGODB_URL")
        client = AsyncIOMotorClient(mongodb_url)
        self.db = client[os.getenv("DATABASE_NAME")]
        self.pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
        self.email_service = EmailService()

    def generate_otp(self) -> str:
        """Generate a 6-digit OTP"""
        return ''.join(random.choices(string.digits, k=6))

    async def register_user(self, user_data: UserCreate) -> str:
        # Check if user exists
        existing_user = await self.db.users.find_one({"email": user_data.email})
        if existing_user:
            raise ValueError("User already exists")

        # Validate password
        if len(user_data.password) < 8:
            raise ValueError("Password must be at least 8 characters long")

        # Generate and store OTP
        otp = self.generate_otp()
        print(f"Generated OTP for {user_data.email}: {otp}")
        
        # Hash password before storing
        user_dict = user_data.dict()
        user_dict["password"] = self.pwd_context.hash(user_data.password)
        
        otp_data = {
            "email": user_data.email,
            "otp": otp,
            "user_data": user_dict,
            "created_at": datetime.utcnow(),
            "expires_at": datetime.utcnow() + timedelta(minutes=10)
        }
        
        result = await self.db.otps.insert_one(otp_data)
        print(f"Stored OTP record with ID: {result.inserted_id}")
        
        # Verify the OTP was stored
        stored_otp = await self.db.otps.find_one({"_id": result.inserted_id})
        print(f"Verified stored OTP record: {stored_otp}")

        # Send email using EmailService
        email_sent = await self.email_service.send_otp_email(user_data.email, otp, is_registration=True)
        if not email_sent:
            raise ValueError("Failed to send verification email")

        return otp

    async def send_login_otp(self, email: str) -> None:
        user = await self.db.users.find_one({"email": email})
        if not user:
            raise ValueError("User not found")

        otp = self.generate_otp()
        await self.db.otps.insert_one({
            "email": email,
            "otp": otp,
            "created_at": datetime.utcnow(),
            "expires_at": datetime.utcnow() + timedelta(minutes=10)
        })

        # Send email using EmailService
        email_sent = await self.email_service.send_otp_email(email, otp, is_registration=False)
        if not email_sent:
            raise ValueError("Failed to send login code")

        # TODO: Send email with OTP
        print(f"Login OTP for {email}: {otp}")  # For development

    def create_access_token(self, data: dict) -> str:
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(minutes=int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES")))
        to_encode.update({"exp": expire})
        return jwt.encode(to_encode, self.secret_key, algorithm=self.algorithm)

    async def verify_otp(self, email: str, otp: str) -> dict:
        print(f"Verifying OTP for email: {email}, OTP: {otp}")
        
        # Find OTP record
        otp_record = await self.db.otps.find_one({
            "email": email,
            "otp": otp
        })
        
        print(f"Found OTP record: {otp_record}")
        
        if not otp_record:
            print("No OTP record found")
            raise ValueError("Invalid or expired OTP")
            
        # Check expiration separately
        if otp_record["expires_at"] < datetime.utcnow():
            print("OTP has expired")
            await self.db.otps.delete_many({"email": email})
            raise ValueError("OTP has expired")

        # Create user if not exists (for registration flow)
        user = await self.db.users.find_one({"email": email})
        if not user and "user_data" in otp_record:
            user_data = otp_record["user_data"]
            # Make sure password is already hashed from registration
            if "password" in user_data and not user_data["password"].startswith("$2b$"):
                user_data["password"] = self.pwd_context.hash(user_data["password"])
            user_data["verified"] = True
            user_data["created_at"] = datetime.utcnow()
            result = await self.db.users.insert_one(user_data)
            user = await self.db.users.find_one({"_id": result.inserted_id})

        # Convert ObjectId to string
        if user:
            user["_id"] = str(user["_id"])

        # Generate token
        access_token = self.create_access_token({"sub": str(user["_id"])})
        
        # Delete used OTP
        await self.db.otps.delete_many({"email": email})
        
        return {
            "token": access_token,
            "user": user
        }

    async def regenerate_otp(self, email: str) -> str:
        # Check if user has a pending registration
        existing_otp = await self.db.otps.find_one({"email": email})
        if not existing_otp:
            raise ValueError("No pending registration found for this email")

        # Generate new OTP
        otp = self.generate_otp()
        print(f"Regenerated OTP for {email}: {otp}")  # Debug log

        # Update OTP record
        await self.db.otps.update_one(
            {"email": email},
            {
                "$set": {
                    "otp": otp,
                    "created_at": datetime.utcnow(),
                    "expires_at": datetime.utcnow() + timedelta(minutes=10)
                }
            }
        )

        # Send email with new OTP
        email_sent = await self.email_service.send_otp_email(email, otp, is_registration=True)
        if not email_sent:
            raise ValueError("Failed to send verification email")

        return otp

    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        return self.pwd_context.verify(plain_password, hashed_password)

    async def login(self, email: str, password: str) -> dict:
        # Find user by email
        user = await self.db.users.find_one({"email": email})
        if not user:
            raise ValueError("Invalid email or password")

        # Verify password
        if not self.verify_password(password, user["password"]):
            raise ValueError("Invalid email or password")

        # Convert ObjectId to string
        user["_id"] = str(user["_id"])

        # Generate access token
        access_token = self.create_access_token({"sub": str(user["_id"])})

        return {
            "access_token": access_token,
            "user": user
        }