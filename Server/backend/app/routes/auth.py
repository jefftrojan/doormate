from fastapi import APIRouter, HTTPException, Depends, Body
from pydantic import BaseModel
from ..models.user import UserCreate, User, UserLogin, OTPVerify  # Add OTPVerify import
from ..services.auth import AuthService
from typing import Dict

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
        result = await auth_service.verify_otp(verify_data.email, verify_data.otp)
        return {
            "token": result["token"],
            "user": result["user"],
            "success": True
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

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