from fastapi import APIRouter, HTTPException, Depends, Body
from pydantic import BaseModel
from ..models.user import UserCreate, User, UserLogin, OTPVerify  # Add OTPVerify import
from ..services.auth import AuthService
from typing import Dict
from ..models.user import User
from ..utils.email import send_verification_email
from ..schemas.auth import EmailVerificationRequest
from ..utils.otp import generate_otp
from ..utils.email_service import EmailService
from ..utils.otp_storage import store_otp_in_db  # Add this import
from ..schemas.auth import EmailVerificationRequest
import traceback
from datetime import datetime, timedelta
import os

router = APIRouter()
auth_service = AuthService()

@router.post("/register")
async def register(user_data: UserCreate):
    try:
        otp = await auth_service.register_user(user_data)
        return {
            "message": "OTP sent to email",
            "success": True,
            "email": user_data.email
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

# Add this class at the top with other imports
class VerifyOTPRequest(BaseModel):
    email: str
    otp: str

@router.post("/verify")
async def verify_otp(verify_data: VerifyOTPRequest):
    try:
        # Find OTP record
        otp_record = await auth_service.db.otps.find_one({
            "email": verify_data.email,
            "otp": verify_data.otp,
            "expires_at": {"$gt": datetime.utcnow()}
        })
        
        if not otp_record:
            raise ValueError("Invalid or expired OTP")
            
        # Check if user exists
        user = await auth_service.get_user_by_email(verify_data.email)
        
        # If user doesn't exist and we have user_data in the OTP record, create the user
        if not user and "user_data" in otp_record:
            # Create user from registration data
            user_data = otp_record["user_data"]
            user_data["verified"] = True
            user_data["created_at"] = datetime.utcnow()
            result = await auth_service.db.users.insert_one(user_data)
            user = await auth_service.db.users.find_one({"_id": result.inserted_id})
            print(f"Created new user from registration data: {user['_id']}")
        
        # If user doesn't exist and we don't have user_data, create a minimal user
        elif not user:
            # Create minimal user record
            minimal_user = {
                "email": verify_data.email,
                "fullName": "New User",
                "verified": True,
                "created_at": datetime.utcnow(),
                "email_verified": True
            }
            result = await auth_service.db.users.insert_one(minimal_user)
            user = await auth_service.db.users.find_one({"_id": result.inserted_id})
            print(f"Created minimal user: {user['_id']}")
        
        # Update user verification status
        await auth_service.db.users.update_one(
            {"_id": user["_id"]},
            {"$set": {"email_verified": True}}
        )
        
        # Delete used OTP
        await auth_service.db.otps.delete_many({"email": verify_data.email})
        
        # Convert ObjectId to string for JSON serialization
        user["_id"] = str(user["_id"])
        
        # Generate token
        token = auth_service.create_access_token({"sub": user["_id"]})
        
        return {
            "token": token,
            "user": user,
            "success": True
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        print(f"Verification error: {str(e)}")
        error_details = traceback.format_exc()
        print(f"Traceback: {error_details}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@router.post("/login")
async def login(user_data: UserLogin):
    try:
        result = await auth_service.login(user_data.email, user_data.password)
        return {
            "token": result["access_token"],
            "user": result["user"],
            "success": True
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/google")
async def google_auth(token: str):
    try:
        user_data = await auth_service.verify_google_token(token)
        return {"token": user_data["token"], "user": user_data["user"]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/regenerate-otp")
async def regenerate_otp(email: str = Body(...)):
    try:
        otp = await auth_service.regenerate_otp(email)
        return {
            "message": "New OTP sent to email",
            "success": True,
            "email": email
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/verify-email")
async def verify_email(request: EmailVerificationRequest):
    try:
        otp = generate_otp()
        
        # Store OTP first
        stored = await store_otp_in_db(request.email, otp)
        if not stored:
            raise HTTPException(status_code=500, detail="Failed to store OTP")
        
        # Send email if storage successful
        email_service = EmailService()
        success = await email_service.send_verification_email(request.email, otp)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to send verification email")
        
        return {"success": True, "message": "Verification email sent"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Add new endpoint for sending OTP
class SendOTPRequest(BaseModel):
    email: str

@router.post("/send-otp")
async def send_otp(request: SendOTPRequest):
    try:
        # Check if user exists
        user = await auth_service.get_user_by_email(request.email)
        
        # If user doesn't exist, create a temporary OTP record without requiring a user
        if not user:
            print(f"User not found for email {request.email}, creating temporary OTP")
            # Generate OTP
            otp = auth_service.generate_otp()
            print(f"Generated OTP for {request.email}: {otp}")
            
            # Store OTP in database without user data
            await auth_service.db.otps.insert_one({
                "email": request.email,
                "otp": otp,
                "created_at": datetime.utcnow(),
                "expires_at": datetime.utcnow() + timedelta(minutes=10)
            })
            
            # Send email
            email_sent = await auth_service.email_service.send_otp_email(request.email, otp, is_registration=True)
            
            # In development mode, we don't want to fail if email sending fails
            is_dev_mode = os.getenv('ENVIRONMENT', 'development') == 'development'
            if not email_sent and not is_dev_mode:
                raise ValueError("Failed to send verification email")
            
            if not email_sent and is_dev_mode:
                print(f"MOCK EMAIL SENT to {request.email}: OTP: {otp}")
            
            return {
                "message": "OTP sent to email",
                "success": True,
                "email": request.email
            }
        
        # If user exists, send login OTP
        await auth_service.send_login_otp(request.email)
        
        return {
            "message": "OTP sent to email",
            "success": True,
            "email": request.email
        }
    except ValueError as e:
        print(f"ValueError in send_otp: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        error_details = traceback.format_exc()
        print(f"Error sending OTP: {str(e)}")
        print(f"Traceback: {error_details}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

# Add new endpoint for resending OTP
@router.post("/resend-otp")
async def resend_otp(request: SendOTPRequest):
    try:
        # Try to regenerate OTP
        otp = await auth_service.regenerate_otp(request.email)
        
        return {
            "message": "New OTP sent to email",
            "success": True,
            "email": request.email
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        error_details = traceback.format_exc()
        print(f"Error resending OTP: {str(e)}")
        print(f"Traceback: {error_details}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

# Add new endpoint for login with OTP
class LoginWithOTPRequest(BaseModel):
    email: str

@router.post("/login-with-otp")
async def login_with_otp(request: LoginWithOTPRequest):
    try:
        # Check if user exists
        user = await auth_service.get_user_by_email(request.email)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # Generate and send OTP
        otp = auth_service.generate_otp()
        
        # Store OTP in database
        await auth_service.db.otps.insert_one({
            "email": request.email,
            "otp": otp,
            "created_at": datetime.utcnow(),
            "expires_at": datetime.utcnow() + timedelta(minutes=10)
        })
        
        # Send email
        email_sent = await auth_service.email_service.send_otp_email(request.email, otp, is_registration=False)
        
        # In development mode, we don't want to fail login if email sending fails
        is_dev_mode = os.getenv('ENVIRONMENT', 'development') == 'development'
        if not email_sent and not is_dev_mode:
            raise ValueError("Failed to send login code")
        
        if not email_sent and is_dev_mode:
            print(f"MOCK EMAIL SENT to {request.email}: OTP: {otp}")
        
        return {
            "message": "OTP sent to email",
            "success": True,
            "email": request.email
        }
    except ValueError as e:
        print(f"ValueError in login_with_otp: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        error_details = traceback.format_exc()
        print(f"Error in login_with_otp: {str(e)}")
        print(f"Traceback: {error_details}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

# Add a new endpoint specifically for mobile app OTP
class MobileOTPRequest(BaseModel):
    email: str
    action: str = "send"  # "send" or "verify"
    otp: str = None

@router.post("/mobile-otp")
async def mobile_otp(request: MobileOTPRequest):
    try:
        if request.action == "send":
            # Generate OTP
            otp = auth_service.generate_otp()
            print(f"Generated OTP for {request.email}: {otp}")
            
            # Store OTP in database
            await auth_service.db.otps.insert_one({
                "email": request.email,
                "otp": otp,
                "created_at": datetime.utcnow(),
                "expires_at": datetime.utcnow() + timedelta(minutes=10)
            })
            
            # Send email
            email_sent = await auth_service.email_service.send_otp_email(request.email, otp, is_registration=False)
            
            # In development mode, we don't want to fail if email sending fails
            is_dev_mode = os.getenv('ENVIRONMENT', 'development') == 'development'
            if not email_sent and not is_dev_mode:
                raise ValueError("Failed to send verification email")
            
            if not email_sent and is_dev_mode:
                print(f"MOCK EMAIL SENT to {request.email}: OTP: {otp}")
            
            return {
                "message": "OTP sent to email",
                "success": True,
                "email": request.email
            }
        
        elif request.action == "verify":
            if not request.otp:
                raise ValueError("OTP is required for verification")
                
            # Find OTP record
            otp_record = await auth_service.db.otps.find_one({
                "email": request.email,
                "otp": request.otp,
                "expires_at": {"$gt": datetime.utcnow()}
            })
            
            if not otp_record:
                raise ValueError("Invalid or expired OTP")
                
            # Check if user exists
            user = await auth_service.get_user_by_email(request.email)
            
            # If user doesn't exist, create a minimal user
            if not user:
                # Create minimal user record
                minimal_user = {
                    "email": request.email,
                    "fullName": "New User",
                    "verified": True,
                    "created_at": datetime.utcnow(),
                    "email_verified": True
                }
                result = await auth_service.db.users.insert_one(minimal_user)
                user = await auth_service.db.users.find_one({"_id": result.inserted_id})
                print(f"Created minimal user: {user['_id']}")
            
            # Update user verification status
            await auth_service.db.users.update_one(
                {"_id": user["_id"]},
                {"$set": {"email_verified": True}}
            )
            
            # Delete used OTP
            await auth_service.db.otps.delete_many({"email": request.email})
            
            # Convert ObjectId to string for JSON serialization
            user["_id"] = str(user["_id"])
            
            # Generate token
            token = auth_service.create_access_token({"sub": user["_id"]})
            
            return {
                "token": token,
                "user": user,
                "success": True
            }
        
        else:
            raise ValueError(f"Invalid action: {request.action}. Must be 'send' or 'verify'")
            
    except ValueError as e:
        print(f"ValueError in mobile_otp: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        error_details = traceback.format_exc()
        print(f"Error in mobile_otp: {str(e)}")
        print(f"Traceback: {error_details}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")