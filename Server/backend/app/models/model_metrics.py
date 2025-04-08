from pydantic import BaseModel
from datetime import datetime
from typing import Dict, List

class ModelMetrics(BaseModel):
    version: str
    accuracy: float
    loss: float
    validation_accuracy: float
    validation_loss: float
    training_samples: int
    created_at: datetime = datetime.utcnow()
    performance_history: List[Dict[str, float]] = []