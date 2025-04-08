from fastapi import APIRouter, HTTPException, Depends, UploadFile
from ..models.user import UserProfile, PasswordUpdate, InitialPasswordSet
from ..services.profile import ProfileService
from ..utils.auth import get_current_user
from ..services.auth import AuthService

router = APIRouter()
profile_service = ProfileService()
auth_service = AuthService()

@router.put("/update")
async def update_profile(
    profile: UserProfile,
    current_user = Depends(get_current_user)
):
    try:
        updated_profile = await profile_service.update_profile(str(current_user["_id"]), profile)
        return updated_profile
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/upload-photo")
async def upload_photo(
    file: UploadFile,
    current_user = Depends(get_current_user)
):
    try:
        photo_url = await profile_service.upload_photo(str(current_user["_id"]), file)
        return {"url": photo_url}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.put("/update-password")
async def update_password(
    password_data: PasswordUpdate,
    current_user = Depends(get_current_user)
):
    try:
        # Verify current password
        if not auth_service.verify_password(password_data.current_password, current_user["password"]):
            raise HTTPException(status_code=400, detail="Current password is incorrect")
        
        # Update password
        result = await profile_service.update_password(str(current_user["_id"]), password_data.new_password)
        return {"success": True, "message": "Password updated successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.put("/set-initial-password")
async def set_initial_password(
    password_data: InitialPasswordSet,
    current_user = Depends(get_current_user)
):
    try:
        # Check if user has a temporary password (from registration)
        # We'll consider any user who hasn't changed their password yet as eligible
        
        # Update password without requiring the current password
        result = await profile_service.update_password(str(current_user["_id"]), password_data.new_password)
        
        # Mark the user as having set their password
        await profile_service.mark_password_set(str(current_user["_id"]))
        
        return {"success": True, "message": "Password set successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))