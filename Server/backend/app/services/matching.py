from typing import Dict, List
import numpy as np
from .model import MatchingModel

class MatchingService:
    def __init__(self):
        self.model = MatchingModel()
        
    def calculate_compatibility(self, user_prefs: Dict, other_prefs: Dict) -> Dict:
        # ML model prediction
        ml_score = self.model.predict_compatibility(user_prefs, other_prefs)
        
        # Direct preference matching
        cleanliness_match = self._calculate_cleanliness_match(
            user_prefs.get('cleanliness'),
            other_prefs.get('cleanliness')
        )
        
        noise_match = self._calculate_noise_match(
            user_prefs.get('noiseLevel'),
            other_prefs.get('noiseLevel')
        )
        
        schedule_match = self._calculate_schedule_match(
            user_prefs.get('studyHabits'),
            other_prefs.get('studyHabits')
        )
        
        budget_match = self._calculate_budget_match(
            user_prefs.get('budget'),
            other_prefs.get('budget')
        )
        
        # Weighted average of all factors
        total_score = (
            ml_score * 0.4 +
            cleanliness_match * 0.2 +
            noise_match * 0.2 +
            schedule_match * 0.1 +
            budget_match * 0.1
        )
        
        return {
            "total_score": total_score,
            "breakdown": {
                "ml_score": ml_score,
                "cleanliness_match": cleanliness_match,
                "noise_match": noise_match,
                "schedule_match": schedule_match,
                "budget_match": budget_match
            }
        }
    
    def _calculate_cleanliness_match(self, user_level: int, other_level: int) -> float:
        if user_level is None or other_level is None:
            return 0.5
        return 1 - (abs(user_level - other_level) / 4)
    
    def _calculate_noise_match(self, user_level: float, other_level: float) -> float:
        if user_level is None or other_level is None:
            return 0.5
        return 1 - (abs(user_level - other_level) / 100)
    
    def _calculate_schedule_match(self, user_habit: str, other_habit: str) -> float:
        if user_habit is None or other_habit is None:
            return 0.5
        return 1.0 if user_habit.lower() == other_habit.lower() else 0.3
    
    def _calculate_budget_match(self, user_budget: float, other_budget: float) -> float:
        if user_budget is None or other_budget is None:
            return 0.5
        diff = abs(user_budget - other_budget)
        return max(0, 1 - (diff / 1000))  # Normalize by $1000 difference