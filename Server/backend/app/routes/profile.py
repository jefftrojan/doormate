from fastapi import APIRouter, HTTPException, Depends, UploadFile
from ..models.user import UserProfile
from ..services.profile import ProfileService
from ..utils.auth import get_current_user

router = APIRouter()
profile_service = ProfileService()

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