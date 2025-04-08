from fastapi import APIRouter, HTTPException
from ..models.model_metrics import ModelMetrics
import os

router = APIRouter()

@router.get("/metrics")
async def get_model_metrics():
    try:
        # Get latest model metrics
        latest_metrics = await db.model_metrics.find_one(
            sort=[("created_at", -1)]
        )
        
        # Get performance trend
        performance_history = await db.model_metrics.find(
            {},
            {"accuracy": 1, "created_at": 1}
        ).sort("created_at", -1).limit(10).to_list(length=10)

        return {
            "current_metrics": latest_metrics,
            "performance_trend": performance_history,
            "total_models_trained": await db.model_metrics.count_documents({})
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/versions")
async def get_model_versions():
    try:
        versions = await db.model_metrics.find(
            {},
            {"version": 1, "accuracy": 1, "created_at": 1}
        ).sort("created_at", -1).to_list(length=5)
        
        return {
            "versions": versions,
            "current_version": versions[0] if versions else None
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))