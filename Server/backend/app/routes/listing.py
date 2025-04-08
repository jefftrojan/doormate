from fastapi import APIRouter, HTTPException, Depends, Query, File, UploadFile
from ..models.listing import Listing, ListingCreate, ListingUpdate
from ..services.listing import ListingService
from ..utils.auth import get_current_user
from typing import List, Optional
from bson import ObjectId
import aiofiles
import os

router = APIRouter()
listing_service = ListingService()

@router.get("/", response_model=List[Listing])
async def get_listings(
    skip: int = 0,
    limit: int = 10,
    type: Optional[str] = None,
    priceMin: Optional[float] = None,
    priceMax: Optional[float] = None,
    location: Optional[str] = None,
    sort_by: Optional[str] = Query(None, enum=['price_asc', 'price_desc', 'date_asc', 'date_desc']),
    current_user = Depends(get_current_user)
):
    try:
        listings = await listing_service.get_all_listings(
            skip=skip,
            limit=limit,
            search=type,
            min_price=priceMin,
            max_price=priceMax,
            location=location,
            sort_by=sort_by
        )
        return listings
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Specific routes with fixed paths come first
@router.get("/my-listings", response_model=List[Listing])
async def get_my_listings(
    current_user = Depends(get_current_user)
):
    try:
        listings = await listing_service.get_user_listings(str(current_user["_id"]))
        return listings
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error fetching listing : {str(e)}")

# Add saved listings route
@router.get("/saved", response_model=List[Listing])
async def get_saved_listings(
    current_user = Depends(get_current_user)
):
    try:
        listings = await listing_service.get_saved_listings(str(current_user["_id"]))
        return listings
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error fetching saved listings: {str(e)}")

# Save/unsave listing routes
@router.post("/{listing_id}/save", status_code=200)
async def save_listing(
    listing_id: str,
    current_user = Depends(get_current_user)
):
    try:
        success = await listing_service.save_listing(listing_id, str(current_user["_id"]))
        if success:
            return {"message": "Listing saved successfully"}
        else:
            raise HTTPException(status_code=404, detail="Listing not found")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error saving listing: {str(e)}")

@router.delete("/{listing_id}/save", status_code=200)
async def unsave_listing(
    listing_id: str,
    current_user = Depends(get_current_user)
):
    try:
        success = await listing_service.unsave_listing(listing_id, str(current_user["_id"]))
        if success:
            return {"message": "Listing unsaved successfully"}
        else:
            raise HTTPException(status_code=404, detail="Listing not found or was not saved")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error unsaving listing: {str(e)}")

@router.get("/university/{university}", response_model=List[Listing])
async def get_university_listings(
    university: str,
    skip: int = 0,
    limit: int = 10,
    current_user = Depends(get_current_user)
):
    try:
        listings = await listing_service.get_listings_by_university(
            university,
            skip=skip,
            limit=limit
        )
        return listings
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Most general parameterized route comes last
@router.get("/{listing_id}")
async def get_listing(
    listing_id: str,
    current_user = Depends(get_current_user)
):
    try:
        listing = await listing_service.get_listing_by_id(listing_id)
        if not listing:
            raise HTTPException(status_code=404, detail="Listing not found")
        return listing
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/", response_model=Listing)
async def create_listing(
    listing: ListingCreate,
    current_user = Depends(get_current_user)
):
    try:
        listing.user_id = str(current_user["_id"])
        new_listing = await listing_service.create_listing(listing)
        return new_listing
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.put("/{listing_id}", response_model=Listing)
async def update_listing(
    listing_id: str,
    listing: ListingUpdate,
    current_user = Depends(get_current_user)
):
    try:
        # Verify ownership
        existing_listing = await listing_service.get_listing_by_id(listing_id)
        if not existing_listing:
            raise HTTPException(status_code=404, detail="Listing not found")
        if str(existing_listing["user_id"]) != str(current_user["_id"]):
            raise HTTPException(status_code=403, detail="Not authorized to update this listing")
        
        updated_listing = await listing_service.update_listing(listing_id, listing)
        if not updated_listing:
            raise HTTPException(status_code=404, detail="Listing not found")
        return updated_listing
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{listing_id}")
async def delete_listing(
    listing_id: str,
    current_user = Depends(get_current_user)
):
    try:
        # Verify ownership
        existing_listing = await listing_service.get_listing_by_id(listing_id)
        if not existing_listing:
            raise HTTPException(status_code=404, detail="Listing not found")
        if str(existing_listing["user_id"]) != str(current_user["_id"]):
            raise HTTPException(status_code=403, detail="Not authorized to delete this listing")
        
        success = await listing_service.delete_listing(listing_id)
        if not success:
            raise HTTPException(status_code=404, detail="Listing not found")
        return {"message": "Listing deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/{listing_id}/images")
async def upload_listing_images(
    listing_id: str,
    images: List[UploadFile] = File(...),
    current_user = Depends(get_current_user)
):
    try:
        # Verify ownership
        existing_listing = await listing_service.get_listing_by_id(listing_id)
        if not existing_listing:
            raise HTTPException(status_code=404, detail="Listing not found")
        if str(existing_listing["user_id"]) != str(current_user["_id"]):
            raise HTTPException(status_code=403, detail="Not authorized")

        image_urls = []
        for image in images:
            image_url = await listing_service.upload_listing_image(listing_id, image)
            image_urls.append(image_url)

        # Update listing with new image URLs
        existing_listing["images"].extend(image_urls)
        await listing_service.update_listing(listing_id, {"images": existing_listing["images"]})

        return {"image_urls": image_urls}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))